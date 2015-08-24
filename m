Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 00CAA6B0255
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 09:16:22 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so72037144wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:16:21 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id gp2si3520719wib.13.2015.08.24.06.16.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 06:16:20 -0700 (PDT)
Date: Mon, 24 Aug 2015 14:15:57 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
Message-ID: <20150824131557.GB7557@n2100.arm.linux.org.uk>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
 <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
 <CACRpkdaRJJjCXR=vK1M2YhR26JZfGoBB+jcqz8r2MhERfxRzqA@mail.gmail.com>
 <CAPAsAGy-r8Z2N09wKV+e0kLfbwxd-eWK6N5Xajsnqq9jfyWqcQ@mail.gmail.com>
 <CACRpkdZmHLMxosLXjyOPdkavo=UNzmTcHOLF5vV4cS1ULfbq6A@mail.gmail.com>
 <CAPAsAGw-iawTpjJh66rQN5fqBFT6UBZCcv2eKx7JTqCXzhzpsw@mail.gmail.com>
 <CACRpkdY2i2M27gP_fXawkFrC_GFgWaKr5rEn6d47refNPiEk=g@mail.gmail.com>
 <55AE56DB.4040607@samsung.com>
 <CACRpkdYaqK8upK-3b01JbO_y+sHnk4-Hm1MfvjSy0tKUkFREtQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACRpkdYaqK8upK-3b01JbO_y+sHnk4-Hm1MfvjSy0tKUkFREtQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Walleij <linus.walleij@linaro.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David Keitel <dkeitel@codeaurora.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Alexander Potapenko <glider@google.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Jul 21, 2015 at 11:27:56PM +0200, Linus Walleij wrote:
> On Tue, Jul 21, 2015 at 4:27 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> 
> > I used vexpress. Anyway, it doesn't matter now, since I have an update
> > with a lot of stuff fixed, and it works on hardware.
> > I still need to do some work on it and tomorrow, probably, I will share.
> 
> Ah awesome. I have a stash of ARM boards so I can test it on a
> range of hardware once you feel it's ready.
> 
> Sorry for pulling stuff out of your hands, people are excited about
> KASan ARM32 as it turns out.

People may be excited about it because it's a new feature, but we really
need to consider whether gobbling up 512MB of userspace for it is a good
idea or not.  There are programs around which like to map large amounts
of memory into their process space, and the more we steal from them, the
more likely these programs are to fail.

The other thing which I'm not happy about is having a 16K allocation per
thread - the 16K allocation for the PGD is already prone to invoking the
OOM killer after memory fragmentation has set in, we don't need another
16K allocation.  We're going from one 16K allocation per process to that
_and_ one 16K allocation per thread.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
