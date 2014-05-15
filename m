Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 271676B0038
	for <linux-mm@kvack.org>; Thu, 15 May 2014 06:17:53 -0400 (EDT)
Received: by mail-ob0-f179.google.com with SMTP id vb8so968632obc.10
        for <linux-mm@kvack.org>; Thu, 15 May 2014 03:17:53 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id mp10si2832329oeb.122.2014.05.15.03.17.52
        for <linux-mm@kvack.org>;
        Thu, 15 May 2014 03:17:52 -0700 (PDT)
Date: Thu, 15 May 2014 11:17:34 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC][PATCH 2/2] ARM: ioremap: Add IO mapping space reused
 support.
Message-ID: <20140515101734.GA14737@localhost>
References: <1399861195-21087-1-git-send-email-superlibj8301@gmail.com>
 <1399861195-21087-3-git-send-email-superlibj8301@gmail.com>
 <5146762.jba3IJe7xt@wuerfel>
 <CAHPCO9FRfR5p1N5v7mUk4hUYdPvqfLN6nW1LcnC83sU86ZFbZA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHPCO9FRfR5p1N5v7mUk4hUYdPvqfLN6nW1LcnC83sU86ZFbZA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Lee <superlibj8301@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Lee <superlibj@gmail.com>

On Tue, May 13, 2014 at 09:45:08AM +0800, Richard Lee wrote:
> > On Mon, May 12, 2014 at 3:51 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> > On Monday 12 May 2014 10:19:55 Richard Lee wrote:
> >> For the IO mapping, for the same physical address space maybe
> >> mapped more than one time, for example, in some SoCs:
> >> 0x20000000 ~ 0x20001000: are global control IO physical map,
> >> and this range space will be used by many drivers.
> >> And then if each driver will do the same ioremap operation, we
> >> will waste to much malloc virtual spaces.
> >>
> >> This patch add IO mapping space reused support.
> >>
> >> Signed-off-by: Richard Lee <superlibj@gmail.com>
> >
> > What happens if the first driver then unmaps the area?
> 
> If the first driver will unmap the area, it shouldn't do any thing
> except decreasing the 'used' counter.

It's still racy. What if the first driver manage to decrement the used
counter, unmaps the regions but doesn't yet free the vm_struct while
another driver finds the vm_struct, increments the used count and
assumes it can use it?

BTW, vm_area_is_aready_to_free() name implies a query but it has
side-effects like decrementing the counter.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
