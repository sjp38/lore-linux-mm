Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAD1KxBH022171
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 12:20:59 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAD1KjTA292748
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 12:20:45 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAD1Kjuq003454
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 12:20:45 +1100
Message-ID: <491B80E8.4090107@linux.vnet.ibm.com>
Date: Thu, 13 Nov 2008 06:50:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/6] memcg: free all at rmdir
References: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com> <20081112122656.c6e56248.kamezawa.hiroyu@jp.fujitsu.com> <20081112160758.3dca0b22.akpm@linux-foundation.org> <20081113101344.6882c209.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081113101344.6882c209.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, menage@google.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 12 Nov 2008 16:07:58 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
>> On Wed, 12 Nov 2008 12:26:56 +0900
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>>> +5.1 on_rmdir
>>> +set behavior of memcg at rmdir (Removing cgroup) default is "drop".
>>> +
>>> +5.1.1 drop
>>> +       #echo on_rmdir drop > memory.attribute
>>> +       This is default. All pages on the memcg will be freed.
>>> +       If pages are locked or too busy, they will be moved up to the parent.
>>> +       Useful when you want to drop (large) page caches used in this memcg.
>>> +       But some of in-use page cache can be dropped by this.
>>> +
>>> +5.1.2 keep
>>> +       #echo on_rmdir keep > memory.attribute
>>> +       All pages on the memcg will be moved to its parent.
>>> +       Useful when you don't want to drop page caches used in this memcg.
>>> +       You can keep page caches from some library or DB accessed by this
>>> +       memcg on memory.
>> Would it not be more useful to implement a per-memcg version of
>> /proc/sys/vm/drop_caches?  (One without drop_caches' locking bug,
>> hopefully).
>>
>> If we do this then we can make the above "keep" behaviour non-optional,
>> and the operator gets to choose whether or not to drop the caches
>> before doing the rmdir.
>>
>> Plus, we get a new per-memcg drop_caches capability.  And it's a nicer
>> interface, and it doesn't have the obvious races which on_rmdir has,
>> etc.
>>
>> hm?
>>
> In my plan, I'll add
> 
> memory.shrink_usage interface to do and allows
> 
> #echo 0M > memory.shrink_memory_usage
> (you may swap tasks out if there is task..)
> 
> to drop pages.
> 

So, shrink_memory_usage is just for dropping caches? I don't understand the part
about swap tasks out.

> Balbir, how do you think ? I've already removed "force_empty".

Have you? Won't that go against API/ABI compatibility guidelines. I would
recommend cc'ing linux-api as well. Sorry, I missed the patch that removes
force_empty. Me culpa.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
