Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1676B82F64
	for <linux-mm@kvack.org>; Sat,  7 Nov 2015 09:24:34 -0500 (EST)
Received: by pasz6 with SMTP id z6so156056485pas.2
        for <linux-mm@kvack.org>; Sat, 07 Nov 2015 06:24:33 -0800 (PST)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id hd6si8156418pac.124.2015.11.07.06.24.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Nov 2015 06:24:33 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so18973401pab.3
        for <linux-mm@kvack.org>; Sat, 07 Nov 2015 06:24:32 -0800 (PST)
Date: Sat, 7 Nov 2015 23:23:09 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: + memcg-fix-thresholds-for-32b-architectures-fix-fix.patch added
 to -mm tree
Message-ID: <20151107142309.GA537@swordfish>
References: <563943fb.IYtEMWL7tCGWBkSl%akpm@linux-foundation.org>
 <20151104091804.GE29607@dhcp22.suse.cz>
 <20151105183132.0a5f874c7f5f69b3c2e53dd1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105183132.0a5f874c7f5f69b3c2e53dd1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, ben@decadent.org.uk, hannes@cmpxchg.org, vdavydov@virtuozzo.com, linux-mm@kvack.org

Hi,

On (11/05/15 18:31), Andrew Morton wrote:
> > On Tue 03-11-15 15:32:11, Andrew Morton wrote:
> > > From: Andrew Morton <akpm@linux-foundation.org>
> > > Subject: memcg-fix-thresholds-for-32b-architectures-fix-fix
> > > 
> > > don't attempt to inline mem_cgroup_usage()
> > > 
> > > The compiler ignores the inline anwyay.  And __always_inlining it adds 600
> > > bytes of goop to the .o file.
> > 
> > I am not sure you whether you want to fold this into the original patch
> > but I would prefer this to be a separate one.
> 
> I'm going to drop this - it was already marked inline and gcc just
> ignores the inline anyway so shrug.
> 

Just out of curiosity, seems that my gcc (5.2) is happy to inline
it (as of linux-next-20151106):

$ grep 'mem_cgroup_usage ' __ipa_build_log
  Inlining page_counter_read into mem_cgroup_usage (always_inline).
  Inlining page_counter_read into mem_cgroup_usage (always_inline).
  Inlining mem_cgroup_is_root into mem_cgroup_usage (always_inline).
  Inlining mem_cgroup_usage into mem_cgroup_read_u64 (always_inline).
  Inlining mem_cgroup_usage into mem_cgroup_read_u64 (always_inline).
  Inlining mem_cgroup_usage into __mem_cgroup_threshold (always_inline).
  Inlining mem_cgroup_usage into __mem_cgroup_usage_unregister_event (always_inline).
  Inlining mem_cgroup_usage into __mem_cgroup_usage_unregister_event (always_inline).
  Inlining mem_cgroup_usage into __mem_cgroup_usage_register_event (always_inline).
  Inlining mem_cgroup_usage into __mem_cgroup_usage_register_event (always_inline).


and the resulting vmlinux.o files

$ ./scripts/bloat-o-meter vmlinux.o.old vmlinux.o
add/remove: 1/0 grow/shrink: 0/4 up/down: 113/-351 (-238)
function                                     old     new   delta
mem_cgroup_usage                               -     113    +113
__mem_cgroup_usage_unregister_event          409     331     -78
__mem_cgroup_threshold                       529     447     -82
__mem_cgroup_usage_register_event            498     403     -95
mem_cgroup_read_u64                          256     160     -96

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
