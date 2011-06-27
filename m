Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA176B0092
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 06:29:38 -0400 (EDT)
Date: Mon, 27 Jun 2011 12:29:33 +0200
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH v3 0/2] fadvise: support POSIX_FADV_NOREUSE
Message-ID: <20110627102933.GA1282@thinkpad>
References: <1308923350-7932-1-git-send-email-andrea@betterlinux.com>
 <4E07F349.2040900@jp.fujitsu.com>
 <20110627071139.GC1247@thinkpad>
 <4E0858CF.6070808@draigBrady.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4E0858CF.6070808@draigBrady.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, minchan.kim@gmail.com, riel@redhat.com, peterz@infradead.org, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, hughd@google.com, jamesjer@betterlinux.com, marcus@bluehost.com, matt@bluehost.com, tytso@mit.edu, shaohua.li@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 27, 2011 at 11:17:51AM +0100, Padraig Brady wrote:
> On 27/06/11 08:11, Andrea Righi wrote:
> > On Mon, Jun 27, 2011 at 12:04:41PM +0900, KOSAKI Motohiro wrote:
> >> (2011/06/24 22:49), Andrea Righi wrote:
> >>> There were some reported problems in the past about trashing page cache
> >>> when a backup software (i.e., rsync) touches a huge amount of pages (see
> >>> for example [1]).
> >>>
> >>> This problem has been almost fixed by the Minchan Kim's patch [2] and a
> >>> proper use of fadvise() in the backup software. For example this patch
> >>> set [3] has been proposed for inclusion in rsync.
> >>>
> >>> However, there can be still other similar trashing problems: when the
> >>> backup software reads all the source files, some of them may be part of
> >>> the actual working set of the system. When a POSIX_FADV_DONTNEED is
> >>> performed _all_ pages are evicted from pagecache, both the working set
> >>> and the use-once pages touched only by the backup software.
> >>>
> >>> A previous proposal [4] tried to resolve this problem being less
> >>> agressive in invalidating active pages, moving them to the inactive list
> >>> intead of just evict them from the page cache.
> >>>
> >>> However, this approach changed completely the old behavior of
> >>> invalidate_mapping_pages(), that is not only used by fadvise.
> >>>
> >>> The new solution maps POSIX_FADV_NOREUSE to the less-agressive page
> >>> invalidation policy.
> >>>
> >>> With POSIX_FADV_NOREUSE active pages are moved to the tail of the
> >>> inactive list, and pages in the inactive list are just removed from page
> >>> cache. Pages mapped by other processes or unevictable pages are not
> >>> touched at all.
> >>>
> >>> In this way if the backup was the only user of a page, that page will be
> >>> immediately removed from the page cache by calling POSIX_FADV_NOREUSE.
> >>> If the page was also touched by other tasks it'll be moved to the
> >>> inactive list, having another chance of being re-added to the working
> >>> set, or simply reclaimed when memory is needed.
> >>>
> >>> In conclusion, now userspace applications that want to drop some page
> >>> cache pages can choose between the following advices:
> >>>
> >>>  POSIX_FADV_DONTNEED = drop page cache if possible
> >>>  POSIX_FADV_NOREUSE = reduce page cache eligibility
> >>
> >> Eeek.
> >>
> >> Your POSIX_FADV_NOREUSE is very different from POSIX definition.
> >> POSIX says,
> >>
> >>        POSIX_FADV_NOREUSE
> >>               Specifies that the application expects to access the specified data once  and  then
> >>               not reuse it thereafter.
> >>
> >> IfI understand correctly, it designed for calling _before_ data access
> >> and to be expected may prevent lru activation. But your NORESE is designed
> >> for calling _after_ data access. Big difference might makes a chance of
> >> portability issue.
> > 
> > You're right. NOREUSE is designed to implement drop behind policy.
> 
> Hmm fair enough.
> NOREUSE is meant for specifying you _will_ need the data _once_
> 
> Isn't this what rsync actually wants though?
> I.E. to specify NOREUSE for the file up front
> so it would drop from cache automatically as processed,
> (if not already in cache).
> 
> I realize that would be a more invasive patch.
> 
> > I'll post a new patch that will plug this logic in DONTNEED (like the
> > presious version), but without breaking the old /proc/sys/vm/drop_caches
> > behavior.
> 
> But will that break existing apps (running as root) that expect DONTNEED
> to drop cache for a _file_.  Perhaps posix_fadvise() is meant to have
> process rather than system scope, but that has not been the case until now.

The actual problem I think is that apps expect that DONTNEED can be used
to drop cache, but this is not written anywhere in the POSIX standard.

I would also like to have both functionalities: 1) be sure to drop page
cache pages (now there's only a system-wide knob to do this:
/proc/sys/vm/drop_caches), 2) give an advice to the kernel that I will
not reuse some pages in the future.

The standard can only provide 2). If we also want 1) at the file
granularity, I think we'd need to introduce something linux specific to
avoid having portability problems.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
