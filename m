Date: Fri, 21 Nov 2008 23:15:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
Message-Id: <20081121231511.ce59702e.akpm@linux-foundation.org>
In-Reply-To: <604427e00811212247k1fe6b63u9efe8cfe37bddfb5@mail.gmail.com>
References: <604427e00811212247k1fe6b63u9efe8cfe37bddfb5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Waychison <mikew@google.com>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Nov 2008 22:47:44 -0800 Ying Han <yinghan@google.com> wrote:

> page fault retry with NOPAGE_RETRY
> Allow major faults to drop the mmap_sem read lock while waitting for
> synchronous disk read. This allows another thread which wishes to grab
> down_read(mmap_sem) to proceed while the current is waitting the disk IO.

Confused.  down_read() on an rwsem will already permit multiple threads
to run that section of ccode concurrently.

The benefit here will be to permit down_write() callers (eg:
sys_mmap()) to get in there and do work.

> The patch flags current->flags to PF_FAULT_MAYRETRY as identify that the
> caller can tolerate the retry in the filemap_fault call patch.
> 
> Benchmark is done by mmap in huge file and spaw 64 thread each faulting in
> pages in reverse order, the the result shows 8% porformance hit with the
> patch.

You mean it slowed down 8%?  I'm a bit surprised - I'd have expected a
smaller slowdown for an IO-intensive thing like this.

Does it speed anything up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
