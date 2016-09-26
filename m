Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id A2C7F280274
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 17:13:00 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id n13so3717684uaa.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 14:13:00 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id g16si4506605vke.165.2016.09.26.14.12.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Sep 2016 14:12:59 -0700 (PDT)
Message-ID: <1474924351.2857.255.camel@kernel.crashing.org>
Subject: Re: [PATCH v3 4/5] powerpc/mm: restore top-down allocation when
 using movable_node
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 27 Sep 2016 07:12:31 +1000
In-Reply-To: <1474828616-16608-5-git-send-email-arbab@linux.vnet.ibm.com>
References: <1474828616-16608-1-git-send-email-arbab@linux.vnet.ibm.com>
	 <1474828616-16608-5-git-send-email-arbab@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

On Sun, 2016-09-25 at 13:36 -0500, Reza Arbab wrote:
> At boot, the movable_node option sets bottom-up memblock allocation.
> 
> This reduces the chance that, in the window before movable memory has
> been identified, an allocation for the kernel might come from a movable
> node. By going bottom-up, early allocations will most likely come from
> the same node as the kernel image, which is necessarily in a nonmovable
> node.
> 
> Then, once any known hotplug memory has been marked, allocation can be
> reset back to top-down. On x86, this is done in numa_init(). This patch
> does the same on power, in numa initmem_init().

That's fragile and a bit gross.

But then I'm not *that* fan of making accelerator memory be "memory" nodes
in the first place. Oh well...

In any case, if the memory hasn't been hotplug, this shouldn't be necessary
as we shouldn't be considering it for allocation.

If we want to prevent it for other reason, we should add logic for that
in memblock, or reserve it early or something like that.

Just relying magically on the direction of the allocator is bad, really bad.

Ben.

> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---
> A arch/powerpc/mm/numa.c | 3 +++
> A 1 file changed, 3 insertions(+)
> 
> diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
> index d7ac419..fdf1e69 100644
> --- a/arch/powerpc/mm/numa.c
> +++ b/arch/powerpc/mm/numa.c
> @@ -945,6 +945,9 @@ void __init initmem_init(void)
> > A 	max_low_pfn = memblock_end_of_DRAM() >> PAGE_SHIFT;
> > A 	max_pfn = max_low_pfn;
> A 
> > +	/* bottom-up allocation may have been set by movable_node */
> > +	memblock_set_bottom_up(false);
> +
> > A 	if (parse_numa_properties())
> > A 		setup_nonnuma();
> > A 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
