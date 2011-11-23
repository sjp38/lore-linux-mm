Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1055D6B00B3
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 10:23:23 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so1842353vbb.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 07:23:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111123150810.GO19415@suse.de>
References: <1321900608-27687-1-git-send-email-mgorman@suse.de>
	<1321900608-27687-8-git-send-email-mgorman@suse.de>
	<1321945011.22361.335.camel@sli10-conroe>
	<CAPQyPG4DQCxDah5VYMU6PNgeuD_3WJ-zm8XpL7V7BK8hAF8OJg@mail.gmail.com>
	<20111123110041.GM19415@suse.de>
	<CAPQyPG588_q1diT8KyPirUD9MLME6SanO-cSw1twzhFiTBWgCw@mail.gmail.com>
	<20111123134512.GN19415@suse.de>
	<CAPQyPG6b-MiysHnEadWRX729_q7G=_mYozSR+OatS-TLs_Sw_Q@mail.gmail.com>
	<20111123150810.GO19415@suse.de>
Date: Wed, 23 Nov 2011 23:23:19 +0800
Message-ID: <CAPQyPG58cjEQ8jPFhxGB6URcFoNt=NBC1L+T8aEWVUtPfBNh-Q@mail.gmail.com>
Subject: Re: [PATCH 7/7] mm: compaction: Introduce sync-light migration for
 use by compaction
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Shaohua Li <shaohua.li@intel.com>, Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 23, 2011 at 11:08 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Wed, Nov 23, 2011 at 10:35:37PM +0800, Nai Xia wrote:
>> On Wed, Nov 23, 2011 at 9:45 PM, Mel Gorman <mgorman@suse.de> wrote:
>> > On Wed, Nov 23, 2011 at 09:05:08PM +0800, Nai Xia wrote:
>> >> > <SNIP>
>> >> >
>> >> > Where are you adding this check?
>> >> >
>> >> > If you mean in __unmap_and_move(), the check is unnecessary unless
>> >> > another subsystem starts using sync-light compaction. With this ser=
ies,
>> >> > only direct compaction cares about MIGRATE_SYNC_LIGHT. If the page =
is
>> >>
>> >> But I am still a little bit confused that if MIGRATE_SYNC_LIGHT is on=
ly
>> >> used by direct compaction and =A0another mode can be used by it:
>> >> MIGRATE_ASYNC also does not write dirty pages, then why not also
>> >> do an (current->flags & PF_MEMALLOC) test before writing out pages,
>> >
>> > Why would it be necessary?
>> > Why would it be better than what is there now?
>>
>> I mean, if
>> =A0 =A0MIGRATE_SYNC_LIGHT --> (current->flags & PF_MEMALLOC) and
>> =A0 =A0MIGRATE_SYNC_LIGHT --> no dirty writeback, and (current->flags & =
PF_MEMALLOC)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 --> (MIGRATE_SYNC_LIGHT || M=
IGRATE_ASYNC)
>> =A0 =A0MIGRATE_ASYNC =A0 =A0 =A0--> no dirty writeback, then
>> why not simply =A0(current->flags & PF_MEMALLOC) ---> no dirty writeback
>> and keep the sync meaning as it was?
>>
>
> Ok, I see what you mean. Instead of making MIGRATE_SYNC_LIGHT part of
> the API, we could instead special case within migrate.c how to behave if
> MIGRATE_SYNC && PF_MEMALLOC.

Yeah~

>
> This would be functionally equivalent and satisfy THP users
> but I do not see it as being easier to understand or easier
> to maintain than updating the API. If someone in the future
> wanted to use migration without significant stalls without
> being PF_MEMALLOC, they would need to update the API like this.
> There are no users like this today but automatic NUMA migration
> might want to leverage something like MIGRATE_SYNC_LIGHT
> (http://comments.gmane.org/gmane.linux.kernel.mm/70239)

I see.
So could I say that might be the time and users for my suggestion of
page uptodate check to fit into?



Thanks,

Nai
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
