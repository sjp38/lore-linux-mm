Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C06516B0008
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 04:54:50 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x1-v6so5059654eds.16
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 01:54:50 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c49-v6si6311529edb.297.2018.11.05.01.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 01:54:49 -0800 (PST)
Date: Mon, 5 Nov 2018 10:54:47 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/6] mm: introduce page->dma_pinned_flags, _count
Message-ID: <20181105095447.GE6953@quack2.suse.cz>
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-5-jhubbard@nvidia.com>
 <20181013035516.GA18822@dastard>
 <7c2e3b54-0b1d-6726-a508-804ef8620cfd@nvidia.com>
 <20181013164740.GA6593@infradead.org>
 <84811b54-60bf-2bc3-a58d-6a7925c24aad@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84811b54-60bf-2bc3-a58d-6a7925c24aad@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On Sun 04-11-18 23:10:12, John Hubbard wrote:
> On 10/13/18 9:47 AM, Christoph Hellwig wrote:
> > On Sat, Oct 13, 2018 at 12:34:12AM -0700, John Hubbard wrote:
> >> In patch 6/6, pin_page_for_dma(), which is called at the end of get_user_pages(),
> >> unceremoniously rips the pages out of the LRU, as a prerequisite to using
> >> either of the page->dma_pinned_* fields. 
> >>
> >> The idea is that LRU is not especially useful for this situation anyway,
> >> so we'll just make it one or the other: either a page is dma-pinned, and
> >> just hanging out doing RDMA most likely (and LRU is less meaningful during that
> >> time), or it's possibly on an LRU list.
> > 
> > Have you done any benchmarking what this does to direct I/O performance,
> > especially for small I/O directly to a (fast) block device?
> > 
> 
> Hi Christoph,
> 
> I'm seeing about 20% slower in one case: lots of reads and writes of size 8192 B,
> on a fast NVMe device. My put_page() --> put_user_page() conversions are incomplete 
> and buggy yet, but I've got enough of them done to briefly run the test.
> 
> One thing that occurs to me is that jumping on and off the LRU takes time, and
> if we limited this to 64-bit platforms, maybe we could use a real page flag? I 
> know that leaves 32-bit out in the cold, but...maybe use this slower approach
> for 32-bit, and the pure page flag for 64-bit? uggh, we shouldn't slow down anything
> by 20%. 
> 
> Test program is below. I hope I didn't overlook something obvious, but it's 
> definitely possible, given my lack of experience with direct IO. 
> 
> I'm preparing to send an updated RFC this week, that contains the feedback to date,
> and also many converted call sites as well, so that everyone can see what the whole
> (proposed) story would look like in its latest incarnation.

Hmm, have you tried larger buffer sizes? Because synchronous 8k IO isn't
going to max-out NVME iops by far. Can I suggest you install fio [1] (it
has the advantage that it is pretty much standard for a test like this so
everyone knows what the test does from a glimpse) and run with it something
like the following workfile:

[reader]
direct=1
ioengine=libaio
blocksize=4096
size=1g
numjobs=1
rw=read
iodepth=64

And see how the numbers with and without your patches compare?

								Honza

[1] https://github.com/axboe/fio


> 
> #define _GNU_SOURCE
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <stdio.h>
> #include <unistd.h>
> #include <stdlib.h>
> #include <stdbool.h>
> #include <string.h>
> 
> const static unsigned BUF_SIZE       = 4096;
> static const unsigned FULL_DATA_SIZE = 2 * BUF_SIZE;
> 
> void read_from_file(int fd, size_t how_much, char * buf)
> {
> 	size_t bytes_read;
> 
> 	for (size_t index = 0; index < how_much; index += BUF_SIZE) {
> 		bytes_read = read(fd, buf, BUF_SIZE);
> 		if (bytes_read != BUF_SIZE) {
> 			printf("reading file failed: %m\n");
> 			exit(3);
> 		}
> 	}
> }
> 
> void seek_to_start(int fd, char *caller)
> {
> 	off_t result = lseek(fd, 0, SEEK_SET);
> 	if (result == -1) {
> 		printf("%s: lseek failed: %m\n", caller);
> 		exit(4);
> 	}
> }
> 
> void write_to_file(int fd, size_t how_much, char * buf)
> {
> 	int result;
> 	for (size_t index = 0; index < how_much; index += BUF_SIZE) {
> 		result = write(fd, buf, BUF_SIZE);
> 		if (result < 0) {
> 			printf("writing file failed: %m\n");
> 			exit(3);
> 		}
> 	}
> }
> 
> void read_and_write(int fd, size_t how_much, char * buf)
> {
> 	seek_to_start(fd, "About to read");
> 	read_from_file(fd, how_much, buf);
> 
> 	memset(buf, 'a', BUF_SIZE);
> 
> 	seek_to_start(fd, "About to write");
> 	write_to_file(fd, how_much, buf);
> }
> 
> int main(int argc, char *argv[])
> {
> 	void *buf;
> 	/*
> 	 * O_DIRECT requires at least 512 B alighnment, but runs faster
> 	 * (2.8 sec, vs. 3.5 sec) with 4096 B alignment.
> 	 */
> 	unsigned align = 4096;
> 	posix_memalign(&buf, align, BUF_SIZE );
> 
> 	if (argc < 3) {
> 		printf("Usage: %s <filename> <iterations>\n", argv[0]);
> 		return 1;
> 	}
> 	char *filename = argv[1];
> 	unsigned iterations = strtoul(argv[2], 0, 0);
> 
> 	/* Not using O_SYNC for now, anyway. */
> 	int fd = open(filename, O_DIRECT | O_RDWR);
> 	if (fd < 0) {
> 		printf("Failed to open %s: %m\n", filename);
> 		return 2;
> 	}
> 
> 	printf("File: %s, data size: %u, interations: %u\n",
> 		       filename, FULL_DATA_SIZE, iterations);
> 
> 	for (int count = 0; count < iterations; count++) {
> 		read_and_write(fd, FULL_DATA_SIZE, buf);
> 	}
> 
> 	close(fd);
> 	return 0;
> }
> 
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
