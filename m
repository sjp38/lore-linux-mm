Subject: Re: vm_ops.page_mkwrite() fails with vmalloc on 2.6.23
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <45a44e480710290117u492dbe82ra6344baf8bb1e370@mail.gmail.com>
References: <1193064057.16541.1.camel@matrix>
	 <20071029004002.60c7182a.akpm@linux-foundation.org>
	 <45a44e480710290117u492dbe82ra6344baf8bb1e370@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 29 Oct 2007 11:11:57 +0100
Message-Id: <1193652717.27652.45.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stefani@seibold.net, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-10-29 at 01:17 -0700, Jaya Kumar wrote:
> On 10/29/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Mon, 22 Oct 2007 16:40:57 +0200 Stefani Seibold <stefani@seibold.net> wrote:
> > >
> > > The problem original occurs with the fb_defio driver (driver/video/fb_defio.c).
> > > This driver use the vm_ops.page_mkwrite() handler for tracking the modified pages,
> > > which will be in an extra thread handled, to perform the IO and clean and
> > > write protect all pages with page_clean().
> > >
> 
> Hi,
> 
> An aside, I just tested that deferred IO works fine on 2.6.22.10/pxa255.
> 
> I understood from the thread that PeterZ is looking into page_mkclean
> changes which I guess went into 2.6.23. I'm also happy to help in any
> way if the way we're doing fb_defio needs to change.

Yeah, its the truncate race stuff introduced by Nick in
  d0217ac04ca6591841e5665f518e38064f4e65bd

I'm a bit at a loss on how to go around fixing this. One ugly idea I had
was to check page->mapping before going into page_mkwrite() and when
that is null, don't bother with the truncate check.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
