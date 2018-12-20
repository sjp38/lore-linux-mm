Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B661B8E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:08:40 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id l45so2324170edb.1
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 05:08:40 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c43si1041316edc.97.2018.12.20.05.08.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 05:08:39 -0800 (PST)
Date: Thu, 20 Dec 2018 14:08:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFCv2 0/4] mm/memory_hotplug: Introduce memory block types
Message-ID: <20181220130832.GH9104@dhcp22.suse.cz>
References: <20181130175922.10425-1-david@redhat.com>
 <1b4afb6a-5f91-407d-6e6e-6a89b8cf5d56@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1b4afb6a-5f91-407d-6e6e-6a89b8cf5d56@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-acpi@vger.kernel.org, devel@linuxdriverproject.org, xen-devel@lists.xenproject.org, x86@kernel.org, Andrew Banman <andrew.banman@hpe.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Arun KS <arunks@codeaurora.org>, Balbir Singh <bsingharora@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Borislav Petkov <bp@alien8.de>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Christophe Leroy <christophe.leroy@c-s.fr>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Jiang <dave.jiang@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Haiyang Zhang <haiyangz@microsoft.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Ingo Molnar <mingo@redhat.com>, Jan =?iso-8859-1?Q?H=2E_Sch=F6nherr?= <jschoenh@amazon.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jonathan =?iso-8859-1?Q?Neusch=E4fer?= <j.neuschaefer@gmx.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Len Brown <lenb@kernel.org>, Logan Gunthorpe <logang@deltatee.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Mathieu Malaterre <malat@debian.org>, Matthew Wilcox <willy@infradead.org>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Michael Neuling <mikey@neuling.org>, Michal =?iso-8859-1?Q?Such=E1nek?= <msuchanek@suse.de>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Nicholas Piggin <npiggin@gmail.com>, Oscar Salvador <osalvador@suse.com>, Oscar Salvador <osalvador@suse.de>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rafael@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Rashmica Gupta <rashmica.g@gmail.com>, Rich Felker <dalias@libc.org>, Rob Herring <robh@kernel.org>, Stefano Stabellini <sstabellini@kernel.org>, Stephen Hemminger <sthemmin@microsoft.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vasily Gorbik <gor@linux.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, YueHaibing <yuehaibing@huawei.com>

On Thu 20-12-18 13:58:16, David Hildenbrand wrote:
> On 30.11.18 18:59, David Hildenbrand wrote:
> > This is the second approach, introducing more meaningful memory block
> > types and not changing online behavior in the kernel. It is based on
> > latest linux-next.
> > 
> > As we found out during dicussion, user space should always handle onlining
> > of memory, in any case. However in order to make smart decisions in user
> > space about if and how to online memory, we have to export more information
> > about memory blocks. This way, we can formulate rules in user space.
> > 
> > One such information is the type of memory block we are talking about.
> > This helps to answer some questions like:
> > - Does this memory block belong to a DIMM?
> > - Can this DIMM theoretically ever be unplugged again?
> > - Was this memory added by a balloon driver that will rely on balloon
> >   inflation to remove chunks of that memory again? Which zone is advised?
> > - Is this special standby memory on s390x that is usually not automatically
> >   onlined?
> > 
> > And in short it helps to answer to some extend (excluding zone imbalances)
> > - Should I online this memory block?
> > - To which zone should I online this memory block?
> > ... of course special use cases will result in different anwers. But that's
> > why user space has control of onlining memory.
> > 
> > More details can be found in Patch 1 and Patch 3.
> > Tested on x86 with hotplugged DIMMs. Cross-compiled for PPC and s390x.
> > 
> > 
> > Example:
> > $ udevadm info -q all -a /sys/devices/system/memory/memory0
> > 	KERNEL=="memory0"
> > 	SUBSYSTEM=="memory"
> > 	DRIVER==""
> > 	ATTR{online}=="1"
> > 	ATTR{phys_device}=="0"
> > 	ATTR{phys_index}=="00000000"
> > 	ATTR{removable}=="0"
> > 	ATTR{state}=="online"
> > 	ATTR{type}=="boot"
> > 	ATTR{valid_zones}=="none"
> > $ udevadm info -q all -a /sys/devices/system/memory/memory90
> > 	KERNEL=="memory90"
> > 	SUBSYSTEM=="memory"
> > 	DRIVER==""
> > 	ATTR{online}=="1"
> > 	ATTR{phys_device}=="0"
> > 	ATTR{phys_index}=="0000005a"
> > 	ATTR{removable}=="1"
> > 	ATTR{state}=="online"
> > 	ATTR{type}=="dimm"
> > 	ATTR{valid_zones}=="Normal"
> > 
> > 
> > RFC -> RFCv2:
> > - Now also taking care of PPC (somehow missed it :/ )
> > - Split the series up to some degree (some ideas on how to split up patch 3
> >   would be very welcome)
> > - Introduce more memory block types. Turns out abstracting too much was
> >   rather confusing and not helpful. Properly document them.
> > 
> > Notes:
> > - I wanted to convert the enum of types into a named enum but this
> >   provoked all kinds of different errors. For now, I am doing it just like
> >   the other types (e.g. online_type) we are using in that context.
> > - The "removable" property should never have been named like that. It
> >   should have been "offlinable". Can we still rename that? E.g. boot memory
> >   is sometimes marked as removable ...
> > 
> 
> 
> Any feedback regarding the suggested block types would be very much
> appreciated!

I still do not like this much to be honest. I just didn't get to think
through this properly. My fear is that this is conflating an actual API
with the current implementation and as such will cause problems in
future. But I haven't really looked into your patches closely so I might
be wrong. Anyway I won't be able to look into it by the end of year.
-- 
Michal Hocko
SUSE Labs
