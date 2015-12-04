Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id BC86B6B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 10:50:08 -0500 (EST)
Received: by wmuu63 with SMTP id u63so67213673wmu.0
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 07:50:08 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id f2si6607902wma.46.2015.12.04.07.50.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 07:50:07 -0800 (PST)
Received: by wmuu63 with SMTP id u63so67212666wmu.0
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 07:50:06 -0800 (PST)
Message-ID: <5661B62B.2020409@gmail.com>
Date: Fri, 04 Dec 2015 16:50:03 +0100
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/23] userfaultfd: linux/Documentation/vm/userfaultfd.txt
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com> <1431624680-20153-2-git-send-email-aarcange@redhat.com> <55F29513.4030503@gmail.com>
In-Reply-To: <55F29513.4030503@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: mtk.manpages@gmail.com, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

Hi Andrea,

On 09/11/2015 10:47 AM, Michael Kerrisk (man-pages) wrote:
> On 05/14/2015 07:30 PM, Andrea Arcangeli wrote:
>> Add documentation.
> 
> Hi Andrea,
> 
> I do not recall... Did you write a man page also for this new system call?

No response to my last mail, so I'll try again... Did you 
write any man page for this interface?

Thanks,

Michael


>> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>> ---
>>  Documentation/vm/userfaultfd.txt | 140 +++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 140 insertions(+)
>>  create mode 100644 Documentation/vm/userfaultfd.txt
>>
>> diff --git a/Documentation/vm/userfaultfd.txt b/Documentation/vm/userfaultfd.txt
>> new file mode 100644
>> index 0000000..c2f5145
>> --- /dev/null
>> +++ b/Documentation/vm/userfaultfd.txt
>> @@ -0,0 +1,140 @@
>> += Userfaultfd =
>> +
>> +== Objective ==
>> +
>> +Userfaults allow the implementation of on-demand paging from userland
>> +and more generally they allow userland to take control various memory
>> +page faults, something otherwise only the kernel code could do.
>> +
>> +For example userfaults allows a proper and more optimal implementation
>> +of the PROT_NONE+SIGSEGV trick.
>> +
>> +== Design ==
>> +
>> +Userfaults are delivered and resolved through the userfaultfd syscall.
>> +
>> +The userfaultfd (aside from registering and unregistering virtual
>> +memory ranges) provides two primary functionalities:
>> +
>> +1) read/POLLIN protocol to notify a userland thread of the faults
>> +   happening
>> +
>> +2) various UFFDIO_* ioctls that can manage the virtual memory regions
>> +   registered in the userfaultfd that allows userland to efficiently
>> +   resolve the userfaults it receives via 1) or to manage the virtual
>> +   memory in the background
>> +
>> +The real advantage of userfaults if compared to regular virtual memory
>> +management of mremap/mprotect is that the userfaults in all their
>> +operations never involve heavyweight structures like vmas (in fact the
>> +userfaultfd runtime load never takes the mmap_sem for writing).
>> +
>> +Vmas are not suitable for page- (or hugepage) granular fault tracking
>> +when dealing with virtual address spaces that could span
>> +Terabytes. Too many vmas would be needed for that.
>> +
>> +The userfaultfd once opened by invoking the syscall, can also be
>> +passed using unix domain sockets to a manager process, so the same
>> +manager process could handle the userfaults of a multitude of
>> +different processes without them being aware about what is going on
>> +(well of course unless they later try to use the userfaultfd
>> +themselves on the same region the manager is already tracking, which
>> +is a corner case that would currently return -EBUSY).
>> +
>> +== API ==
>> +
>> +When first opened the userfaultfd must be enabled invoking the
>> +UFFDIO_API ioctl specifying a uffdio_api.api value set to UFFD_API (or
>> +a later API version) which will specify the read/POLLIN protocol
>> +userland intends to speak on the UFFD. The UFFDIO_API ioctl if
>> +successful (i.e. if the requested uffdio_api.api is spoken also by the
>> +running kernel), will return into uffdio_api.features and
>> +uffdio_api.ioctls two 64bit bitmasks of respectively the activated
>> +feature of the read(2) protocol and the generic ioctl available.
>> +
>> +Once the userfaultfd has been enabled the UFFDIO_REGISTER ioctl should
>> +be invoked (if present in the returned uffdio_api.ioctls bitmask) to
>> +register a memory range in the userfaultfd by setting the
>> +uffdio_register structure accordingly. The uffdio_register.mode
>> +bitmask will specify to the kernel which kind of faults to track for
>> +the range (UFFDIO_REGISTER_MODE_MISSING would track missing
>> +pages). The UFFDIO_REGISTER ioctl will return the
>> +uffdio_register.ioctls bitmask of ioctls that are suitable to resolve
>> +userfaults on the range registered. Not all ioctls will necessarily be
>> +supported for all memory types depending on the underlying virtual
>> +memory backend (anonymous memory vs tmpfs vs real filebacked
>> +mappings).
>> +
>> +Userland can use the uffdio_register.ioctls to manage the virtual
>> +address space in the background (to add or potentially also remove
>> +memory from the userfaultfd registered range). This means a userfault
>> +could be triggering just before userland maps in the background the
>> +user-faulted page.
>> +
>> +The primary ioctl to resolve userfaults is UFFDIO_COPY. That
>> +atomically copies a page into the userfault registered range and wakes
>> +up the blocked userfaults (unless uffdio_copy.mode &
>> +UFFDIO_COPY_MODE_DONTWAKE is set). Other ioctl works similarly to
>> +UFFDIO_COPY.
>> +
>> +== QEMU/KVM ==
>> +
>> +QEMU/KVM is using the userfaultfd syscall to implement postcopy live
>> +migration. Postcopy live migration is one form of memory
>> +externalization consisting of a virtual machine running with part or
>> +all of its memory residing on a different node in the cloud. The
>> +userfaultfd abstraction is generic enough that not a single line of
>> +KVM kernel code had to be modified in order to add postcopy live
>> +migration to QEMU.
>> +
>> +Guest async page faults, FOLL_NOWAIT and all other GUP features work
>> +just fine in combination with userfaults. Userfaults trigger async
>> +page faults in the guest scheduler so those guest processes that
>> +aren't waiting for userfaults (i.e. network bound) can keep running in
>> +the guest vcpus.
>> +
>> +It is generally beneficial to run one pass of precopy live migration
>> +just before starting postcopy live migration, in order to avoid
>> +generating userfaults for readonly guest regions.
>> +
>> +The implementation of postcopy live migration currently uses one
>> +single bidirectional socket but in the future two different sockets
>> +will be used (to reduce the latency of the userfaults to the minimum
>> +possible without having to decrease /proc/sys/net/ipv4/tcp_wmem).
>> +
>> +The QEMU in the source node writes all pages that it knows are missing
>> +in the destination node, into the socket, and the migration thread of
>> +the QEMU running in the destination node runs UFFDIO_COPY|ZEROPAGE
>> +ioctls on the userfaultfd in order to map the received pages into the
>> +guest (UFFDIO_ZEROCOPY is used if the source page was a zero page).
>> +
>> +A different postcopy thread in the destination node listens with
>> +poll() to the userfaultfd in parallel. When a POLLIN event is
>> +generated after a userfault triggers, the postcopy thread read() from
>> +the userfaultfd and receives the fault address (or -EAGAIN in case the
>> +userfault was already resolved and waken by a UFFDIO_COPY|ZEROPAGE run
>> +by the parallel QEMU migration thread).
>> +
>> +After the QEMU postcopy thread (running in the destination node) gets
>> +the userfault address it writes the information about the missing page
>> +into the socket. The QEMU source node receives the information and
>> +roughly "seeks" to that page address and continues sending all
>> +remaining missing pages from that new page offset. Soon after that
>> +(just the time to flush the tcp_wmem queue through the network) the
>> +migration thread in the QEMU running in the destination node will
>> +receive the page that triggered the userfault and it'll map it as
>> +usual with the UFFDIO_COPY|ZEROPAGE (without actually knowing if it
>> +was spontaneously sent by the source or if it was an urgent page
>> +requested through an userfault).
>> +
>> +By the time the userfaults start, the QEMU in the destination node
>> +doesn't need to keep any per-page state bitmap relative to the live
>> +migration around and a single per-page bitmap has to be maintained in
>> +the QEMU running in the source node to know which pages are still
>> +missing in the destination node. The bitmap in the source node is
>> +checked to find which missing pages to send in round robin and we seek
>> +over it when receiving incoming userfaults. After sending each page of
>> +course the bitmap is updated accordingly. It's also useful to avoid
>> +sending the same page twice (in case the userfault is read by the
>> +postcopy thread just before UFFDIO_COPY|ZEROPAGE runs in the migration
>> +thread).
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-api" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
