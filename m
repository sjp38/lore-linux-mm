Date: Thu, 25 Oct 2007 07:30:08 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH+comment] fix tmpfs BUG and AOP_WRITEPAGE_ACTIVATE
In-Reply-To: <84144f020710242237q3aa8e96dtc8cf3f02f2af2cc9@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0710250705510.9811@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710142049000.13119@sbz-30.cs.Helsinki.FI>
 <200710142232.l9EMW8kK029572@agora.fsl.cs.sunysb.edu>
 <84144f020710150447o94b1babo8b6e6a647828465f@mail.gmail.com>
 <Pine.LNX.4.64.0710222101420.23513@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0710242152020.13001@blonde.wat.veritas.com>
 <20071024140836.a0098180.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0710242233470.17796@blonde.wat.veritas.com>
 <84144f020710242237q3aa8e96dtc8cf3f02f2af2cc9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, ezk@cs.sunysb.edu, ryan@finnie.org, mhalcrow@us.ibm.com, cjwatson@ubuntu.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Oct 2007, Pekka Enberg wrote:
> On 10/25/07, Hugh Dickins <hugh@veritas.com> wrote:
> > --- 2.6.24-rc1/mm/shmem.c       2007-10-24 07:16:04.000000000 +0100
> > +++ linux/mm/shmem.c    2007-10-24 22:31:09.000000000 +0100
> > @@ -915,6 +915,21 @@ static int shmem_writepage(struct page *
> >         struct inode *inode;
> >
> >         BUG_ON(!PageLocked(page));
> > +       /*
> > +        * shmem_backing_dev_info's capabilities prevent regular writeback or
> > +        * sync from ever calling shmem_writepage; but a stacking filesystem
> > +        * may use the ->writepage of its underlying filesystem, in which case
> 
> I find the above bit somewhat misleading as it implies that the
> !wbc->for_reclaim case can be removed after ecryptfs has similar fix
> as unionfs. Can we just say that while BDI_CAP_NO_WRITEBACK does
> prevent some callers from entering ->writepage(), it's just an
> optimization and ->writepage() must deal with !wbc->for_reclaim case
> properly?

Sorry for being obtuse, but I don't see how that's misleading at all.

ecryptfs already has a (dissimilar) fix in 2.6.24-rc1, not using the
writepage route at all.  But it remains the case that some stacking
filesystem may (would you prefer "might" to "may"?  "may" has a nice
double meaning of "might" and "we'll allow it", but this patch does
indeed allow it) use the ->writepage of its underlying filesystem.

With unionfs also fixed, we don't know of an absolute need for this
patch (and so, on that basis, the !wbc->for_reclaim case could indeed
be removed very soon); but as I see it, the unionfs case has shown
that it's time to future-proof this code against whatever stacking
filesystems come along.  Hence I didn't mention the names of such
filesystems in the source comment.

The !page_mapped assumption has been built in there since earliest
2.4, but it took a while for us to get a way to express it in a BUG.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
