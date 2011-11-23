Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7CA6B00CF
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 08:05:10 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so1702521vcb.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 05:05:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111123110041.GM19415@suse.de>
References: <1321900608-27687-1-git-send-email-mgorman@suse.de>
	<1321900608-27687-8-git-send-email-mgorman@suse.de>
	<1321945011.22361.335.camel@sli10-conroe>
	<CAPQyPG4DQCxDah5VYMU6PNgeuD_3WJ-zm8XpL7V7BK8hAF8OJg@mail.gmail.com>
	<20111123110041.GM19415@suse.de>
Date: Wed, 23 Nov 2011 21:05:08 +0800
Message-ID: <CAPQyPG588_q1diT8KyPirUD9MLME6SanO-cSw1twzhFiTBWgCw@mail.gmail.com>
Subject: Re: [PATCH 7/7] mm: compaction: Introduce sync-light migration for
 use by compaction
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Shaohua Li <shaohua.li@intel.com>, Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 23, 2011 at 7:00 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Wed, Nov 23, 2011 at 10:01:53AM +0800, Nai Xia wrote:
>> On Tue, Nov 22, 2011 at 2:56 PM, Shaohua Li <shaohua.li@intel.com> wrote=
:
>> > On Tue, 2011-11-22 at 02:36 +0800, Mel Gorman wrote:
>> >> This patch adds a lightweight sync migrate operation MIGRATE_SYNC_LIG=
HT
>> >> mode that avoids writing back pages to backing storage. Async
>> >> compaction maps to MIGRATE_ASYNC while sync compaction maps to
>> >> MIGRATE_SYNC_LIGHT. For other migrate_pages users such as memory
>> >> hotplug, MIGRATE_SYNC is used.
>> >>
>> >> This avoids sync compaction stalling for an excessive length of time,
>> >> particularly when copying files to a USB stick where there might be
>> >> a large number of dirty pages backed by a filesystem that does not
>> >> support ->writepages.
>> > Hi,
>> > from my understanding, with this, even writes
>> > to /proc/sys/vm/compact_memory doesn't wait for pageout, is this
>> > intended?
>> > on the other hand, MIGRATE_SYNC_LIGHT now waits for pagelock and buffe=
r
>> > lock, so could wait on page read. page read and page out have the same
>> > latency, why takes them different?
>>
>> So for the problem you raised, I think my suggestion to Mel is to adopt =
the
>> following logic:
>>
>> =A0 =A0 =A0 =A0 =A0 =A0if (!trylock_page(page) && !PageUptodate(page))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 we are quite likely to block=
 on read, so we
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 depend on yet another MIGRAT=
E_SYNC_MODE to decide
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if we really want to lock_pa=
ge() and wait for this IO.
>>
>> How do you think ?
>>
>
> Where are you adding this check?
>
> If you mean in __unmap_and_move(), the check is unnecessary unless
> another subsystem starts using sync-light compaction. With this series,
> only direct compaction cares about MIGRATE_SYNC_LIGHT. If the page is

But I am still a little bit confused that if MIGRATE_SYNC_LIGHT is only
used by direct compaction and  another mode can be used by it:
MIGRATE_ASYNC also does not write dirty pages, then why not also
do an (current->flags & PF_MEMALLOC) test before writing out pages,
like we already did for the page lock condition, but adding a new mode
instead?


> not up to date, it is also locked during the IO and unlocked after
> setting Uptodate in the IO completion handler.
>
> As the page is locked, compaction will fail trylock_page, do the
> PF_MEMALLOC check and bail as it is not safe for direct compaction
> to call lock_page as the comment in __unmap_and_move explains. This
> should avoid the stall.
>
> Did I misunderstand your suggestion?
>
> --
> Mel Gorman
> SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
