Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D4C96B0343
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 07:23:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n11so19782302pfg.7
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 04:23:12 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j63si1741140pfg.107.2017.03.24.04.23.11
        for <linux-mm@kvack.org>;
        Fri, 24 Mar 2017 04:23:11 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [RFC PATCH 0/2] Add hstate parameter to huge_pte_offset()
References: <20170323125823.429-1-punit.agrawal@arm.com>
	<bde0d8a5-f361-ef4e-5cb3-1615bc2a98b0@oracle.com>
	<20170324103709.253qw6pyjaq5wrgb@node.shutemov.name>
Date: Fri, 24 Mar 2017 11:23:08 +0000
In-Reply-To: <20170324103709.253qw6pyjaq5wrgb@node.shutemov.name> (Kirill
	A. Shutemov's message of "Fri, 24 Mar 2017 13:37:09 +0300")
Message-ID: <87efxmhqar.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tyler Baicar <tbaicar@codeaurora.org>

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Thu, Mar 23, 2017 at 01:55:27PM -0700, Mike Kravetz wrote:
>> On 03/23/2017 05:58 AM, Punit Agrawal wrote:
>> > On architectures that support hugepages composed of contiguous pte as
>> > well as block entries at the same level in the page table,
>> > huge_pte_offset() is not able to determine the right offset to return
>> > when it encounters a swap entry (which is used to mark poisoned as
>> > well as migrated pages in the page table).
>> > 
>> > huge_pte_offset() needs to know the size of the hugepage at the
>> > requested address to determine the offset to return - the current
>> > entry or the first entry of a set of contiguous hugepages. This came
>> > up while enabling support for memory failure handling on arm64[0].
>> > 
>> > Patch 1 adds a hstate parameter to huge_pte_offset() to provide
>> > additional information about the target address. It also updates the
>> > signatures (and usage) of huge_pte_offset() for architectures that
>> > override the generic implementation. This patch has been compile
>> > tested on ia64 and x86.
>> 
>> I haven't looked at the performance implications of making huge_pte_offset
>> just a little slower.  But, I think you can get hstate from the parameters
>> passed today.
>> 
>> vma = find_vma(mm, addr);
>> h = hstate_vma(vma);
>
> It's better to avoid find_vma() in fast(?) path if possible. So passing it
> down is probably better.

Also most call sites of huge_pte_offset() already have the hstate (or
the vma) readily available. So adding overhead feels unnecessary.

I agree that merging the patch will need some co-ordination but lets at
the least give it a shot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
