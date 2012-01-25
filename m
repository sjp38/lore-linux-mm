Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 4C7446B004F
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 18:02:04 -0500 (EST)
Received: by pbaa12 with SMTP id a12so236771pba.14
        for <linux-mm@kvack.org>; Wed, 25 Jan 2012 15:02:03 -0800 (PST)
Date: Wed, 25 Jan 2012 15:01:38 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/3] mm: adjust rss counters for migration entiries
In-Reply-To: <4F1E58DD.6030607@openvz.org>
Message-ID: <alpine.LSU.2.00.1201251453550.2141@eggly.anvils>
References: <20120106173827.11700.74305.stgit@zurg> <20120106173856.11700.98858.stgit@zurg> <20120111144125.0c61f35f.kamezawa.hiroyu@jp.fujitsu.com> <4F0D46EF.4060705@openvz.org> <20120111174126.f35e708a.kamezawa.hiroyu@jp.fujitsu.com>
 <20120118152131.45a47966.akpm@linux-foundation.org> <alpine.LSU.2.00.1201231719580.14979@eggly.anvils> <4F1E58DD.6030607@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 24 Jan 2012, Konstantin Khlebnikov wrote:
> Hugh Dickins wrote:
> > On Wed, 18 Jan 2012, Andrew Morton wrote:
> > > : From: Konstantin Khlebnikov<khlebnikov@openvz.org>
> > > : Subject: mm: add rss counters consistency check
> > > :
> > > : Warn about non-zero rss counters at final mmdrop.
> > > :
> > > : This check will prevent reoccurences of bugs such as that fixed in "mm:
> > > : fix rss count leakage during migration".
> > > :
> > > : I didn't hide this check under CONFIG_VM_DEBUG because it rather small
> > > and
> > > : rss counters cover whole page-table management, so this is a good
> > > : invariant.
> > > :
> > > : Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> > > : Cc: Hugh Dickins<hughd@google.com>
> > > : Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > I'd be happier with this one if you do hide the check under
> > CONFIG_VM_DEBUG - or even under CONFIG_DEBUG_VM if you want it to
> > be compiled in sometimes ;)  I suppose NR_MM_COUNTERS is only 3,
> > so it isn't a huge overhead; but I think you're overestimating the
> > importance of these counters, and it would look better under DEBUG_VM.
> 
> Theoretically, some drivers can touch page tables,
> for example if they do that outside of vma we can get some kind of strange
> memory leaks.

I don't understand you on that.  Sure, drivers could do all kinds of
damage, but if they're touching pagetables outside of the vmas, then
this check on rss at exit isn't going to catch them.

But the message I get is that you want to leave the check (which would
have been better at the end of exit_mmap, I think, but never mind)
outside of CONFIG_DEBUG_VM: okay, I don't feel strongly enough.

> > > : From: Konstantin Khlebnikov<khlebnikov@openvz.org>
> > > : Subject: mm: postpone migrated page mapping reset
> > > :
> > > : Postpone resetting page->mapping until the final
> > > remove_migration_ptes().
> > > : Otherwise the expression PageAnon(migration_entry_to_page(entry)) does
> > > not
> > > : work.
> > > :
> > > : Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> > > : Cc: Hugh Dickins<hughd@google.com>
> > > : Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Isn't this one actually an essential part of the fix?  It should have
> > been part of the same patch, but you split them apart, now Andrew has
> > reordered them and pushed one part to 3.3, but this needs to go in too?
> > 
> 
> Oops. I missed that. Yes. race-fix does not work for anon-memory without that
> patch.
> But this is non-fatal, there are no new bugs.

Non-fatal and no new bug, yes, but it makes the fix which has already
gone in rather less of a fix than was intended (it'll get the total right,
but misreport anon as file).  Andrew, please add this one to your next
push to Linus - thanks.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
