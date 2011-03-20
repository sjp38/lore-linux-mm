Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 220128D0039
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 16:36:12 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p2KKa6aU029387
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 13:36:09 -0700
Received: from pwi3 (pwi3.prod.google.com [10.241.219.3])
	by kpbe20.cbf.corp.google.com with ESMTP id p2KKa1a5000653
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 13:36:04 -0700
Received: by pwi3 with SMTP id 3so637359pwi.9
        for <linux-mm@kvack.org>; Sun, 20 Mar 2011 13:36:01 -0700 (PDT)
Date: Sun, 20 Mar 2011 13:35:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [BUG?] shmem: memory leak on NO-MMU arch
In-Reply-To: <1299575863-7069-1-git-send-email-lliubbo@gmail.com>
Message-ID: <alpine.LSU.2.00.1103201258280.3776@sister.anvils>
References: <1299575863-7069-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, hch@lst.de, npiggin@kernel.dk, tj@kernel.org, David Howells <dhowells@redhat.com>, Paul Mundt <lethal@linux-sh.org>, Magnus Damm <magnus.damm@gmail.com>

On Tue, 8 Mar 2011, Bob Liu wrote:
> Hi, folks

Of course I agree with Al and Andrew about your other patch,
I don't know of any shmem inode leak in the MMU case.

I'm afraid we MM folks tend to be very ignorant of the NOMMU case.
I've sometimes wished we had a NOMMU variant of the x86 architecture,
that we could at least build and test changes on.

Let's Cc David, Paul and Magnus: they do understand NOMMU.

> 
> I got a problem about shmem on NO-MMU arch, it seems memory leak
> happened.
> 
> A simple test file is like this:
> =========
> #include <stdio.h>
> #include <stdlib.h>
> #include <sys/types.h>
> #include <sys/ipc.h>
> #include <sys/shm.h>
> #include <errno.h>
> #include <string.h>
> 
> int main(void)
> {
> 	int i;
> 	key_t k = ftok("/etc", 42);
> 
> 	for ( i=0; i<2; ++i) {
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
> The test results:
> root:/> free 
>               total         used         free       shared      buffers
>   Mem:        60528        13876        46652            0            0
> root:/> ./shmem 
> run ok...
> root:/> free 
>               total         used         free       shared      buffers
>   Mem:        60528        15104        45424            0            0
> root:/> ./shmem 
> run ok...
> root:/> free 
>               total         used         free       shared      buffers
>   Mem:        60528        16292        44236            0            0
> root:/> ./shmem 
> run ok...
> root:/> free 
>               total         used         free       shared      buffers
>   Mem:        60528        17496        43032            0            0
> root:/> ./shmem 
> run ok...
> root:/> free 
>               total         used         free       shared      buffers
>   Mem:        60528        18700        41828            0            0
> root:/> ./shmem 
> run ok...
> root:/> free 
>               total         used         free       shared      buffers
>   Mem:        60528        19904        40624            0            0
> root:/> ./shmem 
> run ok...
> root:/> free 
>               total         used         free       shared      buffers
>   Mem:        60528        21104        39424            0            0
> root:/>
> 
> It seems the shmem didn't free it's memory after using shmctl(IPC_RMID) to rm
> it.

There does indeed appear to be a leak there.  But I'm feeling very
stupid, the leak of ~1200kB per run looks a lot more than the ~20kB
that each run of your test program would lose if the bug is as you say.
Maybe I can't count today.

> =========
> 
> Patch below can work, but I know it's too simple and may cause other problems.
> Any ideas is welcome.
> 
> Thanks!
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

I don't think any patch with a global ramfs_pages, ignoring the
inode in question, can possibly work beyond the simplest of cases.

Yet it does look to me that you're right that ramfs_nommu_expand_for_mapping
forgets to release a reference to its pages; though it's hard to believe
that could go unnoticed for so long - more likely we're both overlooking
something.

> ---
> diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
> index 9eead2c..831e6d5 100644
> --- a/fs/ramfs/file-nommu.c
> +++ b/fs/ramfs/file-nommu.c
> @@ -59,6 +59,8 @@ const struct inode_operations ramfs_file_inode_operations = {
>   * size 0 on the assumption that it's going to be used for an mmap of shared
>   * memory
>   */
> +struct page *ramfs_pages;
> +unsigned long ramfs_nr_pages;
>  int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize)
>  {
>  	unsigned long npages, xpages, loop;
> @@ -114,6 +116,8 @@ int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize)
>  		unlock_page(page);
>  	}
>  
> +	ramfs_pages = pages;
> +	ramfs_nr_pages = loop;
>  	return 0;
>  
>  add_error:
> diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
> index eacb166..2eb33e5 100644
> --- a/fs/ramfs/inode.c
> +++ b/fs/ramfs/inode.c
> @@ -139,6 +139,23 @@ static int ramfs_symlink(struct inode * dir, struct dentry *dentry, const char *
>  	return error;
>  }
>  
> +static void ramfs_delete_inode(struct inode *inode)
> +{
> +	int loop;
> +	struct page *page;
> +
> +	truncate_inode_pages(&inode->i_data, 0);
> +	clear_inode(inode);
> +
> +	for (loop = 0; loop < ramfs_nr_pages; loop++ ){
> +		page = ramfs_pages[loop];
> +		page->flags &= ~PAGE_FLAGS_CHECK_AT_FREE;
> +		if(page)
> +			__free_pages(page, 0);
> +	}
> +	kfree(ramfs_pages);
> +}
> +
>  static const struct inode_operations ramfs_dir_inode_operations = {
>  	.create		= ramfs_create,
>  	.lookup		= simple_lookup,
> @@ -153,6 +170,7 @@ static const struct inode_operations ramfs_dir_inode_operations = {
>  
>  static const struct super_operations ramfs_ops = {
>  	.statfs		= simple_statfs,
> +	.delete_inode   = ramfs_delete_inode,
>  	.drop_inode	= generic_delete_inode,
>  	.show_options	= generic_show_options,
>  };
> diff --git a/fs/ramfs/internal.h b/fs/ramfs/internal.h
> index 6b33063..0b7b222 100644
> --- a/fs/ramfs/internal.h
> +++ b/fs/ramfs/internal.h
> @@ -12,3 +12,5 @@
>  
>  extern const struct address_space_operations ramfs_aops;
>  extern const struct inode_operations ramfs_file_inode_operations;
> +extern struct page *ramfs_pages;
> +extern unsigned long ramfs_nr_pages;
> -- 
> 1.6.3.3

Here's my own suggestion for a patch; but I've not even tried to
compile it, let alone test it, so I'm certainly not signing it.

Hugh
---

 fs/ramfs/file-nommu.c |   19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

--- 2.6.38/fs/ramfs/file-nommu.c	2010-10-20 13:30:22.000000000 -0700
+++ linux/fs/ramfs/file-nommu.c	2011-03-20 12:55:35.000000000 -0700
@@ -90,23 +90,19 @@ int ramfs_nommu_expand_for_mapping(struc
 
 	split_page(pages, order);
 
-	/* trim off any pages we don't actually require */
-	for (loop = npages; loop < xpages; loop++)
-		__free_page(pages + loop);
-
 	/* clear the memory we allocated */
 	newsize = PAGE_SIZE * npages;
 	data = page_address(pages);
 	memset(data, 0, newsize);
 
-	/* attach all the pages to the inode's address space */
+	/* attach the pages we require to the inode's address space */
 	for (loop = 0; loop < npages; loop++) {
 		struct page *page = pages + loop;
 
 		ret = add_to_page_cache_lru(page, inode->i_mapping, loop,
 					GFP_KERNEL);
 		if (ret < 0)
-			goto add_error;
+			break;
 
 		/* prevent the page from being discarded on memory pressure */
 		SetPageDirty(page);
@@ -114,11 +110,14 @@ int ramfs_nommu_expand_for_mapping(struc
 		unlock_page(page);
 	}
 
-	return 0;
+	/*
+	 * release our reference to the pages now added to cache,
+	 * and trim off any pages we don't actually require.
+	 * truncate inode back to 0 if not all pages could be added??
+	 */
+	for (loop = 0; loop < xpages; loop++)
+		put_page(pages + loop);
 
-add_error:
-	while (loop < npages)
-		__free_page(pages + loop++);
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
