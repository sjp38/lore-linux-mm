Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF886B02C3
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 08:08:28 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x28so6143530wma.7
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 05:08:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e143si659226wme.95.2017.08.11.05.08.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Aug 2017 05:08:26 -0700 (PDT)
Date: Fri, 11 Aug 2017 14:08:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom: fix potential data corruption when
 oom_reaper races with writer
Message-ID: <20170811120825.GG30811@dhcp22.suse.cz>
References: <20170807113839.16695-1-mhocko@kernel.org>
 <20170807113839.16695-3-mhocko@kernel.org>
 <201708111128.FEE39036.HFVSQFOtOMLFJO@I-love.SAKURA.ne.jp>
 <20170811070938.GA30811@dhcp22.suse.cz>
 <201708111654.JCH34360.OMOLVFQJOStHFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708111654.JCH34360.OMOLVFQJOStHFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, andrea@kernel.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 11-08-17 16:54:36, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 11-08-17 11:28:52, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > +/*
> > > > + * Checks whether a page fault on the given mm is still reliable.
> > > > + * This is no longer true if the oom reaper started to reap the
> > > > + * address space which is reflected by MMF_UNSTABLE flag set in
> > > > + * the mm. At that moment any !shared mapping would lose the content
> > > > + * and could cause a memory corruption (zero pages instead of the
> > > > + * original content).
> > > > + *
> > > > + * User should call this before establishing a page table entry for
> > > > + * a !shared mapping and under the proper page table lock.
> > > > + *
> > > > + * Return 0 when the PF is safe VM_FAULT_SIGBUS otherwise.
> > > > + */
> > > > +static inline int check_stable_address_space(struct mm_struct *mm)
> > > > +{
> > > > +	if (unlikely(test_bit(MMF_UNSTABLE, &mm->flags)))
> > > > +		return VM_FAULT_SIGBUS;
> > > > +	return 0;
> > > > +}
> > > > +
> > > 
> > > Will you explain the mechanism why random values are written instead of zeros
> > > so that this patch can actually fix the race problem?
> > 
> > I am not sure what you mean here. Were you able to see a write with an
> > unexpected content?
> 
> Yes. See http://lkml.kernel.org/r/201708072228.FAJ09347.tOOVOFFQJSHMFL@I-love.SAKURA.ne.jp .

Ahh, I've missed that random part of your output. That is really strange
because AFAICS the oom reaper shouldn't really interact here. We are
only unmapping anonymous memory and even if a refault slips through we
should always get zeros.

Your test case doesn't mmap MAP_PRIVATE of a file so we shouldn't even
get any uninitialized data from a file by missing CoWed content. The
only possible explanations would be that a page fault returned a
non-zero data which would be a bug on its own or that a file write
extend the file without actually writing to it which smells like a fs
bug to me.

Anyway I wasn't able to reproduce this and I was running your usecase
in the loop for quite some time (with xfs storage). How reproducible
is this? If you can reproduce easily can you simply comment out
unmap_page_range in __oom_reap_task_mm and see if that makes any change
just to be sure that the oom reaper can be ruled out?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
