Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id C2C398E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 12:59:47 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id v184so1702135oie.6
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 09:59:47 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a66si8799379otb.92.2018.12.18.09.59.46
        for <linux-mm@kvack.org>;
        Tue, 18 Dec 2018 09:59:46 -0800 (PST)
Date: Tue, 18 Dec 2018 17:59:38 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC][PATCH 0/3] arm64 relaxed ABI
Message-ID: <20181218175938.GD20197@arrakis.emea.arm.com>
References: <cover.1544445454.git.andreyknvl@google.com>
 <20181210143044.12714-1-vincenzo.frascino@arm.com>
 <CAAeHK+xPZ-Z9YUAq=3+hbjj4uyJk32qVaxZkhcSAHYC4mHAkvQ@mail.gmail.com>
 <20181212150230.GH65138@arrakis.emea.arm.com>
 <CAAeHK+zxYJDJ7DJuDAOuOMgGvckFwMAoVUTDJzb6MX3WsXhRTQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+zxYJDJ7DJuDAOuOMgGvckFwMAoVUTDJzb6MX3WsXhRTQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, Linux Memory Management List <linux-mm@kvack.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Evgenii Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Kostya Serebryany <kcc@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>

On Tue, Dec 18, 2018 at 04:03:38PM +0100, Andrey Konovalov wrote:
> On Wed, Dec 12, 2018 at 4:02 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > The summary of our internal discussions (mostly between kernel
> > developers) is that we can't properly describe a user ABI that covers
> > future syscalls or syscall extensions while not all syscalls accept
> > tagged pointers. So we tweaked the requirements slightly to only allow
> > tagged pointers back into the kernel *if* the originating address is
> > from an anonymous mmap() or below sbrk(0). This should cover some of the
> > ioctls or getsockopt(TCP_ZEROCOPY_RECEIVE) where the user passes a
> > pointer to a buffer obtained via mmap() on the device operations.
> >
> > (sorry for not being clear on what Vincenzo's proposal implies)
> 
> OK, I see. So I need to make the following changes to my patchset AFAIU.
> 
> 1. Make sure that we only allow tagged user addresses that originate
> from an anonymous mmap() or below sbrk(0). How exactly should this
> check be performed?

I don't think we should perform such checks. That's rather stating that
the kernel only guarantees that the tagged pointers work if they
originated from these memory ranges.

> 2. Allow tagged addressed passed to memory syscalls (as long as (1) is
> satisfied). Do I understand correctly that this means that I need to
> locate all find_vma() callers outside of mm/ and fix them up as well?

Yes (unless anyone as a better idea or objections to this approach).

BTW, I'll be off until the new year, so won't be able to follow up.

-- 
Catalin
