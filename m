Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A17A6B0038
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 18:21:12 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id y46so2715669uac.11
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 15:21:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c80sor7272878vkf.128.2018.01.11.15.21.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jan 2018 15:21:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180111102400.GT17719@n2100.armlinux.org.uk>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
 <1515636190-24061-35-git-send-email-keescook@chromium.org> <20180111102400.GT17719@n2100.armlinux.org.uk>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 11 Jan 2018 15:21:09 -0800
Message-ID: <CAGXu5jKaz_rAi_R2x3V73306fw+1MOBN-6v-nK4_S=PU8_pzhA@mail.gmail.com>
Subject: Re: [PATCH 34/38] arm: Implement thread_struct whitelist for hardened usercopy
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Christian Borntraeger <borntraeger@de.ibm.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, linux-arm-kernel@lists.infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel-hardening@lists.openwall.com

On Thu, Jan 11, 2018 at 2:24 AM, Russell King - ARM Linux
<linux@armlinux.org.uk> wrote:
> On Wed, Jan 10, 2018 at 06:03:06PM -0800, Kees Cook wrote:
>> ARM does not carry FPU state in the thread structure, so it can declare
>> no usercopy whitelist at all.
>
> This comment seems to be misleading.  We have stored FP state in the
> thread structure for a long time - for example, VFP state is stored
> in thread->vfpstate.hard, so we _do_ have floating point state in
> the thread structure.
>
> What I think this commit message needs to describe is why we don't
> need a whitelist _despite_ having FP state in the thread structure.
>
> At the moment, the commit message is making me think that this patch
> is wrong and will introduce a regression.

Yeah, I will improve this comment; it's not clear enough. The places
where I see state copied to/from userspace are all either static sizes
or already use bounce buffers (or both). e.g.:

        err |= __copy_from_user(&hwstate->fpregs, &ufp->fpregs,
                                sizeof(hwstate->fpregs));

I will adjust the commit log and comment to more clearly describe the
lack of whitelisting due to all-static sized copies.

Thanks!

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
