Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 8FF1A6B0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 04:50:19 -0400 (EDT)
Received: by mail-bk0-f51.google.com with SMTP id ik5so306584bkc.24
        for <linux-mm@kvack.org>; Wed, 13 Mar 2013 01:50:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <513FD0CB.4000407@jp.fujitsu.com>
References: <1363082773-3598-1-git-send-email-handai.szj@taobao.com>
	<1363082920-3711-1-git-send-email-handai.szj@taobao.com>
	<513FD0CB.4000407@jp.fujitsu.com>
Date: Wed, 13 Mar 2013 16:50:17 +0800
Message-ID: <CAFj3OHUMyJDmDd4TYCXw4JO+cgH4AAFy3uSV93T3FfcF42eKew@mail.gmail.com>
Subject: Re: [PATCH 1/6] memcg: use global stat directly for root memcg usage
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, glommer@parallels.com, akpm@linux-foundation.org, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

On Wed, Mar 13, 2013 at 9:05 AM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2013/03/12 19:08), Sha Zhengju wrote:
>> Since mem_cgroup_recursive_stat(root_mem_cgroup, INDEX) will sum up
>> all memcg stats without regard to root's use_hierarchy, we may use
>> global stats instead for simplicity.
>>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>> ---
>>   mm/memcontrol.c |    6 +++---
>>   1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 669d16a..735cd41 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -4987,11 +4987,11 @@ static inline u64 mem_cgroup_usage(struct mem_cg=
roup *memcg, bool swap)
>>                       return res_counter_read_u64(&memcg->memsw, RES_USA=
GE);
>>       }
>>
>> -     val =3D mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
>> -     val +=3D mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS);
>> +     val =3D global_page_state(NR_FILE_PAGES);
>> +     val +=3D global_page_state(NR_ANON_PAGES);
>>
> you missed NR_ANON_TRANSPARENT_HUGEPAGES
right..

>
>>       if (swap)
>> -             val +=3D mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_=
SWAP);
>> +             val +=3D total_swap_pages - atomic_long_read(&nr_swap_page=
s);
>>
> Double count mapped SwapCache ? Did you saw Costa's trial in a week ago ?

yeah, I=92m hesitating how to handle swapcache. I've replied in that thread=
.  : )


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
