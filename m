Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AF53C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:59:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF4E62183F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:59:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF4E62183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 469226B0278; Thu, 18 Apr 2019 05:59:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41C8A6B0279; Thu, 18 Apr 2019 05:59:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30B7A6B027A; Thu, 18 Apr 2019 05:59:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB526B0278
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:59:02 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id a64so1758280ith.0
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:59:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=VuebU8UkmIRaDiaZ1fyCf6Tqc3AJax52IMQPWDXFyYI=;
        b=IbtFpMp+PEyIwkGUavsMcl2ciG1OexALtAYOzAFc/wlHiuxFi3ieNPV/sKLFDH8W7K
         8+uHUYxvTrBegetw30pCRpOkslwazowqxYywIUo9+UGki6e7rmTLIhCcPs+XWIbWr0CA
         X+EvXYTd7w0L83g9SG2+nY75E5ubu3eyLhbn2mNI+lNbDhH7pVPSguGE5H9Bqg8Q2xYA
         PDs2c4PC9kYbpSF4dyH/gbtAJHi0JNBPBeCrSlabaqaHPW13O7qJRZCRMO8go+LIu11y
         t09JL/7ZhOOAfrx26ivsmf+WLqbSTBGmm6lxzMrmISnAG2r8OiXVc1LcGRaQ2pVBDqGU
         Xofw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3zeq4xakbamu39avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3ZEq4XAkbAMU39Avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAUQKgFLhjRV4Qu5+fU74uw/v6afDLdwGTSiEIK5AH5BXSAaHKwl
	i+x4rNLZOouy3hlwy8HCV8pqZKZPFKDbY+3KRszsOx9n8IF4mnQccm5LXYx+Aes1EPtWjh0lHdy
	0sdXkl7220GQS2bh+VA+xyukICiOJwaVhVzi5HQpacl08pfT0BkIvAk1dKiMHsr8=
X-Received: by 2002:a6b:e202:: with SMTP id z2mr22422509ioc.6.1555581541788;
        Thu, 18 Apr 2019 02:59:01 -0700 (PDT)
X-Received: by 2002:a6b:e202:: with SMTP id z2mr22422482ioc.6.1555581540995;
        Thu, 18 Apr 2019 02:59:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555581540; cv=none;
        d=google.com; s=arc-20160816;
        b=UbpjYeNPxv/IUEhu9hk6UsXnK8gmXGrpifoGY1OBX4zFFtfzD11ob99Rv2JgB8rYly
         dvANwibdPY/uR2qeauBp3PZ9hw086LrdvcVK8OZCHV4H+1m6YJH7MGKtiduqeVvw+yFI
         /KmRpHYssgKgjHrhqPhQymUxK5F9dkNKjVxJl7wYegmnto4lb7jeCF68BzYhNn5nulUb
         A2k2lIAFRvvN1EzwJBrYda9vje+ldcbfOvUlImfq7MmSeoqkaYAcixmx4qKy+v/5PehX
         TX/D3ximQGwz35Viw8cBHFHFG4cX4t1rjkRRgVJvF2vPk1keiJ2ts9HPeeTsefRrLwe2
         EsiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=VuebU8UkmIRaDiaZ1fyCf6Tqc3AJax52IMQPWDXFyYI=;
        b=ePS9g8YyeJmpkgEpuBV34gi0+0XivR4Ak7Gk3ke8kSON6qGW6r5ir94vVqwcGFMODe
         b3kB4ne4uVqgMMLwfhStpTxSy1hFW+ISZhhrRbVl/rtGKBZG0Id6VExy86evafM/A63h
         VOQHvJXajfVL700rLxxEzfhfos/dkQdNvKTd+wJQ9A5fNaZ2roQruFx4qR/J2saIdnOz
         dkY1Y3qpcue0pSsPLa3hARna5ZUJ9FzaEyg4J9jhJb892D+GyNqEbTBZ6zc33GS2yJCf
         r+0p4F3R3pHUePKqVaa48gGwswmGPhLM5pXjg7WcpHw4whOQIXo3YXKVKO+M6ZkmhetL
         HAxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3zeq4xakbamu39avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3ZEq4XAkbAMU39Avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id n133sor796989iod.100.2019.04.18.02.59.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 02:59:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3zeq4xakbamu39avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3zeq4xakbamu39avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3ZEq4XAkbAMU39Avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqxuguFF8FFR1m22eGEJb+0aWhIdhdSN3LOyfQ8EbAbAyGoX9sVIQFN5fC7AqwMqDcOvQERrrrEgHjXPT6FjVwoRV42Yw1lQ
MIME-Version: 1.0
X-Received: by 2002:a6b:188:: with SMTP id 130mr2185721iob.115.1555581540713;
 Thu, 18 Apr 2019 02:59:00 -0700 (PDT)
Date: Thu, 18 Apr 2019 02:59:00 -0700
In-Reply-To: <000000000000c770710586c6fc92@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000274d750586cb0d38@google.com>
Subject: Re: BUG: unable to handle kernel paging request in free_block (5)
From: syzbot <syzbot+438a5abd4f53adb1c073@syzkaller.appspotmail.com>
To: davem@davemloft.net, jon.maloy@ericsson.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, netdev@vger.kernel.org, syzkaller-bugs@googlegroups.com, 
	tipc-discussion@lists.sourceforge.net, ying.xue@windriver.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit 52dfae5c85a4c1078e9f1d5e8947d4a25f73dd81
Author: Jon Maloy <jon.maloy@ericsson.com>
Date:   Thu Mar 22 19:42:52 2018 +0000

     tipc: obtain node identity from interface by default

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=15065bdd200000
start commit:   e6986423 socket: fix compat SO_RCVTIMEO_NEW/SO_SNDTIMEO_NEW
git tree:       net
final crash:    https://syzkaller.appspot.com/x/report.txt?x=17065bdd200000
console output: https://syzkaller.appspot.com/x/log.txt?x=13065bdd200000
kernel config:  https://syzkaller.appspot.com/x/.config?x=4fb64439e07a1ec0
dashboard link: https://syzkaller.appspot.com/bug?extid=438a5abd4f53adb1c073
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12adddbf200000

Reported-by: syzbot+438a5abd4f53adb1c073@syzkaller.appspotmail.com
Fixes: 52dfae5c85a4 ("tipc: obtain node identity from interface by default")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

