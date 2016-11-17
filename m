Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD976B0337
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 12:53:23 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id x190so189934923qkb.5
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 09:53:23 -0800 (PST)
Received: from mail-yb0-x244.google.com (mail-yb0-x244.google.com. [2607:f8b0:4002:c09::244])
        by mx.google.com with ESMTPS id p63si2678078qkd.192.2016.11.17.09.53.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 09:53:22 -0800 (PST)
Received: by mail-yb0-x244.google.com with SMTP id d59so7815585ybi.2
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 09:53:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <026b73f6-ca1d-e7bb-766c-4aaeb7071ce6@intel.com>
References: <026b73f6-ca1d-e7bb-766c-4aaeb7071ce6@intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 17 Nov 2016 09:53:21 -0800
Message-ID: <CA+55aFzHfpZckv8ck19fZSFK+3TmR5eF=BsDzhwVGKrbyEBjEw@mail.gmail.com>
Subject: Re: [PATCH] mremap: fix race between mremap() and page cleanning
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>

On Thu, Nov 10, 2016 at 1:16 AM, Aaron Lu <aaron.lu@intel.com> wrote:
> Prior to 3.15, there was a race between zap_pte_range() and
> page_mkclean() where writes to a page could be lost.  Dave Hansen
> discovered by inspection that there is a similar race between
> move_ptes() and  page_mkclean().

Ok, patch applied.

I'm not entirely happy with the force_flush vs need_flush games, and I
really think this code should be updated to use the same "struct
mmu_gather" that we use for the other TLB flushing cases (no need for
the page freeing batching, but the tlb_flush_mmu_tlbonly() logic
should be the same).

But I guess that's a bigger change, so that wouldn't be approriate for
rc5 or stable back-porting anyway. But it would be lovely if somebody
could look at that. Hint hint.

Hmm?

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
