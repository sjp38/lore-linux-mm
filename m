Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 931526B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 15:00:10 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id y131-v6so10050997itc.5
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:00:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k81sor1462343iod.251.2018.04.16.12.00.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 12:00:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyyZ7KmXbEa151JP287vypJAkxugW17YC7Q1B9=TnyHkw@mail.gmail.com>
References: <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd> <20180416122019.1c175925@gandalf.local.home>
 <20180416162757.GB2341@sasha-vm> <20180416163952.GA8740@amd>
 <20180416164310.GF2341@sasha-vm> <20180416125307.0c4f6f28@gandalf.local.home>
 <20180416170936.GI2341@sasha-vm> <20180416133321.40a166a4@gandalf.local.home>
 <20180416174236.GL2341@sasha-vm> <20180416142653.0f017647@gandalf.local.home>
 <CA+55aFzggPvS2MwFnKfXs6yHUQrbrJH7uyY4=znwetcdEXmZrw@mail.gmail.com>
 <20180416144117.5757ee70@gandalf.local.home> <CA+55aFyyZ7KmXbEa151JP287vypJAkxugW17YC7Q1B9=TnyHkw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 16 Apr 2018 12:00:08 -0700
Message-ID: <CA+55aFz0obg3SmCpa7Ff2d91CATF8p-syYjkm4s5FrR+cp5XRA@mail.gmail.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Pavel Machek <pavel@ucw.cz>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, Apr 16, 2018 at 11:52 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> We're better off making *no* progress, than making "unsteady progress".
>
> Really. Seriously.

Side note: the original impetus for this was our suspend/resume mess.
It went on for *YEARS*, and it was absolutely chock-full of exactly
this "I fixed the worse problem, and introduced another one".

There's a reason I'm a hardliner on the regression issue.  We've been
there, we've done that.

The whole "two steps forwards, one step back" mentality may work
really well if you're doing line dancing.

BUT WE ARE NOT LINE DANCING. We do kernel development.

Absolutely NOTHING else is more important than the "no regressions"
rule. NOTHING.

And just since everybody always tries to weasel about this: the only
regressions that matter are the ones that people notice in real loads.

So if you write a test-case that tests that "system call number 345
returns -ENOSYS", and we add a new system call, and you say "hey, you
regressed my system call test", that's not a regression. That's just a
"change in behavior".

It becomes a regression only if there are people using tools or
workflows that actually depend on it. So if it turns out (for example)
that Firefox had some really odd bug, and the intent was to do system
call 123, but a typo had caused it to do system call 345 instead, and
another bug meant that the end result worked fine as long as system
call 345 returned ENOSYS, then the addition of that system call
actually does turn into a regression.

See? Even adding a system call can be a regression, because what
matters is not behavior per se, but users _depending_ on some specific
behavior.

               Linus
