Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16938C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:48:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D928B21951
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:48:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D928B21951
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67D716B0003; Thu, 25 Jul 2019 12:48:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62EEE6B0005; Thu, 25 Jul 2019 12:48:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51C768E0002; Thu, 25 Jul 2019 12:48:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3337C6B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 12:48:02 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id q26so55477917ioi.10
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:48:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=RIyoo7tX1yNs3TKOq4NKYW32kQ5qo7m0vsA24OoRalg=;
        b=QaOQPGx2mpWJg+lHlWqoEyAGSNF2j3vxjNquVmD96ZvKUZwqX6GzhGv+MG9Fgwpe/3
         2jF4dMTl5QvqWnAOdsnWurmeYIUOa2Mp8VvzMePM2GGAFEFREwndKaaVTmhpa6GwfuGo
         uxkEU5cSHiXOVx0rKgHYXTlZaqJViQpat8XxRcW2DjHjO0wX0YQk5P2/DH1ngBEECFfF
         JhIrHz+m/A7b/zz7AhYJwbV6epBiegPrUviFlYPfLRHksYWO31UG8q5c6XQMfs/YNDC2
         Z7J6byKflSfk6YBNUzABOM2XGwim5QDOgLOOPAPoZEBspBQy60H4CHQuMnEZwHnvfmdv
         y7ng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3qn05xqkbaneflm7x881excc50.3bb381hf1ezbag1ag.zb9@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3QN05XQkbANEFLM7x881ExCC50.3BB381HF1EzBAG1AG.zB9@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAXVd6eimLjm2QQzZ2vQFE2xe7FhremNu9qG+BHtZWdpyBdzWNhA
	VAunU3RKDmwkHLPwH9q4tmMvzVe7NJBLL52FwQ9qxWkz0JvFnHKIJEXF0T4JuUy5r6+QnNQsAHD
	tfCJ/Xp0FZZuFmQmt2W5OYdLJUb9JG5Q5yn4sSDSt9CmnLR7S859/zN2us6uRiF8=
X-Received: by 2002:a6b:d809:: with SMTP id y9mr85764021iob.301.1564073281933;
        Thu, 25 Jul 2019 09:48:01 -0700 (PDT)
X-Received: by 2002:a6b:d809:: with SMTP id y9mr85763943iob.301.1564073280902;
        Thu, 25 Jul 2019 09:48:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564073280; cv=none;
        d=google.com; s=arc-20160816;
        b=GLJheplZLoXNmwwxsLPlz2cwGzO3lo0g7Rqq5iUz52OvqP4qwyG9aKypLA3AlO+7rv
         EtUwOw2o3Zr7y7AQcinWzEkspUB8gK44QOt3m1bwzNbVyi8qDkOmTNkw896rZNiR+xDb
         ioBL8A60TyYIRlDTZ/usJxADMwSm3y14Mb6XbJ3LIzJYfxKrDumFv9OxmwuZQeYdvP5/
         3iENsgtDOhMGOCdvk6UTao0ngPWu7YsPlxNCqDh/n0BQhJtoITlIymeySDk3iOtCLnJz
         0sWjxYgqTZCnr5JHZcctuxlZ4kL64Tk07D+us/DlhxIQz6dK/g8kcqmE8NiN8rBQgZFC
         3mOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=RIyoo7tX1yNs3TKOq4NKYW32kQ5qo7m0vsA24OoRalg=;
        b=ATTOcnFE8DzYOjvGKmRbVXFAhyzjarAE8wUbQL/KYnx5SgSqtjPuxw8JCBmKZvWT93
         CTXq5U0m3OwEDVv8a4xRYXraLEtEggNIDDHy6SuLZDlZc5rUk2iVr/h8xoPG+2E9cF3R
         djPUAYF2nkd9mmPXWGoaRyuezvKkcifQovfj22BjKJS3uNN/WS7w6mvodGq+reBQSsUw
         EH6SrKYtI295+EVaYrnCZGW3Jt+E0JSjB9j2iqndGSWd/VR7rwEBuCzkSHyUAROpILv1
         a4BZLG3CK+kkArwPKX5WiJr8GLjeggILeBWCQLnM2034P5WiTqLBwJmgv4/QCE/JslWN
         dkOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3qn05xqkbaneflm7x881excc50.3bb381hf1ezbag1ag.zb9@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3QN05XQkbANEFLM7x881ExCC50.3BB381HF1EzBAG1AG.zB9@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id u15sor34854844iom.87.2019.07.25.09.48.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 09:48:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3qn05xqkbaneflm7x881excc50.3bb381hf1ezbag1ag.zb9@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3qn05xqkbaneflm7x881excc50.3bb381hf1ezbag1ag.zb9@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3QN05XQkbANEFLM7x881ExCC50.3BB381HF1EzBAG1AG.zB9@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqz5TRtqk7NLmHZ9yCjKgr37hlCy64JGLcLrJPFsu5MG3DE1E7Gd++DbNYtHpzMzIfx8epvxltXfNlkPKaKIMMo/U8GbRTzt
MIME-Version: 1.0
X-Received: by 2002:a6b:641a:: with SMTP id t26mr37599516iog.3.1564073280346;
 Thu, 25 Jul 2019 09:48:00 -0700 (PDT)
Date: Thu, 25 Jul 2019 09:48:00 -0700
In-Reply-To: <00000000000070c81a058e6c2917@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000004761fd058e843049@google.com>
Subject: Re: memory leak in v9fs_session_init
From: syzbot <syzbot+15b759334fd44cd9785a@syzkaller.appspotmail.com>
To: asmadeus@codewreck.org, catalin.marinas@arm.com, dvyukov@google.com, 
	ericvh@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	lucho@ionkov.net, syzkaller-bugs@googlegroups.com, 
	torvalds@linux-foundation.org, v9fs-developer@lists.sourceforge.net
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000021, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit 16490980e396fac079248b23b1dd81e7d48bebf3
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Tue May 17 02:51:04 2016 +0000

     Merge tag 'device-properties-4.7-rc1' of  
git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=115e94cc600000
start commit:   abdfd52a Merge tag 'armsoc-defconfig' of git://git.kernel...
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=135e94cc600000
console output: https://syzkaller.appspot.com/x/log.txt?x=155e94cc600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=d31de3d88059b7fa
dashboard link: https://syzkaller.appspot.com/bug?extid=15b759334fd44cd9785a
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1735466c600000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=117e0cf0600000

Reported-by: syzbot+15b759334fd44cd9785a@syzkaller.appspotmail.com
Fixes: 16490980e396 ("Merge tag 'device-properties-4.7-rc1' of  
git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

