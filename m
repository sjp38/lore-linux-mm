Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 247C96B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 01:25:42 -0400 (EDT)
Received: by obbgg8 with SMTP id gg8so139618095obb.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 22:25:42 -0700 (PDT)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id bt11si1658204obd.98.2015.03.23.22.25.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 22:25:41 -0700 (PDT)
Received: by obdfc2 with SMTP id fc2so139714172obd.3
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 22:25:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150323051731.GA2616341@devbig257.prn2.facebook.com>
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>
	<20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>
	<550A5FF8.90504@gmail.com>
	<CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com>
	<20150323051731.GA2616341@devbig257.prn2.facebook.com>
Date: Mon, 23 Mar 2015 22:25:41 -0700
Message-ID: <CADpJO7zk8J3q7Bw9NibV9CzLarO+YkfeshyFTTq=XeS5qziBiA@mail.gmail.com>
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
From: Aliaksey Kandratsenka <alkondratenko@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: Daniel Micay <danielmicay@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

Hi.

On Sun, Mar 22, 2015 at 10:17 PM, Shaohua Li <shli@fb.com> wrote:
> On Sat, Mar 21, 2015 at 11:06:14PM -0700, Aliaksey Kandratsenka wrote:

>> But now I realize that it is more interesting than that. I.e. because as
>> Daniel
>> pointed out, mremap holds mmap_sem exclusively, while page faults are
>> holding it
>> for read. That could be optimized of course. Either by separate "teleport
>> ptes"
>> syscall (again, as noted by Daniel), or by having mremap drop mmap_sem for
>> write
>> and retaking it for read for "moving pages" part of work. Being not really
>> familiar with kernel code I have no idea if that's doable or not. But it
>> looks
>> like it might be quite important.
>
> Does mmap_sem contend in your workload? Otherwise, there is no big
> difference of read or write lock. memcpy to new allocation could trigger
> page fault, new page allocation overhead and etc.

Well, I don't have any workloads. I'm just maintaining a library that
others run various workloads on. Part of the problem is lack of good
and varied malloc benchmarks which could allow us that prevent
regression. So this makes me a bit more cautious on performance
matters.

But I see your point. Indeed I have no evidence at all that exclusive
locking might cause observable performance difference.

>> b) is that optimization worth having at all ?
>>
>> After all, memcpy is actually known to be fast. I understand that copying
>> memory
>> in user space can be slowed down by minor page faults (results below seem to
>> confirm that). But this is something where either allocator may retain
>> populated
>> pages a bit longer or where kernel could help. E.g. maybe by exposing
>> something
>> similar to MAP_POPULATE in madvise, or even doing some safe combination of
>> madvise and MAP_UNINITIALIZED.
>
> This option will make allocator use more memory than expected.
> Eventually the memory must be reclaimed, which has big overhead too.
>
>> I've played with Daniel's original benchmark (copied from
>> http://marc.info/?l=linux-mm&m=141230769431688&w=2) with some tiny
>> modifications:
>>

...

>> Another notable thing is how mlock effectively disables MADV_DONTNEED for
>> jemalloc{1,2} and tcmalloc, lowers page faults count and thus improves
>> runtime. It can be seen that tcmalloc+mlock on thp-less configuration is
>> slightly better on runtime to glibc. The later spends a ton of time in
>> kernel,
>> probably handling minor page faults, and the former burns cpu in user space
>> doing memcpy-s. So "tons of memcpys" seems to be competitive to what glibc
>> is
>> doing in this benchmark.
>
> mlock disables MADV_DONTNEED, so this is an unfair comparsion. With it,
> allocator will use more memory than expected.

Do not agree with unfair. I'm actually hoping MADV_FREE to provide
most if not all of benefits of mlock in this benchmark. I believe it's
not too unreasonable expectation.

>
> I'm kind of confused why we talk about THP, mlock here. When application
> uses allocator, it doesn't need to be forced to use THP or mlock. Can we
> forcus on normal case?

See my note on mlock above.

THP it is actually "normal". I know for certain, that many production
workloads are run on boxes with THP enabled. Red Hat famously ships
it's distros with THP set to "always". And I also know that some other
many production workloads are run on boxes with THP disabled. Also, as
seen above, "teleporting" pages is more efficient with THP due to much
smaller overhead of moving those pages. So I felt it was important not
to omit THP in my runs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
