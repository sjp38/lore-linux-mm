Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CB18D6B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 08:23:49 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n15DNl84015294
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 5 Feb 2009 22:23:47 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C622345DE53
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 22:23:46 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A713545DD72
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 22:23:46 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BDC71DB8043
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 22:23:46 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 36F151DB8041
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 22:23:46 +0900 (JST)
Message-ID: <74935449f7bd1248f959a526d56ca02a.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <498ADA5D.90201@virident.com>
References: <28631E6913C8074E95A698E8AC93D091B21561@caexch1.virident.info>
    <20090204183600.f41e8b7e.kamezawa.hiroyu@jp.fujitsu.com>
    <20090204184028.09a4bbae.kamezawa.hiroyu@jp.fujitsu.com>
    <20090204185501.837ff5d6.kamezawa.hiroyu@jp.fujitsu.com>
    <alpine.DEB.1.10.0902041037150.19633@qirst.com>
    <20090205101503.b1fd7df6.kamezawa.hiroyu@jp.fujitsu.com>
    <498ADA5D.90201@virident.com>
Date: Thu, 5 Feb 2009 22:23:45 +0900 (JST)
Subject: Re: [RFC][PATCH] release mmap_sem before starting migration (Was
 Re: Need to take mmap_sem lock in move_pages.
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Swamy Gowda <swamy@virident.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, brice.goglin@inria.fr, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Swamy Gowda wrote:
> KAMEZAWA Hiroyuki wrote:
>> On Wed, 4 Feb 2009 10:39:19 -0500 (EST)
>> Christoph Lameter <cl@linux-foundation.org> wrote:
>>
>>> On Wed, 4 Feb 2009, KAMEZAWA Hiroyuki wrote:
>>>
>>> > mmap_sem can be released after page table walk ends.
>>>
>>> No. read lock on mmap_sem must be held since the migrate functions
>>> manipulate page table entries. Concurrent large scale changes to the
>>> page
>>> tables (splitting vmas, remapping etc) must not be possible.
>>>
>> Just for clarification:
>>
>> 1. changes in page table is not problem from the viewpoint of kernel.
>>   (means no panic, no leak,...)
>> 2. But this loses "atomic" aspect of migration and will allow unexpected
>>   behaviors.
>>   (means the page-mapping status after sys_move may not be what user
>> expects.)
>>
>>
>> Thanks,
>> -Kame
>>
>>
> But I can't understand how user can see different page->mapping , since
> new page->mapping still holds the anon_vma pointer which should still
> contain the changes in the vma list( due to split vma etc). But,
> considering it as a problem how is it avoided in case of hotremove?
>
I'm sorry page-mapping in my text is not page->mapping. Just means
process's memory map.

In my point of view, no problems (I wrote no problem in the kernel.)

One big difference between sys_move_pages and hot remove is
hot-remove retries many times but sys_move_pages() doesn't.
So, race/contention in migrate_page() will dramatically decrease
success-rate of page migration by system call.

In user side, sys_move_pages(), we may have to think more.
I wonder that there may be much more contentions of pte_lock and
page_lock() etc... if we remove mmap_sem.
The good point of mmap_sem is the waiter can sleep without any troubles
and nest of locks.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
