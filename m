Date: Thu, 11 Nov 2004 03:06:34 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: follow_page()
Message-Id: <20041111030634.1d06a7c1.akpm@osdl.org>
In-Reply-To: <1100170570.2646.27.camel@laptop.fenrus.org>
References: <20041111024015.7c50c13d.akpm@osdl.org>
	<1100170570.2646.27.camel@laptop.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Arjan van de Ven <arjan@infradead.org> wrote:
>
> On Thu, 2004-11-11 at 02:40 -0800, Andrew Morton wrote:
> > Can anyone think of a sane reason why this thing is marking the page dirty?
> > 
> > I mean, we're supposed to mark the page dirty _after_ modifying its
> > contents.
> 
> most likely it's because the intent to write to it is given.
> It's cheaper for the OS to mark a pagetable dirty than it's for the CPU
> to do so (example, on a Pentium 4 it can easily take the cpu 2000 to
> 4000 cycles to flip the dirty bit on the PTE). So if you KNOW you're
> going to write to it (and thus the intent parameter) you can save a big
> chunk of those cycles.

But it's racy.  writeback can write-and-clean the page before we've
modified its contents.  Whether the page contents are altered via disk DMA
or a memset or whatever, we can lose the data.  Except callers are
correctly dirtying the page after modifying it anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
