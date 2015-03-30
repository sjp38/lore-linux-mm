Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id BFB5D6B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 11:14:47 -0400 (EDT)
Received: by wicne17 with SMTP id ne17so35577972wic.0
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 08:14:47 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id es14si18580717wjc.122.2015.03.30.08.14.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 08:14:46 -0700 (PDT)
Date: Mon, 30 Mar 2015 17:14:31 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Message-ID: <20150330151431.GA23123@twins.programming.kicks-ass.net>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
 <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
 <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
 <20150327091613.GE27490@worktop.programming.kicks-ass.net>
 <20150327093023.GA32047@worktop.ger.corp.intel.com>
 <CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
 <20150328095322.GH27490@worktop.programming.kicks-ass.net>
 <20150330150818.GE3909@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150330150818.GE3909@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, mgorman@suse.de, dave@stgolabs.net, koct9i@gmail.com, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Mar 30, 2015 at 05:08:18PM +0200, Michal Hocko wrote:
> On Sat 28-03-15 10:53:22, Peter Zijlstra wrote:
> [...]
> > Alternatively the thing hocko suggests is an utter fail too. You cannot
> > stuff that into hardirq context, that's insane.
> 
> I guess you are referring to
> http://article.gmane.org/gmane.linux.kernel.mm/127569, right?
> 
> Why cannot we do something like refresh_cpu_vm_stats from the IRQ
> context?  Especially the first zone stat part.

Big machines have big zone counts. There are machines with >200 nodes.
Although with the current trend of bigger nodes, the number of nodes
seems to come down as well. Still.

> The per-cpu pagesets is
> more costly and it would need a special treatment, alright. A simple
> way would be to splice the lists from the per-cpu context and then free
> those pages from the kthread context.
> 
> I am still wondering why those two things were squashed into a single
> place. Why kswapd is not doing the pcp cleanup?

Probably because they could be. The problem with kswapd is that its per
node, not per cpu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
