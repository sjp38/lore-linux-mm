Subject: Re: mmap: is default non-populating behavior stable?
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <490F73CD.4010705@gmail.com>
References: <490F73CD.4010705@gmail.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Mon, 03 Nov 2008 23:41:23 +0100
Message-Id: <1225752083.7803.1644.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eugene V. Lyubimkin" <jackyf.devel@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, hugh <hugh@veritas.com>, riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-11-03 at 23:57 +0200, Eugene V. Lyubimkin wrote:
> Hello kernel hackers!
> 
> The current implementation of mmap() in kernel is very convenient.
> It allows to mmap(fd) very big amount of memory having small file as back-end.
> So one can mmap() 100 MiB on empty file, use first 10 KiB of memory, munmap() and have
> only 10 KiB of file at the end. And while working with memory, file will automatically be
> grown by read/write memory requests.
> 
> Question is: can user-space application rely on this behavior (I failed to find any
> documentation about this)?
> 
> TIA and please CC me in replies.

mmap() writes past the end of the file should not grow the file if I
understand things write, but produce a sigbus (after the first page size
alignment).

The exact interaction of mmap() and truncate() I'm not exactly clear on.

The safe way to do things is to first create your file of at least the
size you mmap, using truncate. This will create a sparse file, and will
on any sane filesystem not take more space than its meta data.

Thereafter you can fill it with writes to the mmap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
