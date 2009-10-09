Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E3D246B004D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 04:46:38 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n998kaHZ003292
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 9 Oct 2009 17:46:36 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A90C45DE52
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 17:46:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EC4F045DE51
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 17:46:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CDC241DB803A
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 17:46:35 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EA521DB8041
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 17:46:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] Fix memory leak of never putback pages in mbind()
In-Reply-To: <20091009100708.1287.A69D9226@jp.fujitsu.com>
References: <20091009100527.1284.A69D9226@jp.fujitsu.com> <20091009100708.1287.A69D9226@jp.fujitsu.com>
Message-Id: <20091009174505.12B3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  9 Oct 2009 17:46:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/mempolicy.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 473f888..824abf3 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1061,6 +1061,8 @@ static long do_mbind(unsigned long start, unsigned long len,
>  
>  		if (!err && nr_failed && (flags & MPOL_MF_STRICT))
>  			err = -EIO;
> +	} else {
> +		putback_lru_pages(&pagelist);
>  	}
>  
>  	up_write(&mm->mmap_sem);


Oops, I forgot to remove unnecessary brace.
updated patch is here.

================================================================
Subject: [PATCH] Fix memory leak of never putback pages in mbind()

if mbind() receive invalid address, do_mbind makes leaked page.
following test program detect its leak.

This patch fixes it.

migrate_efault.c
=======================================
 #include <numaif.h>
 #include <numa.h>
 #include <sys/mman.h>
 #include <stdio.h>
 #include <unistd.h>
 #include <stdlib.h>
 #include <string.h>

static unsigned long pagesize;

static void* make_hole_mapping(void)
{

	void* addr;

	addr = mmap(NULL, pagesize*3, PROT_READ|PROT_WRITE,
		    MAP_ANON|MAP_PRIVATE, 0, 0);
	if (addr == MAP_FAILED)
		return NULL;

	/* make page populate */
	memset(addr, 0, pagesize*3);

	/* make memory hole */
	munmap(addr+pagesize, pagesize);

	return addr;
}

int main(int argc, char** argv)
{
	void* addr;
	int ch;
	int node;
	struct bitmask *nmask = numa_allocate_nodemask();
	int err;
	int node_set = 0;

	while ((ch = getopt(argc, argv, "n:")) != -1){
		switch (ch){
		case 'n':
			node = strtol(optarg, NULL, 0);
			numa_bitmask_setbit(nmask, node);
			node_set = 1;
			break;
		default:
			;
		}
	}
	argc -= optind;
	argv += optind;

	if (!node_set)
		numa_bitmask_setbit(nmask, 0);

	pagesize = getpagesize();

	addr = make_hole_mapping();

	err = mbind(addr, pagesize*3, MPOL_BIND, nmask->maskp, nmask->size, MPOL_MF_MOVE_ALL);
	if (err)
		perror("mbind ");

	return 0;
}
=======================================


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mempolicy.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: b/mm/mempolicy.c
===================================================================
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1061,7 +1061,8 @@ static long do_mbind(unsigned long start
 
 		if (!err && nr_failed && (flags & MPOL_MF_STRICT))
 			err = -EIO;
-	}
+	} else
+		putback_lru_pages(&pagelist);
 
 	up_write(&mm->mmap_sem);
 	mpol_put(new);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
