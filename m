Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D2782900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 18:06:44 -0400 (EDT)
Received: by qwa26 with SMTP id 26so1587157qwa.14
        for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:06:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308810981-5286-1-git-send-email-andrea@betterlinux.com>
References: <1308810981-5286-1-git-send-email-andrea@betterlinux.com>
Date: Fri, 24 Jun 2011 07:06:42 +0900
Message-ID: <BANLkTim8zXQYmEqJbxy0oSxVb3Lsi2f7Tg@mail.gmail.com>
Subject: Re: [PATCH v2] fadvise: move active pages to inactive list with POSIX_FADV_DONTNEED
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Jerry James <jamesjer@betterlinux.com>, Marcus Sorensen <marcus@bluehost.com>, Matt Heaton <matt@bluehost.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Andrea,
Sorry for late response.
These day, I have no time to see the LKML.

On Thu, Jun 23, 2011 at 3:36 PM, Andrea Righi <andrea@betterlinux.com> wrot=
e:
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
> the actual working set of the system. When a
> posix_fadvise(POSIX_FADV_DONTNEED) is performed _all_ pages are evicted
> from pagecache, both the working set and the use-once pages touched only
> by the backup software.

Agreed. It's rather aggressive.

>
> With the following solution when posix_fadvise(POSIX_FADV_DONTNEED) is
> called for an active page instead of removing it from the page cache it
> is added to the tail of the inactive list. Otherwise, if it's already in
> the inactive list the page is removed from the page cache.
>
> In this way if the backup was the only user of a page, that page will
> be immediately removed from the page cache by calling
> posix_fadvise(POSIX_FADV_DONTNEED). If the page was also touched by
> other processes it'll be moved to the inactive list, having another
> chance of being re-added to the working set, or simply reclaimed when
> memory is needed.
>
> Testcase:
>
> =C2=A0- create a 1GB file called "zero"
> =C2=A0- run md5sum zero to read all the pages in page cache (this is to
> =C2=A0 =C2=A0simulate the user activity on this file)
> =C2=A0- run "rsync zero zero_copy" (rsync is patched with [3])
> =C2=A0- re-run md5sum zero (user activity on the working set) and measure
> =C2=A0 =C2=A0the time to complete this command
>
> The test has been performed using 3.0.0-rc4 vanilla and with this patch
> applied (3.0.0-rc4-fadvise).
>
> Results:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0avg elapsed=
 time =C2=A0 =C2=A0 =C2=A0block:block_bio_queue
> =C2=A03.0.0-rc4 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A04.127s =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A08,214
> =C2=A03.0.0-rc4-fadvise =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02.146s =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00
>

Great!

> In the first case the file is evicted from page cache completely and we
> must re-read it from the disk. In the second case the file is still in
> page cache (in the inactive list) and we don't need any other additional
> I/O operation.
>
> [1] http://marc.info/?l=3Drsync&m=3D128885034930933&w=3D2
> [2] https://lkml.org/lkml/2011/2/20/57
> [3] http://lists.samba.org/archive/rsync/2010-November/025827.html
>
> ChangeLog v1 -> v2:
> =C2=A0- fix comment in invalidate_mapping_pages()
>
> Acked-by: Rik van Riel <riel@redhat.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Andrea Righi <andrea@betterlinux.com>
> ---
> =C2=A0mm/swap.c =C2=A0 =C2=A0 | =C2=A0 =C2=A09 +++++----
> =C2=A0mm/truncate.c | =C2=A0 10 +++++++---
> =C2=A02 files changed, 12 insertions(+), 7 deletions(-)
>
> diff --git a/mm/swap.c b/mm/swap.c
> index 3a442f1..fc8bb76 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -411,10 +411,11 @@ void add_page_to_unevictable_list(struct page *page=
)
> =C2=A0*
> =C2=A0* 1. active, mapped page -> none
> =C2=A0* 2. active, dirty/writeback page -> inactive, head, PG_reclaim
> - * 3. inactive, mapped page -> none
> - * 4. inactive, dirty/writeback page -> inactive, head, PG_reclaim
> - * 5. inactive, clean -> inactive, tail
> - * 6. Others -> none
> + * 3. active, clean -> inactive, tail
> + * 4. inactive, mapped page -> none
> + * 5. inactive, dirty/writeback page -> inactive, head, PG_reclaim
> + * 6. inactive, clean -> inactive, tail
> + * 7. Others -> none

Nitpick.
I would like to put together them by on line as rather than adding another =
line.
5, [in]active, clean-> inactive, tail.
I guess it's more easy to understand.

If you want to put it in another line, please change below comment, too.
"In 5, why it moves inactive's head.."

> =C2=A0*
> =C2=A0* In 4, why it moves inactive's head, the VM expects the page would
> =C2=A0* be write it out by flusher threads as this is much more effective
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 3a29a61..a36af48 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -357,11 +357,15 @@ unsigned long invalidate_mapping_pages(struct addre=
ss_space *mapping,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (lock_failed)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ret =3D invalidate_inode_page(page);

I would like to add comment.
"Invalidation of active page is rather aggressive as we can't make
sure it's not a working set of other processes.
deactivate_page would move it into inactive's tail so the page will
have a chance to activate again if other processes
touch it. otherwise, it would be reclaimed simply".

> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (PageActive(page))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D invalidate_inode_page(page);


You have to change description of invalidate_mapping_pages.

 * invalidate_mapping_pages() will not block on IO activity. It will not
 * invalidate pages which are dirty, locked, under writeback, mapped into
 * pagetables or on active lru.

> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0unlock_page(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* Invalidation is a hint that the page is no longer
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* of interest and try to speed up its reclaim.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* Invalidation of an inactive page is a hint that the
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* page is no longer of interest and try to speed up
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* its reclaim.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (!ret)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0deactivate_page(page);
> --
> 1.7.4.1
>
>

Otherwise, Looks good to me.

Acked-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
