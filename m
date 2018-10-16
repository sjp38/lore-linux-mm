Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2F36B0006
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 04:35:36 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id j71-v6so12423016ybg.1
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 01:35:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e17-v6si4112999ybq.144.2018.10.16.01.35.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 01:35:35 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9G8Z7Pe032252
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 04:35:35 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2n5acb5m8p-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 04:35:34 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 16 Oct 2018 09:35:33 +0100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH V3 1/2] mm: Add get_user_pages_cma_migrate
In-Reply-To: <485adcad-4996-ae2c-c098-9dc7bcd2d29a@ozlabs.ru>
References: <20180918115839.22154-1-aneesh.kumar@linux.ibm.com> <20180918115839.22154-2-aneesh.kumar@linux.ibm.com> <6112386d-65cd-fc1f-b012-e33da2c3b8fe@ozlabs.ru> <87murewecs.fsf@linux.ibm.com> <485adcad-4996-ae2c-c098-9dc7bcd2d29a@ozlabs.ru>
Date: Tue, 16 Oct 2018 14:05:25 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87in22wape.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>, akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Alexey Kardashevskiy <aik@ozlabs.ru> writes:

> On 16/10/2018 18:16, Aneesh Kumar K.V wrote:
>> Alexey Kardashevskiy <aik@ozlabs.ru> writes:
>> 
>>> +			}
>>>> +		}
>>>> +	}
>>>> +	if (!list_empty(&cma_page_list)) {
>>>> +		/*
>>>> +		 * drop the above get_user_pages reference.
>>>> +		 */
>
>
> btw, can these pages be used by somebody else in this short window
> before we migrated and pinned them?

isolate lru page make sure that we remove them from lru list. So lru
walkers won't find the page. If somebody happen to increment the page
reference count in that window, the migrate_pages will fail. That is
handled via migrate_page_move_mapping returning EAGAIN

>
>
>>>> +		for (i = 0; i < ret; ++i)
>>>> +			put_page(pages[i]);
>>>> +
>>>> +		if (migrate_pages(&cma_page_list, new_non_cma_page,
>>>> +				  NULL, 0, MIGRATE_SYNC, MR_CONTIG_RANGE)) {
>>>> +			/*
>>>> +			 * some of the pages failed migration. Do get_user_pages
>>>> +			 * without migration.
>>>> +			 */
>>>> +			migrate_allow = false;
>>>
>>>
>>> migrate_allow seems useless, simply calling get_user_pages_fast() should
>>> make the code easier to read imho. And the comment says
>>> get_user_pages(), where does this guy hide?
>> 
>> I didn't get that suggestion. What we want to do here is try to migrate pages as
>> long as we find CMA pages in the result of get_user_pages_fast. If we
>> failed any migration attempt, don't try to migrate again.
>
>
> Setting migrate_allow to false here means you jump up, call
> get_user_pages_fast() and then run the loop which will do nothing just
> because if(...migrate_allow) is false. Instead of jumping up you could
> just call get_user_pages_fast().

ok, that is coding preference I guess, I prefer to avoid multiple
get_user_pages_fast there. Since we droped the page reference, we need
to _go back_ and get the page reference without attempting to migrate. That
is the way I was looking at this.

>
> btw what is migrate_pages() leaves something in cma_page_list (I cannot
> see it removing pages)? Won't it loop indefinitely?
>

putback_movable_pages take care of that. The below hunk.

			if (!list_empty(&cma_page_list))
				putback_movable_pages(&cma_page_list);

-aneesh
