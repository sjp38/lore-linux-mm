From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH]fix VM_CAN_NONLINEAR check in sys_remap_file_pages
Date: Mon, 8 Oct 2007 17:45:38 +1000
References: <3d0408630710080445j4dea115emdfe29aac26814536@mail.gmail.com> <20071008102843.d20b56d7.randy.dunlap@oracle.com> <20071008105120.4e0e4a85.akpm@linux-foundation.org>
In-Reply-To: <20071008105120.4e0e4a85.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_jAeCHpGYRU+cpXT"
Message-Id: <200710081745.39254.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, yanzheng@21cn.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ltp-list@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

--Boundary-00=_jAeCHpGYRU+cpXT
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 09 October 2007 03:51, Andrew Morton wrote:
> On Mon, 8 Oct 2007 10:28:43 -0700

> > I'll now add remap_file_pages soon.
> > Maybe those other 2 tests aren't strong enough (?).
> > Or maybe they don't return a non-0 exit status even when they fail...
> > (I'll check.)
>
> Perhaps Yan Zheng can tell us what test was used to demonstrate this?

Was probably found by review. Otherwise, you could probably reproduce
it by mmaping, say, drm device node, running remap_file_pages() on it
to create a nonlinear mapping, and then finding that you get the wrong
data.

> > > I'm surprise that LTP doesn't have any remap_file_pages() tests.
> >
> > quick grep didn't find any for me.
>
> Me either.  There are a few lying around the place which could be
> integrated.
>
> It would be good if LTP were to have some remap_file_pages() tests
> (please).  As we see here, it is something which we can easily break, and
> leave broken for some time.

Here is Ingo's old test, since cleaned up and fixed a bit by me....
I'm sure he would distribute it GPL, but I've cc'ed him because I didn't
find an explicit statement about that.


--Boundary-00=_jAeCHpGYRU+cpXT
Content-Type: text/x-csrc;
  charset="iso-8859-1";
  name="remap-file-pages.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="remap-file-pages.c"

/*
 * Copyright (C) Ingo Molnar, 2002
 */
#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/times.h>
#include <sys/wait.h>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <linux/unistd.h>

#define PAGE_SIZE 4096
#define PAGE_WORDS (PAGE_SIZE/sizeof(int))

#define CACHE_PAGES 1024
#define CACHE_SIZE (CACHE_PAGES*PAGE_SIZE)

#define WINDOW_PAGES 16
#define WINDOW_SIZE (WINDOW_PAGES*PAGE_SIZE)

#define WINDOW_START 0x48000000

static char cache_contents [CACHE_SIZE];

static void test_nonlinear(int fd)
{
	char *data = NULL;
	int i, j, repeat = 2;

	for (i = 0; i < CACHE_PAGES; i++) {
		int *page = (int *) (cache_contents + i*PAGE_SIZE);

		for (j = 0; j < PAGE_WORDS; j++)
			page[j] = i;
	}

	if (write(fd, cache_contents, CACHE_SIZE) != CACHE_SIZE)
		perror("write"), exit(1);

	data = mmap((void *)WINDOW_START,
			WINDOW_SIZE,
			PROT_READ|PROT_WRITE, 
			MAP_FIXED | MAP_SHARED 
			, fd, 0);

	if (data == MAP_FAILED)
		perror("mmap"), exit(1);

again:
	for (i = 0; i < WINDOW_PAGES; i += 2) {
		char *page = data + i*PAGE_SIZE;

		if (remap_file_pages(page, PAGE_SIZE * 2, 0,
				(WINDOW_PAGES-i-2), 0) == -1)
			perror("remap_file_pages"), exit(1);
	}

	for (i = 0; i < WINDOW_PAGES; i++) {
		/*
		 * Double-check the correctness of the mapping:
		 */
		if (i & 1) {
			if (data[i*PAGE_SIZE] != WINDOW_PAGES-i) {
				printf("hm, mapped incorrect data!\n");
				exit(1);
			}
		} else {
			if (data[i*PAGE_SIZE] != WINDOW_PAGES-i-2) {
				printf("hm, mapped incorrect data!\n");
				exit(1);
			}
		}
	}

	if (--repeat)
		goto again;
}

int main(int argc, char **argv)
{
	int fd;

	fd = open("/dev/shm/cache", O_RDWR|O_CREAT|O_TRUNC,S_IRWXU);
	if (fd < 0)
		perror("open"), exit(1);
	test_nonlinear(fd);
	if (close(fd) == -1)
		perror("close"), exit(1);
	printf("nonlinear shm file OK\n");

	fd = open("/tmp/cache", O_RDWR|O_CREAT|O_TRUNC,S_IRWXU);
	if (fd < 0)
		perror("open"), exit(1);
	test_nonlinear(fd);
	if (close(fd) == -1)
		perror("close"), exit(1);
	printf("nonlinear /tmp/ file OK\n");

	exit(0);
}


--Boundary-00=_jAeCHpGYRU+cpXT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
