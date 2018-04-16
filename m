Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1F96B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 16:17:27 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id a10-v6so10356007itb.1
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:17:27 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 184sor5342743ioy.307.2018.04.16.13.17.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 13:17:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180416160232.2b807ff1@gandalf.local.home>
References: <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd> <20180416122019.1c175925@gandalf.local.home>
 <20180416162757.GB2341@sasha-vm> <20180416163952.GA8740@amd>
 <20180416164310.GF2341@sasha-vm> <20180416125307.0c4f6f28@gandalf.local.home>
 <20180416170936.GI2341@sasha-vm> <20180416133321.40a166a4@gandalf.local.home>
 <20180416174236.GL2341@sasha-vm> <20180416142653.0f017647@gandalf.local.home>
 <CA+55aFzggPvS2MwFnKfXs6yHUQrbrJH7uyY4=znwetcdEXmZrw@mail.gmail.com>
 <20180416144117.5757ee70@gandalf.local.home> <CA+55aFyyZ7KmXbEa151JP287vypJAkxugW17YC7Q1B9=TnyHkw@mail.gmail.com>
 <20180416152429.529e3cba@gandalf.local.home> <CA+55aFwjSRZDT1f99QdY-Q5R4W_asb_1mZgM69YOqRR9-efmwA@mail.gmail.com>
 <20180416153816.292a5b5c@gandalf.local.home> <CA+55aFwXRjgfLfAWSaLBdajjzh4gt8-5M2N-bmjKt8nrJT+vWQ@mail.gmail.com>
 <20180416160232.2b807ff1@gandalf.local.home>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 16 Apr 2018 13:17:24 -0700
Message-ID: <CA+55aFxiUhaFVBDhrTGJmgKZid2nO0efh6Mng1NQJ0JK4EHqMg@mail.gmail.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Pavel Machek <pavel@ucw.cz>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, Apr 16, 2018 at 1:02 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
>
> But this is going way off topic to what we were discussing. The
> discussion is about what gets backported. Is automating the process
> going to make stable better? Or is it likely to add more regressions.
>
> Sasha's response has been that his automated process has the same rate
> of regressions as what gets tagged by authors. My argument is that
> perhaps authors should tag less to stable.

The ones who should matter most for that discussion is the distros,
since they are the actual users of stable (as well as the people doing
the work, of course - ie Sasha and Greg and the rest of the stable
gang).

And I suspect that they actually do want all the noise, and all the
stuff that isn't "critical". That's often the _easy_ choice. It's the
stuff that I suspect the stable maintainers go "this I don't even have
to think about", because it's a new driver ID or something.

Because the bulk of stable tends to be driver updates, afaik. Which
distros very much tend to want.

Will developers think that their patches matter so much that they
should go to stable? Yes they will. Will they overtag as a result?
Probably. But the reverse likely also happens, where people simply
don't think about stable at all, and just want to fix a bug.

In many ways "Fixes" is likely a better thing to check for in stable
backports, but that doesn't always exist either.

And just judging by the amount of stable email I get - and by how
excited _I_ would be about stable work, I think "automated process" is
simply not an option. It's a _requirement_. You'd go completely crazy
if you didn't automate 99% of all the stable work.

So can you trust the "Cc: stable" as being perfect? Hell no. But
what's your alternative? Manually selecting things for stable? Asking
the developers separately?

Because "criticality" definitely isn't what determines it. If it was,
we'd never add driver ID's etc to stable - they're clearly not
"critical".

Yet it feels like that's sometimes those driver things are the _bulk_
of it, and it is usually fairly safe (not quite as obviously safe as
you'd think, because a driver ID addition has occasionally meant not
just "now it's supported", but instead "now the generic driver doesn't
trigger for it any more", so it can actually break things).

So I think - and _hope_ - that 99% of stable should be the
non-critical stuff that people don't even need to think about.

The critical stuff is hopefully a tiny tiny percentage.

                           Linus
