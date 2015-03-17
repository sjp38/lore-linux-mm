Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8A33C6B0032
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 10:06:47 -0400 (EDT)
Received: by obcxo2 with SMTP id xo2so7895884obc.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 07:06:47 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id kv4si29539172pab.101.2015.03.17.07.06.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Mar 2015 07:06:46 -0700 (PDT)
Subject: Re: [PATCH 0/2] Move away from non-failing small allocations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
	<20150316153843.af945a9e452404c22c4db999@linux-foundation.org>
	<20150317090738.GB28112@dhcp22.suse.cz>
In-Reply-To: <20150317090738.GB28112@dhcp22.suse.cz>
Message-Id: <201503172305.DIH52162.FOFMFOVJHLOtQS@I-love.SAKURA.ne.jp>
Date: Tue, 17 Mar 2015 23:06:34 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Mon 16-03-15 15:38:43, Andrew Morton wrote:
> > Realistically, I don't think this overall effort will be successful -
> > we'll add the knob, it won't get enough testing and any attempt to
> > alter the default will be us deliberately destabilizing the kernel
> > without knowing how badly :(
> 
> Without the knob we do not allow users to test this at all though and
> the transition will _never_ happen. Which is IMHO bad.
> 

Even with the knob, quite little users will test this. The consequence is
likely that end users rush into customer support center about obscure bugs.
I'm working at a support center, and such bugs are really annoying.

> > I wonder if we can alter the behaviour only for filesystem code, so we
> > constrain the new behaviour just to that code where we're having
> > problems.  Most/all fs code goes via vfs methods so there's a reasonably
> > small set of places where we can call
> 
> We are seeing issues with the fs code now because the test cases which
> led to the current discussion exercise FS code. The code which does
> lock(); kmalloc(GFP_KERNEL) is not reduced there though. I am pretty sure
> we can find other subsystems if we try hard enough.

I'm expecting for patches which avoids deadlock by lock(); kmalloc(GFP_KERNEL).

> > static inline void enter_fs_code(struct super_block *sb)
> > {
> > 	if (sb->my_small_allocations_can_fail)
> > 		current->small_allocations_can_fail++;
> > }
> > 
> > that way (or something similar) we can select the behaviour on a per-fs
> > basis and the rest of the kernel remains unaffected.  Other subsystems
> > can opt in as well.
> 
> This is basically leading to GFP_MAYFAIL which is completely backwards
> (the hard requirement should be an exception not a default rule).
> I really do not want to end up with stuffing random may_fail annotations
> all over the kernel.
> 

I wish that GFP_NOFS / GFP_NOIO regions are annotated with

  static inline void enter_fs_code(void)
  {
  #ifdef CONFIG_DEBUG_GFP_FLAGS
  	current->in_fs_code++;
  #endif
  }

  static inline void leave_fs_code(void)
  {
  #ifdef CONFIG_DEBUG_GFP_FLAGS
  	current->in_fs_code--;
  #endif
  }

  static inline void enter_io_code(void)
  {
  #ifdef CONFIG_DEBUG_GFP_FLAGS
  	current->in_io_code++;
  #endif
  }

  static inline void leave_io_code(void)
  {
  #ifdef CONFIG_DEBUG_GFP_FLAGS
  	current->in_io_code--;
  #endif
  }

so that inappropriate GFP_KERNEL usage inside GFP_NOFS region are catchable
by doing

  struct page *
  __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
                          struct zonelist *zonelist, nodemask_t *nodemask)
  {
  	struct zoneref *preferred_zoneref;
  	struct page *page = NULL;
  	unsigned int cpuset_mems_cookie;
  	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
  	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
  	struct alloc_context ac = {
  		.high_zoneidx = gfp_zone(gfp_mask),
  		.nodemask = nodemask,
  		.migratetype = gfpflags_to_migratetype(gfp_mask),
  	};
  	
  	gfp_mask &= gfp_allowed_mask;
 +#ifdef CONFIG_DEBUG_GFP_FLAGS
 +	WARN_ON(current->in_fs_code & (gfp_mask & __GFP_FS));
 +	WARN_ON(current->in_io_code & (gfp_mask & __GFP_IO));
 +#endif
  
  	lockdep_trace_alloc(gfp_mask);
  

. It is difficult for non-fs developers to determine whether they need to use
GFP_NOFS than GFP_KERNEL in their code. An example is seen at
http://marc.info/?l=linux-security-module&m=138556479607024&w=2 .

Moreover, I don't know how GFP flags are managed when stacked like
"a swap file on ext4 on top of LVM (with snapshots) on a RAID array
connected over iSCSI" (quoted from comments on Jon's writeup), but I
wish that the distinction between GFP_KERNEL / GFP_NOFS / GFP_NOIO
are removed from memory allocating function callers by doing

  static inline void enter_fs_code(void)
  {
  	current->in_fs_code++;
  }

  static inline void leave_fs_code(void)
  {
  	current->in_fs_code--;
  }

  static inline void enter_io_code(void)
  {
  	current->in_io_code++;
  }

  static inline void leave_io_code(void)
  {
  	current->in_io_code--;
  }

  struct page *
  __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
                          struct zonelist *zonelist, nodemask_t *nodemask)
  {
  	struct zoneref *preferred_zoneref;
  	struct page *page = NULL;
  	unsigned int cpuset_mems_cookie;
  	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
  	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
  	struct alloc_context ac = {
  		.high_zoneidx = gfp_zone(gfp_mask),
  		.nodemask = nodemask,
  		.migratetype = gfpflags_to_migratetype(gfp_mask),
  	};
  	
  	gfp_mask &= gfp_allowed_mask;
 +	if (current->in_fs_code)
 +		gfp_mask &= ~__GFP_FS;
 +	if (current->in_io_code)
 +		gfp_mask &= ~__GFP_IO;
  
  	lockdep_trace_alloc(gfp_mask);
  

so that GFP flags passed to memory allocations involved by stacking
will be appropriately masked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
