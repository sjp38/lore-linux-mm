Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED5F46B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 07:35:18 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 83so349503458pfx.1
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 04:35:18 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b139si29904pfb.162.2016.12.01.04.35.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 04:35:18 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB1CZE8v065752
	for <linux-mm@kvack.org>; Thu, 1 Dec 2016 07:35:17 -0500
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 272hu5eev3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Dec 2016 07:35:15 -0500
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 1 Dec 2016 05:34:11 -0700
Date: Thu, 1 Dec 2016 04:34:09 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: next: Commit 'mm: Prevent __alloc_pages_nodemask() RCU CPU stall
 ...' causing hang on sparc32 qemu
Reply-To: paulmck@linux.vnet.ibm.com
References: <20161130012817.GH3924@linux.vnet.ibm.com>
 <b96c1560-3f06-bb6d-717a-7a0f0c6e869a@roeck-us.net>
 <20161130070212.GM3924@linux.vnet.ibm.com>
 <929f6b29-461a-6e94-fcfd-710c3da789e9@roeck-us.net>
 <20161130120333.GQ3924@linux.vnet.ibm.com>
 <20161130192159.GB22216@roeck-us.net>
 <20161130210152.GL3924@linux.vnet.ibm.com>
 <20161130231846.GB17244@roeck-us.net>
 <20161201011950.GX3924@linux.vnet.ibm.com>
 <20161201065657.GA4697@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161201065657.GA4697@roeck-us.net>
Message-Id: <20161201123409.GA3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, sparclinux@vger.kernel.org, davem@davemloft.net

On Wed, Nov 30, 2016 at 10:56:57PM -0800, Guenter Roeck wrote:
> Hi Paul,
> 
> On Wed, Nov 30, 2016 at 05:19:50PM -0800, Paul E. McKenney wrote:
> [ ... ]
> 
> > > > > 
> > > > > BUG: sleeping function called from invalid context at mm/page_alloc.c:3775
> [ ... ]
> > 
> > Whew!  You had me going for a bit there.  ;-)
> 
> Bisect results are here ... the culprit is, again, commit 2d66cccd73 ("mm:
> Prevent __alloc_pages_nodemask() RCU CPU stall warnings"), and reverting that
> patch fixes the problem. Good that you dropped it already :-).

"My work is done."  ;-)

And apologies for the hassle.  I have no idea what I was thinking when
I put the cond_resched_rcu_qs() there!

							Thanx, Paul

> Guenter
> 
> ---
> # bad: [59ab0083490c8a871b51e893bae5806e55901d7e] Add linux-next specific files for 20161130
> # good: [e5517c2a5a49ed5e99047008629f1cd60246ea0e] Linux 4.9-rc7
> git bisect start 'HEAD' 'v4.9-rc7'
> # good: [187f99e5c22bb3fab8b330f3ebbbd235d238f3f8] Merge remote-tracking branch 'crypto/master'
> git bisect good 187f99e5c22bb3fab8b330f3ebbbd235d238f3f8
> # good: [36126657c908e822523b8563f9b1512937c0f342] Merge remote-tracking branch 'tip/auto-latest'
> git bisect good 36126657c908e822523b8563f9b1512937c0f342
> # good: [2d2139c5c746ec61024fdfa9c36e4e034bb18e59] Merge tag 'iio-for-4.10d' of git://git.kernel.org/pub/scm/linux/kernel/git/jic23/iio into staging-next
> git bisect good 2d2139c5c746ec61024fdfa9c36e4e034bb18e59
> # bad: [926a60551123048c589b45abee2a2ec4c924ab21] Merge remote-tracking branch 'extcon/extcon-next'
> git bisect bad 926a60551123048c589b45abee2a2ec4c924ab21
> # bad: [1541655795a90720b8a094c8cc39f582dec17398] Merge remote-tracking branch 'tty/tty-next'
> git bisect bad 1541655795a90720b8a094c8cc39f582dec17398
> # bad: [69a6720a1e54519d9bf8563764e9e93bf1bd6a84] Merge remote-tracking branch 'kvm-arm/next'
> git bisect bad 69a6720a1e54519d9bf8563764e9e93bf1bd6a84
> # good: [33b8b045b93f9104c61ecad1865af961b3bef03e] Merge remote-tracking branch 'ftrace/for-next'
> git bisect good 33b8b045b93f9104c61ecad1865af961b3bef03e
> # good: [8370c3d08bd98576d97514eca29970e03767a5d1] kvm: svm: Add kvm_fast_pio_in support
> git bisect good 8370c3d08bd98576d97514eca29970e03767a5d1
> # good: [0a895142323de3eebb0b753d3d8c0e768ff179d9] mm: Prevent shrink_node() RCU CPU stall warnings
> git bisect good 0a895142323de3eebb0b753d3d8c0e768ff179d9
> # bad: [f8045446ca778333e960dcb9e30a5858ff2b8c20] srcu: Force full grace-period ordering
> git bisect bad f8045446ca778333e960dcb9e30a5858ff2b8c20
> # good: [f660d64912ccadadcdce6dfb39eb06924dd93767] doc: Fix RCU requirements typos
> git bisect good f660d64912ccadadcdce6dfb39eb06924dd93767
> # good: [d2db185bfee894c573faebed93461e9938bdbb61] rcu: Remove short-term CPU kicking
> git bisect good d2db185bfee894c573faebed93461e9938bdbb61
> # bad: [2d66cccd73436ac9985a08e5c2f82e4344f72264] mm: Prevent __alloc_pages_nodemask() RCU CPU stall warnings
> git bisect bad 2d66cccd73436ac9985a08e5c2f82e4344f72264
> # good: [34c53f5cd399801b083047cc9cf2ad3ed17c3144] mm: Prevent shrink_node_memcg() RCU CPU stall warnings
> git bisect good 34c53f5cd399801b083047cc9cf2ad3ed17c3144
> # first bad commit: [2d66cccd73436ac9985a08e5c2f82e4344f72264] mm: Prevent __alloc_pages_nodemask() RCU CPU stall warnings
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
