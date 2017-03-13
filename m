Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 88A766B0389
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 10:03:41 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g8so14036920wmg.7
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 07:03:41 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l81si10981717wma.110.2017.03.13.07.03.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 07:03:40 -0700 (PDT)
Date: Mon, 13 Mar 2017 15:03:25 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv6 4/5] x86/mm: check in_compat_syscall() instead TIF_ADDR32
 for mmap(MAP_32BIT)
In-Reply-To: <4f802f8b-07a6-f8cd-71fc-943e40714d1b@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1703131502240.3558@nanos>
References: <20170306141721.9188-1-dsafonov@virtuozzo.com> <20170306141721.9188-5-dsafonov@virtuozzo.com> <alpine.DEB.2.20.1703131035020.3558@nanos> <35a16a2c-c799-fe0c-2689-bf105b508663@virtuozzo.com> <alpine.DEB.2.20.1703131446410.3558@nanos>
 <4f802f8b-07a6-f8cd-71fc-943e40714d1b@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michael Kerrisk <mtk@man7.org>

On Mon, 13 Mar 2017, Dmitry Safonov wrote:
> On 03/13/2017 04:47 PM, Thomas Gleixner wrote:
> > On Mon, 13 Mar 2017, Dmitry Safonov wrote:
> > > On 03/13/2017 12:39 PM, Thomas Gleixner wrote:
> > > > On Mon, 6 Mar 2017, Dmitry Safonov wrote:
> > > > 
> > > > > Result of mmap() calls with MAP_32BIT flag at this moment depends
> > > > > on thread flag TIF_ADDR32, which is set during exec() for 32-bit apps.
> > > > > It's broken as the behavior of mmap() shouldn't depend on exec-ed
> > > > > application's bitness. Instead, it should check the bitness of mmap()
> > > > > syscall.
> > > > > How it worked before:
> > > > > o for 32-bit compatible binaries it is completely ignored. Which was
> > > > > fine when there were one mmap_base, computed for 32-bit syscalls.
> > > > > After introducing mmap_compat_base 64-bit syscalls do use computed
> > > > > for 64-bit syscalls mmap_base, which means that we can allocate 64-bit
> > > > > address with 64-bit syscall in application launched from 32-bit
> > > > > compatible binary. And ignoring this flag is not expected behavior.
> > > > 
> > > > Well, the real question here is, whether we should allow 32bit
> > > > applications
> > > > to obtain 64bit mappings at all. We can very well force 32bit
> > > > applications
> > > > into the 4GB address space as it was before your mmap base splitup and
> > > > be
> > > > done with it.
> > > 
> > > Hmm, yes, we could restrict 32bit applications to 32bit mappings only.
> > > But the approach which I tried to follow in the patches set, it was do
> > > not base the logic on the bitness of launched applications
> > > (native/compat) - only base on bitness of the performing syscall.
> > > The idea was suggested by Andy and I made mmap() logic here independent
> > > from original application's bitness.
> > > 
> > > It also seems to me simpler:
> > > if 32-bit application wants to allocate 64-bit mapping, it should
> > > long-jump with 64-bit segment descriptor and do `syscall` instruction
> > > for 64-bit syscall entry path. So, in my point of view after this dance
> > > the application does not differ much from native 64-bit binary and can
> > > have 64-bit address mapping.
> > 
> > Works for me, but it lacks documentation .....
> 
> Sure, could you recommend a better place for it?
> Should it be in-code comment in x86 mmap() code or Documentation/*
> change or a patch to man-pages?

I added a comment in the code and fixed up the changelogs. man-page needs
some care as well.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
