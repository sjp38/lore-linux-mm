Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 963696B0038
	for <linux-mm@kvack.org>; Sat, 13 May 2017 22:35:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c10so75768979pfg.10
        for <linux-mm@kvack.org>; Sat, 13 May 2017 19:35:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v5si7341138plg.227.2017.05.13.19.35.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 May 2017 19:35:15 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4E2Y2mW023535
	for <linux-mm@kvack.org>; Sat, 13 May 2017 22:35:15 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2aedp59hf4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 13 May 2017 22:35:14 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sun, 14 May 2017 12:35:12 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4E2Z2ZI64290860
	for <linux-mm@kvack.org>; Sun, 14 May 2017 12:35:10 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4E2YVVl030129
	for <linux-mm@kvack.org>; Sun, 14 May 2017 12:34:32 +1000
Subject: Re: [PATCH] mm/madvise: Dont poison entire HugeTLB page for single
 page errors
References: <893ecbd7-e9fa-7a54-fc62-43f8a5b8107f@linux.vnet.ibm.com>
 <20170420110627.12307-1-khandual@linux.vnet.ibm.com>
 <20170512081001.GA13069@hori1.linux.bs1.fc.nec.co.jp>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Sun, 14 May 2017 08:04:12 +0530
MIME-Version: 1.0
In-Reply-To: <20170512081001.GA13069@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Message-Id: <dd5e2561-b936-7778-75db-5fe25485bf93@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>

On 05/12/2017 01:40 PM, Naoya Horiguchi wrote:
> On Thu, Apr 20, 2017 at 04:36:27PM +0530, Anshuman Khandual wrote:
>> Currently soft_offline_page() migrates the entire HugeTLB page, then
>> dequeues it from the active list by making it a dangling HugeTLB page
>> which ofcourse can not be used further and marks the entire HugeTLB
>> page as poisoned. This might be a costly waste of memory if the error
>> involved affects only small section of the entire page.
>>
>> This changes the behaviour so that only the affected page is marked
>> poisoned and then the HugeTLB page is released back to buddy system.
> Hi Anshuman,
> 
> This is a good catch, and we can solve this issue now because freeing
> hwpoisoned page (previously forbidden) is available now.
> 
> And I'm thinking that the same issue for hard/soft-offline on free
> hugepages can be solved, so I'll submit a patchset which includes
> updated version of your patch.

Sure, thanks Naoya.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
