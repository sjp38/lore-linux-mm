Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91F136B025F
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 04:01:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x7so1582642pfa.19
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 01:01:16 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h11si4006483pgf.463.2017.11.01.01.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 01:01:15 -0700 (PDT)
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2E3A721921
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 08:01:15 +0000 (UTC)
Received: by mail-io0-f177.google.com with SMTP id h70so4339388ioi.4
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 01:01:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171031223208.F271E813@viggo.jf.intel.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223208.F271E813@viggo.jf.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 1 Nov 2017 01:00:54 -0700
Message-ID: <CALCETrVbGHJUeZP2X36s-gUcEywpv_uuAwZRVAJWL5U8DijPkQ@mail.gmail.com>
Subject: Re: [PATCH 12/23] x86, kaiser: map dynamically-allocated LDTs
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Tue, Oct 31, 2017 at 3:32 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> Normally, a process just has a NULL mm->context.ldt.  But, we
> have a syscall for a process to set a new one.  If a process does
> that, we need to map the new LDT.
>
> The original KAISER patch missed this case.

Tglx suggested that we instead increase the padding at the top of the
user address space from 4k to 64k and put the LDT there.  This is a
slight ABI break, but I'd be rather surprised if anything noticed,
especially because the randomized vdso currently regularly lands there
(IIRC), so any user code that explicitly uses those 60k already
collides with the vdso.

I can make this happen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
