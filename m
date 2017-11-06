Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 203066B026E
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 05:56:05 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y83so2561544wmc.8
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 02:56:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o35si7650695edd.385.2017.11.06.02.56.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 02:56:03 -0800 (PST)
Date: Mon, 6 Nov 2017 11:56:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: use in_atomic() in print_vma_addr()
Message-ID: <20171106105601.4evsp63q5xb2drc2@dhcp22.suse.cz>
References: <1509572313-102989-1-git-send-email-yang.s@alibaba-inc.com>
 <20171102075744.whhxjmqbdkfaxghd@dhcp22.suse.cz>
 <ace5b078-652b-cbc0-176a-25f69612f7fa@alibaba-inc.com>
 <20171103110245.7049460a05cc18c7e8a9feb2@linux-foundation.org>
 <1509739786.2473.33.camel@wdc.com>
 <20171105081946.yr2pvalbegxygcky@dhcp22.suse.cz>
 <20171106100558.GD3165@worktop.lehotels.local>
 <20171106104354.2jlgd2m4j4gxx4qo@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171106104354.2jlgd2m4j4gxx4qo@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Bart Van Assche <Bart.VanAssche@wdc.com>, "yang.s@alibaba-inc.com" <yang.s@alibaba-inc.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "joe@perches.com" <joe@perches.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mingo@redhat.com" <mingo@redhat.com>

On Mon 06-11-17 11:43:54, Michal Hocko wrote:
> On Mon 06-11-17 11:05:58, Peter Zijlstra wrote:
> > On Sun, Nov 05, 2017 at 09:19:46AM +0100, Michal Hocko wrote:
> > > [CC Peter]
> > > 
> > > On Fri 03-11-17 20:09:49, Bart Van Assche wrote:
> > > > On Fri, 2017-11-03 at 11:02 -0700, Andrew Morton wrote:
> > > > > Also, checkpatch says
> > > > > 
> > > > > WARNING: use of in_atomic() is incorrect outside core kernel code
> > > > > #43: FILE: mm/memory.c:4491:
> > > > > +       if (in_atomic())
> > > > > 
> > > > > I don't recall why we did that, but perhaps this should be revisited?
> > > > 
> > > > Is the comment above in_atomic() still up-to-date? From <linux/preempt.h>:
> > > > 
> > > > /*
> > > >  * Are we running in atomic context?  WARNING: this macro cannot
> > > >  * always detect atomic context; in particular, it cannot know about
> > > >  * held spinlocks in non-preemptible kernels.  Thus it should not be
> > > >  * used in the general case to determine whether sleeping is possible.
> > > >  * Do not use in_atomic() in driver code.
> > > >  */
> > > > #define in_atomic()	(preempt_count() != 0)
> > > 
> > > I can still see preempt_disable NOOP for !CONFIG_PREEMPT_COUNT kernels
> > > which makes me think this is still a valid comment.
> > 
> > Yes the comment is very much accurate.
> 
> Which suggests that print_vma_addr might be problematic, right?
> Shouldn't we do trylock on mmap_sem instead?

I might be missing something but the check seems to be broken. The
original commit by Ingo e8bff74afbdb ("x86: fix "BUG: sleeping function
called from invalid context" in print_vma_addr()") relied on elevated
preempt count by preempt_conditional_sti which is gone for quite some
time. First replaced by explicit preempt_disable in d99e1bd175f4
("x86/entry/traps: Refactor preemption and interrupt flag handling").

So unless I am missing something this check doesn't work and we should
rather do the trylock thing.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
