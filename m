Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8DD6B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 11:24:15 -0500 (EST)
Received: by igbhn18 with SMTP id hn18so38071687igb.2
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 08:24:15 -0800 (PST)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id o8si15623468igw.7.2015.03.04.08.24.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 08:24:14 -0800 (PST)
Message-ID: <1425486216.17007.236.camel@misato.fc.hp.com>
Subject: Re: [PATCH v3 6/6] x86, mm: Support huge KVA mappings on x86
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 04 Mar 2015 09:23:36 -0700
In-Reply-To: <20150303170035.85e94c87.akpm@linux-foundation.org>
References: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
	 <1425404664-19675-7-git-send-email-toshi.kani@hp.com>
	 <20150303144414.9f97ef25ad8aed7d112896bf@linux-foundation.org>
	 <1425424472.17007.191.camel@misato.fc.hp.com>
	 <20150303170035.85e94c87.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "hpa@zytor.com" <hpa@zytor.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "Elliott, Robert (Server Storage)" <Elliott@hp.com>

On Wed, 2015-03-04 at 01:00 +0000, Andrew Morton wrote:
> On Tue, 03 Mar 2015 16:14:32 -0700 Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > On Tue, 2015-03-03 at 14:44 -0800, Andrew Morton wrote:
> > > On Tue,  3 Mar 2015 10:44:24 -0700 Toshi Kani <toshi.kani@hp.com> wrote:
> >  :
> > > > +
> > > > +#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
> > > > +int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
> > > > +{
> > > > +	u8 mtrr;
> > > > +
> > > > +	/*
> > > > +	 * Do not use a huge page when the range is covered by non-WB type
> > > > +	 * of MTRRs.
> > > > +	 */
> > > > +	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE);
> > > > +	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
> > > > +		return 0;
> > > 
> > > It would be good to notify the operator in some way when this happens. 
> > > Otherwise the kernel will run more slowly and there's no way of knowing
> > > why.  I guess slap a pr_info() in there.  Or maybe pr_warn()?
> > 
> > We only use 4KB mappings today, so this case will not make it run
> > slowly, i.e. it will be the same as today.
> 
> Yes, but it would be slower than it would be if the operator fixed the
> mtrr settings!  How do we let the operator know this?
> 
> >  Also, adding a message here
> > can generate a lot of messages when MTRRs cover a large area.
> 
> Really?  This is only going to happen when a device driver requests a
> huge io mapping, isn't it?  That's rare.  We could emit a warning,
> return an error code and fall all the way back to the top-level ioremap
> code which can then retry with 4k mappings.  Or something similar -
> somehow record the fact that this warning has been emitted or use
> printk ratelimiting (bad option).

Yes, an IO device with a huge MMIO space that is covered by MTRRs is a
rare case.  BIOS does not need to specify how MMIO of each card needs to
be accessed with MTRRs (or BIOS should not do it since an MMIO address
is configurable on each card).

However, PCIe has the MMCONFIG space, PCIe config space, which is also
memory mapped and must be accessed with UC.  The PCI subsystem calls
ioremap_nocache() to map the entire MMCONFIG space, which covers the
PCIe config space of all possible cards.  Here are boot messages on my
test system.

  :
PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xc0000000-0xcf
ffffff] (base 0xc0000000)
PCI: MMCONFIG at [mem 0xc0000000-0xcfffffff] reserved in E820
  :

And MTRRs cover this MMCONFIG space with UC to assure that the range is
always accessed with UC.

# cat /proc/mtrr
reg00: base=0x0c0000000 ( 3072MB), size= 1024MB, count=1: uncachable

So, if we add a message into the code, it will be displayed many times
in this ioremap_nocache() call from PCI.

Ideally, pud_set_huge() and pmd_set_huge() should allow using a huge
page mapping when the entire map range is covered by a single MTRR
entry, which is the case with MMCONFIG.  But I did not include such
handling into the patch because UC map is slow by itself, MMCONFIG is
only accessed at boot-time, and mtrr_type_lookup() does not provide the
level of info necessary.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
