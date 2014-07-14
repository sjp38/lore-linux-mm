Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 81DC06B003B
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 15:25:06 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so5766195pde.3
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 12:25:06 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id h13si4951696pdl.42.2014.07.14.12.25.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 12:25:05 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so5728532pde.17
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 12:25:04 -0700 (PDT)
Date: Mon, 14 Jul 2014 12:22:47 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: PROBLEM: repeated remap_file_pages on tmpfs triggers bug on
 process exit
In-Reply-To: <748020aaaf5c5c2924a16232313e0175.squirrel@webmail.tu-dortmund.de>
Message-ID: <alpine.LSU.2.11.1407141209160.17242@eggly.anvils>
References: <748020aaaf5c5c2924a16232313e0175.squirrel@webmail.tu-dortmund.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Korb <ingo.korb@tu-dortmund.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Ning Qu <quning@google.com>, Dave Jones <davej@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 14 Jul 2014, Ingo Korb wrote:

> Hi,
> 
> repeated mapping of the same file on tmpfs using remap_file_pages
> sometimes triggers a "BUG at mm/filemap.c:202" when the process exits, log
> message below. The system is an x86_64 VirtualBox machine with 2GB of RAM
> running Debian, but it could also be reproduced on a non-virtualized
> laptop.
> 
> The bug can be triggered in Linux 3.16-rc5, bisecting has located d7c17551
> as the first failing commit (mm: implement ->map_pages for shmem/tmpfs).
> 
> A test program for this has been attached (I don't trust this webmailer to
> not mangle it). With the parameters set in the source code, the BUG
> message should be triggered within a small number of tries (usually the
> first or second). Changing the size of the memory map sometimes delays the
> bug ("while true; do ./remap-demo; done" should still trigger it within a
> few seconds) or avoids it completely - I don't see any patterns yet. Using
> (at least) two different mappings for the file, each of which has been
> remapped seem to be a requirement for triggering it.
> 
> Implementing the same mappings using mmap() does not appear to cause any
> problems, but I assume that someone might care about this problem while
> remap_file_pages() is still in the kernel.

This is very good news :)  Thank you so much for going to all this
trouble over it.  If you didn't realize, yours is not the first report
of an mm/filemap.c:202! BUG_ON(page_mapped(page)), but most of them
have happened when using the Trinity fuzzer (known to be fond of tmpfs
and remap_file_pages), and too rare to track down further.

I have several times in recent months eyed the (old) remap_file_pages
code, and the filemap_map_pages code, hoping to find the answer in one
or the other; but had no success.

Kirill, Konstantin, would either of you have a moment to try and track
this down further?  I'd love to, but I am _still_ not finished with the
fallocate hang business, then sealing review, then plenty beyond that.
Ingo's remap-demo.c inline below.

Of course, one option will be just to revert d7c17551; but I'd much
rather track down the bug and fix it, if we can in the next couple of
weeks - even if it does turn out to be in code removed in 3.17.

Thanks!
Hugh

> 
> -ik
> 
> 
> ------------[ cut here ]------------
> kernel BUG at mm/filemap.c:202!
> invalid opcode: 0000 [#1] SMP
> Modules linked in: uinput nfsd auth_rpcgss oid_registry nfs_acl nfs lockd
> fscache sunrpc ext3 jbd loop joydev hid_generic usbhid hid psmouse
> parport_pc ohci_pci ohci_hcd ehci_hcd usbcore ac i2c_piix4 pcspkr
> serio_raw evdev parport battery button processor i2c_core usb_common
> microcode thermal_sys ext4 crc16 jbd2 mbcache sr_mod cdrom sg sd_mod
> crc_t10dif crct10dif_common ata_generic e1000 ahci libahci ata_piix libata
> scsi_mod
> CPU: 3 PID: 2992 Comm: test Not tainted 3.16.0-rc5ik1 #37
> Hardware name: innotek GmbH VirtualBox, BIOS VirtualBox 12/01/2006 task:
> ffff88005a9363d0 ti: ffff880037968000 task.ti: ffff880037968000 RIP:
> 0010:[<ffffffff810db4d3>]  [<ffffffff810db4d3>]
> __delete_from_page_cache+0x16f/0x1f6
> RSP: 0018:ffff88003796bba8  EFLAGS: 00010046
> RAX: 0000000000000000 RBX: ffffea00012ee220 RCX: 00000000ffffffe2
> RDX: 0000000000000018 RSI: 0000000000000018 RDI: ffff88005dbeb700
> RBP: ffff8800378d1c10 R08: ffff88005dbeb700 R09: 0000000000000013
> R10: 0000000000000013 R11: 0000000000000000 R12: 0000000000000000
> R13: 0000000000000003 R14: ffff8800378d1c18 R15: 000000000000000f
> FS:  0000000000000000(0000) GS:ffff88005d980000(0000)
> knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007f69ad38fa30 CR3: 0000000001611000 CR4: 00000000000006e0
> Stack:
>  0000000000000002 000000000000000f ffff880059899008 ffff8800598990a8
> ffff8800378d1c10 ffffea00012ee220 ffff8800378d1c28 0000000000000000
> ffff8800378d1ac0 ffff8800374d0600 0000000000000001 ffffffff810db65b
> Call Trace:
>  [<ffffffff810db65b>] ? delete_from_page_cache+0x32/0x56
>  [<ffffffff810e621d>] ? truncate_inode_page+0x62/0x69
>  [<ffffffff810edf29>] ? shmem_undo_range+0x13f/0x3f3
>  [<ffffffff810df855>] ? get_pfnblock_flags_mask+0x1d/0x4d
>  [<ffffffff810e0bcb>] ? free_hot_cold_page+0x76/0x134
>  [<ffffffff810e528a>] ? release_pages+0x171/0x180
>  [<ffffffff810e4aa2>] ? hpage_nr_pages+0x1b/0x1b
>  [<ffffffff811418df>] ? __inode_wait_for_writeback+0x67/0xae
>  [<ffffffff810ee1e8>] ? shmem_truncate_range+0xb/0x25
>  [<ffffffff810ee76d>] ? shmem_evict_inode+0x4f/0xed
>  [<ffffffff810ee71e>] ? shmem_file_setup+0x7/0x7
>  [<ffffffff81136947>] ? evict+0xa3/0x147
>  [<ffffffff81133576>] ? __dentry_kill+0x103/0x173
>  [<ffffffff81133983>] ? dput+0x133/0x150
>  [<ffffffff8112489d>] ? __fput+0x163/0x184
>  [<ffffffff8105f10c>] ? task_work_run+0x7b/0x8f
>  [<ffffffff81049c69>] ? do_exit+0x3f6/0x904
>  [<ffffffff8104a282>] ? do_group_exit+0x68/0x9a
>  [<ffffffff8104a2c4>] ? SyS_exit_group+0x10/0x10
>  [<ffffffff8138fb69>] ? system_call_fastpath+0x16/0x1b
> Code: be 0a 00 00 00 48 89 df e8 96 5b 01 00 48 8b 03 a9 00 00 08 00 74 0d
> be 18 00 00 00 48 89 df e8 7f 5b 01 00 8b 43 18 85 c0 78 02 <0f> 0b 48 8b
> 03 a8 10 74 6f 48 8b 85 88 00 00 00 f6 40 20 01 75
> RIP  [<ffffffff810db4d3>] __delete_from_page_cache+0x16f/0x1f6
>  RSP <ffff88003796bba8>
> ---[ end trace 79ae5bd27fcedca9 ]---
> Fixing recursive fault but reboot is needed!
> BUG: Bad rss-counter state mm:ffff88005aae60c0 idx:0 val:1

And that "Bad rss-counter" report fits some of the reports too, good.

Here's Ingo's remap-demo.c inline, but I've not tried it:

#define _GNU_SOURCE
#include <sys/mman.h>
#include <sys/resource.h>
#include <errno.h>
#include <limits.h>
#include <malloc.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define PAGE_SIZE 4096
// NOTE: DATA=MAP2=16 seems to trigger in the first few tries
// NOTE: 9/9 needs a loop and a few seconds to trigger
// NOTE: DATA=9, MAP2=8 does not trigger
#define DATA_SIZE 16
#define MAP2_SIZE 16

int shmfd;
char shmpath[] = "/dev/shm/mmaptest-XXXXXX";
unsigned char *map1, *map2;
unsigned int i;

int main(int argc, char *argv[]) {
  /* create a data file on tmpfs */
  shmfd = mkstemp(shmpath);
  if (shmfd < 0) {
    perror("mkstemp");
    exit(2);
  }

  if (unlink(shmpath)) {
    perror("unlink");
    exit(2);
  }

  if (ftruncate(shmfd, DATA_SIZE * PAGE_SIZE)) {
    perror("ftruncate");
    exit(2);
  }

  /* map a single page from the file */
  map1 = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, shmfd, 0);
  if (map1 == MAP_FAILED) {
    perror("mmap 1");
    exit(2);
  }

  /* remap it to another page in the file */
  // NOTE: Does not trigger without remapping
  // NOTE: Does not trigger for 7, but does trigger for 8 if both sizes are 16
  //  (DATA_SIZE-2 is sufficiently generic here)
  if (remap_file_pages(map1, PAGE_SIZE, 0, DATA_SIZE - 2, MAP_SHARED)) {
    perror("remap_file_pages 1");
    exit(2);
  }

  /* create a second mapping */
  map2 = mmap(NULL, MAP2_SIZE * PAGE_SIZE, PROT_READ | PROT_WRITE,
              MAP_SHARED, shmfd, 0);
  if (map2 == MAP_FAILED) {
    perror("mmap 2");
    exit(2);
  }

  /* map all of its pages to page 0 */
  // NOTE: Remapping only the last page does not trigger
  for (i = 0; i < MAP2_SIZE; i++) {
    if (remap_file_pages(map2 + PAGE_SIZE * i, PAGE_SIZE, 0, 0, MAP_SHARED)) {
      perror("remap_file_pages 3");
      exit(2);
    }
  }

  close(shmfd);

  exit(0);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
