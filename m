Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC4D56B0389
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 13:48:52 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m27so4837689iti.7
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 10:48:52 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id a16si591483ioa.47.2017.03.14.10.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 10:48:51 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id u69so692423ita.3
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 10:48:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170314074729.GA23151@gmail.com>
References: <20170313143309.16020-1-kirill.shutemov@linux.intel.com> <20170314074729.GA23151@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 14 Mar 2017 10:48:51 -0700
Message-ID: <CA+55aFzALboaXe5TWv8=3QZBPJCVAVBmfxTjQEi-aAnHKYAuPQ@mail.gmail.com>
Subject: Re: [PATCH 0/6] x86: 5-level paging enabling for v4.12, Part 1
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Mar 14, 2017 at 12:47 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> I've also applied the GUP patch, with the assumption that you'll address Linus's
> request to switch x86 over to the generic version.

Note that switching over to the generic version is somewhat fraught
with subtle issues:

 (a) we need to make sure that x86 actually matches the required
semantics for the generic GUP.

 (b) we need to make sure the atomicity of the page table reads is ok.

 (c) need to verify the maximum VM address properly

I _think_ (a) is ok. The code (and the config option name) talks about
freeing page tables using RCU, but in fact I don't think it relies on
it, and it's sufficient that it disables interrupts and that that will
block any IPI's.

In contrast, I think (b) needs real work to make sure it's ok on
32-bit PAE with 64-bit pte entries. The generic code currently just
does READ_ONCE(), while the x86 code does gup_get_pte().

And (c) means that we need to really replace that generic code that
does "access_ok()": with a proper check against maximum user address
(ie independent of set_fs(KERNEL_DS)).

But it would be good to aim for unifying this part of the VM,
considering how many bugs we've had in GUP. The latest 5-level typo
has not been the only one. It's clearly more subtle than you'd think.

So it's not quite as simple as just "switching over". I think we need
to introduce that gup_get_pte() to all the generic users, and we need
to introduce a "user address limit" for those architectures too.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
