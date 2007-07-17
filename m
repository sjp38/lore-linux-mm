Date: Mon, 16 Jul 2007 17:15:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] fix periodic superblock dirty inode flushing
Message-Id: <20070716171537.0a57e6e7.akpm@linux-foundation.org>
In-Reply-To: <b040c32a0707161701q49ad150di6387b029a39b39c3@mail.gmail.com>
References: <b040c32a0707112121y21d08438u8ca7f138931827b0@mail.gmail.com>
	<20070712120519.8a7241dd.akpm@linux-foundation.org>
	<b040c32a0707131517m4cc20d3an2123e324746d3e7@mail.gmail.com>
	<b040c32a0707161701q49ad150di6387b029a39b39c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Jul 2007 17:01:31 -0700
"Ken Chen" <kenchen@google.com> wrote:

> On 7/13/07, Ken Chen <kenchen@google.com> wrote:
> > On 7/12/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > > Was this tested in combination with check_dirty_inode_list.patch,
> > > to make sure that the time-orderedness is being retained?
> >
> > I think I tested with the debug patch.  And just to be sure, I ran the
> > test again with the time-order check in place.  It passed the test.
> 
> I ran some more tests over the weekend with the debug turned on. There
> are a few fall out that the order-ness of sb-s_dirty is corrupted.  We
> probably should drop this patch until I figure out a real solution to
> this.

drat.

> One idea is to use rb-tree for sorting and use a in-tree dummy node as
> a tree iterator.  Do you think that will work better?  I will hack on
> that.

Yeah, handling those list_heads is like juggling ten bars of soap.

I've long had vague thoughts that a new data structure is needed to fix all
this up.  But I was thinking radix-tree because radix-trees have the very
important characteristic that you can remember where you were up to when
you drop the lock, so you can trivially restart the search at the correct
place.  Although I never quiet worked out what an appropriate index would
be for that radix-tree.

I suppose we can do the same search-restarting with rb-trees, once we work
out what the index is.

It will all be a pretty big project - the *requirements* for that code are
long and complex, let alone the implementation, and the testing is tough. 
Probably we'd be better off finding some nasty hack to (yet again) paper up
the existing code while we have time to think about a reimplementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
