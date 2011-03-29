Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F0A0D8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 20:03:04 -0400 (EDT)
Date: Mon, 28 Mar 2011 17:02:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ramfs: fix memleak on no-mmu arch
Message-Id: <20110328170220.fc61fb5c.akpm@linux-foundation.org>
In-Reply-To: <1301290355-8980-1-git-send-email-lliubbo@gmail.com>
References: <1301290355-8980-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, viro@zeniv.linux.org.uk, hch@lst.de, npiggin@kernel.dk, tj@kernel.org, dhowells@redhat.com, lethal@linux-sh.org, magnus.damm@gmail.com

On Mon, 28 Mar 2011 13:32:35 +0800
Bob Liu <lliubbo@gmail.com> wrote:

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
> ...
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

Something is still wrong here.

A live, in-use page should have a refcount of three.  One for the
existence of the page, one for its presence on the page LRU and one for
its existence in the pagecache radix tree.

So allocation should do:

	alloc_pages()
	add_to_page_cache()
	add_to_lru()

and deallocation should do

	remove_from_lru()
	remove_from_page_cache()
	put_page()

If this protocol is followed correctly, there is no need to do a
put_page() during the allocation/setup phase!

I suspect that the problem in nommu really lies in the
deallocation/teardown phase.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
