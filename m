From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH resend] ramdisk: fix zeroed ramdisk pages on memory pressure
Date: Tue, 16 Oct 2007 16:45:58 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <200710160123.32434.nickpiggin@yahoo.com.au> <m1zlyjiwdc.fsf@ebiederm.dsl.xmission.com>
In-Reply-To: <m1zlyjiwdc.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710161645.58686.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

On Tuesday 16 October 2007 13:14, Eric W. Biederman wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> writes:
> > On Monday 15 October 2007 19:16, Andrew Morton wrote:
> >> On Tue, 16 Oct 2007 00:06:19 +1000 Nick Piggin <nickpiggin@yahoo.com.au>
> >
> > wrote:
> >> > On Monday 15 October 2007 18:28, Christian Borntraeger wrote:
> >> > > Andrew, this is a resend of a bugfix patch. Ramdisk seems a bit
> >> > > unmaintained, so decided to sent the patch to you :-).
> >> > > I have CCed Ted, who did work on the code in the 90s. I found no
> >> > > current email address of Chad Page.
> >> >
> >> > This really needs to be fixed...
> >>
> >> rd.c is fairly mind-boggling vfs abuse.
> >
> > Why do you say that? I guess it is _different_, by necessity(?)
> > Is there anything that is really bad?
>
> make_page_uptodate() is most hideous part I have run into.
> It has to know details about other layers to now what not
> to stomp.  I think my incorrect simplification of this is what messed
> things up, last round.

Not really, it's just named funny. That's just a minor utility
function that more or less does what it says it should do.

The main problem is really that it's implementing a block device
who's data comes from its own buffercache :P. I think.


> > I guess it's not nice
> > for operating on the pagecache from its request_fn, but the
> > alternative is to duplicate pages for backing store and buffer
> > cache (actually that might not be a bad alternative really).
>
> Cool. Triple buffering :)  Although I guess that would only
> apply to metadata these days.

Double buffering. You no longer serve data out of your buffer
cache. All filesystem data was already double buffered anyway,
so we'd be just losing out on one layer of savings for metadata.
I think it's worthwhile, given that we'd have a "real" looking
block device and minus these bugs.


> Having a separate store would 
> solve some of the problems, and probably remove the need
> for carefully specifying the ramdisk block size.  We would
> still need the magic restictions on page allocations though
> and it we would use them more often as the initial write to the
> ramdisk would not populate the pages we need.

What magic restrictions on page allocations? Actually we have
fewer restrictions on page allocations because we can use
highmem! And the lowmem buffercache pages that we currently pin
(unsuccessfully, in the case of this bug) are now completely
reclaimable. And all your buffer heads are now reclaimable.

If you mean GFP_NOIO... I don't see any problem. Block device
drivers have to allocate memory with GFP_NOIO; this may have
been considered magic or deep badness back when the code was
written, but it's pretty simple and accepted now.


> A very ugly bit seems to be the fact that we assume we can
> dereference bh->b_data without any special magic which
> means the ramdisk must live in low memory on 32bit machines.

Yeah but that's not rd.c. You need to rewrite the buffer layer
to fix that (see fsblock ;)).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
