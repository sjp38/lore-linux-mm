Date: Mon, 1 Dec 2008 17:20:18 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] acpi: do not use kmem caches
Message-ID: <20081201162018.GF10790@wotan.suse.de>
References: <20081201083128.GB2529@wotan.suse.de> <84144f020812010318v205579ean57edecf7992ec7ef@mail.gmail.com> <20081201120002.GB10790@wotan.suse.de> <4933E2C3.4020400@gmail.com> <1228138641.14439.18.camel@penberg-laptop> <Pine.LNX.4.64.0812010828150.14977@quilx.com> <4933F925.3020907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4933F925.3020907@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Starikovskiy <aystarik@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 01, 2008 at 05:48:05PM +0300, Alexey Starikovskiy wrote:
> Christoph Lameter wrote:
> >On Mon, 1 Dec 2008, Pekka Enberg wrote:
> >
> >  
> >>Why do you think Nick's patch is going to _increase_ memory consumption?
> >>SLUB _already_ merges the ACPI caches with kmalloc caches so you won't
> >>see any difference there. For SLAB, it's a gain because there's not
> >>enough activity going on which results in lots of unused space in the
> >>slabs (which is, btw, the reason SLUB does slab merging in the first
> >>place).
> >>    
> >
> >The patch is going to increase memory consumption because the use of
> >the kmalloc array means that the allocated object sizes are rounded up to
> >the next power of two.
> >
> >I would recommend to keep the caches. Subsystem specific caches help to
> >simplify debugging and track the memory allocated for various purposes in
> >addition to saving the rounding up to power of two overhead.
> >And with SLUB the creation of such caches usually does not require
> >additional memory.
> >
> >Maybe it would be best to avoid kmalloc as much as possible.
> >
> >  
> Christoph,
> Thanks for support, these were my thoughts, when I changed ACPICA to use 
> kmem_cache instead of
> it's own on top of kmalloc 4 years ago...
> Here are two acpi caches on my thinkpad z61m, IMHO any laptop will show 
> similar numbers:
> 
> aystarik@thinkpad:~$ cat /proc/slabinfo | grep Acpi
> Acpi-ParseExt       2856   2856     72   56    1 : tunables    0    0    
> 0 : slabdata     51     51      0
> Acpi-Parse           170    170     48   85    1 : tunables    0    0    
> 0 : slabdata      2      2      0
> 
> Size of first will become 96 and size of second will be 64 if kmalloc is 
> used, and we don't count ACPICA internal overhead.
> Number of used blocks is not smallest in the list of slabs, actually it 
> is among the highest.

Hmm.
Acpi-Operand        2641   2773     64   59    1 : tunables  120   60    8 : slabdata     47     47     0
Acpi-ParseExt          0      0     64   59    1 : tunables  120   60    8 : slabdata      0      0     0
Acpi-Parse             0      0     40   92    1 : tunables  120   60    8 : slabdata      0      0     0
Acpi-State             0      0     80   48    1 : tunables  120   60    8 : slabdata      0      0     0
Acpi-Namespace      1711   1792     32  112    1 : tunables  120   60    8 : slabdata     16     16     0

Looks different for my thinkpad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
