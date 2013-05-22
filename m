Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 8FEBE6B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 22:55:35 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5D8553EE0BC
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:55:33 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DE2045DEB7
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:55:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 369F745DEB5
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:55:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 265B41DB803B
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:55:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BFB1A1DB8038
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:55:32 +0900 (JST)
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Subject: [PATCH v7 0/8] kdump, vmcore: support mmap() on /proc/vmcore
Date: Wed, 22 May 2013 11:55:31 +0900
Message-ID: <20130522025410.12215.16793.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vgoyal@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

Currently, read to /proc/vmcore is done by read_oldmem() that uses
ioremap/iounmap per a single page. For example, if memory is 1GB,
ioremap/iounmap is called (1GB / 4KB)-times, that is, 262144
times. This causes big performance degradation due to repeated page
table changes, TLB flush and build-up of VM related objects.

In particular, the current main user of this mmap() is makedumpfile,
which not only reads memory from /proc/vmcore but also does other
processing like filtering, compression and IO work.

To address the issue, this patch implements mmap() on /proc/vmcore to
improve read performance.

Benchmark
=========

You can see two benchmarks on terabyte memory system. Both show about
40 seconds on 2TB system. This is almost equal to performance by
experimental kernel-side memory filtering.

- makedumpfile mmap() benchmark, by Jingbai Ma
  https://lkml.org/lkml/2013/3/27/19

- makedumpfile: benchmark on mmap() with /proc/vmcore on 2TB memory system
  https://lkml.org/lkml/2013/3/26/914

ChangeLog
=========

v6 => v7)

- Rebase 3.10-rc2.
- Move roundup operation to note segment from patch 2/8 to patch 6/8.
- Rewrite get_note_number_and_size_elf{64,32} and
  copy_notes_elf{64,32} in patch 6/8.

v5 => v6)

- Change patch order: clenaup patch => PT_LOAD change patch =>
  vmalloc-related patch => mmap patch.
- Some cleanups: improve symbol names simply, add helper functoins for
  processing ELF note segment and add comments for the helper
  functions.
- Fix patch description of patch 7/8.

v4 => v5)

- Rebase 3.10-rc1.
- Introduce remap_vmalloc_range_partial() in order to remap vmalloc
  memory in a part of vma area.
- Allocate buffer for ELF note segment at 2nd kernel by vmalloc(). Use
  remap_vmalloc_range_partial() to remap the memory to userspace.

v3 => v4)

- Rebase 3.9-rc7.
- Drop clean-up patches orthogonal to the main topic of this patch set.
- Copy ELF note segments in the 2nd kernel just as in v1. Allocate
  vmcore objects per pages. => See [PATCH 5/8]
- Map memory referenced by PT_LOAD entry directly even if the start or
  end of the region doesn't fit inside page boundary, no longer copy
  them as the previous v3. Then, holes, outside OS memory, are visible
  from /proc/vmcore. => See [PATCH 7/8]

v2 => v3)

- Rebase 3.9-rc3.
- Copy program headers separately from e_phoff in ELF note segment
  buffer. Now there's no risk to allocate huge memory if program
  header table positions after memory segment.
- Add cleanup patch that removes unnecessary variable.
- Fix wrongly using the variable that is buffer size configurable at
  runtime. Instead, use the variable that has original buffer size.

v1 => v2)

- Clean up the existing codes: use e_phoff, and remove the assumption
  on PT_NOTE entries.
- Fix potential bug that ELF header size is not included in exported
  vmcoreinfo size.
- Divide patch modifying read_vmcore() into two: clean-up and primary
  code change.
- Put ELF note segments in page-size boundary on the 1st kernel
  instead of copying them into the buffer on the 2nd kernel.

Test
====

This patch set is composed based on v3.10-rc2, tested on x86_64,
x86_32 both with 1GB and with 5GB (over 4GB) memory configurations.

---

HATAYAMA Daisuke (8):
      vmcore: support mmap() on /proc/vmcore
      vmcore: calculate vmcore file size from buffer size and total size of vmcore objects
      vmcore: allocate ELF note segment in the 2nd kernel vmalloc memory
      vmalloc: introduce remap_vmalloc_range_partial
      vmalloc: make find_vm_area check in range
      vmcore: treat memory chunks referenced by PT_LOAD program header entries in page-size boundary in vmcore_list
      vmcore: allocate buffer for ELF headers on page-size alignment
      vmcore: clean up read_vmcore()


 fs/proc/vmcore.c        |  595 +++++++++++++++++++++++++++++++++++------------
 include/linux/vmalloc.h |    4 
 mm/vmalloc.c            |   65 ++++-
 3 files changed, 494 insertions(+), 170 deletions(-)

-- 

Thanks.
HATAYAMA, Daisuke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
