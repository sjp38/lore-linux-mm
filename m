Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 407DE6B00AE
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 16:57:28 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id x12so3790381wgg.6
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 13:57:27 -0800 (PST)
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com. [74.125.82.175])
        by mx.google.com with ESMTPS id bz14si4225658wib.84.2015.02.18.13.57.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Feb 2015 13:57:26 -0800 (PST)
Received: by wevk48 with SMTP id k48so3859623wev.3
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 13:57:26 -0800 (PST)
Date: Wed, 18 Feb 2015 22:57:22 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 6/7] x86, mm: Support huge I/O mappings on x86
Message-ID: <20150218215722.GA27863@gmail.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
 <1423521935-17454-7-git-send-email-toshi.kani@hp.com>
 <20150218204414.GA20943@gmail.com>
 <1424294020.17007.21.camel@misato.fc.hp.com>
 <20150218211555.GA22696@gmail.com>
 <1424295209.17007.34.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424295209.17007.34.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com


* Toshi Kani <toshi.kani@hp.com> wrote:

> On Wed, 2015-02-18 at 22:15 +0100, Ingo Molnar wrote:
> > * Toshi Kani <toshi.kani@hp.com> wrote:
> > 
> > > On Wed, 2015-02-18 at 21:44 +0100, Ingo Molnar wrote:
> > > > * Toshi Kani <toshi.kani@hp.com> wrote:
> > > > 
> > > > > This patch implements huge I/O mapping capability interfaces on x86.
> > > > 
> > > > > +#ifdef CONFIG_HUGE_IOMAP
> > > > > +#ifdef CONFIG_X86_64
> > > > > +#define IOREMAP_MAX_ORDER       (PUD_SHIFT)
> > > > > +#else
> > > > > +#define IOREMAP_MAX_ORDER       (PMD_SHIFT)
> > > > > +#endif
> > > > > +#endif  /* CONFIG_HUGE_IOMAP */
> > > > 
> > > > > +#ifdef CONFIG_HUGE_IOMAP
> > > > 
> > > > Hm, so why is there a Kconfig option for this? It just 
> > > > complicates things.
> > > > 
> > > > For example the kernel already defaults to mapping itself 
> > > > with as large mappings as possible, without a Kconfig entry 
> > > > for it. There's no reason to make this configurable - and 
> > > > quite a bit of complexity in the patches comes from this 
> > > > configurability.
> > > 
> > > This Kconfig option was added to disable this feature in 
> > > case there is an issue. [...]
> > 
> > If bugs are found then they should be fixed.
> 
> Right.
> 
> > > [...]  That said, since the patchset also added a new 
> > > nohugeiomap boot option for the same purpose, I agree 
> > > that this Kconfig option can be removed.  So, I will 
> > > remove it in the next version.
> > > 
> > > An example of such case is with multiple MTRRs described 
> > > in patch 0/7.
> > 
> > So the multi-MTRR case should probably be detected and 
> > handled safely?
> 
> I considered two options to safely handle this case, i.e. 
> option A) and B) described in the link below.
>
>   https://lkml.org/lkml/2015/2/5/638
> 
> I thought about how much complication we should put into 
> the code for an imaginable platform with a combination of 
> new NVM (or large I/O range) and legacy MTRRs with 
> multi-types & contiguous ranges.  My thinking is that we 
> should go with option C) for simplicity, and implement A) 
> or B) later if we find it necessary.

Well, why not option D):

   D) detect unaligned requests and reject them

?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
