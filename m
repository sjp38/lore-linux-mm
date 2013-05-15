Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 4BCD86B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 05:05:43 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7D30A3EE0AE
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:05:41 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B4EB45DE58
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:05:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CB9C45DE54
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:05:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4172FE08001
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:05:41 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DDAA61DB804B
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:05:40 +0900 (JST)
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Subject: [PATCH v6 0/8] kdump, vmcore: support mmap() on /proc/vmcore
Date: Wed, 15 May 2013 18:05:39 +0900
Message-ID: <20130515090507.28109.28956.stgit@localhost6.localdomain6>
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
times. This causes big performance degradation.

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

This patch set is composed based on v3.10-rc1, tested on x86_64,
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


 fs/proc/vmcore.c        |  539 +++++++++++++++++++++++++++++++++--------------
 include/linux/vmalloc.h |    4 
 mm/vmalloc.c            |   65 ++++--
 3 files changed, 430 insertions(+), 178 deletions(-)

-- 

Thanks.
HATAYAMA, Daisuke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
