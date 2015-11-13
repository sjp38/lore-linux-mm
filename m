Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 65C516B026D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 14:46:28 -0500 (EST)
Received: by obbww6 with SMTP id ww6so81806369obb.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 11:46:28 -0800 (PST)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id q4si13113023oia.7.2015.11.13.11.46.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 11:46:27 -0800 (PST)
Received: by oies6 with SMTP id s6so55966169oie.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 11:46:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56459B9A.7080501@gmail.com>
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
 <1447302793-5376-2-git-send-email-minchan@kernel.org> <CALCETrWA6aZC_3LPM3niN+2HFjGEm_65m9hiEdpBtEZMn0JhwQ@mail.gmail.com>
 <564421DA.9060809@gmail.com> <20151113061511.GB5235@bbox> <56458056.8020105@gmail.com>
 <20151113063802.GF5235@bbox> <56458720.4010400@gmail.com> <20151113070356.GG5235@bbox>
 <56459B9A.7080501@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 13 Nov 2015 11:46:07 -0800
Message-ID: <CALCETrVx0JFchtJrrKVqEYvTwWvC+DwSLxzhD_A7EdNu2PiG7w@mail.gmail.com>
Subject: Re: [PATCH v3 01/17] mm: support madvise(MADV_FREE)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin wang <yalin.wang2010@gmail.com>

On Fri, Nov 13, 2015 at 12:13 AM, Daniel Micay <danielmicay@gmail.com> wrote:
> On 13/11/15 02:03 AM, Minchan Kim wrote:
>> On Fri, Nov 13, 2015 at 01:45:52AM -0500, Daniel Micay wrote:
>>>> And now I am thinking if we use access bit, we could implment MADV_FREE_UNDO
>>>> easily when we need it. Maybe, that's what you want. Right?
>>>
>>> Yes, but why the access bit instead of the dirty bit for that? It could
>>> always be made more strict (i.e. access bit) in the future, while going
>>> the other way won't be possible. So I think the dirty bit is really the
>>> more conservative choice since if it turns out to be a mistake it can be
>>> fixed without a backwards incompatible change.
>>
>> Absolutely true. That's why I insist on dirty bit until now although
>> I didn't tell the reason. But I thought you wanted to change for using
>> access bit for the future, too. It seems MADV_FREE start to bloat
>> over and over again before knowing real problems and usecases.
>> It's almost same situation with volatile ranges so I really want to
>> stop at proper point which maintainer should decide, I hope.
>> Without it, we will make the feature a lot heavy by just brain storming
>> and then causes lots of churn in MM code without real bebenfit
>> It would be very painful for us.
>
> Well, I don't think you need more than a good API and an implementation
> with no known bugs, kernel security concerns or backwards compatibility
> issues. Configuration and API extensions are something for later (i.e.
> land a baseline, then submit stuff like sysctl tunables). Just my take
> on it though...
>

As long as it's anonymous MAP_PRIVATE only, then the security aspects
should be okay.  MADV_DONTNEED seems to work on pretty much any VMA,
and there's been long history of interesting bugs there.

As for dirty vs accessed, an argument in favor of going straight to
accessed is that it means that users can write code like this without
worrying about whether they have a kernel that uses the dirty bit:

x = mmap(...);
*x = 1;  /* mark it present */

/* i'm done with it */
*x = 1;
madvise(MADV_FREE, x, ...);

wait a while;

/* is it still there? */
if (*x == 1) {
  /* use whatever was cached there */
} else {
 /* reinitialize it */
 *x = 1;
}

With the dirty bit, this will look like it works, but on occasion
users will lose the race where they probe *x to see if the data was
lost and then the data gets lost before the next write comes in.

Sure, that load from *x could be changed to RMW or users could do a
dummy write (e.g. x[1] = 1; if (*x == 1) ...), but people might forget
to do that, and the caching implications are a little bit worse.

Note that switching to RMW is really really dangerous.  Doing:

*x &= 1;
if (*x == 1) ...;

is safe on x86 if the compiler generates:

andl $1, (%[x]);
cmpl $1, (%[x]);

but is unsafe if the compiler generates:

movl (%[x]), %eax;
andl $1, %eax;
movl %eax, (%[x]);
cmpl $1, %eax;

and even worse if the write is omitted when "provably" unnecessary.

OTOH, if switching to the accessed bit is too much of a mess, then
using the dirty bit at first isn't so bad.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
