Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C76AB8D0039
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 09:07:27 -0500 (EST)
Received: by iyf13 with SMTP id 13so2773091iyf.14
        for <linux-mm@kvack.org>; Mon, 21 Feb 2011 06:07:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110221084014.GC25382@cmpxchg.org>
References: <cover.1298212517.git.minchan.kim@gmail.com>
	<c76a1645aac12c3b8ffe2cc5738033f5a6da8d32.1298212517.git.minchan.kim@gmail.com>
	<20110221084014.GC25382@cmpxchg.org>
Date: Mon, 21 Feb 2011 23:07:26 +0900
Message-ID: <AANLkTikkGGQdxtshsWb8k2Lb89LwWznNjZLBB5i=UQrm@mail.gmail.com>
Subject: Re: [PATCH v6 2/3] memcg: move memcg reclaimable page into tail of
 inactive list
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Feb 21, 2011 at 5:40 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Sun, Feb 20, 2011 at 11:43:37PM +0900, Minchan Kim wrote:
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -813,6 +813,33 @@ void mem_cgroup_del_lru(struct page *page)
>> =C2=A0 =C2=A0 =C2=A0 mem_cgroup_del_lru_list(page, page_lru(page));
>> =C2=A0}
>>
>> +/*
>> + * Writeback is about to end against a page which has been marked for i=
mmediate
>> + * reclaim. =C2=A0If it still appears to be reclaimable, move it to the=
 tail of the
>> + * inactive list.
>> + */
>> +void mem_cgroup_rotate_reclaimable_page(struct page *page)
>> +{
>> + =C2=A0 =C2=A0 struct mem_cgroup_per_zone *mz;
>> + =C2=A0 =C2=A0 struct page_cgroup *pc;
>> + =C2=A0 =C2=A0 enum lru_list lru =3D page_lru(page);
>> +
>> + =C2=A0 =C2=A0 if (mem_cgroup_disabled())
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> +
>> + =C2=A0 =C2=A0 pc =3D lookup_page_cgroup(page);
>> + =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0* Used bit is set without atomic ops but after smp=
_wmb().
>> + =C2=A0 =C2=A0 =C2=A0* For making pc->mem_cgroup visible, insert smp_rm=
b() here.
>> + =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 smp_rmb();
>> + =C2=A0 =C2=A0 /* unused or root page is not rotated. */
>> + =C2=A0 =C2=A0 if (!PageCgroupUsed(pc) || mem_cgroup_is_root(pc->mem_cg=
roup))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>
> The placement of this barrier is confused and has been fixed up in the
> meantime in other places. =C2=A0It has to be between PageCgroupUsed() and
> accessing pc->mem_cgroup. =C2=A0You can look at the other memcg lru
> functions for reference.

Yes. I saw your patch at that time but forgot it.
I will resend fixed version.
Thanks.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
