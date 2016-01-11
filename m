Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id B6F9C828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 00:57:04 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id q63so40760283pfb.1
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 21:57:04 -0800 (PST)
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com. [202.81.31.145])
        by mx.google.com with ESMTPS id f7si26033456pfd.188.2016.01.10.21.57.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Jan 2016 21:57:04 -0800 (PST)
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 11 Jan 2016 15:57:00 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id BC9362CE8054
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 16:56:58 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0B5uTFG30474428
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 16:56:37 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0B5uPkZ028998
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 16:56:26 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH next] powerpc/mm: fix _PAGE_PTE breaking swapoff
In-Reply-To: <87si24u32t.fsf@linux.vnet.ibm.com>
References: <alpine.LSU.2.11.1601091643060.9808@eggly.anvils> <87si24u32t.fsf@linux.vnet.ibm.com>
Date: Mon, 11 Jan 2016 11:25:59 +0530
Message-ID: <87k2ngu0b4.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> Hugh Dickins <hughd@google.com> writes:
>
>> Swapoff after swapping hangs on the G5.  That's because the _PAGE_PTE
>> bit, added by set_pte_at(), is not expected by swapoff: so swap ptes
>> cannot be recognized.
>>
>> I'm not sure whether a swap pte should or should not have _PAGE_PTE set:
>> this patch assumes not, and fixes set_pte_at() to set _PAGE_PTE only on
>> present entries.
>
> One of the reason we added _PAGE_PTE is to enable HUGETLB migration. So
> we want migratio ptes to have _PAGE_PTE set.
>
>>
>> But if that's wrong, a reasonable alternative would be to
>> #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) & ~_PAGE_PTE })
>> #define __swp_entry_to_pte(x)	__pte((x).val | _PAGE_PTE)
>>

You other email w.r.t soft dirty bits explained this. What I missed was
the fact that core kernel expect swp_entry_t to be of an arch neutral
format.  The confusing part was "arch_entry"

static inline pte_t swp_entry_to_pte(swp_entry_t entry)
{
	swp_entry_t arch_entry;
.....
}
	
IMHO we should use the alternative you suggested above. I can write a
patch with additional comments around that if you want me to do that.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
