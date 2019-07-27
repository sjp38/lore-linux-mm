Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 360B8C7618B
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 10:16:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A3EC20840
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 10:16:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A3EC20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96C7B8E0003; Sat, 27 Jul 2019 06:16:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91D398E0002; Sat, 27 Jul 2019 06:16:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85A108E0003; Sat, 27 Jul 2019 06:16:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 652B48E0002
	for <linux-mm@kvack.org>; Sat, 27 Jul 2019 06:16:01 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id c5so61217715iom.18
        for <linux-mm@kvack.org>; Sat, 27 Jul 2019 03:16:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=x2XPPyWw+kTQEvjXcX/vC5JNb6a5vMqFuiwlUWd2Kag=;
        b=Dk/GK0H8hlRfCpMvugHJDpRhX1qtTdhXM5MMqhJ6cVDtXvjAS0KMgzocb0D8BQV19C
         yZep8wMuwO9bYkANifyRC5UN2bPqblUrJX9qpRAHOjZ8PUik/jZpL5bHvsIp4bwEMc0A
         XEvogKrqOq6IS6NAbS+2Lxf2fn3Ez8ttcYd6ilOO3mqKFizEHB5mQKQ0ICrQ4hCWdxyX
         RA2PkcsLcTIM+5agy1ZZMe2NpKb6ROf1b4METSrwzA7Ms2qDp2jmPEG7wY7Gf0hfIuWH
         ARBArW3QZ2X7/0O9lougr0a8Jv2z1aOIUR7W7mgoRuQTloaCBlWly8/pAbOpddWXW9Yp
         DXgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3ycq8xqkbaik5bcxnyyr4n22vq.t11tyr75r4p106r06.p1z@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3YCQ8XQkbAIk5BCxnyyr4n22vq.t11tyr75r4p106r06.p1z@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAVvt50tDfXf69ksNNYDMOeIRABvATV4ApgoOziPzbQspJENndzG
	uKvRVP3A6WFMKWgqGbJrDwUuW4MQb9wkN25pu9ZhtkN2EUy+IC3SfYuyEcih/BKyWFLV+hvhhKG
	AWqYIIxi31+uciWiPtfDgpNkRVVDra+w6EUWWk46eZQEF/xs+HaTxjvLN4+52ajI=
X-Received: by 2002:a5e:9304:: with SMTP id k4mr6028940iom.206.1564222561174;
        Sat, 27 Jul 2019 03:16:01 -0700 (PDT)
X-Received: by 2002:a5e:9304:: with SMTP id k4mr6028906iom.206.1564222560550;
        Sat, 27 Jul 2019 03:16:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564222560; cv=none;
        d=google.com; s=arc-20160816;
        b=VBmKD+jx+DvAvOofCn0uIF6YlE+snzhcoO566ncFP4o+z3CNTUaH3uwk2AghkqQYX+
         S8jlMEJD6PwXt6u2lhtB4noGgyrvxzXdz1jUTHwRjwwBiwrww3WeMGuKzMsrp0iFPR5H
         tFTalCxEfkPzCzNf4mANCHUdrtigVURaA6U4qBRWs9P90C2qBZBsvwraNeWwKYgy1G73
         MI9lC+JnTjpw2U+C4/T9ZDnjX8wxoP+qPqY0xZggKDojjtodXxm1RLAnuVk0J13hDBoo
         zxgQZsYYAmwWgLG/Z/eXVTJpb9Upl90swZVa+hLuqIeq5QvnnrwLWzEbVWaCC/3oCoJx
         +Ccg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=x2XPPyWw+kTQEvjXcX/vC5JNb6a5vMqFuiwlUWd2Kag=;
        b=JVchOeW5ribDJ1EQw/DCJYd5bPvlaDlTxN13KzCup82ziHtOwMcdMaMMZCk2zXTbN+
         PWCRvM+1dt8Z49aYgdqLIAfWHooF91TawIZ18hznpaOPQlNZ2BDmI0LwhVhTfPlpeRwn
         Ye52eXoQuJbDceyGqJ6SUTInK8YPidAYPLQS5EPK+CSHOwNwsh92reQujftsjPsIKhAF
         SJPqgrdAXfNeUO3/QO1+xwHnaM452ly5nq/t8DG97tb7/DOQZLPLyZVl6HNWfJQ1+0Sw
         gSr6opQtZeNXm9AU7UajlrWvdq1l88USO7k2dEgGTWt+bDRCI1w7YTctX+3/4LLIq72k
         MbHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3ycq8xqkbaik5bcxnyyr4n22vq.t11tyr75r4p106r06.p1z@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3YCQ8XQkbAIk5BCxnyyr4n22vq.t11tyr75r4p106r06.p1z@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id k7sor38735545iol.66.2019.07.27.03.16.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 27 Jul 2019 03:16:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ycq8xqkbaik5bcxnyyr4n22vq.t11tyr75r4p106r06.p1z@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3ycq8xqkbaik5bcxnyyr4n22vq.t11tyr75r4p106r06.p1z@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3YCQ8XQkbAIk5BCxnyyr4n22vq.t11tyr75r4p106r06.p1z@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqyUUXRwrDhv+Q8VwK3XJ+lyMBkXhuGvc/B+mH+HMjh06Rq3S9TIzl2shA7qpymnG5hvTqwSBsZorpk8Y0tjAKx1u9bCuJWS
MIME-Version: 1.0
X-Received: by 2002:a5d:994b:: with SMTP id v11mr46002856ios.165.1564222560256;
 Sat, 27 Jul 2019 03:16:00 -0700 (PDT)
Date: Sat, 27 Jul 2019 03:16:00 -0700
In-Reply-To: <000000000000111cbe058dc7754d@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000000dc874058ea6f261@google.com>
Subject: Re: memory leak in new_inode_pseudo (2)
From: syzbot <syzbot+e682cca30bc101a4d9d9@syzkaller.appspotmail.com>
To: axboe@fb.com, axboe@kernel.dk, catalin.marinas@arm.com, 
	davem@davemloft.net, linux-block@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, michaelcallahan@fb.com, 
	netdev@vger.kernel.org, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000446, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit a21f2a3ec62abe2e06500d6550659a0ff5624fbb
Author: Michael Callahan <michaelcallahan@fb.com>
Date:   Tue May 3 15:12:49 2016 +0000

     block: Minor blk_account_io_start usage cleanup

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=13565e92600000
start commit:   be8454af Merge tag 'drm-next-2019-07-16' of git://anongit...
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=10d65e92600000
console output: https://syzkaller.appspot.com/x/log.txt?x=17565e92600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=d23a1a7bf85c5250
dashboard link: https://syzkaller.appspot.com/bug?extid=e682cca30bc101a4d9d9
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=155c5800600000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=1738f800600000

Reported-by: syzbot+e682cca30bc101a4d9d9@syzkaller.appspotmail.com
Fixes: a21f2a3ec62a ("block: Minor blk_account_io_start usage cleanup")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

