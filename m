Date: Tue, 29 Jul 2008 14:53:12 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] reserved-ram for pci-passthrough without VT-d capable
	hardware
Message-ID: <20080729125312.GL11494@duo.random>
References: <1214232737-21267-1-git-send-email-benami@il.ibm.com> <1214232737-21267-2-git-send-email-benami@il.ibm.com> <20080625005739.GM6938@duo.random> <20080625011808.GN6938@duo.random> <20080729121125.GK11494@duo.random> <20080729124317.GK30344@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080729124317.GK30344@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: benami@il.ibm.com, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, amit.shah@qumranet.com, kvm@vger.kernel.org, aliguori@us.ibm.com, allen.m.kay@intel.com, muli@il.ibm.com, linux-mm@kvack.org, tglx@linutronix.de, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Tue, Jul 29, 2008 at 02:43:17PM +0200, Andi Kleen wrote:
> > This is a port to current linux-2.6.git of the previous reserved-ram
> > patch. Let me know if there's a chance to get this acked and
> > included. Anything that isn't at compile time would require much
> 
> I still think runtime would be far better. Nobody really wants
> a proliferation of more weird special kernel images.

Not for the usage we're interested about but surely this would prevent
distro to take advantage of the feature. The question is if distro
need to take advantage of the feature in the first place instead of
sticking with VT-d. 1:1 isn't secure virtualization as the guest must
be trusted so it's not necessarily a good model to deploy to users
that don't know exactly what they're doing.

> > bigger changes just to parse the command line at 16bit realmode time
> 
> You could always do it with kexec if you think 16bit real mode is
> too hard.

It's not too hard, but it'll add bloat to the 16 bit part of the boot
in the bzImage. It's likely simpler than kexec and surely more
user-friendly to setup for the end user.

In any case, my patch does the needed bits with regard to the e820
map. An incremental patch can add the parsing of the booatloader and
switch the Kconfig dependency from PHYSICAL_START to RELOCATABLE. The
e820 file will then have to replace the __PHYSICAL_START define with
something else and that's all.

I mean it's not entirely backwards to provide a compile time smaller
and simpler approach initially, and then to go where you want to go
incrementally later if we're sure there's enough userbase needing 1:1.

I'm not so interested to go there right now, because while this code
is useful right now because the majority of systems out there lacks
VT-d/iommu, I suspect this code could be nuked in the long
run when all systems will ship with that, which is why I kept it all
under #ifdef, and the changes to the other files outside ifdef are
bugfixes needed if you want to kexec-relocate above 40m or so that
should be kept.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
