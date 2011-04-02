Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 26B348D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 22:52:52 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p322qkDe012869
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 19:52:48 -0700
Received: from iym7 (iym7.prod.google.com [10.241.52.7])
	by kpbe19.cbf.corp.google.com with ESMTP id p322q7Lc018153
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 19:52:45 -0700
Received: by iym7 with SMTP id 7so5223238iym.24
        for <linux-mm@kvack.org>; Fri, 01 Apr 2011 19:52:44 -0700 (PDT)
Date: Fri, 1 Apr 2011 19:52:37 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] ramfs: fix memleak on no-mmu arch
In-Reply-To: <1301290355-8980-1-git-send-email-lliubbo@gmail.com>
Message-ID: <alpine.LSU.2.00.1104011929090.3340@sister.anvils>
References: <1301290355-8980-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, hughd@google.com, viro@zeniv.linux.org.uk, hch@lst.de, npiggin@kernel.dk, tj@kernel.org, dhowells@redhat.com, lethal@linux-sh.org, magnus.damm@gmail.com

On Mon, 28 Mar 2011, Bob Liu wrote:
> On no-mmu arch, there is a memleak duirng shmem test.
> The cause of this memleak is ramfs_nommu_expand_for_mapping() added page
> refcount to 2 which makes iput() can't free that pages.
> 
> The simple test file is like this:
> int main(void)
> {
> 	int i;
> 	key_t k = ftok("/etc", 42);
> 
> 	for ( i=0; i<100; ++i) {
> 		int id = shmget(k, 10000, 0644|IPC_CREAT);
> 		if (id == -1) {
> 			printf("shmget error\n");
> 		}
> 		if(shmctl(id, IPC_RMID, NULL ) == -1) {
> 			printf("shm  rm error\n");
> 			return -1;
> 		}
> 	}
> 	printf("run ok...\n");
> 	return 0;
> }
> 
> And the result:
> root:/> free
>              total         used         free       shared      buffers
> Mem:         60320        16644        43676            0            0
> -/+ buffers:              16644        43676
> root:/> shmem
> run ok...
> root:/> free
>              total         used         free       shared      buffers
> Mem:         60320        17912        42408            0            0
> -/+ buffers:              17912        42408
> root:/> shmem
> run ok...
> root:/> free
>              total         used         free       shared      buffers
> Mem:         60320        19096        41224            0            0
> -/+ buffers:              19096        41224
> root:/> shmem
> run ok...
> root:/> free
>              total         used         free       shared      buffers
> Mem:         60320        20296        40024            0            0
> -/+ buffers:              20296        40024
> root:/> shmem
> run ok...
> root:/> free
>              total         used         free       shared      buffers
> Mem:         60320        21496        38824            0            0
> -/+ buffers:              21496        38824
> root:/> shmem 
> run ok...
> root:/> free
>              total         used         free       shared      buffers
> Mem:         60320        22692        37628            0            0
> -/+ buffers:              22692        37628
> root:/> 
> 
> After this patch the test result is:(no memleak anymore)
> root:/> 
> root:/> free
>              total         used         free       shared      buffers
> Mem:         60320        16580        43740            0            0
> -/+ buffers:              16580        43740
> root:/> shmem
> run ok...
> root:/> free
>              total         used         free       shared      buffers
> Mem:         60320        16668        43652            0            0
> -/+ buffers:              16668        43652
> root:/> shmem
> run ok...
> root:/> free
>              total         used         free       shared      buffers
> Mem:         60320        16668        43652            0            0
> -/+ buffers:              16668        43652
> root:/> shmem
> run ok...
> root:/> free
>              total         used         free       shared      buffers
> Mem:         60320        16668        43652            0            0
> -/+ buffers:              16668        43652
> root:/> shmem
> run ok...
> root:/> free
>              total         used         free       shared      buffers
> Mem:         60320        16668        43652            0            0
> -/+ buffers:              16668        43652
> root:/> shmem
> run ok...
> root:/> free
>              total         used         free       shared      buffers
> Mem:         60320        16668        43652            0            0
> -/+ buffers:              16668        43652
> root:/> 
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Acked-by: Hugh Dickins <hughd@google.com>
Cc: stable@kernel.org

Sorry for being so slow to get back to this, Bob.

And I'm sorry that in my original patch for it, I just couldn't
resist a little tidying up while I was there: which led Paul to
observe correctly that the function would be better off using
alloc_pages_exact(); which made me pause before responding,
seeing a proposal to rename that to get_free_pages_exact().

Aaaaaah, let's go with your patch below, which fixes the bug in
the simplest fashion; and do any tidying up at leisure later on.

I see Andrew is questioning the correctness of this patch:
let me answer his mail separately.

Hugh

> ---
>  fs/ramfs/file-nommu.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
> index 9eead2c..fbb0b47 100644
> --- a/fs/ramfs/file-nommu.c
> +++ b/fs/ramfs/file-nommu.c
> @@ -112,6 +112,7 @@ int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize)
>  		SetPageDirty(page);
>  
>  		unlock_page(page);
> +		put_page(page);
>  	}
>  
>  	return 0;
> -- 
> 1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
