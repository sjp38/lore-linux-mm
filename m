Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id CE8C26B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 02:19:58 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so4943083pdj.22
        for <linux-mm@kvack.org>; Sun, 15 Dec 2013 23:19:58 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id cz3si8077986pbc.123.2013.12.15.23.19.56
        for <linux-mm@kvack.org>;
        Sun, 15 Dec 2013 23:19:57 -0800 (PST)
Date: Sun, 15 Dec 2013 23:21:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] vfs: don't fallback to buffered read if the offset
 of dio read is beyond eof
Message-Id: <20131215232132.194f406f.akpm@linux-foundation.org>
In-Reply-To: <1385022854-2683-1-git-send-email-wenqing.lz@taobao.com>
References: <1385022854-2683-1-git-send-email-wenqing.lz@taobao.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zheng Liu <gnehzuil.liu@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Zheng Liu <wenqing.lz@taobao.com>, linux-mm@kvack.org

(cc linux-mm)

It would be good if we could get some more eyes onto this please.

On Thu, 21 Nov 2013 16:34:14 +0800 Zheng Liu <gnehzuil.liu@gmail.com> wrote:

> From: Zheng Liu <wenqing.lz@taobao.com>
> 
> Currently when we issue a dio read at a given offset that is beyond the
> end of file we will fallback to buffered read.  Then we check i_size in
> buffered read path after we know the page is updated.  But it could
> return some zero-filled pages to the userspace when we do some append
> dio writes.  We could use the following code snippet to reproduce this
> problem in a ext2/3/4 filesystem.
> 
> code snippet:
>   #define _GNU_SOURCE
> 
>   #include <stdio.h>
>   #include <stdlib.h>
>   #include <string.h>
>   #include <memory.h>
> 
>   #include <unistd.h>
>   #include <fcntl.h>
>   #include <sys/types.h>
>   #include <sys/stat.h>
>   #include <errno.h>
> 
>   #include <pthread.h>
> 
>   #define BUF_ALIGN	1024
> 
>   struct writer_data {
>   	int fd;
>   	size_t blksize;
>   	char *buf;
>   };
> 
>   static void *writer(void *arg)
>   {
>   	struct writer_data *data = (struct writer_data *)arg;
>   	int ret;
> 
>   	ret = write(data->fd, data->buf, data->blksize);
>   	if (ret < 0)
>   		fprintf(stderr, "write file failed: %s\n", strerror(errno));
> 
>   	return NULL;
>   }
> 
>   int main(int argc, char *argv[])
>   {
>   	pthread_t tid;
>   	struct writer_data wdata;
>   	size_t max_blocks = 10 * 1024;
>   	size_t blksize = 1 * 1024 * 1024;
>   	char *rbuf, *wbuf;
>   	int readfd, writefd;
>   	int i, j;
> 
>   	if (argc < 2) {
>   		fprintf(stderr, "usage: %s [filename]\n", argv[0]);
>   		exit(1);
>   	}
> 
>   	writefd = open(argv[1], O_CREAT|O_DIRECT|O_WRONLY|O_APPEND|O_TRUNC, S_IRWXU);
>   	if (writefd < 0) {
>   		fprintf(stderr, "failed to open wfile: %s\n", strerror(errno));
>   		exit(1);
>   	}
>   	readfd = open(argv[1], O_DIRECT|O_RDONLY, S_IRWXU);
>   	if (readfd < 0) {
>   		fprintf(stderr, "failed to open rfile: %s\n", strerror(errno));
>   		exit(1);
>   	}
> 
>   	if (posix_memalign((void **)&wbuf, BUF_ALIGN, blksize)) {
>   		fprintf(stderr, "failed to alloc memory: %s\n", strerror(errno));
>   		exit(1);
>   	}
> 
>   	if (posix_memalign((void **)&rbuf, 4096, blksize)) {
>   		fprintf(stderr, "failed to alloc memory: %s\n", strerror(errno));
>   		exit(1);
>   	}
> 
>   	memset(wbuf, 'a', blksize);
> 
>   	wdata.fd = writefd;
>   	wdata.blksize = blksize;
>   	wdata.buf = wbuf;
> 
>   	for (i = 0; i < max_blocks; i++) {
>   		void *retval;
>   		int ret;
> 
>   		ret = pthread_create(&tid, NULL, writer, &wdata);
>   		if (ret) {
>   			fprintf(stderr, "create thread failed: %s\n", strerror(errno));
>   			exit(1);
>   		}
> 
>   		memset(rbuf, 'b', blksize);
>   		do {
>   			ret = pread(readfd, rbuf, blksize, i * blksize);
>   		} while (ret <= 0);
> 
>   		if (ret < 0) {
>   			fprintf(stderr, "read file failed: %s\n", strerror(errno));
>   			exit(1);
>   		}
> 
>   		if (pthread_join(tid, &retval)) {
>   			fprintf(stderr, "pthread join failed: %s\n", strerror(errno));
>   			exit(1);
>   		}
> 
>   		if (ret >= 0) {
>   			for (j = 0; j < ret; j++) {
>   				if (rbuf[j] != 'a') {
>   					fprintf(stderr, "encounter an error: offset %ld\n",
>   						i);
>   					goto err;
>   				}
>   			}
>   		}
>   	}
> 
>   err:
>   	free(wbuf);
>   	free(rbuf);
> 
>   	return 0;
>   }
> 
> build & run:
>   $ gcc code.c -o code -lpthread # build
>   $ ./code ${filename} # run
> 
> As we expected, we should read nothing or data with 'a'.  But now we
> read data with '0'.  I take a closer look at the code and it seems that
> there is a bug in vfs.  Let me describe my found here.
> 
>   reader					writer
>                                                 generic_file_aio_write()
>                                                 ->__generic_file_aio_write()
>                                                   ->generic_file_direct_write()
>   generic_file_aio_read()
>   ->do_generic_file_read()
>     [fallback to buffered read]
> 
>     ->find_get_page()
>     ->page_cache_sync_readahead()
>     ->find_get_page()
>     [in find_page label, we couldn't find a
>      page before and after calling
>      page_cache_sync_readahead().  So go to
>      no_cached_page label]

It's odd that do_generic_file_read() is permitting a "read" outside
i_size.  Perhaps we should be checking for this in the `no_cached_page'
block.

>     ->page_cache_alloc_cold()
>     ->add_to_page_cache_lru()
>     [in no_cached_page label, we alloc a page
>      and goto readpage label.]
> 
>     ->aops->readpage()
>     [in readpage label, readpage() callback
>      is called and mpage_readpage() return a
>      zero-filled page (e.g. ext3/4), and go
>      to page_ok label]
> 
>                                                   ->a_ops->direct_IO()
>                                                   ->i_size_write()
>                                                   [we enlarge the i_size]
> 
>     Here we check i_size
>     [in page_ok label, we check i_size but
>      it has been enlarged.  Thus, we pass
>      the check and return a zero-filled page]

OK, so it's a race.

> This commit let dio read return directly if the current offset of the
> dio read is beyond the end of file in order to avoid this problem.
> 
> ...
>
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1452,6 +1452,8 @@ generic_file_aio_read(struct kiocb *iocb, const struct iovec *iov,
>  				file_accessed(filp);
>  				goto out;
>  			}
> +		} else {
> +			goto out;
>  		}
>  	}

OK, so we don't fall back to buffered reading at all if we're outside
i_size.

I'm not sure this 100% fixes the problem.  In generic_file_aio_read():

: 		if (pos < size) {

write() extends i_size now.

: 			retval = filemap_write_and_wait_range(mapping, pos,
: 					pos + iov_length(iov, nr_segs) - 1);
: 			if (!retval) {
: 				retval = mapping->a_ops->direct_IO(READ, iocb,
: 							iov, pos, nr_segs);
: 			}
: 			if (retval > 0) {
: 				*ppos = pos + retval;
: 				count -= retval;
: 			}
: 
: 			/*
: 			 * Btrfs can have a short DIO read if we encounter
: 			 * compressed extents, so if there was an error, or if
: 			 * we've already read everything we wanted to, or if
: 			 * there was a short read because we hit EOF, go ahead
: 			 * and return.  Otherwise fallthrough to buffered io for
: 			 * the rest of the read.
: 			 */
: 			if (retval < 0 || !count || *ppos >= size) {
: 				file_accessed(filp);
: 				goto out;
: 			}

we can still fall through to buffered read.

: 		} else {
: 			goto out;
: 		}
: 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
