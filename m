Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C15F6B0012
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 12:19:38 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id c3-v6so12786241itc.4
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 09:19:38 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0127.outbound.protection.outlook.com. [104.47.33.127])
        by mx.google.com with ESMTPS id c139-v6si7521418itb.136.2018.04.17.09.19.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 09:19:37 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Tue, 17 Apr 2018 16:19:35 +0000
Message-ID: <20180417161933.GY2341@sasha-vm>
References: <20180416160200.GY2341@sasha-vm>
 <20180416121224.2138b806@gandalf.local.home> <20180416161911.GA2341@sasha-vm>
 <20180416123019.4d235374@gandalf.local.home> <20180416163754.GD2341@sasha-vm>
 <20180416170604.GC11034@amd> <20180416172327.GK2341@sasha-vm>
 <20180417114144.ov27khlig5thqvyo@quack2.suse.cz>
 <20180417133149.GR2341@sasha-vm>
 <20180417155549.6lxmoiwnlwtwdgld@quack2.suse.cz>
In-Reply-To: <20180417155549.6lxmoiwnlwtwdgld@quack2.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <691D2CF14B25954AA8F1F65B4D37659A@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue, Apr 17, 2018 at 05:55:49PM +0200, Jan Kara wrote:
>On Tue 17-04-18 13:31:51, Sasha Levin wrote:
>> We may be able to guesstimate the 'regression chance', but there's no
>> way we can guess the 'annoyance' once. There are so many different use
>> cases that we just can't even guess how many people would get "annoyed"
>> by something.
>
>As a maintainer, I hope I have reasonable idea what are common use cases
>for my subsystem. Those I cater to when estimating 'annoyance'. Sure I don=
't
>know all of the use cases so people doing unusual stuff hit more bugs and
>have to report them to get fixes included in -stable. But for me this is a
>preferable tradeoff over the risk of regression so this is the rule I use
>when tagging for stable. Now I'm not a -stable maintainer and I fully agre=
e
>with "those who do the work decide" principle so pick whatever patches you
>think are appropriate, I just wanted explain why I don't think more patche=
s
>in stable are necessarily good.

The AUTOSEL story is different for subsystems that don't do -stable, and
subsystems that are actually doing the work (like yourself).

I'm not trying to override active maintainers, I'm trying to help them
make decisions.

The AUTOSEL bot will attempt to apply any patch it deems as -stable for
on all -stable branches, finding possible dependencies, build them, and
run any tests that you might deem necessary.

You would be able to start your analysis without "wasting" time on doing
a bunch of "manual labor".

There's a big difference between subsystems like yours and most of the
rest of the kernel.

>> Even regression chance is tricky, look at the commits I've linked
>> earlier in the thread. Even the most trivial looking commits that end up
>> in stable have a chance for regression.
>
>Sure, you can never be certain and I think people (including me)
>underestimate the chance of regressions for "trivial" patches. But you jus=
t
>estimate a chance, you may be lucky, you may not...
>
>> >Another point I wanted to make is that if chance a patch causes a
>> >regression is about 2% as you said somewhere else in a thread, then by
>> >adding 20 patches that "may fix a bug that is annoying for someone" you=
've
>> >just increased a chance there's a regression in the release by 34%. And
>>
>> So I've said that the rejection rate is less than 2%. This includes
>> all commits that I have proposed for -stable, but didn't end up being
>> included in -stable.
>>
>> This includes commits that the author/maintainers NACKed, commits that
>> didn't do anything on older kernels, commits that were buggy but were
>> caught before the kernel was released, commits that failed to build on
>> an arch I didn't test it on originally and so on.
>>
>> After thousands of merged AUTOSEL patches I can count the number of
>> times a commit has caused a regression and had to be removed on one
>> hand.
>>
>> >this is not just a math game, this also roughly matches a real experien=
ce
>> >with maintaining our enterprise kernels. Do 20 "maybe" fixes outweight =
such
>> >regression chance? And I also note that for a regression to get reporte=
d so
>> >that it gets included into your 2% estimate of a patch regression rate,
>> >someone must be bothered enough by it to triage it and send an email
>> >somewhere so that already falls into a category of "serious" stuff to m=
e.
>>
>> It is indeed a numbers game, but the regression rate isn't 2%, it's
>> closer to 0.05%.
>
>Honestly, I think 0.05% is too optimististic :) Quick grepping of 4.14
>stable tree suggests some 13 commits were reverted from stable due to bugs=
.
>That's some 0.4% and that doesn't count fixes that were applied to
>fix other regressions.

0.05% is for commits that were merged in stable but later fixed or
reverted because they introduced a regression. By grepping for reverts
you also include things such as:

 - Reverts of commits that were in the corresponding mainline tree
 - Reverts of commits that didn't introduce regressions

>But the actual numbers don't really matter that much, in principle the mor=
e
>patches you add the higher is the chance of regression. You can't change
>that so you better have a good reason to include a patch...

You increase the chance of regressions, but you also increase the chance
of fixing bugs that affect users.

My claim is that the chance to fix bugs increases far more significantly
than the chance to introduce regressions.=
