Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A66BC8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:14:12 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id c14so3972852pls.21
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:14:12 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o32si1715942pld.407.2019.01.16.07.14.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 07:14:11 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0GF9GTD085608
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:14:10 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q26gbsx7t-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:14:10 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 16 Jan 2019 15:14:07 -0000
Date: Wed, 16 Jan 2019 17:13:49 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 19/21] treewide: add checks for the return value of
 memblock_alloc*()
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
 <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
 <CAMuHMdWKPj-2Let44rmaVwh-b6kkGg+0cFPQ-+3k9LP86pB7NA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdWKPj-2Let44rmaVwh-b6kkGg+0cFPQ-+3k9LP86pB7NA@mail.gmail.com>
Message-Id: <20190116151348.GD6643@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS" <devicetree@vger.kernel.org>, kasan-dev@googlegroups.com, alpha <linux-alpha@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, linux-mips@vger.kernel.org, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, linux-um@lists.infradead.org, USB list <linux-usb@vger.kernel.org>, linux-xtensa@linux-xtensa.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Openrisc <openrisc@lists.librecores.org>, sparclinux <sparclinux@vger.kernel.org>, "moderated list:H8/300 ARCHITECTURE" <uclinux-h8-devel@lists.sourceforge.jp>, the arch/x86 maintainers <x86@kernel.org>, xen-devel@lists.xenproject.org

On Wed, Jan 16, 2019 at 03:27:35PM +0100, Geert Uytterhoeven wrote:
> Hi Mike,
> 
> On Wed, Jan 16, 2019 at 2:46 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> > Add check for the return value of memblock_alloc*() functions and call
> > panic() in case of error.
> > The panic message repeats the one used by panicing memblock allocators with
> > adjustment of parameters to include only relevant ones.
> >
> > The replacement was mostly automated with semantic patches like the one
> > below with manual massaging of format strings.
> >
> > @@
> > expression ptr, size, align;
> > @@
> > ptr = memblock_alloc(size, align);
> > + if (!ptr)
> > +       panic("%s: Failed to allocate %lu bytes align=0x%lx\n", __func__,
> 
> In general, you want to use %zu for size_t
> 
> > size, align);
> >
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> 
> Thanks for your patch!
> 
> >  74 files changed, 415 insertions(+), 29 deletions(-)
> 
> I'm wondering if this is really an improvement?

>From memblock perspective it's definitely an improvement :)

git diff --stat mmotm/master include/linux/memblock.h mm/memblock.c
 include/linux/memblock.h |  59 ++---------
 mm/memblock.c            | 249 ++++++++++++++++-------------------------------
 2 files changed, 90 insertions(+), 218 deletions(-)

> For the normal memory allocator, the trend is to remove printing of errors
> from all callers, as the core takes care of that.

It's more about allocation errors handling than printing of the errors.
Indeed, there is not much that can be done if an early allocation fails,
but I believe having an explicit pattern

	ptr = alloc();
	if (!ptr)
		do_something_about_it();

is clearer than relying on the allocator to panic().

Besides, the diversity of panic and nopanic variants creates a confusion
and I've caught several places that call nopanic variant and do not check
its return value.
 
> > --- a/arch/alpha/kernel/core_marvel.c
> > +++ b/arch/alpha/kernel/core_marvel.c
> > @@ -83,6 +83,9 @@ mk_resource_name(int pe, int port, char *str)
> >
> >         sprintf(tmp, "PCI %s PE %d PORT %d", str, pe, port);
> >         name = memblock_alloc(strlen(tmp) + 1, SMP_CACHE_BYTES);
> > +       if (!name)
> > +               panic("%s: Failed to allocate %lu bytes\n", __func__,
> 
> %zu, as strlen() returns size_t.

Thanks for spotting it, will fix.

> > +                     strlen(tmp) + 1);
> >         strcpy(name, tmp);
> >
> >         return name;
> > @@ -118,6 +121,9 @@ alloc_io7(unsigned int pe)
> >         }
> >
> >         io7 = memblock_alloc(sizeof(*io7), SMP_CACHE_BYTES);
> > +       if (!io7)
> > +               panic("%s: Failed to allocate %lu bytes\n", __func__,
> 
> %zu, as sizeof() returns size_t.
> Probably there are more. Yes, it's hard to get them right in all callers.

Yeah :)
 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> -- 
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds
> 

-- 
Sincerely yours,
Mike.
