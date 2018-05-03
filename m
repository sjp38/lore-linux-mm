Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 451316B0005
	for <linux-mm@kvack.org>; Thu,  3 May 2018 09:28:10 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id y4-v6so17508749iod.5
        for <linux-mm@kvack.org>; Thu, 03 May 2018 06:28:10 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0108.outbound.protection.outlook.com. [104.47.38.108])
        by mx.google.com with ESMTPS id 23-v6si11058273itj.37.2018.05.03.06.28.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 03 May 2018 06:28:09 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Thu, 3 May 2018 13:28:04 +0000
Message-ID: <20180503132800.GH18390@sasha-vm>
References: <20180416161911.GA2341@sasha-vm>
 <20180416123019.4d235374@gandalf.local.home> <20180416163754.GD2341@sasha-vm>
 <20180416170604.GC11034@amd> <20180416172327.GK2341@sasha-vm>
 <20180417114144.ov27khlig5thqvyo@quack2.suse.cz>
 <20180417133149.GR2341@sasha-vm>
 <20180417155549.6lxmoiwnlwtwdgld@quack2.suse.cz>
 <20180417161933.GY2341@sasha-vm> <20180503093651.GC32180@amd>
In-Reply-To: <20180503093651.GC32180@amd>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <889546DA857A2243B0CBD37E2EF4F4DB@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: "jacek.anaszewski@gmail.com" <jacek.anaszewski@gmail.com>, "Rafael J.
 Wysocki" <rjw@rjwysocki.net>, Jan Kara <jack@suse.cz>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Thu, May 03, 2018 at 11:36:51AM +0200, Pavel Machek wrote:
>On Tue 2018-04-17 16:19:35, Sasha Levin wrote:
>> On Tue, Apr 17, 2018 at 05:55:49PM +0200, Jan Kara wrote:
>> >On Tue 17-04-18 13:31:51, Sasha Levin wrote:
>> >> We may be able to guesstimate the 'regression chance', but there's no
>> >> way we can guess the 'annoyance' once. There are so many different us=
e
>> >> cases that we just can't even guess how many people would get "annoye=
d"
>> >> by something.
>> >
>> >As a maintainer, I hope I have reasonable idea what are common use case=
s
>> >for my subsystem. Those I cater to when estimating 'annoyance'. Sure I =
don't
>> >know all of the use cases so people doing unusual stuff hit more bugs a=
nd
>> >have to report them to get fixes included in -stable. But for me this i=
s a
>> >preferable tradeoff over the risk of regression so this is the rule I u=
se
>> >when tagging for stable. Now I'm not a -stable maintainer and I fully a=
gree
>> >with "those who do the work decide" principle so pick whatever patches =
you
>> >think are appropriate, I just wanted explain why I don't think more pat=
ches
>> >in stable are necessarily good.
>>
>> The AUTOSEL story is different for subsystems that don't do -stable, and
>> subsystems that are actually doing the work (like yourself).
>>
>> I'm not trying to override active maintainers, I'm trying to help them
>> make decisions.
>
>Ok, cool. Can you exclude LED subsystem, Hibernation and Nokia N900
>stuff from autosel work?

Curiousity got me, and I had to see what these subsystems do as far as
stable commits:

$ git log --oneline --grep 'stable@vger' --since=3D"01-01-2016" kernel/powe=
r drivers/leds drivers/media/i2c/et8ek8 drivers/media/i2c/ad5820.c arch/x86=
/kernel/acpi/ | wc -l
7

Which got me a bit surprised: maybe indeed leds is mostly fine, but
hibernation is definitely tricky, I've been stung by it a few times...

So why not pick something an actual user reported, and see how that was
dealt with?

Googling first showed this:

	https://bugzilla.kernel.org/show_bug.cgi?id=3D97201

Which was fixed by:

	https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/=
?id=3Dbdbc98abb3aa323f6323b11db39c740e6f8fc5b1

But that's not in any -stable tree. Hmm.. ok..

Next one on google was:

	https://bugzilla.kernel.org/show_bug.cgi?id=3D117971

Which, in turn, was fixed by:

	https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/=
?id=3D5b3f249c94ce1f46bacd9814385b0ee2d1ae52f3

Oh look at that, it's not in -stable either...

So seeing how you have concerns with my selection of -stable commits,
maybe you could explain to me why these commits didn't end up in
-stable?=
