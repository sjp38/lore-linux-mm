Date: Sun, 7 May 2000 11:43:33 +0100
From: Steve Dodd <steved@loth.demon.co.uk>
Subject: Re: [PATCH] address_space_operations unification
Message-ID: <20000507114333.A342@loth.demon.co.uk>
References: <Pine.LNX.4.10.10005061556040.701-100000@aviro.devel.redhat.com> <Pine.LNX.4.10.10005061749080.29159-100000@cesium.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.10005061749080.29159-100000@cesium.transmeta.com>; from Linus Torvalds on Sat, May 06, 2000 at 06:29:51PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alexander Viro <aviro@redhat.com>, "Roman V. Shaposhnick" <vugluskr@unicorn.math.spbu.ru>, linux-fsdevel@vger.rutgers.edu, linux-kernel@vger.rutgers.edu, trond.myklebust@fys.uio.no, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[linux-mm added to the mix]

[..]
>  - remove "file" from the argument list, replacing it with "void *
>    cookie", which actually gets the value "file".
> 
> 	struct file * file = (struct file *)cookie;
> 
>    which again is not, in my not so d*mn humble opinion, any improvement
>    at all.
> 
> In short, both of the changes resulted in (a) uglier code and (b) loss of
> typechecking. 
> 
> Note that the code did not add any new information - it couldn't do that.
> It just hid the information we _did_ have available, and made it uglier.
> 
> And people then _applaud_ this move?

Because AFAICS a struct address_space should be usable for caching /anything/
in the page cache, not just file data. Otherwise we might as well merge it
back into struct inode and be done with it. If it is going to be more generic,
having any parameter other than the actual page passed to those methods looks
wrong, but I can't think of another solution for NFS which is conceptually
clean _and_ efficient.

Actually, thinking about this, is there any point now where the generic page
cache code calls address_space methods? I've just looked, and AFAICS all the
calls are from the filemap code. I thought the original idea was that an
address_space should contain the data and function ptrs to allow the page
cache to go about its business without caring what the data was used
for. We don't actually seem to be doing that, other than the new sync_page.
Some of the methods also look downright wrong for this - ->bmap at least
should be an inode op, surely? 

I was hoping to use the addr_space stuff to cache fs metadata easily - NTFS
for example has on-disk structures which span blocks, so using the buffer
cache is out. Sure, I could code up a private cache, but then the mm subsystem
has no way to tell me to prune data as memory pressure increases.

Maybe we should put this discussion on ice until 2.5 is opened.. Mind you,
people writing filesystems are going to kill us if/when the API changes
again.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
