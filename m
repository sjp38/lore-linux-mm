Date: Sun, 26 Aug 2007 10:30:41 +0200 (CEST)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] Prefix each line of multiline printk(KERN_<level>
 "foo\nbar") with KERN_<level>
In-Reply-To: <1187999098.32738.179.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708261028120.31149@anakin>
References: <1187999098.32738.179.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, blinux-list@redhat.com, cluster-devel@redhat.com, discuss@x86-64.org, jffs-dev@axis.com, linux-acpi@vger.kernel.org, linux-ide@vger.kernel.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-scsi@vger.kernel.org, mpt_linux_developer@lsi.com, netdev@vger.kernel.org, osst-users@lists.sourceforge.net, parisc-linux@parisc-linux.org, tpmdd-devel@lists.sourceforge.net, uclinux-dist-devel@blackfin.uclinux.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Aug 2007, Joe Perches wrote:
> Corrected printk calls with multiple output lines which
> did not correctly preface each line with KERN_<level>
> 
> Fixed uses of some single lines with too many KERN_<level>

> --- a/arch/arm/kernel/ecard.c
> +++ b/arch/arm/kernel/ecard.c
> @@ -547,7 +547,8 @@ static void ecard_check_lockup(struct irq_desc *desc)
>  	if (last == jiffies) {
>  		lockup += 1;
>  		if (lockup > 1000000) {
> -			printk(KERN_ERR "\nInterrupt lockup detected - "
> +			printk(KERN_ERR "\n"
> +			       KERN_ERR "Interrupt lockup detected - "
>  			       "disabling all expansion card interrupts\n");
>  
>  			desc->chip->mask(IRQ_EXPANSIONCARD);

What's the purpose of having lines printed with e.g. `KERN_ERR "\n"' only?
Shouldn't these just be removed?

Usually lines starting with `\n' are continuations, but given some other
module may call printk() in between, there's no guarantee continuations
appear on the same line.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
