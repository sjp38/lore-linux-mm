Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B6A0C49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 20:00:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5203120644
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 20:00:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="c0ymhVx5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5203120644
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1DDA6B0003; Mon, 16 Sep 2019 16:00:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCF546B0006; Mon, 16 Sep 2019 16:00:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBC776B0007; Mon, 16 Sep 2019 16:00:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0230.hostedemail.com [216.40.44.230])
	by kanga.kvack.org (Postfix) with ESMTP id AA6F46B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 16:00:15 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 2D008180AD803
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 20:00:15 +0000 (UTC)
X-FDA: 75941850390.16.hot95_21f081a8e154
X-HE-Tag: hot95_21f081a8e154
X-Filterd-Recvd-Size: 6835
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 20:00:14 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id i1so565160pfa.6
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 13:00:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=GkrRDU4n+A0mwdRr9SZP5oIS+Dn9buzlq9OjWSBq+U4=;
        b=c0ymhVx5/QZhSh4uc2bqUht0XOUXdrplY+Qinz9udzz/RGT4dQdYTF+k0Ndep7R67U
         lf7pzTYmvUq5AxJ/QgXvuXBQUDat6iaqvhMv+kV5JtcMdEineArUr5zYk3y32qtUlgBv
         7znrll+LPEAMk8LnQaD6kN5cRlDfJ38NwMXOhQILW0010Ja+5W+mbaLiE0pnDH8enyPz
         GLiHo0jQOdKTxPOi00r2X5mQUbA7tDB6dVETXVcE/o0cgk0OJNHF3AvPZvDvlFHyKRkg
         CdNfuAlvFb0wVDtCUMPcJSdC7WqCeKQw4G/sTI70yfsnzHxTl7ve7iSOxrY2C0/FubbH
         /u/Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=GkrRDU4n+A0mwdRr9SZP5oIS+Dn9buzlq9OjWSBq+U4=;
        b=rx8SOE/swCfj8LFbjNMT+MjwoL/xXZ7Gi+Dz2PuWjk92zC+PZBJLaxk+7DMMfgmLHQ
         xsLeH9p+ithLh8TXUTjJELdsCJzQkbuhWBsgAL7dbIvi5+XPxZUyR387/mkNNZTLk+a7
         0qPHhFDXJTxVcaVvR74C6s8sMaaHCQF1QFZhkh8LJ3ZqatUJuU3JFHuS40eYfFNbq5wv
         4cSSjZGON5n/GzEqRY0Rw+4QfSellSx75LTWvl/FL4voVegjnWKExz7pCHrp6TWrLzmu
         S/76cLNxDvqyyr2S4vD0eEjP/bgqx3jNTiulgXSZkpqiQSBe3jrMo7wJklPR3v5jvl5b
         Fckg==
X-Gm-Message-State: APjAAAU+7L4po/S9n6EgchGYGUk7mppC1Re07uJxizaUyL8202IVMUKu
	Qjk7jglKrx2INruVW/twt5x7lQ==
X-Google-Smtp-Source: APXvYqzzeBqfN19EkgRYHn2FKS9cRAy4ZLMoQatugO67DgdlU8I5c+fdmfBKhC6fq8aw2Tpg8JT34w==
X-Received: by 2002:a63:5a0a:: with SMTP id o10mr371691pgb.282.1568664012969;
        Mon, 16 Sep 2019 13:00:12 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id f20sm31526161pgg.56.2019.09.16.13.00.12
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 13:00:12 -0700 (PDT)
Date: Mon, 16 Sep 2019 13:00:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: syzbot <syzbot+e38fe539fedfc127987e@syzkaller.appspotmail.com>, 
    Jiri Kosina <jikos@kernel.org>, 
    Benjamin Tissoires <benjamin.tissoires@redhat.com>
cc: Andrea Arcangeli <aarcange@redhat.com>, 
    Andrew Morton <akpm@linux-foundation.org>, andreyknvl@google.com, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    linux-usb@vger.kernel.org, mhocko@suse.com, 
    syzkaller-bugs@googlegroups.com, vbabka@suse.cz, 
    yang.shi@linux.alibaba.com, zhongjiang@huawei.com
Subject: Re: WARNING in __alloc_pages_nodemask
In-Reply-To: <00000000000025ae690592b00fbd@google.com>
Message-ID: <alpine.DEB.2.21.1909161258150.118156@chino.kir.corp.google.com>
References: <00000000000025ae690592b00fbd@google.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Sep 2019, syzbot wrote:

> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    f0df5c1b usb-fuzzer: main usb gadget fuzzer driver
> git tree:       https://github.com/google/kasan.git usb-fuzzer
> console output: https://syzkaller.appspot.com/x/log.txt?x=14b15371600000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=5c6633fa4ed00be5
> dashboard link: https://syzkaller.appspot.com/bug?extid=e38fe539fedfc127987e
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1093bed1600000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=1603cfc6600000
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+e38fe539fedfc127987e@syzkaller.appspotmail.com
> 
> WARNING: CPU: 0 PID: 1720 at mm/page_alloc.c:4696
> __alloc_pages_nodemask+0x36f/0x780 mm/page_alloc.c:4696
> Kernel panic - not syncing: panic_on_warn set ...
> CPU: 0 PID: 1720 Comm: syz-executor388 Not tainted 5.3.0-rc7+ #0
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google
> 01/01/2011
> Call Trace:
> __dump_stack lib/dump_stack.c:77 [inline]
> dump_stack+0xca/0x13e lib/dump_stack.c:113
> panic+0x2a3/0x6da kernel/panic.c:219
> __warn.cold+0x20/0x4a kernel/panic.c:576
> report_bug+0x262/0x2a0 lib/bug.c:186
> fixup_bug arch/x86/kernel/traps.c:179 [inline]
> fixup_bug arch/x86/kernel/traps.c:174 [inline]
> do_error_trap+0x12b/0x1e0 arch/x86/kernel/traps.c:272
> do_invalid_op+0x32/0x40 arch/x86/kernel/traps.c:291
> invalid_op+0x23/0x30 arch/x86/entry/entry_64.S:1028
> RIP: 0010:__alloc_pages_nodemask+0x36f/0x780 mm/page_alloc.c:4696
> Code: fe ff ff 65 48 8b 04 25 00 ef 01 00 48 05 60 10 00 00 41 be 01 00 00 00
> 48 89 44 24 58 e9 ee fd ff ff 81 e5 00 20 00 00 75 02 <0f> 0b 45 31 f6 e9 6b
> ff ff ff 8b 44 24 68 89 04 24 65 8b 2d e9 7e
> RSP: 0018:ffff8881d320f9d8 EFLAGS: 00010046
> RAX: 0000000000000000 RBX: 1ffff1103a641f3f RCX: 0000000000000000
> RDX: 0000000000000000 RSI: dffffc0000000000 RDI: 0000000000040a20
> RBP: 0000000000000000 R08: ffff8881d3bcc800 R09: ffffed103a541d19
> R10: ffffed103a541d18 R11: ffff8881d2a0e8c7 R12: 0000000000000012
> R13: 0000000000000012 R14: 0000000000000000 R15: ffff8881d2a0e8c0
> alloc_pages_current+0xff/0x200 mm/mempolicy.c:2153
> alloc_pages include/linux/gfp.h:509 [inline]
> kmalloc_order+0x1a/0x60 mm/slab_common.c:1257
> kmalloc_order_trace+0x18/0x110 mm/slab_common.c:1269
> __usbhid_submit_report drivers/hid/usbhid/hid-core.c:588 [inline]
> usbhid_submit_report+0x5b5/0xde0 drivers/hid/usbhid/hid-core.c:638
> usbhid_request+0x3c/0x70 drivers/hid/usbhid/hid-core.c:1252
> hid_hw_request include/linux/hid.h:1053 [inline]
> hiddev_ioctl+0x526/0x1550 drivers/hid/usbhid/hiddev.c:735
> vfs_ioctl fs/ioctl.c:46 [inline]
> file_ioctl fs/ioctl.c:509 [inline]
> do_vfs_ioctl+0xd2d/0x1330 fs/ioctl.c:696
> ksys_ioctl+0x9b/0xc0 fs/ioctl.c:713
> __do_sys_ioctl fs/ioctl.c:720 [inline]
> __se_sys_ioctl fs/ioctl.c:718 [inline]
> __x64_sys_ioctl+0x6f/0xb0 fs/ioctl.c:718
> do_syscall_64+0xb7/0x580 arch/x86/entry/common.c:296
> entry_SYSCALL_64_after_hwframe+0x49/0xbe

Adding Jiri and Benjamin.  The hid report length is simply too large for 
the page allocator to allocate: this is triggering because the resulting 
allocation order is > MAX_ORDER-1.  Any way to make this allocate less 
physically contiguous memory?

