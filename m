Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC3C06B0262
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 01:48:52 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id r135so142810576vkf.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 22:48:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h4si311242ybb.17.2016.07.13.22.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 22:48:52 -0700 (PDT)
Date: Thu, 14 Jul 2016 00:48:42 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH v2 01/11] mm: Implement stack frame object validation
Message-ID: <20160714054842.6zal5rqawpgew26r@treble>
References: <1468446964-22213-1-git-send-email-keescook@chromium.org>
 <1468446964-22213-2-git-send-email-keescook@chromium.org>
 <CALCETrVDJDjdoh7yvOPd=_5twQnzQRhe8G2KLaRw-NnA1Uf__g@mail.gmail.com>
 <CAGXu5jLPZiRJx8n3_7GW2bufiuUgE9=c6dQcNxDRPHMU72sD9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAGXu5jLPZiRJx8n3_7GW2bufiuUgE9=c6dQcNxDRPHMU72sD9g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andy Lutomirski <luto@amacapital.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, X86 ML <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Wed, Jul 13, 2016 at 03:04:26PM -0700, Kees Cook wrote:
> On Wed, Jul 13, 2016 at 3:01 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> > On Wed, Jul 13, 2016 at 2:55 PM, Kees Cook <keescook@chromium.org> wrote:
> >> This creates per-architecture function arch_within_stack_frames() that
> >> should validate if a given object is contained by a kernel stack frame.
> >> Initial implementation is on x86.
> >>
> >> This is based on code from PaX.
> >>
> >
> > This, along with Josh's livepatch work, are two examples of unwinders
> > that matter for correctness instead of just debugging.  ISTM this
> > should just use Josh's code directly once it's been written.
> 
> Do you have URL for Josh's code? I'd love to see what happening there.

The code is actually going to be 100% different next time around, but
FWIW, here's the last attempt:

  https://lkml.kernel.org/r/4d34d452bf8f85c7d6d5f93db1d3eeb4cba335c7.1461875890.git.jpoimboe@redhat.com

In the meantime I've realized the need to rewrite the x86 core stack
walking code to something much more manageable so we don't need all
these unwinders everywhere.  I'll probably post the patches in the next
week or so.  I'll add you to the CC list.

With the new interface I think you'll be able to do something like:

	struct unwind_state;

	unwind_start(&state, current, NULL, NULL);
	unwind_next_frame(&state);
	oldframe = unwind_get_stack_pointer(&state);

	unwind_next_frame(&state);
	frame = unwind_get_stack_pointer(&state);

	do {
		if (obj + len <= frame)
			return blah;
		oldframe = frame;
		frame = unwind_get_stack_pointer(&state);

	} while (unwind_next_frame(&state);

And then at the end there'll be some (still TBD) way to query whether it
reached the last syscall pt_regs frame, or if it instead encountered a
bogus frame pointer along the way and had to bail early.

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
