Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 98F2F6B0032
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 05:16:24 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so22526746wia.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 02:16:24 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id hi10si2936465wib.37.2015.03.27.02.16.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 02:16:23 -0700 (PDT)
Date: Fri, 27 Mar 2015 10:16:13 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Message-ID: <20150327091613.GE27490@worktop.programming.kicks-ass.net>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
 <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
 <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, mgorman@suse.de, dave@stgolabs.net, koct9i@gmail.com, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Fri, Mar 27, 2015 at 10:19:54AM +0530, Viresh Kumar wrote:
> On 27 March 2015 at 01:48, Andrew Morton <akpm@linux-foundation.org> wrote:
> > Shouldn't this be viewed as a shortcoming of the core timer code?
> 
> Yeah, it is. Some (not so pretty) solutions were tried earlier to fix that, but
> they are rejected for obviously reasons [1].
> 
> > vmstat_shepherd() is merely rescheduling itself with
> > schedule_delayed_work().  That's a dead bog simple operation and if
> > it's producing suboptimal behaviour then we shouldn't be fixing it with
> > elaborate workarounds in the caller?
> 
> I understand that, and that's why I sent it as an RFC to get the discussion
> started. Does anyone else have got another (acceptable) idea to get this
> resolved ?

So the issue seems to be that we need base->running_timer in order to
tell if a callback is running, right?

We could align the base on 8 bytes to gain an extra bit in the pointer
and use that bit to indicate the running state. Then these sites can
spin on that bit while we can change the actual base pointer.

Since the timer->base pointer is locked through the base->lock and
hand-over is safe vs lock_timer_base, this should all work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
