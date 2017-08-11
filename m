Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 452E16B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 16:50:09 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id g131so4887606oic.10
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 13:50:09 -0700 (PDT)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id l2si1129940oib.447.2017.08.11.13.50.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 13:50:08 -0700 (PDT)
Received: by mail-oi0-x22c.google.com with SMTP id x3so43793970oia.1
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 13:50:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1502483265.6577.52.camel@redhat.com>
References: <20170811191942.17487-1-riel@redhat.com> <20170811191942.17487-3-riel@redhat.com>
 <CA+55aFzA+7CeCdUi-13DfOeE3FfhtTPMMmBA4UQx8FixXiD4YA@mail.gmail.com> <1502483265.6577.52.camel@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 11 Aug 2017 13:50:07 -0700
Message-ID: <CA+55aFzXBP-dvVC_q+FMDAxFKE1=PoFX+0FjEnSU+b54VpEKtw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm,fork: introduce MADV_WIPEONFORK
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm <linux-mm@kvack.org>, Florian Weimer <fweimer@redhat.com>, =?UTF-8?Q?Colm_MacC=C3=A1rthaigh?= <colm@allcosts.net>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>, Will Drewry <wad@chromium.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Linux API <linux-api@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>

On Fri, Aug 11, 2017 at 1:27 PM, Rik van Riel <riel@redhat.com> wrote:
>>
>> Yes, you don't do the page table copies. Fine. But you leave vma with
>> the the anon_vma pointer - doesn't that mean that it's still
>> connected
>> to the original anonvma chain, and we might end up swapping something
>> in?
>
> Swapping something in would require there to be a swap entry in
> the page table entries, which we are not copying, so this should
> not be a correctness issue.

Yeah, I thought the rmap code just used the offset from the start to
avoid even doing swap entries, but I guess we don't actually ever
populate the page tables without the swap entry being there.

> There is another test in copy_page_range already which ends up
> skipping the page table copy when it should not be done.

Well, the VM_DONTCOPY test is in dup_mmap(), and I think I'd rather
match up the VM_WIPEONFORK logic with VM_DONTCOPY than with the
copy_page_range() tests.

Because I assume you are talking about the "if it's a shared mapping,
we don't need to copy the page tables and can just do it at page fault
time instead" part? That's a rather different thing, which isn't so
much about semantics, as about just a trade-off about when to touch
the page tables.

But yes, that one *might* make sense in dup_mmap() too. I just don't
think it's really analogous to the WIPEONFORK and DONTCOPY tests.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
