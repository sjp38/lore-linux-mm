Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [PATCH] slabasap-mm5_A2
Date: Sun, 8 Sep 2002 17:48:19 -0400
References: <200209071006.18869.tomlins@cam.org> <200209081714.54110.tomlins@cam.org> <3D7BC58F.D8AC82E8@digeo.com>
In-Reply-To: <3D7BC58F.D8AC82E8@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209081748.19674.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On September 8, 2002 05:47 pm, Andrew Morton wrote:
> Ed Tomlinson wrote:

This was getting a little massive so I trimmed.

> > I have a small optimization coded in slab.  If there are not any free
> > slab objects I do not free the page.   If we have problems with high
> > order slabs we can change this to be if we do not have <n> objects
> > do not free it.
>
> OK.

> > OK will change this.  This also means the changes to prune functions
> > made for slablru will come back - they convert these fuctions so they
> > age <n> object rather than purge <n>.
>
> That would make the slab pruning less aggressive than the code I'm
> testing now.  I'm not sure it needs that change.  Not sure...

Well without this change slab sometimes really get hurt.  It took me a while
to figure out what was happening in when I coded slablru.  In any case you
do have the code to fix it.

> > Ah thanks.  Was wondering the best way to do this.  Will read the code.
>
> Then again, shrinking slab harder for big highmem machines is good ;)

That was Rik's comment too...  Just figured it best to mention the options.

> But the prunes are miles too small at present.  We go into
> try_to_free_pages() and reclaim 32 pages.  And we also call into
> prune_cache() and free about 0.3 pages.  It's out of whack.  I'd suggest
> not calling out to the pruner until we want at least several pages' worth
> of objects.

Agreed.  I had not quite digested your last comments when I wrote this.  
Once we are happy I will readd the callbacks (using a second call to set
the callback - btw I have some nice oak hiking sticks here...) and fix this 
as you sugested.

> > The other thing we want to be careful with is to make sure the lack of
> > free page accounting is detected by oom - we definitly do not want to
> > oom when slab has freed memory by try_to_free_pages does not
> > realize it..
>
> How much memory are we talking about here?  Not much I think?

Usually not much.  I do know that when Rik added my slab accounting to rmap
the number of oom reports dropped.  We just need to be aware there is a 
hole and there might be a small problem.

> > This converts the prunes in inode and dcache to age <n> entries rather
> > than purge them.  Think this is the more correct behavior.  Code is from
> > slablru.
>
> Makes sense (I think).

As I mentioned above I needed this to make slablru stable...  Might be since you
now limit the number of pages scanned to 2*nr_pages we can get away without
this - not at all sure though.  Going back the basics.  Without this are we not 
devaluating seeks required to rebuild slab objects vs lru pages?

Ed












--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
