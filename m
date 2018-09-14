Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id D44948E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 14:51:08 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id l45-v6so11453494wre.4
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 11:51:08 -0700 (PDT)
Received: from smtp1.de.adit-jv.com (smtp1.de.adit-jv.com. [62.225.105.245])
        by mx.google.com with ESMTPS id r8-v6si226093wmf.166.2018.09.14.11.51.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 11:51:06 -0700 (PDT)
Date: Fri, 14 Sep 2018 20:50:51 +0200
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: Re: [PATCH v11 0/3] remain and optimize memblock_next_valid_pfn on
 arm and arm64
Message-ID: <20180914185051.GA22530@vmlxhi-102.adit-jv.com>
References: <1534907237-2982-1-git-send-email-jia.he@hxt-semitech.com>
 <CAKv+Gu9u8RcrzSHdgXiqHS9HK1aSrjbPxVUSCP0DT4erAhx0pw@mail.gmail.com>
 <20180907144447.GD12788@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180907144447.GD12788@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jia He <jia.he@hxt-semitech.com>, "George G. Davis" <george_davis@mentor.com>, Vladimir Zapolskiy <vladimir_zapolskiy@mentor.com>, Andy Lowe <andy_lowe@mentor.com>, linux-renesas-soc@vger.kernel.org, Eugeniu Rosca <roscaeugeniu@gmail.com>, Eugeniu Rosca <erosca@de.adit-jv.com>

+ Renesas people

Hello Will, hello Ard, 

On Fri, Sep 07, 2018 at 03:44:47PM +0100, Will Deacon wrote:
> On Thu, Sep 06, 2018 at 01:24:22PM +0200, Ard Biesheuvel wrote:
> > OK so we can summarize the benefits of this series as follows:
> > - boot time on a virtual model of a Samurai CPU drops from 109 to 62 seconds
> > - boot time on a QDF2400 arm64 server with 96 GB of RAM drops by ~15
> > *milliseconds*
> > 
> > Google was not very helpful in figuring out what a Samurai CPU is and
> > why we should care about the boot time of Linux running on a virtual
> > model of it, and the 15 ms speedup is not that compelling either.
> > 
> > Apologies to Jia that it took 11 revisions to reach this conclusion,
> > but in /my/ opinion, tweaking the fragile memblock/pfn handling code
> > for this reason is totally unjustified, and we're better off
> > disregarding these patches.
> 
> Oh, we're talking about a *simulator* for the significant boot time
> improvement here? I didn't realise that, so I agree that the premise of
> this patch set looks pretty questionable given how much "fun" we've had
> with the memmap on arm and arm64.
> 
> Will

Similar to https://lkml.org/lkml/2018/1/24/420, my measurements show that
the boot time of R-Car H3-ES2.0 Salvator-X (having 4GiB RAM) is decreased
by ~135-140ms with this patch-set applied on top of v4.19-rc3.

I agree that in the Desktop realm you would barely perceive the 140ms
difference, but saving 140ms on the automotive SoC (designed for products
which must comply with 2s-to-rear-view-camera NHTSA US regulations) *is*
significant.

FWIW, cppcheck and `checkpatch --strict` report style issues for
patches #2 and #3. I hope these can be fixed and the review process
can go on? From functional standpoint, I did some dynamic testing on
H3-Salvator-X with UBSAN/KASAN=y and didn't observe any regressions, so:

Tested-by: Eugeniu Rosca <erosca@de.adit-jv.com>

Best regards,
Eugeniu.
