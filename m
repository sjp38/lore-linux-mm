Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B436D6B0492
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 23:54:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y68so10568978pfd.6
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 20:54:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n16si498562pll.49.2017.09.05.20.54.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Sep 2017 20:54:09 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v863rnwq029508
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 23:54:08 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ct76a7vkq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 05 Sep 2017 23:54:08 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 6 Sep 2017 13:54:05 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v863s2SO38338786
	for <linux-mm@kvack.org>; Wed, 6 Sep 2017 13:54:02 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v863rr1J011308
	for <linux-mm@kvack.org>; Wed, 6 Sep 2017 13:53:53 +1000
Subject: Re: [RFC] mm/tlbbatch: Introduce arch_tlbbatch_should_defer()
References: <20170905144540.3365-1-khandual@linux.vnet.ibm.com>
 <20170905155000.gasnjvor4slvgkst@suse.de>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 6 Sep 2017 09:23:49 +0530
MIME-Version: 1.0
In-Reply-To: <20170905155000.gasnjvor4slvgkst@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Message-Id: <c5e4e0ad-131a-8002-859c-1251096687f7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On 09/05/2017 09:20 PM, Mel Gorman wrote:
> On Tue, Sep 05, 2017 at 08:15:40PM +0530, Anshuman Khandual wrote:
>> The entire scheme of deferred TLB flush in reclaim path rests on the
>> fact that the cost to refill TLB entries is less than flushing out
>> individual entries by sending IPI to remote CPUs. But architecture
>> can have different ways to evaluate that. Hence apart from checking
>> TTU_BATCH_FLUSH in the TTU flags, rest of the decision should be
>> architecture specific.
>>
>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> 
> There is only one arch implementation given and if an arch knows that
> the flush should not be deferred then why would it implement support in
> the first place? I'm struggling to see the point of the patch.

Even if the arch supports deferring of TLB flush like in the existing
case, it still checks if mm_cpumask(mm) contains anything other than
the current CPU (which indicates need for an IPI for a TLB flush) to
decide whether the TLB batch flush should be deferred or not. The
point is some architectures might do something different for a given
struct mm other than checking for presence of remote CPU in the mask
mm_cpumask(mm). It might be specific to the situation, struct mm etc.
Hence arch callback should be used instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
