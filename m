Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67F46440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 14:04:25 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 76so5397584pfr.3
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 11:04:25 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v13si227266plk.576.2017.11.09.11.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 11:04:24 -0800 (PST)
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C5917214EE
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 19:04:23 +0000 (UTC)
Received: by mail-io0-f176.google.com with SMTP id p186so10954043ioe.12
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 11:04:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171108194731.AB5BDA01@viggo.jf.intel.com>
References: <20171108194646.907A1942@viggo.jf.intel.com> <20171108194731.AB5BDA01@viggo.jf.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 9 Nov 2017 11:04:02 -0800
Message-ID: <CALCETrUs-6yWK9uYLFmVNhYz9e1NAUbT6BPJKHge8Zkwghsesg@mail.gmail.com>
Subject: Re: [PATCH 24/30] x86, kaiser: disable native VSYSCALL
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Wed, Nov 8, 2017 at 11:47 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> The VSYSCALL page is mapped by kernel page tables at a kernel address.
> It is troublesome to support with KAISER in place, so disable the
> native case.
>
> Also add some help text about how KAISER might affect the emulation
> case as well.

Can you re-explain why this is helpful?

Also, I'm about to send patches that may cause a rethinking of how
KAISER handles the fixmap.

--Andy

>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
> Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
> Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
> Cc: Richard Fellner <richard.fellner@student.tugraz.at>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Kees Cook <keescook@google.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: x86@kernel.org
>
> ---
>
>  b/arch/x86/Kconfig |    8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff -puN arch/x86/Kconfig~kaiser-no-vsyscall arch/x86/Kconfig
> --- a/arch/x86/Kconfig~kaiser-no-vsyscall       2017-11-08 10:45:39.157681370 -0800
> +++ b/arch/x86/Kconfig  2017-11-08 10:45:39.162681370 -0800
> @@ -2231,6 +2231,9 @@ choice
>
>         config LEGACY_VSYSCALL_NATIVE
>                 bool "Native"
> +               # The VSYSCALL page comes from the kernel page tables
> +               # and is not available when KAISER is enabled.
> +               depends on ! KAISER
>                 help
>                   Actual executable code is located in the fixed vsyscall
>                   address mapping, implementing time() efficiently. Since
> @@ -2248,6 +2251,11 @@ choice
>                   exploits. This configuration is recommended when userspace
>                   still uses the vsyscall area.
>
> +                 When KAISER is enabled, the vsyscall area will become
> +                 unreadable.  This emulation option still works, but KAISER
> +                 will make it harder to do things like trace code using the
> +                 emulation.
> +
>         config LEGACY_VSYSCALL_NONE
>                 bool "None"
>                 help
> _

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
