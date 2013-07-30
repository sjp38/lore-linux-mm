Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 7A5666B0037
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 10:32:48 -0400 (EDT)
Date: Tue, 30 Jul 2013 16:32:37 +0200
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v2 1/2] uio: provide vm access to UIO_MEM_PHYS maps
Message-ID: <20130730143237.GU1754@pengutronix.de>
References: <20130727214911.GK1754@pengutronix.de>
 <1374962978-1860-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <20130729200914.GA6146@kroah.com>
 <20130730075239.GN1754@pengutronix.de>
 <20130730134950.GA27962@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20130730134950.GA27962@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Hans J. Koch" <hjk@hansjkoch.de>, linux-kernel@vger.kernel.org, kernel@pengutronix.de, linux-mm@kvack.org

Hello Greg,

On Tue, Jul 30, 2013 at 06:49:50AM -0700, Greg Kroah-Hartman wrote:
> On Tue, Jul 30, 2013 at 09:52:39AM +0200, Uwe Kleine-Konig wrote:
> > [expanding Cc: to also include akpm and linux-mm]
> > 
> > Hello,
> > 
> > On Mon, Jul 29, 2013 at 01:09:14PM -0700, Greg Kroah-Hartman wrote:
> > > On Sun, Jul 28, 2013 at 12:09:37AM +0200, Uwe Kleine-Konig wrote:
> > > > This makes it possible to let gdb access mappings of the process that is
> > > > being debugged.
> > > > 
> > > > uio_mmap_logical was moved and uio_vm_ops renamed to group related code
> > > > and differentiate to new stuff.
> > > > 
> > > > Signed-off-by: Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>
> > > > ---
> > > > Changes since v1:
> > > >     - only use generic_access_phys ifdef CONFIG_HAVE_IOREMAP_PROT
> > > >     - fix all users of renamed struct
> > > 
> > > I still get a build error with this patch:
> > > 
> > >   MODPOST 384 modules
> > > ERROR: "generic_access_phys" [drivers/uio/uio.ko] undefined!
> > > 
> > > So something isn't quite right.
> > Ah, you built as a module and generic_access_phys isn't exported. The
> > other users of generic_access_phys (arch/x86/pci/i386.c and
> > drivers/char/mem.c) can only be builtin.
> > 
> > So the IMHO best option is to add an EXPORT_SYMBOL(generic_access_phys)
> > to mm/memory.c.
> 
> EXPORT_SYMBOL_GPL() perhaps?
Yeah, that would work just fine, too. Who takes care for mm/memory.c,
Andrew? Should I send a separate patch or is it ok to do it in the patch
making use of it and let it go in via Greg?
 
> And why all of a sudden does the uio driver need this change?  It is
> working just fine right now without it, right?
Yeah it works. But if you gdb your userspace driver, gdb cannot access
the mappings without my patch.

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-Konig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
