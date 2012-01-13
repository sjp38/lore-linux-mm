Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id E41286B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:24:16 -0500 (EST)
Received: by qadb10 with SMTP id b10so55038qad.14
        for <linux-mm@kvack.org>; Fri, 13 Jan 2012 14:24:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120112204458.GA10389@tiehlicka.suse.cz>
References: <1326321668-5422-1-git-send-email-yinghan@google.com>
	<20120112125411.GG1042@tiehlicka.suse.cz>
	<CALWz4izcSeY3TvrBUurg+X_fyHn3EPGRRS_jvSr0c2CWDnuhAQ@mail.gmail.com>
	<20120112204458.GA10389@tiehlicka.suse.cz>
Date: Fri, 13 Jan 2012 14:24:15 -0800
Message-ID: <CALWz4iwRRm9wiAQoY9w6XTOVcR_VQNYo-4jiswPqu9zD9_NgoQ@mail.gmail.com>
Subject: Re: memcg: add mlock statistic in memory.stat
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Thu, Jan 12, 2012 at 12:44 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Thu 12-01-12 11:09:58, Ying Han wrote:
>> On Thu, Jan 12, 2012 at 4:54 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> > On Wed 11-01-12 14:41:08, Ying Han wrote:
>> >> We have the nr_mlock stat both in meminfo as well as vmstat system wi=
de, this
>> >> patch adds the mlock field into per-memcg memory stat. The stat itsel=
f enhances
>> >> the metrics exported by memcg, especially is used together with "unei=
vctable"
>> >> lru stat.
>> >
>> > Could you describe when the unevictable has such a different meaning t=
han
>> > mlocked that it is unusable?
>>
>> The unevictable lru includes more than mlock()'d pages ( SHM_LOCK'd
>> etc). Like the following:
>
> Yes, I am aware of that. Maybe I wasn't clear enough in my question. I
> was rather interested _when_ it actually matters for your decisions about
> the setup. Those pages are not evictable anyway.

It is true that we (as kernel) can not do much on those pages as long
as they are unevictable. The mlock stat I am proposing is more useful
for system admin, and sometimes for kernel developers as well. Many
times in the past that we need to read the mlock stat from the
per-container meminfo for different reasons. Sorry I can not give you
a very concrete example, but I do remember it happened a lot.

On the other hand, we do have the ability to read the mlock from
meminfo, and we should add the same visibility to memcg as well.

--Ying

>
>> $ memtoy>shmem shm_400m 400m
>> $ memtoy>map shm_400m 0 400m
>> $ memtoy>touch shm_400m
>> memtoy: =A0touched 102400 pages in =A00.360 secs
>> $ memtoy>slock shm_400m
>> //meantime add some memory pressure.
>>
>> $ memtoy>file /export/hda3/file_512m
>> $ memtoy>map file_512m 0 512m shared
>> $ memtoy>lock file_512m
>>
>> $ cat /dev/cgroup/memory/B/memory.stat
>> mapped_file 956301312
>> mlock 536870912
>> unevictable 956203008
>>
>> Here, mapped_file - mlock =3D 400M shm_lock'ed pages are included in
>> unevictable stat.
>>
>> Besides, not all mlock'ed pages get to unevictable lru at the first
>> place, and the same for the other way around.
>>
>> Thanks
>>
>> --Ying
>
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
