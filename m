Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C53FC6B0069
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 22:16:03 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 5so858075753pgi.2
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 19:16:03 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f10si22334355plm.125.2016.12.27.19.16.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 19:16:02 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v4 0/9] mm/swap: Regular page swap optimizations
References: <cover.1481317367.git.tim.c.chen@linux.intel.com>
	<20161227074503.GA10616@bbox> <87d1gc4y3w.fsf@yhuang-dev.intel.com>
	<20161228023739.GA12634@bbox>
Date: Wed, 28 Dec 2016 11:15:57 +0800
In-Reply-To: <20161228023739.GA12634@bbox> (Minchan Kim's message of "Wed, 28
	Dec 2016 11:37:39 +0900")
Message-ID: <8760m43frm.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, jack@suse.cz

Minchan Kim <minchan@kernel.org> writes:

> Hi Huang,
>
> On Wed, Dec 28, 2016 at 09:54:27AM +0800, Huang, Ying wrote:
>
> < snip >
>
>> > The patchset has used several techniqueus to reduce lock contention, for example,
>> > batching alloc/free, fine-grained lock and cluster distribution to avoid cache
>> > false-sharing. Each items has different complexity and benefits so could you
>> > show the number for each step of pathchset? It would be better to include the
>> > nubmer in each description. It helps how the patch is important when we consider
>> > complexitiy of the patch.
>> 
>> One common problem of scalability optimization is that, after you have
>> optimized one lock, the end result may be not very good, because another
>> lock becomes heavily contended.  Similar problem occurs here, there are
>> mainly two locks during swap out/in, one protects swap cache, the other
>> protects swap device.  We can achieve good scalability only after having
>> optimized the two locks.
>
> Yes. You can describe that situation into the description. For example,
> "with this patch, we can watch less swap_lock contention with perf but
> overall performance is not good because swap cache lock still is still
> contended heavily like below data so next patch will solve the problem".
>
> It will make patch's justficiation clear.
>
>> 
>> You cannot say that one patch is not important just because the test
>> result for that single patch is not very good.  Because without that,
>> the end result of the whole series will be not very good.
>
> I know that but this patchset are lack of number too much to justify
> each works. You can show just raw number itself of a techniqueue
> although it is not huge benefit or even worse. You can explain the reason
> why it was not good, which would be enough motivation for next patch.
>
> Number itself wouldn't be important but justfication is really crucial
> to review/merge patchset and number will help it a lot in especially
> MM community.
>
>> 
>> >> 
>> >> Patch 1 is a clean up patch.
>> >
>> > Could it be separated patch?
>> >
>> >> Patch 2 creates a lock per cluster, this gives us a more fine graind lock
>> >>         that can be used for accessing swap_map, and not lock the whole
>> >>         swap device
>> >
>> > I hope you make three steps to review easier. You can create some functions like
>> > swap_map_lock and cluster_lock which are wrapper functions just hold swap_lock.
>> > It doesn't change anything performance pov but it clearly shows what kinds of lock
>> > we should use in specific context.
>> >
>> > Then, you can introduce more fine-graind lock in next patch and apply it into
>> > those wrapper functions.
>> >
>> > And last patch, you can adjust cluster distribution to avoid false-sharing.
>> > And the description should include how it's bad in testing so it's worth.
>> >
>> > Frankly speaking, although I'm huge user of bit_spin_lock(zram/zsmalloc
>> > have used it heavily), I don't like swap subsystem uses it.
>> > During zram development, it really hurts debugging due to losing lockdep.
>> > The reason zram have used it is by size concern of embedded world but server
>> > would be not critical so please consider trade-off of spinlock vs. bit_spin_lock.
>> 
>> There will be one struct swap_cluster_info for every 1MB swap space.
>> So, for example, for 1TB swap space, the number of struct
>> swap_cluster_info will be one million.  To reduce the RAM usage, we
>> choose to use bit_spin_lock, otherwise, spinlock is better.  The code
>> will be used by embedded, PC and server, so the RAM usage is important.
>
> It seems you already increase swap_cluster_info 4 byte to support
> bit_spin_lock.

The increment only occurs on 64bit platform.  On 32bit platform, the
size is the same as before.

> Compared to that, how much memory does spin_lock increase?

The size of struct swap_cluster_info will increase from 4 bytes to 16
bytes on 64bit platform.  I guess it will increase from 4 bytes to 8
bytes on 32bit platform at least, but I did not test that.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
