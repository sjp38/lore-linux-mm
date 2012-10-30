Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 927AE6B0068
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 14:26:40 -0400 (EDT)
Date: Tue, 30 Oct 2012 19:24:20 +0100
From: chrubis@suse.cz
Subject: Partialy mapped page stays in page cache after unmap
Message-ID: <20121030182420.GA17171@rei.Home>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="huq684BweRXVnRxX"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!
I'm currently revisiting mmap related tests in LTP (Linux Test Project)
and I've came to the tests testing that writes to the partially
mapped page (at the end of mapping) are carried out correctly.

These tests fails because even after the object is unmapped and the
file-descriptor closed the pages still stays in the page cache so if
(possibly another process) opens and maps the file again the whole
content of the partial page is preserved.

Strictly speaking this is not a bug at least when sticking to regular
files as POSIX which says that the change is not written out. In this
case the file content is correct and forcing the data to be written out
by msync() makes the test pass. The SHM mappings seems to preserve the
content even after calling msync() which is, in my opinion, POSIX
violation although a minor one.

Looking at the test results I have, the file based mmap test worked fine
on 2.6.5 (or perhaps the page cache was working/setup differently and
the test succeeded by accidend).

Attached is a stripped down LTP test for the problem, uncommenting the
msync() makes the test succeed.

I would like to hear your opinions on this problems.

-- 
Cyril Hrubis
chrubis@suse.cz

--huq684BweRXVnRxX
Content-Type: text/x-c; charset=us-ascii
Content-Disposition: attachment; filename="reproducer.c"

#define _XOPEN_SOURCE 600

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>

int main(void)
{
	char tmpfname[256];
	long page_size;
	long total_size;

	void *pa;
	size_t len;
	int i, fd;
	
	pid_t child;
	char *ch;
	int exit_val;

	page_size = sysconf(_SC_PAGE_SIZE);

	/* Size of the file to be mapped */
	total_size = page_size / 2;

	/* mmap will create a partial page */
	len = page_size / 2;

	snprintf(tmpfname, sizeof(tmpfname), "/tmp/pts_mmap_11_5_%d", getpid());
	
	/* Create shared file */
	unlink(tmpfname);
	fd = open(tmpfname, O_CREAT | O_RDWR | O_EXCL, S_IRUSR | S_IWUSR);
	if (fd == -1) {
		printf("Error at open(): %s\n", strerror(errno));
		return 1;
	}
	if (ftruncate(fd, total_size) == -1) {
		printf("Error at ftruncate(): %s\n", strerror(errno));
		return 1;
	}

	pa = mmap(NULL, len, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (pa == MAP_FAILED) {
		printf("Error at mmap(): %s\n", strerror(errno));
		return 1;
	}
		
	ch = (char*)pa + len + 1;

	/* Check the patial page is ZERO filled */
	for (i = 0; i < page_size/2 - 1; i++) {
		if (ch[i] != 0) {
			printf("Test FAILED: The partial page at the "
			       "end of the file is not zero-filled\n");
			return 1;
		}
	}

	/* Write to the partial page */
	*ch = 'b';
	//msync(pa, len, MS_SYNC);
	munmap(pa, len);
	close(fd);

	/* Open and map it again */
	fd = open(tmpfname, O_RDWR, 0);
	unlink(tmpfname);

	pa = mmap(NULL, len, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (pa == MAP_FAILED) {
		printf("Error at 2nd mmap(): %s\n", strerror(errno));
		return 1;
	}

	ch = pa + len + 1;
	if (*ch == 'b') {
		printf("Test FAILED: Modification of the partial page "
		       "at the end of an object is written out\n");
		return 1;
	}
	
	close(fd);
	munmap(pa, len);

	printf("Test PASSED\n");
	return 1;
}

--huq684BweRXVnRxX--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
