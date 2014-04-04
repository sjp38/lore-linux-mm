Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6803A6B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 03:11:04 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id t61so2986378wes.30
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 00:11:03 -0700 (PDT)
Received: from mail-we0-x236.google.com (mail-we0-x236.google.com [2a00:1450:400c:c03::236])
        by mx.google.com with ESMTPS id ni18si537298wic.59.2014.04.04.00.11.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Apr 2014 00:11:03 -0700 (PDT)
Received: by mail-we0-f182.google.com with SMTP id p61so2985429wes.27
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 00:11:02 -0700 (PDT)
Date: Fri, 4 Apr 2014 09:10:59 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH V2 2/2] mm: add FAULT_AROUND_ORDER Kconfig paramater for
 powerpc
Message-ID: <20140404071059.GA1397@gmail.com>
References: <1396592835-24767-1-git-send-email-maddy@linux.vnet.ibm.com>
 <1396592835-24767-3-git-send-email-maddy@linux.vnet.ibm.com>
 <20140404070241.GA984@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140404070241.GA984@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Ingo Molnar <mingo@kernel.org> wrote:

> * Madhavan Srinivasan <maddy@linux.vnet.ibm.com> wrote:
> 
> > Performance data for different FAULT_AROUND_ORDER values from 4 
> > socket Power7 system (128 Threads and 128GB memory) is below. perf 
> > stat with repeat of 5 is used to get the stddev values. This patch 
> > create FAULT_AROUND_ORDER Kconfig parameter and defaults it to 3 
> > based on the performance data.
> > 
> > FAULT_AROUND_ORDER      Baseline        1               3               4               5               7
> > 
> > Linux build (make -j64)
> > minor-faults            7184385         5874015         4567289         4318518         4193815         4159193
> > times in seconds        61.433776136    60.865935292    59.245368038    60.630675011    60.56587624     59.828271924
> >  stddev for time	( +-  1.18% )	( +-  1.78% )	( +-  0.44% )	( +-  2.03% )	( +-  1.66% )	( +-  1.45% )
> 
> Ok, this is better, but it is still rather incomplete statistically, 
> please also calculate the percentage difference to baseline, so that 
> the stddev becomes meaningful and can be compared to something!
> 
> As an example I did this for the first line of measurements (all 
> errors in the numbers are mine, this was done manually), and it 
> gives:
> 
> >  stddev for time   ( +-  1.18% ) ( +-  1.78% ) ( +-  0.44% ) ( +-  2.03% ) ( +-  1.66% ) ( +-  1.45% )
>                                         +0.9%         +3.5%         +1.3%         +1.4%         +2.6%
> 
> This shows that there is probably a statistically significant 
> (positiv) effect from the change, but from these numbers alone I 
> would not draw any quantitative (sizing, tuning) conclusions, 
> because in 3 out of 5 cases the stddev was larger than the effect, 
> so the resulting percentages are not comparable.

Also note that because we calculate the percentage by dividing result 
with baseline, the stddev of the two values roughly adds up. So for 
example the second column the true noise is around 1.5%, not 0.4%

So for good sizing decisions the stddev must be 'comfortably' below 
the effect. (or sizing should be done based on the other workloads yu 
tested, I have not checked them.)

It also makes sense to run more measurements to reduce the stddev of 
the baseline. So if each measurement is run 3 times then it makes 
sense to run the baseline 6 times, this gives a ~30% improvement in 
the confidence of our result, at just a small increase in test time.

[ For such cases it might also make sense to script all of that, 
  combined with a debug patch that puts the tuned fault-around value 
  into a dynamic knob in /proc/sys/, so that you can run the full 
  measurement in a single pass, with no reboot and with no human 
  intervention. ]

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
