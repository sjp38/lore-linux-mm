Date: Mon, 1 Dec 2008 18:12:19 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] acpi: do not use kmem caches
Message-ID: <20081201171219.GI10790@wotan.suse.de>
References: <20081201083128.GB2529@wotan.suse.de> <84144f020812010318v205579ean57edecf7992ec7ef@mail.gmail.com> <20081201120002.GB10790@wotan.suse.de> <4933E2C3.4020400@gmail.com> <1228138641.14439.18.camel@penberg-laptop> <Pine.LNX.4.64.0812010828150.14977@quilx.com> <4933F925.3020907@gmail.com> <20081201162018.GF10790@wotan.suse.de> <49341915.5000900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49341915.5000900@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Starikovskiy <aystarik@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 01, 2008 at 08:04:21PM +0300, Alexey Starikovskiy wrote:
> Nick Piggin wrote:
> >Hmm.
> >Acpi-Operand        2641   2773     64   59    1 : tunables  120   60    8 
> >: slabdata     47     47     0
> >Acpi-ParseExt          0      0     64   59    1 : tunables  120   60    8 
> >: slabdata      0      0     0
> >Acpi-Parse             0      0     40   92    1 : tunables  120   60    8 
> >: slabdata      0      0     0
> >Acpi-State             0      0     80   48    1 : tunables  120   60    8 
> >: slabdata      0      0     0
> >Acpi-Namespace      1711   1792     32  112    1 : tunables  120   60    8 
> >: slabdata     16     16     0
> >
> >  
> >Looks different for my thinkpad.
> >  
> Probably this is SLUB vs. SLAB thing Pecca was talking about...

Sizes should not be bigger with SLUB. Although if you have SLUB debugging
turned on then maybe the size gets padded with redzones, but in that
configuration you don't expect memory saving anyway because padding bloats
things up.


> And, probably you run at 32-bit? This is part of my .config:

No, 64 bit.


> --------------------------------------------
> CONFIG_SLUB_DEBUG=y
> # CONFIG_SLAB is not set
> CONFIG_SLUB=y
> # CONFIG_SLOB is not set
> -------------------------------------------
> 
> With your patch you would be able to save 64*(2773 - 2641) + 32 * 
> (1792-1711)= 8448 + 2592 = 11040 bytes of memory, less than 3 pages?

You don't account the cost of the kmem cache. Or fragmentation that
can be caused with extra kmem caches.  I guess neither is any problem
with SLOB, which is used by tiny systems...

 
> 2856 * (96-72) = 68544 bytes and 170 * (64-48) = 2720 bytes, so you will be 
> wasting 5 times more memory in 64 bit case.

With debugging on, in which case you're wasting memory anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
