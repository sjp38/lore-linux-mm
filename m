Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id CAB946B01FF
	for <linux-mm@kvack.org>; Sun, 26 Jun 2011 23:05:05 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 41C363EE081
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 12:05:01 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 19F0E45DE52
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 12:05:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EBABB45DE4F
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 12:05:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DB0621DB802F
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 12:05:00 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A6A781DB803E
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 12:05:00 +0900 (JST)
Message-ID: <4E07F349.2040900@jp.fujitsu.com>
Date: Mon, 27 Jun 2011 12:04:41 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 0/2] fadvise: support POSIX_FADV_NOREUSE
References: <1308923350-7932-1-git-send-email-andrea@betterlinux.com>
In-Reply-To: <1308923350-7932-1-git-send-email-andrea@betterlinux.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: andrea@betterlinux.com
Cc: akpm@linux-foundation.org, minchan.kim@gmail.com, riel@redhat.com, peterz@infradead.org, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, hughd@google.com, jamesjer@betterlinux.com, marcus@bluehost.com, matt@bluehost.com, tytso@mit.edu, shaohua.li@intel.com, P@draigBrady.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2011/06/24 22:49), Andrea Righi wrote:
> There were some reported problems in the past about trashing page cache
> when a backup software (i.e., rsync) touches a huge amount of pages (see
> for example [1]).
> 
> This problem has been almost fixed by the Minchan Kim's patch [2] and a
> proper use of fadvise() in the backup software. For example this patch
> set [3] has been proposed for inclusion in rsync.
> 
> However, there can be still other similar trashing problems: when the
> backup software reads all the source files, some of them may be part of
> the actual working set of the system. When a POSIX_FADV_DONTNEED is
> performed _all_ pages are evicted from pagecache, both the working set
> and the use-once pages touched only by the backup software.
> 
> A previous proposal [4] tried to resolve this problem being less
> agressive in invalidating active pages, moving them to the inactive list
> intead of just evict them from the page cache.
> 
> However, this approach changed completely the old behavior of
> invalidate_mapping_pages(), that is not only used by fadvise.
> 
> The new solution maps POSIX_FADV_NOREUSE to the less-agressive page
> invalidation policy.
> 
> With POSIX_FADV_NOREUSE active pages are moved to the tail of the
> inactive list, and pages in the inactive list are just removed from page
> cache. Pages mapped by other processes or unevictable pages are not
> touched at all.
> 
> In this way if the backup was the only user of a page, that page will be
> immediately removed from the page cache by calling POSIX_FADV_NOREUSE.
> If the page was also touched by other tasks it'll be moved to the
> inactive list, having another chance of being re-added to the working
> set, or simply reclaimed when memory is needed.
> 
> In conclusion, now userspace applications that want to drop some page
> cache pages can choose between the following advices:
> 
>  POSIX_FADV_DONTNEED = drop page cache if possible
>  POSIX_FADV_NOREUSE = reduce page cache eligibility

Eeek.

Your POSIX_FADV_NOREUSE is very different from POSIX definition.
POSIX says,

       POSIX_FADV_NOREUSE
              Specifies that the application expects to access the specified data once  and  then
              not reuse it thereafter.

IfI understand correctly, it designed for calling _before_ data access
and to be expected may prevent lru activation. But your NORESE is designed
for calling _after_ data access. Big difference might makes a chance of
portability issue.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
