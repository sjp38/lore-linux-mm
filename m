Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3106B0038
	for <linux-mm@kvack.org>; Sat, 28 Mar 2015 05:53:33 -0400 (EDT)
Received: by wixm2 with SMTP id m2so50331644wix.0
        for <linux-mm@kvack.org>; Sat, 28 Mar 2015 02:53:32 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id hj13si8200253wib.39.2015.03.28.02.53.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Mar 2015 02:53:31 -0700 (PDT)
Date: Sat, 28 Mar 2015 10:53:22 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Message-ID: <20150328095322.GH27490@worktop.programming.kicks-ass.net>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
 <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
 <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
 <20150327091613.GE27490@worktop.programming.kicks-ass.net>
 <20150327093023.GA32047@worktop.ger.corp.intel.com>
 <CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, mgorman@suse.de, dave@stgolabs.net, koct9i@gmail.com, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Sat, Mar 28, 2015 at 09:48:28AM +0530, Viresh Kumar wrote:
> On Fri, Mar 27, 2015 at 3:00 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Fri, Mar 27, 2015 at 10:16:13AM +0100, Peter Zijlstra wrote:
> 
> >> So the issue seems to be that we need base->running_timer in order to
> >> tell if a callback is running, right?
> >>
> >> We could align the base on 8 bytes to gain an extra bit in the pointer
> >> and use that bit to indicate the running state. Then these sites can
> >> spin on that bit while we can change the actual base pointer.
> >
> > Even though tvec_base has ____cacheline_aligned stuck on, most are
> > allocated using kzalloc_node() which does not actually respect that but
> > already guarantees a minimum u64 alignment, so I think we can use that
> > third bit without too much magic.
> 
> Right. So what I tried earlier was very much similar to you are suggesting.
> The only difference was that I haven't made much attempts towards
> saving memory.
> 
> But Thomas didn't like it for sure and I believe that Rant will hold true for
> what you are suggesting as well, isn't it ?
> 
> http://lists.linaro.org/pipermail/linaro-kernel/2013-November/008866.html

Well, for one your patch is indeed disgusting. But yes I'm aware Thomas
wants to rewrite the timer thing. But Thomas is away for a little while
and if this really needs to happen then it does.

Alternatively the thing hocko suggests is an utter fail too. You cannot
stuff that into hardirq context, that's insane.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
