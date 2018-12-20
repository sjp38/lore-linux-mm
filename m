Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB6838E0003
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 00:22:22 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b3so1102390edi.0
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 21:22:22 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j17-v6si7088470ejv.307.2018.12.19.21.22.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 21:22:21 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBK5IPU2156256
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 00:22:20 -0500
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2pg2s5n269-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 00:22:19 -0500
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 20 Dec 2018 05:22:19 -0000
Subject: Re: [PATCH V5 1/3] mm: Add get_user_pages_cma_migrate
References: <20181219034047.16305-1-aneesh.kumar@linux.ibm.com>
 <20181219034047.16305-2-aneesh.kumar@linux.ibm.com>
 <e9c9b68a-a31b-ab59-902a-73401a89f72a@ozlabs.ru>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Thu, 20 Dec 2018 10:52:09 +0530
MIME-Version: 1.0
In-Reply-To: <e9c9b68a-a31b-ab59-902a-73401a89f72a@ozlabs.ru>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <b316eb1c-36dc-49e0-f46f-e610f29b6058@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>, akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, mpe@ellerman.id.au, paulus@samba.org, David Gibson <david@gibson.dropbear.id.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 12/20/18 9:49 AM, Alexey Kardashevskiy wrote:
> 
> 
> On 19/12/2018 14:40, Aneesh Kumar K.V wrote:
>> This helper does a get_user_pages_fast and if it find pages in the CMA area
>> it will try to migrate them before taking page reference. This makes sure that
>> we don't keep non-movable pages (due to page reference count) in the CMA area.
>> Not able to move pages out of CMA area result in CMA allocation failures.
>>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>

.....
>> +		 * We did migrate all the pages, Try to get the page references again
>> +		 * migrating any new CMA pages which we failed to isolate earlier.
>> +		 */
>> +		drain_allow = true;
>> +		goto get_user_again;
> 
> 
> So it is possible to have pages pinned, then successfully migrated
> (migrate_pages() returned 0), then pinned again, then some pages may end
> up in CMA again and migrate again and nothing seems to prevent this loop
> from being endless. What do I miss?
> 

pages used as target page for migration won't be allocated from CMA region.

-aneesh
