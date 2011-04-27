Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D65569000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 04:12:21 -0400 (EDT)
Received: by vws4 with SMTP id 4so1608623vws.14
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 01:12:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110427165437.bef6967a.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<1d9791f27df2341cb6750f5d6279b804151f57f9.1303833417.git.minchan.kim@gmail.com>
	<20110427165437.bef6967a.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 27 Apr 2011 17:12:19 +0900
Message-ID: <BANLkTinq7w+cejBgBMuWvGw9htK0YJOvEw@mail.gmail.com>
Subject: Re: [RFC 1/8] Only isolate page we can handle
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Apr 27, 2011 at 4:54 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 27 Apr 2011 01:25:18 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> There are some places to isolate lru page and I believe
>> users of isolate_lru_page will be growing.
>> The purpose of them is each different so part of isolated pages
>> should put back to LRU, again.
>>
>> The problem is when we put back the page into LRU,
>> we lose LRU ordering and the page is inserted at head of LRU list.
>> It makes unnecessary LRU churning so that vm can evict working set pages
>> rather than idle pages.
>>
>> This patch adds new filter mask when we isolate page in LRU.
>> So, we don't isolate pages if we can't handle it.
>> It could reduce LRU churning.
>>
>> This patch shouldn't change old behavior.
>> It's just used by next patches.
>>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> nitpick below.
>
>> ---
>> =C2=A0include/linux/swap.h | =C2=A0 =C2=A03 ++-
>> =C2=A0mm/compaction.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +-
>> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +-
>> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 26 ++++++++=
++++++++++++------
>> =C2=A04 files changed, 24 insertions(+), 9 deletions(-)
>>
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index 384eb5f..baef4ad 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -259,7 +259,8 @@ extern unsigned long mem_cgroup_shrink_node_zone(str=
uct mem_cgroup *mem,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 unsigned int swappiness,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 struct zone *zone,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 unsigned long *nr_scanned);
>> -extern int __isolate_lru_page(struct page *page, int mode, int file);
>> +extern int __isolate_lru_page(struct page *page, int mode, int file,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 int not_dirty, int not_mapped);
>
> Hmm, which is better to use 4 binary args or a flag with bitmask ?

Yes. Even I added new flags one more in next patch.
So I try to use bitmask flag in next version.
Thanks.


>
> Thanks,
> -Kame
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
