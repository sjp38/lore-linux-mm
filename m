Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 77B756B025A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 06:14:52 -0400 (EDT)
Received: by wiga1 with SMTP id a1so252106276wig.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 03:14:51 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id m8si35293464wje.41.2015.07.07.03.14.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jul 2015 03:14:48 -0700 (PDT)
Date: Tue, 7 Jul 2015 11:13:30 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v5 2/6] arch: unify ioremap prototypes and macro aliases
Message-ID: <20150707101330.GJ7557@n2100.arm.linux.org.uk>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
 <20150622082427.35954.73529.stgit@dwillia2-desk3.jf.intel.com>
 <20150622161002.GB8240@lst.de>
 <CAPcyv4h5OXyRvZvLGD5ZknO-YUPn675YGv0XdtW1QOO9qmZsug@mail.gmail.com>
 <20150701062352.GA3739@lst.de>
 <CAMuHMdUO4uSWH1Qc0SfDTLuXbiG2N9fq8Tf6j+3RoqVKdPugbA@mail.gmail.com>
 <20150701065948.GA4355@lst.de>
 <CAMuHMdXqjmo2T3V=msZySVSu2j4YjyE7FnVXWTjySEyfYLSg1A@mail.gmail.com>
 <20150701072828.GA4881@lst.de>
 <20150707095012.GQ7021@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150707095012.GQ7021@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Cc: Christoph Hellwig <hch@lst.de>, Andy Lutomirski <luto@amacapital.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Julia Lawall <julia.lawall@lip6.fr>, Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Linux MM <linux-mm@kvack.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Michael Ellerman <mpe@ellerman.id.au>, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, mcgrof@do-not-panic.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, Jul 07, 2015 at 11:50:12AM +0200, Luis R. Rodriguez wrote:
> mcgrof@ergon ~/linux-next (git::kill-mtrr)$ git grep ioremap_nocache drivers/| wc -l
> 359

Yes, it's because we have:
(a) LDD telling people they should be using ioremap_nocache() for mapping
    devices.
(b) We have documentation in the Documentation/ subdirectory telling people
    to use ioremap_nocache() for the same.

> This is part of the work I've been doing lately. The
> eventual goal once we have the write-combing areas properly split with
> ioremap_wc() and using the new proper preferred architecture agnostic modifier
> (arch_phys_wc_add()) is to change the default ioremap behaviour on x86 to use
> strong UC for PAT enabled systems for *both* ioremap() and ioremap_nocache().

Please note that on ARM, ioremap_wc() gives what's termed in ARM ARM
speak "normal memory, non-cacheable" - which can be subject to speculation,
write combining, multiple accesses, etc.  The important point is that
such mapping is not suitable for device registers, but is suitable for
device regions that have "memory like" properties (iow, a chunk of RAM,
like video drivers.)  It does support unaligned accesses.

> Because of these grammatical issues and the issues with
> unaligned access with ARM I think its important we put some effort
> to care a bit more about defining clear semantics through grammar
> for new APIs or as we rewrite APIs. We have tools to do this these
> days, best make use of them.

I'm in support of anything which more clearly specifies the requirements
for these APIs.

> While we're at it and reconsidering all this, a few items I wish for
> us to address as well then, most of them related to grammar, some
> procedural clarification:
> 
>   * Document it as not supported to have overlapping ioremap() calls.
>     No one seems to have a clue if this should work, but clearly this
>     is just a bad idea. I don't see why we should support the complexity
>     of having this. It seems we can write grammar rules to prevent this.

On ARM, we (probably) have a lot of cases where ioremap() is used multiple
times for the same physical address space, so we shouldn't rule out having
multiple mappings of the same type.  However, differing types would be a
problem on ARM.

>   * We seem to care about device drivers / kernel code doing unaligned
>     accesses with certain ioremap() variants. At least for ARM you should
>     not do unaligned accesses on ioremap_nocache() areas.

... and ioremap() areas.

If we can stop the "abuse" of ioremap_nocache() to map device registers,
then we could potentially switch ioremap_nocache() to be a normal-memory
like mapping, which would allow it to support unaligned accesses.

>     I am not sure
>     if we can come up with grammar to vet for / warn for unaligned access
>     type of code in driver code on some memory area when some ioremap()
>     variant is used, but this could be looked into. I believe we may
>     want rules for unaligned access maybe in general, and not attached
>     to certain calls due to performance considerations, so this work
>     may be welcomed regardless (refer to
>     Documentation/unaligned-memory-access.txt)
>     
>   * We seem to want to be pedantic about adding new ioremap() variants, the
>     unaligned issue on ARM is one reason, do we ideally then want *all*
>     architecture maintainers to provide an Acked-by for any new ioremap
>     variants ?

/If/ we get the current mess sorted out so that we have a safe fallback,
and we have understanding of the different architecture variants (iow,
documented what the safe fallback is) I don't see any reason why we'd
need acks from arch maintainers.  Unfortunately, we're not in that
situation today, because of the poorly documented mess that ioremap*()
currently is (and yes, I'm partly to blame for that too by not documenting
ARMs behaviour here.)

I have some patches (prepared last week, I was going to push them out
towards the end of the merge window) which address that, but unfortunately
the ARM autobuilders have been giving a number of seemingly random boot
failures, and I'm not yet sure what's going on... so I'm holding that
back until stuff has settled down.

Another issue is... the use of memcpy()/memset() directly on memory
returned from ioremap*().  The pmem driver does this.  This fails sparse
checks.  However, years ago, x86 invented the memcpy_fromio()/memcpy_toio()
memset_io() functions, which took a __iomem pointer (which /presumably/
means they're supposed to operate on the memory associated with an
ioremap'd region.)

Should these functions always be used for mappings via ioremap*(), and
the standard memcpy()/memset() be avoided?  To me, that sounds like a
very good thing, because that gives us more control over the
implementation of the functions used to access ioremap'd regions,
and the arch can decide to prevent GCC inlining its own memset() or
memcpy() code if desired.

Note that on x86, these three functions are merely wrappers around
standard memcpy()/memset(), so there should be no reason why pmem.c
couldn't be updated to use these accessors instead.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
