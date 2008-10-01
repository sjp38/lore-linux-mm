Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m9161fV2011730
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 16:01:42 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m915x7OL220278
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 15:59:09 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m915x73Z014425
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 15:59:07 +1000
Message-ID: <48E311A8.3000802@linux.vnet.ibm.com>
Date: Wed, 01 Oct 2008 11:29:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 9/12] memcg allocate all page_cgroup at boot
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com> <20080925153206.281243dc.kamezawa.hiroyu@jp.fujitsu.com> <48E2F6A9.9010607@linux.vnet.ibm.com> <20081001140748.637b9831.kamezawa.hiroyu@jp.fujitsu.com> <20081001143242.1b44de24.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081001143242.1b44de24.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 1 Oct 2008 14:07:48 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>> Can we make this patch indepedent of the flags changes and push it in ASAP.
>>>
>> Need much work....Hmm..rewrite all again ? 
>>
> 
> BTW, do you have good idea to modify flag bit without affecting LOCK bit on
> page_cgroup->flags ?
> 
> At least, we'll have to set ACTIVE/INACTIVE/UNEVICTABLE flags dynamically.
> take lock_page_cgroup() always ?

In the past patches, I've used lock_page_cgroup(). In some cases like
initialization at boot time, I've ignored taking the lock, since I know no-one
is accessing them yet.

> __mem_cgroup_move_lists() will have some amount of changes. And we should
> check dead lock again.

__mem_cgroup_move_lists() is called from mem_cgroup_isolate_pages() and
mem_cgroup_move_lists(). In mem_cgroup_move_lists(), we have the page_cgroup
lock. I think the current code works on the assumption (although not documented
anywhere I've seen), that PAGE_CGROUP_FLAG_INACTIVE/ACTIVE/UNEVICTABLE bits are
protected by lru_lock. Please look at

__mem_cgroup_remove_list
__mem_cgroup_add_list
__mem_cgroup_move_lists
__mem_cgroup_charge_common (sets this flag, before the pc is associated with the
page).

Am I missing something (today is holiday here, so I am in a bit of a lazy/sleepy
mood :) )

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
