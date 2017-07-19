Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2256B0279
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 02:50:34 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d193so45182660pgc.0
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 23:50:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a34si3694153pli.199.2017.07.18.23.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 23:50:32 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6J6nOah142579
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 02:50:31 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bssrxt5b4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 02:50:31 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 19 Jul 2017 16:50:29 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6J6nCDq26411112
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 16:49:12 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6J6n3o0021555
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 16:49:04 +1000
Subject: Re: [RFC] mm/mremap: Remove redundant checks inside vma_expandable()
References: <20170710111059.30795-1-khandual@linux.vnet.ibm.com>
 <20170710134917.GB19645@dhcp22.suse.cz>
 <d6f9ec12-4518-8f97-eca9-6592808b839d@linux.vnet.ibm.com>
 <20170711060354.GA24852@dhcp22.suse.cz>
 <4c182da0-6c84-df67-b173-6960fac0544a@suse.cz>
 <20170711065030.GE24852@dhcp22.suse.cz>
 <337a8a4c-1f27-7371-409d-6a9f181b3871@suse.cz>
 <8bcc5908-7f0d-ba5c-a484-e0763f9b7664@linux.vnet.ibm.com>
 <20170711112253.GA11936@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 19 Jul 2017 12:19:04 +0530
MIME-Version: 1.0
In-Reply-To: <20170711112253.GA11936@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <aaae800b-a3b7-a0eb-fe14-3a1ed55a53af@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On 07/11/2017 04:52 PM, Michal Hocko wrote:
> On Tue 11-07-17 16:38:46, Anshuman Khandual wrote:
>> On 07/11/2017 12:26 PM, Vlastimil Babka wrote:
>>> On 07/11/2017 08:50 AM, Michal Hocko wrote:
>>>> On Tue 11-07-17 08:26:40, Vlastimil Babka wrote:
>>>>> On 07/11/2017 08:03 AM, Michal Hocko wrote:
>>>>>> Are you telling me that two if conditions cause more than a second
>>>>>> difference? That sounds suspicious.
>>>>> It's removing also a call to get_unmapped_area(), AFAICS. That means a
>>>>> vma search?
>>>> Ohh, right. I have somehow missed that. Is this removal intentional?
>>> I think it is: "Checking for availability of virtual address range at
>>> the end of the VMA for the incremental size is also reduntant at this
>>> point."
>>>
>>>> The
>>>> changelog is silent about it.
>>> It doesn't explain why it's redundant, indeed. Unfortunately, the commit
>>> f106af4e90ea ("fix checks for expand-in-place mremap") which added this,
>>> also doesn't explain why it's needed.
>> Its redundant because there are calls to get_unmapped_area() down the
>> line in the function whose failure will anyway fail the expansion of
>> the VMA.
> mremap code is quite complex and I am not sure you are right here.
> Anyway, please make sure you document why you believe those checks are
> not needed when resubmitting your patch.

vma_adjust() expands/contracts the given VMA and adjusts everything
around it like anon vma, rb tree, statistics etc but it never checks
whether the requested expansion/contraction is OK from arch point of
view by calling get_unmapped_area() some where. IIUC now the function
vma_expandable() does that check for it beforehand. Hence I think its
required. My tests happened to pass may be because of coincidence that
every thing (all the VA space) was up for grabs at that point of time.
So, will drop this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
