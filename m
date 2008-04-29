Date: Tue, 29 Apr 2008 17:58:40 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: 2.6.25-mm1: Failing to probe IDE interface
Message-ID: <20080429165840.GA24125@csn.ul.ie>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org> <20080428164235.GA29229@csn.ul.ie> <200804282044.34783.bzolnier@gmail.com> <20080429094327.GB4503@csn.ul.ie> <20080429154957.GA19148@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080429154957.GA19148@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, ink@jurassic.park.msu.ru
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, gregkh@suse.de
List-ID: <linux-mm.kvack.org>

On (29/04/08 16:49), Mel Gorman didst pronounce:
> On (29/04/08 10:43), Mel Gorman didst pronounce:
> > On (28/04/08 20:44), Bartlomiej Zolnierkiewicz didst pronounce:
> > > 
> > > Hi,
> > > 
> > > On Monday 28 April 2008, Mel Gorman wrote:
> > > > An old T21 is failing to boot and the relevant message appears to be
> > > > 
> > > > [    1.929536] Probing IDE interface ide0...
> > > > [   36.939317] ide0: Wait for ready failed before probe !
> > > > [   37.502676] ide0: DISABLED, NO IRQ
> > > > [   37.506356] ide0: failed to initialize IDE interface
> > > > 
> > > > The owner of ide-mm-ide-add-struct-ide_io_ports-take-2.patch with the
> > > > "DISABLED, NO IRQ" message is cc'd. I've attached the config, full boot log
> > > > and lspci -v for the machine in question. I'll start reverting some of the
> > > > these patches to see if ide-mm-ide-add-struct-ide_io_ports-take-2.patch
> > > > is really the culprit.
> > > 
> > > Please try reverting ide-fix-hwif-s-initialization.patch first - it has
> > > already been dropped from IDE tree because people were reporting problems
> > > similar to the one encountered by you.
> > > 
> > 
> > Thanks.
> > 
> > I reverted this patch and ide-mm-ide-make-ide_hwifs-static.patch (for compile
> > breakage reasons). It's better but still fails to find the IDE device.
> 
> Interestingly, bisection firmly blames this patch and QEMU boots with the two
> patches reverted but fails with them applied so that patch does cause problems.
> The failure on the laptop must be depending on some follow-on patch. I tried
> a hatchet-job revert of the IDE patches between IDE-START and IDE-END in
> the series file and it similarly fails to probe the IDE devices. So either
> I made a mess of the reverts (strong possibility) or there is more than one
> problem patch.
> 

The third patch that needed reverting was
gregkh-pci-pci-clean-up-resource-alignment-management.patch (owners added
to cc). The relevant hint in the a diff between a broken and working bootlog was;

 system 00:09: ioport range 0x15e0-0x15ef has been reserved
+ PCI: bogus alignment of resource 7 [100:1ff] (flags 100) of 0000:00:02.0
+ PCI: bogus alignment of resource 8 [100:1ff] (flags 100) of 0000:00:02.0
+ PCI: bogus alignment of resource 9 [4000000:7ffffff] (flags 1200) of 0000:00:02.0
+ PCI: bogus alignment of resource 10 [4000000:7ffffff] (flags 200) of 0000:00:02.0
+ PCI: bogus alignment of resource 7 [100:1ff] (flags 100) of 0000:00:02.1
+ PCI: bogus alignment of resource 8 [100:1ff] (flags 100) of 0000:00:02.1
+ PCI: bogus alignment of resource 9 [4000000:7ffffff] (flags 1200) of 0000:00:02.1
+ PCI: bogus alignment of resource 10 [4000000:7ffffff] (flags 200) of 0000:00:02.1

With the resource alignment patch and the two IDE patches reverted, the
laptop is able to boot.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
