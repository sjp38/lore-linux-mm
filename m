Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 462016B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:05:26 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id to4so13725418igc.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 12:05:26 -0800 (PST)
Received: from mail-io0-x229.google.com (mail-io0-x229.google.com. [2607:f8b0:4001:c06::229])
        by mx.google.com with ESMTPS id u4si24687488igr.88.2015.12.14.12.05.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 12:05:25 -0800 (PST)
Received: by ioae126 with SMTP id e126so56485091ioa.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 12:05:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151214190632.6A741188@viggo.jf.intel.com>
References: <20151214190542.39C4886D@viggo.jf.intel.com>
	<20151214190632.6A741188@viggo.jf.intel.com>
Date: Mon, 14 Dec 2015 12:05:25 -0800
Message-ID: <CAGXu5jJ5oHy11Uy4N2m1aa2A9ar9-oH_kez9jq=gM8CVSj734Q@mail.gmail.com>
Subject: Re: [PATCH 31/32] x86, pkeys: execute-only support
From: Kees Cook <keescook@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon, Dec 14, 2015 at 11:06 AM, Dave Hansen <dave@sr71.net> wrote:
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> Protection keys provide new page-based protection in hardware.
> But, they have an interesting attribute: they only affect data
> accesses and never affect instruction fetches.  That means that
> if we set up some memory which is set as "access-disabled" via
> protection keys, we can still execute from it.
>
> This patch uses protection keys to set up mappings to do just that.
> If a user calls:
>
>         mmap(..., PROT_EXEC);
> or
>         mprotect(ptr, sz, PROT_EXEC);
>
> (note PROT_EXEC-only without PROT_READ/WRITE), the kernel will
> notice this, and set a special protection key on the memory.  It
> also sets the appropriate bits in the Protection Keys User Rights
> (PKRU) register so that the memory becomes unreadable and
> unwritable.
>
> I haven't found any userspace that does this today.

To realistically take advantage of this, it sounds like the linker
would need to know to keep bss and data page-aligned away from text,
and then set text to PROT_EXEC only?

Do you have any example linker scripts for this?

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
