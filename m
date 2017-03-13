Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3336B038A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:45:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g8so16007768wmg.7
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:45:42 -0700 (PDT)
From: Till Smejkal <till.smejkal@googlemail.com>
Date: Mon, 13 Mar 2017 15:45:36 -0700
Subject: Re: [RFC PATCH 11/13] mm/vas: Introduce VAS segments - shareable
 address space regions
Message-ID: <20170313224536.saqdijtdayxwmlpz@arch-dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170313222758.GB4033@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Till Smejkal <till.smejkal@googlemail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andy Lutomirski <luto@amacapital.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Richard Weinberger <richard@nod.at>, Cyrille Pitchen <cyrille.pitchen@atmel.com>, Felipe Balbi <balbi@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jeff Layton <jlayton@poochiereds.net>, "J. Bruce Fields" <bfields@fieldses.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-media@vger.kernel.org, linux-mtd@lists.infradead.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, alsa-devel@alsa-project.org

Hi Matthew,

On Mon, 13 Mar 2017, Matthew Wilcox wrote:
> On Mon, Mar 13, 2017 at 03:14:13PM -0700, Till Smejkal wrote:
> > +/**
> > + * Create a new VAS segment.
> > + *
> > + * @param[in] name:		The name of the new VAS segment.
> > + * @param[in] start:		The address where the VAS segment begins.
> > + * @param[in] end:		The address where the VAS segment ends.
> > + * @param[in] mode:		The access rights for the VAS segment.
> > + *
> > + * @returns:			The VAS segment ID on success, -ERRNO otherwise.
> > + **/
> 
> Please follow the kernel-doc conventions, as described in
> Documentation/doc-guide/kernel-doc.rst.  Also, function documentation
> goes with the implementation, not the declaration.

Thank you for this pointer. I wasn't aware of this convention. I will change the
patches accordingly.

> > +/**
> > + * Get ID of the VAS segment belonging to a given name.
> > + *
> > + * @param[in] name:		The name of the VAS segment for which the ID
> > + *				should be returned.
> > + *
> > + * @returns:			The VAS segment ID on success, -ERRNO
> > + *				otherwise.
> > + **/
> > +extern int vas_seg_find(const char *name);
> 
> So ... segments have names, and IDs ... and access permissions ...
> Why isn't this a special purpose filesystem?

We also thought about this. However, we decided against implementing them as a
special purpose filesystem, mainly because we could not think of a good way to
represent a VAS/VAS segment in this file system (should they be represented rather as
file or directory) and we weren't sure what a hierarchy in the filesystem would mean
for the underlying address spaces. Hence we decided against it and rather used a
combination of IDR and sysfs. However, I don't have any strong feelings and would
also reimplement them as a special purpose filesystem if people rather like them to
be one.

Till

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
