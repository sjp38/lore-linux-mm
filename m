Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 235216B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 07:39:04 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id b57so222511eek.12
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 04:39:03 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id x44si26655040eep.210.2014.04.29.04.39.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Apr 2014 04:39:02 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: ARM: mm: Could I change module space size or place modules in vmalloc area?
Date: Tue, 29 Apr 2014 13:35:34 +0200
Message-ID: <4710126.4mE2sZLRKS@wuerfel>
In-Reply-To: <20140429111946.GC26067@arm.com>
References: <002001cf07a1$fd4bdc10$f7e39430$@lge.com> <535B1618.5030504@huawei.com> <20140429111946.GC26067@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Jianguo Wu <wujianguo@huawei.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Gioh Kim <gioh.kim@lge.com>, 'Baruch Siach' <baruch@tkos.co.il>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 'linux-arm-kernel' <linux-arm-kernel@lists.infradead.org>, 'HyoJun Im' <hyojun.im@lge.com>

On Tuesday 29 April 2014 12:19:46 Will Deacon wrote:
> On Sat, Apr 26, 2014 at 03:12:40AM +0100, Jianguo Wu wrote:
> > On 2014/1/3 8:47, Russell King - ARM Linux wrote:
> > > ARM can only branch relatively within +/- 32MB.  Hence, with a module
> > > space of 16MB, modules can reach up to a maximum 16MB into the direct-
> > > mapped kernel image.  As module space increases in size, so that figure
> > > decreases.  So, if module space were to be 40MB, the maximum size of the
> > > kernel binary would be 8MB.
> > > 
> > 
> > Hi Russell ,Arnd or Will,
> > 
> > I encountered the same situation in arm64, I loaded 80+ modules in arm64, and
> > run out of module address space(64M). Why the module space is restricted to 64M,
> > can it be expanded?  
> 
> The module space is restricted to 64M on AArch64 because the range of the BL
> instruction is += 128M. In order to call kernel functions, we need to ensure
> that this range is large enough and therefore place the modules 64M below the
> kernel text, allowing 64M for modules and 64M for the kernel text. We could
> probably improve this a bit by assuming a maximum size for the kernel text.
> 
> If we want to remove the problem altogether, we'd need to hack the module
> loader to insert trampolines (fiddly) or somehow persuade the tools to use
> indirect branches (BLR) for all calls (inefficient).

Well, there might also be a bug involved. Loading 80 modules should never
take up 64MB. The typical size of a loadable module should be a few dozen
kilobytes, although we have a few modules that are hundreds of kilobytes.

Jianguo Wu, can you send the defconfig you were using? Did you have
some debugging option enabled that increased the module size?

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
