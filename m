Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 38B196B0272
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 16:25:58 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id f13so6779639oib.20
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 13:25:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u126si1471765oib.328.2018.01.08.13.25.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jan 2018 13:25:56 -0800 (PST)
Date: Mon, 8 Jan 2018 15:25:55 -0600
From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: kernel BUG at ./include/linux/mm.h:LINE! (3)
Message-ID: <20180108152555.791cceec@lembas.zaitcev.lan>
In-Reply-To: <20180103092604.5y4bvh3i644ts3zm@node.shutemov.name>
References: <20171228160346.6406d52df0d9afe8cf7a0862@linux-foundation.org>
	<20171229132420.jn2pwabl6pyjo6mk@node.shutemov.name>
	<20180103010238.1e510ac2@lembas.zaitcev.lan>
	<20180103092604.5y4bvh3i644ts3zm@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-usb@vger.kernel.org, zaitcev@redhat.com

On Wed, 3 Jan 2018 12:26:04 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> > > -	unsigned long offset, chunk_idx;
> > > +	unsigned long offset, chunk_idx, flags;
> > >  	struct page *pageptr;
> > >  
> > > +	mutex_lock(&rp->fetch_lock);
> > > +	spin_lock_irqsave(&rp->b_lock, flags);
> > >  	offset = vmf->pgoff << PAGE_SHIFT;

> > I think that grabbing the spinlock is not really necessary in
> > this case. The ->b_lock is designed for things that are accessed
> > from interrupts that Host Controller Driver serves -- mostly
> > various pointers. By defintion it's not covering things that
> > are related to re-allocation. Now, the re-allocation itself
> > grabs it, because it resets indexes into the new buffer, but
> > does not appear to apply here, does it now?  
> 
> Please, double check everything. I remember that the mutex wasn't enough
> to stop bug from triggering. But I didn't spend much time understanding
> the code.

Attached is the test that I used to reproduce the problem, and my
patch with just the ->fetch_lock fixes it. That said, your test
suite may be more comprehensive, or you may have a device that
generates enough USB traffic with associated monitoring callbacks.
But I don't see it.

At this point, I'm going to post the patch with a Signed-Off-By.

-- Pete

(this reproduces very quickly)

/*
 * usbmontest: The crash test for usbmon, crashes kernel 4.15
 *
 * Copyright (c) 2007 Red Hat, Inc.
 * Copyright (c) 2016 Mike Frysinger <vapier@gentoo.org>
 * Copyright (c) 2018 Pete Zaitcev <zaitcev@redhat.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/sysmacros.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <inttypes.h>
#include <stdarg.h>

#define TAG "usbmontest"

#ifdef __GNUC__
#define __unused __attribute__((unused))
#else
#define __unused /**/
#endif

#define MON_IOC_MAGIC 0x92

#define MON_IOCG_STATS _IOR(MON_IOC_MAGIC, 3, struct usbmon_stats)

#define MON_IOCT_RING_SIZE _IO(MON_IOC_MAGIC, 4)

#define MON_IOCQ_RING_SIZE _IO(MON_IOC_MAGIC, 5)

struct usbmon_mfetch_arg {
	unsigned int *offvec;		/* Vector of events fetched */
	unsigned int nfetch;		/* Num. of events to fetch / fetched */
	unsigned int nflush;		/* Number of events to flush */
};

#define MON_IOCX_MFETCH _IOWR(MON_IOC_MAGIC, 7, struct usbmon_mfetch_arg)

/*
 */
struct params {
	int ifnum;	/* USB bus number */
	char *devname;	/* /dev/usbmonN */

	unsigned int map_size;
};
const unsigned int page_size = 8192;	/* 2x the size on x86, cross-platform */
const unsigned int num_pages = 3;

void Usage(void);

void parse_params(struct params *p, char **argv);
void make_device(const struct params *p);
int find_major(void);

struct params par;

int main(int argc __unused, char **argv)
{
	int fd;
	unsigned char *data_buff;
	unsigned int n;
	int wstat;
	int rc;

	parse_params(&par, argv+1);

	/*
	 * Two reasons to do this:
	 * 1. Reduce weird error messages.
	 * 2. If we create device nodes, we want them owned by root.
	 */
	if (geteuid() != 0) {
		fprintf(stderr, TAG ": Must run as root\n");
		exit(1);
	}

	if ((fd = open(par.devname, O_RDWR)) == -1) {
		if (errno == ENOENT) {
			make_device(&par);
			fd = open(par.devname, O_RDWR);
		}
		if (fd == -1) {
			if (errno == ENODEV && par.ifnum == 0) {
				fprintf(stderr, TAG
				    ": Can't open pseudo-bus zero at %s"
				    " (probably not supported by kernel)\n",
				    par.devname);
			} else {
				fprintf(stderr, TAG ": Can't open %s: %s\n",
				    par.devname, strerror(errno));
			}
			exit(1);
		}
	}

	rc = ioctl(fd, MON_IOCT_RING_SIZE, par.map_size);
	if (rc == -1) {
		fprintf(stderr, TAG ": Cannot set ring size (%d): %s\n",
		    par.map_size, strerror(errno));
		exit(1);
	}

	rc = fork();
	if (rc < 0) {
		fprintf(stderr, TAG ": fork: %s\n", strerror(errno));
		exit(1);
	}
	if (rc != 0) {
		/*
		 * This loop races the mmap and makes it carsh with BUG() in
		 * include/linux/mm.h:831.
		 */
		for (;;) {
			rc = ioctl(fd, MON_IOCT_RING_SIZE, par.map_size);
			if (rc == -1) {
				fprintf(stderr, TAG ": Cannot set ring size (%d): %s\n",
				    par.map_size, strerror(errno));
				exit(1);
			}

			rc = waitpid(0, &wstat, WNOHANG);
			if (rc < 0) {
				fprintf(stderr, TAG ": waitpid: %s\n",
				    strerror(errno));
				exit(1);
			}
			/*
			 * Exit if the child crashed, this way the user does
			 * not need to hunt and kill the runwaway mapping loop.
			 */
			if (rc != 0)
				exit(0);
		}
	} else {
		/*
		 * This loop sets up and tears down the mmap continuously
		 * in order to cause page faults. Merely accessing the mapped
		 * buffer causes the faults one time at the beginning only.
		 */
		for (;;) {
			data_buff = mmap(0, par.map_size, PROT_READ, MAP_SHARED, fd, 0);
			if (data_buff == MAP_FAILED) {
				fprintf(stderr, TAG ": Cannot mmap: %s\n",
				    strerror(errno));
				exit(1);
			}

			/* dear gcc, please don't optimize orz */
			for (n = 0; n < num_pages; n++) {
				unsigned char x;
				x = ((volatile unsigned char *)data_buff)[n * page_size];
			}

			munmap(data_buff, par.map_size);
		}
	}

	// return 0;
}

void parse_params(struct params *p, char **argv)
{
	char *arg;
	long num;

	memset(p, 0, sizeof(struct params));

	while ((arg = *argv++) != NULL) {
		if (arg[0] == '-') {
			if (arg[1] == 0)
				Usage();
			switch (arg[1]) {
			case 'i':
				if (arg[2] != 0)
					Usage();
				if ((arg = *argv++) == NULL)
					Usage();
				if (strncmp(arg, "usb", 3) == 0)
					arg += 3;
				if (!isdigit(arg[0]))
					Usage();
				errno = 0;
				num = strtol(arg, NULL, 10);
				if (errno != 0)
					Usage();
				if (num < 0 || num >= 128) {
					fprintf(stderr, TAG ": Bus number %ld"
					   " is out of bounds\n", num);
					exit(2);
				}
				p->ifnum = num;
				break;
			default:
				Usage();
			}
		} else {
			Usage();
		}
	}

	if (p->devname == NULL) {
		if ((p->devname = malloc(100)) == NULL) {
			fprintf(stderr, TAG ": No core\n");
			exit(1);
		}
		snprintf(p->devname, 100, "/dev/usbmon%d", p->ifnum);
	}

	p->map_size = num_pages * page_size;
}

void make_device(const struct params *p)
{
	int major;
	dev_t dev;

	major = find_major();
	dev = makedev(major, p->ifnum);
	if (mknod(p->devname, S_IFCHR|S_IRUSR|S_IWUSR, dev) != 0) {
		fprintf(stderr, TAG ": Can't make device %s: %s\n",
		    p->devname, strerror(errno));
		exit(1);
	}
}

int find_major(void)
{
	long num;
	FILE *df;
	enum { LEN = 50 };
	char buff[LEN], c, *p;
	char *major, *mname;

	if ((df = fopen("/proc/devices", "r")) == NULL) {
		fprintf(stderr, TAG ": Can't open /proc/devices\n");
		exit(1);
	}
	num = -1;
	while (fgets(buff, LEN, df) != NULL) {
		p = buff;
		major = NULL;
		mname = NULL;
		for (p = buff; (c = *p) != 0; p++) {
			if (major == NULL) {
				if (c != ' ') {
					major = p;
				}
			} else if (mname == NULL) {
				if (!isdigit(c) && c != ' ') {
					mname = p;
				}
			} else {
				if (c == '\n') {
					*p = 0;
					break;
				}
			}
		}
		if (major != NULL && mname != NULL) {
			if (strcmp(mname, "usbmon") == 0) {
				errno = 0;
				num = strtol(major, NULL, 10);
				if (errno != 0) {
					fprintf(stderr, TAG ": Syntax error "
					    "in /proc/devices\n");
					exit(1);
				}
				break;
			}
		}
	}
	fclose(df);

	if (num == -1) {
		fprintf(stderr, TAG ": Can't find usbmon in /proc/devices\n");
		exit(1);
	}

	if (num <= 0 || num > INT_MAX) {
		fprintf(stderr, TAG ": Weird major %ld in /proc/devices\n",
		    num);
		exit(1);
	}

	return (int) num;
}

void Usage(void)
{
	fprintf(stderr, "Usage: "
	    "usbmontest [-i usbN]\n");
	exit(2);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
