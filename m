Message-ID: <396386387.18082@ustc.edu.cn>
Date: Fri, 30 Nov 2007 09:32:59 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [patch 1/1] Writeback fix for concurrent large and small file
	writes
References: <20071128192957.511EAB8310@localhost> <396296481.07368@ustc.edu.cn> <532480950711291216l181b0bej17db6c42067aa832@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <532480950711291216l181b0bej17db6c42067aa832@mail.gmail.com>
Message-Id: <E1IxukV-0003Ns-5C@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Rubin <mrubin@google.com>
Cc: a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 29, 2007 at 12:16:36PM -0800, Michael Rubin wrote:
> Due to my faux pas of top posting (see
> http://www.zip.com.au/~akpm/linux/patches/stuff/top-posting.txt) I am
> resending this email.
> 
> On Nov 28, 2007 4:34 PM, Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:
> > Could you demonstrate the situation? Or if I guess it right, could it
> > be fixed by the following patch? (not a nack: If so, your patch could
> > also be considered as a general purpose improvement, instead of a bug
> > fix.)
> >
> > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > index 0fca820..62e62e2 100644
> > --- a/fs/fs-writeback.c
> > +++ b/fs/fs-writeback.c
> > @@ -301,7 +301,7 @@ __sync_single_inode(struct inode *inode, struct writeback_control *wbc)
> >                          * Someone redirtied the inode while were writing back
> >                          * the pages.
> >                          */
> > -                       redirty_tail(inode);
> > +                       requeue_io(inode);
> >                 } else if (atomic_read(&inode->i_count)) {
> >                         /*
> >                          * The inode is clean, inuse
> >
> 
> By testing the situation I can confirm that the one line patch above
> fixes the problem.
> 
> I will continue testing some other cases to see if it cause any other
> issues but I don't expect it to.

One major concern could be whether a continuous writer dirting pages
at the 'right' pace will generate a steady flow of write I/Os which are
_tiny_hence_inefficient_.

I have gathered some timing info about writeback speed in
http://lkml.org/lkml/2007/10/4/468. For ext3, it takes wb_kupdate()
~15ms to submit 4MB. Whereas one disk I/O typically takes ~5ms. So if
there are too many tiny write I/Os, they will simply get delayed and
merged into bigger ones.

So it's not a problem in *theory* :-)

> I will post this change for 2.6.24 and list Feng as author. If that's
> ok with Feng.

Thank you.

> As for the original patch I will resubmit it for 2.6.25 as a general
> purpose improvement.

There are some discussions and patches on inode number based writeback
clustering which you may want to reference/compare with:
                http://lkml.org/lkml/2007/8/21/396
                http://lkml.org/lkml/2007/8/27/45

Cheers,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
