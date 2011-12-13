Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 38A286B027A
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 12:59:16 -0500 (EST)
Received: by qan41 with SMTP id 41so4757620qan.14
        for <linux-mm@kvack.org>; Tue, 13 Dec 2011 09:59:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111213134554.2cec3c3a.kamezawa.hiroyu@jp.fujitsu.com>
References: <1323742608-9246-1-git-send-email-yinghan@google.com>
	<20111213134554.2cec3c3a.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 13 Dec 2011 09:59:14 -0800
Message-ID: <CALWz4iz2XUQqfC_0e4fK=XiQ7Ox3rj1J=oryxrDYZrGHD-OOaA@mail.gmail.com>
Subject: Re: [PATCH 2/2] memcg: fix livelock in try charge during readahead
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, Fengguang Wu <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

On Mon, Dec 12, 2011 at 8:45 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 12 Dec 2011 18:16:48 -0800
> Ying Han <yinghan@google.com> wrote:
>
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
>
> Should this __lock_page() be lock_page_killable() ?
> Hmm, at seeing linux-next, it's now lock_page_or_retry() and FAULT_FLAG_K=
ILLABLE
> is set. why not killed immediately ?

Hmm, thank you for pointing it out. It seems that we are missing the
following patch in the tree triggering the problem:

commit 37b23e0525d393d48a7d59f870b3bc061a30ccdb
Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date:   Tue May 24 17:11:30 2011 -0700

    x86,mm: make pagefault killable

    When an oom killing occurs, almost all processes are getting stuck at t=
he
    following two points.

        1) __alloc_pages_nodemask
        2) __lock_page_or_retry

By eye-balling the linux-next including the patch above, we should be
able to avoid the live-lock by checking the fatal_signal_pending in
the page fault path.

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
