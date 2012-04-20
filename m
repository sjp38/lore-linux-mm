Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 78A3E6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 02:40:00 -0400 (EDT)
Received: by lbbgg6 with SMTP id gg6so1848858lbb.14
        for <linux-mm@kvack.org>; Thu, 19 Apr 2012 23:39:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F90FF57.9060401@jp.fujitsu.com>
References: <1334773315-32215-1-git-send-email-yinghan@google.com>
	<20120418163330.ca1518c7.akpm@linux-foundation.org>
	<4F8F6368.2090005@jp.fujitsu.com>
	<20120419131211.GA1759@cmpxchg.org>
	<4F90AFDE.2000707@jp.fujitsu.com>
	<CALWz4iw5+ypsD_vwm6vcDKN-JrV_riF4mFvQME2zr2jR_iNuOg@mail.gmail.com>
	<4F90FF57.9060401@jp.fujitsu.com>
Date: Thu, 19 Apr 2012 23:39:58 -0700
Message-ID: <CALWz4iw7NqytLSkwGwj284OLGQrPCOq_ez14TMj6dPiROi_3+w@mail.gmail.com>
Subject: Re: [PATCH V2] memcg: add mlock statistic in memory.stat
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Thu, Apr 19, 2012 at 11:16 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/04/20 14:57), Ying Han wrote:
>
>> On Thu, Apr 19, 2012 at 5:37 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>> (2012/04/19 22:12), Johannes Weiner wrote:
>>>> Plus this code runs for ALL uncharges, the unlikely() and preliminary
>>>> flag testing don't make it okay. =A0It's bad that we have this in the
>>>> allocator, but at least it would be good to hook into that branch and
>>>> not add another one.
>>>>
>>>> pc->mem_cgroup stays intact after the uncharge. =A0Could we make the
>>>> memcg removal path wait on the mlock counter to drop to zero instead
>>>> and otherwise keep Ying's version?
>>>>
>>>
>>>
>>> handling problem in ->destroy() path ? Hmm, it will work against use-af=
ter-free.
>>
>>> But accounting problem which may be caused by mem_cgroup_lru_add_list()=
 cannot
>>> be handled, which overwrites pc->mem_cgroup.
>>
>> Kame, can you clarify that? What the mem_cgroup_lru_add_list() has
>> anything to do w/ this problem?
>>
>
>
> It overwrites pc->mem_cgroup. Then, Assume a task in cgroup "A".
>
> =A0 =A0 =A0 =A01. page is charged. =A0 =A0 =A0 pc->mem_cgroup =3D A + Use=
d bit.
> =A0 =A0 =A0 =A02. page is set Mlocked. =A0 A's mlock-counter +=3D 1
> =A0 =A0 =A0 =A03. page is uncharged =A0 =A0 =A0- Used bit.
> =A0 =A0 =A0 =A04. page is added to lru =A0 pc->mem_cgroup =3D root
> =A0 =A0 =A0 =A05. page is freed =A0 =A0 =A0 =A0 =A0root's mlock-coutner -=
=3D1,
>
> Then, A's mlock-counter +1, root's mlock-counter -1 IF free_pages()
> really handle mlocked pages...

Hmm, now the question is whether the TestClearPageMlock() should only
happen between step 2 and step 3. If so, the mlock stat will be
updated correctly.

>
>
>
>>>
>>> But hm, is this too slow ?...
>>> =3D=3D
>>> mem_cgroup_uncharge_common()
>>> {
>>> =A0 =A0 =A0 =A0....
>>> =A0 =A0 =A0 =A0if (PageSwapCache(page) || PageMlocked(page))
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>>> }
>>>
>>> page_alloc.c::
>>>
>>> static inline void free_page_mlock(struct page *page)
>>> {
>>>
>>> =A0 =A0 =A0 =A0__dec_zone_page_state(page, NR_MLOCK);
>>> =A0 =A0 =A0 =A0__count_vm_event(UNEVICTABLE_MLOCKFREED);
>>>
>>> =A0 =A0 =A0 =A0mem_cgroup_uncharge_page(page);
>>> }
>>> =3D=3D
>>>
>>> BTW, at reading code briefly....why we have hooks in free_page() ?
>>>
>>> It seems do_munmap() and exit_mmap() calls munlock_vma_pages_all().
>>> So, it seems all vmas which has VM_MLOCKED are checked before freeing.
>>> vmscan never frees mlocked pages, I think.
>>>
>>> Any other path to free mlocked pages without munlock ?
>>
>> I found this commit which introduced the hook in the freeing path,
>> however I couldn't get more details why it was introduced from the
>> commit description
>>
>> commit 985737cf2ea096ea946aed82c7484d40defc71a8
>> Author: Lee Schermerhorn <lee.schermerhorn@hp.com>
>> Date: =A0 Sat Oct 18 20:26:53 2008 -0700
>>
>> =A0 =A0 mlock: count attempts to free mlocked page
>>
>> =A0 =A0 Allow free of mlock()ed pages. =A0This shouldn't happen, but dur=
ing
>> =A0 =A0 developement, it occasionally did.
>>
>> =A0 =A0 This patch allows us to survive that condition, while keeping th=
e
>> =A0 =A0 statistics and events correct for debug.
>>
>>> I feel freeing Mlocked page is a cause of problems.
>>
>
>
> Sigh...."This shouldn't happen"!!!!!
>
> How about adding warning to free_page() path and remove your current hook=
 ?

That does make thing a lot simpler.. I will wait a bit in case someone
remember a counter example?

--Ying

> Thanks,
> -Kame
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
