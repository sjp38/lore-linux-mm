Date: Wed, 3 Sep 2008 17:25:02 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH #2.6.27-rc5] mmap: fix petty bug in anonymous shared mmap
 offset handling
In-Reply-To: <48BE9AAB.9070303@kernel.org>
Message-ID: <Pine.LNX.4.64.0809031713250.6250@blonde.site>
References: <48BE9AAB.9070303@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Sep 2008, Tejun Heo wrote:

> Anonymous mappings should ignore offset but shared anonymous mapping
> forgot to clear it and makes the following legit test program trigger
> SIGBUS.
> 
>  #include <sys/mman.h>
>  #include <stdio.h>
>  #include <errno.h>
> 
>  #define PAGE_SIZE	4096
> 
>  int main(void)
>  {
> 	 char *p;
> 	 int i;
> 
> 	 p = mmap(NULL, 2 * PAGE_SIZE, PROT_READ|PROT_WRITE,
> 		  MAP_SHARED|MAP_ANONYMOUS, -1, PAGE_SIZE);
> 	 if (p == MAP_FAILED) {
> 		 perror("mmap");
> 		 return 1;
> 	 }
> 
> 	 for (i = 0; i < 2; i++) {
> 		 printf("page %d\n", i);
> 		 p[i * 4096] = i;
> 	 }
> 	 return 0;
>  }
> 
> Fix it.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Fair enough.  The current behaviour has (almost) never bothered us,
so I'm uncertain if your test is legit, but I can't see any reason
to object to the change.  Particularly since (just out of sight below
the context of your patch) we force pgoff in the MAP_PRIVATE case.

Acked-by: Hugh Dickins <hugh@veritas.com>

> ---
>  mm/mmap.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 339cf5c..e7a5a68 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1030,6 +1030,10 @@ unsigned long do_mmap_pgoff(struct file * file, unsigned long addr,
>  	} else {
>  		switch (flags & MAP_TYPE) {
>  		case MAP_SHARED:
> +			/*
> +			 * Ignore pgoff.
> +			 */
> +			pgoff = 0;
>  			vm_flags |= VM_SHARED | VM_MAYSHARE;
>  			break;
>  		case MAP_PRIVATE:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
