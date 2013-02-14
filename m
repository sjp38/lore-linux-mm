Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id B8D3E6B0002
	for <linux-mm@kvack.org>; Thu, 14 Feb 2013 17:19:19 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id hz10so1448021pad.35
        for <linux-mm@kvack.org>; Thu, 14 Feb 2013 14:19:19 -0800 (PST)
Date: Thu, 14 Feb 2013 14:19:26 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 6/11] ksm: remove old stable nodes more thoroughly
In-Reply-To: <20130214115805.GC7367@suse.de>
Message-ID: <alpine.LNX.2.00.1302141353020.2195@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251800550.29196@eggly.anvils> <20130205175551.GL21389@suse.de> <alpine.LNX.2.00.1302081057110.4233@eggly.anvils> <20130214115805.GC7367@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 14 Feb 2013, Mel Gorman wrote:
> On Fri, Feb 08, 2013 at 11:33:40AM -0800, Hugh Dickins wrote:
> > 
> > What I found is that a 4th cause emerges once KSM migration
> > is properly working: that interval during page migration when the old
> > page has been fully unmapped but the new not yet mapped in its place.
> > 
> 
> For anyone else watching -- normal page migration expects to be protected
> during that particular window with migration ptes. Any references to the
> PTE mapping a page being migrated faults on a swap-like PTE and waits
> in migration_entry_wait().
> 
> > The KSM COW breaking cannot see a page there then, so it ends up with
> > a (newly migrated) KSM page left behind.  Almost certainly has to be
> > fixed in follow_page(), but I've not yet settled on its final form -
> > the fix I have works well, but a different approach might be better.
> > 

The fix I had (following migration entry to old page) was a bit too
PageKsm specfic, and probably wrong for when get_user_pages() needs
to get a hold on the _new_ page.

> 
> follow_page() is one option. My guess is that you're thinking of adding
> a FOLL_ flag that will cause follow_page() to check is_migration_entry()
> and migration_entry_wait() if the flag is present.

Maybe a FOLL_flag, but I was thinking of doing it always.  The usual
get_user_pages() case will already wait in handle_mm_fault() and works
okay, and I didn't identify a problem case for follow_page() apart from
this ksm.c usage; but I did wonder if someone might have or add code
which gets similarly caught out by the migration case.

It's not a change I'd dare to make (without a FOLL_flag) if Andrea
hadn't already added a wait_split_huge_page() into follow_page();
and I need to convince myself that adding another cause for waiting
is necessarily safe (perhaps adding a might_sleep would be good).

Sorry, I expected to have posted follow-up patches days and days ago,
but in fact my time has vanished elsewhere and I've not even started.

> 
> Otherwise you would need to check for migration ptes in a number of places
> under page lock and then hold the lock for long periods of time to prevent
> migration starting. I did not check this option in depth because it quickly
> looked like it would be a mess, with long page lock hold times and might
> not even be workable.

Yes, I think that's more or less why I quickly decided on doing it in
follow_page().

Another option would be to move the ksm_migrate_page() callsite, and
allow it to reject the migration attempt when "inconvenient" (I haven't
stopped to think of the definition of inconvenient).  Though it wouldn't
fail often enough for anyone out there to care, that option just feels
like a shameful cop-out to me: I'm trying to improve migration, not add
strange cases when it fails.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
