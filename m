Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 860C26B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 06:24:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y134so91237779pfg.1
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 03:24:13 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id b6si2714268pag.62.2016.07.20.03.24.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 03:24:12 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id q2so3084928pap.0
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 03:24:12 -0700 (PDT)
Message-ID: <1469010283.2800.5.camel@gmail.com>
Subject: Re: [PATCH v3 02/11] mm: Hardened usercopy
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 20 Jul 2016 20:24:43 +1000
In-Reply-To: <CAGXu5j+nHpHcYT8FyHNe6AFQCdakoSMW=UWDatyxhRK7CB7_=g@mail.gmail.com>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
	 <1468619065-3222-3-git-send-email-keescook@chromium.org>
	 <fc3c7f68-bd2e-cb06-c47c-d97c520fc08b@redhat.com>
	 <CAGXu5j+nHpHcYT8FyHNe6AFQCdakoSMW=UWDatyxhRK7CB7_=g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S.
 Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, 2016-07-19 at 11:48 -0700, Kees Cook wrote:
> On Mon, Jul 18, 2016 at 6:06 PM, Laura Abbott <labbott@redhat.com> wrote:
> >A 
> > On 07/15/2016 02:44 PM, Kees Cook wrote:
> >A 
> > This doesn't work when copying CMA allocated memory since CMA purposely
> > allocates larger than a page block size without setting head pages.
> > Given CMA may be used with drivers doing zero copy buffers, I think it
> > should be permitted.
> >A 
> > Something like the following lets it pass (I can clean up and submit
> > the is_migrate_cma_page APIs as a separate patch for review)
> Yeah, this would be great. I'd rather use an accessor to check this
> than a direct check for MIGRATE_CMA.
>
> > A A A A A A A A A */
> > A A A A A A A A for (; ptr <= end ; ptr += PAGE_SIZE, page = virt_to_head_page(ptr))
> > {
> > -A A A A A A A A A A A A A A A if (!PageReserved(page))
> > +A A A A A A A A A A A A A A A if (!PageReserved(page) && !is_migrate_cma_page(page))
> > A A A A A A A A A A A A A A A A A A A A A A A A return "<spans multiple pages>";
> > A A A A A A A A }
> Yeah, I'll modify this a bit so that which type it starts as is
> maintained for all pages (rather than allowing to flip back and forth
> -- even though that is likely impossible).
>A 
Sorry, I completely missed the MIGRATE_CMA bits. Could you clarify if you
caught this in testing/review?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
