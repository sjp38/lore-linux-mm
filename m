Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14401C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 19:51:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBED8218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 19:51:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="lPJDV17f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBED8218AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 544888E0005; Thu, 28 Feb 2019 14:51:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F1968E0001; Thu, 28 Feb 2019 14:51:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 392648E0005; Thu, 28 Feb 2019 14:51:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 092AA8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 14:51:08 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id k13so16575591iop.0
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:51:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=FTeX9wtexJUmONEYN0mhb1P2R1Q8ukcNJMPt2XCNpAw=;
        b=b1kbaTETAz2HprrLnwenSPeWQwbWIZknJ9ZA2+a69m0Xbgz0hsY/S1zgNulq9MPXCJ
         CDxJ02iPN/U/QeRK29bQZI4jeiT2zJbuL7zl7/GbaqVykLf4gci4kGNEygB6WTL2MplS
         sCOUdUFuczfmg31K1cFQSsoKhcJR5mnlmYOJsW2D07xWJ733kXKVoungDIbXKrziZD50
         GcaBydEyKzQs6WelgomMa4++guhIY0AuQDi3pN9XDqn+8KEQY74UMrvjrKdhB/BQ//Pm
         3oQtZ1R2yllyAQIhohMU5ywRFc5SsClv9LBVrhZ933oRAh3IRrCXkCMQQN1hUbZr5So7
         J2ng==
X-Gm-Message-State: APjAAAXW2ikXzMnEuQvJ4bscDwayBKGojQsGbz99WgKxtSb6jZGNLjYD
	9quU8roB0y375RpEjRbrHf8YRxCKGV/KLap6bB3IvDtuUewBCQxehll25jBWGVYWMdbV34Po9lk
	DfIR9Ray8pIN0TxAnFdt9fidyKQASJBGgWSlhRne3C8LsWFFc0oiMXTLSxzRFOQuCFYwH1dzXWH
	yHfQ8j6KuuOBJeqyGap/B5U59PCjaPvYLcR3q/Co3Wu773a2uWyHQNmug4Z13cy5kQYuGEb9a1f
	3EsW5xm5mn5eB7A4h9xWX58lXKgoyDziKmC31tux8CLMPivPOQ13w6TF5OnDa7Zeu/Dv5fP9RgG
	dWFnCl/TJIvzapbx+07bIsZf9ndbhLqP4dVQLSNhy9wx6ETW2D8BcsTSsg/6N9zk/lHlHIBtT0x
	m
X-Received: by 2002:a24:10c4:: with SMTP id 187mr944763ity.31.1551383467681;
        Thu, 28 Feb 2019 11:51:07 -0800 (PST)
X-Received: by 2002:a24:10c4:: with SMTP id 187mr944728ity.31.1551383466703;
        Thu, 28 Feb 2019 11:51:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551383466; cv=none;
        d=google.com; s=arc-20160816;
        b=dKDzu1c96SGGxWdJTc2lt5slfNH0wYdsEc4HUpHbarlPcgOPo0mT96x5wfXv8jgT71
         mbbExEKGQogGZNC8pGl6sE6mLb+BIx17anX8/6jWGU8VOTqVxuwjXYBoUodNMA7pXLJ4
         krWkna+VglOWiYOd6SxLigLIbD3ZGY6xZBl/0jAWICCe5TMMVB5DXxhEo2uM4w8E73wX
         QCCxMZeCYZcov1saAb58zsHztdlzUf4j3w4nnfa4/KGKAEC5XxYjiBoxMZTQS4kQVDHR
         7xMtVsXMoA8go80MW4Lyn+Zb4IwfF03TQgd6Jys5J1tD2VITh2wROo3r5aQ12q56TwbB
         juhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=FTeX9wtexJUmONEYN0mhb1P2R1Q8ukcNJMPt2XCNpAw=;
        b=UwvfBvScD3wL/zglsuhrftsMUtyNy3AIdKdssnqIfoj0jqt2j3pgG4f0MnCWgWnAFe
         GuHZkwR+ALmcbFJF7tVM/FOyeHNQtq3PTEDorN+C96bycUlm/evnQujlfxwPvVrgTwzf
         brJvhfQiAD9ab7LP/OOATsHewhFmpp2p3jmvHy6CwsOMGwFkJReDxNv31t/34Q/q7cSh
         VLjhHKx/3V2IAN498xhynUNnC/LNCriSs3iGqqHrvlomdc4XshV8zER1IZMKl0oNKpao
         WbN0gDRtp5TsUdDsgun0NGc6c0chZxF6wJj3HCr+k3tU3MumMJXANwo6YOK0Ly0zXPdl
         i4oA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=lPJDV17f;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l2sor9304559iop.108.2019.02.28.11.51.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 11:51:06 -0800 (PST)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=lPJDV17f;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=FTeX9wtexJUmONEYN0mhb1P2R1Q8ukcNJMPt2XCNpAw=;
        b=lPJDV17fql2nEQ+oC5eqt4EvoutxiCesnKXyQ309QI7ub6Chnwv8xpqYFbnphspQ+l
         pj34VG58ikCTPDxeAlDDOMc4x/aDXpxa5Uc0OeVKGZ4JXNzbzqcvYiHTIHLrk8GB/u9x
         FUoftdUkwixa/WJPJNM/+W4UPb2l61X9AcFWFhsg4PTtGm2MpHcMGrr5t2ipiu1B+4/W
         2YMLNShbImVYhKLJ1uEnLL2r6vbbeAicanbJoN9h6BJyAMrs1rKGErwfwVdWi/qQQv/j
         lXxtfVcIhjIod1mffgxxmfhe+i/Awtx+zw1deIUylEVnkHWnGPMp9bZNTo77zFZYCUR1
         s8gQ==
X-Google-Smtp-Source: APXvYqxexOt5MFJowBTSc1xmFKwuaxTNzSVJFBfEZYribyNCD3lojUNg02Tfk+MTMakGTC72gjh1kQ==
X-Received: by 2002:a5e:9b0e:: with SMTP id j14mr666800iok.35.1551383466202;
        Thu, 28 Feb 2019 11:51:06 -0800 (PST)
Received: from [192.168.1.158] ([216.160.245.98])
        by smtp.gmail.com with ESMTPSA id t68sm3332555ita.4.2019.02.28.11.51.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 11:51:04 -0800 (PST)
Subject: Re: BUG: Bad page state (6)
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Eric Biggers <ebiggers@kernel.org>,
 syzbot <syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com>,
 Andrew Morton <akpm@linux-foundation.org>, arunks@codeaurora.org,
 Dan Williams <dan.j.williams@intel.com>, Lance Roy <ldr709@gmail.com>,
 LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 Michal Hocko <mhocko@suse.com>, nborisov@suse.com,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
 Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>,
 yuehaibing@huawei.com
References: <00000000000024b3aa0582f1cde7@google.com>
 <CACT4Y+byrcaasUaEJj=hcemEEBBkon=VC24gPwGXHzfeRP0E3w@mail.gmail.com>
 <20190228174250.GB663@sol.localdomain>
 <54e34bcb-7de7-4488-cead-3ea3a2b71ed7@kernel.dk>
 <CACT4Y+Zy4uY+guS3ZBZAtg-ES5-351mKSOfKxpZySafur+XvCw@mail.gmail.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <918aa0a6-09dd-7a4a-8de0-fda3d0855c38@kernel.dk>
Date: Thu, 28 Feb 2019 12:51:02 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Zy4uY+guS3ZBZAtg-ES5-351mKSOfKxpZySafur+XvCw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/28/19 10:53 AM, Dmitry Vyukov wrote:
> On Thu, Feb 28, 2019 at 6:51 PM Jens Axboe <axboe@kernel.dk> wrote:
>>
>> On 2/28/19 10:42 AM, Eric Biggers wrote:
>>> On Thu, Feb 28, 2019 at 11:36:21AM +0100, 'Dmitry Vyukov' via syzkaller-bugs wrote:
>>>> On Thu, Feb 28, 2019 at 11:32 AM syzbot
>>>> <syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com> wrote:
>>>>>
>>>>> Hello,
>>>>>
>>>>> syzbot found the following crash on:
>>>>>
>>>>> HEAD commit:    42fd8df9d1d9 Add linux-next specific files for 20190228
>>>>> git tree:       linux-next
>>>>> console output: https://syzkaller.appspot.com/x/log.txt?x=179ba9e0c00000
>>>>> kernel config:  https://syzkaller.appspot.com/x/.config?x=c0f38652d28b522f
>>>>> dashboard link: https://syzkaller.appspot.com/bug?extid=6f5a9b79b75b66078bf0
>>>>> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
>>>>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12ed6bd0c00000
>>>>> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=10690c8ac00000
>>>>>
>>>>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>>>>> Reported-by: syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com
>>>>
>>>> +Jens, Eric,
>>>>
>>>> Looks similar to:
>>>> https://groups.google.com/forum/#!msg/syzkaller-bugs/E3v3XQweVBw/6BPrkIYJIgAJ
>>>> Perhaps the fixing commit is not in the build yet?
>>>>
>>>>
>>>>> BUG: Bad page state in process syz-executor193  pfn:9225a
>>>>> page:ffffea0002489680 count:0 mapcount:0 mapping:ffff88808652fd80 index:0x81
>>>>> shmem_aops
>>>>> name:"memfd:cgroup2"
>>>>> flags: 0x1fffc000008000e(referenced|uptodate|dirty|swapbacked)
>>>>> raw: 01fffc000008000e ffff88809277fac0 ffff88809277fac0 ffff88808652fd80
>>>>> raw: 0000000000000081 0000000000000000 00000000ffffffff 0000000000000000
>>>>> page dumped because: non-NULL mapping
>>>>> Modules linked in:
>>>>> CPU: 0 PID: 7659 Comm: syz-executor193 Not tainted 5.0.0-rc8-next-20190228
>>>>> #45
>>>>> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
>>>>> Google 01/01/2011
>>>>> Call Trace:
>>>>>   __dump_stack lib/dump_stack.c:77 [inline]
>>>>>   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
>>>>>   bad_page.cold+0xda/0xff mm/page_alloc.c:586
>>>>>   free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1013
>>>>>   free_pages_check mm/page_alloc.c:1022 [inline]
>>>>>   free_pages_prepare mm/page_alloc.c:1112 [inline]
>>>>>   free_pcp_prepare mm/page_alloc.c:1137 [inline]
>>>>>   free_unref_page_prepare mm/page_alloc.c:3001 [inline]
>>>>>   free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3070
>>>>>   release_pages+0x60d/0x1940 mm/swap.c:794
>>>>>   pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
>>>>>   activate_page_drain mm/swap.c:297 [inline]
>>>>>   lru_add_drain_cpu+0x3b1/0x520 mm/swap.c:596
>>>>>   lru_add_drain+0x20/0x60 mm/swap.c:647
>>>>>   exit_mmap+0x290/0x530 mm/mmap.c:3134
>>>>>   __mmput kernel/fork.c:1047 [inline]
>>>>>   mmput+0x15f/0x4c0 kernel/fork.c:1068
>>>>>   exit_mm kernel/exit.c:546 [inline]
>>>>>   do_exit+0x816/0x2fa0 kernel/exit.c:863
>>>>>   do_group_exit+0x135/0x370 kernel/exit.c:980
>>>>>   __do_sys_exit_group kernel/exit.c:991 [inline]
>>>>>   __se_sys_exit_group kernel/exit.c:989 [inline]
>>>>>   __x64_sys_exit_group+0x44/0x50 kernel/exit.c:989
>>>>>   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
>>>>>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
>>>>> RIP: 0033:0x442a58
>>>>> Code: 00 00 be 3c 00 00 00 eb 19 66 0f 1f 84 00 00 00 00 00 48 89 d7 89 f0
>>>>> 0f 05 48 3d 00 f0 ff ff 77 21 f4 48 89 d7 44 89 c0 0f 05 <48> 3d 00 f0 ff
>>>>> ff 76 e0 f7 d8 64 41 89 01 eb d8 0f 1f 84 00 00 00
>>>>> RSP: 002b:00007ffe99e2faf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
>>>>> RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000442a58
>>>>> RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
>>>>> RBP: 00000000004c2468 R08: 00000000000000e7 R09: ffffffffffffffd0
>>>>> R10: 0000000002000005 R11: 0000000000000246 R12: 0000000000000001
>>>>> R13: 00000000006d4180 R14: 0000000000000000 R15: 0000000000000000
>>>>>
>>>>>
>>>>> ---
>>>>> This bug is generated by a bot. It may contain errors.
>>>>> See https://goo.gl/tpsmEJ for more information about syzbot.
>>>>> syzbot engineers can be reached at syzkaller@googlegroups.com.
>>>>>
>>>>> syzbot will keep track of this bug report. See:
>>>>> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
>>>>> syzbot.
>>>>> syzbot can test patches for this bug, for details see:
>>>>> https://goo.gl/tpsmEJ#testing-patches
>>>>>
>>>>> --
>>>>> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
>>>>> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
>>>>> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/00000000000024b3aa0582f1cde7%40google.com.
>>>>> For more options, visit https://groups.google.com/d/optout.
>>>>
>>>> --
>>>> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
>>>> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
>>>> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/CACT4Y%2BbyrcaasUaEJj%3DhcemEEBBkon%3DVC24gPwGXHzfeRP0E3w%40mail.gmail.com.
>>>> For more options, visit https://groups.google.com/d/optout.
>>>
>>> It bisects down to the same patch ("block: implement bio helper to add iter bvec
>>> pages to bio") so apparently it's just still broken despite Jens' fix.
>>>
>>> BTW, as this is trivially bisectable with the reproducer, I still don't see why
>>> syzbot can't do the bisection itself and use get_maintainer.pl on the broken
>>> patch to actually send the report to the right person:
>>>
>>> $ ./scripts/get_maintainer.pl 0001-block-implement-bio-helper-to-add-iter-bvec-pages-to.patch
>>> Jens Axboe <axboe@kernel.dk> (maintainer:BLOCK LAYER)
>>> linux-block@vger.kernel.org (open list:BLOCK LAYER)
>>> linux-kernel@vger.kernel.org (open list)
>>>
>>> Spamming unrelated lists and maintainers not only prevents the bug from being
>>> fixed, but it also reduces the average usefulness of syzbot reports which
>>> teaches people to ignore them.
>>
>> Huh, weird. Where's the reproducer for this one?
> 
> Under the "C reproducer" link.

This doesn't reproduce for me, but I think that's because there was a
bug in the mp_bvec_for_each_page() helper. I merged a fix for it this
morning, should be fine after that.

-- 
Jens Axboe

