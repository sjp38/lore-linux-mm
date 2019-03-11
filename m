Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A443C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:33:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1637D2063F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:33:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1637D2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A10C38E0003; Mon, 11 Mar 2019 13:33:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C1708E0002; Mon, 11 Mar 2019 13:33:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D6FE8E0003; Mon, 11 Mar 2019 13:33:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 660628E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:33:02 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id v12so5656746itv.9
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 10:33:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=isauicIveizh2Thnf2HeFHmP4eOsW9wt5monXQQBqYA=;
        b=XtjtvawCLPQMqXB9KRSyEYteoLzl8+xPuclXvla+XRttPZWxgvDJFisFAp8o3yC8dW
         dfqXeHQVMunHzwkF1RdsUKvIst0YGuyBuhYzE55hHPVuR1+sFIR+/LaBIF3eHP2+ctv+
         cHmVD/Dag58FWTOzPFZSSZknq/m9w9jU17qqfNti5acSs6o62YinrKIDI72WK7SGGoz7
         fpsx9hspsTnCAZCXRZjSVwQ+vLzbbvf/JfdaVPV9SllVFrgOFs3CXKl8Vl17f2tbLbOW
         Eau79DwPedp9Mmrv7ZFiZ+92PgCmyotxrSIw+PXJ6heQdzLkdkkplyQQy7bKEwTtfQOX
         qehw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3zjugxakbaak178tjuun0jyyrm.pxxpun31n0lxw2nw2.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3zJuGXAkbAAk178tjuun0jyyrm.pxxpun31n0lxw2nw2.lxv@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAWtx50sOj4FTNpjL0aBIyYb7rrWhB3S6GBZXytTYoKBd6MBpMiS
	XaVAS4FzPqrYHBRO6NXSeK28GJ6tHxojIxIoPfMsQUu/ylCD7pxx8urxjnls/2fSlUUfJ1svNY9
	7lFD7WDjZ5UWrhxGfo31xN1GEzHr1PY/VKbBqDn/Q+XyNmIfL3NLEqFu8Y4JrSrqX+oleot9B4d
	uRG/QaWLGA4NQ9Ki6xX1IVe1QIjtcxnlLcaHjdwnb+9tQLy87aVK8huE4KPjKTp/3W/rseP30KA
	enpAIDx98Fc0Chf/1euTCCJluV9U1upeGmo7Ktwx7EPR1FdH5yeMS4avVKic0ZO8hK1T8en9Fc+
	zqPHBL9GUkuGC1A8xLUgsSfhzU2B2vXQ4A5G+vPRV4XFTDFUk0Lv0bShM4VHmM/s2YfdqnwhsA=
	=
X-Received: by 2002:a5d:85d9:: with SMTP id e25mr19349112ios.31.1552325582196;
        Mon, 11 Mar 2019 10:33:02 -0700 (PDT)
X-Received: by 2002:a5d:85d9:: with SMTP id e25mr19349058ios.31.1552325581270;
        Mon, 11 Mar 2019 10:33:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552325581; cv=none;
        d=google.com; s=arc-20160816;
        b=S9f+fBFnrfS8lXp4iKHxVgqqVgrdo8WRT4F5F2svoPWqzCfxZhwYyjp2WKQvJEApK/
         Xhk54n6SzLvuunG0cyW83xUjjiKUU92sibdjfmE7RTTG+GEigB/By+L7LFTCHputTUd/
         f4vTZ0mk6fT+PRJqGP7Mvudf8Jff+DgESUYC2GqD4SNRwHmAvvFN2XNFLN8Jj/V7PiVN
         L3uJJKbiO+irnxloegL3rQ9Yfay19793U0xBx4c30BO+h/VT2swiqMN0FK2v9eB+M4It
         P5kQr3T3d6Qavq1uTOrwRxEFyFMkoZFqWenjAmAlsqoyjaOzYIllDPtmAxTRdMQZqmd9
         /u9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=isauicIveizh2Thnf2HeFHmP4eOsW9wt5monXQQBqYA=;
        b=sLv3gpg23ZcCP7uqerWfA16QwUtHZvzR54HrQUgSsLOchWQKHiI3PSgNBv3Jt6jg20
         CebjHW2nK8LHHrtsb+HWd+kbKMJTKb4J/Ve7y3R1ng3Xrm+j/EGy/eY2Udc+Y3VWSaof
         YbGmUuGIHeOyzH7Z/SyXIWbVX6W/1K4W6LvNfluKPlC4w/m/141od2wLc1/Ymd57lPpG
         BAPL9BjNumnWNTCnU8am7OJTdP2ed4yDeADRykgwERj8DBYXVJLa3MgAaou9feFMoFiC
         oZKVt1zCOSRt5gI7jvWtCuufPiv7EKvImjTmQ1VYCBzEq27V45ptW2CdRO6Hu0JTBgLT
         Mp2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3zjugxakbaak178tjuun0jyyrm.pxxpun31n0lxw2nw2.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3zJuGXAkbAAk178tjuun0jyyrm.pxxpun31n0lxw2nw2.lxv@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id f74sor27317533itf.11.2019.03.11.10.33.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 10:33:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3zjugxakbaak178tjuun0jyyrm.pxxpun31n0lxw2nw2.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3zjugxakbaak178tjuun0jyyrm.pxxpun31n0lxw2nw2.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3zJuGXAkbAAk178tjuun0jyyrm.pxxpun31n0lxw2nw2.lxv@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqxNHGDwxMkhRMzYJUaaRw1NG+HTbRv8/Iwq88XM8tYlVM3Bik892jQNUzBmbT5xOMWwyVBKe39zxZmaWv4+1WHoIhakjx36
MIME-Version: 1.0
X-Received: by 2002:a24:6283:: with SMTP id d125mr128441itc.14.1552325580967;
 Mon, 11 Mar 2019 10:33:00 -0700 (PDT)
Date: Mon, 11 Mar 2019 10:33:00 -0700
In-Reply-To: <0000000000004aed310583d22822@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000d458540583d4f6ef@google.com>
Subject: Re: WARNING in lockdep_unregister_key
From: syzbot <syzbot+be0c198232f86389c3dd@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, bp@alien8.de, bvanassche@acm.org, 
	dave.hansen@linux.intel.com, davem@davemloft.net, hmclauchlan@fb.com, 
	hpa@zytor.com, joe@perches.com, johan.hedberg@gmail.com, 
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, luto@kernel.org, marcel@holtmann.org, mhocko@suse.com, 
	mingo@kernel.org, netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com, 
	peterz@infradead.org, riel@surriel.com, rientjes@google.com, 
	syzkaller-bugs@googlegroups.com, tglx@linutronix.de, 
	torvalds@linux-foundation.org, will.deacon@arm.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit 009bb421b6ceb7916ce627023d0eb7ced04c8910
Author: Bart Van Assche <bvanassche@acm.org>
Date:   Sun Mar 3 22:00:46 2019 +0000

     workqueue, lockdep: Fix an alloc_workqueue() error path

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=1625a027200000
start commit:   009bb421 workqueue, lockdep: Fix an alloc_workqueue() erro..
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=1525a027200000
console output: https://syzkaller.appspot.com/x/log.txt?x=1125a027200000
kernel config:  https://syzkaller.appspot.com/x/.config?x=e9d91b7192a5e96e
dashboard link: https://syzkaller.appspot.com/bug?extid=be0c198232f86389c3dd
userspace arch: amd64
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1006dc83200000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=137d0027200000

Reported-by: syzbot+be0c198232f86389c3dd@syzkaller.appspotmail.com
Fixes: 009bb421 ("workqueue, lockdep: Fix an alloc_workqueue() error path")

