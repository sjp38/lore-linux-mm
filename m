Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 358B86B000A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 02:10:16 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id 141-v6so6891142ywr.10
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 23:10:16 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id w8-v6si13915493ybo.51.2018.11.04.23.10.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Nov 2018 23:10:14 -0800 (PST)
Subject: Re: [PATCH 4/6] mm: introduce page->dma_pinned_flags, _count
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-5-jhubbard@nvidia.com> <20181013035516.GA18822@dastard>
 <7c2e3b54-0b1d-6726-a508-804ef8620cfd@nvidia.com>
 <20181013164740.GA6593@infradead.org>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <84811b54-60bf-2bc3-a58d-6a7925c24aad@nvidia.com>
Date: Sun, 4 Nov 2018 23:10:12 -0800
MIME-Version: 1.0
In-Reply-To: <20181013164740.GA6593@infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason
 Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 10/13/18 9:47 AM, Christoph Hellwig wrote:
> On Sat, Oct 13, 2018 at 12:34:12AM -0700, John Hubbard wrote:
>> In patch 6/6, pin_page_for_dma(), which is called at the end of get_user_pages(),
>> unceremoniously rips the pages out of the LRU, as a prerequisite to using
>> either of the page->dma_pinned_* fields. 
>>
>> The idea is that LRU is not especially useful for this situation anyway,
>> so we'll just make it one or the other: either a page is dma-pinned, and
>> just hanging out doing RDMA most likely (and LRU is less meaningful during that
>> time), or it's possibly on an LRU list.
> 
> Have you done any benchmarking what this does to direct I/O performance,
> especially for small I/O directly to a (fast) block device?
> 

Hi Christoph,

I'm seeing about 20% slower in one case: lots of reads and writes of size 8192 B,
on a fast NVMe device. My put_page() --> put_user_page() conversions are incomplete 
and buggy yet, but I've got enough of them done to briefly run the test.

One thing that occurs to me is that jumping on and off the LRU takes time, and
if we limited this to 64-bit platforms, maybe we could use a real page flag? I 
know that leaves 32-bit out in the cold, but...maybe use this slower approach
for 32-bit, and the pure page flag for 64-bit? uggh, we shouldn't slow down anything
by 20%. 

Test program is below. I hope I didn't overlook something obvious, but it's 
definitely possible, given my lack of experience with direct IO. 

I'm preparing to send an updated RFC this week, that contains the feedback to date,
and also many converted call sites as well, so that everyone can see what the whole
(proposed) story would look like in its latest incarnation.

#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

const static unsigned BUF_SIZE       = 4096;
static const unsigned FULL_DATA_SIZE = 2 * BUF_SIZE;

void read_from_file(int fd, size_t how_much, char * buf)
{
	size_t bytes_read;

	for (size_t index = 0; index < how_much; index += BUF_SIZE) {
		bytes_read = read(fd, buf, BUF_SIZE);
		if (bytes_read != BUF_SIZE) {
			printf("reading file failed: %m\n");
			exit(3);
		}
	}
}

void seek_to_start(int fd, char *caller)
{
	off_t result = lseek(fd, 0, SEEK_SET);
	if (result == -1) {
		printf("%s: lseek failed: %m\n", caller);
		exit(4);
	}
}

void write_to_file(int fd, size_t how_much, char * buf)
{
	int result;
	for (size_t index = 0; index < how_much; index += BUF_SIZE) {
		result = write(fd, buf, BUF_SIZE);
		if (result < 0) {
			printf("writing file failed: %m\n");
			exit(3);
		}
	}
}

void read_and_write(int fd, size_t how_much, char * buf)
{
	seek_to_start(fd, "About to read");
	read_from_file(fd, how_much, buf);

	memset(buf, 'a', BUF_SIZE);

	seek_to_start(fd, "About to write");
	write_to_file(fd, how_much, buf);
}

int main(int argc, char *argv[])
{
	void *buf;
	/*
	 * O_DIRECT requires at least 512 B alighnment, but runs faster
	 * (2.8 sec, vs. 3.5 sec) with 4096 B alignment.
	 */
	unsigned align = 4096;
	posix_memalign(&buf, align, BUF_SIZE );

	if (argc < 3) {
		printf("Usage: %s <filename> <iterations>\n", argv[0]);
		return 1;
	}
	char *filename = argv[1];
	unsigned iterations = strtoul(argv[2], 0, 0);

	/* Not using O_SYNC for now, anyway. */
	int fd = open(filename, O_DIRECT | O_RDWR);
	if (fd < 0) {
		printf("Failed to open %s: %m\n", filename);
		return 2;
	}

	printf("File: %s, data size: %u, interations: %u\n",
		       filename, FULL_DATA_SIZE, iterations);

	for (int count = 0; count < iterations; count++) {
		read_and_write(fd, FULL_DATA_SIZE, buf);
	}

	close(fd);
	return 0;
}


thanks,
-- 
John Hubbard
NVIDIA
