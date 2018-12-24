Return-Path: <SRS0=oA8h=PB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 622E6C65BDE
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 15:48:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E34EE21848
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 15:48:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E34EE21848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B2AC8E0002; Mon, 24 Dec 2018 10:48:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43AC48E0001; Mon, 24 Dec 2018 10:48:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DC468E0002; Mon, 24 Dec 2018 10:48:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 019D78E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 10:48:04 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id t133so13498015iof.20
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 07:48:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=3Ns/ZR8GRsrbEzZga0NBTqUr3ae0W2DBbO1xflujF7g=;
        b=QTQc3BdMb7M0dbcbax+7uI0Z7i4kpFeIhXiQOzw/M1HgD9NtdaePwmD6dr4fuqXRVW
         bTqEO+61gHsJVaJFSI16RzyKn7rSxepHon4AnIlLJ6RAUK3d+etD1ADXH956X1yWhsqE
         DC/jTntshnxNrtJem9qrMHGnL18xGPcDFRoYduCDuOClzAa7AoRoAhfF97DQ0USZDk1h
         VMsQjgAQv2PMJy4j1XlTRjB5gYHHyVF1WveQ7wTY7P4K/Y10Ta4mCm89/PCbxFJ9h1Ww
         5552CPYa0f1cdAshlQWwVPr+C5nZRLq1cqPudZMyrnz0HPyQgNuAFS2a1f73woi8vlLE
         Uv+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3s_8gxakbab4mste4ff8l4jjc7.aiiaf8om8l6ihn8hn.6ig@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3s_8gXAkbAB4MSTE4FF8L4JJC7.AIIAF8OM8L6IHN8HN.6IG@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AA+aEWYfrh25bcQtyf3H7Zc6ULD/tGSdRyswMNvEEDYkhpUnQZH6cs0r
	LywE0dI/tBy+HT8L9zDo9eqr7qLU9WZVqUcGGyiE4Yn8pq986gNX7aVGAyKJe9inQ0KrMVhV+9C
	E2vJnRjMWKaH0b9XZHMoDUwV0DDt6I2x7ioEFkomAsxZybun+5imwormjnlR+4PUanwpiJF2n4g
	n/2RitPrtGAtH8z8Z1n9oOTRrYwwUuTktK/TpI1BJ27ShbeDEZGXmZyjHktuVcPn7vvQLjfUuU9
	rNvvw6/J1PMu2ULYYL/24rPrPW2bIMKt9u1sXPjZNargwq2f4n/2OYvSnqWFcFwrx4Az2vg1hGO
	jnv0Pt9SuhOUcZPyxr2Kx7serPYBpWpUVjNjmku4bSkHWmODmrqmhuvYYKac01E8VDkssAUumQ=
	=
X-Received: by 2002:a02:b015:: with SMTP id p21mr9087728jah.17.1545666484763;
        Mon, 24 Dec 2018 07:48:04 -0800 (PST)
X-Received: by 2002:a02:b015:: with SMTP id p21mr9087689jah.17.1545666483743;
        Mon, 24 Dec 2018 07:48:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545666483; cv=none;
        d=google.com; s=arc-20160816;
        b=YIxArRzvMsZfrOWkHGfWi59TK0DbpPBdtPLsLT/0SU98yHyfn1q6Ygnxec/hYZYvFU
         KIt7tyTr1vAgteLDokRNd/61UV7XlWnLoIUqqYE5ZwknUTM4Ls8T7zdakDq/E7sznDxA
         NW+XCTEq9qeeIsq033Kd/Jfgu49Aa9+nOr6aBvaT1NsqUWgNOiGO0cpnC89fy6s9ofbw
         o6lSBCQkRO9rGMl9cu5XvY4k1bMdArC066KKuasysrYXS2g/Q31Jng7DJw+dNWdbR/v2
         jvOER533O7d7e9jTaFmrK5HP9DUydMOR5cANW1NO/NNFEHGi+dU4/K7urSL23/iSlB81
         dCOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=3Ns/ZR8GRsrbEzZga0NBTqUr3ae0W2DBbO1xflujF7g=;
        b=VPgKYiiWxLNLxqhx8ifc072LCab1SNGTwnaF+1U/opsA7ejDssrvHY6KNk8vfrvCa+
         FjPO/EDvlBP7ujEdSbjDIGtIaGPdNVXnX+U6ILjFJ1ok4E+QFk8iIF0OE5fyiqEVr3Mo
         63hFUWb8X6vUZoIboOtGRWXtp+Muzd3J0umoihLd7jM0+Zpi9IWcP2moKw4+C5Vn4G/7
         QxphiiBhKykxdRMS+INiLfDmPLL5WUcwPTMZxlzzcKxV9Z2XyRJdPPa0Po1tQ34SBPP0
         s/jAjB13RYmGYtOuSGhCT0SU31Tms8g8ebcnRK4jFGR/wLcLn/NBziYzjWI/MJVILuPP
         8JCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3s_8gxakbab4mste4ff8l4jjc7.aiiaf8om8l6ihn8hn.6ig@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3s_8gXAkbAB4MSTE4FF8L4JJC7.AIIAF8OM8L6IHN8HN.6IG@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id d26sor2209115iob.26.2018.12.24.07.48.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 07:48:03 -0800 (PST)
Received-SPF: pass (google.com: domain of 3s_8gxakbab4mste4ff8l4jjc7.aiiaf8om8l6ihn8hn.6ig@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3s_8gxakbab4mste4ff8l4jjc7.aiiaf8om8l6ihn8hn.6ig@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3s_8gXAkbAB4MSTE4FF8L4JJC7.AIIAF8OM8L6IHN8HN.6IG@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: ALg8bN4S62gTKPe/0USe0RiFIgH7mE6e95UKy/96r1As/jz4TW/LThaqPP2xRNtmKcE1azKf0Kp2izAFLNr4U/2CwP3/pt1b+jwk
MIME-Version: 1.0
X-Received: by 2002:a5e:931a:: with SMTP id k26mr1701679iom.21.1545666483335;
 Mon, 24 Dec 2018 07:48:03 -0800 (PST)
Date: Mon, 24 Dec 2018 07:48:03 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000ae384d057dc685c1@google.com>
Subject: general protection fault in transparent_hugepage_enabled
From: syzbot <syzbot+a5fea9200aefd1cf4818@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, 
	hughd@google.com, jglisse@redhat.com, khlebnikov@yandex-team.ru, 
	kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, mhocko@suse.com, rientjes@google.com, 
	sfr@canb.auug.org.au, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, 
	willy@infradead.org
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181224154803.F-hoe8ozKh60qm27HRuZ6XUcnWBIwF8GjPT8UKHwIg0@z>

Hello,

syzbot found the following crash on:

HEAD commit:    6a1d293238c1 Add linux-next specific files for 20181224
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=149a2add400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c190b602a5d2d731
dashboard link: https://syzkaller.appspot.com/bug?extid=a5fea9200aefd1cf4818
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1798bfb7400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17f4dc57400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+a5fea9200aefd1cf4818@syzkaller.appspotmail.com

sshd (6016) used greatest stack depth: 15720 bytes left
kasan: CONFIG_KASAN_INLINE enabled
kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] PREEMPT SMP KASAN
CPU: 1 PID: 6032 Comm: syz-executor045 Not tainted 4.20.0-rc7-next-20181224  
#187
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:transparent_hugepage_enabled+0x8c/0x5e0 mm/huge_memory.c:69
Code: 80 3c 02 00 0f 85 ae 04 00 00 4c 8b a3 a0 00 00 00 48 b8 00 00 00 00  
00 fc ff df 49 8d bc 24 b8 01 00 00 48 89 fa 48 c1 ea 03 <80> 3c 02 00 0f  
85 91 04 00 00 49 8b bc 24 b8 01 00 00 e8 2d 70 e6
RSP: 0018:ffff8881c2237138 EFLAGS: 00010202
RAX: dffffc0000000000 RBX: ffff8881c2bdbc60 RCX: 0000000000000000
RDX: 0000000000000037 RSI: ffffffff81c8fa1a RDI: 00000000000001b8
RBP: ffff8881c2237160 R08: ffffed10383b25ed R09: ffffed10383b25ec
R10: ffffed10383b25ec R11: ffff8881c1d92f63 R12: 0000000000000000
R13: ffff8881c2bdbd00 R14: dffffc0000000000 R15: 0000000000000f5e
FS:  0000000001a48880(0000) GS:ffff8881dad00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020b58000 CR3: 00000001c2210000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  show_smap+0x167/0x580 fs/proc/task_mmu.c:805
  traverse+0x344/0x7b0 fs/seq_file.c:113
  seq_read+0xc76/0x1150 fs/seq_file.c:188
  do_loop_readv_writev fs/read_write.c:700 [inline]
  do_iter_read+0x4bc/0x670 fs/read_write.c:924
  vfs_readv+0x175/0x1c0 fs/read_write.c:986
  kernel_readv fs/splice.c:362 [inline]
  default_file_splice_read+0x539/0xb20 fs/splice.c:417
  do_splice_to+0x12e/0x190 fs/splice.c:880
  splice_direct_to_actor+0x31c/0x9d0 fs/splice.c:957
  do_splice_direct+0x2d4/0x420 fs/splice.c:1066
  do_sendfile+0x62a/0xe50 fs/read_write.c:1439
  __do_sys_sendfile64 fs/read_write.c:1494 [inline]
  __se_sys_sendfile64 fs/read_write.c:1486 [inline]
  __x64_sys_sendfile64+0x15d/0x250 fs/read_write.c:1486
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x440089
Code: 18 89 d0 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 00 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 5b 14 fc ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007fff3d710a18 EFLAGS: 00000213 ORIG_RAX: 0000000000000028
RAX: ffffffffffffffda RBX: 00007fff3d710a20 RCX: 0000000000440089
RDX: 0000000020b58000 RSI: 0000000000000003 RDI: 0000000000000003
RBP: 00000000006ca018 R08: 0000000000000010 R09: 65732f636f72702f
R10: 000000000000ffff R11: 0000000000000213 R12: 0000000000401970
R13: 0000000000401a00 R14: 0000000000000000 R15: 0000000000000000
Modules linked in:
---[ end trace faf026efd8795e93 ]---
RIP: 0010:transparent_hugepage_enabled+0x8c/0x5e0 mm/huge_memory.c:69
Code: 80 3c 02 00 0f 85 ae 04 00 00 4c 8b a3 a0 00 00 00 48 b8 00 00 00 00  
00 fc ff df 49 8d bc 24 b8 01 00 00 48 89 fa 48 c1 ea 03 <80> 3c 02 00 0f  
85 91 04 00 00 49 8b bc 24 b8 01 00 00 e8 2d 70 e6
RSP: 0018:ffff8881c2237138 EFLAGS: 00010202
RAX: dffffc0000000000 RBX: ffff8881c2bdbc60 RCX: 0000000000000000
RDX: 0000000000000037 RSI: ffffffff81c8fa1a RDI: 00000000000001b8
RBP: ffff8881c2237160 R08: ffffed10383b25ed R09: ffffed10383b25ec
R10: ffffed10383b25ec R11: ffff8881c1d92f63 R12: 0000000000000000
R13: ffff8881c2bdbd00 R14: dffffc0000000000 R15: 0000000000000f5e
FS:  0000000001a48880(0000) GS:ffff8881dad00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020b58000 CR3: 00000001c2210000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

