Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8F56B007B
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 01:08:31 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p5358NSc011660
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 22:08:28 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by kpbe12.cbf.corp.google.com with ESMTP id p5358LaV001233
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 22:08:22 -0700
Received: by qyk7 with SMTP id 7so3009287qyk.12
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 22:08:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110602221906.GA4554@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-8-git-send-email-hannes@cmpxchg.org>
	<BANLkTi=cHVZP+fZwHNM3cXVyw53kJ2HQmw@mail.gmail.com>
	<BANLkTimvuwLYwzRT-6k_oVwKBzBEo500s-rXETerTskYHfontQ@mail.gmail.com>
	<BANLkTik1X72Re_QKM4iCaPbxCx2kcnfH_w@mail.gmail.com>
	<20110602221906.GA4554@cmpxchg.org>
Date: Thu, 2 Jun 2011 22:08:21 -0700
Message-ID: <BANLkTinSx6M1y9MsN6TJ_340X4kXt6HM1w@mail.gmail.com>
Subject: Re: [patch 7/8] vmscan: memcg-aware unevictable page rescue scanner
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Jun 2, 2011 at 3:19 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Fri, Jun 03, 2011 at 07:01:34AM +0900, Hiroyuki Kamezawa wrote:
>> 2011/6/3 Ying Han <yinghan@google.com>:
>> > On Thu, Jun 2, 2011 at 6:27 AM, Hiroyuki Kamezawa
>> > <kamezawa.hiroyuki@gmail.com> wrote:
>> >> 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
>> >>> Once the per-memcg lru lists are exclusive, the unevictable page
>> >>> rescue scanner can no longer work on the global zone lru lists.
>> >>>
>> >>> This converts it to go through all memcgs and scan their respective
>> >>> unevictable lists instead.
>> >>>
>> >>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>> >>
>> >> Hm, isn't it better to have only one GLOBAL LRU for unevictable pages=
 ?
>> >> memcg only needs counter for unevictable pages and LRU is not necessa=
ry
>> >> to be per memcg because we don't reclaim it...
>> >
>> > Hmm. Are we suggesting to keep one un-evictable LRU list for all
>> > memcgs? So we will have
>> > exclusive lru only for file and anon. If so, we are not done to make
>> > all the lru list being exclusive
>> > which is critical later to improve the zone->lru_lock contention
>> > across the memcgs
>> >
>> considering lrulock, yes, maybe you're right.
>
> That's one of the complications.

That should be achievable if we make all the per-memcg lru being
exclusive. So we can switch the global zone->lru_lock
to per-memcg-per-zone lru_lock. We have a prototype of the patch doing
something like that, but we will wait for this effort
being discussed and reviewed.

--Ying

>
>> > Sorry If i misinterpret the suggestion here
>> >
>>
>> My concern is I don't know for what purpose this function is used ..
>
> I am not sure how it's supposed to be used, either. =A0But it's
> documented to be a 'really big hammer' and it's kicked off from
> userspace. =A0So I suppose having the thing go through all memcgs bears
> a low risk of being a problem. =A0My suggestion is we go that way until
> someone complains.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
