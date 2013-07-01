Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 0E5296B0036
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 07:57:57 -0400 (EDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 00/13] PRAM: Persistent over-kexec memory storage
Date: Mon, 1 Jul 2013 15:57:35 +0400
Message-ID: <cover.1372582754.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com, khorenko@parallels.com

Hi,

This patchset implements persistent over-kexec memory storage or PRAM, which is
intended to be used for saving memory pages of the currently executing kernel
and restoring them after a kexec in the newly booted one. This can be utilized
for speeding up reboot by leaving process memory and/or FS caches in-place. The
patchset introduces the PRAM kernel API serving for that purpose and makes use
of this API to make tmpfs 'persistent', i.e. makes it possible to save tmpfs
tree on unmount and restore it on the next mount even if the system is kexec'd
between the mount and unmount.

For further details, please see below.

 -- The problem --

If Ksplice is not available or cannot be applied, a kernel update requires
restarting the system, which implies reinitialization of all running
application. Since this is a disk-bound operation, it can take quite a lot of
time. What is worse, if the host serves as a web or database or whatever else
server, apart from huge downtime the system reboot will cause any existent
connection to be dropped, which may not always be tolerated.

Although the kernel boot can be speeded up significantly by employing kexec,
which jumps directly to the new kernel skipping the BIOS and boot loader
stages, it has nothing to do with running applications, which still need to be
restarted.

 -- The solution --

There is the rapidly developing criu project (www.criu.org), which targets on
saving running application states to disk to be restored later. It is already
accepted by the community and hopefully it will soon be able to dump and
restore every Linux process. Obviously criu can be successfully used to omit
full application reinitialization on reboot, but criu'ing may still take a lot
of time. To illustrate, imagine a database server that cached to its internal
buffers 100 GB of data. Writing the image of that process sequentially at 100
MB/s will take more that 15 minutes. Multiplied by two, since the image must be
read after reboot, it gives half an hour of downtime! The server's clients will
probably disconnect by timeout until the system is up and running, which
cancels all the benefits of criu'ing.

However, the disk read/write, which is the bottleneck in the criu scheme, can
be avoided if kexec is used for rebooting. The point is kexec does not reset
the RAM state leaving all data written to memory intact. This fact is already
utilized by kdump to gather the full memory image on kernel panic. If it were
possible to save arbitrary data and restore them after kexec, it could be
utilized to completely avoid disk accesses when criu'ing.

This patchset implements the kernel API for saving data to be restored after
kexec and employs it to make tmpfs 'persistent' as described below.

 -- Usage --

 1) Boot kernel with 'pram_banned=MEMRANGE' boot option.
 
    MEMRANGE=MEMMIN-MEMMAX specifies memory range where kexec will load the new
    kernel code. It is used to avoid conflicts with persistent memory as
    described in implementation details. MEMRANGE=0-128M should be enough.

 2) Mount tmpfs with 'pram=NAME' option.

    NAME is an arbitrary string specifying persistent memory node. Different
    tmpfs trees may be saved to PRAM if different names are passed.

    # mkdir -p /mnt/crdump
    # mount -t tmpfs -o pram=mytmpfs none /mnt/crdump

 3) Checkpoint the process tree you'd want to pass over kexec to tmpfs.

    # criu dump -D /mnt/crdump -t $PID

 4) Unmount tmpfs.
 
    It will be automatically saved to PRAM on unmount.

    # umount /mnt/crdump

 5) Load the new kernel image.
 
    Kexec needs some tweaking for PRAM to work. First, one should pass PRAM
    super block pfn via 'pram' boot option. The pfn is exported via the sysfs
    file /sys/kernel/pram. Second, kexec must be forced to load the kernel code
    to MEMRANGE (see p.1).

    # kexec --load /vmlinuz --initrd=initrd.img \
            --append="$(cat /proc/cmdline | sed -e 's/pram=[^ ]*//g') pram=$(cat /sys/kernel/pram)" \
	    --mem-min=$MEMMIN --mem-max=$MEMMAX

 6) Boot to the new kernel.

    # reboot

 7) Mount tmpfs with 'pram=NAME' option.

    It should find the PRAM node with the tmpfs tree saved on previous unmount
    and restore it.

    # mount -t tmpfs -o pram=mytmpfs none /mnt/crdump

 8) Restore the process saved in p.3.

    # criu restore -d -D /mnt/crdump

 9) Remove the dump and unmount tmpfs

    # rm -f /mnt/crdump
    # umount /mnt/crdump

 -- Implementation details --

 * Saving a memory page is simply incrementing its refcounter so the page will
   not get freed when the last user puts it. So the data saved to PRAM may be
   safely used as usual.

 * To preserve persistent memory in the newly booted kernel, PRAM marks all the
   pages saved as reserved at early boot so that they will not be recycled. For
   the new kernel to find persistent memory metadata, one should pass PRAM
   super block pfn, which is exported via /sys/kernel/pram, in the 'pram' boot
   param.

 * Since some memory is required for completing boot sequence, PRAM tracks all
   memory regions that have ever been reserved by other parts of the kernel and
   avoids using them for persistent memory. Since the device configuration
   cannot change during kexec, and the newly booted kernel is likely to have
   the same set of device drivers, it should work in most cases.

 * Since kexec may load the new kernel code to any memory region, it can
   destroy persistent memory. To exclude this, kexec should be forced to load
   the new kernel code to a memory region that is banned for PRAM. For that
   purpose, there is the 'pram_banned' boot param and --mem-min and --mem-max
   otpions of the kexec utility.

 * If a conflict still happens, it will be identified and all persistent memory
   will be discarded to prevent further errors. It is guaranteed by
   checksumming all data saved to PRAM.

 * tmpfs is saved to PRAM on unmount and loaded on mount if 'pram=NAME' mount
   option is passed. NAME specifies the PRAM node to save data to. This is to
   allow saving several tmpfs trees.

 * Saving tmpfs to PRAM is not well elaborated at present and serves rather as
   a proof of concept. Namely, only regular files without multiple hard links
   are supported and tmpfs may not be swapped out. If these requirements are
   not met, save to PRAM will be aborted spewing a message to the kernel log.
   This is not very difficult to fix, but at present one should turn off swap
   to test the feature.

 -- Future plans --

What we'd like to do:

 * Implement swap entries 'freezing' to allow saving a swapped out tmpfs.
 * Implement full support of tmpfs including saving dirs, special files, etc.
 * Implement SPLICE_F_MOVE, SPLICE_F_GIFT flags for splicing data from/to
   shmem. This would allow avoiding memory copying on checkpoint/restore.
 * Save uptodate fs cache on umount to be restored on mount after kexec.

Thanks,

Vladimir Davydov (13):
  mm: add PRAM API stubs and Kconfig
  mm: PRAM: implement node load and save functions
  mm: PRAM: implement page stream operations
  mm: PRAM: implement byte stream operations
  mm: PRAM: link nodes by pfn before reboot
  mm: PRAM: introduce super block
  mm: PRAM: preserve persistent memory at boot
  mm: PRAM: checksum saved data
  mm: PRAM: ban pages that have been reserved at boot time
  mm: PRAM: allow to ban arbitrary memory ranges
  mm: PRAM: allow to free persistent memory from userspace
  mm: shmem: introduce shmem_insert_page
  mm: shmem: enable saving to PRAM

 arch/x86/kernel/setup.c  |    2 +
 arch/x86/mm/init_32.c    |    5 +
 arch/x86/mm/init_64.c    |    5 +
 include/linux/pram.h     |   62 +++
 include/linux/shmem_fs.h |   29 ++
 mm/Kconfig               |   14 +
 mm/Makefile              |    1 +
 mm/bootmem.c             |    4 +
 mm/memblock.c            |    7 +-
 mm/pram.c                | 1279 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/shmem.c               |   97 +++-
 mm/shmem_pram.c          |  378 ++++++++++++++
 12 files changed, 1878 insertions(+), 5 deletions(-)
 create mode 100644 include/linux/pram.h
 create mode 100644 mm/pram.c
 create mode 100644 mm/shmem_pram.c

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
