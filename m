Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28F12C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:16:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB5E620644
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:16:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB5E620644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FB178E0003; Mon, 29 Jul 2019 04:16:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AD588E0002; Mon, 29 Jul 2019 04:16:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79A0A8E0003; Mon, 29 Jul 2019 04:16:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 607238E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 04:16:01 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id x17so66337896iog.8
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:16:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=0rPakemNyIs9fbLrhB6s/ulRRU21c/3n0kSBtdCA0Eo=;
        b=brtnKYpSHg1iZT+Q/Ifi4UdR6mM8gHTSVxIudHuSbq6L5u+I5bayasfmh5CXkXotfE
         XaMJaL3jOUHLbLQdSKASNsMjmrDKfUxx6Fh8zimGdyEAzc9RMXmC0r+al3Vru6DGCvHF
         5Yg4SN3JeerYTPFX+0g1tghR7S9Q8qoAXb6lDKdUwu9i42KIzZgLwSEAhdpi7fdPT0LW
         BLJXUkhsjzq6zDjxJlKYIG/A4HslySDPXOHp3sMTEPxXje/2fOgeyRVxLU8jfxFy8G1o
         tkcVEoXkhnhC0WpxPFDsgbBGG2DMBN2BKblDEg2x8GGuYcaF1G30kqxuivJF10NZOxNk
         AdFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3qks-xqkbaiex34pfqqjwfuuni.lttlqjzxjwhtsyjsy.htr@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3QKs-XQkbAIEx34pfqqjwfuuni.lttlqjzxjwhtsyjsy.htr@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAV9r4qhdlJIuNTcHgUH1rvVkARbdqbDZ5sXYgfNpT6kHfdpSyM9
	7bTGTPtqRRPkUoETvshzdVwiUQedbg1Bi0CXApKV5NMY1KSFSHWfC0rhsEQX8OYd3jIP7qrUPAl
	wfsNOnLMrcXuf3J9H0JZ6dAdyqC46OWSuFNab3h9FDiGbiKtYS9kHAI4nCyWvntk=
X-Received: by 2002:a6b:ba88:: with SMTP id k130mr96454044iof.212.1564388161165;
        Mon, 29 Jul 2019 01:16:01 -0700 (PDT)
X-Received: by 2002:a6b:ba88:: with SMTP id k130mr96454012iof.212.1564388160534;
        Mon, 29 Jul 2019 01:16:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564388160; cv=none;
        d=google.com; s=arc-20160816;
        b=Zwvxk9tjlV5RlrtdarzieRgaAdeWM+6Ps9JXhS18mZIG37p1gV6CFCqYFt7tA6U22W
         +aLkzSBAF6sFpYI/udG61Jkqqj37oLZyberFLIRUgtGHVSaCdpb1X94DCZyZFOALviRQ
         4g/19y2ZPi+VdA0JsIeBN6bkruNFW9gO2d4rBhKBm6ODIf//EtVk31DZbbJjV2xUfe4I
         mJ7XvtATTo1w+qdlMx8CSSN2EMHLPNRlgpgfeWqPIhuFcbodT8TftZ0LXkQdFVyFhFnM
         F31DoSkVlUt+ZswZNJx7vmr9QTt5QFQQ6AhAdcmTrbZd0g1ERKR9iR65KNYRs6k5Gfti
         PYMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=0rPakemNyIs9fbLrhB6s/ulRRU21c/3n0kSBtdCA0Eo=;
        b=WbvhSQBW6QAdSqC6YDUURVD81Oe3sNP1VQ/GgN0dDiBLmMa2VNvv4WuFaHAoohaGYF
         IzuyYlEMED9UVKHU4xXtm0zAx7p2WVIXpU97RYrxdek+tYdaOi45gwwnOevEg4deQfjX
         0qwPUqO7+aX/yTi1FyMp7gS1+UftllxP3VnVoqaMCKB9Hq+6NWcnMy3+8uHulKhRWQha
         NLwtCbuX+DJ1dhqLkt+qg02/8C91LE/OU+u/L4ea7R2lrmGpU9Gve/w6Y/sBKkmYcQpX
         lD9zDA52VDDpAbSvZEIQ5wEab3ZeZd3cF4NkajQgu9HCVpLA+XWjFu/mQvpVSm1RJ7aS
         nL9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3qks-xqkbaiex34pfqqjwfuuni.lttlqjzxjwhtsyjsy.htr@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3QKs-XQkbAIEx34pfqqjwfuuni.lttlqjzxjwhtsyjsy.htr@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id m66sor41452878iof.144.2019.07.29.01.16.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 01:16:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3qks-xqkbaiex34pfqqjwfuuni.lttlqjzxjwhtsyjsy.htr@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3qks-xqkbaiex34pfqqjwfuuni.lttlqjzxjwhtsyjsy.htr@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3QKs-XQkbAIEx34pfqqjwfuuni.lttlqjzxjwhtsyjsy.htr@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqxSkxuHca0jLTiQmdMdnlp+TfywXlCfVmn/nxBSNrXe+PgHcKdxjXDq/A4yJcJjcL3n5aaCmQIspC/xzgAeN42nGa5pW21x
MIME-Version: 1.0
X-Received: by 2002:a5d:994b:: with SMTP id v11mr53971532ios.165.1564388160200;
 Mon, 29 Jul 2019 01:16:00 -0700 (PDT)
Date: Mon, 29 Jul 2019 01:16:00 -0700
In-Reply-To: <0000000000005718ef058b3a0fcf@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000094699a058ecd8017@google.com>
Subject: Re: memory leak in __nf_hook_entries_try_shrink
From: syzbot <syzbot+c51f73e78e7e2ce3a31e@syzkaller.appspotmail.com>
To: catalin.marinas@arm.com, coreteam@netfilter.org, davem@davemloft.net, 
	deller@gmx.de, fw@strlen.de, jejb@parisc-linux.org, kadlec@blackhole.kfki.hu, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-parisc@vger.kernel.org, mingo@redhat.com, netdev@vger.kernel.org, 
	netfilter-devel@vger.kernel.org, pablo@netfilter.org, rostedt@goodmis.org, 
	syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit fc79168a7c75423047d60a033dc4844955ccae0b
Author: Helge Deller <deller@gmx.de>
Date:   Wed Apr 13 20:44:54 2016 +0000

     parisc: Add syscall tracepoint support

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=16ad2cd8600000
start commit:   b076173a Merge tag 'selinux-pr-20190612' of git://git.kern..
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=15ad2cd8600000
console output: https://syzkaller.appspot.com/x/log.txt?x=11ad2cd8600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=cb38d33cd06d8d48
dashboard link: https://syzkaller.appspot.com/bug?extid=c51f73e78e7e2ce3a31e
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=105a958ea00000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=103c758ea00000

Reported-by: syzbot+c51f73e78e7e2ce3a31e@syzkaller.appspotmail.com
Fixes: fc79168a7c75 ("parisc: Add syscall tracepoint support")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

