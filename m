Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC50B8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 06:13:05 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id g7so255407itg.7
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 03:13:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z2sor32195697ioi.114.2019.01.07.03.13.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 03:13:04 -0800 (PST)
MIME-Version: 1.0
References: <0000000000007beca9057e4c8c14@google.com> <CACT4Y+Yx4BJw=F_PMx9a8AjPKzEwhzLnzt9K-dgkBoNkKQj2+g@mail.gmail.com>
 <ef2508c9-d069-2143-09a6-a90b9ef12568@I-love.SAKURA.ne.jp>
 <CACT4Y+YYwYDnqFmMwfSg6UNXnrbh46bo0jp7ijbej8nkDDmBXQ@mail.gmail.com>
 <eeb95c52-5bf8-d3ce-d32b-269aa86bcd93@i-love.sakura.ne.jp>
 <8cdbcb63-d2f7-cace-0eda-d73255fd47e7@i-love.sakura.ne.jp>
 <CACT4Y+Y5cdD=optF2k4a0W7vriVnzmzLU0SPGEJoOHRMi_bsZA@mail.gmail.com> <ea2bc542-38b2-8218-9eb7-4c4a05da36ea@i-love.sakura.ne.jp>
In-Reply-To: <ea2bc542-38b2-8218-9eb7-4c4a05da36ea@i-love.sakura.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 7 Jan 2019 12:12:53 +0100
Message-ID: <CACT4Y+Yy-bF07F7F8DoFY8=4LtLURRn1WsZzNZ9LN+N=vn7Tpw@mail.gmail.com>
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>, David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>, Shakeel Butt <shakeelb@google.com>

On Sun, Jan 6, 2019 at 2:47 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/01/06 22:24, Dmitry Vyukov wrote:
> >> A report at 2019/01/05 10:08 from "no output from test machine (2)"
> >> ( https://syzkaller.appspot.com/text?tag=CrashLog&x=1700726f400000 )
> >> says that there are flood of memory allocation failure messages.
> >> Since continuous memory allocation failure messages itself is not
> >> recognized as a crash, we might be misunderstanding that this problem
> >> is not occurring recently. It will be nice if we can run testcases
> >> which are executed on bpf-next tree.
> >
> > What exactly do you mean by running test cases on bpf-next tree?
> > syzbot tests bpf-next, so it executes lots of test cases on that tree.
> > One can also ask for patch testing on bpf-next tree to test a specific
> > test case.
>
> syzbot ran "some tests" before getting this report, but we can't find from
> this report what the "some tests" are. If we could record all tests executed
> in syzbot environments before getting this report, we could rerun the tests
> (with manually examining where the source of memory consumption is) in local
> environments.

Filed https://github.com/google/syzkaller/issues/917 for this.

> Since syzbot is now using memcg, maybe we can test with sysctl_panic_on_oom == 1.
> Any memory consumption that triggers global OOM killer could be considered as
> a problem (e.g. memory leak or uncontrolled memory allocation).

Interesting idea. This will also alleviate the previous problem as I
think only a stream of OOMs currently produces 1+MB of output.

+Shakeel who was interested in catching more memcg-escaping allocations.

To do this we need a buy-in from kernel community to consider this as
a bug/something to fix in kernel. Systematic testing can't work gray
checks requiring humans to look at each case and some cases left as
being working-as-intended.

There are also 2 interesting points:
 - testing of kernel without memcg-enabled (some kernel users
obviously do this); it's doable, but currently syzkaller have no
precedents/infrastructure to consider some output patterns as bugs or
not depending on kernel features
 - false positives for minimized C reproducers that have memcg code
stripped off (people complain that reproducers are too large/complex
otherwise)
