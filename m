Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 2F8FE6B007D
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 17:16:18 -0400 (EDT)
Date: Thu, 15 Aug 2013 14:16:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] Fix aio performance regression for database caused
 by THP
Message-Id: <20130815141616.6cf60a354b9a92214ac0c246@linux-foundation.org>
In-Reply-To: <1376590389.24607.33.camel@concerto>
References: <1376590389.24607.33.camel@concerto>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: aarcange@redhat.com, hannes@cmpxchg.org, mgorman@suse.de, riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Thu, 15 Aug 2013 12:13:09 -0600 Khalid Aziz <khalid.aziz@oracle.com> wrote:

> I am working with a tool that simulates oracle database I/O workload.
> This tool (orion to be specific -
> <http://docs.oracle.com/cd/E11882_01/server.112/e16638/iodesign.htm#autoId24>) allocates hugetlbfs pages using shmget() with SHM_HUGETLB flag. It then does aio into these pages from flash disks using various common block sizes used by database. I am looking at performance with two of the most common block sizes - 1M and 64K. aio performance with these two block sizes plunged after Transparent HugePages was introduced in the kernel. Here are performance numbers:
> 
> 		pre-THP		2.6.39		3.11-rc5
> 1M read		8384 MB/s	5629 MB/s	6501 MB/s
> 64K read	7867 MB/s	4576 MB/s	4251 MB/s
> 
> I have narrowed the performance impact down to the overheads introduced
> by THP in __get_page_tail() and put_compound_page() routines. perf top
> shows >40% of cycles being spent in these two routines. Every time
> direct I/O to hugetlbfs pages starts, kernel calls get_page() to grab a
> reference to the pages and calls put_page() when I/O completes to put
> the reference away. THP introduced significant amount of locking
> overhead to get_page() and put_page() when dealing with compound pages
> because hugepages can be split underneath get_page() and put_page(). It
> added this overhead irrespective of whether it is dealing with hugetlbfs
> pages or transparent hugepages. This resulted in 20%-45% drop in aio
> performance when using hugetlbfs pages.
> 
> Since hugetlbfs pages can not be split, there is no reason to go through
> all the locking overhead for these pages from what I can see. I added
> code to __get_page_tail() and put_compound_page() to bypass all the
> locking code when working with hugetlbfs pages. This improved
> performance significantly. Performance numbers with this patch:
> 
> 		pre-THP		3.11-rc5	3.11-rc5 + Patch
> 1M read		8384 MB/s	6501 MB/s	8371 MB/s
> 64K read	7867 MB/s	4251 MB/s	6510 MB/s
> 
> Performance with 64K read is still lower than what it was before THP,
> but still a 53% improvement. It does mean there is more work to be done
> but I will take a 53% improvement for now.
> 
> Please take a look at the following patch and let me know if it looks
> reasonable.

Pretty convincing.

I tagged this for a -stable backport.  To allow time for review and
testing I'll plan to merge the patch into 3.12-rc1, so it should
materialize in 3.11.x (and hopefully earlier) stable kernels after that.

To facilitate backporting the patch could have been quite a bit
smaller, with some simple restructuring.  It applies OK to 3.10, but
not 3.9.  Hopefully that's good enough...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
