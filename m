Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 66B4E6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 02:13:44 -0400 (EDT)
From: "Hampson, Steven T" <steven.t.hampson@intel.com>
Subject: [PATCH} mm: Merging memory blocks resets mempolicy
Date: Mon, 18 Mar 2013 06:13:42 +0000
Message-ID: <CD6BFEA8.10FFB%steven.t.hampson@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <ECDE31AD55DC0B49A208414B031BB417@intel.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

Using mbind to change the mempolicy to MPOL_BIND on several adjacent
mmapped blocks
may result in a reset of the mempolicy to MPOL_DEFAULT in vma_adjust.

Test code.  Correct result is three lines containing "OK".


#include <stdio.h>
#include <unistd.h>
#include <sys/mman.h>
#include <numaif.h>
#include <errno.h>

/* gcc mbind_test.c -lnuma -o mbind_test -Wall */
#define MAXNODE 4096

void allocate()
{
	int ret;
	int len;
	int policy =3D -1;
	unsigned char *p;
	unsigned long mask[MAXNODE] =3D { 0 };
	unsigned long retmask[MAXNODE] =3D { 0 };

	len =3D getpagesize() * 0x2fc00;
	p =3D mmap(NULL, len, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
		 -1, 0);
	if (p =3D=3D MAP_FAILED)
		printf("mbind err: %d\n", errno);

	mask[0] =3D 1;
	ret =3D mbind(p, len, MPOL_BIND, mask, MAXNODE, 0);
	if (ret < 0)
		printf("mbind err: %d %d\n", ret, errno);
	ret =3D get_mempolicy(&policy, retmask, MAXNODE, p, MPOL_F_ADDR);
	if (ret < 0)
		printf("get_mempolicy err: %d %d\n", ret, errno);

	if (policy =3D=3D MPOL_BIND)
		printf("OK\n");
	else
		printf("ERROR: policy is %d\n", policy);
}

int main()
{
	allocate();
	allocate();
	allocate();
	return 0;
}

Signed-off-by: Steven T Hampson <steven.t.hampson@intel.com>


---

diff --git a/mm/mmap.c b/mm/mmap.c
index 8832b87..5ba8b92 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -820,7 +820,7 @@ again:			remove_next =3D 1 + (end > next->vm_end);
 		if (next->anon_vma)
 			anon_vma_merge(vma, next);
 		mm->map_count--;
-		mpol_put(vma_policy(next));
+		vma_set_policy(vma, vma_policy(next));
 		kmem_cache_free(vm_area_cachep, next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
