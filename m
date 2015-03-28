Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4E50A6B0038
	for <linux-mm@kvack.org>; Sat, 28 Mar 2015 07:41:42 -0400 (EDT)
Received: by wixm2 with SMTP id m2so51493807wix.0
        for <linux-mm@kvack.org>; Sat, 28 Mar 2015 04:41:41 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id ex9si8517017wid.93.2015.03.28.04.41.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Mar 2015 04:41:40 -0700 (PDT)
Date: Sat, 28 Mar 2015 12:41:38 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Message-ID: <20150328114138.GI27490@worktop.programming.kicks-ass.net>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
 <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
 <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
 <20150327091613.GE27490@worktop.programming.kicks-ass.net>
 <20150327093023.GA32047@worktop.ger.corp.intel.com>
 <alpine.DEB.2.11.1503270610430.19514@gentwo.org>
 <20150327120240.GC23123@twins.programming.kicks-ass.net>
 <CAKohpomiqOcmZe+tAPNv_kX=+FmtMu8K=Qgze1y2SvgJ1A16NQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKohpomiqOcmZe+tAPNv_kX=+FmtMu8K=Qgze1y2SvgJ1A16NQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, dave@stgolabs.net, Konstantin Khlebnikov <koct9i@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Sat, Mar 28, 2015 at 09:58:38AM +0530, Viresh Kumar wrote:
> On 27 March 2015 at 17:32, Peter Zijlstra <peterz@infradead.org> wrote:
> > What's not clear to me is why that thing is allocated at all, AFAICT
> > something like:
> >
> > static DEFINE_PER_CPU(struct tvec_base, tvec_bases);
> >
> > Should do the right thing and be much simpler.
> 
> Does this comment from timers.c answers your query ?
> 
>                         /*
>                          * This is for the boot CPU - we use compile-time
>                          * static initialisation because per-cpu memory isn't
>                          * ready yet and because the memory allocators are not
>                          * initialised either.
>                          */

No. The reason is because __TIMER_INITIALIZER() needs to set ->base to a
valid pointer and we cannot get a compile time pointer to per-cpu
entries because we don't know where we'll map the section, even for the
boot cpu.

This in turn means we need that boot_tvec_bases thing.

Now the reason we need to set ->base to a valid pointer is because we've
made NULL special.

Arguably we could create another special pointer, but since that's init
time only we get to add code for that will 'never' be used, more special
cases.

Its all a bit of a bother, but it makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
