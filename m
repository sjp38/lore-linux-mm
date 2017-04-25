Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 12A986B0374
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:43:45 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t184so115229784oif.12
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 09:43:45 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id e8si12759284oif.234.2017.04.25.09.43.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 09:43:44 -0700 (PDT)
Received: by mail-oi0-x22d.google.com with SMTP id y11so146362895oie.0
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 09:43:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170425092557.21852-1-kirill.shutemov@linux.intel.com>
References: <20170425092557.21852-1-kirill.shutemov@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 25 Apr 2017 09:43:43 -0700
Message-ID: <CAPcyv4j6woeE7QfTVXEohh-kCbcFFJQmciMmgf5RDDWntM+P5w@mail.gmail.com>
Subject: Re: [PATCH] x86/mm/64: Fix crash in remove_pagetable()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Apr 25, 2017 at 2:25 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> remove_pagetable() does page walk using p*d_page_vaddr() plus cast.
> It's not canonical approach -- we usually use p*d_offset() for that.
>
> It works fine as long as all page table levels are present. We broke the
> invariant by introducing folded p4d page table level.
>
> As result, remove_pagetable() interprets PMD as PUD and it leads to
> crash:
>
>         BUG: unable to handle kernel paging request at ffff880300000000
>         IP: memchr_inv+0x60/0x110
>         PGD 317d067
>         P4D 317d067
>         PUD 3180067
>         PMD 33f102067
>         PTE 8000000300000060
>
> Let's fix this by using p*d_offset() instead of p*d_page_vaddr() for
> page walk.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Dan Williams <dan.j.williams@intel.com>
> Fixes: f2a6a7050109 ("x86: Convert the rest of the code to support p4d_t")

Thanks! This patch on top of tip/master passes a full run of the
nvdimm regression suite.

Tested-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
