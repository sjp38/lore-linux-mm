Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B23D66B30F4
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:14:15 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id b26so8535541qtq.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:14:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h22si32603qtk.163.2018.11.23.03.14.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 03:14:14 -0800 (PST)
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
References: <20180928150357.12942-1-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <b01a956b-080c-c643-6473-eb132b9f7200@redhat.com>
Date: Fri, 23 Nov 2018 12:13:58 +0100
MIME-Version: 1.0
In-Reply-To: <20180928150357.12942-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, linux-acpi@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>, Joe Perches <joe@perches.com>, Michael Neuling <mikey@neuling.org>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Rashmica Gupta <rashmica.g@gmail.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Rob Herring <robh@kernel.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Mathieu Malaterre <malat@debian.org>, =?UTF-8?Q?Michal_Such=c3=a1nek?= <msuchanek@suse.de>

On 28.09.18 17:03, David Hildenbrand wrote:
> How to/when to online hotplugged memory is hard to manage for
> distributions because different memory types are to be treated differently.
> Right now, we need complicated udev rules that e.g. check if we are
> running on s390x, on a physical system or on a virtualized system. But
> there is also sometimes the demand to really online memory immediately
> while adding in the kernel and not to wait for user space to make a
> decision. And on virtualized systems there might be different
> requirements, depending on "how" the memory was added (and if it will
> eventually get unplugged again - DIMM vs. paravirtualized mechanisms).
> 
> On the one hand, we have physical systems where we sometimes
> want to be able to unplug memory again - e.g. a DIMM - so we have to online
> it to the MOVABLE zone optionally. That decision is usually made in user
> space.
> 
> On the other hand, we have memory that should never be onlined
> automatically, only when asked for by an administrator. Such memory only
> applies to virtualized environments like s390x, where the concept of
> "standby" memory exists. Memory is detected and added during boot, so it
> can be onlined when requested by the admininistrator or some tooling.
> Only when onlining, memory will be allocated in the hypervisor.
> 
> But then, we also have paravirtualized devices (namely xen and hyper-v
> balloons), that hotplug memory that will never ever be removed from a
> system right now using offline_pages/remove_memory. If at all, this memory
> is logically unplugged and handed back to the hypervisor via ballooning.
> 
> For paravirtualized devices it is relevant that memory is onlined as
> quickly as possible after adding - and that it is added to the NORMAL
> zone. Otherwise, it could happen that too much memory in a row is added
> (but not onlined), resulting in out-of-memory conditions due to the
> additional memory for "struct pages" and friends. MOVABLE zone as well
> as delays might be very problematic and lead to crashes (e.g. zone
> imbalance).
> 
> Therefore, introduce memory block types and online memory depending on
> it when adding the memory. Expose the memory type to user space, so user
> space handlers can start to process only "normal" memory. Other memory
> block types can be ignored. One thing less to worry about in user space.
> 

So I was looking into alternatives.

1. Provide only "normal" and "standby" memory types to user space. This
way user space can make smarter decisions about how to online memory.
Not really sure if this is the right way to go.


2. Use device driver information (as mentioned by Michal S.).

The problem right now is that there are no drivers for memory block
devices. The "memory" subsystem has no drivers, so the KOBJ_ADD uevent
will not contain a "DRIVER" information and we ave no idea what kind of
memory block device we hold in our hands.

$ udevadm info -q all -a /sys/devices/system/memory/memory0

  looking at device '/devices/system/memory/memory0':
    KERNEL=="memory0"
    SUBSYSTEM=="memory"
    DRIVER==""
    ATTR{online}=="1"
    ATTR{phys_device}=="0"
    ATTR{phys_index}=="00000000"
    ATTR{removable}=="0"
    ATTR{state}=="online"
    ATTR{valid_zones}=="none"


If we would provide "fake" drivers for the memory block devices we want
to treat in a special way in user space (e.g. standby memory on s390x),
user space could use that information to make smarter decisions.

Adding such drivers might work. My suggestion would be to let ordinary
DIMMs be without a driver for now and only special case standby memory
and eventually paravirtualized memory devices (XEN and Hyper-V).

Any thoughts?


-- 

Thanks,

David / dhildenb
