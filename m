Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB656B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 22:25:09 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id 77so75602623ioc.2
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 19:25:09 -0800 (PST)
Received: from mail-io0-x235.google.com (mail-io0-x235.google.com. [2607:f8b0:4001:c06::235])
        by mx.google.com with ESMTPS id iq7si1881765igb.92.2016.01.21.19.25.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 19:25:08 -0800 (PST)
Received: by mail-io0-x235.google.com with SMTP id 77so75602431ioc.2
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 19:25:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151209151326.f7efba4e5697e1b0f212ea34@linux-foundation.org>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
	<2564892.qO1q7YJ6Nb@wuerfel>
	<7343206.sFybcLLUN2@wuerfel>
	<20151209185858.GA2342@cmpxchg.org>
	<20151209142836.e81260567879110f319c01a4@linux-foundation.org>
	<20151209230505.GA16610@cmpxchg.org>
	<20151209151326.f7efba4e5697e1b0f212ea34@linux-foundation.org>
Date: Fri, 22 Jan 2016 12:25:08 +0900
Message-ID: <CALLJCT2wHo3jJb7emyG8bWR5=zC7aEo_05JfHsnKHhjgHArCcA@mail.gmail.com>
Subject: Re: [PATCH] mm: memcontrol: only manage socket pressure for CONFIG_INET
From: Masanari Iida <standby24x7@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, netdev@vger.kernel.org, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi,
I hit this while I was testing 4.5-rc1 with randconfig during merger period.
And now I noticed that it was fixed after Linus merged akpm branch.

commit eae21770b4fed5597623aad0d618190fa60426ff
Merge: e9f57eb 9f273c2
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Thu Jan 21 12:32:08 2016 -0800

    Merge branch 'akpm' (patches from Andrew)

Try one commit before this (commit e9f57ebcba563e0cd532926cab83c92bb4d79360 )
DOES have an issue.
So I believe it was fixed for now.
Thanks

Masanari


On Thu, Dec 10, 2015 at 8:13 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 9 Dec 2015 18:05:05 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
>
>> On Wed, Dec 09, 2015 at 02:28:36PM -0800, Andrew Morton wrote:
>> > On Wed, 9 Dec 2015 13:58:58 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
>> > > The calls to tcp_init_cgroup() appear earlier in the series than "mm:
>> > > memcontrol: hook up vmpressure to socket pressure". However, they get
>> > > moved around a few times so fixing it earlier means respinning the
>> > > series. Andrew, it's up to you whether we take the bisectability hit
>> > > for !CONFIG_INET && CONFIG_MEMCG (how common is this?) or whether you
>> > > want me to resend the series.
>> >
>> > hm, drat, I was suspecting dependency issues here, but a test build
>> > said it was OK.
>> >
>> > Actually, I was expecting this patch series to depend on the linux-next
>> > cgroup2 changes, but that doesn't appear to be the case.  *should* this
>> > series be staged after the cgroup2 code?
>>
>> Code-wise they are independent. My stuff is finishing up the new memcg
>> control knobs, the cgroup2 stuff is changing how and when those knobs
>> are exposed from within the cgroup core. I'm not relying on any recent
>> changes in the cgroup core AFAICS, so the order shouldn't matter here.
>
> OK, thanks.
>
>> > Regarding this particular series: yes, I think we can live with a
>> > bisection hole for !CONFIG_INET && CONFIG_MEMCG users.  But I'm not
>> > sure why we're discussing bisection issues, because Arnd's build
>> > failure occurs with everything applied?
>>
>> Arnd's patches apply to the top of the stack, but they address issues
>> introduced early in the series and the problematic code gets touched a
>> lot in subsequent patches. E.g. the first build breakage is in ("net:
>> tcp_memcontrol: simplify linkage between socket and page counter")
>> when the tcp_init_cgroup() and tcp_destroy_cgroup() function calls get
>> moved around and lose the CONFIG_INET protection.
>
> Yeah, this is a pain.  I think I'll fold Arnd's fix into
> mm-memcontrol-introduce-config_memcg_legacy_kmem.patch (which is staged
> after all the other MM patches and after linux-next) and will pretend I
> didn't know about the issue ;)
>
>> Anyway, if we can live with the bisection caveat then Arnd's fixes on
>> top of the kmem series look good to me. Depending on what Vladimir
>> thinks we might want to replace the CONFIG_SLOB fix with something
>> else later on, but that shouldn't be a problem, either.
>
> I don't have a fix for the CONFIG_SLOB&&CONFIG_MEMCG issue yet.  I
> agree that it would be best to make the combination work correctly
> rather than banning it, but that does require a bit of runtime testing.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
