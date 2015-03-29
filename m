Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7976B007D
	for <linux-mm@kvack.org>; Sun, 29 Mar 2015 13:24:57 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so144664853pad.3
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 10:24:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id q15si11501055pdl.129.2015.03.29.10.24.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Mar 2015 10:24:56 -0700 (PDT)
Date: Sun, 29 Mar 2015 19:24:47 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Message-ID: <20150329172447.GM27490@worktop.programming.kicks-ass.net>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
 <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
 <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
 <20150327091613.GE27490@worktop.programming.kicks-ass.net>
 <20150327093023.GA32047@worktop.ger.corp.intel.com>
 <CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
 <20150328095322.GH27490@worktop.programming.kicks-ass.net>
 <55169723.3070006@linaro.org>
 <20150328134457.GK27490@worktop.programming.kicks-ass.net>
 <CAKohpokgT+PfczvpBV2zEzuGMvu0VY50L7EGtyxvLkY2C9z2hQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKohpokgT+PfczvpBV2zEzuGMvu0VY50L7EGtyxvLkY2C9z2hQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, dave@stgolabs.net, Konstantin Khlebnikov <koct9i@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>, realmz6@gmail.com

On Sun, Mar 29, 2015 at 05:31:32PM +0530, Viresh Kumar wrote:
> Warning:
> 
> config: blackfin-allyesconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross
> -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout ca713e393c6eceb54e803df204772a3d6e6c7981
>   # save the attached .config to linux build tree
>   make.cross ARCH=blackfin
> 
> All error/warnings:
> 
>    kernel/time/timer.c: In function 'init_timers':
> >> kernel/time/timer.c:1648:2: error: call to '__compiletime_assert_1648' declared with attribute error: BUILD_BUG_ON failed: __alignof__(struct tvec_base) & TIMER_FLAG_MASK

Ha, this is because blackfin is broken.

blackfin doesn't respect ____cacheline_aligned and NOPs it for UP
builds. Why it thinks {__,}__cacheline_aligned semantics should differ
between SMP/UP is a mystery to me, we have the &_in_smp primitives for
that.

So just ignore this, let the blackfin people deal with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
