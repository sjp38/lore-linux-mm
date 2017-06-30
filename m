Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2892802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 11:54:36 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e199so118694264pfh.7
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 08:54:36 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0101.outbound.protection.outlook.com. [104.47.2.101])
        by mx.google.com with ESMTPS id g13si6530348plm.355.2017.06.30.08.54.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 08:54:34 -0700 (PDT)
Subject: Re: [PATCH] mm/memory-hotplug: Switch locking to a percpu rwsem
References: <alpine.DEB.2.20.1706291803380.1861@nanos>
 <20170630092747.GD22917@dhcp22.suse.cz>
 <alpine.DEB.2.20.1706301210210.1748@nanos>
 <3f2395c6-bbe0-23c1-fe06-d17ffbf619c3@virtuozzo.com>
 <alpine.DEB.2.20.1706301418190.1748@nanos>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <fc6676da-dc20-a80c-82b3-ae479af3e6ad@virtuozzo.com>
Date: Fri, 30 Jun 2017 18:56:44 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1706301418190.1748@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On 06/30/2017 04:00 PM, Thomas Gleixner wrote:
> On Fri, 30 Jun 2017, Andrey Ryabinin wrote:
>> On 06/30/2017 01:15 PM, Thomas Gleixner wrote:
>>> On Fri, 30 Jun 2017, Michal Hocko wrote:
>>>> So I like this simplification a lot! Even if we can get rid of the
>>>> stop_machine eventually this patch would be an improvement. A short
>>>> comment on why the per-cpu semaphore over the regular one is better
>>>> would be nice.
>>>
>>> Yes, will add one.
>>>
>>> The main point is that the current locking construct is evading lockdep due
>>> to the ability to support recursive locking, which I did not observe so
>>> far.
>>>
>>
>> Like this?
> 
> Cute.....
> 
>> [  131.023034] Call Trace:
>> [  131.023034]  dump_stack+0x85/0xc7
>> [  131.023034]  __lock_acquire+0x1747/0x17a0
>> [  131.023034]  ? lru_add_drain_all+0x3d/0x190
>> [  131.023034]  ? __mutex_lock+0x218/0x940
>> [  131.023034]  ? trace_hardirqs_on+0xd/0x10
>> [  131.023034]  lock_acquire+0x103/0x200
>> [  131.023034]  ? lock_acquire+0x103/0x200
>> [  131.023034]  ? lru_add_drain_all+0x42/0x190
>> [  131.023034]  cpus_read_lock+0x3d/0x80
>> [  131.023034]  ? lru_add_drain_all+0x42/0x190
>> [  131.023034]  lru_add_drain_all+0x42/0x190
>> [  131.023034]  __offline_pages.constprop.25+0x5de/0x870
>> [  131.023034]  offline_pages+0xc/0x10
>> [  131.023034]  memory_subsys_offline+0x43/0x70
>> [  131.023034]  device_offline+0x83/0xb0
>> [  131.023034]  store_mem_state+0xdb/0xe0
>> [  131.023034]  dev_attr_store+0x13/0x20
>> [  131.023034]  sysfs_kf_write+0x40/0x50
>> [  131.023034]  kernfs_fop_write+0x130/0x1b0
>> [  131.023034]  __vfs_write+0x23/0x130
>> [  131.023034]  ? rcu_read_lock_sched_held+0x6d/0x80
>> [  131.023034]  ? rcu_sync_lockdep_assert+0x2a/0x50
>> [  131.023034]  ? __sb_start_write+0xd4/0x1c0
>> [  131.023034]  ? vfs_write+0x1a8/0x1d0
>> [  131.023034]  vfs_write+0xc8/0x1d0
>> [  131.023034]  SyS_write+0x44/0xa0
> 
> Why didn't trigger that here? Bah, I should have become suspicious due to
> not seeing a splat ....
> 
> The patch below should cure that.
> 

FWIW, it works for me.

> Thanks,
> 
> 	tglx
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
