Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 6A9306B004F
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 22:24:11 -0500 (EST)
Date: Fri, 16 Dec 2011 19:26:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 05/11] mm: compaction: Determine if dirty pages can be
 migrated without blocking within ->migratepage
Message-Id: <20111216192641.b598b9b1.akpm@linux-foundation.org>
In-Reply-To: <201112171103.01613.nai.xia@gmail.com>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
	<1323877293-15401-6-git-send-email-mgorman@suse.de>
	<20111216152054.f7445e98.akpm@linux-foundation.org>
	<201112171103.01613.nai.xia@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nai.xia@gmail.com
Cc: Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, 17 Dec 2011 11:03:01 +0800 Nai Xia <nai.xia@gmail.com> wrote:

> On Saturday 17 December 2011 07:20:54 Andrew Morton wrote:
> > 
> > I hadn't paid a lot of attention to buffer_migrate_page() before. 
> > Scary function.  I'm rather worried about its interactions with ext3
> > journal commit which locks buffers then plays with them while leaving
> > the page unlocked.  How vigorously has this been whitebox-tested?
> 
> buffer_migrate_page() is done under page lock & buffer head locks.
> 
> I had assumed that anyone who has locked the buffer_heads should 
> also have a stable relationship between buffer_head <---> page,
> otherwise, the buffer_head locking semantics should be broken itself ?
> 
> I am actually using the similar logic for some other stuff,
> it will make me cry if it can really crash ext3....

It's complicated ;) JBD attaches a journal_head to the buffer_head and
thereby largely increases the amount of metadata in the buffer_head. 
Locking the buffer_head isn't considered to have locked the
journal_head, although it might often work out that way.

I don't see anything in the journal_head which refers to the page
contents (b_committed_data points to a JBD-private copy of the data),
and buffer_migrate_page() migrates the buffers to a new page, rather
than migrating new buffers to the new page.

We should check that the b_committed_data copy is taken under
lock_buffer() (surely true).

The core writeback code will initiate writeback against buffer_heads
and will then unlock the page.  But in that case the buffer_heads are
locked and come unlocked after writeback has completed.  So that should
be OK.

set_page_dirty() and friends can sometimes play with an unlocked page
and even unlocked buffers, from IRQ context iirc.  If there are
problems around this, taking ->private_lock in buffer_migrate_page()
will help...

It's just ...  scary.  Whether there are gremlins in there (or in other
filesystems!) I just don't know.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
