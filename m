Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3766B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:17:21 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j6so1208456pgn.7
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:17:21 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0099.outbound.protection.outlook.com. [104.47.32.99])
        by mx.google.com with ESMTPS id k13si10090166pgr.124.2018.04.16.11.17.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 11:17:19 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 18:17:17 +0000
Message-ID: <20180416181715.GM2341@sasha-vm>
References: <20180415144248.GP2341@sasha-vm>
 <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd> <20180416161412.GZ2341@sasha-vm>
 <20180416170501.GB11034@amd> <20180416171607.GJ2341@sasha-vm>
 <20180416134423.2b60ff13@gandalf.local.home>
In-Reply-To: <20180416134423.2b60ff13@gandalf.local.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <BD093F82ADD8374A9680DF28D6F0867B@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, Apr 16, 2018 at 01:44:23PM -0400, Steven Rostedt wrote:
>On Mon, 16 Apr 2018 17:16:10 +0000
>Sasha Levin <Alexander.Levin@microsoft.com> wrote:
>
>
>> So if a user is operating a nuclear power plant, and has 2 leds: green
>> one that says "All OK!" and a red one saying "NUCLEAR MELTDOWN!", and
>> once in a blue moon a race condition is causing the red one to go on and
>> cause panic in the little province he lives in, we should tell that user
>> to fuck off?
>>
>> LEDs may not be critical for you, but they can be critical for someone
>> else. Think of all the different users we have and the wildly different
>> ways they use the kernel.
>
>We can point them to the fix and have them backport it. Or they should
>ask their distribution to backport it.

It may work in your subsystem, but it really doesn't work this way with
the kernel.

Let me share a concrete example with you: there's a vfs bug that's a
pain to reproduce going around. It was originally reported on
CoreOS/AWS:

	https://github.com/coreos/bugs/issues/2356

But our customers reported to us that they're hitting this issue too.

We couldn't reproduce it, and the call trace indicated it may be a
memory corrution. We could however confirm with the customers that the
latest mainline fixes the issue.

Given that we couldn't reproduce it, and neither of us is a fs/ expert,
we sent a mail to LKML, just like you suggested doing:

	https://lkml.org/lkml/2018/3/2/1038

But unlike what you said, no one pointed us to the fix, even though the
issue was fixed on mainline. Heck, no one engaged in any meaningful
conversation about the bug.

I really think that we have a different views as to how well the whole
"let me shoot a mail to LKML" process works, which leads to different
views on -stable.

>Hopefully they tested the kernel they are using for something like
>that, and only want critical fixes. What happens if they take the next
>stable assuming that it has critical fixes only, and this fix causes a
>regression that creates the "ALL OK!" when it wasn't.
>
>Basically, I rather have stable be more bug compatible with the version
>it is based on with only critical fixes (things that will cause an
>oops) than to try to be bug compatible with mainline, as then we get
>into a state where things are a frankenstein of the stable base version
>and mainline. I could say, "Yeah this feature works better on this
>4.x version of the kernel" and not worry about "4.x.y" versions having
>it better.

This is how things used to work, right? Look at redhat kernels for
example, they'd stick with a kernel for tens of years, doing the tiniest
fixes, only when customers complained, and encouraging users to upgrade
only when the kernel would go EoL, and when customers couldn't do that
because they were too locked on that kernel version.

redhat still supports 2.6.9.

I thought we agreed that this is bad? We wanted users to be closer to
mainline, and we can't do it without bringing -stable closer to mainline
as well.=
