Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD5538E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 08:10:30 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v11so9862074ply.4
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 05:10:30 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t3si7389390pgl.108.2019.01.19.05.10.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Jan 2019 05:10:29 -0800 (PST)
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
References: <ea2bc542-38b2-8218-9eb7-4c4a05da36ea@i-love.sakura.ne.jp>
 <CACT4Y+Yy-bF07F7F8DoFY8=4LtLURRn1WsZzNZ9LN+N=vn7Tpw@mail.gmail.com>
 <201901180520.x0I5KYTi096127@www262.sakura.ne.jp>
 <CACT4Y+acvQXPLHFSbNYAEma6Rqx6QCp_kqjsbAF8M9og4KA3CA@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <d90cc533-607e-fe40-9b02-a6cac7b7b534@i-love.sakura.ne.jp>
Date: Sat, 19 Jan 2019 22:10:22 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+acvQXPLHFSbNYAEma6Rqx6QCp_kqjsbAF8M9og4KA3CA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>, David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>, Shakeel Butt <shakeelb@google.com>, syzkaller <syzkaller@googlegroups.com>

On 2019/01/19 21:16, Dmitry Vyukov wrote:
>> The question for me is, whether sysbot can detect hash collision with different
>> syz-program lines before writing the hash value to /dev/kmsg, and retry by modifying
>> syz-program lines in order to get a new hash value until collision is avoided.
>> If it is difficult, simpler choice like current Unix time and PID could be used
>> instead...
> 
> Hummm, say, if you run syz-manager locally and report a bug, where
> will the webserver and database that allows to download all satellite
> info work? How long you need to keep this info and provide the web
> service? You will also need to pay and maintain the server for... how
> long? I don't see how this can work and how we can ask people to do
> this. This frankly looks like overly complex solution to a problem
> were simpler solutions will work. Keeping all info in a self-contained
> file looks like the only option to make it work reliably.
> It's also not possible to attribute kernel output to individual programs.

The first messages I want to look at is kernel output. Then, I look at
syz-program lines as needed. But current "a self-contained file" is
hard to find kernel output. Even if we keep both kernel output and
syz-program lines in a single file, we can improve readability by
splitting into kernel output section and syz-program section.

  # Kernel output section start
  [$(uptime)][$(caller_info)] executing program #0123456789abcdef0123456789abcdef
  [$(uptime)][$(caller_info)] $(kernel_messages_caused_by_0123456789abcdef0123456789abcdef_are_here)
  [$(uptime)][$(caller_info)] executing program #456789abcdef0123456789abcdef0123
  [$(uptime)][$(caller_info)] $(kernel_messages_caused_by_456789abcdef0123456789abcdef0123_and_0123456789abcdef0123456789abcdef_are_here)
  [$(uptime)][$(caller_info)] executing program #89abcdef0123456789abcdef01234567
  [$(uptime)][$(caller_info)] $(kernel_messages_caused_by_89abcdef0123456789abcdef01234567_456789abcdef0123456789abcdef0123_and_0123456789abcdef0123456789abcdef_are_here)
  [$(uptime)][$(caller_info)] BUG: unable to handle kernel paging request at $(address)
  [$(uptime)][$(caller_info)] CPU: $(cpu) PID: $(pid) Comm: syz#89abcdef0123 Not tainted $(version) #$(build)
  [$(uptime)][$(caller_info)] $(backtrace_of_caller_info_is_here)
  [$(uptime)][$(caller_info)] Kernel panic - not syncing: Fatal exception
  # Kernel output section end
  # syzbot code section start
  Program for #0123456789abcdef0123456789abcdef
  $(program_lines_for_0123456789abcdef0123456789abcdef_is_here)
  Program for #456789abcdef0123456789abcdef0123
  $(program_lines_for_456789abcdef0123456789abcdef0123_is_here)
  Program for #89abcdef0123456789abcdef01234567
  $(program_lines_for_89abcdef0123456789abcdef01234567_is_here)
  # syzbot code section end
