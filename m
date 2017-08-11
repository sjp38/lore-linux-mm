Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 798B06B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 03:54:49 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t18so3118779oih.11
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 00:54:49 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c84si184325oif.540.2017.08.11.00.54.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Aug 2017 00:54:47 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, oom: fix potential data corruption when oom_reaper races with writer
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170807113839.16695-1-mhocko@kernel.org>
	<20170807113839.16695-3-mhocko@kernel.org>
	<201708111128.FEE39036.HFVSQFOtOMLFJO@I-love.SAKURA.ne.jp>
	<20170811070938.GA30811@dhcp22.suse.cz>
In-Reply-To: <20170811070938.GA30811@dhcp22.suse.cz>
Message-Id: <201708111654.JCH34360.OMOLVFQJOStHFF@I-love.SAKURA.ne.jp>
Date: Fri, 11 Aug 2017 16:54:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, andrea@kernel.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 11-08-17 11:28:52, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > +/*
> > > + * Checks whether a page fault on the given mm is still reliable.
> > > + * This is no longer true if the oom reaper started to reap the
> > > + * address space which is reflected by MMF_UNSTABLE flag set in
> > > + * the mm. At that moment any !shared mapping would lose the content
> > > + * and could cause a memory corruption (zero pages instead of the
> > > + * original content).
> > > + *
> > > + * User should call this before establishing a page table entry for
> > > + * a !shared mapping and under the proper page table lock.
> > > + *
> > > + * Return 0 when the PF is safe VM_FAULT_SIGBUS otherwise.
> > > + */
> > > +static inline int check_stable_address_space(struct mm_struct *mm)
> > > +{
> > > +	if (unlikely(test_bit(MMF_UNSTABLE, &mm->flags)))
> > > +		return VM_FAULT_SIGBUS;
> > > +	return 0;
> > > +}
> > > +
> > 
> > Will you explain the mechanism why random values are written instead of zeros
> > so that this patch can actually fix the race problem?
> 
> I am not sure what you mean here. Were you able to see a write with an
> unexpected content?

Yes. See http://lkml.kernel.org/r/201708072228.FAJ09347.tOOVOFFQJSHMFL@I-love.SAKURA.ne.jp .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
