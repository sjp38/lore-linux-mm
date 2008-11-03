Message-ID: <490F8005.9020708@redhat.com>
Date: Mon, 03 Nov 2008 17:49:41 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: mmap: is default non-populating behavior stable?
References: <490F73CD.4010705@gmail.com> <1225752083.7803.1644.camel@twins>
In-Reply-To: <1225752083.7803.1644.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Eugene V. Lyubimkin" <jackyf.devel@gmail.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, hugh <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Mon, 2008-11-03 at 23:57 +0200, Eugene V. Lyubimkin wrote:
>> Hello kernel hackers!
>>
>> The current implementation of mmap() in kernel is very convenient.
>> It allows to mmap(fd) very big amount of memory having small file as back-end.
>> So one can mmap() 100 MiB on empty file, use first 10 KiB of memory, munmap() and have
>> only 10 KiB of file at the end. And while working with memory, file will automatically be
>> grown by read/write memory requests.
>>
>> Question is: can user-space application rely on this behavior (I failed to find any
>> documentation about this)?
>>
>> TIA and please CC me in replies.
> 
> mmap() writes past the end of the file should not grow the file if I
> understand things write, but produce a sigbus (after the first page size
> alignment).

Indeed, faulting beyond the end of file returns a SIGBUS,
see these lines in mm/filemap.c:filemap_fault():

         size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> 
PAGE_CACHE_SHIFT;
         if (vmf->pgoff >= size)
                 return VM_FAULT_SIGBUS;

> The exact interaction of mmap() and truncate() I'm not exactly clear on.

Truncate will reduce the size of the mmaps on the file to
match the new file size, so processes accessing beyond the
end of file will get a segmentation fault (SIGSEGV).

> The safe way to do things is to first create your file of at least the
> size you mmap, using truncate. This will create a sparse file, and will
> on any sane filesystem not take more space than its meta data.
> 
> Thereafter you can fill it with writes to the mmap.

Agreed.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
