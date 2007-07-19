Message-ID: <384832548.21788@ustc.edu.cn>
Date: Thu, 19 Jul 2007 16:09:10 +0800
From: Fengguang Wu <fengguang.wu@gmail.com>
Subject: Re: [patch] fix periodic superblock dirty inode flushing
Message-ID: <20070719080910.GA7459@mail.ustc.edu.cn>
References: <b040c32a0707112121y21d08438u8ca7f138931827b0@mail.gmail.com> <20070712120519.8a7241dd.akpm@linux-foundation.org> <b040c32a0707131517m4cc20d3an2123e324746d3e7@mail.gmail.com> <b040c32a0707161701q49ad150di6387b029a39b39c3@mail.gmail.com> <384813965.25550@ustc.edu.cn> <20070718201018.9beb0f90.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070718201018.9beb0f90.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ken Chen <kenchen@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 18, 2007 at 08:10:18PM -0700, Andrew Morton wrote:
> On Thu, 19 Jul 2007 10:59:27 +0800 Fengguang Wu <fengguang.wu@gmail.com> wrote:
> > On Mon, Jul 16, 2007 at 05:01:31PM -0700, Ken Chen wrote:
> > > I ran some more tests over the weekend with the debug turned on. There
> > > are a few fall out that the order-ness of sb-s_dirty is corrupted.  We
> > > probably should drop this patch until I figure out a real solution to
> > > this.
> > > 
> > > One idea is to use rb-tree for sorting and use a in-tree dummy node as
> > > a tree iterator.  Do you think that will work better?  I will hack on
> > > that.
> > 
> > Sorry if I'm not backgrounded.
> > 
> > But what's the problem of a list? If we always do the two actions
> > *together*:
> >         1) update inode->dirtied_when
> >         2) requeue inode in the correct place
> > the list will be in order.
> > linux-2.6.22-rc6-mm1/fs/fs-writeback.c obviously obeys this rule.
> > 
> > I don't see how can a new data structure make life easier.
> > 1) and 2) should still be safeguarded, isn't it?
> 
> Well yes, the existing implementation does its best to work, and almost
> does work correctly but it was really hard to do and it is hard to maintain.
> 
> Whereas if we had a better data structure it would be cleaner and easier to
> implement and to maintain, I expect.
>
> With an indexed data structure (ie: radix-tree or rbtree) the writeback
> code can remember where it was up to in the ordered list of inodes so it
> can drop locks, do writeback, remember where it was up to for the next
> pass, etc.
> 
> Basically, the walk of the per-superblock inodes would follow the same
> model as the walk of the per-inode pages.  And the latter has worked out
> *really* well.  It would be great if the per-sb inode traversal was as
> flexible and as powerful as the page walks.
> 
> Probably it never will be, because I suspect we'd need to order the inodes
> by multiple indices.  I hn't thought it through, really.  

Just one more possibility...  an array of lists?

The array is cyclic and time-addressable, and
the lists can be ordered by other criterion(s).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
