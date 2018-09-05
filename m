Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD996B735E
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 09:26:29 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u74-v6so8569392oie.16
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 06:26:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w63-v6si1365025oib.307.2018.09.05.06.26.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 06:26:28 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w85DKfTl023097
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 09:26:28 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2maf6m2nu4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 09:26:27 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 5 Sep 2018 07:26:27 -0600
Subject: Re: [RFC PATCH] mm/hugetlb: make hugetlb_lock irq safe
References: <20180905112341.21355-1-aneesh.kumar@linux.ibm.com>
 <20180905130440.GA3729@bombadil.infradead.org>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Wed, 5 Sep 2018 18:56:19 +0530
MIME-Version: 1.0
In-Reply-To: <20180905130440.GA3729@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <d76771e6-1664-5d38-a5a0-e98f1120494c@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/05/2018 06:34 PM, Matthew Wilcox wrote:
> On Wed, Sep 05, 2018 at 04:53:41PM +0530, Aneesh Kumar K.V wrote:
>>   inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
> 
> How do you go from "can be taken in softirq context" problem report to
> "must disable hard interrupts" solution?  Please explain why spin_lock_bh()
> is not a sufficient fix.
> 
>>   swapper/68/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
>>   0000000052a030a7 (hugetlb_lock){+.?.}, at: free_huge_page+0x9c/0x340
>>   {SOFTIRQ-ON-W} state was registered at:
>>     lock_acquire+0xd4/0x230
>>     _raw_spin_lock+0x44/0x70
>>     set_max_huge_pages+0x4c/0x360
>>     hugetlb_sysctl_handler_common+0x108/0x160
>>     proc_sys_call_handler+0x134/0x190
>>     __vfs_write+0x3c/0x1f0
>>     vfs_write+0xd8/0x220
> 
> Also, this only seems to trigger here.  Is it possible we _already_
> have softirqs disabled through every other code path, and it's just this
> one sysctl handler that needs to disable softirqs?  Rather than every
> lock access?

Are you asking whether I looked at moving that put_page to a worker 
thread? I didn't. The reason I looked at current patch is to enable the 
usage of put_page() from irq context. We do allow that for non hugetlb 
pages. So was not sure adding that additional restriction for hugetlb
is really needed. Further the conversion to irqsave/irqrestore was
straightforward.

Now with respect to making sure we don't have irq already disabled in 
those code paths, I did check that. But let me know if you find anything 
I missed.

> I'm not seeing any analysis in this patch description, just a kneejerk
> "lockdep complained, must disable interrupts".
> 

-aneesh
