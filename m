Received: by fg-out-1718.google.com with SMTP id d23so46559fga.7
        for <linux-mm@kvack.org>; Tue, 29 Apr 2008 14:21:56 -0700 (PDT)
From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: 2.6.25-mm1: Failing to probe IDE interface
Date: Tue, 29 Apr 2008 23:37:57 +0200
References: <20080417160331.b4729f0c.akpm@linux-foundation.org> <20080429154957.GA19148@csn.ul.ie> <20080429165840.GA24125@csn.ul.ie>
In-Reply-To: <20080429165840.GA24125@csn.ul.ie>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200804292337.57874.bzolnier@gmail.com>
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: ink@jurassic.park.msu.ru, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, gregkh@suse.de
List-ID: <linux-mm.kvack.org>

On Tuesday 29 April 2008, Mel Gorman wrote:
> On (29/04/08 16:49), Mel Gorman didst pronounce:
> > On (29/04/08 10:43), Mel Gorman didst pronounce:
> > > On (28/04/08 20:44), Bartlomiej Zolnierkiewicz didst pronounce:
> > > > 
> > > > Hi,
> > > > 
> > > > On Monday 28 April 2008, Mel Gorman wrote:
> > > > > An old T21 is failing to boot and the relevant message appears to be
> > > > > 
> > > > > [    1.929536] Probing IDE interface ide0...
> > > > > [   36.939317] ide0: Wait for ready failed before probe !
> > > > > [   37.502676] ide0: DISABLED, NO IRQ
> > > > > [   37.506356] ide0: failed to initialize IDE interface
> > > > > 
> > > > > The owner of ide-mm-ide-add-struct-ide_io_ports-take-2.patch with the
> > > > > "DISABLED, NO IRQ" message is cc'd. I've attached the config, full boot log
> > > > > and lspci -v for the machine in question. I'll start reverting some of the
> > > > > these patches to see if ide-mm-ide-add-struct-ide_io_ports-take-2.patch
> > > > > is really the culprit.
> > > > 
> > > > Please try reverting ide-fix-hwif-s-initialization.patch first - it has
> > > > already been dropped from IDE tree because people were reporting problems
> > > > similar to the one encountered by you.
> > > > 
> > > 
> > > Thanks.
> > > 
> > > I reverted this patch and ide-mm-ide-make-ide_hwifs-static.patch (for compile
> > > breakage reasons). It's better but still fails to find the IDE device.
> > 
> > Interestingly, bisection firmly blames this patch and QEMU boots with the two
> > patches reverted but fails with them applied so that patch does cause problems.
> > The failure on the laptop must be depending on some follow-on patch. I tried
> > a hatchet-job revert of the IDE patches between IDE-START and IDE-END in
> > the series file and it similarly fails to probe the IDE devices. So either
> > I made a mess of the reverts (strong possibility) or there is more than one
> > problem patch.
> > 
> 
> The third patch that needed reverting was
> gregkh-pci-pci-clean-up-resource-alignment-management.patch (owners added
> to cc). The relevant hint in the a diff between a broken and working bootlog was;
> 
>  system 00:09: ioport range 0x15e0-0x15ef has been reserved
> + PCI: bogus alignment of resource 7 [100:1ff] (flags 100) of 0000:00:02.0
> + PCI: bogus alignment of resource 8 [100:1ff] (flags 100) of 0000:00:02.0
> + PCI: bogus alignment of resource 9 [4000000:7ffffff] (flags 1200) of 0000:00:02.0
> + PCI: bogus alignment of resource 10 [4000000:7ffffff] (flags 200) of 0000:00:02.0
> + PCI: bogus alignment of resource 7 [100:1ff] (flags 100) of 0000:00:02.1
> + PCI: bogus alignment of resource 8 [100:1ff] (flags 100) of 0000:00:02.1
> + PCI: bogus alignment of resource 9 [4000000:7ffffff] (flags 1200) of 0000:00:02.1
> + PCI: bogus alignment of resource 10 [4000000:7ffffff] (flags 200) of 0000:00:02.1
> 
> With the resource alignment patch and the two IDE patches reverted, the
> laptop is able to boot.

Thanks for tracking it down.

Hmm, it seems that the above patch was merged a week ago:

commit bda0c0afa7a694bb1459fd023515aca681e4d79a
Merge: 904e0ab... af40b48...
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Mon Apr 21 15:58:35 2008 -0700

    Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/pci-2.6
...
      PCI: clean up resource alignment management
...

but it could be that the issue has been already fixed in git tree
(could you verify it please?).

BTW according to lspci output you should be able to use piix driver
instead of ide_generic on this laptop.

Thanks,
Bart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
