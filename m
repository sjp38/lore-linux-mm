Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 7B4A06B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:27:54 -0500 (EST)
Received: by qadz30 with SMTP id z30so1447356qad.14
        for <linux-mm@kvack.org>; Fri, 13 Jan 2012 14:27:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120113091006.43de8ca5.kamezawa.hiroyu@jp.fujitsu.com>
References: <1326321668-5422-1-git-send-email-yinghan@google.com>
	<alpine.LSU.2.00.1201111512570.1846@eggly.anvils>
	<20120112085937.ae601869.kamezawa.hiroyu@jp.fujitsu.com>
	<CALWz4iyuT48FWuw52bcu3B9GvHbz3c3ODcsgPzOP80UOP1Q-bQ@mail.gmail.com>
	<20120112122116.7547cb42.kamezawa.hiroyu@jp.fujitsu.com>
	<CALWz4ixZdyFtVOnVfQ0=eYnx_BY1ibkm6oqdgYbAMkMxLS5E6A@mail.gmail.com>
	<20120113091006.43de8ca5.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 13 Jan 2012 14:27:53 -0800
Message-ID: <CALWz4ize9VQxH0UUEe+hQ3T5deJHeSMUh9SPyG=vix=wkzKHFg@mail.gmail.com>
Subject: Re: memcg: add mlock statistic in memory.stat
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Thu, Jan 12, 2012 at 4:10 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 12 Jan 2012 11:13:00 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> On Wed, Jan 11, 2012 at 7:21 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Wed, 11 Jan 2012 16:50:09 -0800
>> > Ying Han <yinghan@google.com> wrote:
>> >
>> >> On Wed, Jan 11, 2012 at 3:59 PM, KAMEZAWA Hiroyuki
>> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >> > On Wed, 11 Jan 2012 15:17:42 -0800 (PST)
>> >> > Hugh Dickins <hughd@google.com> wrote:
>> >> >
>> >> >> On Wed, 11 Jan 2012, Ying Han wrote:
>> >> >>
>> >> >> > We have the nr_mlock stat both in meminfo as well as vmstat syst=
em wide, this
>> >> >> > patch adds the mlock field into per-memcg memory stat. The stat =
itself enhances
>> >> >> > the metrics exported by memcg, especially is used together with =
"uneivctable"
>> >> >> > lru stat.
>> >> >> >
>> >> >> > --- a/include/linux/page_cgroup.h
>> >> >> > +++ b/include/linux/page_cgroup.h
>> >> >> > @@ -10,6 +10,7 @@ enum {
>> >> >> > =A0 =A0 /* flags for mem_cgroup and file and I/O status */
>> >> >> > =A0 =A0 PCG_MOVE_LOCK, /* For race between move_account v.s. fol=
lowing bits */
>> >> >> > =A0 =A0 PCG_FILE_MAPPED, /* page is accounted as "mapped" */
>> >> >> > + =A0 PCG_MLOCK, /* page is accounted as "mlock" */
>> >> >> > =A0 =A0 /* No lock in page_cgroup */
>> >> >> > =A0 =A0 PCG_ACCT_LRU, /* page has been accounted for (under lru_=
lock) */
>> >> >> > =A0 =A0 __NR_PCG_FLAGS,
>> >> >>
>> >> >> Is this really necessary? =A0KAMEZAWA-san is engaged in trying to =
reduce
>> >> >> the number of PageCgroup flags, and I expect that in due course we=
 shall
>> >> >> want to merge them in with Page flags, so adding more is unwelcome=
.
>> >> >> I'd =A0have thought that with memcg_ hooks in the right places,
>> >> >> a separate flag would not be necessary?
>> >> >>
>> >> >
>> >> > Please don't ;)
>> >> >
>> >> > NR_UNEIVCTABLE_LRU is not enough ?
>> >>
>> >> Seems not.
>> >>
>> >> The unevictable lru includes more than mlock()'d pages ( SHM_LOCK'd
>> >> etc). There are use cases where we like to know the mlock-ed size
>> >> per-cgroup. We used to archived that in fake-numa based container by
>> >> reading the value from per-node meminfo, however we miss that
>> >> information in memcg. What do you think?
>> >>
>> >
>> > Hm. The # of mlocked pages can be got sum of /proc/<pid>/? ?
>>
>> That is tough. Then we have to do the calculation by adding up all the
>> pids within a cgroup.
>>
>> > BTW, Roughly..
>> >
>> > (inactive_anon + active_anon) - rss =3D # of unlocked shm.
>> >
>> > cache - (inactive_file + active_file) =3D total # of shm
>> >
>> > Then,
>> >
>> > (cache - =A0(inactive_file + active_file)) - ((inactive_anon + active_=
anon) - rss)
>> > =3D cache + rss - (sum of inactive/actige lru)
>> > =3D locked shm.
>> >
>> > Hm, but this works only when unmapped swapcache is =A0small ;)
>>
>> We might be getting a rough number. But we have use cases relying on
>> more accurate output. Thoughts?
>>
> If we need mega-byte order accuracy, above will work enough.
> But ok, having stats seems useful because meminfo has it ;)

Thanks.

>
> For your input, I'd like to post an updated RFC patch to do page state ac=
counting
> without additional bits to pc->flags, today. With that, you can rely on P=
G_mlocked.
>
> By that patch, I know we can make use of page-flags by some logic but am =
still
> looking for more efficient way...

Thank you for the heads up. It makes sense to me to look at your
patchset first, and then the mlock stat patch comes after that.

--Ying
>
> Thanks,
> -Kame
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
