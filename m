Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9A36B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 04:10:29 -0400 (EDT)
Received: by wgqq4 with SMTP id q4so29589055wgq.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 01:10:28 -0700 (PDT)
Received: from pandora.arm.linux.org.uk ([2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id e7si23955124wiy.79.2015.07.01.01.10.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 01 Jul 2015 01:10:27 -0700 (PDT)
Date: Wed, 1 Jul 2015 09:09:15 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v5 2/6] arch: unify ioremap prototypes and macro aliases
Message-ID: <20150701080915.GJ7557@n2100.arm.linux.org.uk>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
 <20150622082427.35954.73529.stgit@dwillia2-desk3.jf.intel.com>
 <20150622161002.GB8240@lst.de>
 <CAPcyv4h5OXyRvZvLGD5ZknO-YUPn675YGv0XdtW1QOO9qmZsug@mail.gmail.com>
 <20150701062352.GA3739@lst.de>
 <CAMuHMdUO4uSWH1Qc0SfDTLuXbiG2N9fq8Tf6j+3RoqVKdPugbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdUO4uSWH1Qc0SfDTLuXbiG2N9fq8Tf6j+3RoqVKdPugbA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, Linux MM <linux-mm@kvack.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Michael Ellerman <mpe@ellerman.id.au>, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Jul 01, 2015 at 08:55:57AM +0200, Geert Uytterhoeven wrote:
> On Wed, Jul 1, 2015 at 8:23 AM, Christoph Hellwig <hch@lst.de> wrote:
> >> One useful feature of the ifdef mess as implemented in the patch is
> >> that you could test for whether ioremap_cache() is actually
> >> implemented or falls back to default ioremap().  I think for
> >> completeness archs should publish an ioremap type capabilities mask
> >> for drivers that care... (I can imagine pmem caring), or default to
> >> being permissive if something like IOREMAP_STRICT is not set.  There's
> >> also the wrinkle of archs that can only support certain types of
> >> mappings at a given alignment.
> >
> > I think doing this at runtime might be a better idea.  E.g. a
> > ioremap_flags with the CACHED argument will return -EOPNOTSUP unless
> > actually implemented.  On various architectures different CPUs or
> > boards will have different capabilities in this area.
> 
> So it would be the responsibility of the caller to fall back from
> ioremap(..., CACHED) to ioremap(..., UNCACHED)?
> I.e. all drivers using it should be changed...

Another important point here is to define what the properties of the
mappings are.  It's no good just saying "uncached".

We've recently been around this over the PMEM driver and the broken
addition of ioremap_wt() on ARM...

By "properties" I mean stuff like whether unaligned accesses permitted,
any kind of atomic access (eg, xchg, cmpxchg, etc).

This matters: on ARM, a mapping suitable for a device does not support
unaligned accesses or atomic accesses - only "memory-like" mappings
support those.  However, memory-like mappings are not required to
preserve access size, number of accesses, etc which makes them unsuitable
for device registers.

The problem with ioremap_uncached() in particular is that we have LDD
and other documentation telling people to use it to map device registers,
so we can't define ioremap_uncached() on ARM to have memory-like
properties, and it doesn't support unaligned accesses.

I have a series of patches which fix up 32-bit ARM for the broken
ioremap_wt() stuff that was merged during this merge window, which I
intend to push out into linux-next at some point (possibly during the
merge window, if not after -rc1) which also move ioremap*() out of line
on ARM but more importantly, adds a load of documentation about the
properties of the resulting mapping on ARM.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
