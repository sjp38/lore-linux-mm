Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC8D280274
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 23:25:43 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fi2so88289463pad.3
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 20:25:43 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i70si22736204pfk.182.2016.09.25.20.25.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 25 Sep 2016 20:25:42 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping out
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	<20160922225608.GA3898@kernel.org>
	<1474591086.17726.1.camel@redhat.com>
	<87d1jvuz08.fsf@yhuang-dev.intel.com>
	<20160925191849.GA83300@kernel.org>
Date: Mon, 26 Sep 2016 11:25:27 +0800
In-Reply-To: <20160925191849.GA83300@kernel.org> (Shaohua Li's message of
	"Sun, 25 Sep 2016 12:18:49 -0700")
Message-ID: <877f9zs5p4.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Shaohua Li <shli@kernel.org> writes:

> On Fri, Sep 23, 2016 at 10:32:39AM +0800, Huang, Ying wrote:
>> Rik van Riel <riel@redhat.com> writes:
>>=20
>> > On Thu, 2016-09-22 at 15:56 -0700, Shaohua Li wrote:
>> >> On Wed, Sep 07, 2016 at 09:45:59AM -0700, Huang, Ying wrote:
>> >> >.
>> >> > - It will help the memory fragmentation, especially when the THP is
>> >> > . heavily used by the applications..=A0The 2M continuous pages will
>> >> > be
>> >> > . free up after THP swapping out.
>> >>=20
>> >> So this is impossible without THP swapin. While 2M swapout makes a
>> >> lot of
>> >> sense, I doubt 2M swapin is really useful. What kind of application
>> >> is
>> >> 'optimized' to do sequential memory access?
>> >
>> > I suspect a lot of this will depend on the ratio of storage
>> > speed to CPU & RAM speed.
>> >
>> > When swapping to a spinning disk, it makes sense to avoid
>> > extra memory use on swapin, and work in 4kB blocks.
>>=20
>> For spinning disk, the THP swap optimization will be turned off in
>> current implementation.  Because huge swap cluster allocation based on
>> swap cluster management, which is available only for non-rotating block
>> devices (blk_queue_nonrot()).
>
> For 2m swapin, as long as one byte is changed in the 2m, next time we mus=
t do
> 2m swapout. There is huge waste of memory and IO bandwidth and increases
> unnecessary memory pressure. 2M IO will very easily saturate a very fast =
SSD
> and makes IO the bottleneck. Not sure about NVRAM though.

One solution is to make 2M swapin configurable, maybe via a sysfs file
in /sys/kernel/mm/transparent_hugepage/, so that we can turn on it only
for really fast storage devices, such as NVRAM, etc.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
