From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH 2/3] hugetlb: fix prio_tree unit
Date: Wed, 25 Oct 2006 16:49:29 -0700
Message-ID: <000001c6f890$373fb960$12d0180a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0001_01C6F855.8AE0E160"
In-Reply-To: <Pine.LNX.4.64.0610250828020.8576@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Hugh Dickins' <hugh@veritas.com>, David Gibson <david@gibson.dropbear.id.au>
Cc: Andrew Morton <akpm@osdl.org>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

------=_NextPart_000_0001_01C6F855.8AE0E160
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hugh Dickins wrote on Wednesday, October 25, 2006 12:41 AM
> On Wed, 25 Oct 2006, David Gibson wrote:
> > 
> > Hugh, I'd like to add a testcase to the libhugetlbfs testsuite which
> > will trigger this bug, but from the description above I'm not sure
> > exactly how to tickle it.  Can you give some more details of what
> > sequence of calls will cause the BUG_ON() to be called.
> > 
> > I've attached the skeleton test I have now, but I'm not sure if it's
> > even close to what's really required for this.
> 
> I'll take a look, or reconstruct my own sequence, later on today and
> send it just to you.  The BUG_ON was not at all what I was expecting,
> and I spent quite a while working out how it came about (v_offset
> wrapped, so vm_start + v_offset less than vm_start, so the huge unmap
> applied to a non-huge vma before it).  Though I'm dubious whether it's
> really worthwhile devising such a test now.

It's fairly easy to reproduce.  I got a test cases that easily trigger
kernel oops and even got a sequence to screw up hugepage_rsvd count.
All I have to do is to place vm_start high enough and combined with large
enough v_offset, the add "vma->vm_start + v_offset" will overflow. It
doesn't even need to be over 4GB.

Hugh, if you haven't got time to reconstruct the bug sequence, don't
bother. I'll give my test cases to David.

- Ken


------=_NextPart_000_0001_01C6F855.8AE0E160
Content-Type: application/octet-stream;
	name="case2.c"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="case2.c"

#include <stdlib.h>=0A=
#include <stdio.h>=0A=
#include <unistd.h>=0A=
#include <sys/mman.h>=0A=
#include <sys/types.h>=0A=
#include <fcntl.h>=0A=
=0A=
#define FILE_NAME "/mnt/htlb/junk"=0A=
#define HPAGE_SIZE (4*1024*1024)=0A=
#define LENGTH (16UL*1024*1024)=0A=
#define TRUNCATE (0x60000000)=0A=
#define PROTECTION (PROT_READ | PROT_WRITE)=0A=
#define ADDR (void *)(0xa0000000UL)=0A=
#define FLAGS (MAP_PRIVATE)=0A=
=0A=
int main(void)=0A=
{=0A=
        char *addr;=0A=
        int fd;=0A=
	char s;=0A=
	unsigned long i;=0A=
=0A=
        fd =3D open(FILE_NAME, O_CREAT | O_RDWR, 0755);=0A=
        if (fd < 0) {=0A=
                perror("Open failed");=0A=
                exit(1);=0A=
        }=0A=
=0A=
        addr =3D mmap(0, LENGTH+TRUNCATE, PROTECTION, FLAGS, fd, 0);=0A=
        if (addr =3D=3D MAP_FAILED) {=0A=
                perror("first mmap");=0A=
                unlink(FILE_NAME);=0A=
                exit(1);=0A=
        }=0A=
	munmap(addr, LENGTH+TRUNCATE);=0A=
=0A=
        addr =3D mmap(ADDR, LENGTH, PROTECTION, FLAGS, fd, 0);=0A=
        if (addr =3D=3D MAP_FAILED) {=0A=
                perror("secound mmap");=0A=
                unlink(FILE_NAME);=0A=
                exit(1);=0A=
        }=0A=
=0A=
	for (i =3D 0; i < LENGTH; i+=3D HPAGE_SIZE)=0A=
		addr[i] =3D 1;=0A=
	printf("addr =3D %lx\n", addr);=0A=
=0A=
	ftruncate(fd, TRUNCATE);=0A=
=0A=
	s =3D addr[0];=0A=
=0A=
        close(fd);=0A=
        unlink(FILE_NAME);=0A=
=0A=
        return s;=0A=
}=0A=

------=_NextPart_000_0001_01C6F855.8AE0E160
Content-Type: application/octet-stream;
	name="case1.c"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="case1.c"

#include <stdlib.h>=0A=
#include <stdio.h>=0A=
#include <unistd.h>=0A=
#include <sys/mman.h>=0A=
#include <sys/types.h>=0A=
#include <fcntl.h>=0A=
=0A=
#define FILE_NAME "/mnt/htlb/junk"=0A=
#define HPAGE_SIZE (4*1024*1024)=0A=
#define LENGTH (16UL*1024*1024)=0A=
#define TRUNCATE (8UL*1024*1024)=0A=
#define PROTECTION (PROT_READ | PROT_WRITE)=0A=
#define ADDR (void *)(0xa0000000UL)=0A=
#define OFFSET (0x50000000L)=0A=
#define FLAGS (MAP_SHARED)=0A=
=0A=
int main(void)=0A=
{=0A=
        char *addr;=0A=
        int fd;=0A=
	char s;=0A=
	unsigned long i;=0A=
=0A=
        fd =3D open(FILE_NAME, O_CREAT | O_RDWR, 0755);=0A=
        if (fd < 0) {=0A=
                perror("Open failed");=0A=
                exit(1);=0A=
        }=0A=
=0A=
        addr =3D mmap(ADDR, LENGTH, PROTECTION, FLAGS, fd, OFFSET);=0A=
        if (addr =3D=3D MAP_FAILED) {=0A=
                perror("mmap");=0A=
                unlink(FILE_NAME);=0A=
                exit(1);=0A=
        }=0A=
=0A=
	for (i =3D 0; i < LENGTH; i+=3D HPAGE_SIZE)=0A=
		addr[i] =3D 1;=0A=
=0A=
	ftruncate(fd, TRUNCATE);=0A=
        close(fd);=0A=
        unlink(FILE_NAME);=0A=
=0A=
        return s;=0A=
}=0A=

------=_NextPart_000_0001_01C6F855.8AE0E160--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
