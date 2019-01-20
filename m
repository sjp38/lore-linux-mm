Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D765D8E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 09:25:18 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id b8so14021009pfe.10
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 06:25:18 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id n13si9429168pgp.307.2019.01.20.06.25.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Jan 2019 06:25:16 -0800 (PST)
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
References: <ea2bc542-38b2-8218-9eb7-4c4a05da36ea@i-love.sakura.ne.jp>
 <CACT4Y+Yy-bF07F7F8DoFY8=4LtLURRn1WsZzNZ9LN+N=vn7Tpw@mail.gmail.com>
 <201901180520.x0I5KYTi096127@www262.sakura.ne.jp>
 <CACT4Y+acvQXPLHFSbNYAEma6Rqx6QCp_kqjsbAF8M9og4KA3CA@mail.gmail.com>
 <d90cc533-607e-fe40-9b02-a6cac7b7b534@i-love.sakura.ne.jp>
 <CACT4Y+b=5_p=eTgKobApkZZTAVeRxrn3dEempFHampFjrGX0Pw@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <de7ca08f-2a2f-bb1c-0525-8fdc198209a1@i-love.sakura.ne.jp>
Date: Sun, 20 Jan 2019 23:24:55 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+b=5_p=eTgKobApkZZTAVeRxrn3dEempFHampFjrGX0Pw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>, David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>, Shakeel Butt <shakeelb@google.com>, syzkaller <syzkaller@googlegroups.com>

On 2019/01/20 22:30, Dmitry Vyukov wrote:
>> The first messages I want to look at is kernel output. Then, I look at
>> syz-program lines as needed. But current "a self-contained file" is
>> hard to find kernel output.
> 
> I think everybody looks at kernel crash first, that's why we provide
> kernel crash inline in the email so it's super easy to find. One does
> not need to look at console output at all to read the crash message.

I don't think so. Sometimes it happens that a backtrace of memory allocation
fault injection prior to the crash tells everything. But since such lines are
not immediately findable from a file containing console output, people fails
to understand what has happened.

And one (of my two suggestions) is about helping people to easily find kernel
messages from console output, by moving syzbot-program lines into a dedicated
location.

> Console output is meant for more complex cases when a developer needs
> to extract some long tail of custom information.

This "INFO: rcu detected stall in ndisc_alloc_skb" is exactly a case where only
syzbot-program lines can provide some clue. And the other (of my two suggestions)
is about preserving all syzbot-program lines in a file containing console output.

>                                                  We don't know what
> exactly information a developer is looking for and it is different in
> each case, so it's not possible to optimize for this.

I'm not asking to optimize. I'm asking to preserve all syzbot-program lines.

>                                                       We preserve
> console output intact to not destroy some potentially important
> information. Say, if we start reordering messages, we lose timing
> information and timing/interleaving information is important in some
> cases.

My suggestion is not a reordering of messages. It is a cross referencing.
The [$(uptime)] part acts as the timing information. Since inlining syzbot-program
line there makes difficult to find previous/next kernel messages, I'm suggesting
to move syzbot-program lines into a dedicated block and cross reference using some
identifiers like hash. There is no loss of timing information, and we can
reconstruct interleaved output (if needed) as long as identifiers are unique
within that report.

> 
>> Even if we keep both kernel output and
>> syz-program lines in a single file, we can improve readability by
>> splitting into kernel output section and syz-program section.
>>
>>   # Kernel output section start
>>   [$(uptime)][$(caller_info)] executing program #0123456789abcdef0123456789abcdef
>>   [$(uptime)][$(caller_info)] $(kernel_messages_caused_by_0123456789abcdef0123456789abcdef_are_here)
>>   [$(uptime)][$(caller_info)] executing program #456789abcdef0123456789abcdef0123
>>   [$(uptime)][$(caller_info)] $(kernel_messages_caused_by_456789abcdef0123456789abcdef0123_and_0123456789abcdef0123456789abcdef_are_here)
>>   [$(uptime)][$(caller_info)] executing program #89abcdef0123456789abcdef01234567
>>   [$(uptime)][$(caller_info)] $(kernel_messages_caused_by_89abcdef0123456789abcdef01234567_456789abcdef0123456789abcdef0123_and_0123456789abcdef0123456789abcdef_are_here)
>>   [$(uptime)][$(caller_info)] BUG: unable to handle kernel paging request at $(address)
>>   [$(uptime)][$(caller_info)] CPU: $(cpu) PID: $(pid) Comm: syz#89abcdef0123 Not tainted $(version) #$(build)
>>   [$(uptime)][$(caller_info)] $(backtrace_of_caller_info_is_here)
>>   [$(uptime)][$(caller_info)] Kernel panic - not syncing: Fatal exception
>>   # Kernel output section end
>>   # syzbot code section start
>>   Program for #0123456789abcdef0123456789abcdef
>>   $(program_lines_for_0123456789abcdef0123456789abcdef_is_here)
>>   Program for #456789abcdef0123456789abcdef0123
>>   $(program_lines_for_456789abcdef0123456789abcdef0123_is_here)
>>   Program for #89abcdef0123456789abcdef01234567
>>   $(program_lines_for_89abcdef0123456789abcdef01234567_is_here)
>>   # syzbot code section end
>>
> 

-------------------- Current output --------------------
[  938.184721][T10912] F2FS-fs (loop0): Magic Mismatch, valid(0xf2f52010) - read(0x0)
[  938.193080][T10912] F2FS-fs (loop0): Can't find valid F2FS filesystem in 2th superblock
[  938.202030][T10912] F2FS-fs (loop0): Magic Mismatch, valid(0xf2f52010) - read(0x0)
[  938.210375][T10912] F2FS-fs (loop0): Can't find valid F2FS filesystem in 1th superblock
22:37:55 executing program 4:
r0 = syz_open_dev$sg(&(0x7f0000000040)='/dev/sg#\x00', 0x0, 0x2)
write$binfmt_elf64(r0, &(0x7f0000000340)=ANY=[@ANYBLOB="7f454c460000040000000000000000000000d40000004800000000000000000000000000000000001cca000000e4"], 0x2e)

[  938.275686][T10912] F2FS-fs (loop0): Magic Mismatch, valid(0xf2f52010) - read(0x0)
[  938.300740][T10912] F2FS-fs (loop0): Can't find valid F2FS filesystem in 2th superblock
22:37:55 executing program 3:
bpf$PROG_LOAD(0x5, &(0x7f000000d000)={0xe, 0x3, &(0x7f0000008000)=@framed={{0xffffff85, 0x0, 0x0, 0x0, 0x7, 0x64, 0x4c000000}}, &(0x7f0000000200)='7R\xec\x1f\x83\"\x8e@\xb7Ec\x80!\xe8\x98\xb9\x0fc\x1e\xf9\x04`\x0e\x963kU\xd5:\n\x86\xfc\f`v\x92\xa0F\xa6R\xd10a\v7\x8cA\xd5taZ\xa8\x15\xb164\xd0\x98\xacm\x1c\x15\x8e}\xa9~\a?\x01\xbe\xfe\x04\f\xd2\x8b#A\x84J\x87\x02o\xb4\xd7\xaa\x83\xda\xfe\xfc\xf57\x90\xe0D\xcd\xd1Z\xe9\x99-\x82\xd0\'\a{\xe4\xef\x85\x83\xadJ\x8f\x88\xdeDH@\\\xea\xc4>\xc4\"\xdcl\a\x00\x00\x00\x00\x00\x00J\x88g\x1c\x19\xe52\xa2\x98\x06j8@iV\xb6Z\xdbR{,\xed\x05\x00c\xa5\xc8\x8fF\xd2\a\x11\xcdC1k\x8b\xb4[\xb16\xa6a\xe2\xe7\x8d\x88\x8d\xa8:\xc1\xcb\b', 0x2, 0x1074, &(0x7f0000014000)=""/4096, 0x0, 0x0, [0x3f000000]}, 0x48)

22:37:55 executing program 1:
r0 = openat$proc_capi20(0xffffffffffffff9c, &(0x7f0000000000)='/proc/capi/capi20\x00', 0x0, 0x0)
ioctl$FS_IOC_SETFSLABEL(r0, 0x41009432, &(0x7f0000000140)="a7e66891b3c4503a1061c17727c1d522854b5b6493f286a24a29c4741f0e38eef3c3f9843d3a0c490f0bb1e7d2d609accfefa8227ac2a7a79ae00d7c6f696bcd50d24eff01b9368c754ef748fe352124ced7d38607ec80d03d3ce497a5d65ef83da9366e221f7b509516091fb311b69319947307836405776778f944826f7364999fbc557e3d3a27e73b463ee362329e8d62294e51036508bb382c7830a2d4c728a3bfabeb544e0f3672a5019c9bc03bcd69c2e62721aabcc02386c74fd1e793610011348c794e5cee9763e05f0d3220e2da70007bd337bf4b1463c390ffb10611e8d0335e0ab726d63a4fc3dc3e16d18b536b6f8fc2d178c300d26ae9358d67")
ioctl$TIOCCONS(r0, 0x541d)
setsockopt$inet_MCAST_JOIN_GROUP(r0, 0x0, 0x2a, &(0x7f0000000040)={0x1, {{0x2, 0x4e23, @multicast1}}}, 0x88)
read$FUSE(r0, 0x0, 0xfffffffffffffe69)

[  938.449693][T10937] sg_write: data in/out 262108/4 bytes for SCSI command 0x0-- guessing data in;
[  938.449693][T10937]    program syz-executor4 not setting count and/or reply_len properly
22:37:56 executing program 2:
r0 = syz_open_procfs(0xffffffffffffffff, &(0x7f00000000c0)='oom_adj\x00')
exit(0x0)
preadv(r0, &(0x7f0000001600), 0x0, 0x0)
ioctl$FS_IOC_SETVERSION(r0, 0x40087602, &(0x7f0000000000)=0x20)

22:37:56 executing program 0:
socketpair$unix(0x1, 0x1, 0x0, &(0x7f0000000100)={0xffffffffffffffff, <r0=>0xffffffffffffffff})
syz_mount_image$f2fs(&(0x7f0000000180)='f2fs\x00', &(0x7f00000001c0)='./file0\x00', 0x3d04, 0x0, 0x0, 0x4, &(0x7f0000002380)={[{@norecovery='norecovery'}, {@data_flush='data_flush'}, {@four_active_logs='active_logs=4'}, {@quota='quota'}, {@lazytime='lazytime'}, {@usrjquota={'usrjquota', 0x3d, 'security.SMACK64TRANSMUTE\x00'}}, {@jqfmt_vfsold='jqfmt=vfsold'}, {@discard='discard'}, {@jqfmt_vfsv0='jqfmt=vfsv0'}], [{@defcontext={'defcontext', 0x3d, 'system_u'}}, {@appraise='appraise'}, {@subj_role={'subj_role', 0x3d, '@\xb0#posix_acl_access'}}, {@dont_measure='dont_measure'}]})
ioctl$PERF_EVENT_IOC_ENABLE(r0, 0x8912, 0x400200)

22:37:56 executing program 1:
r0 = openat$proc_capi20(0xffffffffffffff9c, &(0x7f0000000000)='/proc/capi/capi20\x00', 0x0, 0x0)
getsockopt$inet_sctp_SCTP_MAX_BURST(r0, 0x84, 0x14, &(0x7f0000000080)=@assoc_value={<r1=>0x0}, &(0x7f00000000c0)=0x8)
getsockopt$inet_sctp_SCTP_GET_PEER_ADDR_INFO(r0, 0x84, 0xf, &(0x7f0000000100)={r1, @in={{0x2, 0x4e21, @multicast2}}, 0xfffffffffffff177, 0x9, 0xd9e, 0x4, 0x100}, &(0x7f00000001c0)=0x98)
read$FUSE(r0, 0x0, 0x0)
setsockopt$inet6_tcp_TCP_QUEUE_SEQ(r0, 0x6, 0x15, &(0x7f0000000040)=0x7fffffff, 0x4)

22:37:56 executing program 4:
r0 = syz_open_dev$sg(&(0x7f0000000040)='/dev/sg#\x00', 0x0, 0x2)
write$binfmt_elf64(r0, &(0x7f0000000340)=ANY=[@ANYBLOB="7f454c460000040000000000000000000000d40000004c00000000000000000000000000000000001cca000000e4"], 0x2e)

22:37:56 executing program 3:
bpf$PROG_LOAD(0x5, &(0x7f000000d000)={0xe, 0x3, &(0x7f0000008000)=@framed={{0xffffff85, 0x0, 0x0, 0x0, 0x7, 0x64, 0x4c000000}}, &(0x7f0000000200)='7R\xec\x1f\x83\"\x8e@\xb7Ec\x80!\xe8\x98\xb9\x0fc\x1e\xf9\x04`\x0e\x963kU\xd5:\n\x86\xfc\f`v\x92\xa0F\xa6R\xd10a\v7\x8cA\xd5taZ\xa8\x15\xb164\xd0\x98\xacm\x1c\x15\x8e}\xa9~\a?\x01\xbe\xfe\x04\f\xd2\x8b#A\x84J\x87\x02o\xb4\xd7\xaa\x83\xda\xfe\xfc\xf57\x90\xe0D\xcd\xd1Z\xe9\x99-\x82\xd0\'\a{\xe4\xef\x85\x83\xadJ\x8f\x88\xdeDH@\\\xea\xc4>\xc4\"\xdcl\a\x00\x00\x00\x00\x00\x00J\x88g\x1c\x19\xe52\xa2\x98\x06j8@iV\xb6Z\xdbR{,\xed\x05\x00c\xa5\xc8\x8fF\xd2\a\x11\xcdC1k\x8b\xb4[\xb16\xa6a\xe2\xe7\x8d\x88\x8d\xa8:\xc1\xcb\b', 0x2, 0x1074, &(0x7f0000014000)=""/4096, 0x0, 0x0, [0x40000000]}, 0x48)

22:37:56 executing program 3:
bpf$PROG_LOAD(0x5, &(0x7f000000d000)={0xe, 0x3, &(0x7f0000008000)=@framed={{0xffffff85, 0x0, 0x0, 0x0, 0x7, 0x64, 0x4c000000}}, &(0x7f0000000200)='7R\xec\x1f\x83\"\x8e@\xb7Ec\x80!\xe8\x98\xb9\x0fc\x1e\xf9\x04`\x0e\x963kU\xd5:\n\x86\xfc\f`v\x92\xa0F\xa6R\xd10a\v7\x8cA\xd5taZ\xa8\x15\xb164\xd0\x98\xacm\x1c\x15\x8e}\xa9~\a?\x01\xbe\xfe\x04\f\xd2\x8b#A\x84J\x87\x02o\xb4\xd7\xaa\x83\xda\xfe\xfc\xf57\x90\xe0D\xcd\xd1Z\xe9\x99-\x82\xd0\'\a{\xe4\xef\x85\x83\xadJ\x8f\x88\xdeDH@\\\xea\xc4>\xc4\"\xdcl\a\x00\x00\x00\x00\x00\x00J\x88g\x1c\x19\xe52\xa2\x98\x06j8@iV\xb6Z\xdbR{,\xed\x05\x00c\xa5\xc8\x8fF\xd2\a\x11\xcdC1k\x8b\xb4[\xb16\xa6a\xe2\xe7\x8d\x88\x8d\xa8:\xc1\xcb\b', 0x2, 0x1074, &(0x7f0000014000)=""/4096, 0x0, 0x0, [0x43000000]}, 0x48)

22:37:56 executing program 4:
r0 = syz_open_dev$sg(&(0x7f0000000040)='/dev/sg#\x00', 0x0, 0x2)
write$binfmt_elf64(r0, &(0x7f0000000340)=ANY=[@ANYBLOB="7f454c460000040000000000000000000000d40000006800000000000000000000000000000000001cca000000e4"], 0x2e)

[  939.167542][T10956] F2FS-fs (loop0): Magic Mismatch, valid(0xf2f52010) - read(0x0)
22:37:56 executing program 1:
r0 = openat$proc_capi20(0xffffffffffffff9c, &(0x7f0000000000)='/proc/capi/capi20\x00', 0x0, 0x0)
read$FUSE(r0, 0x0, 0x0)
setsockopt$IPT_SO_SET_ADD_COUNTERS(r0, 0x0, 0x41, &(0x7f0000000140)=ANY=[@ANYBLOB="6e61740000000000000000000000000000000000001842000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005810f528769d7fe60000000000000000000000000000000000000000000000080000000000000000000000000000000000008f93902e54bd6eee49bc89d5b50eb7c3e052d70064eef4bf3662c39f4d2a02ff3b3ea9b3ff0966d2295abf3525052e464025ac0019bf93103e68000222fd35d68a327e56f5ad1b43412cb6247787f783ea08e94f7d1ec55d6597df55dee150eb05600937a9e13d2afaac2edc72736559068a6f1d"], 0x78)
prctl$PR_GET_NAME(0x10, &(0x7f0000000040)=""/119)

[  939.214806][T10956] F2FS-fs (loop0): Can't find valid F2FS filesystem in 1th superblock
[  939.276518][T10956] F2FS-fs (loop0): Magic Mismatch, valid(0xf2f52010) - read(0x0)
[  939.285099][T10956] F2FS-fs (loop0): Can't find valid F2FS filesystem in 2th superblock
[  939.336812][T10956] F2FS-fs (loop0): Magic Mismatch, valid(0xf2f52010) - read(0x0)
[  939.377329][T10956] F2FS-fs (loop0): Can't find valid F2FS filesystem in 1th superblock
[  939.411893][T10956] F2FS-fs (loop0): Magic Mismatch, valid(0xf2f52010) - read(0x0)
[  939.425615][T10956] F2FS-fs (loop0): Can't find valid F2FS filesystem in 2th superblock
[  942.734545][ T1043] ------------[ cut here ]------------
[  942.740643][ T1043] kernel BUG at mm/page_alloc.c:3112!
[  942.746017][ T1043] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
[  942.752096][ T1043] CPU: 0 PID: 1043 Comm: kcompactd0 Not tainted 5.0.0-rc2-next-20190116 #13
[  942.760748][ T1043] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
[  942.770806][ T1043] RIP: 0010:__isolate_free_page+0x4a8/0x680
[  942.776697][ T1043] Code: 4c 39 e3 77 c0 0f b6 8d 74 ff ff ff b8 01 00 00 00 48 d3 e0 e9 11 fd ff ff 48 c7 c6 a0 65 52 88 4c 89 e7 e8 6a 14 10 00 0f 0b <0f> 0b 48 c7 c6 c0 66 52 88 4c 89 e7 e8 57 14 10 00 0f 0b 48 89 cf
[  942.796291][ T1043] RSP: 0018:ffff8880a783ef58 EFLAGS: 00010003
[  942.802345][ T1043] RAX: 0000000020000080 RBX: 0000000000000000 RCX: ffff88812fffc7e0
[  942.810304][ T1043] RDX: 1ffff11025fff8fc RSI: 0000000000000008 RDI: ffff88812fffc7b0
[  942.818281][ T1043] RBP: ffff8880a783f018 R08: ffff8880a78c8000 R09: ffffed1014f07df2
[  942.826243][ T1043] R10: ffffed1014f07df1 R11: 0000000000000003 R12: ffff88812fffc7b0
[  942.834209][ T1043] R13: 1ffff11014f07df2 R14: ffff88812fffc7b0 R15: ffff8880a783eff0
[  942.842182][ T1043] FS:  0000000000000000(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
[  942.851103][ T1043] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  942.857681][ T1043] CR2: 000000c4313a9410 CR3: 0000000009871000 CR4: 00000000001406f0
[  942.865657][ T1043] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  942.873614][ T1043] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  942.881587][ T1043] Call Trace:
[  942.884872][ T1043]  ? lock_release+0xc40/0xc40
[  942.889544][ T1043]  ? rwlock_bug.part.0+0x90/0x90
[  942.894489][ T1043]  ? zone_watermark_ok+0x1b0/0x1b0
[  942.899589][ T1043]  ? trace_hardirqs_on+0xbd/0x310
[  942.904619][ T1043]  ? kasan_check_read+0x11/0x20
[  942.909464][ T1043]  compaction_alloc+0xd05/0x2970
-------------------- Current output --------------------

-------------------- My suggested output --------------------
[  938.184721][T10912] F2FS-fs (loop0): Magic Mismatch, valid(0xf2f52010) - read(0x0)
[  938.193080][T10912] F2FS-fs (loop0): Can't find valid F2FS filesystem in 2th superblock
[  938.202030][T10912] F2FS-fs (loop0): Magic Mismatch, valid(0xf2f52010) - read(0x0)
[  938.210375][T10912] F2FS-fs (loop0): Can't find valid F2FS filesystem in 1th superblock
[  938.XXXXXX][ T$pid] 22:37:55 executing program #01234567:
[  938.275686][T10912] F2FS-fs (loop0): Magic Mismatch, valid(0xf2f52010) - read(0x0)
[  938.300740][T10912] F2FS-fs (loop0): Can't find valid F2FS filesystem in 2th superblock
[  938.XXXXXX][ T$pid] 22:37:55 executing program #12345678:
[  938.XXXXXX][ T$pid] 22:37:55 executing program #23456789:
[  938.449693][T10937] sg_write: data in/out 262108/4 bytes for SCSI command 0x0-- guessing data in;
[  938.449693][T10937]    program syz-executor4 not setting count and/or reply_len properly
[  939.XXXXXX][ T$pid] 22:37:56 executing program #3456789a:
[  939.XXXXXX][ T$pid] 22:37:56 executing program #456789ab:
[  939.XXXXXX][ T$pid] 22:37:56 executing program #56789abc:
[  939.XXXXXX][ T$pid] 22:37:56 executing program #6789abcd:
[  939.XXXXXX][ T$pid] 22:37:56 executing program #789abcde:
[  939.XXXXXX][ T$pid] 22:37:56 executing program #89abcdef:
[  939.XXXXXX][ T$pid] 22:37:56 executing program #9abcdef0:
[  939.167542][T10956] F2FS-fs (loop0): Magic Mismatch, valid(0xf2f52010) - read(0x0)
[  939.XXXXXX][ T$pid] 22:37:56 executing program #abcdef01:
[  939.214806][T10956] F2FS-fs (loop0): Can't find valid F2FS filesystem in 1th superblock
[  939.276518][T10956] F2FS-fs (loop0): Magic Mismatch, valid(0xf2f52010) - read(0x0)
[  939.285099][T10956] F2FS-fs (loop0): Can't find valid F2FS filesystem in 2th superblock
[  939.336812][T10956] F2FS-fs (loop0): Magic Mismatch, valid(0xf2f52010) - read(0x0)
[  939.377329][T10956] F2FS-fs (loop0): Can't find valid F2FS filesystem in 1th superblock
[  939.411893][T10956] F2FS-fs (loop0): Magic Mismatch, valid(0xf2f52010) - read(0x0)
[  939.425615][T10956] F2FS-fs (loop0): Can't find valid F2FS filesystem in 2th superblock
[  942.734545][ T1043] ------------[ cut here ]------------
[  942.740643][ T1043] kernel BUG at mm/page_alloc.c:3112!
[  942.746017][ T1043] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
[  942.752096][ T1043] CPU: 0 PID: 1043 Comm: kcompactd0 Not tainted 5.0.0-rc2-next-20190116 #13
[  942.760748][ T1043] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
[  942.770806][ T1043] RIP: 0010:__isolate_free_page+0x4a8/0x680
[  942.776697][ T1043] Code: 4c 39 e3 77 c0 0f b6 8d 74 ff ff ff b8 01 00 00 00 48 d3 e0 e9 11 fd ff ff 48 c7 c6 a0 65 52 88 4c 89 e7 e8 6a 14 10 00 0f 0b <0f> 0b 48 c7 c6 c0 66 52 88 4c 89 e7 e8 57 14 10 00 0f 0b 48 89 cf
[  942.796291][ T1043] RSP: 0018:ffff8880a783ef58 EFLAGS: 00010003
[  942.802345][ T1043] RAX: 0000000020000080 RBX: 0000000000000000 RCX: ffff88812fffc7e0
[  942.810304][ T1043] RDX: 1ffff11025fff8fc RSI: 0000000000000008 RDI: ffff88812fffc7b0
[  942.818281][ T1043] RBP: ffff8880a783f018 R08: ffff8880a78c8000 R09: ffffed1014f07df2
[  942.826243][ T1043] R10: ffffed1014f07df1 R11: 0000000000000003 R12: ffff88812fffc7b0
[  942.834209][ T1043] R13: 1ffff11014f07df2 R14: ffff88812fffc7b0 R15: ffff8880a783eff0
[  942.842182][ T1043] FS:  0000000000000000(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
[  942.851103][ T1043] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  942.857681][ T1043] CR2: 000000c4313a9410 CR3: 0000000009871000 CR4: 00000000001406f0
[  942.865657][ T1043] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  942.873614][ T1043] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  942.881587][ T1043] Call Trace:
[  942.884872][ T1043]  ? lock_release+0xc40/0xc40
[  942.889544][ T1043]  ? rwlock_bug.part.0+0x90/0x90
[  942.894489][ T1043]  ? zone_watermark_ok+0x1b0/0x1b0
[  942.899589][ T1043]  ? trace_hardirqs_on+0xbd/0x310
[  942.904619][ T1043]  ? kasan_check_read+0x11/0x20
[  942.909464][ T1043]  compaction_alloc+0xd05/0x2970

Program for #01234567
r0 = syz_open_dev$sg(&(0x7f0000000040)='/dev/sg#\x00', 0x0, 0x2)
write$binfmt_elf64(r0, &(0x7f0000000340)=ANY=[@ANYBLOB="7f454c460000040000000000000000000000d40000004800000000000000000000000000000000001cca000000e4"], 0x2e)

Program for #12345678
bpf$PROG_LOAD(0x5, &(0x7f000000d000)={0xe, 0x3, &(0x7f0000008000)=@framed={{0xffffff85, 0x0, 0x0, 0x0, 0x7, 0x64, 0x4c000000}}, &(0x7f0000000200)='7R\xec\x1f\x83\"\x8e@\xb7Ec\x80!\xe8\x98\xb9\x0fc\x1e\xf9\x04`\x0e\x963kU\xd5:\n\x86\xfc\f`v\x92\xa0F\xa6R\xd10a\v7\x8cA\xd5taZ\xa8\x15\xb164\xd0\x98\xacm\x1c\x15\x8e}\xa9~\a?\x01\xbe\xfe\x04\f\xd2\x8b#A\x84J\x87\x02o\xb4\xd7\xaa\x83\xda\xfe\xfc\xf57\x90\xe0D\xcd\xd1Z\xe9\x99-\x82\xd0\'\a{\xe4\xef\x85\x83\xadJ\x8f\x88\xdeDH@\\\xea\xc4>\xc4\"\xdcl\a\x00\x00\x00\x00\x00\x00J\x88g\x1c\x19\xe52\xa2\x98\x06j8@iV\xb6Z\xdbR{,\xed\x05\x00c\xa5\xc8\x8fF\xd2\a\x11\xcdC1k\x8b\xb4[\xb16\xa6a\xe2\xe7\x8d\x88\x8d\xa8:\xc1\xcb\b', 0x2, 0x1074, &(0x7f0000014000)=""/4096, 0x0, 0x0, [0x3f000000]}, 0x48)

Program for #23456789
r0 = openat$proc_capi20(0xffffffffffffff9c, &(0x7f0000000000)='/proc/capi/capi20\x00', 0x0, 0x0)
ioctl$FS_IOC_SETFSLABEL(r0, 0x41009432, &(0x7f0000000140)="a7e66891b3c4503a1061c17727c1d522854b5b6493f286a24a29c4741f0e38eef3c3f9843d3a0c490f0bb1e7d2d609accfefa8227ac2a7a79ae00d7c6f696bcd50d24eff01b9368c754ef748fe352124ced7d38607ec80d03d3ce497a5d65ef83da9366e221f7b509516091fb311b69319947307836405776778f944826f7364999fbc557e3d3a27e73b463ee362329e8d62294e51036508bb382c7830a2d4c728a3bfabeb544e0f3672a5019c9bc03bcd69c2e62721aabcc02386c74fd1e793610011348c794e5cee9763e05f0d3220e2da70007bd337bf4b1463c390ffb10611e8d0335e0ab726d63a4fc3dc3e16d18b536b6f8fc2d178c300d26ae9358d67")
ioctl$TIOCCONS(r0, 0x541d)
setsockopt$inet_MCAST_JOIN_GROUP(r0, 0x0, 0x2a, &(0x7f0000000040)={0x1, {{0x2, 0x4e23, @multicast1}}}, 0x88)
read$FUSE(r0, 0x0, 0xfffffffffffffe69)

Program for #3456789a
r0 = syz_open_procfs(0xffffffffffffffff, &(0x7f00000000c0)='oom_adj\x00')
exit(0x0)
preadv(r0, &(0x7f0000001600), 0x0, 0x0)
ioctl$FS_IOC_SETVERSION(r0, 0x40087602, &(0x7f0000000000)=0x20)

Program for #456789ab
socketpair$unix(0x1, 0x1, 0x0, &(0x7f0000000100)={0xffffffffffffffff, <r0=>0xffffffffffffffff})
syz_mount_image$f2fs(&(0x7f0000000180)='f2fs\x00', &(0x7f00000001c0)='./file0\x00', 0x3d04, 0x0, 0x0, 0x4, &(0x7f0000002380)={[{@norecovery='norecovery'}, {@data_flush='data_flush'}, {@four_active_logs='active_logs=4'}, {@quota='quota'}, {@lazytime='lazytime'}, {@usrjquota={'usrjquota', 0x3d, 'security.SMACK64TRANSMUTE\x00'}}, {@jqfmt_vfsold='jqfmt=vfsold'}, {@discard='discard'}, {@jqfmt_vfsv0='jqfmt=vfsv0'}], [{@defcontext={'defcontext', 0x3d, 'system_u'}}, {@appraise='appraise'}, {@subj_role={'subj_role', 0x3d, '@\xb0#posix_acl_access'}}, {@dont_measure='dont_measure'}]})
ioctl$PERF_EVENT_IOC_ENABLE(r0, 0x8912, 0x400200)

Program for #56789abc
r0 = openat$proc_capi20(0xffffffffffffff9c, &(0x7f0000000000)='/proc/capi/capi20\x00', 0x0, 0x0)
getsockopt$inet_sctp_SCTP_MAX_BURST(r0, 0x84, 0x14, &(0x7f0000000080)=@assoc_value={<r1=>0x0}, &(0x7f00000000c0)=0x8)
getsockopt$inet_sctp_SCTP_GET_PEER_ADDR_INFO(r0, 0x84, 0xf, &(0x7f0000000100)={r1, @in={{0x2, 0x4e21, @multicast2}}, 0xfffffffffffff177, 0x9, 0xd9e, 0x4, 0x100}, &(0x7f00000001c0)=0x98)
read$FUSE(r0, 0x0, 0x0)
setsockopt$inet6_tcp_TCP_QUEUE_SEQ(r0, 0x6, 0x15, &(0x7f0000000040)=0x7fffffff, 0x4)

Program for #6789abcd
r0 = syz_open_dev$sg(&(0x7f0000000040)='/dev/sg#\x00', 0x0, 0x2)
write$binfmt_elf64(r0, &(0x7f0000000340)=ANY=[@ANYBLOB="7f454c460000040000000000000000000000d40000004c00000000000000000000000000000000001cca000000e4"], 0x2e)

Program for #789abcde
bpf$PROG_LOAD(0x5, &(0x7f000000d000)={0xe, 0x3, &(0x7f0000008000)=@framed={{0xffffff85, 0x0, 0x0, 0x0, 0x7, 0x64, 0x4c000000}}, &(0x7f0000000200)='7R\xec\x1f\x83\"\x8e@\xb7Ec\x80!\xe8\x98\xb9\x0fc\x1e\xf9\x04`\x0e\x963kU\xd5:\n\x86\xfc\f`v\x92\xa0F\xa6R\xd10a\v7\x8cA\xd5taZ\xa8\x15\xb164\xd0\x98\xacm\x1c\x15\x8e}\xa9~\a?\x01\xbe\xfe\x04\f\xd2\x8b#A\x84J\x87\x02o\xb4\xd7\xaa\x83\xda\xfe\xfc\xf57\x90\xe0D\xcd\xd1Z\xe9\x99-\x82\xd0\'\a{\xe4\xef\x85\x83\xadJ\x8f\x88\xdeDH@\\\xea\xc4>\xc4\"\xdcl\a\x00\x00\x00\x00\x00\x00J\x88g\x1c\x19\xe52\xa2\x98\x06j8@iV\xb6Z\xdbR{,\xed\x05\x00c\xa5\xc8\x8fF\xd2\a\x11\xcdC1k\x8b\xb4[\xb16\xa6a\xe2\xe7\x8d\x88\x8d\xa8:\xc1\xcb\b', 0x2, 0x1074, &(0x7f0000014000)=""/4096, 0x0, 0x0, [0x40000000]}, 0x48)

Program for #89abcdef
bpf$PROG_LOAD(0x5, &(0x7f000000d000)={0xe, 0x3, &(0x7f0000008000)=@framed={{0xffffff85, 0x0, 0x0, 0x0, 0x7, 0x64, 0x4c000000}}, &(0x7f0000000200)='7R\xec\x1f\x83\"\x8e@\xb7Ec\x80!\xe8\x98\xb9\x0fc\x1e\xf9\x04`\x0e\x963kU\xd5:\n\x86\xfc\f`v\x92\xa0F\xa6R\xd10a\v7\x8cA\xd5taZ\xa8\x15\xb164\xd0\x98\xacm\x1c\x15\x8e}\xa9~\a?\x01\xbe\xfe\x04\f\xd2\x8b#A\x84J\x87\x02o\xb4\xd7\xaa\x83\xda\xfe\xfc\xf57\x90\xe0D\xcd\xd1Z\xe9\x99-\x82\xd0\'\a{\xe4\xef\x85\x83\xadJ\x8f\x88\xdeDH@\\\xea\xc4>\xc4\"\xdcl\a\x00\x00\x00\x00\x00\x00J\x88g\x1c\x19\xe52\xa2\x98\x06j8@iV\xb6Z\xdbR{,\xed\x05\x00c\xa5\xc8\x8fF\xd2\a\x11\xcdC1k\x8b\xb4[\xb16\xa6a\xe2\xe7\x8d\x88\x8d\xa8:\xc1\xcb\b', 0x2, 0x1074, &(0x7f0000014000)=""/4096, 0x0, 0x0, [0x43000000]}, 0x48)

Program for #9abcdef0
r0 = syz_open_dev$sg(&(0x7f0000000040)='/dev/sg#\x00', 0x0, 0x2)
write$binfmt_elf64(r0, &(0x7f0000000340)=ANY=[@ANYBLOB="7f454c460000040000000000000000000000d40000006800000000000000000000000000000000001cca000000e4"], 0x2e)

Program for #abcdef01
r0 = openat$proc_capi20(0xffffffffffffff9c, &(0x7f0000000000)='/proc/capi/capi20\x00', 0x0, 0x0)
read$FUSE(r0, 0x0, 0x0)
setsockopt$IPT_SO_SET_ADD_COUNTERS(r0, 0x0, 0x41, &(0x7f0000000140)=ANY=[@ANYBLOB="6e61740000000000000000000000000000000000001842000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005810f528769d7fe60000000000000000000000000000000000000000000000080000000000000000000000000000000000008f93902e54bd6eee49bc89d5b50eb7c3e052d70064eef4bf3662c39f4d2a02ff3b3ea9b3ff0966d2295abf3525052e464025ac0019bf93103e68000222fd35d68a327e56f5ad1b43412cb6247787f783ea08e94f7d1ec55d6597df55dee150eb05600937a9e13d2afaac2edc72736559068a6f1d"], 0x78)
prctl$PR_GET_NAME(0x10, &(0x7f0000000040)=""/119)
-------------------- My suggested output --------------------
