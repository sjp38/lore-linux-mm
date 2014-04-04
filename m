Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 41AFB6B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 03:02:46 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id u56so2873058wes.23
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 00:02:45 -0700 (PDT)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id yi10si520764wib.120.2014.04.04.00.02.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Apr 2014 00:02:44 -0700 (PDT)
Received: by mail-wg0-f48.google.com with SMTP id l18so2985755wgh.7
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 00:02:44 -0700 (PDT)
Date: Fri, 4 Apr 2014 09:02:41 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH V2 2/2] mm: add FAULT_AROUND_ORDER Kconfig paramater for
 powerpc
Message-ID: <20140404070241.GA984@gmail.com>
References: <1396592835-24767-1-git-send-email-maddy@linux.vnet.ibm.com>
 <1396592835-24767-3-git-send-email-maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1396592835-24767-3-git-send-email-maddy@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org


* Madhavan Srinivasan <maddy@linux.vnet.ibm.com> wrote:

> Performance data for different FAULT_AROUND_ORDER values from 4 socket
> Power7 system (128 Threads and 128GB memory) is below. perf stat with
> repeat of 5 is used to get the stddev values. This patch create
> FAULT_AROUND_ORDER Kconfig parameter and defaults it to 3 based on the
> performance data.
> 
> FAULT_AROUND_ORDER      Baseline        1               3               4               5               7
> 
> Linux build (make -j64)
> minor-faults            7184385         5874015         4567289         4318518         4193815         4159193
> times in seconds        61.433776136    60.865935292    59.245368038    60.630675011    60.56587624     59.828271924
>  stddev for time	( +-  1.18% )	( +-  1.78% )	( +-  0.44% )	( +-  2.03% )	( +-  1.66% )	( +-  1.45% )

Ok, this is better, but it is still rather incomplete statistically, 
please also calculate the percentage difference to baseline, so that 
the stddev becomes meaningful and can be compared to something!

As an example I did this for the first line of measurements (all 
errors in the numbers are mine, this was done manually), and it gives:

>  stddev for time   ( +-  1.18% ) ( +-  1.78% ) ( +-  0.44% ) ( +-  2.03% ) ( +-  1.66% ) ( +-  1.45% )
                                        +0.9%         +3.5%         +1.3%         +1.4%         +2.6%

This shows that there is probably a statistically significant 
(positiv) effect from the change, but from these numbers alone I would 
not draw any quantitative (sizing, tuning) conclusions, because in 3 
out of 5 cases the stddev was larger than the effect, so the resulting 
percentages are not comparable.

Please do this calculation for all the other lines as well and also 
close all the numbers with a conclusion section where you *analyze* 
the results, outline the statistics and compare the various workloads 
and how the tuning affects them and don't force the readers of the 
commit guess what it all means and how significant it all is!

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
