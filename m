Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7386B038E
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 18:02:40 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l37so5289478wrc.7
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 15:02:40 -0700 (PDT)
From: Till Smejkal <till.smejkal@googlemail.com>
Date: Wed, 15 Mar 2017 15:02:34 -0700
Subject: Re: [RFC PATCH 00/13] Introduce first class virtual address spaces
Message-ID: <20170315220234.mooiyrzqdsglo4lp@arch-dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXfGgxaLivhci0VL=wUaWAnBiUXC47P7TUaEuOYV_-X_g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Till Smejkal <till.smejkal@googlemail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Richard Weinberger <richard@nod.at>, Cyrille Pitchen <cyrille.pitchen@atmel.com>, Felipe Balbi <balbi@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jeff Layton <jlayton@poochiereds.net>, "J. Bruce Fields" <bfields@fieldses.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-alpha@vger.kernel.org, arcml <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-metag@vger.kernel.org, Linux MIPS Mailing List <linux-mips@linux-mips.org>, linux-parisc@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, Linux Media Mailing List <linux-media@vger.kernel.org>, linux-mtd@lists.infradead.org, USB list <linux-usb@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-aio@kvack.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, ALSA development <alsa-devel@alsa-project.org>

On Wed, 15 Mar 2017, Andy Lutomirski wrote:
> On Wed, Mar 15, 2017 at 12:44 PM, Till Smejkal
> <till.smejkal@googlemail.com> wrote:
> > On Wed, 15 Mar 2017, Andy Lutomirski wrote:
> >> > One advantage of VAS segments is that they can be globally queried by user programs
> >> > which means that VAS segments can be shared by applications that not necessarily have
> >> > to be related. If I am not mistaken, MAP_SHARED of pure in memory data will only work
> >> > if the tasks that share the memory region are related (aka. have a common parent that
> >> > initialized the shared mapping). Otherwise, the shared mapping have to be backed by a
> >> > file.
> >>
> >> What's wrong with memfd_create()?
> >>
> >> > VAS segments on the other side allow sharing of pure in memory data by
> >> > arbitrary related tasks without the need of a file. This becomes especially
> >> > interesting if one combines VAS segments with non-volatile memory since one can keep
> >> > data structures in the NVM and still be able to share them between multiple tasks.
> >>
> >> What's wrong with regular mmap?
> >
> > I never wanted to say that there is something wrong with regular mmap. We just
> > figured that with VAS segments you could remove the need to mmap your shared data but
> > instead can keep everything purely in memory.
> 
> memfd does that.

Yes, that's right. Thanks for giving me the pointer to this. I should have researched
more carefully before starting to work at VAS segments.

> > VAS segments on the other side would provide a functionality to
> > achieve the same without the need of any mounted filesystem. However, I agree, that
> > this is just a small advantage compared to what can already be achieved with the
> > existing functionality provided by the Linux kernel.
> 
> I see this "small advantage" as "resource leak and security problem".

I don't agree here. VAS segments are basically in-memory files that are handled by
the kernel directly without using a file system. Hence, if an application uses a VAS
segment to store data the same rules apply as if it uses a file. Everything that it
saves in the VAS segment might be accessible by other applications. An application
using VAS segments should be aware of this fact. In addition, the resources that are
represented by a VAS segment are not leaked. As I said, VAS segments are much like
files. Hence, if you don't want to use them any more, delete them. But as with files,
the kernel will not delete them for you (although something like this can be added).

> >> This sounds complicated and fragile.  What happens if a heuristically
> >> shared region coincides with a region in the "first class address
> >> space" being selected?
> >
> > If such a conflict happens, the task cannot use the first class address space and the
> > corresponding system call will return an error. However, with the current available
> > virtual address space size that programs can use, such conflicts are probably rare.
> 
> A bug that hits 1% of the time is often worse than one that hits 100%
> of the time because debugging it is miserable.

I don't agree that this is a bug at all. If there is a conflict in the memory layout
of the ASes the application simply cannot use this first class virtual address space.
Every application that wants to use first class virtual address spaces should check
for error return values and handle them.

This situation is similar to mapping a file at some special address in memory because
the file contains pointer based data structures and the application wants to use
them, but the kernel cannot map the file at this particular position in the
application's AS because there is already a different conflicting mapping. If an
application wants to do such things, it should also handle all the errors that can
occur.

Till

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
