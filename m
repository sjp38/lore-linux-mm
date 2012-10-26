Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 734176B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 23:08:10 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so4029127ied.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 20:08:09 -0700 (PDT)
Message-ID: <5089FE8E.4030603@gmail.com>
Date: Fri, 26 Oct 2012 11:07:58 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] mm: thp: Set the accessed flag for old pages on access
 fault.
References: <1351183471-14710-1-git-send-email-will.deacon@arm.com> <20121025195110.GA4771@cmpxchg.org>
In-Reply-To: <20121025195110.GA4771@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, mhocko@suse.cz, peterz@infradead.org, akpm@linux-foundation.org, Chris Metcalf <cmetcalf@tilera.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>

On 10/26/2012 03:51 AM, Johannes Weiner wrote:
> On Thu, Oct 25, 2012 at 05:44:31PM +0100, Will Deacon wrote:
>> On x86 memory accesses to pages without the ACCESSED flag set result in the
>> ACCESSED flag being set automatically. With the ARM architecture a page access
>> fault is raised instead (and it will continue to be raised until the ACCESSED
>> flag is set for the appropriate PTE/PMD).
>>
>> For normal memory pages, handle_pte_fault will call pte_mkyoung (effectively
>> setting the ACCESSED flag). For transparent huge pages, pmd_mkyoung will only
>> be called for a write fault.
>>
>> This patch ensures that faults on transparent hugepages which do not result
>> in a CoW update the access flags for the faulting pmd.
>>
>> Cc: Chris Metcalf <cmetcalf@tilera.com>
>> Cc: Kirill A. Shutemov <kirill@shutemov.name>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Signed-off-by: Will Deacon <will.deacon@arm.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>
>> Ok chaps, I rebased this thing onto today's next (which basically
>> necessitated a rewrite) so I've reluctantly dropped my acks and kindly
>> ask if you could eyeball the new code, especially where the locking is
>> concerned. In the numa code (do_huge_pmd_prot_none), Peter checks again
>> that the page is not splitting, but I can't see why that is required.
> I don't either.  If the thing was splitting when the fault happened,
> that path is not taken.  And the locked pmd_same() check should rule
> out splitting setting in after testing pmd_trans_huge_splitting().

Why I can't find function pmd_trans_huge_splitting() you mentioned in 
latest mainline codes and linux-next?

>
> Peter?
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
