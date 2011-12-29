Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 2A4ED6B004D
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 17:46:11 -0500 (EST)
Received: by iacb35 with SMTP id b35so29185895iac.14
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 14:46:10 -0800 (PST)
Date: Thu, 29 Dec 2011 14:46:02 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/3] mm: cond_resched in scan_mapping_unevictable_pages
In-Reply-To: <alpine.LSU.2.00.1112282142360.2405@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112291421280.4781@eggly.anvils>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils> <alpine.LSU.2.00.1112282035250.1362@eggly.anvils> <4EFBF732.1070303@gmail.com> <alpine.LSU.2.00.1112282142360.2405@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On Wed, 28 Dec 2011, Hugh Dickins wrote:
> On Thu, 29 Dec 2011, KOSAKI Motohiro wrote:
> > 
> > Hmm...
> > scan_mapping_unevictable_pages() is always under spinlock?
> 
> Yikes, how dreadful!  Dreadful that it's like that, and dreadful
> that I didn't notice.  Many thanks for spotting, consider this
> patch summarily withdrawn.  All the more need for some patch like
> this, but no doubt it was "easier" to do it all under the spinlock,
> so the right replacement patch may not be so obvious.

It's not so bad, I think: that info->lock isn't really needed across
scan_mapping_unevictable_pages(), which has to deal with races on a
page by page basis anyway.

But it's not the only spinlock, there is also ipc_lock() (often) held
in the level above: so I'll have to restructure it a little.  And now
that it's no longer a one-liner, I really ought to add a patch fixing
another bug I introduced here - if there were swapped pages when the
area was SHM_LOCKed, find_get_pages() will give up if it hits a row
of PAGEVEC_SIZE swap entries, leaving subsequent pages unevictable.

But I'd better empty my queue of trivia before going on to that.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
