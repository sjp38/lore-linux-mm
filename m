Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7DBCC6B0032
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 08:02:54 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so94829852pdn.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 05:02:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id h1si2597049pdh.142.2015.03.27.05.02.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 05:02:53 -0700 (PDT)
Date: Fri, 27 Mar 2015 13:02:40 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Message-ID: <20150327120240.GC23123@twins.programming.kicks-ass.net>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
 <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
 <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
 <20150327091613.GE27490@worktop.programming.kicks-ass.net>
 <20150327093023.GA32047@worktop.ger.corp.intel.com>
 <alpine.DEB.2.11.1503270610430.19514@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1503270610430.19514@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, mgorman@suse.de, dave@stgolabs.net, koct9i@gmail.com, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Fri, Mar 27, 2015 at 06:11:44AM -0500, Christoph Lameter wrote:
> On Fri, 27 Mar 2015, Peter Zijlstra wrote:
> 
> > > We could align the base on 8 bytes to gain an extra bit in the pointer
> > > and use that bit to indicate the running state. Then these sites can
> > > spin on that bit while we can change the actual base pointer.
> >
> > Even though tvec_base has ____cacheline_aligned stuck on, most are
> > allocated using kzalloc_node() which does not actually respect that but
> > already guarantees a minimum u64 alignment, so I think we can use that
> > third bit without too much magic.
> 
> Create a new slab cache for this purpose that does the proper aligning?

That is certainly a possibility, but we'll only ever allocate nr_cpus-1
entries from it, a whole new slab cache might be overkill.

What's not clear to me is why that thing is allocated at all, AFAICT
something like:

static DEFINE_PER_CPU(struct tvec_base, tvec_bases);

Should do the right thing and be much simpler.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
