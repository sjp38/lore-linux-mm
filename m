Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 65ABA6B0081
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 03:56:29 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 445B73EE0BC
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 16:56:27 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B87245DEB2
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 16:56:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1467B45DE9E
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 16:56:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 06ABF1DB803E
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 16:56:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AA1A51DB8038
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 16:56:26 +0900 (JST)
Message-ID: <4FE2D2F4.2020202@jp.fujitsu.com>
Date: Thu, 21 Jun 2012 16:53:24 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: add per cgroup dirty pages accounting
References: <1339761611-29033-1-git-send-email-handai.szj@taobao.com> <1339761717-29070-1-git-send-email-handai.szj@taobao.com> <xr93k3z8twtg.fsf@gthelen.mtv.corp.google.com> <4FDC28F0.8050805@jp.fujitsu.com> <CAFj3OHXuX7tpDe4famK3fFMZBcj2w-9mDs9mD9P_-SwaRKx8tg@mail.gmail.com>
In-Reply-To: <CAFj3OHXuX7tpDe4famK3fFMZBcj2w-9mDs9mD9P_-SwaRKx8tg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, yinghan@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, Sha Zhengju <handai.szj@taobao.com>

(2012/06/19 23:31), Sha Zhengju wrote:
> On Sat, Jun 16, 2012 at 2:34 PM, Kamezawa Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com>  wrote:
>> (2012/06/16 0:32), Greg Thelen wrote:
>>>
>>> On Fri, Jun 15 2012, Sha Zhengju wrote:
>>>
>>>> This patch adds memcg routines to count dirty pages. I notice that
>>>> the list has talked about per-cgroup dirty page limiting
>>>> (http://lwn.net/Articles/455341/) before, but it did not get merged.
>>>
>>>
>>> Good timing, I was just about to make another effort to get some of
>>> these patches upstream.  Like you, I was going to start with some basic
>>> counters.
>>>
>>> Your approach is similar to what I have in mind.  While it is good to
>>> use the existing PageDirty flag, rather than introducing a new
>>> page_cgroup flag, there are locking complications (see below) to handle
>>> races between moving pages between memcg and the pages being {un}marked
>>> dirty.
>>>
>>>> I've no idea how is this going now, but maybe we can add per cgroup
>>>> dirty pages accounting first. This allows the memory controller to
>>>> maintain an accurate view of the amount of its memory that is dirty
>>>> and can provide some infomation while group's direct reclaim is working.
>>>>
>>>> After commit 89c06bd5 (memcg: use new logic for page stat accounting),
>>>> we do not need per page_cgroup flag anymore and can directly use
>>>> struct page flag.
>>>>
>>>>
>>>> Signed-off-by: Sha Zhengju<handai.szj@taobao.com>
>>>> ---
>>>>   include/linux/memcontrol.h |    1 +
>>>>   mm/filemap.c               |    1 +
>>>>   mm/memcontrol.c            |   32 +++++++++++++++++++++++++-------
>>>>   mm/page-writeback.c        |    2 ++
>>>>   mm/truncate.c              |    1 +
>>>>   5 files changed, 30 insertions(+), 7 deletions(-)
>>>>
>>>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>>>> index a337c2e..8154ade 100644
>>>> --- a/include/linux/memcontrol.h
>>>> +++ b/include/linux/memcontrol.h
>>>> @@ -39,6 +39,7 @@ enum mem_cgroup_stat_index {
>>>>         MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
>>>>         MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
>>>>         MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
>>>> +       MEM_CGROUP_STAT_FILE_DIRTY,  /* # of dirty pages in page cache */
>>>>         MEM_CGROUP_STAT_NSTATS,
>>>>   };
>>>>
>>>> diff --git a/mm/filemap.c b/mm/filemap.c
>>>> index 79c4b2b..5b5c121 100644
>>>> --- a/mm/filemap.c
>>>> +++ b/mm/filemap.c
>>>> @@ -141,6 +141,7 @@ void __delete_from_page_cache(struct page *page)
>>>>          * having removed the page entirely.
>>>>          */
>>>>         if (PageDirty(page)&&    mapping_cap_account_dirty(mapping)) {
>>>> +               mem_cgroup_dec_page_stat(page,
>>>> MEM_CGROUP_STAT_FILE_DIRTY);
>>>
>>>
>>> You need to use mem_cgroup_{begin,end}_update_page_stat around critical
>>> sections that:
>>> 1) check PageDirty
>>> 2) update MEM_CGROUP_STAT_FILE_DIRTY counter
>>>
>>> This protects against the page from being moved between memcg while
>>> accounting.  Same comment applies to all of your new calls to
>>> mem_cgroup_{dec,inc}_page_stat.  For usage pattern, see
>>> page_add_file_rmap.
>>>
>>
>> If you feel some difficulty with mem_cgroup_{begin,end}_update_page_stat(),
>> please let me know...I hope they should work enough....
>>
>
> Hi, Kame
>
> While digging into the bigger lock of mem_cgroup_{begin,end}_update_page_stat(),
> I find the reality is more complex than I thought. Simply stated,
> modifying page info
> and update page stat may be wide apart and in different level (eg.
> mm&fs), so if we
> use the big lock it may lead to scalability and maintainability issues.
>
> For example:
>       mem_cgroup_begin_update_page_stat()
>       modify page information                 =>  TestSetPageDirty ina??ceph_set_page_dirty() (fs/ceph/addr.c)
>       XXXXXX                                  =>  other fs operations
>       mem_cgroup_update_page_stat()   =>  account_page_dirtied() ina??mm/page-writeback.c
>       mem_cgroup_end_update_page_stat().
>
> We can choose to get lock in higher level meaning vfs set_page_dirty()
> but this may span
> too much and can also have some missing cases.
> What's your opinion of this problem?
>

yes, that's sad....If set_page_dirty() is always called under lock_page(), the
story will be easier (we'll take lock_page() in move side.)
but the comment on set_page_dirty() says it's not true.....Now, I haven't found a magical
way for avoiding the race.
(*) If holding lock_page() in move_account() can be a generic solution, it will be good.
     
A proposal from me is a small-start. You can start from adding hooks to a generic
functions as set_page_dirty() and __set_page_dirty_nobuffers(), clear_page_dirty_for_io().

And see what happens. I guess we can add WARN_ONCE() against callers of update_page_stat()
who don't take mem_cgroup_begin/end_update_page_stat()
(by some new check, for example, checking !rcu_read_lock_held() in update_stat())

I think we can make TODO list and catch up remaining things one by one.

Thanks,
-Kame

















--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
