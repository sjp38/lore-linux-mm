Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 44EDA6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 10:52:28 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id v10so6352996qac.2
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 07:52:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t9si2492965qag.6.2015.01.23.07.52.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 07:52:27 -0800 (PST)
Message-ID: <54C2613F.6080403@redhat.com>
Date: Fri, 23 Jan 2015 09:57:03 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: incorporate read-only pages into transparent huge
 pages
References: <1421999256-3881-1-git-send-email-ebru.akagunduz@gmail.com> <20150123113701.GB5975@node.dhcp.inet.fi>
In-Reply-To: <20150123113701.GB5975@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, aarcange@redhat.com

On 01/23/2015 06:37 AM, Kirill A. Shutemov wrote:
> On Fri, Jan 23, 2015 at 09:47:36AM +0200, Ebru Akagunduz wrote:
>> This patch aims to improve THP collapse rates, by allowing
>> THP collapse in the presence of read-only ptes, like those
>> left in place by do_swap_page after a read fault.
>>
>> Currently THP can collapse 4kB pages into a THP when
>> there are up to khugepaged_max_ptes_none pte_none ptes
>> in a 2MB range. This patch applies the same limit for
>> read-only ptes.

>> @@ -2179,6 +2179,17 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>>  		 */
>>  		if (!trylock_page(page))
>>  			goto out;
>> +		if (!pte_write(pteval)) {
>> +			if (PageSwapCache(page) && !reuse_swap_page(page)) {
>> +					unlock_page(page);
>> +					goto out;
>> +			}
>> +			/*
>> +			 * Page is not in the swap cache, and page count is
>> +			 * one (see above). It can be collapsed into a THP.
>> +			 */
>> +		}
> 
> Hm. As a side effect it will effectevely allow collapse in PROT_READ vmas,
> right? I'm not convinced it's a good idea.

It will only allow a THP collapse if there is at least one
read-write pte.

I suspect that excludes read-only VMAs automatically.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
