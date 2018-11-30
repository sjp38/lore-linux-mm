Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id EA04F6B5977
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 12:59:47 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id k66so6115550qkf.1
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 09:59:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 52si2845155qvg.213.2018.11.30.09.59.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 09:59:46 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFCv2 0/4] mm/memory_hotplug: Introduce memory block types
Date: Fri, 30 Nov 2018 18:59:18 +0100
Message-Id: <20181130175922.10425-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-acpi@vger.kernel.org, devel@linuxdriverproject.org, xen-devel@lists.xenproject.org, x86@kernel.org, David Hildenbrand <david@redhat.com>, Andrew Banman <andrew.banman@hpe.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Arun KS <arunks@codeaurora.org>, Balbir Singh <bsingharora@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Borislav Petkov <bp@alien8.de>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Christophe Leroy <christophe.leroy@c-s.fr>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Jiang <dave.jiang@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Haiyang Zhang <haiyangz@microsoft.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Ingo Molnar <mingo@redhat.com>, =?UTF-8?q?Jan=20H=2E=20Sch=C3=B6nherr?= <jschoenh@amazon.de>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Len Brown <lenb@kernel.org>, Logan Gunthorpe <logang@deltatee.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Mathieu Malaterre <malat@debian.org>, Matthew Wilcox <willy@infradead.org>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Michael Neuling <mikey@neuling.org>, Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, =?UTF-8?q?Michal=20Such=C3=A1nek?= <msuchanek@suse.de>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Nicholas Piggin <npiggin@gmail.com>, Oscar Salvador <osalvador@suse.com>, Oscar Salvador <osalvador@suse.de>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rafael@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Rashmica Gupta <rashmica.g@gmail.com>, Rich Felker <dalias@libc.org>, Rob Herring <robh@kernel.org>, Stefano Stabellini <sstabellini@kernel.org>, Stephen Hemminger <sthemmin@microsoft.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vasily Gorbik <gor@linux.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, YueHaibing <yuehaibing@huawei.com>

This is the second approach, introducing more meaningful memory block
types and not changing online behavior in the kernel. It is based on
latest linux-next.

As we found out during dicussion, user space should always handle onlining
of memory, in any case. However in order to make smart decisions in user
space about if and how to online memory, we have to export more information
about memory blocks. This way, we can formulate rules in user space.

One such information is the type of memory block we are talking about.
This helps to answer some questions like:
- Does this memory block belong to a DIMM?
- Can this DIMM theoretically ever be unplugged again?
- Was this memory added by a balloon driver that will rely on balloon
  inflation to remove chunks of that memory again? Which zone is advised?
- Is this special standby memory on s390x that is usually not automatically
  onlined?

And in short it helps to answer to some extend (excluding zone imbalances)
- Should I online this memory block?
- To which zone should I online this memory block?
... of course special use cases will result in different anwers. But that's
why user space has control of onlining memory.

More details can be found in Patch 1 and Patch 3.
Tested on x86 with hotplugged DIMMs. Cross-compiled for PPC and s390x.


Example:
$ udevadm info -q all -a /sys/devices/system/memory/memory0
	KERNEL=="memory0"
	SUBSYSTEM=="memory"
	DRIVER==""
	ATTR{online}=="1"
	ATTR{phys_device}=="0"
	ATTR{phys_index}=="00000000"
	ATTR{removable}=="0"
	ATTR{state}=="online"
	ATTR{type}=="boot"
	ATTR{valid_zones}=="none"
$ udevadm info -q all -a /sys/devices/system/memory/memory90
	KERNEL=="memory90"
	SUBSYSTEM=="memory"
	DRIVER==""
	ATTR{online}=="1"
	ATTR{phys_device}=="0"
	ATTR{phys_index}=="0000005a"
	ATTR{removable}=="1"
	ATTR{state}=="online"
	ATTR{type}=="dimm"
	ATTR{valid_zones}=="Normal"


RFC -> RFCv2:
- Now also taking care of PPC (somehow missed it :/ )
- Split the series up to some degree (some ideas on how to split up patch 3
  would be very welcome)
- Introduce more memory block types. Turns out abstracting too much was
  rather confusing and not helpful. Properly document them.

Notes:
- I wanted to convert the enum of types into a named enum but this
  provoked all kinds of different errors. For now, I am doing it just like
  the other types (e.g. online_type) we are using in that context.
- The "removable" property should never have been named like that. It
  should have been "offlinable". Can we still rename that? E.g. boot memory
  is sometimes marked as removable ...

David Hildenbrand (4):
  mm/memory_hotplug: Introduce memory block types
  mm/memory_hotplug: Replace "bool want_memblock" by "int type"
  mm/memory_hotplug: Introduce and use more memory types
  mm/memory_hotplug: Drop MEMORY_TYPE_UNSPECIFIED

 arch/ia64/mm/init.c                           |  4 +-
 arch/powerpc/mm/mem.c                         |  4 +-
 arch/powerpc/platforms/powernv/memtrace.c     |  9 +--
 .../platforms/pseries/hotplug-memory.c        |  7 +-
 arch/s390/mm/init.c                           |  4 +-
 arch/sh/mm/init.c                             |  4 +-
 arch/x86/mm/init_32.c                         |  4 +-
 arch/x86/mm/init_64.c                         |  8 +--
 drivers/acpi/acpi_memhotplug.c                | 16 ++++-
 drivers/base/memory.c                         | 60 ++++++++++++++--
 drivers/hv/hv_balloon.c                       |  3 +-
 drivers/s390/char/sclp_cmd.c                  |  3 +-
 drivers/xen/balloon.c                         |  2 +-
 include/linux/memory.h                        | 69 ++++++++++++++++++-
 include/linux/memory_hotplug.h                | 18 ++---
 kernel/memremap.c                             |  6 +-
 mm/memory_hotplug.c                           | 29 ++++----
 17 files changed, 194 insertions(+), 56 deletions(-)

-- 
2.17.2
