Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 981326B0255
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 07:30:54 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p65so18316472wmp.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 04:30:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gt8si3761348wjc.204.2016.03.04.04.30.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Mar 2016 04:30:53 -0800 (PST)
Date: Fri, 4 Mar 2016 13:31:12 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/3] radix-tree: support locking of individual exception
 entries.
Message-ID: <20160304123112.GA17393@quack.suse.cz>
References: <145663588892.3865.9987439671424028216.stgit@notabene>
 <145663616983.3865.11911049648442320016.stgit@notabene>
 <20160303131033.GC12118@quack.suse.cz>
 <87a8mfm86l.fsf@notabene.neil.brown.name>
 <87si06lfcv.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87si06lfcv.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri 04-03-16 21:14:24, NeilBrown wrote:
> On Fri, Mar 04 2016, NeilBrown wrote:
> 
> >
> > By not layering on top of wait_bit_key, you've precluded the use of the
> > current page wait_queues for these locks - you need to allocate new wait
> > queue heads.
> >
> > If in
> >
> >> +struct wait_exceptional_entry_queue {
> >> +	wait_queue_t wait;
> >> +	struct exceptional_entry_key key;
> >> +};
> >
> > you had the exceptional_entry_key first (like wait_bit_queue does) you
> > would be closer to being able to re-use the queues.
> 
> Scratch that bit, I was confusing myself again.  Sorry.
> Each wait_queue_t has it's own function so one function will never be
> called on other items in the queue - of course.

Yes.

> > Also I don't think it is safe to use an exclusive wait.  When a slot is
> > deleted, you need to wake up *all* the waiters.
> 
> I think this issue is still valid.

Yes, you are right. I have deleted your function radix_tree_delete_unlock()
because I thought it won't be needed - but if we use exclusive waits (which
I think we want to) we need to wakeup all waiters when deleting entry as you
properly spotted.

Currently I'm undecided how we want to deal with that. The thing is - when
exceptional entries use locking, we need deleting of a radix tree entry to
avoid deleting locked entry so the only proper way to delete entry would be
via something like radix_tree_delete_unlock(). OTOH when entry locking is
not used (like for tmpfs exceptional entries), we don't want to bother with
passing waitqueues around and locking entry just to delete it. The best I
came up with was that radix_tree_delete_item() would complain about
deleting locked entry so that we catch when someone doesn't properly obey
the locking protocol... But I'm still somewhat hesitating whether it would
not be better to move the locking out of generic radix tree code since it
is not quite as generic as I'd like and e.g. clear_exceptional_entry()
would use locked delete only for DAX mappings anyway.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
