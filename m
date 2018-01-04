Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D04846B04C4
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 01:14:00 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f5so423673pgp.18
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 22:14:00 -0800 (PST)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTPS id r15si1648895pgu.379.2018.01.03.22.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 22:13:59 -0800 (PST)
Subject: Re: [PATCH] mm/fadvise: discard partial pages iff endbyte is also eof
References: <1514002568-120457-1-git-send-email-shidao.ytt@alibaba-inc.com>
 <8DAEE48B-AD5D-4702-AB4B-7102DD837071@alibaba-inc.com>
 <20180103104800.xgqe32hv63xsmsjh@techsingularity.net>
From: "=?UTF-8?B?5aS35YiZKENhc3Bhcik=?=" <jinli.zjl@alibaba-inc.com>
Message-ID: <7dd95219-f0be-b30a-0a43-2aadcc61899c@alibaba-inc.com>
Date: Thu, 04 Jan 2018 14:13:43 +0800
MIME-Version: 1.0
In-Reply-To: <20180103104800.xgqe32hv63xsmsjh@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, green@linuxhacker.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?UTF-8?B?5p2o5YuHKOaZuuW9uyk=?= <zhiche.yy@alibaba-inc.com>, =?UTF-8?B?5Y2B5YiA?= <shidao.ytt@alibaba-inc.com>



On 2018/1/3 18:48, Mel Gorman wrote:
> On Wed, Jan 03, 2018 at 02:53:43PM +0800, ??????(Caspar) wrote:
>>
>>
>>> ?? 2017??12??23????12:16?????? <shidao.ytt@alibaba-inc.com> ??????
>>>
>>> From: "shidao.ytt" <shidao.ytt@alibaba-inc.com>
>>>
>>> in commit 441c228f817f7 ("mm: fadvise: document the
>>> fadvise(FADV_DONTNEED) behaviour for partial pages") Mel Gorman
>>> explained why partial pages should be preserved instead of discarded
>>> when using fadvise(FADV_DONTNEED), however the actual codes to calcuate
>>> end_index was unexpectedly wrong, the code behavior didn't match to the
>>> statement in comments; Luckily in another commit 18aba41cbf
>>> ("mm/fadvise.c: do not discard partial pages with POSIX_FADV_DONTNEED")
>>> Oleg Drokin fixed this behavior
>>>
>>> Here I come up with a new idea that actually we can still discard the
>>> last parital page iff the page-unaligned endbyte is also the end of
>>> file, since no one else will use the rest of the page and it should be
>>> safe enough to discard.
>>
>> +akpm...
>>
>> Hi Mel, Andrew:
>>
>> Would you please take a look at this patch, to see if this proposal
>> is reasonable enough, thanks in advance!
>>
> 
> I'm backlogged after being out for the Christmas. Superficially the patch
> looks ok but I wondered how often it happened in practice as we already
> would discard files smaller than a page on DONTNEED. It also requires

Actually, we would *not*. Let's look into the codes.

Clue 1: start_index is a round-up page-aligned addr and end_index is a 
round-down page-aligned addr, while offset & endbyte might be unaligned 
obviously (mm/fadvise.c):

       start_index = (offset+(PAGE_SIZE-1)) >> PAGE_SHIFT;
       end_index = (endbyte >> PAGE_SHIFT);
       if ((endbyte & ~PAGE_MASK) != ~PAGE_MASK) {
          /* First page is tricky as 0 - 1 = -1, but pgoff_t
           * is unsigned, so the end_index >= start_index
           * check below would be true and we'll discard the whole
           * file cache which is not what was asked.
           */
          if (end_index == 0)
             break;

          end_index--;
       }

       if (end_index >= start_index) {
          <snip>
          count = invalidate_mapping_pages(mapping,
                   start_index, end_index);
          <snip>


Clue 2: looking into invalidate_mapping_pages() definition in 
mm/truncate.c, we see the end_index is included:

     * @end: the offset 'to' which to invalidate (inclusive)

Now we know:

+ if `offset' is an unaligned addr, the start partial page will not be 
discarded,
+ if `endbyte' is not aligned: behaviors before and after commit 
18aba41cbf ("mm/fadvise.c: do not discard partial pages with 
POSIX_FADV_DONTNEED") are different.
  + before: end_index is the start addr of the last partial page, thus 
the whole page will be invalidated according to 
invalidate_mapping_page() comments and implementation;
  + after: in commit 18aba41cbf, `endbyte' gets checked again, if it is 
not aligned, draw back by one page so that the partial page would not be 
included; and a special case is that if end_index == 0, means the length 
mapped less than a single page, the code just breaks and never runs into 
invalidate_mapping_pages().

We have done some experiments based on an opensource tool vmtouch[1], to 
simplify the reproducer, I also make a simple .c program [2]. Here is 
the output:

* Test 1, upstream:

[root@caspar ~]# uname -r
4.15.0-rc6+

[root@caspar ~]# dd if=/dev/zero of=testfile_1k bs=1k count=1
1+0 records in
1+0 records out
1024 bytes (1.0 kB) copied, 0.000852646 s, 1.2 MB/s

[root@caspar ~]# ./test_fadvise testfile_1k
file size: 1024 Bytes
length of pages: 1
start addr of mmap: 0x7f7aa0f1b000
do posix_fadvise(DONTNEED)
still resident in memory?
vec[0]: 1

[root@caspar ~]# dd if=/dev/zero of=testfile_10k bs=1k count=10
10+0 records in
10+0 records out
10240 bytes (10 kB) copied, 0.000931652 s, 11.0 MB/s

[root@caspar ~]# ./test_fadvise testfile_10k
file size: 10240 Bytes
length of pages: 3
start addr of mmap: 0x7ff57de8f000
do posix_fadvise(DONTNEED)
still resident in memory?
vec[0]: 0
vec[1]: 0
vec[2]: 1

* Test 2, reverted 18aba41cbf

[root@caspar ~]# uname -r
4.15.0-rc6.revert+

[root@caspar ~]# dd if=/dev/zero of=testfile_10k bs=1k count=1
1+0 records in
1+0 records out
1024 bytes (1.0 kB) copied, 0.000858957 s, 1.2 MB/s

[root@caspar ~]# ./test_fadvise testfile_1k
file size: 1024 Bytes
length of pages: 1
start addr of mmap: 0x7f07fe08b000
do posix_fadvise(DONTNEED)
still resident in memory?
vec[0]: 0

[root@caspar ~]# dd if=/dev/zero of=testfile_10k bs=1k count=10
10+0 records in
10+0 records out
10240 bytes (10 kB) copied, 0.00083475 s, 12.3 MB/s
[root@caspar ~]# ./test_fadvise testfile_10k
file size: 10240 Bytes
length of pages: 3
start addr of mmap: 0x7f6a49541000
do posix_fadvise(DONTNEED)
still resident in memory?
vec[0]: 0
vec[1]: 0
vec[2]: 0

* Test 3, patched with our original proposal

[root@caspar ~]# uname -r
4.15.0-rc6.patched+

[root@caspar ~]# dd if=/dev/zero of=testfile_1k bs=1k count=1
1+0 records in
1+0 records out
1024 bytes (1.0 kB) copied, 0.000852275 s, 1.2 MB/s

[root@caspar ~]# ./test_fadvise testfile_1k
file size: 1024 Bytes
length of pages: 1
start addr of mmap: 0x7f0ef6407000
do posix_fadvise(DONTNEED)
still resident in memory?
vec[0]: 0

[root@caspar ~]# dd if=/dev/zero of=testfile_10k bs=1k count=10
10+0 records in
10+0 records out
10240 bytes (10 kB) copied, 0.000939927 s, 10.9 MB/s

[root@caspar ~]# ./test_fadvise testfile_10k
file size: 10240 Bytes
length of pages: 3
start addr of mmap: 0x7f9fb70f1000
do posix_fadvise(DONTNEED)
still resident in memory?
vec[0]: 0
vec[1]: 0
vec[2]: 0

Our analysis matches what we observed from the output, in the latest 
upstream codes, none partial pages would be discarded even it's the 
everything of a less-than-4k file.

> that the system call get the exact size of the file correct and would not
> discard if the off + len was past the end of the file for whatever reason
> (e.g. a stat to read the size, a truncate in parallel and fadvise using
> stale data from stat) and that's why the patch looked like it might have
> no impact in practice. Is the patch known to help a real workload or is
> it motivated by a code inspection?

This patch is trying to help to solve a real issue. Sometimes we need to 
evict the whole file from page cache because we are sure it will not be 
used in the near future. We try to use posix_fadvise() to finish our 
work but we often see a "small tail" at the end of some files could not 
be evicted, after digging a little bit, we find those file sizes are not 
page-aligned and the "tail" turns out to be partial pages.

We fail to find a standard from posix_fadvise() manual page to subscribe 
the function behaviors if the `offset' and `len' params are not 
page-aligned, then we go to kernel tree and see this:

         /*
          * First and last FULL page! Partial pages are deliberately
          * preserved on the expectation that it is better to preserve
          * needed memory than to discard unneeded memory.
          */

So we know the left of partial page is most likely to be a by-design 
behavior, but is it really necessary when it is at the end of the file? 
We know that the rest of the partial page will be unlikely to be used 
and it should be safe enough to discard the whole page, thus, here is 
the patch.

Comments?

Thanks,
Caspar

> 

[1] https://hoytech.com/vmtouch/

[2] reproducer (test_fadvise.c):

#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>


int main(int argc, char **argv)
{
	int i, fd, ret, len;
	struct stat buf;
	void *addr;
	unsigned char *vec;
	ssize_t pagesize = getpagesize();

	fd = open(argv[1], O_RDWR);
	if (fd < 0)
		return -1;

	ret = fstat(fd, &buf);
	if (ret < 0)
		return -1;
	printf("file size: %u Bytes\n", buf.st_size);

	len = (buf.st_size + pagesize - 1) / pagesize;
	printf("length of pages: %d\n", len);

	addr = mmap(NULL, buf.st_size, PROT_READ, MAP_SHARED, fd, 0);
	if (addr == MAP_FAILED)
		return -1;
	printf("start addr of mmap: %p\n", addr);

	ret = posix_fadvise(fd, 0, buf.st_size, POSIX_FADV_DONTNEED);
	if (ret < 0)
		return -1;

	printf("still resident in memory?\n");
	vec = malloc(len);
	ret = mincore(addr, buf.st_size, (void *)vec);
	if (ret < 0)
		return -1;
	for (i = 0; i < len; i++)
		printf("vec[%d]: %x\n", i, vec[i] & 0x1);
	free(vec);
	
	close(fd);
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
