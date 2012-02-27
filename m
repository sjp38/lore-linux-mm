Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 2823B6B002C
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 05:46:59 -0500 (EST)
Date: Mon, 27 Feb 2012 11:46:46 +0100
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH v5 3/3] fadvise: implement POSIX_FADV_NOREUSE
Message-ID: <20120227104646.GA1700@thinkpad>
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
 <1329006098-5454-4-git-send-email-andrea@betterlinux.com>
 <20120227113338.e8e1ecd6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120227113338.e8e1ecd6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?iso-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Feb 27, 2012 at 11:33:38AM +0900, KAMEZAWA Hiroyuki wrote:
> On Sun, 12 Feb 2012 01:21:38 +0100
> Andrea Righi <andrea@betterlinux.com> wrote:
> 
> > According to the POSIX standard the POSIX_FADV_NOREUSE hint means that
> > the application expects to access the specified data once and then not
> > reuse it thereafter.
> > 
> > It seems that the expected behavior is to implement a drop-behind
> > policy where the application can set certain intervals of a file as
> > FADV_NOREUSE _before_ accessing the data.
> > 
> > An interesting usage of this hint is to guarantee that pages marked as
> > FADV_NOREUSE will never blow away the pages of the current working set.
> > 
> > A possible solution to satisfy this requirement is to prevent lru
> > activation of the pages marked as FADV_NOREUSE, in other words, never
> > add pages marked as FADV_NOREUSE to the active lru list. Moreover, all
> > the file cache pages in a FADV_NOREUSE range can be immediately dropped
> > after a read if the page was not present in the file cache before.
> > 
> > In general, the purpose of this approach is to preserve as much as
> > possible the previous state of the file cache memory before reading data
> > in ranges marked by FADV_NOREUSE.
> > 
> > All the pages read before (pre-)setting them as FADV_NOREUSE should be
> > treated as normal, so they can be added to the active lru list as usual
> > if they're accessed multiple times.
> > 
> > Only after setting them as FADV_NOREUSE we can prevent them for being
> > promoted to the active lru list. If they are already in the active lru
> > list before calling FADV_NOREUSE we should keep them there, but if they
> > quit from the active list they can't get back anymore (except by
> > explicitly setting a different caching hint).
> > 
> 
> >From this part, it seems the behavior of systemcall is highly depends on
> interanal kernel implemenatation...

Yes. If in a future kernel we'll decide to remove the active/inactive
lru lists we also need to change the implementation of FADV_NOREUSE.

However, I think that any solution for a feature that allows to not
disturb the state of the page cache has inevitably something dependent
on internal kernel implementation...

Probably a more generic concept to document is that FADV_NOREUSE is an
advice from the application to never consider the marked pages as part
of the working set (for any possible meaning/implementation of "working
set").

> 
> 
> > To achieve this goal we need to maintain the list of file ranges marked
> > as FADV_NOREUSE until the pages are dropped from the page cache, or the
> > inode is deleted, or they're explicitly marked to use a different cache
> > behavior (FADV_NORMAL | FADV_WILLNEED).
> > 
> > The list of FADV_NOREUSE ranges is maintained in the address_space
> > structure using an interval tree (kinterval).
> > 
> > Signed-off-by: Andrea Righi <andrea@betterlinux.com>
> 
> 
> Once an appliation sets a range of file as FILEMAP_CACHE_ONCE,
> the effects will last until the inode is dropped....right ?
> Won't this cause troubles which cannot be detected
> (because kinterval information is hidden.) ?
> 
> I'm not sure but FADV_NOREUSE seems like one-shot call and should not have
> very long time of effect (after the application exits.)
> Can't we ties the liftime of kinteval to the application/file descriptor ?

Yes, I'm also concerned about this. Using FADV_NOREUSE may also affect
the page cache behavior of other applications.

I like the idea to tie the FADV_NOREUSE ranges to the file descriptor.
In addition to the shorter lifetime it has the advantage that the policy
is applied only to the application that is actually using this feature
and not also to the other apps running in the system.

I'll consider this possibility for sure if I'll post a new version of
this patch set.

Thanks!
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
