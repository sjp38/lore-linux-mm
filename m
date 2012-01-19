Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id EDCB96B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 10:05:22 -0500 (EST)
Received: by iadj38 with SMTP id j38so21861iad.14
        for <linux-mm@kvack.org>; Thu, 19 Jan 2012 07:05:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1201182100010.2830@eggly.anvils>
References: <1326949826.5016.5.camel@lappy> <20120119122354.66eb9820.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LSU.2.00.1201181932040.2287@eggly.anvils> <20120119130353.0ca97435.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LSU.2.00.1201182100010.2830@eggly.anvils>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Thu, 19 Jan 2012 10:05:01 -0500
Message-ID: <CA+1xoqe5zNrx5H66HwkoywHf9FD6QTr2fcAPJSUbEx2KHf1VOg@mail.gmail.com>
Subject: Re: [BUG] kernel BUG at mm/memcontrol.c:1074!
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, hannes <hannes@cmpxchg.org>, mhocko@suse.cz, bsingharora@gmail.com, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-kernel <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 19, 2012 at 12:16 AM, Hugh Dickins <hughd@google.com> wrote:
> On Thu, 19 Jan 2012, KAMEZAWA Hiroyuki wrote:
>> On Wed, 18 Jan 2012 19:41:44 -0800 (PST)
>> Hugh Dickins <hughd@google.com> wrote:
>> >
>> > I notice that, unlike Linus's git, this linux-next still has
>> > mm-isolate-pages-for-immediate-reclaim-on-their-own-lru.patch in.
>> >
>> > I think that was well capable of oopsing in mem_cgroup_lru_del_list(),
>> > since it didn't always know which lru a page belongs to.
>> >
>> > I'm going to be optimistic and assume that was the cause.
>> >
>> Hmm, because the log hits !memcg at lru "del", the page should be added
>> to LRU somewhere and the lru must be determined by pc->mem_cgroup.
>>
>> Once set, pc->mem_cgroup is not cleared, just overwritten. AFAIK, there =
is
>> only one chance to set pc->mem_cgroup as NULL... initalization.
>> I wonder why it hits lru_del() rather than lru_add()...
>> ................
>>
>> Ahhhh, ok, it seems you are right. the patch has following kinds of code=
s
>> =3D=3D
>> +static void pagevec_putback_immediate_fn(struct page *page, void *arg)
>> +{
>> + =A0 =A0 =A0 struct zone *zone =3D page_zone(page);
>> +
>> + =A0 =A0 =A0 if (PageLRU(page)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum lru_list lru =3D page_lru(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&page->lru, &zone->lru[lru].list=
);
>> + =A0 =A0 =A0 }
>> +}
>> =3D=3D
>> ..this will bypass mem_cgroup_lru_add(), and we can see bug in lru_del()
>> rather than lru_add()..
>
> I've not thought it through in detail (and your questioning reminds me
> that the worst I saw from that patch was updating of the wrong counts,
> leading to underflow, then livelock from the mismatch between empty list
> and enormous count: I never saw an oops from it, and may be mistaken).
>
>>
>> Another question is who pushes pages to LRU before setting pc->mem_cgrou=
p..
>> Anyway, I think we need to fix memcg to be LRU_IMMEDIATE aware.
>
> I don't think so: Mel agreed that the patch could not go forward as is,
> without an additional pageflag, and asked Andrew to drop it from mmotm
> in mail on 29th December (I didn't notice an mm-commits message to say
> akpm did drop it, and marc is blacked out in protest for today, so I
> cannot check: but certainly akpm left it out of his push to Linus).
>
> Oh, and Mel noticed another bug in it on the 30th, that the PageLRU
> check in the function you quote above is wrong: see PATCH 11/11 thread.

So reverting this patch seems to indeed solve the issue (though
reverting wasn't clean - some minor conflicts in mm/swap.c).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
