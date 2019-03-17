Return-Path: <SRS0=9bJk=RU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 033DBC43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 20:49:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95D4C2087C
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 20:49:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95D4C2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 083AA6B0005; Sun, 17 Mar 2019 16:49:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 034896B0006; Sun, 17 Mar 2019 16:49:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E66C06B0007; Sun, 17 Mar 2019 16:49:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE1D66B0005
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 16:49:02 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id y6so10533278itj.5
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 13:49:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=AdDJQGRn1HKxzvaNiNMtuUjAUxpN+UvUqzicULcWxYI=;
        b=B42UuTs4tXXF44XEXXWY4Eb4vewEodw/WewsajaTqz6LJPPT2ZuwIPwAkO0VeXoJkL
         YbKvYaRf8lTuXpVuQ7OPPu9tMKNXNQwA2wqZdq9W7KLT1dnizHOzLAcBHiDO2CZw58Rd
         K29MPritZ4UyXguc18e1mPVk11nBronSFkDvwwBSyAmtZNjIMoth0bfWzX86F1GBNse0
         6rK3Eg1soH7WM6Tmy8tdjCPOiTAmhLX0gAiAmGwt9ActSWKp0fvreL4Xdi6xKKBAMzIo
         AKABRJwjaUfgBeye3MWUT0uj3hc2ZgB4j6f7hme9oTs9XpNyRdUmyEFaSB+mO9zNh+BN
         N+fw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3vbkoxakbaeg289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3vbKOXAkbAEg289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAXK7icI8DClW9RznOI2Z17Zl70ADGnU+XjHoeZ3YqT7qOvdaQZc
	70QqnPb2odm2Uvj/ppLp9wPONXztBWpV5ugsUTyPotp+5Qrs2b9QhbCiw0ys7p0b2b4JsODjTcv
	XKv0S9kZWi+StZ42WKO3Fgqf544qA9zaPV6h37+UV3TVUyJj7pDKXQmRRjc8jot0=
X-Received: by 2002:a24:4643:: with SMTP id j64mr8089366itb.74.1552855742542;
        Sun, 17 Mar 2019 13:49:02 -0700 (PDT)
X-Received: by 2002:a24:4643:: with SMTP id j64mr8089349itb.74.1552855741732;
        Sun, 17 Mar 2019 13:49:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552855741; cv=none;
        d=google.com; s=arc-20160816;
        b=S7TMkYJK0mj4DA/pxYukN/TMBIv3XOE+jW6jvWGR2cEoX31qiHaeX0bes1TLwO+wQX
         7i78OO2GoM4U9RHyHGtdCT43RvEdvg7lg8sO7F7tDhiPtRVJktvUFATVcNK1cUcRpNLY
         dcvWUpPDx2FTktut33NzFw9ILxgIpCvblobtHjW+TabG4smG0CW47ZVRIjfPFgTFlr7/
         QMv9pqA1IWAf4oOOY3uvkaAC0Gx0UlIfY1s3XvWbRp5x32TGB3oMfoLpg75RdCp232K1
         pYswwgPnmAfwNRdXEMe+6VTNDBrYGEvOFLMZbWu5lLVpPaYf76f8JrHBeI0v3rn3zhFH
         eP5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=AdDJQGRn1HKxzvaNiNMtuUjAUxpN+UvUqzicULcWxYI=;
        b=ImbNKRp2e+iwH357gtDYwqAL5ZRgByt1a8aZ+Ad1Cb5/J+mUNszdC0fe3ixuERh8wG
         J7cejoi692cUlvuZIgtbaHDOxZh/N1PjlAQM7f+Xs0cAydnEuWfmYHw23LU0bRRtYoIp
         PdIOOrLF9ZanAO6rOyeOsgTweUVQO0qipL5nx0VpFlWondiJ1qKf8HdKoiZPtzffk3KE
         ldDbF4+xSnop+oVnpZqHP5OrDN3OvDx4E5RjzQpRqTxDiPyvGgJkF4zHa+eZlv+SVAU+
         gz4IHXLTP/UJPJIE1J5RuJWXl6QvolGf7m1oEXpjrddeTQayf9V7IKFY3lR6sldursla
         GwgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3vbkoxakbaeg289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3vbKOXAkbAEg289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id p4sor10117313jab.5.2019.03.17.13.49.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Mar 2019 13:49:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3vbkoxakbaeg289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3vbkoxakbaeg289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3vbKOXAkbAEg289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqxojhExD56b/yMGdo1rthu1JsRKBbq+nglPXYMv7KIAn0A7lR9LfGenfJEuOvhjcVopDkkpLBAFNpERS8o441NA3SoXY50Q
MIME-Version: 1.0
X-Received: by 2002:a02:3f1d:: with SMTP id d29mr8708325jaa.4.1552855741444;
 Sun, 17 Mar 2019 13:49:01 -0700 (PDT)
Date: Sun, 17 Mar 2019 13:49:01 -0700
In-Reply-To: <000000000000b05d0c057e492e33@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000db3d130584506672@google.com>
Subject: Re: kernel panic: corrupted stack end in wb_workfn
From: syzbot <syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com, cai@lca.pw, 
	davem@davemloft.net, dvyukov@google.com, guro@fb.com, hannes@cmpxchg.org, 
	jbacik@fb.com, ktkhai@virtuozzo.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, linux-sctp@vger.kernel.org, mgorman@techsingularity.net, 
	mhocko@suse.com, netdev@vger.kernel.org, nhorman@tuxdriver.com, 
	shakeelb@google.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, 
	vyasevich@gmail.com, willy@infradead.org
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000021, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit c981f254cc82f50f8cb864ce6432097b23195b9c
Author: Al Viro <viro@zeniv.linux.org.uk>
Date:   Sun Jan 7 18:19:09 2018 +0000

     sctp: use vmemdup_user() rather than badly open-coding memdup_user()

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=137bcecf200000
start commit:   c981f254 sctp: use vmemdup_user() rather than badly open-c..
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=10fbcecf200000
console output: https://syzkaller.appspot.com/x/log.txt?x=177bcecf200000
kernel config:  https://syzkaller.appspot.com/x/.config?x=5e7dc790609552d7
dashboard link: https://syzkaller.appspot.com/bug?extid=ec1b7575afef85a0e5ca
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=16a9a84b400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17199bb3400000

Reported-by: syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com
Fixes: c981f254 ("sctp: use vmemdup_user() rather than badly open-coding  
memdup_user()")

