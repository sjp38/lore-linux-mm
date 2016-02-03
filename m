Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0CADB6B025A
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 15:43:02 -0500 (EST)
Received: by mail-lb0-f171.google.com with SMTP id bc4so19334412lbc.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 12:43:01 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id r15si5166515lfr.132.2016.02.03.12.43.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 12:43:00 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [RFC] ARM: modify pgd_t definition for TRANSPARENT_HUGEPAGE_PUD
Date: Wed, 03 Feb 2016 21:36:38 +0100
Message-ID: <15001627.5KATBhJaXU@wuerfel>
In-Reply-To: <20160203163946.GA20360@ravnborg.org>
References: <1773775.QWf7OyDGPh@wuerfel> <20160203163946.GA20360@ravnborg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Sam Ravnborg <sam@ravnborg.org>, linux-arch@vger.kernel.org, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org, Russell King <rmk@arm.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wednesday 03 February 2016 17:39:46 Sam Ravnborg wrote:
> On Wed, Feb 03, 2016 at 02:21:48PM +0100, Arnd Bergmann wrote:
> > arch/alpha/include/asm/page.h
> > arch/arc/include/asm/page.h
> > arch/arm/include/asm/pgtable-3level-types.h
> > arch/arm64/include/asm/pgtable-types.h
> > arch/ia64/include/asm/page.h
> > arch/parisc/include/asm/page.h
> > arch/powerpc/include/asm/page.h
> > arch/sparc/include/asm/page_32.h
> > arch/sparc/include/asm/page_64.h
> 
> For the sparc32 case we use the simpler variants.
> According to the comment this is due to limitation in
> the way we pass arguments in the sparc32 ABI.
> But I have not tried to compare a kernel for sparc32 with
> and without the use of structs.
> 
> For sparc64 we use the stricter types (structs).
> I did not check other architectures - but just wanted to
> tell that the right choice may be architecture dependent.
> 

I see. I was assuming that they all (wrongly) default to the simple
definitions.

It seems we have these categories:

* both defined, but using strict:
arch/alpha/include/asm/page.h:#define STRICT_MM_TYPECHECKS
arch/sparc/include/asm/page_64.h:#define STRICT_MM_TYPECHECKS
arch/ia64/include/asm/page.h:#  define STRICT_MM_TYPECHECKS
arch/parisc/include/asm/page.h:#define STRICT_MM_TYPECHECKS

* both defined, but using non-strict:
arch/arc/include/asm/page.h:#undef STRICT_MM_TYPECHECKS
arch/arm/include/asm/pgtable-2level-types.h:#undef STRICT_MM_TYPECHECKS
arch/arm/include/asm/pgtable-3level-types.h:#undef STRICT_MM_TYPECHECKS
arch/arm64/include/asm/pgtable-types.h:#undef STRICT_MM_TYPECHECKS
arch/sparc/include/asm/page_32.h:/* #define STRICT_MM_TYPECHECKS */
arch/unicore32/include/asm/page.h:#undef STRICT_MM_TYPECHECKS

* Kconfig option:
arch/powerpc/Kconfig.debug:config STRICT_MM_TYPECHECKS
			 	default n

* only strict defined:
everything else


	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
