Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBDD26B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 21:57:56 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a8so238148447pfg.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 18:57:56 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id a203si57684161pfa.99.2016.11.28.18.57.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 18:57:55 -0800 (PST)
Subject: [PATCH] mremap: move_ptes: check pte dirty after its removal
References: <026b73f6-ca1d-e7bb-766c-4aaeb7071ce6@intel.com>
 <CA+55aFzHfpZckv8ck19fZSFK+3TmR5eF=BsDzhwVGKrbyEBjEw@mail.gmail.com>
 <c160bc18-7c1b-2d54-8af1-7c5bfcbcefe8@intel.com>
 <20161128083715.GA21738@aaronlu.sh.intel.com>
 <20161128084012.GC21738@aaronlu.sh.intel.com>
 <CA+55aFwm8MgLi3pDMOQr2gvmjRKXeSjsmV2kLYSYZHFiUa_0fQ@mail.gmail.com>
From: Aaron Lu <aaron.lu@intel.com>
Message-ID: <977b6c8b-2df3-5f4b-0d6c-fe766cf3fae0@intel.com>
Date: Tue, 29 Nov 2016 10:57:53 +0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFwm8MgLi3pDMOQr2gvmjRKXeSjsmV2kLYSYZHFiUa_0fQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 11/29/2016 01:15 AM, Linus Torvalds wrote:
> However, I also independently think I found an actual bug while
> looking at the code as part of looking at the patch.
> 
> This part looks racy:
> 
>                 /*
>                  * We are remapping a dirty PTE, make sure to
>                  * flush TLB before we drop the PTL for the
>                  * old PTE or we may race with page_mkclean().
>                  */
>                 if (pte_present(*old_pte) && pte_dirty(*old_pte))
>                         force_flush = true;
>                 pte = ptep_get_and_clear(mm, old_addr, old_pte);
> 
> where the issue is that another thread might make the pte be dirty (in
> the hardware walker, so no locking of ours make any difference)
> *after* we checked whether it was dirty, but *before* we removed it
> from the page tables.

Ah, very right. Thanks for the catch!

> 
> So I think the "check for force-flush" needs to come *after*, and we should do
> 
>                 pte = ptep_get_and_clear(mm, old_addr, old_pte);
>                 if (pte_present(pte) && pte_dirty(pte))
>                         force_flush = true;
> 
> instead.
> 
> This happens for the pmd case too.

Here is a fix patch, sorry for the trouble.
