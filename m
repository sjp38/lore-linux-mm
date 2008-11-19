From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
Date: Wed, 19 Nov 2008 15:25:59 +1100
References: <491DAF8E.4080506@quantum.com>
In-Reply-To: <491DAF8E.4080506@quantum.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200811191526.00036.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim LaBerge <tim.laberge@quantum.com>, "Arcangeli, Andrea" <aarcange@redhat.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Saturday 15 November 2008 04:04, Tim LaBerge wrote:

> However, it appears that data corruption may occur when a multithreaded
> process reads into a non-page size aligned user buffer. A test program
> which reliably reproduces the problem on ext3 and xfs is attached.
>
> The program creates, patterns, reads, and verify a series of files.
>
> In the read phase, a file is opened with O_DIRECT n times, where n is the
> number of cpu's. A single buffer large enough to contain the file is
> allocated
> and patterned with data not found in any of the files. The alignment of the
> buffer is controlled by a command line option.
>
> Each file is read in parallel by n threads, where n is the number of cpu's.
> Thread 0 reads the first page of data from the file into the first page
> of the buffer, thread 1 reads the second page of data in to the second
> page of
> the buffer, and so on.  Thread n - 1 reads the remainder of the file
> into the
> remainder of the buffer.
>
> After a thread reads data into the buffer, it immediately verifies that the
> contents of the buffer are correct. If the buffer contains corrupt data,
> the thread dumps the data surrounding the corruption and calls abort().
> Otherwise,
> the thread exits.
>
> Crucially, before the reader threads are dispatched, another thread is
> started
> which calls fork()/msleep() in a loop until all reads are completed. The
> child
> created by fork() does nothing but call exit(0).
>
> A command line option controls whether the buffer is aligned.  In the
> case where
> the buffer is aligned on a page boundary, all is well. In the case where
> the buffer is aligned on a page + 512 byte offset, corruption is seen
> frequently.
>
> I believe that what is happening is that in the direct IO path, because the
> user's buffer is not aligned, some user pages are being mapped twice. When
> a fork() happens in between the calls to map the page, the page will be
> marked as
> COW. When the second map happens (via get_user_pages()), a new physical
> page will be allocated and copied.
>
> Thus, there is a race between the completion of the first read from disk
> (and
> write to the user page) and get_user_pages() mapping the page for the
> second time. If the write does not complete before the page is copied, the
> user will
> see stale data in the first 512 bytes of this page of their buffer. Indeed,
> this is corruption most frequently seen. (It's also possible for the
> race to be
> lost the other way, so that the last 3584 bytes of the page are stale.)
>
> The attached program dma_thread.c (which is a heavily modified version of a
> program provided by a customer seeing this problem) reliably reproduces the
> problem on any multicore linux machine on both ext3 and xfs, although any
> filesystem using the generic blockdev_direct_IO() routine is probably
> vulnerable.
>
> I've seen a few threads that mention the potential for this kind of
> problem, but no
> definitive solution or workaround (other than "Don't do that").

I think your analysis is correct. It is in the same class of problems
that Andrea identified with fork and COW vs get_user_pages().

(I'm sorry Andrea for being really slow in participating in that thread,
I've just been spending some time tinkering and thinking, but I'll
reply soon...)

The solution either involves synchronising forks and get_user_pages,
or probably better, to do copy on fork rather than COW in the case
that we detect a page is subject to get_user_pages. The trick is in
the details :)

Thanks for the test program though, that's something I hadn't actually
written myself yet so that's really useful.

For the moment (and previous kernels up to now), I guess you have to
be careful about fork and get_user_pages, unfortunately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
