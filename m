Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 104616B00EC
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 09:44:30 -0400 (EDT)
Date: Mon, 16 Apr 2012 14:44:22 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/11] nfs: disable data cache revalidation for swapfiles
Message-ID: <20120416134422.GC2359@suse.de>
References: <1334578675-23445-1-git-send-email-mgorman@suse.de>
 <1334578675-23445-9-git-send-email-mgorman@suse.de>
 <CADnza444dTr=JEtqpL5wxHRNkEc7vBz1qq9TL7Z+5h749vNawg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CADnza444dTr=JEtqpL5wxHRNkEc7vBz1qq9TL7Z+5h749vNawg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fred Isaman <iisaman@netapp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Mon, Apr 16, 2012 at 09:10:04AM -0400, Fred Isaman wrote:
> > <SNIP>
> > -static struct nfs_page *nfs_page_find_request_locked(struct page *page)
> > +static struct nfs_page *
> > +nfs_page_find_request_locked(struct nfs_inode *nfsi, struct page *page)
> >  {
> >        struct nfs_page *req = NULL;
> >
> > -       if (PagePrivate(page)) {
> > +       if (PagePrivate(page))
> >                req = (struct nfs_page *)page_private(page);
> > -               if (req != NULL)
> > -                       kref_get(&req->wb_kref);
> > +       else if (unlikely(PageSwapCache(page))) {
> > +               struct nfs_page *freq, *t;
> > +
> > +               /* Linearly search the commit list for the correct req */
> > +               list_for_each_entry_safe(freq, t, &nfsi->commit_list, wb_list) {
> > +                       if (freq->wb_page == page) {
> > +                               req = freq;
> > +                               break;
> > +                       }
> > +               }
> > +
> > +               BUG_ON(req == NULL);
> 
> I suspect I am missing something, but why is it guaranteed that the
> req is on the commit list?
> 

It's a fair question and a statement about what I expected to happen.
The commit list replaces the nfs_page_tree radix tree that used to exist
and my understanding was that the req would exist in the radix tree until
the swap IO was completed. I expected it to be the same for the commit
list and the BUG_ON was based on that expectation. Are there cases where
the req would not be found?

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
