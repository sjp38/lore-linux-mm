Return-Path: <owner-linux-mm@kvack.org>
Date: Thu, 19 Dec 2013 13:29:21 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: bad page state in 3.13-rc4
Message-ID: <20131219182920.GG30640@kvack.org>
References: <20131219040738.GA10316@redhat.com> <CA+55aFwweoGs3eGWXFULcqnbRbpDhpj2qrefXB5OpQOiWW8wYA@mail.gmail.com> <20131219155313.GA25771@redhat.com> <CA+55aFyoXCDNfHb+r5b=CgKQLPA1wrU_Tmh4ROZNEt5TPjpODA@mail.gmail.com> <20131219181134.GC25385@kmo-pixel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131219181134.GC25385@kmo-pixel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <kmo@daterainc.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Al Viro <viro@zeniv.linux.org.uk>

On Thu, Dec 19, 2013 at 10:11:34AM -0800, Kent Overstreet wrote:
> On Thu, Dec 19, 2013 at 09:07:27AM -0800, Linus Torvalds wrote:
> > On Thu, Dec 19, 2013 at 7:53 AM, Dave Jones <davej@redhat.com> wrote:
> > >
> > > Interesting that CPU2 was doing sys_io_setup again. Different trace though.
> > 
> > Well, it was once again in aio_free_ring() - double free or freeing
> > while already in use? And this time the other end of the complaint was
> > allocating a new page that definitely was still busily in use (it's
> > locked).
> > 
> > And there's no sign of migration, although obviously that could have
> > happened or be in progress on another CPU and just didn't notice the
> > mess. But yes, based on the two traces, fs/aio.c:io_setup() would seem
> > to be the main point of interest.
> > 
> > Have you started doing something new in trinity wrt AIO, and
> > io_setup() in particular? Or anything else different that might have
> > started triggering this?
> > 
> > But we do have new AIO code, and these two in particular look suspicious:
> > 
> >  - new page migration logic:
> > 
> >     71ad7490c1f3 rework aio migrate pages to use aio fs
> > 
> >  - trying to fix double frees and error cases:
> > 
> >     e34ecee2ae79 aio: Fix a trinity splat
> >     d558023207e0 aio: prevent double free in ioctx_alloc
> >     d1b9432712a2 aio: clean up aio ring in the fail path
> > 
> > and some kind of double free in an error path would certainly explain
> > this (with io_setup() . And the first oops reported obviously had that
> > migration thing. So maybe those "fixes" weren't fixing things at all
> > (or just moved the error case around).
> > 
> > Btw, that "rework aio migrate pages to use aio fs" looks odd. It has
> > Ben LaHaise marked as author, but no sign-off, instead "Tested-by" and
> > "Acked-by".
> 
> I could certainly believe a double free, but rereading the current code
> I can't find anything, and I just manually tested all the relevant error
> paths in ioctx_alloc() and aio_setup_ring() without finding anything.

The same here.  It would be very helpful to know what syscalls trinity is 
issuing in the lead up to the bug.

> I don't get wtf that loop at line 350 is supposed to be for though.
> You'd think if it was doing anything important it would be doing
> something more intelligent than just breaking on error (?). But I
> haven't slept yet and maybe I'm just being dumb.

The loop at 350 is just instantiating the page cache pages for the ring 
buffer with freshly zeroed pages.

> I don't understand this page migration stuff at all, and I actually
> don't think I understand the refcounting w.r.t. the page cache either.
> But looking at (say) the aio_free_ring() call at line 409 - we just did
> one put_page() in aio_setup_ring(), and then _another_ put_page() in
> aio_free_ring()... ok, one of those corresponds to the get
> get_user_pages() did, but what's the other correspond to?

The second put_page() should be dropping the page from the page cache.  
Perhaps it would be better to rely on a truncate of the file to remove the 
pages from the page cache.  I'd hoped someone with a clue about how 
migration is supposed to work would have chimed in during the review, but 
nobody has stepped up with expertise in this area yet.

		-ben
-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
