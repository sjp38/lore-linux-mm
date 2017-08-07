Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6ECD26B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 14:45:59 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f11so952328oic.3
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:45:59 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id u6si4666069oib.413.2017.08.07.11.45.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 11:45:58 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id 76so857364ith.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:45:58 -0700 (PDT)
Message-ID: <1502131556.1803.10.camel@gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
From: Daniel Micay <danielmicay@gmail.com>
Date: Mon, 07 Aug 2017 14:45:56 -0400
In-Reply-To: <1502131092.1803.8.camel@gmail.com>
References: 
	<CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
	 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
	 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
	 <1502131092.1803.8.camel@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kostya Serebryany <kcc@google.com>, Kees Cook <keescook@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>, eugenis@google.com

> There are currently other issues. Try:
> 
> sysctl vm.mmap_rnd_bits=32
> sysctl vm.mmap_rnd_compat_bits=16
> 
> IIRC that breaks some sanitizers at least for 32-bit executables.

Also, stack mapping rand isn't yet tied to that sysctl but is rather
hard-wired to 11 bits on 32-bit and 20 bits (IIRC) on 64-bit. Once it's
tied to the sysctl (or a different sysctl, if keeping the same defaults
is desired) that will be able to use significantly more address space.

It might be setting it to the maximum + better stack rand that breaks
sanitizers, rather than just setting the entropy higher.

If anyone wants to test some other changes though...

https://github.com/copperhead/linux-hardened/commit/31ebed471d31a437cc551b1bfae03c9e7f58117d.patch
https://github.com/copperhead/linux-hardened/commit/073329e7b541b89172833f61fb84d81f32389d6e.patch

They haven't been submitted for inclusion upstream, but that's the plan:
reaching parity with the ASLR PaX has provided for years when the
entropy values are set to max.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
