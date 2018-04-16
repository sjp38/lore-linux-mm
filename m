Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5296B000A
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:23:33 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id m14so6806439pfj.18
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 10:23:33 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0138.outbound.protection.outlook.com. [104.47.36.138])
        by mx.google.com with ESMTPS id 59-v6si5479330plp.179.2018.04.16.10.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 10:23:32 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 17:23:30 +0000
Message-ID: <20180416172327.GK2341@sasha-vm>
References: <20180415144248.GP2341@sasha-vm>
 <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416113629.2474ae74@gandalf.local.home> <20180416160200.GY2341@sasha-vm>
 <20180416121224.2138b806@gandalf.local.home> <20180416161911.GA2341@sasha-vm>
 <20180416123019.4d235374@gandalf.local.home> <20180416163754.GD2341@sasha-vm>
 <20180416170604.GC11034@amd>
In-Reply-To: <20180416170604.GC11034@amd>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3D765F417F57E84DB8B91271B39281FA@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, Apr 16, 2018 at 07:06:04PM +0200, Pavel Machek wrote:
>On Mon 2018-04-16 16:37:56, Sasha Levin wrote:
>> On Mon, Apr 16, 2018 at 12:30:19PM -0400, Steven Rostedt wrote:
>> >On Mon, 16 Apr 2018 16:19:14 +0000
>> >Sasha Levin <Alexander.Levin@microsoft.com> wrote:
>> >
>> >> >Wait! What does that mean? What's the purpose of stable if it is as
>> >> >broken as mainline?
>> >>
>> >> This just means that if there is a fix that went in mainline, and the
>> >> fix is broken somehow, we'd rather take the broken fix than not.
>> >>
>> >> In this scenario, *something* will be broken, it's just a matter of
>> >> what. We'd rather have the same thing broken between mainline and
>> >> stable.
>> >
>> >Honestly, I think that removes all value of the stable series. I
>> >remember when the stable series were first created. People were saying
>> >that it wouldn't even get to more than 5 versions, because the bar for
>> >backporting was suppose to be very high. Today it's just a fork of the
>> >kernel at a given version. No more features, but we will be OK with
>> >regressions. I'm struggling to see what the benefit of it is suppose to
>> >be?
>>
>> It's not "OK with regressions".
>>
>> Let's look at a hypothetical example: You have a 4.15.1 kernel that has
>> a broken printf() behaviour so that when you:
>>
>> 	pr_err("%d", 5)
>>
>> Would print:
>>
>> 	"Microsoft Rulez"
>>
>> Bad, right? So you went ahead and fixed it, and now it prints "5" as you
>> might expect. But alas, with your patch, running:
>>
>> 	pr_err("%s", "hi!")
>>
>> Would show a cat picture for 5 seconds.
>>
>> Should we take your patch in -stable or not? If we don't, we're stuck
>> with the original issue while the mainline kernel will behave
>> differently, but if we do - we introduce a new regression.
>
>Of course not.
>
>- It must be obviously correct and tested.
>
>If it introduces new bug, it is not correct, and certainly not
>obviously correct.

As you might have noticed, we don't strictly follow the rules.

Take a look at the whole PTI story as an example. It's way more than 100
lines, it's not obviously corrent, it fixed more than 1 thing, and so
on, and yet it went in -stable!

Would you argue we shouldn't have backported PTI to -stable?=
