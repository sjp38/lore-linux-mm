Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 549536B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 16:27:52 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id hb3so108431930igb.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 13:27:52 -0800 (PST)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id qo12si5183366igb.4.2016.02.17.13.27.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 13:27:51 -0800 (PST)
Received: by mail-ig0-x22f.google.com with SMTP id g6so68375363igt.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 13:27:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160212210240.CB4BB5CA@viggo.jf.intel.com>
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
	<20160212210240.CB4BB5CA@viggo.jf.intel.com>
Date: Wed, 17 Feb 2016 13:27:51 -0800
Message-ID: <CAGXu5j+L6W17wkKNdheUQQ01bJE4ZXLDiG=5JBaNWju2j9NB2Q@mail.gmail.com>
Subject: Re: [PATCH 33/33] x86, pkeys: execute-only support
From: Kees Cook <keescook@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>

On Fri, Feb 12, 2016 at 1:02 PM, Dave Hansen <dave@sr71.net> wrote:
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
> I haven't found any userspace that does this today.  With this
> facility in place, we expect userspace to move to use it
> eventually.  Userspace _could_ start doing this today.  Any
> PROT_EXEC calls get converted to PROT_READ inside the kernel, and
> would transparently be upgraded to "true" PROT_EXEC with this
> code.  IOW, userspace never has to do any PROT_EXEC runtime
> detection.

Random thought while skimming email:

Is there a way to detect this feature's availability without userspace
having to set up a segv handler and attempting to read a
PROT_EXEC-only region? (i.e. cpu flag for protection keys, or a way to
check the protection to see if PROT_READ got added automatically,
etc?)

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
