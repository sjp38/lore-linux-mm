Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD4276B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 22:06:40 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j92so277153314ioi.2
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 19:06:40 -0800 (PST)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id s75si42669672ios.102.2016.11.28.19.06.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 19:06:40 -0800 (PST)
Received: by mail-io0-x243.google.com with SMTP id r94so26749721ioe.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 19:06:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <977b6c8b-2df3-5f4b-0d6c-fe766cf3fae0@intel.com>
References: <026b73f6-ca1d-e7bb-766c-4aaeb7071ce6@intel.com>
 <CA+55aFzHfpZckv8ck19fZSFK+3TmR5eF=BsDzhwVGKrbyEBjEw@mail.gmail.com>
 <c160bc18-7c1b-2d54-8af1-7c5bfcbcefe8@intel.com> <20161128083715.GA21738@aaronlu.sh.intel.com>
 <20161128084012.GC21738@aaronlu.sh.intel.com> <CA+55aFwm8MgLi3pDMOQr2gvmjRKXeSjsmV2kLYSYZHFiUa_0fQ@mail.gmail.com>
 <977b6c8b-2df3-5f4b-0d6c-fe766cf3fae0@intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 28 Nov 2016 19:06:39 -0800
Message-ID: <CA+55aFx_vOfab=WNHd=OR7vng2V_UqrEdx_xZBsKv_ohE65f8w@mail.gmail.com>
Subject: Re: [PATCH] mremap: move_ptes: check pte dirty after its removal
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Nov 28, 2016 at 6:57 PM, Aaron Lu <aaron.lu@intel.com> wrote:
>
> Here is a fix patch, sorry for the trouble.

I don't think you tested this one.. You've now essentially reverted
5d1904204c99 entirely by making the new force_flush logic a no-op.

> +               pmd = pmdp_huge_get_and_clear(mm, old_addr, old_pmd);
>                 if (pmd_present(*old_pmd) && pmd_dirty(*old_pmd))
>                         force_flush = true;

You need to be testing "pmd", not "*old_pmd".

Because now "*old_pmd" will be zeroes.

>                 if (pte_present(*old_pte) && pte_dirty(*old_pte))
>                         force_flush = true;

Similarly here. You need to check "pte", not "*old_pte".

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
