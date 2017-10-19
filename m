Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D6AA86B0069
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:03:08 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l10so3457474wmg.5
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:03:08 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id y68si6598710wrc.333.2017.10.19.05.03.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 05:03:07 -0700 (PDT)
Date: Thu, 19 Oct 2017 13:01:37 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
Message-ID: <20171019120137.GT20805@n2100.armlinux.org.uk>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-2-liuwenliang@huawei.com>
 <31b16c9d-48c7-bc0a-51d1-cc6cf892329b@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <31b16c9d-48c7-bc0a-51d1-cc6cf892329b@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Osipenko <digetx@gmail.com>
Cc: Abbott Liu <liuwenliang@huawei.com>, aryabinin@virtuozzo.com, afzal.mohd.ma@gmail.com, f.fainelli@gmail.com, labbott@redhat.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, cdall@linaro.org, marc.zyngier@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mawilcox@microsoft.com, tglx@linutronix.de, thgarnie@google.com, keescook@chromium.org, arnd@arndb.de, vladimir.murzin@arm.com, tixy@linaro.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, mingo@kernel.org, grygorii.strashko@linaro.org, glider@google.com, dvyukov@google.com, opendmb@gmail.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, jiazhenghua@huawei.com, dylix.dailei@huawei.com, zengweilin@huawei.com, heshaoliang@huawei.com

On Thu, Oct 12, 2017 at 02:42:49AM +0300, Dmitry Osipenko wrote:
> On 11.10.2017 11:22, Abbott Liu wrote:
> > +void __init kasan_map_early_shadow(pgd_t *pgdp)
> > +{
> > +	int i;
> > +	unsigned long start = KASAN_SHADOW_START;
> > +	unsigned long end = KASAN_SHADOW_END;
> > +	unsigned long addr;
> > +	unsigned long next;
> > +	pgd_t *pgd;
> > +
> > +	for (i = 0; i < PTRS_PER_PTE; i++)
> > +		set_pte_at(&init_mm, KASAN_SHADOW_START + i*PAGE_SIZE,
> > +			&kasan_zero_pte[i], pfn_pte(
> > +				virt_to_pfn(kasan_zero_page),
> > +				__pgprot(_L_PTE_DEFAULT | L_PTE_DIRTY | L_PTE_XN)));
> 
> Shouldn't all __pgprot's contain L_PTE_MT_WRITETHROUGH ?

One of the architecture restrictions is that the cache attributes of
all aliases should match (but there is a specific workaround that
permits this, provided that the dis-similar mappings aren't accessed
without certain intervening instructions.)

Why should it be L_PTE_MT_WRITETHROUGH, and not the same cache
attributes as the lowmem mapping?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
