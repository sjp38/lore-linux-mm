Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 80C366B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 05:37:33 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so58720605wia.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 02:37:32 -0700 (PDT)
Received: from andre.telenet-ops.be (andre.telenet-ops.be. [195.130.132.53])
        by mx.google.com with ESMTP id wt7si2163935wjc.159.2015.04.01.02.37.31
        for <linux-mm@kvack.org>;
        Wed, 01 Apr 2015 02:37:31 -0700 (PDT)
Date: Wed, 1 Apr 2015 11:37:13 +0200 (CEST)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] mm/migrate: Mark unmap_and_move() "noinline" to avoid ICE
 in gcc 4.7.3 (was: Re: Possible regression in  gcc 4.7.3 next-20150323 due
 to "ARM, arm64: kvm: get rid of the bounce page")
In-Reply-To: <7h8uec95t2.fsf@deeprootsystems.com>
Message-ID: <alpine.DEB.2.10.1504011130030.14762@ayla.of.borg>
References: <20150324004537.GA24816@verge.net.au> <CAKv+Gu-0jPk=KQ4gY32ELc+BVbe=1QdcrwQ+Pb=RkdwO9K3Vkw@mail.gmail.com> <20150324161358.GA694@kahuna> <20150326003939.GA25368@verge.net.au> <20150326133631.GB2805@arm.com> <CANMBJr68dsbYvvHUzy6U4m4fEM6nq8dVHBH4kLQ=0c4QNOhLPQ@mail.gmail.com>
 <20150327002554.GA5527@verge.net.au> <20150327100612.GB1562@arm.com> <7hbnj99epe.fsf@deeprootsystems.com> <CAKv+Gu_ZHZFm-1eXn+r7fkEHOxqSmj+Q+Mmy7k6LK531vSfAjQ@mail.gmail.com> <7h8uec95t2.fsf@deeprootsystems.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-7
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Hilman <khilman@kernel.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Simon Horman <horms@verge.net.au>, Tyler Baker <tyler.baker@linaro.org>, Nishanth Menon <nm@ti.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, Marc Zyngier <Marc.Zyngier@arm.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Magnus Damm <magnus.damm@gmail.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

	Hi Kevin,

On Tue, 31 Mar 2015, Kevin Hilman wrote:
> Ard Biesheuvel <ard.biesheuvel@linaro.org> writes:
> Nope, that branch is already part of linux-next, and linux-next still
> fails to compile for 20+ defconfigs[1]
> 
> > Could you elaborate on the issue please? What is the error you are
> > getting, and can you confirm that is is caused by ld choking on the
> > linker script? If not, this is another error than the one we have been
> > trying to fix
> 
> It's definitely not linker script related.
> 
> Using "arm-linux-gnueabi-gcc (Ubuntu/Linaro 4.7.3-12ubuntu1) 4.7.3",
> here's the error when building for multi_v7_defconfig (full log
> available[2]):
> 
> ../mm/migrate.c: In function 'migrate_pages':
> ../mm/migrate.c:1148:1: internal compiler error: in push_minipool_fix, at config/arm/arm.c:13101
> Please submit a full bug report,
> with preprocessed source if appropriate.
> See <file:///usr/share/doc/gcc-4.7/README.Bugs> for instructions.
> Preprocessed source stored into /tmp/ccO1Nz1m.out file, please attach
> this to your bugreport.
> make[2]: *** [mm/migrate.o] Error 1
> make[2]: Target `__build' not remade because of errors.
> make[1]: *** [mm] Error 2
> 
> build bisect points to commit 21f992084aeb[3], but that doesn't revert
> cleanly so I haven't got any further than that yet.

I installed gcc-arm-linux-gnueabi (4:4.7.2-1 from Ubuntu 14.04 LTS) and could
reproduce the ICE. I came up with the workaround below.
Does this work for you?
