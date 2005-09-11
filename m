Received: from twins ([62.194.129.232]) by amsfep13-int.chello.nl
          (InterMail vM.6.01.04.04 201-2131-118-104-20050224) with ESMTP
          id <20050911230456.MRUM22129.amsfep13-int.chello.nl@twins>
          for <linux-mm@kvack.org>; Mon, 12 Sep 2005 01:04:56 +0200
Subject: Re: [RFC][PATCH 0/7] CART Implementation v3
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20050911202540.581022000@twins>
References: <20050911202540.581022000@twins>
Content-Type: multipart/mixed; boundary="=-aeAcST8wIPN2+02Wp+UA"
Date: Mon, 12 Sep 2005 01:05:00 +0200
Message-Id: <1126479900.20161.185.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-aeAcST8wIPN2+02Wp+UA
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2005-09-11 at 22:25 +0200, a.p.zijlstra@chello.nl wrote:
> Hi All,
> 
> Here my latest efforts on implementing CART, an advanced page replacement 
> policy.
> 
> It seems pretty stable, except for a spurious OOM. However it yet has to
> run on something other than UML.
> 
> A complete CART implementation should be present in cart-cart.patch. 
> The cart-cart-r.patch improves thereon by keeping a 3th adaptive parameter
> which measures the amount of fresh pages (not in |T1| u |T2| u |B1| u |B2|).
> When the amount of fresh pages drops below the number of longterm pages
> we start to reclaim pages that have just been inserted.
> 
> This works very well for a simple looped linear scan larger than the total 
> resident set. Also it doesn't seem to regress normal workloads.
> 

Some numbers. All run in an UML with mem=64M and 128M of swapspace, sync
ubd.

linux-2.6.13-rc7

make -j4

real    107m15.351s
user    24m4.820s
sys     12m16.590s

scan 60 16

real    3m39.432s
user    0m4.990s
sys     0m21.920s

linux-2.6.13-rc7-cart

make -j4 

real    93m18.035s
user    22m44.280s
sys     9m20.220s

scan 60 16

real    1m47.857s
user    0m4.690s
sys     0m11.690s


-- 
Peter Zijlstra <a.p.zijlstra@chello.nl>

--=-aeAcST8wIPN2+02Wp+UA
Content-Disposition: attachment; filename=scan.c
Content-Type: text/x-csrc; name=scan.c; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>

int main(int argc, char **argv)
{
	char *ptr;
	int size = -1;
	int loops = -1;
	if (argc > 1) {
		size = atoi(argv[1]);
	}
	if (argc > 2) {
		loops = atoi(argv[2]);
	}

	if (size < 0) {
		printf("no size specified\n");
		return 0;
	}
	if (loops < 0) {
		printf("no loops specified\n");
		return 0;
	}

	printf("Size: %dMB\n", size);
	printf("Loops: %d\n", loops);
	size *= 1024*1024;

	ptr = (char*)mmap(0, size, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
	if (ptr) {
		for (;loops; --loops) {
			int i;
			for (i=0; i<size; ++i) {
				*(ptr + i) = loops;
			}
			printf(".");
			fflush(stdout);
		}
		printf("\n");
		munmap(ptr, size);
	}
	return 0;
}

--=-aeAcST8wIPN2+02Wp+UA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
