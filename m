Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC9288E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 13:03:20 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i68-v6so7044983pfb.9
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 10:03:20 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id x4-v6si4866860plo.459.2018.09.28.10.03.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Sep 2018 10:03:19 -0700 (PDT)
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
References: <20180928150357.12942-1-david@redhat.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <5dba97a5-5a18-5df1-5493-99987679cf3a@linux.intel.com>
Date: Fri, 28 Sep 2018 10:02:48 -0700
MIME-Version: 1.0
In-Reply-To: <20180928150357.12942-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org
Cc: xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, linux-acpi@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>, Joe Perches <joe@perches.com>, Michael Neuling <mikey@neuling.org>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Rashmica Gupta <rashmica.g@gmail.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Rob Herring <robh@kernel.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Mathieu Malaterre <malat@debian.org>

It's really nice if these kinds of things are broken up.  First, replace
the old want_memblock parameter, then add the parameter to the
__add_page() calls.

> +/*
> + * NONE:     No memory block is to be created (e.g. device memory).
> + * NORMAL:   Memory block that represents normal (boot or hotplugged) memory
> + *           (e.g. ACPI DIMMs) that should be onlined either automatically
> + *           (memhp_auto_online) or manually by user space to select a
> + *           specific zone.
> + *           Applicable to memhp_auto_online.
> + * STANDBY:  Memory block that represents standby memory that should only
> + *           be onlined on demand by user space (e.g. standby memory on
> + *           s390x), but never automatically by the kernel.
> + *           Not applicable to memhp_auto_online.
> + * PARAVIRT: Memory block that represents memory added by
> + *           paravirtualized mechanisms (e.g. hyper-v, xen) that will
> + *           always automatically get onlined. Memory will be unplugged
> + *           using ballooning, not by relying on the MOVABLE ZONE.
> + *           Not applicable to memhp_auto_online.
> + */
> +enum {
> +	MEMORY_BLOCK_NONE,
> +	MEMORY_BLOCK_NORMAL,
> +	MEMORY_BLOCK_STANDBY,
> +	MEMORY_BLOCK_PARAVIRT,
> +};

This does not seem like the best way to expose these.

STANDBY, for instance, seems to be essentially a replacement for a check
against running on s390 in userspace to implement a _typical_ s390
policy.  It seems rather weird to try to make the userspace policy
determination easier by telling userspace about the typical s390 policy
via the kernel.

As for the OOM issues, that sounds like something we need to fix by
refusing to do (or delaying) hot-add operations once we consume too much
ZONE_NORMAL from memmap[]s rather than trying to indirectly tell
userspace to hurry thing along.

So, to my eye, we need:

 +enum {
 +	MEMORY_BLOCK_NONE,
 +	MEMORY_BLOCK_STANDBY, /* the default */
 +	MEMORY_BLOCK_AUTO_ONLINE,
 +};

and we can probably collapse NONE into AUTO_ONLINE because userspace
ends up doing the same thing for both: nothing.

>  struct memory_block {
>  	unsigned long start_section_nr;
>  	unsigned long end_section_nr;
> @@ -34,6 +58,7 @@ struct memory_block {
>  	int (*phys_callback)(struct memory_block *);
>  	struct device dev;
>  	int nid;			/* NID for this memory block */
> +	int type;			/* type of this memory block */
>  };

Shouldn't we just be creating and using an actual named enum type?
