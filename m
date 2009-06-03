Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 651846B00D6
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:26:52 -0400 (EDT)
Date: Wed, 3 Jun 2009 09:28:31 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
	ZERO_SIZE_PTR to point at unmapped space)
Message-ID: <20090603162831.GF6701@oblivion.subreption.com>
References: <20090530192829.GK6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain> <20090530230022.GO6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain> <20090531022158.GA9033@oblivion.subreption.com> <alpine.DEB.1.10.0906021130410.23962@gentwo.org> <20090602203405.GC6701@oblivion.subreption.com> <alpine.DEB.1.10.0906031047390.15621@gentwo.org> <1244041914.12272.64.camel@localhost.localdomain> <alpine.DEB.1.10.0906031134410.13551@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0906031134410.13551@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Stephen Smalley <sds@tycho.nsa.gov>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On 11:41 Wed 03 Jun     , Christoph Lameter wrote:
> On Wed, 3 Jun 2009, Stephen Smalley wrote:
> 
> > > If one remaps page 0 then the kernel checks for NULL pointers of various
> > > flavors are bypassed and this may be exploited in various creative ways
> > > to transfer data from kernel space to user space.
> > >
> > > Fix this by not allowing the remapping of page 0. Return -EINVAL if
> > > such a mapping is attempted.

Christopher, crippling the system is truly not the way to fix this.
There are many legitimate users of private|fixed mappings at 0. In
addition, if you want to go ahead and break POSIX, at least make sure
your patch closes the loophole.

Given these circumstances, are you proposing this over my patch?

Linus already pointed out the main (functional) problem about it. It
seems you are also confusing the issue, albeit already realized it can
be a venue of attack, which is good.

For instance, there are many scenarios in which a fixed mapping can be
used in a non-zero address to abuse kernel flaws... your patch is
useless against those.

Please let me remind you that my original intent was to prevent
kmalloc(0) from leading to potential NULL or offset-from-NULL access
issues, and not deterring NULL pointer deferences in kernel-land which
is a whole different thing (see PaX UDEREF for clues on this).

> >
> > You can already prevent unauthorized processes from mapping low memory
> > via the existing mmap_min_addr setting, configurable via
> > SECURITY_DEFAULT_MMAP_MIN_ADDR or /proc/sys/vm/mmap_min_addr.  Then
> > cap_file_mmap() or selinux_file_mmap() will apply a check when a process
> > attempts to map memory below that address.

If SELinux isn't present, that's not useful. If mmap_min_addr is
enabled, that still won't solve what my original, utterly simple patch
fixes.

The patch provides a no-impact, clean solution to prevent kmalloc(0)
situations from becoming a security hazard. Nothing else.

If you want to solve NULL/ptr deference abuse from userland, you better
start thinking about separating kernel virtual address space from
userland's, with the performance impact that implies. Few architectures
provide this capability without performance hit, and x86 ain't one of
them.

> mmap_min_addr depends on CONFIG_SECURITY which establishes various
> strangely complex "security models".
> 
> The system needs to be secure by default.

Correct, so what was wrong with my patch again? That the original two
line change was written by the PaX team?

Come on chap, It's not like you will lose your bragging rights among
your peers for admitting that I was right. Just this one time. I won't
tell anybody. Promise.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
