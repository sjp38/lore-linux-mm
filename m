Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 559636B0032
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 05:30:29 -0400 (EDT)
Received: by pacwz10 with SMTP id wz10so39552433pac.2
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 02:30:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id vz4si2095891pac.137.2015.03.27.02.30.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 02:30:28 -0700 (PDT)
Date: Fri, 27 Mar 2015 10:30:23 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Message-ID: <20150327093023.GA32047@worktop.ger.corp.intel.com>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
 <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
 <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
 <20150327091613.GE27490@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150327091613.GE27490@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, mgorman@suse.de, dave@stgolabs.net, koct9i@gmail.com, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Fri, Mar 27, 2015 at 10:16:13AM +0100, Peter Zijlstra wrote:
> On Fri, Mar 27, 2015 at 10:19:54AM +0530, Viresh Kumar wrote:
> > On 27 March 2015 at 01:48, Andrew Morton <akpm@linux-foundation.org> wrote:
> > > Shouldn't this be viewed as a shortcoming of the core timer code?
> > 
> > Yeah, it is. Some (not so pretty) solutions were tried earlier to fix that, but
> > they are rejected for obviously reasons [1].
> > 
> > > vmstat_shepherd() is merely rescheduling itself with
> > > schedule_delayed_work().  That's a dead bog simple operation and if
> > > it's producing suboptimal behaviour then we shouldn't be fixing it with
> > > elaborate workarounds in the caller?
> > 
> > I understand that, and that's why I sent it as an RFC to get the discussion
> > started. Does anyone else have got another (acceptable) idea to get this
> > resolved ?
> 
> So the issue seems to be that we need base->running_timer in order to
> tell if a callback is running, right?
> 
> We could align the base on 8 bytes to gain an extra bit in the pointer
> and use that bit to indicate the running state. Then these sites can
> spin on that bit while we can change the actual base pointer.

Even though tvec_base has ____cacheline_aligned stuck on, most are
allocated using kzalloc_node() which does not actually respect that but
already guarantees a minimum u64 alignment, so I think we can use that
third bit without too much magic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
