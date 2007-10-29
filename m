Subject: Re: vm_ops.page_mkwrite() fails with vmalloc on 2.6.23
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <45a44e480710290117u492dbe82ra6344baf8bb1e370@mail.gmail.com>
References: <1193064057.16541.1.camel@matrix>
	 <20071029004002.60c7182a.akpm@linux-foundation.org>
	 <45a44e480710290117u492dbe82ra6344baf8bb1e370@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 29 Oct 2007 18:01:42 +0100
Message-Id: <1193677302.27652.56.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stefani@seibold.net, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org
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

> An aside, I just tested that deferred IO works fine on 2.6.22.10/pxa255.
> 
> I understood from the thread that PeterZ is looking into page_mkclean
> changes which I guess went into 2.6.23. I'm also happy to help in any
> way if the way we're doing fb_defio needs to change.

OK, seems I can't read. Or at least, I missed a large part of the
problem.

page_mkclean() hasn't changed, it was ->page_mkwrite() that changed. And
looking at the fb_defio code, I'm not sure I understand how its
page_mkclean() use could ever have worked.

The proposed patch [1] only fixes the issue of ->page_mkwrite() on
vmalloc()'ed memory. Not page_mkclean(), and that has never worked from
what I can make of it.

Jaya, could you shed some light on this? I presume you had your display
working.


[1] which I will clean up and resend after this issue is cleared up -
and preferably tested by someone who has this hardware.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
