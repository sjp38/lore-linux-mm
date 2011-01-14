Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C8B826B0092
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 07:24:58 -0500 (EST)
Received: by iwn40 with SMTP id 40so2582842iwn.14
        for <linux-mm@kvack.org>; Fri, 14 Jan 2011 04:24:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110114121342.GQ23189@cmpxchg.org>
References: <20110114190412.73362cd7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110114191042.dd145d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20110114121342.GQ23189@cmpxchg.org>
Date: Fri, 14 Jan 2011 21:24:57 +0900
Message-ID: <AANLkTim8VLaXYH2HWYULBUP7vBb-FEJh4U=Zi-u2bMwX@mail.gmail.com>
Subject: Re: [PATCH 3/4] [BUGFIX] fix memcgroup LRU stat with THP
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, aarcange@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

2011/1/14 Johannes Weiner <hannes@cmpxchg.org>:
> On Fri, Jan 14, 2011 at 07:10:42PM +0900, KAMEZAWA Hiroyuki wrote:
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> memroy cgroup's LRU stat should take care of size of pages because
>> Transparent Hugepage inserts hugepage into LRU and zone counter
>> is updeted based on the size of page.
>>
>> If this value is the number wrong, memory reclaim will not work well.
>>
>> Note: only head page of THP's huge page is linked into LRU.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>> =A0mm/memcontrol.c | =A0 10 ++++++++--
>> =A01 file changed, 8 insertions(+), 2 deletions(-)
>>
>> Index: mmotm-0107/mm/memcontrol.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- mmotm-0107.orig/mm/memcontrol.c
>> +++ mmotm-0107/mm/memcontrol.c
>> @@ -815,7 +815,10 @@ void mem_cgroup_del_lru_list(struct page
>> =A0 =A0 =A0 =A0* removed from global LRU.
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 mz =3D page_cgroup_zoneinfo(pc);
>> - =A0 =A0 MEM_CGROUP_ZSTAT(mz, lru) -=3D 1;
>> + =A0 =A0 if (!PageTransHuge(page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, lru) -=3D 1;
>> + =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, lru) -=3D 1 << compound_o=
rder(page);
>
> compound_order() returns 0 for !PG_head pages, that should do the
> right thing without checking PageTransHuge(), right?

You're right. Then, I can remove this 'if'. Thank you.
Hmm, I'll check other places, again.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
