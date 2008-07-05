From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <20795958.1215245782985.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 5 Jul 2008 17:16:22 +0900 (JST)
Subject: Re: Re: [PATCH] memcg: handle shmem's swap cache (Was 2.6.26-rc8-mm1
In-Reply-To: <486F1967.1030207@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <486F1967.1030207@linux.vnet.ibm.com>
 <20080703020236.adaa51fa.akpm@linux-foundation.org> <20080704180913.bb1a3fc6.kamezawa.hiroyu@jp.fujitsu.com> <486F0976.7010104@linux.vnet.ibm.com> <20080705151146.206071a4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com, nishimura@mxp.nes.nec.co.jp, yamamoto@valinux.co.jp
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>Date: Sat, 05 Jul 2008 12:19:11 +0530
>From: Balbir Singh <balbir@linux.vnet.ibm.com>
>To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>CC: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
>   linux-mm@kvack.org, "hugh@veritas.com" <hugh@veritas.com>,
>   "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>,
>   "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
>Subject: Re: [PATCH] memcg: handle shmem's swap cache (Was 2.6.26-rc8-mm1
>
>
>KAMEZAWA Hiroyuki wrote:
>> On Sat, 05 Jul 2008 11:11:10 +0530
>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> 
>>> KAMEZAWA Hiroyuki wrote:
>>>> My swapcache accounting under memcg patch failed to catch tmpfs(shmem)'s 
one.
>>>> Can I test this under -mm tree ?
>>>> (If -mm is busy, I'm not in hurry.)
>>>> This patch works well in my box.
>>>> =
>>>> SwapCache handling fix.
>>>>
>>>> shmem's swapcache behavior is a little different from anonymous's one and
>>>> memcg failed to handle it. This patch tries to fix it.
>>>>
>>>> After this:
>>>>
>>>> Any page marked as SwapCache is not uncharged. (delelte_from_swap_cache()
>>>> delete the SwapCache flag.)
>>>>
>>>> To check a shmem-page-cache is alive or not we use
>>>>  page->mapping && !PageAnon(page) instead of
>>>>  pc->flags & PAGE_CGROUP_FLAG_CACHE.
>>>>
>>>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>> Though I am not opposed to this, I do sit up and think if keeping the refe
rence
>>> count around could avoid this complexity and from my point, the maintenanc
e
>>> overhead of this logic/code (I fear there might be more special cases :( )
>> 
>> yes, to me. but we have to fix..
>> 
>> But I don't like old code's refcnt handling which does
>>    - increment
>>      - does this increment was really neccesary ?
>>        No? ok, decrement it again.
>> 
>> This was much more complex to me than current code.
>> 
At first, what I have to say is
"this is a fix against handle-swapcache patch not against remove-refcnt"

This complex comes from handle-swapcache. (But it's necessary.)

>
>That can be redone -- the moment a page is used by a path, refcnt (increment)
>it. Undo the same when the page is no longer in use.
>
>I expect
>
>rmap path to increment/decrement it on mapping
>radix-tree (cache's) to do the same
>
>
>Using a kref we should be able to get this logic right - no?
>
no
What the old code does was

  - a page is added to rmap (mapcount 0->1) +1
  - a page is removed from rmap (mapcount ->0) -1
  - a page is added to radix-tree (+1)
  - a page is removed from radix-tree (-1)

All information is recorded in struct page because it exists for.
Then, why duplicates information ? It's usually bad habit.


>> And old ones will needs the check at treating swap-cache. (it couldn't but 
if we want)
>> 
>>> The trade-off is complexity versus the overhead of reference counting.
>>>
>> refcnt was also very complex ;)
>
>I think that is easier to simply, instead of adding the complex checks we hav
e
>right now. refcnt is easier to prove as working correct than the checks.

About swap-cache, refcnt is just obstacle because you can't handle
add-to-swapcache by refcnt.

If you want to add refcnt (or some code) for "debug", I have no objection.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
