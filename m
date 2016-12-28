Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1CFC76B0069
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 23:56:29 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 5so862906687pgi.2
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 20:56:29 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id r85si48625848pfr.254.2016.12.27.20.56.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 20:56:28 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v4 0/9] mm/swap: Regular page swap optimizations
References: <cover.1481317367.git.tim.c.chen@linux.intel.com>
	<20161227074503.GA10616@bbox> <87d1gc4y3w.fsf@yhuang-dev.intel.com>
	<20161228023739.GA12634@bbox> <8760m43frm.fsf@yhuang-dev.intel.com>
	<871sws3f2d.fsf@yhuang-dev.intel.com> <20161228035330.GA12769@bbox>
Date: Wed, 28 Dec 2016 12:56:23 +0800
In-Reply-To: <20161228035330.GA12769@bbox> (Minchan Kim's message of "Wed, 28
	Dec 2016 12:53:30 +0900")
Message-ID: <87wpek1wjs.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, jack@suse.cz

Minchan Kim <minchan@kernel.org> writes:

> On Wed, Dec 28, 2016 at 11:31:06AM +0800, Huang, Ying wrote:
>
> < snip >
>
>> >>> > Frankly speaking, although I'm huge user of bit_spin_lock(zram/zsmalloc
>> >>> > have used it heavily), I don't like swap subsystem uses it.
>> >>> > During zram development, it really hurts debugging due to losing lockdep.
>> >>> > The reason zram have used it is by size concern of embedded world but server
>> >>> > would be not critical so please consider trade-off of spinlock vs. bit_spin_lock.
>> >>> 
>> >>> There will be one struct swap_cluster_info for every 1MB swap space.
>> >>> So, for example, for 1TB swap space, the number of struct
>> >>> swap_cluster_info will be one million.  To reduce the RAM usage, we
>> >>> choose to use bit_spin_lock, otherwise, spinlock is better.  The code
>> >>> will be used by embedded, PC and server, so the RAM usage is important.
>> >>
>> >> It seems you already increase swap_cluster_info 4 byte to support
>> >> bit_spin_lock.
>> >
>> > The increment only occurs on 64bit platform.  On 32bit platform, the
>> > size is the same as before.
>> >
>> >> Compared to that, how much memory does spin_lock increase?
>> >
>> > The size of struct swap_cluster_info will increase from 4 bytes to 16
>> > bytes on 64bit platform.  I guess it will increase from 4 bytes to 8
>> > bytes on 32bit platform at least, but I did not test that.
>> 
>> Sorry, I make a mistake during test.  The size of struct
>> swap_cluster_info will increase from 4 bytes to 8 bytes on 64 bit
>> platform.  I think it will increase from 4 bytes to 8 bytes on 32 bit
>> platform too (not tested).
>
> Thanks for the information.
> To me, it's not big when we consider spinlock's usefullness which helps
> cache-line bouncing, lockdep and happy with RT people.

Yes.  spinlock helps on lockdep and RT, but I don't think it helps
cache-line bouncing.

> So, I vote spin_lock but I'm not in charge of deciding on that and your
> opinion might be different still. If so, let's pass the decision to
> maintainer.

I have no strong opinion for size change on 32bit platform.  But I want
to know other people's opinion, especially maintainer's too.

> Instead, please write down above content in description for maintainer to
> judge it fairly.

Sure.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
