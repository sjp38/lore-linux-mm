Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE946B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 02:12:53 -0500 (EST)
Received: by mail-pa0-f71.google.com with SMTP id hr10so71173793pac.2
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 23:12:53 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0066.outbound.protection.outlook.com. [104.47.1.66])
        by mx.google.com with ESMTPS id z8si34014824pab.243.2016.11.08.23.12.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 08 Nov 2016 23:12:52 -0800 (PST)
Date: Wed, 9 Nov 2016 15:12:19 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH 2/2] mm: hugetlb: support gigantic surplus pages
Message-ID: <20161109071218.GA15044@sha-win-210.asiapac.arm.com>
References: <1478141499-13825-1-git-send-email-shijie.huang@arm.com>
 <1478141499-13825-3-git-send-email-shijie.huang@arm.com>
 <20161107162504.17591806@thinkpad>
 <20161108021929.GA982@sha-win-210.asiapac.arm.com>
 <20161108070851.GA15044@sha-win-210.asiapac.arm.com>
 <20161108091725.GA18678@sha-win-210.asiapac.arm.com>
 <20161108202742.57ed120d@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20161108202742.57ed120d@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Tue, Nov 08, 2016 at 08:27:42PM +0100, Gerald Schaefer wrote:
> On Tue, 8 Nov 2016 17:17:28 +0800
> Huang Shijie <shijie.huang@arm.com> wrote:
> 
> > > I will look at the lockdep issue.
> > I tested the new patch (will be sent out later) on the arm64 platform,
> > and I did not meet the lockdep issue when I enabled the lockdep.
> > The following is my config:
> > 
> > 	CONFIG_LOCKD=y
> > 	CONFIG_LOCKD_V4=y
> > 	CONFIG_LOCKUP_DETECTOR=y
> >         # CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
> > 	CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
> > 	CONFIG_DEBUG_SPINLOCK=y
> > 	CONFIG_DEBUG_LOCK_ALLOC=y
> > 	CONFIG_PROVE_LOCKING=y
> > 	CONFIG_LOCKDEP=y
> > 	CONFIG_LOCK_STAT=y
> > 	CONFIG_DEBUG_LOCKDEP=y
> > 	CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
> > 	
> > So do I miss something? 
> 
> Those options should be OK. Meanwhile I looked into this a little more,
> and the problematic line/lock is spin_lock_irqsave(&z->lock, flags) at
> the top of alloc_gigantic_page(). From the lockdep trace we see that
> it is triggered by an mmap(), and then hugetlb_acct_memory() ->
> __alloc_huge_page() -> alloc_gigantic_page().
> 
> However, in between those functions (inside gather_surplus_pages())
> a NUMA_NO_NODE node id comes into play. And this finally results in
> alloc_gigantic_page() being called with NUMA_NO_NODE as nid (which is
> -1), and NODE_DATA(nid)->node_zones will then reach into Nirvana.
Thanks for pointing this.
I sent out the new patch just now. Could you please try it again?
I added a NUMA_NO_NODE check in the alloc_gigantic_page();

thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
