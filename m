Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 85DE66B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 08:39:29 -0500 (EST)
Received: by werf1 with SMTP id f1so1859222wer.14
        for <linux-mm@kvack.org>; Thu, 12 Jan 2012 05:39:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1201111351080.1846@eggly.anvils>
References: <CAJd=RBAiAfyXBcn+9WO6AERthyx+C=cNP-romp9YJO3Hn7-U-g@mail.gmail.com>
	<alpine.LSU.2.00.1201111351080.1846@eggly.anvils>
Date: Thu, 12 Jan 2012 21:39:27 +0800
Message-ID: <CAJd=RBC6zXtN1uQMxJJxGGHrXH5xUAeDWGzoEazbVAdRXo9F0Q@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: deactivate isolated pages with lru lock released
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi Hugh

Thanks for your comment.

On Thu, Jan 12, 2012 at 6:33 AM, Hugh Dickins <hughd@google.com> wrote:
> On Wed, 11 Jan 2012, Hillf Danton wrote:
>
>> Spinners on other CPUs, if any, could take the lru lock and do their job=
s while
>> isolated pages are deactivated on the current CPU if the lock is release=
d
>> actively. And no risk of race raised as pages are already queued on loca=
lly
>> private list.
>
> You make a good point - except, I'm afraid as usual, I have difficulty
> in understanding your comment, in separating how it is before your change
> and how it is after your change. =C2=A0Above you're describing how it is =
after
> your change; and it would help if you point out that you're taking the
> lock off clear_active_flags(), which goes all the way down the list of
> pages we isolated (to a locally private list, yes, important point).
>
> However... this patch is based on Linus's current, and will clash with a
> patch of mine presently in akpm's tree - which I'm expecting will go on
> to Linus soon, unless Andrew discards it in favour of yours (that might
> involve a little unravelling, I didn't look). =C2=A0Among other rearrange=
ments,
> I merged the code from clear_active_flags() into update_isolated_counts()=
.
>
> And something that worries me is that you're now dropping the spinlock
> and reacquiring it shortly afterwards, just clear_active_flags in between=
.
> That may bounce the lock around more than before, and actually prove wors=
e.
>

Yes, there is change introduced in locking behavior, and if it is already h=
ot,
last acquiring it maybe a lucky accident due to that bounce(in your term).

The same lock is also encountered when isolating pages for migration, and I=
 am
currently attempting to copy that lock mode to reclaim, based on the assump=
tion
that bounce could be cured with bounce 8-) and preparing for incoming compl=
ains.

Though a hot lock, tiny window remains open for tiny tackle, for example th=
e
attached diff.

--- a/mm/vmscan.c	Thu Dec 29 20:20:16 2011
+++ b/mm/vmscan.c	Thu Jan 12 20:48:42 2012
@@ -1032,6 +1032,12 @@ keep_lumpy:
 	return nr_reclaimed;
 }

+static bool is_all_lru_mode(isolate_mode_t mode)
+{
+	return (mode & (ISOLATE_ACTIVE|ISOLATE_INACTIVE)) =3D=3D
+			(ISOLATE_ACTIVE|ISOLATE_INACTIVE);
+}
+
 /*
  * Attempt to remove the specified page from its LRU.  Only take this page
  * if it is of the appropriate PageActive status.  Pages which are being
@@ -1051,8 +1057,7 @@ int __isolate_lru_page(struct page *page
 	if (!PageLRU(page))
 		return ret;

-	all_lru_mode =3D (mode & (ISOLATE_ACTIVE|ISOLATE_INACTIVE)) =3D=3D
-		(ISOLATE_ACTIVE|ISOLATE_INACTIVE);
+	all_lru_mode =3D is_all_lru_mode(mode);

 	/*
 	 * When checking the active state, we need to be sure we are
@@ -1155,6 +1160,13 @@ static unsigned long isolate_lru_pages(u
 	unsigned long nr_lumpy_dirty =3D 0;
 	unsigned long nr_lumpy_failed =3D 0;
 	unsigned long scan;
+
+	/* Try to save a few cycles mainly due to lru_lock held and irq off,
+	 * no bother attempting pfn-based isolation if pages only on the given
+	 * src list could be taken.
+	 */
+	if (order && !is_all_lru_mode(mode))
+		order =3D 0;

 	for (scan =3D 0; scan < nr_to_scan && !list_empty(src); scan++) {
 		struct page *page;
--


> I suspect that your patch can be improved, to take away that worry.
> Why do we need to take the lock again? =C2=A0Only to update reclaim_stat:
> for the other stats, interrupts disabled is certainly good enough,
> and more research might show that preemption disabled would be enough.
>
> get_scan_count() is called at the (re)start of shrink_mem_cgroup_zone(),
> before it goes down to do shrink_list()s: I think it would not be harmed
> at all if we delayed updating reclaim_stat->recent_scanned until the
> next time we take the lock, lower down.
>

Dunno how to handle the tons of __mod_zone_page_state() or similar without =
lock
protection 8-/ try to deffer updating reclaim_stat soon.

> Other things that strike me, looking here again: isn't it the case that
> update_isolated_counts() is actually called either for file or for anon,
> but never for both?

No, see the above diff please 8-)

>=C2=A0We might be able to make savings from that, perhaps
> enlist help from isolate_lru_pages() to avoid having to go down the list
> again to clear active flags.
>

Best regards
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
