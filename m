Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 98DCF6B7341
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 09:04:44 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c8-v6so3934451pfn.2
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 06:04:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w20-v6si1941329pgf.434.2018.09.05.06.04.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Sep 2018 06:04:43 -0700 (PDT)
Date: Wed, 5 Sep 2018 06:04:40 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH] mm/hugetlb: make hugetlb_lock irq safe
Message-ID: <20180905130440.GA3729@bombadil.infradead.org>
References: <20180905112341.21355-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180905112341.21355-1-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: akpm@linux-foundation.org, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 05, 2018 at 04:53:41PM +0530, Aneesh Kumar K.V wrote:
>  inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.

How do you go from "can be taken in softirq context" problem report to
"must disable hard interrupts" solution?  Please explain why spin_lock_bh()
is not a sufficient fix.

>  swapper/68/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
>  0000000052a030a7 (hugetlb_lock){+.?.}, at: free_huge_page+0x9c/0x340
>  {SOFTIRQ-ON-W} state was registered at:
>    lock_acquire+0xd4/0x230
>    _raw_spin_lock+0x44/0x70
>    set_max_huge_pages+0x4c/0x360
>    hugetlb_sysctl_handler_common+0x108/0x160
>    proc_sys_call_handler+0x134/0x190
>    __vfs_write+0x3c/0x1f0
>    vfs_write+0xd8/0x220

Also, this only seems to trigger here.  Is it possible we _already_
have softirqs disabled through every other code path, and it's just this
one sysctl handler that needs to disable softirqs?  Rather than every
lock access?

I'm not seeing any analysis in this patch description, just a kneejerk
"lockdep complained, must disable interrupts".
