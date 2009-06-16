Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E4EAF6B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 10:41:03 -0400 (EDT)
Date: Tue, 16 Jun 2009 16:42:17 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/10] Fix page_mkwrite() for blocksize < pagesize
	(version 3)
Message-ID: <20090616144217.GA18063@duck.suse.cz>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <20090616143424.GA22002@infradead.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="VS++wcV0S1rZb1Fb"
Content-Disposition: inline
In-Reply-To: <20090616143424.GA22002@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue 16-06-09 10:34:24, Christoph Hellwig wrote:
> On Mon, Jun 15, 2009 at 07:59:47PM +0200, Jan Kara wrote:
> > 
> > patches below are an attempt to solve problems filesystems have with
> > page_mkwrite() when blocksize < pagesize (see the changelog of the second patch
> > for details).
> 
> It would be useful if you had a test case reproducing these issues,
> so that I can verify how well your patches work in various scenarios.
  Good point, I should have mentioned in the changelog: fsx-linux is able
to trigger the problem quite quickly.
  I have also written a simple program for initial testing of the fix
(works only for 1K blocksize and 4K pagesize) - it's attached.

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--VS++wcV0S1rZb1Fb
Content-Type: text/x-c++src; charset=us-ascii
Content-Disposition: attachment; filename="test-mkwrite.c"

#define _XOPEN_SOURCE 500
#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>

#define MMAP_THREADS 4

void map_file(int fd)
{
	char *addr = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	int i;

	if (addr == MAP_FAILED) {
		perror("mmap");
		exit(1);
	}
	while (1) {
		for (i = 0; i < 128; i++)
			addr[i + 1024] = 'c';
	}
}

char buf2[4096] __attribute__ ((aligned (4096)));

int main(int argc, char **argv)
{
	int i;
	int ret;
	int fd;
	char buf[1024];

	if (argc != 2) {
		printf("Usage: test-mkwrite <file>\n");
		return 1;
	}
	fd = open(argv[1], O_RDWR | O_CREAT | O_TRUNC, 0644);
	if (fd < 0) {
		perror("open");
		return 1;
	}
	memset(buf, 'a', sizeof(buf));
	pwrite(fd, buf, sizeof(buf), 0);

	for (i = 0; i < MMAP_THREADS; i++) {
		ret = fork();
		if (ret < 0) {
			perror("fork");
			return 1;
		} else if (ret == 0)
			map_file(fd);
	}
	close(fd);

	memset(buf2, 'b', sizeof(buf2));
	fd = open(argv[1], O_RDWR | O_DIRECT);
	if (fd < 0) {
		perror("dopen");
		return 1;
	}
	while (1) {
		if (pwrite(fd, buf2, 4096, 4096) < 0)
			perror("pwrite");
		usleep(10000000);
		ftruncate(fd, 1024);
		usleep(10000000);
	}
	
	return 0;
}

--VS++wcV0S1rZb1Fb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
