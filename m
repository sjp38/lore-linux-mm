Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 1758D6B0044
	for <linux-mm@kvack.org>; Mon,  7 May 2012 15:19:54 -0400 (EDT)
Received: by yenm8 with SMTP id m8so6356972yen.14
        for <linux-mm@kvack.org>; Mon, 07 May 2012 12:19:53 -0700 (PDT)
Message-ID: <4FA82056.2070706@gmail.com>
Date: Mon, 07 May 2012 15:19:50 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
References: <20120501132409.GA22894@lizard> <20120501132620.GC24226@lizard> <4FA35A85.4070804@kernel.org> <20120504073810.GA25175@lizard> <CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com> <CAHGf_=qcGfuG1g15SdE0SDxiuhCyVN025pQB+sQNuNba4Q4jcA@mail.gmail.com> <20120507121527.GA19526@lizard>
In-Reply-To: <20120507121527.GA19526@lizard>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Pekka Enberg <penberg@kernel.org>, Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

(5/7/12 8:15 AM), Anton Vorontsov wrote:
> On Mon, May 07, 2012 at 04:26:00AM -0400, KOSAKI Motohiro wrote:
>>>> If we'll give up on "1." (Pekka, ping), then we need to solve "2."
>>>> in a sane way: we'll have to add a 'NR_FILE_PAGES - NR_SHMEM -
>>>> <todo-locked-file-pages>' attribute, and give it a name.
>>>
>>> Well, no, we can't give up on (1) completely. That'd mean that
>>> eventually we'd need to change the ABI and break userspace. The
>>> difference between exposing internal details and reasonable
>>> abstractions is by no means black and white.
>>>
>>> AFAICT, RECLAIMABLE_CACHE_PAGES is a reasonable thing to support. Can
>>> anyone come up with a reason why we couldn't do that in the future?
>>
>> It can. but the problem is, that is completely useless.
>
> Surely it is useful. Could be not ideal, but you can't say that
> it is completely useless.

Why? It doesn't work.



>> Because of, 1) dirty pages writing-out is sometimes very slow and
>
> I don't see it as a unresolvable problem: we can exclude dirty pages,
> that's a nice idea actually.
>
> Easily reclaimable cache pages = file_pages - shmem - locked pages
> - dirty pages.
>
> The amount of dirty pages is configurable, which is also great.

You don't understand the issue. The point is NOT a formula. The problem
is, dirty and non-dirty pages aren't isolated in our kernel. Then, kernel
start to get stuck  far before non-dirty pages become empty. Lie notification
always useless.


> Even more, we may introduce two attributes:
>
> RECLAIMABLE_CACHE_PAGES and
> RECLAIMABLE_CACHE_PAGES_NOIO (which excludes dirty pages).
>
> This makes ABI detached from the mm internals and still keeps a
> defined meaning of the attributes.

Collection of craps are also crap. If you want to improve userland
notification, you should join VM improvement activity. You shouldn't
think nobody except you haven't think userland notification feature.

The problem is, Any current kernel vm statistics were not created for
such purpose and don't fit.

Even though, some inaccurate and incorrect statistics fit _your_ usecase,
they definitely don't fit other. And their people think it is bug.


>> 2) libc and some important library's pages are critical important
>> for running a system even though it is clean and reclaimable. In other
>> word, kernel don't have an info then can't expose it.
>
> First off, I guess LRU would try to keep important/most used pages in
> the cache, as we try to never fully drain page cache to the zero mark.

Yes, what do you want say?


> Secondly, if we're really low on memory (which low memory notifications
> help to prevent) and kernel decided to throw libc's pages out of the
> cache, you'll get cache miss and kernel will have to read it back. Well,
> sometimes cache misses do happen, that's life. And if somebody really
> don't want this for the essential parts of the system, one have to
> mlock it (which eliminates your "kernel don't have an info" argument).

First off, "low memory" is very poor definition and we must not use it.
It is multiple meanings. 1) System free memory is low. Some embedded have userland
oom killer and they want to know _system_ status. 2) available memory is low.
This is different from (1) when using NUMA, memcg or cpusets. And in nowadays,
almost all x86 box have numa. This is userful for swap avoidance activity if
we can implement correctly.

Secondly, we can't assume someone mlock to libc. Because of, Linux is generic
purpose kernel. As far as you continue to talk about only user usecase, we can't
agree you. "Users may have a workaround" don't make excuse to accept broken patch.




> Btw, if you have any better strategy on helping userspace to define
> 'low memory' conditions, I'll readily try to implement it.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
