Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5CE8E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 08:30:42 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id b14so8491986itd.1
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 05:30:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 23sor24563116jal.5.2019.01.20.05.30.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 05:30:40 -0800 (PST)
MIME-Version: 1.0
References: <ea2bc542-38b2-8218-9eb7-4c4a05da36ea@i-love.sakura.ne.jp>
 <CACT4Y+Yy-bF07F7F8DoFY8=4LtLURRn1WsZzNZ9LN+N=vn7Tpw@mail.gmail.com>
 <201901180520.x0I5KYTi096127@www262.sakura.ne.jp> <CACT4Y+acvQXPLHFSbNYAEma6Rqx6QCp_kqjsbAF8M9og4KA3CA@mail.gmail.com>
 <d90cc533-607e-fe40-9b02-a6cac7b7b534@i-love.sakura.ne.jp>
In-Reply-To: <d90cc533-607e-fe40-9b02-a6cac7b7b534@i-love.sakura.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 20 Jan 2019 14:30:29 +0100
Message-ID: <CACT4Y+b=5_p=eTgKobApkZZTAVeRxrn3dEempFHampFjrGX0Pw@mail.gmail.com>
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>, David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>, Shakeel Butt <shakeelb@google.com>, syzkaller <syzkaller@googlegroups.com>

On Sat, Jan 19, 2019 at 2:10 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/01/19 21:16, Dmitry Vyukov wrote:
> >> The question for me is, whether sysbot can detect hash collision with different
> >> syz-program lines before writing the hash value to /dev/kmsg, and retry by modifying
> >> syz-program lines in order to get a new hash value until collision is avoided.
> >> If it is difficult, simpler choice like current Unix time and PID could be used
> >> instead...
> >
> > Hummm, say, if you run syz-manager locally and report a bug, where
> > will the webserver and database that allows to download all satellite
> > info work? How long you need to keep this info and provide the web
> > service? You will also need to pay and maintain the server for... how
> > long? I don't see how this can work and how we can ask people to do
> > this. This frankly looks like overly complex solution to a problem
> > were simpler solutions will work. Keeping all info in a self-contained
> > file looks like the only option to make it work reliably.
> > It's also not possible to attribute kernel output to individual programs.
>
> The first messages I want to look at is kernel output. Then, I look at
> syz-program lines as needed. But current "a self-contained file" is
> hard to find kernel output.

I think everybody looks at kernel crash first, that's why we provide
kernel crash inline in the email so it's super easy to find. One does
not need to look at console output at all to read the crash message.
Console output is meant for more complex cases when a developer needs
to extract some long tail of custom information. We don't know what
exactly information a developer is looking for and it is different in
each case, so it's not possible to optimize for this. We preserve
console output intact to not destroy some potentially important
information. Say, if we start reordering messages, we lose timing
information and timing/interleaving information is important in some
cases.

> Even if we keep both kernel output and
> syz-program lines in a single file, we can improve readability by
> splitting into kernel output section and syz-program section.
>
>   # Kernel output section start
>   [$(uptime)][$(caller_info)] executing program #0123456789abcdef0123456789abcdef
>   [$(uptime)][$(caller_info)] $(kernel_messages_caused_by_0123456789abcdef0123456789abcdef_are_here)
>   [$(uptime)][$(caller_info)] executing program #456789abcdef0123456789abcdef0123
>   [$(uptime)][$(caller_info)] $(kernel_messages_caused_by_456789abcdef0123456789abcdef0123_and_0123456789abcdef0123456789abcdef_are_here)
>   [$(uptime)][$(caller_info)] executing program #89abcdef0123456789abcdef01234567
>   [$(uptime)][$(caller_info)] $(kernel_messages_caused_by_89abcdef0123456789abcdef01234567_456789abcdef0123456789abcdef0123_and_0123456789abcdef0123456789abcdef_are_here)
>   [$(uptime)][$(caller_info)] BUG: unable to handle kernel paging request at $(address)
>   [$(uptime)][$(caller_info)] CPU: $(cpu) PID: $(pid) Comm: syz#89abcdef0123 Not tainted $(version) #$(build)
>   [$(uptime)][$(caller_info)] $(backtrace_of_caller_info_is_here)
>   [$(uptime)][$(caller_info)] Kernel panic - not syncing: Fatal exception
>   # Kernel output section end
>   # syzbot code section start
>   Program for #0123456789abcdef0123456789abcdef
>   $(program_lines_for_0123456789abcdef0123456789abcdef_is_here)
>   Program for #456789abcdef0123456789abcdef0123
>   $(program_lines_for_456789abcdef0123456789abcdef0123_is_here)
>   Program for #89abcdef0123456789abcdef01234567
>   $(program_lines_for_89abcdef0123456789abcdef01234567_is_here)
>   # syzbot code section end
>
