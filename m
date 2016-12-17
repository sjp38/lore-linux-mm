Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE73C6B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 19:28:26 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id y71so224240194pgd.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 16:28:26 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id n19si9942125pfk.284.2016.12.16.16.28.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 16:28:25 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id p66so11190286pga.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 16:28:25 -0800 (PST)
Date: Fri, 16 Dec 2016 16:28:21 -0800
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 1/2] bpf: do not use KMALLOC_SHIFT_MAX
Message-ID: <20161217002820.GB5359@ast-mbp.thefacebook.com>
References: <20161215164722.21586-1-mhocko@kernel.org>
 <20161215164722.21586-2-mhocko@kernel.org>
 <20161216180209.GA77597@ast-mbp.thefacebook.com>
 <20161216220235.GD7645@dhcp22.suse.cz>
 <20161216232340.GA99159@ast-mbp.thefacebook.com>
 <20161216233917.GB23392@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216233917.GB23392@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Cristopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>

On Sat, Dec 17, 2016 at 12:39:17AM +0100, Michal Hocko wrote:
> On Fri 16-12-16 15:23:42, Alexei Starovoitov wrote:
> > On Fri, Dec 16, 2016 at 11:02:35PM +0100, Michal Hocko wrote:
> > > On Fri 16-12-16 10:02:10, Alexei Starovoitov wrote:
> > > > On Thu, Dec 15, 2016 at 05:47:21PM +0100, Michal Hocko wrote:
> > > > > From: Michal Hocko <mhocko@suse.com>
> > > > > 
> > > > > 01b3f52157ff ("bpf: fix allocation warnings in bpf maps and integer
> > > > > overflow") has added checks for the maximum allocateable size. It
> > > > > (ab)used KMALLOC_SHIFT_MAX for that purpose. While this is not incorrect
> > > > > it is not very clean because we already have KMALLOC_MAX_SIZE for this
> > > > > very reason so let's change both checks to use KMALLOC_MAX_SIZE instead.
> > > > > 
> > > > > Cc: Alexei Starovoitov <ast@kernel.org>
> > > > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > > 
> > > > Nack until the patches 1 and 2 are reversed.
> > > 
> > > I do not insist on ordering. The thing is that it shouldn't matter all
> > > that much. Or are you worried about bisectability?
> > 
> > This patch 1 strongly depends on patch 2 !
> > Therefore order matters.
> > The patch 1 by itself is broken.
> > The commit log is saying
> > '(ab)used KMALLOC_SHIFT_MAX for that purpose .. use KMALLOC_MAX_SIZE instead'
> > that is also incorrect. We cannot do that until KMALLOC_MAX_SIZE is fixed.
> > So please change the order
> 
> Yes, I agree that using KMALLOC_MAX_SIZE could lead to a warning with
> the current ordering. Why that matters all that much is less clear to
> me. The allocation would simply fail and you would return ENOMEM rather
> than E2BIG. Does this really matter?
> 
> Anyway, as I've said, I do not really insist on the current ordering and
> the will ask Andrew to reorder them. I am just really wondering about
> such a strong pushback about something that barely matters. Or maybe I
> am just missing your point and checking KMALLOC_MAX_SIZE without an
> update would lead to a wrong behavior, user space breakage, crash or
> anything similar.

if admin set ulimit for locked memory high enough for the particular user,
that non-root user will be able to trigger warn_on_once in __alloc_pages_slowpath
which is not acceptable.
Also see the comment in hashtab.c
  if (htab->map.value_size >= (1 << (KMALLOC_SHIFT_MAX - 1)) -
      MAX_BPF_STACK - sizeof(struct htab_elem))
          /* if value_size is bigger, the user space won't be able to
           * access the elements via bpf syscall. This check also makes
           * sure that the elem_size doesn't overflow and it's
           * kmalloc-able later in htab_map_update_elem()
           */
          goto free_htab;

> > and fix the commit log to say that KMALLOC_MAX_SIZE
> > is actually valid limit now.
> 
> KMALLOC_MAX_SIZE has always been the right limit. It's value has been
> incorrect but that is to be fixed now. Using KMALLOC_SHIFT_MAX is simply
> abusing an internal constant. So I am not sure what should be fixed in
> the changelog.

that's exactly my problem with this patch and the commit log.
You think it's abusing KMALLOC_SHIFT_MAX whereas it's doing so
for reasons stated above.
That piece of code cannot use KMALLOC_MAX_SIZE until it's fixed.
So commit log should say something like:
"now since KMALLOC_MAX_SIZE is fixed and size < KMALLOC_MAX_SIZE condition
guarantees warn free allocation in kmalloc(value_size, GFP_USER | __GFP_NOWARN);
we can safely use KMALLOC_MAX_SIZE instead of KMALLOC_SHIFT_MAX"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
