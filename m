Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id D08456B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 13:17:29 -0500 (EST)
Received: by qabg40 with SMTP id g40so1849286qab.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 10:17:28 -0800 (PST)
From: kosaki.motohiro@gmail.com
Subject: [PATCH] [v2] mempolicy: refix mbind_range() vma issue
Date: Tue, 20 Dec 2011 13:17:10 -0500
Message-Id: <1324405032-22281-1-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <20111212112000.GB18789@cmpxchg.org>
References: <20111212112000.GB18789@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Caspar Zhang <caspar@casparzhang.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Wilson <wilsons@start.ca>, Andrea Arcangeli <aarcange@redhat.com>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

commit 8aacc9f550 (mm/mempolicy.c: fix pgoff in mbind vma merge) is
slightly incorrect fix.

Why? Think following case.

1. map 4 pages of a file at offset 0

   [0123]

2. map 2 pages just after the first mapping of the same file but with
   page offset 2

   [0123][23]

3. mbind() 2 pages from the first mapping at offset 2.
   mbind_range() should treat new vma is,

   [0123][23]
     |23|
     mbind vma

   but it does

   [0123][23]
     |01|
     mbind vma

   Oops. then, it makes wrong vma merge and splitting ([01][0123] or similar).

This patch fixes it.

[testcase]
  test result - before the patch

	case4: 126: test failed. expect '2,4', actual '2,2,2'
       	case5: passed
	case6: passed
	case7: passed
	case8: passed
	case_n: 246: test failed. expect '4,2', actual '1,4'

	------------[ cut here ]------------
	kernel BUG at mm/filemap.c:135!
	invalid opcode: 0000 [#4] SMP DEBUG_PAGEALLOC

	(snip long bug on messages)

  test result - after the patch

	case4: passed
       	case5: passed
	case6: passed
	case7: passed
	case8: passed
	case_n: passed

  source:  mbind_vma_test.c
============================================================
 #include <numaif.h>
 #include <numa.h>
 #include <sys/mman.h>
 #include <stdio.h>
 #include <unistd.h>
 #include <stdlib.h>
 #include <string.h>

static unsigned long pagesize;
void* mmap_addr;
struct bitmask *nmask;
char buf[1024];
FILE *file;
char retbuf[10240] = "";
int mapped_fd;

char *rubysrc = "ruby -e '\
  pid = %d; \
  vstart = 0x%llx; \
  vend = 0x%llx; \
  s = `pmap -q #{pid}`; \
  rary = []; \
  s.each_line {|line|; \
    ary=line.split(\" \"); \
    addr = ary[0].to_i(16); \
    if(vstart <= addr && addr < vend) then \
      rary.push(ary[1].to_i()/4); \
    end; \
  }; \
  print rary.join(\",\"); \
'";

void init(void)
{
	void* addr;
	char buf[128];

	nmask = numa_allocate_nodemask();
	numa_bitmask_setbit(nmask, 0);

	pagesize = getpagesize();

	sprintf(buf, "%s", "mbind_vma_XXXXXX");
	mapped_fd = mkstemp(buf);
	if (mapped_fd == -1)
		perror("mkstemp "), exit(1);
	unlink(buf);

	if (lseek(mapped_fd, pagesize*8, SEEK_SET) < 0)
		perror("lseek "), exit(1);
	if (write(mapped_fd, "\0", 1) < 0)
		perror("write "), exit(1);

	addr = mmap(NULL, pagesize*8, PROT_NONE,
		    MAP_SHARED, mapped_fd, 0);
	if (addr == MAP_FAILED)
		perror("mmap "), exit(1);

	if (mprotect(addr+pagesize, pagesize*6, PROT_READ|PROT_WRITE) < 0)
		perror("mprotect "), exit(1);

	mmap_addr = addr + pagesize;

	/* make page populate */
	memset(mmap_addr, 0, pagesize*6);
}

void fin(void)
{
	void* addr = mmap_addr - pagesize;
	munmap(addr, pagesize*8);

	memset(buf, 0, sizeof(buf));
	memset(retbuf, 0, sizeof(retbuf));
}

void mem_bind(int index, int len)
{
	int err;

	err = mbind(mmap_addr+pagesize*index, pagesize*len,
		    MPOL_BIND, nmask->maskp, nmask->size, 0);
	if (err)
		perror("mbind "), exit(err);
}

void mem_interleave(int index, int len)
{
	int err;

	err = mbind(mmap_addr+pagesize*index, pagesize*len,
		    MPOL_INTERLEAVE, nmask->maskp, nmask->size, 0);
	if (err)
		perror("mbind "), exit(err);
}

void mem_unbind(int index, int len)
{
	int err;

	err = mbind(mmap_addr+pagesize*index, pagesize*len,
		    MPOL_DEFAULT, NULL, 0, 0);
	if (err)
		perror("mbind "), exit(err);
}

void Assert(char *expected, char *value, char *name, int line)
{
	if (strcmp(expected, value) == 0) {
		fprintf(stderr, "%s: passed\n", name);
		return;
	}
	else {
		fprintf(stderr, "%s: %d: test failed. expect '%s', actual '%s'\n",
			name, line,
			expected, value);
//		exit(1);
	}
}

/*
      AAAA
    PPPPPPNNNNNN
    might become
    PPNNNNNNNNNN
    case 4 below
*/
void case4(void)
{
	init();
	sprintf(buf, rubysrc, getpid(), mmap_addr, mmap_addr+pagesize*6);

	mem_bind(0, 4);
	mem_unbind(2, 2);

	file = popen(buf, "r");
	fread(retbuf, sizeof(retbuf), 1, file);
	Assert("2,4", retbuf, "case4", __LINE__);

	fin();
}

/*
       AAAA
 PPPPPPNNNNNN
 might become
 PPPPPPPPPPNN
 case 5 below
*/
void case5(void)
{
	init();
	sprintf(buf, rubysrc, getpid(), mmap_addr, mmap_addr+pagesize*6);

	mem_bind(0, 2);
	mem_bind(2, 2);

	file = popen(buf, "r");
	fread(retbuf, sizeof(retbuf), 1, file);
	Assert("4,2", retbuf, "case5", __LINE__);

	fin();
}

/*
	    AAAA
	PPPPNNNNXXXX
	might become
	PPPPPPPPPPPP 6
*/
void case6(void)
{
	init();
	sprintf(buf, rubysrc, getpid(), mmap_addr, mmap_addr+pagesize*6);

	mem_bind(0, 2);
	mem_bind(4, 2);
	mem_bind(2, 2);

	file = popen(buf, "r");
	fread(retbuf, sizeof(retbuf), 1, file);
	Assert("6", retbuf, "case6", __LINE__);

	fin();
}

/*
    AAAA
PPPPNNNNXXXX
might become
PPPPPPPPXXXX 7
*/
void case7(void)
{
	init();
	sprintf(buf, rubysrc, getpid(), mmap_addr, mmap_addr+pagesize*6);

	mem_bind(0, 2);
	mem_interleave(4, 2);
	mem_bind(2, 2);

	file = popen(buf, "r");
	fread(retbuf, sizeof(retbuf), 1, file);
	Assert("4,2", retbuf, "case7", __LINE__);

	fin();
}

/*
    AAAA
PPPPNNNNXXXX
might become
PPPPNNNNNNNN 8
*/
void case8(void)
{
	init();
	sprintf(buf, rubysrc, getpid(), mmap_addr, mmap_addr+pagesize*6);

	mem_bind(0, 2);
	mem_interleave(4, 2);
	mem_interleave(2, 2);

	file = popen(buf, "r");
	fread(retbuf, sizeof(retbuf), 1, file);
	Assert("2,4", retbuf, "case8", __LINE__);

	fin();
}

void case_n(void)
{
	init();
	sprintf(buf, rubysrc, getpid(), mmap_addr, mmap_addr+pagesize*6);

	/* make redundunt mappings [0][1234][34][7] */
	mmap(mmap_addr + pagesize*4, pagesize*2, PROT_READ|PROT_WRITE,
	     MAP_FIXED|MAP_SHARED, mapped_fd, pagesize*3);

	/* Expect to do nothing. */
	mem_unbind(2, 2);

	file = popen(buf, "r");
	fread(retbuf, sizeof(retbuf), 1, file);
	Assert("4,2", retbuf, "case_n", __LINE__);

	fin();
}

int main(int argc, char** argv)
{
	case4();
	case5();
	case6();
	case7();
	case8();
	case_n();

	return 0;
}
=============================================================

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Caspar Zhang <caspar@casparzhang.com>
---
 mm/mempolicy.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)


changed from v1:
 - added mpol_equal() check.
 - added an explanation of why current upstream code is broken.
 - added one testcase to reproduce Hannes says.

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index adc3954..c3fdbcb 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -636,6 +636,7 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 	struct vm_area_struct *prev;
 	struct vm_area_struct *vma;
 	int err = 0;
+	pgoff_t pgoff;
 	unsigned long vmstart;
 	unsigned long vmend;
 
@@ -643,13 +644,21 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 	if (!vma || vma->vm_start > start)
 		return -EFAULT;
 
+	if (start > vma->vm_start)
+		prev = vma;
+
 	for (; vma && vma->vm_start < end; prev = vma, vma = next) {
 		next = vma->vm_next;
 		vmstart = max(start, vma->vm_start);
 		vmend   = min(end, vma->vm_end);
 
+		if (mpol_equal(vma_policy(vma), new_pol))
+			continue;
+
+		pgoff = vma->vm_pgoff +
+			((vmstart - vma->vm_start) >> PAGE_SHIFT);
 		prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
-				  vma->anon_vma, vma->vm_file, vma->vm_pgoff,
+				  vma->anon_vma, vma->vm_file, pgoff,
 				  new_pol);
 		if (prev) {
 			vma = prev;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
