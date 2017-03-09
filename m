Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 185F22808AF
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 00:35:28 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id w189so93495834pfb.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 21:35:28 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d13si5390910pgn.154.2017.03.08.21.35.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 21:35:27 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v295XbX5146908
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 00:35:26 -0500
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com [125.16.236.4])
	by mx0a-001b2d01.pphosted.com with ESMTP id 292j700586-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 09 Mar 2017 00:35:26 -0500
Received: from localhost
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 9 Mar 2017 11:05:23 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v295ZLUZ16646284
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 11:05:21 +0530
Received: from d28av06.in.ibm.com (localhost [127.0.0.1])
	by d28av06.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v295ZJRP007862
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 11:05:20 +0530
Subject: Re: [RFC PATCH 03/14] mm/migrate: Add copy_pages_mthread function
References: <20170217150551.117028-1-zi.yan@sent.com>
 <20170217150551.117028-4-zi.yan@sent.com>
 <20170223060649.GA7336@hori1.linux.bs1.fc.nec.co.jp>
 <ff44b5a5-d022-5c68-b067-634614f0a28c@linux.vnet.ibm.com>
 <20170223080216.GA9486@hori1.linux.bs1.fc.nec.co.jp>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 9 Mar 2017 11:05:19 +0530
MIME-Version: 1.0
In-Reply-To: <20170223080216.GA9486@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Message-Id: <82a5680c-42f9-0916-3492-ceb1009fdb26@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Zi Yan <zi.yan@sent.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dnellans@nvidia.com" <dnellans@nvidia.com>, "apopple@au1.ibm.com" <apopple@au1.ibm.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>

On 02/23/2017 01:32 PM, Naoya Horiguchi wrote:
> On Thu, Feb 23, 2017 at 01:20:16PM +0530, Anshuman Khandual wrote:
> ...
>>>
>>>> +
>>>> +	cthreads = nr_copythreads;
>>>> +	cthreads = min_t(unsigned int, cthreads, cpumask_weight(cpumask));
>>>
>>> nitpick, but looks a little wordy, can it be simply like below?
>>>
>>>   cthreads = min_t(unsigned int, nr_copythreads, cpumask_weight(cpumask));
>>>
>>>> +	cthreads = (cthreads / 2) * 2;
>>>
>>> I'm not sure the intention here. # of threads should be even number?
>>
>> Yes.
>>
>>> If cpumask_weight() is 1, cthreads is 0, that could cause zero division.
>>> So you had better making sure to prevent it.
>>
>> If cpumask_weight() is 1, then min_t(unsigned int, 8, 1) should be
>> greater that equal to 1. Then cthreads can end up in 0. That is
>> possible. But how there is a chance of zero division ? 
> 
> Hi Anshuman,
> 
> I just thought like above when reading the line your patch introduces:
> 
>        chunk_size = PAGE_SIZE * nr_pages / cthreads
>                                            ~~~~~~~~
>                                            (this can be 0?)

Right cthreads can be 0. I am changing like this.

cthreads = min_t(unsigned int, NR_COPYTHREADS, cpumask_weight(cpumask));
cthreads = (cthreads / 2) * 2;
if (!cthreads)
      cthreads = 1;

In the first two statements cthreads can be 0 if cpumask_weight() turns
to be 1 or 0 in which case we force it to be 1. Then with this

        i = 0;
        for_each_cpu(cpu, cpumask) {
                if (i >= cthreads)
                        break;
                cpu_id_list[i] = cpu;
                ++i;
        }

cpu_id_list[0] will have the single cpu (in case cpumask of the node has
a cpu) or it will have 0 in case its memory only cpu less node. In both
cases the page copy happens in single threaded manner. This also removes
the possibility of divide by zero scenario here.

chunk_size = PAGE_SIZE * nr_pages / cthreads;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
