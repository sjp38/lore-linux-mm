Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 65E566B005D
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 16:05:09 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so3029677qcs.14
        for <linux-mm@kvack.org>; Mon, 04 Jun 2012 13:05:08 -0700 (PDT)
Message-ID: <4FCD14F1.1030105@gmail.com>
Date: Mon, 04 Jun 2012 16:05:05 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Some vmevent fixes...
References: <20120507121527.GA19526@lizard> <4FA82056.2070706@gmail.com> <CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com> <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com> <CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com> <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com> <CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com> <20120601122118.GA6128@lizard> <alpine.LFD.2.02.1206032125320.1943@tux.localdomain> <4FCC7592.9030403@kernel.org> <20120604113811.GA4291@lizard>
In-Reply-To: <20120604113811.GA4291@lizard>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <cbouatmailru@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

>> Anton, I expect you already investigated android low memory killer so maybe you know pros and cons of each solution.
>> Could you convince us "why we need vmevent" and "why can't android LMK do it?"
>
> Note that 1) and 2) are not problems per se, it's just implementation
> details, easy stuff. Vmevent is basically an ABI/API, and I didn't
> hear anybody who would object to vmevent ABI idea itself. More than
> this, nobody stop us from implementing in-kernel vmevent API, and
> make Android Lowmemory killer use it, if we want to.

I never agree "it's mere ABI" discussion. Until the implementation is ugly,
I never agree the ABI even if syscall interface is very clean.


> The real problem is not with vmevent. Today there are two real problems:
>
> a) Gathering proper statistics from the kernel. Both cgroups and vmstat
>     have issues. Android lowmemory killer has the same problems w/ the
>     statistics as vmevent, it uses vmstat, so by no means Android
>     low memory killer is better or easier in this regard.
>     (And cgroups has issues w/ slab accounting, plus some folks don't
>     want memcg at all, since it has runtime and memory-wise costs.)

Right. android lowmemory killer is also buggy.


> b) Interpreting this statistics. We can't provide one, universal
>     "low memory" definition that would work for everybody.
>     (Btw, your "levels" based low memory grading actually sounds
>     the same as mine RECLAIMABLE_CACHE_PAGES and
>     RECLAIMABLE_CACHE_PAGES_NOIO idea, i.e.
>     http://lkml.indiana.edu/hypermail/linux/kernel/1205.0/02751.html
>     so personally I like the idea of level-based approach, based
>     on available memory *cost*.)
>
> So, you see, all these issues are valid for vmevent, cgroups and
> android low memory killer.
>
>> KOSAKI, AFAIRC, you are a person who hates android low memory killer.
>> Why do you hate it? If it solve problems I mentioned, do you have a concern, still?
>> If so, please, list up.
>>
>> Android low memory killer is proved solution for a long time, at least embedded area(So many android phone already have used it) so I think improving it makes sense to me rather than inventing new wheel.
>
> Yes, nobody throws Android lowmemory killer away. And recently I fixed
> a bunch of issues in its tasks traversing and killing code. Now it's
> just time to "fix" statistics gathering and interpretation issues,
> and I see vmevent as a good way to do just that, and then we
> can either turn Android lowmemory killer driver to use the vmevent
> in-kernel API (so it will become just a "glue" between notifications
> and killing functions), or use userland daemon.

Huh? No? android lowmem killer is a "killer". it doesn't make any notification,
it only kill memory hogging process. I don't think we can merge them.



> Note that memcg has notifications as well, so it's another proof that
> there is a demand for this stuff outside of embedded world, and going
> with ad-hoc, custom "low memory killer" is simple and tempting approach,
> but it doesn't solve any real problems.

Wrong.
memcg notification notify the event to _another_ mem cgroup's process. Then, it can
avoid a notified process can't work well by swap thrashing. Its feature only share a
weakness of vmevent api.



>> Frankly speaking, I don't know vmevent's other use cases except low memory notification
>
> I won't speak for realistic use-cases, but that is what comes to
> mind:
>
> - DB can grow its caches/in-memory indexes infinitely, and start dropping
>    them on demand (based on internal LRU list, for example). No more
>    guessed/static configuration for DB daemons?

They uses direct-io for fine grained cache control.


> - Assuming VPS hosting w/ dynamic resources management, notifications
>    would be useful to readjust resources?

How do they readjust? Now kvm/xen use balloon driver for dynamic resource
adjustment. AND it work more fine than vmevent because it doesn't route
userspace.


> - On desktops, apps can drop their caches on demand if they want to
>    and can avoid swap activity?

In this case, fallocate(VOLATILE) is work more better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
