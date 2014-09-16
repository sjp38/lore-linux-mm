Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id AB3F46B0038
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 21:36:15 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id fp1so7468868pdb.29
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 18:36:15 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id o2si25867166pdf.1.2014.09.15.18.36.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 18:36:14 -0700 (PDT)
Received: from kw-mxauth.gw.nic.fujitsu.com (unknown [10.0.237.134])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A6F5F3EE0C3
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 10:36:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id B3AF3AC01D8
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 10:36:10 +0900 (JST)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 502A5E08002
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 10:36:10 +0900 (JST)
Message-ID: <541793BF.7070106@jp.fujitsu.com>
Date: Tue, 16 Sep 2014 10:34:55 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] memory cgroup: my thoughts on memsw
References: <20140904143055.GA20099@esperanza> <20140915191435.GA8950@cmpxchg.org>
In-Reply-To: <20140915191435.GA8950@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, LKML-MM <linux-mm@kvack.org>, LKML-cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

(2014/09/16 4:14), Johannes Weiner wrote:
> Hi Vladimir,
>
> On Thu, Sep 04, 2014 at 06:30:55PM +0400, Vladimir Davydov wrote:
>> To sum it up, the current mem + memsw configuration scheme doesn't allow
>> us to limit swap usage if we want to partition the system dynamically
>> using soft limits. Actually, it also looks rather confusing to me. We
>> have mem limit and mem+swap limit. I bet that from the first glance, an
>> average admin will think it's possible to limit swap usage by setting
>> the limits so that the difference between memory.memsw.limit and
>> memory.limit equals the maximal swap usage, but (surprise!) it isn't
>> really so. It holds if there's no global memory pressure, but otherwise
>> swap usage is only limited by memory.memsw.limit! IMHO, it isn't
>> something obvious.
>
> Agreed, memory+swap accounting & limiting is broken.
>
>>   - Anon memory is handled by the user application, while file caches are
>>     all on the kernel. That means the application will *definitely* die
>>     w/o anon memory. W/o file caches it usually can survive, but the more
>>     caches it has the better it feels.
>>
>>   - Anon memory is not that easy to reclaim. Swap out is a really slow
>>     process, because data are usually read/written w/o any specific
>>     order. Dropping file caches is much easier. Typically we have lots of
>>     clean pages there.
>>
>>   - Swap space is limited. And today, it's OK to have TBs of RAM and only
>>     several GBs of swap. Customers simply don't want to waste their disk
>>     space on that.
>
>> Finally, my understanding (may be crazy!) how the things should be
>> configured. Just like now, there should be mem_cgroup->res accounting
>> and limiting total user memory (cache+anon) usage for processes inside
>> cgroups. This is where there's nothing to do. However, mem_cgroup->memsw
>> should be reworked to account *only* memory that may be swapped out plus
>> memory that has been swapped out (i.e. swap usage).
>
> But anon pages are not a resource, they are a swap space liability.
> Think of virtual memory vs. physical pages - the use of one does not
> necessarily result in the use of the other.  Without memory pressure,
> anonymous pages do not consume swap space.
>
> What we *should* be accounting and limiting here is the actual finite
> resource: swap space.  Whenever we try to swap a page, its owner
> should be charged for the swap space - or the swapout be rejected.
>
> For hard limit reclaim, the semantics of a swap space limit would be
> fairly obvious, because it's clear who the offender is.
>
> However, in an overcommitted machine, the amount of swap space used by
> a particular group depends just as much on the behavior of the other
> groups in the system, so the per-group swap limit should be enforced
> even during global reclaim to feed back pressure on whoever is causing
> the swapout.  If reclaim fails, the global OOM killer triggers, which
> should then off the group with the biggest soft limit excess.
>
> As far as implementation goes, it should be doable to try-charge from
> add_to_swap() and keep the uncharging in swap_entry_free().
>
> We'll also have to extend the global OOM killer to be memcg-aware, but
> we've been meaning to do that anyway.
>

When we introduced memsw limitation, we tried to avoid affecting global memory reclaim.
Then, we did memory+swap limitation.

Now, global memory reclaim is memcg-aware. So, I think swap-limitation rather than
anon+swap may be a choice. The change will reduce res_counter access. Hmm, it will be
desireble to move anon pages to Unevictable if memcg's swap slot is 0.

Anyway, I think softlimit should be re-implemented, 1st. It will be starting point.

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
