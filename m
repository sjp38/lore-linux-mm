Date: Fri, 15 Sep 2006 00:35:29 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] page fault retry with NOPAGE_RETRY
Message-Id: <20060915003529.8a59c542.akpm@osdl.org>
In-Reply-To: <20060915001151.75f9a71b.akpm@osdl.org>
References: <1158274508.14473.88.camel@localhost.localdomain>
	<20060915001151.75f9a71b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Mike Waychison <mikew@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 15 Sep 2006 00:11:51 -0700
Andrew Morton <akpm@osdl.org> wrote:

> b) It could be more efficient.  Most of the time, there's no need to
>    back all the way out of the pagefault handler and rerun the whole thing.
>    Because most of the time, nobody changed anything in the mm_struct.  We
>    _could_ just retake the mmap_sem after the page comes uptodate and, if
>    nothing has changed, proceed.  I see two ways of doing this:
> 
>    - The simple way: look to see if any other processes are sharing
>      this mm_struct.  If not, just do the synchronous read inside mmap_sem.

This assumes that no other heavyweight process will try to modify this
single-threaded process's mm.  I don't _think_ that happens anywhere, does
it?  access_process_vm() is the only case I can think of, and it does
down_read(other process's mmap_sem).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
