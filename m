Date: Thu, 8 May 2008 16:39:33 +0200
From: Hans Rosenfeld <hans.rosenfeld@amd.com>
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
Message-ID: <20080508143933.GF12654@escobedo.amd.com>
References: <b6a2187b0805051806v25fa1272xb08e0b70b9c3408@mail.gmail.com> <20080506124946.GA2146@elte.hu> <Pine.LNX.4.64.0805061435510.32567@blonde.site> <alpine.LFD.1.10.0805061138580.32269@woody.linux-foundation.org> <Pine.LNX.4.64.0805062043580.11647@blonde.site> <20080506202201.GB12654@escobedo.amd.com> <1210106579.4747.51.camel@nimitz.home.sr71.net> <20080508143453.GE12654@escobedo.amd.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3MwIy2ne0vdjdPXF"
Content-Disposition: inline
In-Reply-To: <20080508143453.GE12654@escobedo.amd.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 08, 2008 at 04:34:53PM +0200, Hans Rosenfeld wrote:
> A stripped-down program exposing the leak is attached.

It is now :)

-- 
%SYSTEM-F-ANARCHISM, The operating system has been overthrown

--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="hugetest.c"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <inttypes.h>
#include <signal.h>
#include <string.h>
#include <strings.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define HUGEPAGES "/proc/sys/vm/nr_hugepages"
#define HUGE_FILE "/mnt/huge/foobar"

void *huge;

int main(int argc, char **argv)
{
	uint64_t ppte;
        int fd, maps;

        if ((fd = open(HUGEPAGES, O_WRONLY, 0)) == -1) {
                perror(HUGEPAGES);
                return 1;
        }
        write(fd, "20\n", 3);
        close(fd);

        if ((fd = open(HUGE_FILE, O_RDWR | O_CREAT, 0)) == -1) {
                perror(HUGE_FILE);
                return 1;
        }

        huge = mmap((void *) 0x1000000, 0x400000,
                    PROT_READ | PROT_WRITE,
                    MAP_PRIVATE | MAP_FIXED,
                    fd, 0);

        if (huge == MAP_FAILED) {
                perror(HUGE_FILE);
                return 1;
        }

        fprintf(stderr, "huge: 0x%0.*" PRIxPTR "\n", sizeof(huge) * 2, huge);
        memset(huge, 1, 12345);

	if ((maps = open("/proc/self/pagemap", O_RDONLY, 0)) < 0) {
		perror("/proc/self/pagemap");
		return 1;
	}

	if (pread(maps, &ppte, sizeof(ppte), ((uintptr_t) huge) >> 9) < 0) {
		perror("pread");
		return 1;
	}

	fprintf(stderr, "ppte: 0x%0.16" PRIx64 "\n", ppte);

        return 0;
}

--3MwIy2ne0vdjdPXF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
