Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 343706B0075
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 00:49:02 -0500 (EST)
Received: by iacb35 with SMTP id b35so27717254iac.14
        for <linux-mm@kvack.org>; Wed, 28 Dec 2011 21:49:01 -0800 (PST)
Date: Wed, 28 Dec 2011 21:48:51 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/3] mm: cond_resched in scan_mapping_unevictable_pages
In-Reply-To: <4EFBF732.1070303@gmail.com>
Message-ID: <alpine.LSU.2.00.1112282142360.2405@eggly.anvils>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils> <alpine.LSU.2.00.1112282035250.1362@eggly.anvils> <4EFBF732.1070303@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On Thu, 29 Dec 2011, KOSAKI Motohiro wrote:
> (12/28/11 11:36 PM), Hugh Dickins wrote:
> > scan_mapping_unevictable_pages() is used to make SysV SHM_LOCKed pages
> > evictable again once the shared memory is unlocked or destroyed (the
> > latter seems rather a waste of time, but meets internal expectations).
> > It does pagevec_lookup()s across the whole object: methinks a
> > cond_resched() every PAGEVEC_SIZE pages would be worthwhile.
> > 
> > Signed-off-by: Hugh Dickins<hughd@google.com>
> > ---
> >   mm/vmscan.c |    2 +-
> >   1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > --- mmotm.orig/mm/vmscan.c	2011-12-28 16:49:36.000000000 -0800
> > +++ mmotm/mm/vmscan.c	2011-12-28 17:03:07.647220248 -0800
> > @@ -3583,8 +3583,8 @@ void scan_mapping_unevictable_pages(stru
> >   		pagevec_release(&pvec);
> > 
> >   		count_vm_events(UNEVICTABLE_PGSCANNED, pg_scanned);
> > +		cond_resched();
> >   	}
> 
> Hmm...
> scan_mapping_unevictable_pages() is always under spinlock?

Yikes, how dreadful!  Dreadful that it's like that, and dreadful
that I didn't notice.  Many thanks for spotting, consider this
patch summarily withdrawn.  All the more need for some patch like
this, but no doubt it was "easier" to do it all under the spinlock,
so the right replacement patch may not be so obvious.
 
Thanks again,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
