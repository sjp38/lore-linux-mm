Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DC5155F0001
	for <linux-mm@kvack.org>; Sun, 19 Apr 2009 21:40:24 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 0/5] ksm - dynamic page sharing driver for linux v4
Date: Mon, 20 Apr 2009 04:36:01 +0300
Message-Id: <1240191366-10029-1-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

Introduction:
KSM is a linux driver that allows dynamicly sharing identical memory
pages between one or more processes.

Unlike tradtional page sharing that is made at the allocation of the
memory, ksm do it dynamicly after the memory was created.
Memory is periodically scanned; identical pages are identified and
merged.

The sharing is made in a transparent way to the procsess that use it.

Ksm is highly important for hypervisors (kvm), where in production
enviorments there might be many copys of the same data data among the
host memory.
This kind of data can be:
similar kernels, librarys, cache, and so on.

Even that ksm was wrote for kvm, any userspace application that want
to use it to share its data can try it.

Ksm may be useful for any application that might have similar (page
aligment) data strctures among the memory, ksm will find this data merge
it to one copy, and even if it will be changed and thereforew copy on
writed, ksm will merge it again as soon as it will be identical again.

Another reason to consider using ksm is the fact that it might simplify
alot the userspace code of application that want to use shared private data,
instead that the application will mange shared area, ksm will do this for
the application, and even write to this data will be allowed without any
synchinization acts from the application.

Ksm was desgiend to be a loadable module that doesnt change the VM code
of linux.


>From v3 - v4:

1) Mostly fixes of coding styles, and few bugs that Andrew found.
   * get_user_pages return value check - we now check == 1.
   * protecting the vma under the mmap_sem() while checking its fields.
   * kthread_* renaming into ksm_thread_*
   * const to the file_operations strctures.

   (The only thing i didnt change from your comments, is the number
    of pages we are allocating for the hash table, this is performence
    critical for ksm)

2) Changed get_pte() to be linux generic function avaible for other users.


Description of the ksm interface:

Ksm interface is splited into two areas;
Administration sysfs interface - interface that is avaible thanks to
sysfs to control the ksm cpu timing, maximum allocation of kernel pages
and statics.

This interface is avaible at /sys/kernel/mm/ksm/ and its fields are:

kernel_pages_allocated - information about how many kernel pagesksm have
allocated, this pages are not swappabke, and each page like that is used
by ksm to share pages with identical content.

pages_shared - how many pages were shared by ksm

run - set to 1 when you want ksm to run, 0 when no

max_kernel_pages - set the maximum amount of kernel pages to be allocated
by ksm, set 0 for unlimited.

pages_to_scan - how many pages to scan before ksm will sleep

sleep - how much usecs ksm will sleep.


The interface for applications that want its memory to be scanned by ksm:
This interface is built around ioctls when application want its memory
to be scanned it will do something like that:

static int ksm_register_memory(unsigned long phys_ram_size,
                               unsigned long phys_ram_base)
{
    int fd;
    int ksm_fd;
    int r = 1;
    struct ksm_memory_region ksm_region;

    fd = open("/dev/ksm", O_RDWR | O_TRUNC, (mode_t)0600);
    if (fd == -1)
        goto out;

    ksm_fd = ioctl(fd, KSM_CREATE_SHARED_MEMORY_AREA);
    if (ksm_fd == -1)
        goto out_free;

    ksm_region.npages = phys_ram_size / TARGET_PAGE_SIZE;
    ksm_region.addr = phys_ram_base;
    r = ioctl(ksm_fd, KSM_REGISTER_MEMORY_REGION, &ksm_region);
    if (r)
        goto out_free1;

    return r;

out_free1:
    close(ksm_fd);
out_free:
    close(fd);
out:
    return r;
}

This ioctls are:

KSM_GET_API_VERSION:
Give the userspace the api version of the module.

KSM_CREATE_SHARED_MEMORY_AREA:
Create shared memory reagion fd, that latter allow the user to register
the memory region to scan by using:
KSM_REGISTER_MEMORY_REGION and KSM_REMOVE_MEMORY_REGION

KSM_REGISTER_MEMORY_REGION:
Register userspace virtual address range to be scanned by ksm.
This ioctl is using the ksm_memory_region structure:
ksm_memory_region:
__u32 npages;
         number of pages to share inside this memory region.
__u32 pad;
__u64 addr:
        the begining of the virtual address of this region.
__u64 reserved_bits;
        reserved bits for future usage.

KSM_REMOVE_MEMORY_REGION:
Remove memory region from ksm.


Testing ksm:
Considering the fact that i got some mails asking me how to use this,
I guess it wasnt explined good in the last posts, i will try to improve
this:

The following steps should allow you to test ksm and play with it:

1) First patch your kernel with this patchs.

2) Patch avi kvm-git tree:
   (git.kernel.org/pub/scm/linux/kernel/git/avi/kvm.git) with the patchs
   from:
   http://lkml.org/lkml/2009/3/30/534

3) Patch kvm-userspace tree:
   git.kernel.org/pub/scm/virt/kvm/kvm-userspace.git with the patchs from:
   http://lkml.org/lkml/2009/3/30/538 

4) try to do:
   echo 300 > /sys/kernel/mm/ksm/pages_to_scan
   echo 10000 > /sys/kernel/mm/ksm/sleep
   echo 1 > /sys/kernel/mm/ksm/run 
   (Or any other numbers...)


Ok, you are ready :-)

(Just remember, memory that is swapped, isnt scanned by ksm until it
 come back to memory, so dont try to raise alot of VMS togather)


Thanks.


Izik Eidus (5):
  MMU_NOTIFIERS: add set_pte_at_notify()
  add get_pte(): helper function: fetching pte for va
  add page_wrprotect(): write protecting page.
  add replace_page(): change the page pte is pointing to.
  add ksm kernel shared memory driver.

 include/linux/ksm.h          |   48 ++
 include/linux/miscdevice.h   |    1 +
 include/linux/mm.h           |   29 +
 include/linux/mmu_notifier.h |   34 +
 include/linux/rmap.h         |   11 +
 mm/Kconfig                   |    6 +
 mm/Makefile                  |    1 +
 mm/ksm.c                     | 1675 ++++++++++++++++++++++++++++++++++++++++++
 mm/memory.c                  |   90 +++-
 mm/mmu_notifier.c            |   20 +
 mm/rmap.c                    |  139 ++++
 11 files changed, 2052 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/ksm.h
 create mode 100644 mm/ksm.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
