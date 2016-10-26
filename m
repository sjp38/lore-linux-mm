Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65BC56B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 17:30:51 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f78so16569964oih.7
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 14:30:51 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id g41si2720069otc.179.2016.10.26.14.30.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 14:30:50 -0700 (PDT)
Received: by mail-oi0-x234.google.com with SMTP id y2so12992647oie.0
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 14:30:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1731570270.13088320.1477515684152.JavaMail.zimbra@redhat.com>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
 <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com>
 <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
 <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com>
 <CA+55aFyRv0YttbLUYwDem=-L5ZAET026umh6LOUQ6hWaRur_VA@mail.gmail.com>
 <996124132.13035408.1477505043741.JavaMail.zimbra@redhat.com>
 <CA+55aFzVmppmua4U0pesp2moz7vVPbH1NP264EKeW3YqOzFc3A@mail.gmail.com> <1731570270.13088320.1477515684152.JavaMail.zimbra@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 26 Oct 2016 14:30:49 -0700
Message-ID: <CA+55aFxfb-kY40P4HgYnhehx--TuwV7K7C4J4jdx9nan7u0s1A@mail.gmail.com>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Peterson <rpeterso@redhat.com>, Borislav Petkov <bp@suse.de>
Cc: Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 26, 2016 at 2:01 PM, Bob Peterson <rpeterso@redhat.com> wrote:
>
> Hm. It didn't even boot, at least on my amd box in the lab.
> I've made no attempt to debug this.

Hmm. Looks like a completely independent issue from the patch. Did you
try booting that machine without the patch?

> [    2.378877] kernel BUG at arch/x86/mm/physaddr.c:26!

Ok, similar issue, I think - passing a non-1:1 address to __phys_addr().

But the call trace has nothing to do with gfs2 or the bitlocks:

> [    2.504561] Call Trace:
> [    2.507005]   save_microcode_in_initrd_amd+0x31/0x106
> [    2.513778]   save_microcode_in_initrd+0x3c/0x45
> [    2.526110]   do_one_initcall+0x50/0x180
> [    2.531756]   ? set_debug_rodata+0x12/0x12
> [    2.537573]   kernel_init_freeable+0x194/0x230
> [    2.543740]   ? rest_init+0x80/0x80
> [    2.548952]   kernel_init+0xe/0x100
> [    2.554164]   ret_from_fork+0x25/0x30

I think this might be the

        cont    = __pa(container);

line in save_microcode_in_initrd_amd().

I see that Borislav is busy with some x86/microcode patches, I suspect
he already hit this. Adding Borislav to the cc.

Can you re-try without the AMD microcode driver for now? This seems to
be a separate issue from the gfs2 one.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
