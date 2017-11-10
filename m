Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 90F4A440D41
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 17:04:09 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m188so476812pga.22
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:04:09 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g17si8545305plo.542.2017.11.10.14.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 14:04:08 -0800 (PST)
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A8A3C218E3
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 22:04:07 +0000 (UTC)
Received: by mail-io0-f175.google.com with SMTP id f20so15031479ioj.9
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:04:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171110193146.5908BE13@viggo.jf.intel.com>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193146.5908BE13@viggo.jf.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 10 Nov 2017 14:03:46 -0800
Message-ID: <CALCETrXrXpTZE2sceBh=eW5kEP79hWc5iY36QKjfy=U4nTirDw@mail.gmail.com>
Subject: Re: [PATCH 21/30] x86, mm: put mmu-to-h/w ASID translation in one place
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Fri, Nov 10, 2017 at 11:31 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> There are effectively two ASID types:
> 1. The one stored in the mmu_context that goes from 0->5
> 2. The one programmed into the hardware that goes from 1->6
>
> This consolidates the locations where converting beween the two
> (by doing +1) to a single place which gives us a nice place to
> comment.  KAISER will also need to, given an ASID, know which
> hardware ASID to flush for the userspace mapping.
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
> ---
>
>  b/arch/x86/include/asm/tlbflush.h |   30 ++++++++++++++++++------------
>  1 file changed, 18 insertions(+), 12 deletions(-)
>
> diff -puN arch/x86/include/asm/tlbflush.h~kaiser-pcid-pre-build-kern arch/x86/include/asm/tlbflush.h
> --- a/arch/x86/include/asm/tlbflush.h~kaiser-pcid-pre-build-kern        2017-11-10 11:22:16.521244931 -0800
> +++ b/arch/x86/include/asm/tlbflush.h   2017-11-10 11:22:16.525244931 -0800
> @@ -87,21 +87,26 @@ static inline u64 inc_mm_tlb_gen(struct
>   */
>  #define MAX_ASID_AVAILABLE ((1<<CR3_AVAIL_ASID_BITS) - 2)
>
> -/*
> - * If PCID is on, ASID-aware code paths put the ASID+1 into the PCID
> - * bits.  This serves two purposes.  It prevents a nasty situation in
> - * which PCID-unaware code saves CR3, loads some other value (with PCID
> - * == 0), and then restores CR3, thus corrupting the TLB for ASID 0 if
> - * the saved ASID was nonzero.  It also means that any bugs involving
> - * loading a PCID-enabled CR3 with CR4.PCIDE off will trigger
> - * deterministically.
> - */
> +static inline u16 kern_asid(u16 asid)
> +{
> +       VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
> +       /*
> +        * If PCID is on, ASID-aware code paths put the ASID+1 into the PCID
> +        * bits.  This serves two purposes.  It prevents a nasty situation in
> +        * which PCID-unaware code saves CR3, loads some other value (with PCID
> +        * == 0), and then restores CR3, thus corrupting the TLB for ASID 0 if
> +        * the saved ASID was nonzero.  It also means that any bugs involving
> +        * loading a PCID-enabled CR3 with CR4.PCIDE off will trigger
> +        * deterministically.
> +        */
> +       return asid + 1;
> +}

This seems really error-prone.  Maybe we should have a pcid_t type and
make all the interfaces that want a h/w PCID take pcid_t.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
