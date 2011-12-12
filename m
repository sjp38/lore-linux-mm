Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id B7FB56B018E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 10:32:28 -0500 (EST)
Received: by qadc16 with SMTP id c16so678601qad.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 07:32:27 -0800 (PST)
Message-ID: <4EE61E6D.4070401@gmail.com>
Date: Mon, 12 Dec 2011 10:31:57 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] mm: simplify find_vma_prev
References: <1323466526.27746.29.camel@joe2Laptop> <1323470921-12931-1-git-send-email-kosaki.motohiro@gmail.com> <20111212094930.9d4716e1.kamezawa.hiroyu@jp.fujitsu.com> <20111212182711.3a072358.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111212182711.3a072358.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Andrew Morton (commit_signer:15/23=65%)" <akpm@linux-foundation.org>, "Hugh Dickins (commit_signer:7/23=30%)" <hughd@google.com>, "Peter Zijlstra (commit_signer:4/23=17%)" <a.p.zijlstra@chello.nl>, "Shaohua Li (commit_signer:3/23=13%)" <shaohua.li@intel.com>

(12/12/11 4:27 AM), KAMEZAWA Hiroyuki wrote:
> On Mon, 12 Dec 2011 09:49:30 +0900
> KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>  wrote:
>
>> On Fri,  9 Dec 2011 17:48:40 -0500
>> kosaki.motohiro@gmail.com wrote:
>>
>>> From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>>>
>>> commit 297c5eee37 (mm: make the vma list be doubly linked) added
>>> vm_prev member into vm_area_struct. Therefore we can simplify
>>> find_vma_prev() by using it. Also, this change help to improve
>>> page fault performance because it has strong locality of reference.
>>>
>>> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>>
>> Reviewed-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>>
>
> Hmm, your work remind me of a patch I tried in past.
> Here is a refleshed one...how do you think ?
>
> ==
>  From c0261936fc01322d06425731d33f38b2021e8067 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Date: Mon, 12 Dec 2011 18:31:19 +0900
> Subject: [PATCH] per thread vma cache.
>
> This is a toy patch. How do you think ?
>
> This is a patch for per-thread mmap_cache without heavy atomic ops.
>
> I'm sure overhead of find_vma() is pretty small in usual application
> and this will not show good improvement. But I think, if we need
> to have cache of vma, it should be per thread rather than per mm.

Agreed. per-thread is better.


> This patch adds thread->mmap_cache, a pointer for vm_area_struct
> and update it appropriately. Because we have no refcnt on vm_area_struct,
> thread->mmap_cache may be a stale pointer. This patch detects stale
> pointer by checking
>
>      - thread->mmap_cache is one of SLABs in vm_area_cachep.
>      - thread->mmap_cache->vm_mm == mm.
>
> vma->vm_mm will be cleared before kmem_cache_free() by this patch.

Do you mean the cache can make mishit with unrelated vma when freed vma 
was reused?
If so, it is most tricky part of this patch, I strongly hope you write
a comment more.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
