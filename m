Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id F2EB86B0010
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 20:50:41 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id r77-v6so6813889qke.3
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 17:50:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s35-v6sor17913176qtj.23.2018.10.10.17.50.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 17:50:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181011004618.GA237677@joelaf.mtv.corp.google.com>
References: <20181009201400.168705-1-joel@joelfernandes.org>
 <20181009220222.26nzajhpsbt7syvv@kshutemo-mobl1> <20181009230447.GA17911@joelaf.mtv.corp.google.com>
 <20181010100011.6jqjvgeslrvvyhr3@kshutemo-mobl1> <20181011004618.GA237677@joelaf.mtv.corp.google.com>
From: Joel Fernandes <joelaf@google.com>
Date: Wed, 10 Oct 2018 17:50:39 -0700
Message-ID: <CAJWu+oqEmAQ0vWB7fKitQPQjdMX0uhQs_Vb1jH5MFfDO8xBnHQ@mail.gmail.com>
Subject: Re: [PATCH] mm: Speed up mremap on large regions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "Cc: Android Kernel" <kernel-team@android.com>, Minchan Kim <minchan@google.com>, Hugh Dickins <hughd@google.com>, Lokesh Gidra <lokeshgidra@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Oct 10, 2018 at 5:46 PM, Joel Fernandes <joel@joelfernandes.org> wrote:
> On Wed, Oct 10, 2018 at 01:00:11PM +0300, Kirill A. Shutemov wrote:
[...]
>>
>> My worry is that some architecture has to allocate page table differently
>> depending on virtual address (due to aliasing or something). Original page
>> table was allocated for one virtual address and moving the page table to
>> different spot in virtual address space may break the invariant.
>>
>> > Also the clean up of the argument that you're proposing is a bit out of scope
>> > of this patch but yeah we could clean it up in a separate patch if needed. I
>> > don't feel too strongly about that. It seems cosmetic and in the future if
>> > the address that's passed in is needed, then the architecture can use it.
>>
>> Please, do. This should be pretty mechanical change, but it will help to
>> make sure that none of obscure architecture will be broken by the change.
>>
>
> The thing is its quite a lot of change, I wrote a coccinelle script to do it
> tree wide, following is the diffstat:
>  48 files changed, 91 insertions(+), 124 deletions(-)
>
> Imagine then having to add the address argument back in the future in case
> its ever needed. Is it really worth doing it? Anyway I confirmed that the
> address is NOT used for anything at the moment so your fears of the
> optimization doing anything wonky really don't exist at the moment. I really
> feel this is unnecessary but I am Ok with others agree the second arg to
> pte_alloc should be removed in light of this change. Andrew, what do you
> think?

I meant to say here, "I am Ok if others agree the second arg to
pte_alloc should be removed", but I would really like some input from
the others as well on what they think.
