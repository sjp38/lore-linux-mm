Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 9F7196B02D4
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 06:31:21 -0500 (EST)
Received: by ghrr18 with SMTP id r18so181769ghr.14
        for <linux-mm@kvack.org>; Wed, 14 Dec 2011 03:31:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALWz4iw1i_EtJD9y+JZb+5YnAOuZ93Bg=fO+-KGD6xR6a7znNw@mail.gmail.com>
References: <1323742608-9246-1-git-send-email-yinghan@google.com>
	<20111213061035.GA8513@barrios-laptop.redhat.com>
	<CALWz4iw1i_EtJD9y+JZb+5YnAOuZ93Bg=fO+-KGD6xR6a7znNw@mail.gmail.com>
Date: Wed, 14 Dec 2011 20:31:20 +0900
Message-ID: <CAEwNFnDbGcbzEd1j4ctXu=WpZ7GwnV3Md1+7sQVvNBOVN6LR4A@mail.gmail.com>
Subject: Re: [PATCH 2/2] memcg: fix livelock in try charge during readahead
From: Minchan Kim <minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Fengguang Wu <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

On Wed, Dec 14, 2011 at 3:29 AM, Ying Han <yinghan@google.com> wrote:
> On Mon, Dec 12, 2011 at 10:10 PM, Minchan Kim <minchan@kernel.org> wrote:
>> On Mon, Dec 12, 2011 at 06:16:48PM -0800, Ying Han wrote:
>>> Couple of kernel dumps are triggered by watchdog timeout. It turns out =
that two
>>> processes within a memcg livelock on a same page lock. We believe this =
is not
>>> memcg specific issue and the same livelock exists in non-memcg world as=
 well.
>>>
>>> The sequence of triggering the livelock:
>>> 1. Task_A enters pagefault (filemap_fault) and then starts readahead
>>> filemap_fault
>>> =C2=A0-> do_sync_mmap_readahead
>>> =C2=A0 =C2=A0 -> ra_submit
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0->__do_page_cache_readahead // here we alloc=
ate the readahead pages
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0->read_pages
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0...
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0->add_to_page_cache_locked
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0//for each page, we do =
the try charge and then add the page into
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0//radix tree. If one of=
 the try charge failed, it enters per-memcg
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0//oom while holding the=
 page lock of previous readahead pages.
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 // in the memcg oom killer, i=
t picks a task within the same memcg
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 // and mark it TIF_MEMDIE. th=
en it goes back into retry loop and
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 // hopes the task exits to fr=
ee some memory.
>>>
>>> 2. Task_B enters pagefault (filemap_fault) and finds the page in radix =
tree (
>>> one of the readahead pages from ProcessA)
>>>
>>> filemap_fault
>>> =C2=A0->__lock_page // here it is marked as TIF_MEMDIE. but it can not =
proceed since
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0// the page lock=
 is hold by ProcessA looping at OOM.
>>>
>>> Since the TIF_MEMDIE task_B is live locked, it ends up blocking other t=
asks
>>> making forward progress since they are also checking the flag in
>>> select_bad_process. The same issue exists in the non-memcg world. Inste=
ad of
>>> entering oom through mem_cgroup_cache_charge(), we might enter it throu=
gh
>>> radix_tree_preload().
>>>
>>> The proposed fix here is to pass __GFP_NORETRY gfp_mask into try charge=
 under
>>> readahead. Then we skip entering memcg OOM kill which eliminates the ca=
se where
>>> it OOMs on one page and holds other page locks. It seems to be safe to =
do that
>>> since both filemap_fault() and do_generic_file_read() handles the fallb=
ack case
>>> of "no_cached_page".
>>>
>>> Note:
>>> After this patch, we might experience some charge fails for readahead p=
ages
>>> (since we don't enter oom). But this sounds sane compared to letting th=
e system
>>> trying extremely hard to charge a readahead page by doing reclaim and t=
hen oom,
>>> the later one also triggers livelock as listed above.
>>>
>>> Signed-off-by: Greg Thelen <gthelen@google.com>
>>> Signed-off-by: Ying Han <yinghan@google.com>
>>
>> Nice catch.
>>
>> The concern is GFP_KERNEL !=3D avoid OOM.
>> Although it works now, it can be changed.
>>
>> With alternative idea, We can use explicit oom_killer_disable with __GFP=
_NOWARN
>> but it wouldn't work since oom_killer_disabled isn't reference count var=
iable.
>> Of course, we can change it with reference-counted atomic variable.
>> The benefit is it's more explicit and doesn't depends on __GFP_NORETRY i=
mplementation.
>> So I don't have a good idea except above.
>
>> If you want __GFP_NORTRY patch, thing we can do best is add comment in d=
etail, at least.
>> both side, here add_to_page_cache_lru and there __GFP_NORETRY in include=
/linux/gfp.h.
>
> Correct me in case i missed something, looks like I want to backport
> the " x86,mm: make pagefault killable" patch, and we might be able to
> solve the livelock w/o changing the readahead code.
>

I missed lock_page_or_retry Kame pointed out.
So, backport should solve the problem.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
