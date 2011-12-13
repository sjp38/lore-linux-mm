Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 438206B027C
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:29:36 -0500 (EST)
Received: by qan41 with SMTP id 41so4779785qan.14
        for <linux-mm@kvack.org>; Tue, 13 Dec 2011 10:29:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111213061035.GA8513@barrios-laptop.redhat.com>
References: <1323742608-9246-1-git-send-email-yinghan@google.com>
	<20111213061035.GA8513@barrios-laptop.redhat.com>
Date: Tue, 13 Dec 2011 10:29:34 -0800
Message-ID: <CALWz4iw1i_EtJD9y+JZb+5YnAOuZ93Bg=fO+-KGD6xR6a7znNw@mail.gmail.com>
Subject: Re: [PATCH 2/2] memcg: fix livelock in try charge during readahead
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Fengguang Wu <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

On Mon, Dec 12, 2011 at 10:10 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Mon, Dec 12, 2011 at 06:16:48PM -0800, Ying Han wrote:
>> Couple of kernel dumps are triggered by watchdog timeout. It turns out t=
hat two
>> processes within a memcg livelock on a same page lock. We believe this i=
s not
>> memcg specific issue and the same livelock exists in non-memcg world as =
well.
>>
>> The sequence of triggering the livelock:
>> 1. Task_A enters pagefault (filemap_fault) and then starts readahead
>> filemap_fault
>> =A0-> do_sync_mmap_readahead
>> =A0 =A0 -> ra_submit
>> =A0 =A0 =A0 =A0->__do_page_cache_readahead // here we allocate the reada=
head pages
>> =A0 =A0 =A0 =A0 =A0->read_pages
>> =A0 =A0 =A0 =A0 =A0...
>> =A0 =A0 =A0 =A0 =A0 =A0->add_to_page_cache_locked
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0//for each page, we do the try charge and the=
n add the page into
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0//radix tree. If one of the try charge failed=
, it enters per-memcg
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0//oom while holding the page lock of previous=
 readahead pages.
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 // in the memcg oom killer, it picks a task with=
in the same memcg
>> =A0 =A0 =A0 =A0 =A0 =A0 // and mark it TIF_MEMDIE. then it goes back int=
o retry loop and
>> =A0 =A0 =A0 =A0 =A0 =A0 // hopes the task exits to free some memory.
>>
>> 2. Task_B enters pagefault (filemap_fault) and finds the page in radix t=
ree (
>> one of the readahead pages from ProcessA)
>>
>> filemap_fault
>> =A0->__lock_page // here it is marked as TIF_MEMDIE. but it can not proc=
eed since
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// the page lock is hold by ProcessA loop=
ing at OOM.
>>
>> Since the TIF_MEMDIE task_B is live locked, it ends up blocking other ta=
sks
>> making forward progress since they are also checking the flag in
>> select_bad_process. The same issue exists in the non-memcg world. Instea=
d of
>> entering oom through mem_cgroup_cache_charge(), we might enter it throug=
h
>> radix_tree_preload().
>>
>> The proposed fix here is to pass __GFP_NORETRY gfp_mask into try charge =
under
>> readahead. Then we skip entering memcg OOM kill which eliminates the cas=
e where
>> it OOMs on one page and holds other page locks. It seems to be safe to d=
o that
>> since both filemap_fault() and do_generic_file_read() handles the fallba=
ck case
>> of "no_cached_page".
>>
>> Note:
>> After this patch, we might experience some charge fails for readahead pa=
ges
>> (since we don't enter oom). But this sounds sane compared to letting the=
 system
>> trying extremely hard to charge a readahead page by doing reclaim and th=
en oom,
>> the later one also triggers livelock as listed above.
>>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>> Signed-off-by: Ying Han <yinghan@google.com>
>
> Nice catch.
>
> The concern is GFP_KERNEL !=3D avoid OOM.
> Although it works now, it can be changed.
>
> With alternative idea, We can use explicit oom_killer_disable with __GFP_=
NOWARN
> but it wouldn't work since oom_killer_disabled isn't reference count vari=
able.
> Of course, we can change it with reference-counted atomic variable.
> The benefit is it's more explicit and doesn't depends on __GFP_NORETRY im=
plementation.
> So I don't have a good idea except above.

> If you want __GFP_NORTRY patch, thing we can do best is add comment in de=
tail, at least.
> both side, here add_to_page_cache_lru and there __GFP_NORETRY in include/=
linux/gfp.h.

Correct me in case i missed something, looks like I want to backport
the " x86,mm: make pagefault killable" patch, and we might be able to
solve the livelock w/o changing the readahead code.

Thanks

--Ying

>
>> ---
>> =A0fs/mpage.c =A0 =A0 | =A0 =A03 ++-
>> =A0mm/readahead.c | =A0 =A03 ++-
>> =A02 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/mpage.c b/fs/mpage.c
>> index 643e9f5..90d608e 100644
>> --- a/fs/mpage.c
>> +++ b/fs/mpage.c
>> @@ -380,7 +380,8 @@ mpage_readpages(struct address_space *mapping, struc=
t list_head *pages,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 prefetchw(&page->flags);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&page->lru);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!add_to_page_cache_lru(page, mapping,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 page->index, GFP_KERNEL)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 page->index,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 GFP_KERNEL | __GFP_NORETRY)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bio =3D do_mpage_readpage(bi=
o, page,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 nr_pages - page_idx,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 &last_block_in_bio, &map_bh,
>> diff --git a/mm/readahead.c b/mm/readahead.c
>> index cbcbb02..bc9431c 100644
>> --- a/mm/readahead.c
>> +++ b/mm/readahead.c
>> @@ -126,7 +126,8 @@ static int read_pages(struct address_space *mapping,=
 struct file *filp,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *page =3D list_to_page(pages);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&page->lru);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!add_to_page_cache_lru(page, mapping,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 page->index, GFP_KERNEL)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 page->index,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 GFP_KERNEL | __GFP_NORETRY)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mapping->a_ops->readpage(fil=
p, page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_cache_release(page);
>> --
>> 1.7.3.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign http://stopthemete=
r.ca/
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
