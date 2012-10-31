Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id BC0DD6B0070
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 10:21:23 -0400 (EDT)
Date: Wed, 31 Oct 2012 15:19:03 +0100
From: chrubis@suse.cz
Subject: Re: Partialy mapped page stays in page cache after unmap
Message-ID: <20121031141903.GA23341@rei.suse.cz>
References: <20121030182420.GA17171@rei.Home>
 <CAA_GA1fozH3wA+2YWrCEUN2S=3rSpJ3f829yy8TZFfuh8q-WYQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="tKW2IUtsqtDRztdT"
Content-Disposition: inline
In-Reply-To: <CAA_GA1fozH3wA+2YWrCEUN2S=3rSpJ3f829yy8TZFfuh8q-WYQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!
> > Strictly speaking this is not a bug at least when sticking to regular
> > files as POSIX which says that the change is not written out. In this
> > case the file content is correct and forcing the data to be written out
> > by msync() makes the test pass. The SHM mappings seems to preserve the
> > content even after calling msync() which is, in my opinion, POSIX
> > violation although a minor one.
> >
> 
> fsync implemented in SHM is noop_fsync.
> May be we should extend it if needed.

I'm entirely sure that would fix the interface correclty. The posix
says:


mmap:

...
The system shall always zero-fill any partial page at the end of an
object. Further, the system shall never write out any modified portions
of the last page of an object which are beyond its end. 
...


msync:

...
The effect of msync() on a shared memory object or a typed memory object
is unspecified. 
...

Hmm, that is a little confusing and it looks like it depends on
interpretation what 'write out' for SHM object means. And I guess that
leaving the SHM part as it is is reasonable. Maybe worth of a note in
manual page.


On the other hand there seems to be several bugs in mmap() on regular
files. For example mapping half of the page from a file doesn't fill the
rest of the page with zeroes. And it looks like when half of page is
mapped, the second half modified, then unmapped and then the whole page
is mapped the content doesn't seem to be right, although this seems to
change randomly. The reproducer for the first case attached.

-- 
Cyril Hrubis
chrubis@suse.cz

--tKW2IUtsqtDRztdT
Content-Type: text/x-c; charset=us-ascii
Content-Disposition: attachment; filename="reproducer1.c"

#define _XOPEN_SOURCE 600

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
	void *data;
	char *pa;
	size_t len;
	int fd, i, fail = 0;

	page_size = sysconf(_SC_PAGE_SIZE);

	snprintf(tmpfname, sizeof(tmpfname), "/tmp/test");
	
	/* Create file */
	unlink(tmpfname);
	fd = open(tmpfname, O_CREAT | O_RDWR | O_EXCL,
		  S_IRUSR | S_IWUSR);
	if (fd == -1) {
		printf("Error at open(): %s\n", strerror(errno));
		return 1;
	}
	
	/* Fill it to the size of the page with 'a' */
	data = malloc(page_size);
	memset(data, 'a', page_size);
	if (write(fd, data, page_size) != page_size) {
		printf("Error at write(): %s\n", strerror(errno));
		return 1;
	}
	free(data);

	/* mmap half of the page */
	pa = mmap(NULL, page_size/2, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (pa == MAP_FAILED) {
		printf("Error at mmap(): %s\n", strerror(errno));
		return 1;
	}
	
	for (i = 0; i < page_size; i++) {
		if (i > page_size/2 && pa[i] != 0)
			fail++;
		printf("%4i %2x\n", i, pa[i]);
	}

	close(fd);
	munmap(pa, len);
	
	if (fail)
		printf("FAILED: Page not zeroed\n");
	else
		printf("SUCCEDED\n");

	return 0;
}

--tKW2IUtsqtDRztdT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
