Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D192C6B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 16:34:03 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u13so14206933wre.1
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:34:03 -0700 (PDT)
Received: from twin.jikos.cz (twin.jikos.cz. [91.219.245.39])
        by mx.google.com with ESMTPS id i67si5549210wmf.22.2018.04.16.13.34.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 13:34:02 -0700 (PDT)
Date: Mon, 16 Apr 2018 22:33:16 +0200 (CEST)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
In-Reply-To: <CA+55aFxiUhaFVBDhrTGJmgKZid2nO0efh6Mng1NQJ0JK4EHqMg@mail.gmail.com>
Message-ID: <alpine.LRH.2.00.1804162221320.26111@gjva.wvxbf.pm>
References: <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm> <20180416160608.GA7071@amd> <20180416122019.1c175925@gandalf.local.home> <20180416162757.GB2341@sasha-vm> <20180416163952.GA8740@amd> <20180416164310.GF2341@sasha-vm>
 <20180416125307.0c4f6f28@gandalf.local.home> <20180416170936.GI2341@sasha-vm> <20180416133321.40a166a4@gandalf.local.home> <20180416174236.GL2341@sasha-vm> <20180416142653.0f017647@gandalf.local.home> <CA+55aFzggPvS2MwFnKfXs6yHUQrbrJH7uyY4=znwetcdEXmZrw@mail.gmail.com>
 <20180416144117.5757ee70@gandalf.local.home> <CA+55aFyyZ7KmXbEa151JP287vypJAkxugW17YC7Q1B9=TnyHkw@mail.gmail.com> <20180416152429.529e3cba@gandalf.local.home> <CA+55aFwjSRZDT1f99QdY-Q5R4W_asb_1mZgM69YOqRR9-efmwA@mail.gmail.com> <20180416153816.292a5b5c@gandalf.local.home>
 <CA+55aFwXRjgfLfAWSaLBdajjzh4gt8-5M2N-bmjKt8nrJT+vWQ@mail.gmail.com> <20180416160232.2b807ff1@gandalf.local.home> <CA+55aFxiUhaFVBDhrTGJmgKZid2nO0efh6Mng1NQJ0JK4EHqMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sasha Levin <Alexander.Levin@microsoft.com>, Pavel Machek <pavel@ucw.cz>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, 16 Apr 2018, Linus Torvalds wrote:

> The ones who should matter most for that discussion is the distros,
> since they are the actual users of stable (as well as the people doing
> the work, of course - ie Sasha and Greg and the rest of the stable
> gang).
> 
> And I suspect that they actually do want all the noise, and all the
> stuff that isn't "critical". That's often the _easy_ choice. It's the
> stuff that I suspect the stable maintainers go "this I don't even have
> to think about", because it's a new driver ID or something.

So I am a maintainer of SUSE enterprise kernel, and I can tell you I 
personally really don't want all the noise, simply because

	(a) noone asked us to distribute it (if they did, we would do so)
	(b) the risk of regressions

We've always been very cautious about what is coming from stable, and 
actually filtering out patches we actively don't want for one reason or 
another.

And yes, there is also a history of regressions caused by stable updates 
that were painful for us ... I brought this up a multiple times at 
ksummit-discuss@ over past years.

So with the upcoming release, we've actually abandonded stable and are 
relying more on auto-processing the Fixes: tag.

That is not perfect in both ways (it doesn't cover everything, and we can 
miss complex semantical dependencies between patches even though they 
"apply"), but we didn't base our decision this time on aligning our 
schedule with stable, and so far we don't seem to be suffering. And we 
have much better overview / control over what is landing in our enterprise 
tree (of course this all is shepherded by machinery around processing 
Fixes: tag, which then though has to be *actively* acted upon, depending 
on a case-by-case human assessment of how critical it actually is).

> Because the bulk of stable tends to be driver updates, afaik. Which 
> distros very much tend to want.

For "community" distros (like Fedora, openSUSE), perhaps, yeah.

For "enterprise" kernels, quite frankly, we much rather get the driver 
updates/backports from the respective HW vedndors we're cooperating with, 
as they have actually tested and verified the backport on the metal.

> The critical stuff is hopefully a tiny tiny percentage.

But quite frankly, that's the only thing we as distro *really* want -- to 
save our users from hitting the critical issues with all the consequences 
(data loss, unbootable systems, etc). All the rest we can easily handle on 
a reactive basis, which heavily depends on the userbase spectrum (and 
that's probably completely different for each -stable tree consumer 
anyway).

This is a POV of me as an distro kernel maintainer, but mileage of others 
definitely can / will vary of course.

Thanks,

-- 
Jiri Kosina
SUSE Labs
