Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B9D0D60021B
	for <linux-mm@kvack.org>; Sat,  2 Jan 2010 08:29:44 -0500 (EST)
Received: by iwn41 with SMTP id 41so9635775iwn.12
        for <linux-mm@kvack.org>; Sat, 02 Jan 2010 05:29:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1262429166.32223.32.camel@laptop>
References: <1262339141-4682-1-git-send-email-kosaki.motohiro@jp.fujitsu.com>
	 <1262387986.16572.234.camel@laptop>
	 <2f11576a1001012121o4f09d30n6dba925e74099da1@mail.gmail.com>
	 <1262429166.32223.32.camel@laptop>
Date: Sat, 2 Jan 2010 22:29:41 +0900
Message-ID: <2f11576a1001020529l729caebawc4364690f1df56cb@mail.gmail.com>
Subject: Re: [PATCH] mm, lockdep: annotate reclaim context to zone reclaim too
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

2010/1/2 Peter Zijlstra <peterz@infradead.org>:
> On Sat, 2010-01-02 at 14:21 +0900, KOSAKI Motohiro wrote:
>> 2010/1/2 Peter Zijlstra <peterz@infradead.org>:
>> > On Fri, 2010-01-01 at 18:45 +0900, KOSAKI Motohiro wrote:
>> >> Commit cf40bd16fd (lockdep: annotate reclaim context) introduced recl=
aim
>> >> context annotation. But it didn't annotate zone reclaim. This patch d=
o it.
>> >
>> > And yet you didn't CC anyone involved in that patch, nor explain why y=
ou
>> > think it necessary, massive FAIL.
>> >
>> > The lockdep annotations cover all of kswapd() and direct reclaim throu=
gh
>> > __alloc_pages_direct_reclaim(). So why would you need an explicit
>> > annotation in __zone_reclaim()?
>>
>> Thanks CCing. The point is zone-reclaim doesn't use
>> __alloc_pages_direct_reclaim.
>> current call graph is
>>
>> __alloc_pages_nodemask
>> =A0 =A0 get_page_from_freelist
>> =A0 =A0 =A0 =A0 zone_reclaim()
>> =A0 =A0 __alloc_pages_slowpath
>> =A0 =A0 =A0 =A0 __alloc_pages_direct_reclaim
>> =A0 =A0 =A0 =A0 =A0 =A0 try_to_free_pages
>>
>> Actually, if zone_reclaim_mode=3D1, VM never call
>> __alloc_pages_direct_reclaim in usual VM pressure.
>> Thus I think zone-reclaim should be annotated explicitly too.
>> I know almost user don't use zone reclaim mode. but explicit
>> annotation doesn't have any demerit, I think.
>
> Just be aware that the annotation isn't recursive, I'd have to trace all
> calls to __zone_reclaim, but if kswapd were ever to call it you'd just
> wrecked things by getting lockdep_clear_current_reclaim_state() called.
>
> So just make sure you don't shorten the existing notations by adding it
> here. Other than that it seems ok.

Umm, probably I haven't catch your mention. currently kswapd never
call __zone_reclaim() because
kswapd has PF_MEMALLOC and PF_MEMALLOC prevent to call __zone_reclaim
(see zone_reclaim()).

When recursive annotation occur?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
