Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7E36B0006
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 15:19:54 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 140-v6so10166944itg.4
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:19:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i129-v6sor4627215iti.147.2018.04.16.12.19.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 12:19:53 -0700 (PDT)
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
Date: Mon, 16 Apr 2018 12:19:51 -0700
Message-ID: <CA+55aFxt1FFJ0DPpHcANvHiOO1JLcupDok+mHKG7D+zzC-TeYw@mail.gmail.com>
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
> And yes, sometimes that means jumping through hoops. But that's what
> it takes to keep users happy.

The example of "jumping through hoops" I tend to give is the pipe "packet mode".

The kernel actually has a magic pipe mode for "packet buffers", so
that if you do two small writes, the other side of the pipe can
actually say "I want to read not the pipe buffers, but the individual
packets".

Why would we do that? That's not how pipes work! If you want to send
and receive messages, use a socket, for chrissake! A pipe is just a
stream of bytes - as the elder Gods of Unix decreed!

But it turns out that we added the notion of a packetized pipe writer,
and you can actually access it in user space by setting the O_DIRECT
flag (so after you do the "pipe()" system call, do a fcntl(SETFL,
O_DIRECT) on it).

Absolutely nobody uses it, afaik, because you'd be crazy to do it.
What would be the point? sockets work, and are portable.

So why do we have it?

We have it for one single user: autofs. The way you talk to the kernel
side of things is with a magic pipe that you get at mount time, and
the user-space autofs daemon might be 32-bit even if the kernel is
64-bit, and we had a horrible ABI mistake which meant that sending the
binary data over that pipe had different format for a 32-bit autofsd.

And systemd and automount had different workarounds (or lack
there-of), for the ABI issue.

So the whole "ok, allow people to send packets, and read them as
packets" came about purely because the ABI was broken, and there was
no other way to fix things.

See 64f371bc3107 ("autofs: make the autofsv5 packet file descriptor
use a packetized pipe") for (some) of the sad details.

That commit kind of makes it sound like it's a nice solution that just
takes advantage of the packetized pipes. Nice and clean fix, right?

No. The packetized pipes exist in the first place _purely_ to make
that nice solution possible. It's literally just a "this allows us to
be ABI compatible with two different users that were confused about
the compatibility issue we had due to a broken binary structure format
acrss x86-32 and x86-64".

See commit 9883035ae7ed ("pipes: add a "packetized pipe" mode for
writing") for the other side of that.

All this just because _we_ made a mistake in our ABI, and then real
life users started using that mistake, including one user that
literally *knew* about the mistake and worked around it and started
depending on the fact t hat our compatibility mode was buggy because
of it.

So it was a bug in our ABI. But since people depended on the bug, the
bug was a feature, and needed to be kept around. In this case by
adding a totally new and unrelated feature, and using that new feature
to make those old users happy. The whole "set packetized mode on the
autofs pipe" is all done transparently inside the kernel, and
automount never knew or needed to care that we started to use a
packetized pipe to get the data it sent us in the chunks it intended.

             Linus
