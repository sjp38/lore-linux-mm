Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02E596B0008
	for <linux-mm@kvack.org>; Fri, 25 May 2018 11:08:55 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id t143-v6so4120664qke.18
        for <linux-mm@kvack.org>; Fri, 25 May 2018 08:08:54 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d132-v6si797081qka.364.2018.05.25.08.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 May 2018 08:08:50 -0700 (PDT)
Subject: Re: [PATCH v1 00/10] mm: online/offline 4MB chunks controlled by
 device driver
References: <20180523151151.6730-1-david@redhat.com>
 <20180524075327.GU20441@dhcp22.suse.cz>
 <14d79dad-ad47-f090-2ec0-c5daf87ac529@redhat.com>
 <20180524093121.GZ20441@dhcp22.suse.cz>
 <c0b8bbd5-6c01-f550-ae13-ef80b2255ea6@redhat.com>
 <20180524120341.GF20441@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <216ca71b-9880-f013-878b-ae39e865b94b@redhat.com>
Date: Fri, 25 May 2018 17:08:37 +0200
MIME-Version: 1.0
In-Reply-To: <20180524120341.GF20441@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Balbir Singh <bsingharora@gmail.com>, Baoquan He <bhe@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>, Jan Kara <jack@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Miles Chen <miles.chen@mediatek.com>, Oscar Salvador <osalvador@techadventures.net>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, Rashmica Gupta <rashmica.g@gmail.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, kexec@lists.infradead.org

>> So, no, virtio-mem is not a balloon driver :)
> [...]
>>>> 1. "hotplug should simply not depend on kdump at all"
>>>>
>>>> In theory yes. In the current state we already have to trigger kdump to
>>>> reload whenever we add/remove a memory block.
>>>
>>> More details please.
>>
>> I just had another look at the whole complexity of
>> makedumfile/kdump/uevents and I'll follow up with a detailed description.
>>
>> kdump.service is definitely reloaded when setting a memory block
>> online/offline (not when adding/removing as I wrongly claimed before).
>>
>> I'll follow up with a more detailed description and all the pointers.
> 
> Please make sure to describe what is the architecture then. I have no
> idea what kdump.servise is supposed to do for example.

Giving a high level description, going into applicable details:


Dump tools always generate the dump file from /proc/vmcore inside the
kexec environment. This is a vmcore dump in ELF format, with required
and optional headers and notes.


1. Core collectors

The tool that writes /proc/vmcore into a file is called "core collector".

"This allows you to specify the command to copy the vmcore. You could
use the dump filtering program makedumpfile, the default one, to
retrieve your core, which on some arches can drastically reduce core
file size." [1]

E.g. under RHEL, the only supported core collector is in fact
makedumpfile [2][3], which is e.g. able to exclude e.g. hwpoison pages,
which could result otherwise in a crash if you simply copy /proc/vmcore
into a file on harddisk.


2. vmcoreinfo

/proc/vmcore can optionally contain a vmcoreinfo, that exposes some
magic variables necessary to e.g. find and interpret segments but also
struct pages. This is generated in "kernel/crash_core.c" in the crashed
linux kernel.

...
VMCOREINFO_SYMBOL_ARRAY(mem_section);
VMCOREINFO_LENGTH(mem_section, NR_SECTION_ROOTS);
...
VMCOREINFO_NUMBER(PG_hwpoison);
...
VMCOREINFO_NUMBER(PAGE_BUDDY_MAPCOUNT_VALUE);
...

If not available, it is e.g. tried to extract relevant
symbols/variables/pointers from vmlinux (similar like e.g. GDB).


3. PM_LOAD / Memory holes

Each vmcore contains "PM_LOAD" sections. These sections define which
physical memory areas are available in the vmcore (and to which virtual
addresses they translate). Generated e.g. in "kernel/kexec_file.c" - and
in some other places "git grep Elf64_Phdr".

This information is generated in the crashed kernel.

arch/x86/kernel/crash.c:
 walk_system_ram_res() is effectively used to generate PM_LOAD segments

arch/s390/kernel/crash_dump.c:
 for_each_mem_range() is effectively used to generate PM_LOAD
 information

At this point, I don't see how offline sections are treated. I assume
they are always also included. So PT_LOAD will include all memory, no
matter if online or offline.


4. Reloading kexec/kdump.service

The important thing is that the vmcore *excluding* the actual memory has
to be prepared by the *old* kernel. The kexec kernel will allow to
- Read the prepared vmcore (contained in kexec kernel)
- Read the memory

So dump tools only have the vmcore (esp. PT_LOAD) to figure out which
physical memory was available in the *old* system. The kexec kernel
neither reads or interprets segments/struct pages from the old kernel
(and there would be no way to really do it). All it does is allow to
read old memory as defined in the prepared vmcore. If that memory is not
accessible or broken (hwpoison), we will crash the system.

So what does this imply? vmcore (including PT_LOAD sections) has to be
regenerated every time memory is added/removed from the system.
Otherwise the data contained in the prepared vmcore is stale. As far as
I understand this cannot be done by the actual kernel when
adding/removing memory but has to be done by user space.

The same is e.g. also true when hot(un)plugging CPUs.

This is done by reloading kexec, resulting in a regeneration of the
vmcore. UDEV events are used to reload kdump.service and therefore
regenerate. This events are triggered when onlining/offlining a memory
block.

...
SUBSYSTEM=="memory", ACTION=="online", PROGRAM="/bin/systemctl
try-restart kdump.service"
SUBSYSTEM=="memory", ACTION=="offline", PROGRAM="/bin/systemctl
try-restart kdump.service"
...

For "online", this is the right thing to do.

I am right now not 100% if that is the right thing to do for "offline".
I guess we should regenerate actually after "remove" events, but I
didn't follow the details. Otherwise it could happen that the vmcore is
regenerated before the actual removal of memory blocks. So the
applicable memory blocks would still be included as PT_LOAD in the
vmcore. If we then remove the actual DIMM then, trying to dump the
vmcore will result in reading invalid memory. But maybe I am missing
something there.


5. Access to vmcore / memory in the kexec environment

fs/proc/vmcore.c: contains the code for parsing vmcore in the kexec
kernel, prepared by the crashed kernel. The kexec kernel provides read
access to /proc/vmcore on this basis.

All PT_LOAD sections will be converted and stored in "vmcore_list".

When reading the vmcore, this list will be used to actually provide
access to the original crash memory (__read_vmcore()).

So only memory that was originally in vmcore PT_LOAD will be allowed to
be red.

read_from_oldmem() will perform the actual read. At that point we have
no control over old page flags or segments. Just a straight memory read.

There is special handling for e.g. XEN in there: pfn_is_ram() can be
used to hinder reading inflated memory. (register_oldmem_pfn_is_ram)

However reusing that for virtio-mem with multiple devices and queues and
such might not be possible. It is the last resort :)


6. makedumpfile

makedumpfile can exclude free (buddy) pages, hwpoison pages and some
more. It will *not* exclude reserved pages or balloon (e.g.
virtio-balloon) inflated pages. So it will read inflated pages and if
they are zero, save a compressed zero page. However it will (read)
access that memory.

makedumpfile was adapted to the new SECTION_IS_ONLINE bit (to mask the
right section address), offline sections will *not* be excluded. So also
all memory in offline sections will be accessed and dumped - unless
pages don't fall into PT_LOAD sections ("memory hole"), in this case
they are not accessed.


7. Further information

Some more details can be found in "Documentation/kdump/kdump.txt".


"All of the necessary information about the system kernel's core image
is encoded in the ELF format, and stored in a reserved area of memory
before a crash. The physical address of the start of the ELF header is
passed to the dump-capture kernel through the elfcorehdr= boot
parameter."
-> I am pretty sure this is why the kexec reload from user space is
   necessary

"For s390x there are two kdump modes: If a ELF header is specified with
 the elfcorehdr= kernel parameter, it is used by the kdump kernel as it
 is done on all other architectures. If no elfcorehdr= kernel parameter
 is specified, the s390x kdump kernel dynamically creates the header.
 The second mode has the advantage that for CPU and memory hotplug,
 kdump has not to be reloaded with kexec_load()."


Any experts, please jump in :)



[1] https://www.systutorials.com/docs/linux/man/5-kdump/
[2] https://sourceforge.net/projects/makedumpfile/
[3] git://git.code.sf.net/p/makedumpfile/code

-- 

Thanks,

David / dhildenb
