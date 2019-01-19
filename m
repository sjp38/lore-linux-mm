Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3698E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 07:16:27 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id o22so12909893iob.13
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 04:16:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l17sor3997010iob.121.2019.01.19.04.16.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 19 Jan 2019 04:16:25 -0800 (PST)
MIME-Version: 1.0
References: <ea2bc542-38b2-8218-9eb7-4c4a05da36ea@i-love.sakura.ne.jp>
 <CACT4Y+Yy-bF07F7F8DoFY8=4LtLURRn1WsZzNZ9LN+N=vn7Tpw@mail.gmail.com> <201901180520.x0I5KYTi096127@www262.sakura.ne.jp>
In-Reply-To: <201901180520.x0I5KYTi096127@www262.sakura.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sat, 19 Jan 2019 13:16:13 +0100
Message-ID: <CACT4Y+acvQXPLHFSbNYAEma6Rqx6QCp_kqjsbAF8M9og4KA3CA@mail.gmail.com>
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>, David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>, Shakeel Butt <shakeelb@google.com>, syzkaller <syzkaller@googlegroups.com>

On Fri, Jan 18, 2019 at 6:20 AM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> Dmitry Vyukov wrote:
> > On Sun, Jan 6, 2019 at 2:47 PM Tetsuo Handa
> > <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > >
> > > On 2019/01/06 22:24, Dmitry Vyukov wrote:
> > > >> A report at 2019/01/05 10:08 from "no output from test machine (2)"
> > > >> ( https://syzkaller.appspot.com/text?tag=CrashLog&x=1700726f400000 )
> > > >> says that there are flood of memory allocation failure messages.
> > > >> Since continuous memory allocation failure messages itself is not
> > > >> recognized as a crash, we might be misunderstanding that this problem
> > > >> is not occurring recently. It will be nice if we can run testcases
> > > >> which are executed on bpf-next tree.
> > > >
> > > > What exactly do you mean by running test cases on bpf-next tree?
> > > > syzbot tests bpf-next, so it executes lots of test cases on that tree.
> > > > One can also ask for patch testing on bpf-next tree to test a specific
> > > > test case.
> > >
> > > syzbot ran "some tests" before getting this report, but we can't find from
> > > this report what the "some tests" are. If we could record all tests executed
> > > in syzbot environments before getting this report, we could rerun the tests
> > > (with manually examining where the source of memory consumption is) in local
> > > environments.
> >
> > Filed https://github.com/google/syzkaller/issues/917 for this.
>
> Thanks. Here is what I would suggest.
>
> Let syz-fuzzer write to /dev/kmsg . But don't directly write syz-program lines.
> Instead, just write the hash value of syz-program lines, and allow downloading
> syz-program lines from external URL. Also, use the first 12 characters of the
> hash value as comm name executing that syz-program lines. An example of console
> output would look something like below.
>
>
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
>
> Then, we can build CrashLog by picking up all "executing program #" lines and
> "latest lines up to available space" from console output like below.
>
>   [$(uptime)][$(caller_info)] executing program #0123456789abcdef0123456789abcdef
>   [$(uptime)][$(caller_info)] executing program #456789abcdef0123456789abcdef0123
>   [$(uptime)][$(caller_info)] executing program #89abcdef0123456789abcdef01234567
>   [$(uptime)][$(caller_info)] $(kernel_messages_caused_by_89abcdef0123456789abcdef01234567_456789abcdef0123456789abcdef0123_and_0123456789abcdef0123456789abcdef_are_here)
>   [$(uptime)][$(caller_info)] BUG: unable to handle kernel paging request at $(address)
>   [$(uptime)][$(caller_info)] CPU: $(cpu) PID: $(pid) Comm: syz89abcdef0123 Not tainted $(version) #$(build)
>   [$(uptime)][$(caller_info)] $(backtrace_of_caller_info_is_here)
>   [$(uptime)][$(caller_info)] Kernel panic - not syncing: Fatal exception
>
> Then, we can understand that a crash happened when executing 89abcdef0123 and
> download 89abcdef0123456789abcdef01234567 for analysis. Also, we can download
> 0123456789abcdef0123456789abcdef and 456789abcdef0123456789abcdef0123 as needed.
>
> Honestly, since lines which follows "$(date) executing program $(num):" line can
> become so long, it is difficult to find where previous/next kernel messages are.
> If only one-liner "executing program #" output is used, it is easy to find
> previous/next kernel messages.
>
> The program referenced by "executing program #" would be made downloadable via
> Web server or git repository. Maybe "executing program https://$server/$hash"
> for the former case. But repeating "https://$server/" part would be redundant.
>
> The question for me is, whether sysbot can detect hash collision with different
> syz-program lines before writing the hash value to /dev/kmsg, and retry by modifying
> syz-program lines in order to get a new hash value until collision is avoided.
> If it is difficult, simpler choice like current Unix time and PID could be used
> instead...

Hummm, say, if you run syz-manager locally and report a bug, where
will the webserver and database that allows to download all satellite
info work? How long you need to keep this info and provide the web
service? You will also need to pay and maintain the server for... how
long? I don't see how this can work and how we can ask people to do
this. This frankly looks like overly complex solution to a problem
were simpler solutions will work. Keeping all info in a self-contained
file looks like the only option to make it work reliably.
It's also not possible to attribute kernel output to individual programs.
