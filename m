Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id B96106B004F
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 11:58:49 -0500 (EST)
Received: by qao25 with SMTP id 25so2735814qao.14
        for <linux-mm@kvack.org>; Fri, 09 Dec 2011 08:58:48 -0800 (PST)
From: kosaki.motohiro@gmail.com
Subject: [PATCH] mempolicy: refix mbind_range() vma issue
Date: Fri,  9 Dec 2011 11:55:09 -0500
Message-Id: <1323449709-25923-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Caspar Zhang <caspar@casparzhang.com>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

commit 8aacc9f550 (mm/mempolicy.c: fix pgoff in mbind vma merge) is
slightly incorrect fix. It doesn't handle vma merge case 4 (see
mmap.c#vma_merge() source comment).

This patch fixes it.

testcase:  mbind_vma_test.c
=====================================================
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

	nmask = numa_allocate_nodemask();
	numa_bitmask_setbit(nmask, 0);

	pagesize = getpagesize();

	addr = mmap(NULL, pagesize*8, PROT_NONE,
		    MAP_ANON|MAP_PRIVATE, 0, 0);
	if (addr == MAP_FAILED)
		perror("mmap "), exit(1);

	if (mmap(addr+pagesize, pagesize*6, PROT_READ|PROT_WRITE,
		 MAP_ANON|MAP_PRIVATE|MAP_FIXED, 0, 0) == MAP_FAILED)
		perror("mmap "), exit(1);

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

int main(int argc, char** argv)
{
	case4();
	case5();
	case6();
	case7();
	case8();

	return 0;
}
=============================================================

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
CC: Caspar Zhang <caspar@casparzhang.com>
---
 mm/mempolicy.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index adc3954..fd07eae 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -636,6 +636,7 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 	struct vm_area_struct *prev;
 	struct vm_area_struct *vma;
 	int err = 0;
+	pgoff_t pgoff;
 	unsigned long vmstart;
 	unsigned long vmend;
 
@@ -643,13 +644,17 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 	if (!vma || vma->vm_start > start)
 		return -EFAULT;
 
+	if (start > vma->vm_start)
+		prev = vma;
+
 	for (; vma && vma->vm_start < end; prev = vma, vma = next) {
 		next = vma->vm_next;
 		vmstart = max(start, vma->vm_start);
 		vmend   = min(end, vma->vm_end);
 
+		pgoff = vma->vm_pgoff + ((vmstart - vma->vm_start) >> PAGE_SHIFT);
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
