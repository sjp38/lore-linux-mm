Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A21ECC7618F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 16:34:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57FFB21872
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 16:34:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57FFB21872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4B7D8E0001; Fri, 19 Jul 2019 12:34:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFCD46B000C; Fri, 19 Jul 2019 12:34:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D11298E0001; Fri, 19 Jul 2019 12:34:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id B1E0B6B000A
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 12:34:01 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id u25so34894938iol.23
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 09:34:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=K0tO5uO221nvtR7gnlqeSa9IqFZGmt58DDiOBmYEiu8=;
        b=Vm89LKLW8EbhrHYUDSonmoJ81e47+zIi8omuZ4Krph+nkoaV6je13RP2jE2GVulMqK
         IMZpN7RYvoiLq/h8iBkSqqLaOaLK4RXSHiznMQib969mx+a2IPao23fq7xGDzSLjQ61T
         MO31GKgar4gdKvLxYntEfuIrWquWQGg4K6X72U7eSbpIwhK2Jn9Y/wa4wNF5uMXrapgI
         qNaRCdL6TqJ6wnYdXGB0f6wIyG/dSYueFAbXrSDFGe0aLtGC7Tl/T/o98FjxAxei1OLB
         aJvF6eBitkeXgwajXMcHCAgDJiv/6AP//N90cSBbRK7WV2cKHaXqfnEYPTM5CO5amVgl
         GjCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3-paxxqkbajedjk5v66zcvaa3y.19916zfdzcx98ez8e.x97@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3-PAxXQkbAJEDJK5v66zCvAA3y.19916zFDzCx98Ez8E.x97@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAUXmKdYAv1Sg7/dXF9WbXM7H1GP8U5JjKT6hwpNyKPoglmoUHo7
	6dMBtd3GUyZj8AI7DgKCad/y4rYSCDPDMgW858b/5podLqW5PpnvbdoUpnRNMNyS9iseHIGD7MI
	XV2WskBrTuv36S4Ubr48vhixIDLIpcdg+CSzJS5rRRdsUqL/Qk2FxmEHemE8Y+dU=
X-Received: by 2002:a5d:8ccc:: with SMTP id k12mr50163231iot.141.1563554041356;
        Fri, 19 Jul 2019 09:34:01 -0700 (PDT)
X-Received: by 2002:a5d:8ccc:: with SMTP id k12mr50163165iot.141.1563554040593;
        Fri, 19 Jul 2019 09:34:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563554040; cv=none;
        d=google.com; s=arc-20160816;
        b=VUKZiTjX/3+VYOQ2FMxt47Fl8c0lDjCrHKSH7YMSj+lSLFpH9De+DJGXWGBc1qb7UC
         SB4rCzoX65NTIKOqKNZYHUO6gp7jSH6jBHMh4d2Knu565uqvEXrdpzrKmuQJwqDHlAuh
         G9nB7G4Qac0YqC+aZl53QE5gzZN449hWu0G4DXNPWxShbZJ5ifpg+/Uyfk+GNt9vjXqF
         73G+0JigcO9P22zuMrmIUDMT2pluJUBZsv6JzOfgyyA9paOLL/TR6v1KShTfotDisSaS
         mxrQ5F+WZChbgRsxNU+GJEPyt5Osco8WHUvjG6NXE2SjGgiUNySR0F+Kvxal3sJIkdhC
         YPjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=K0tO5uO221nvtR7gnlqeSa9IqFZGmt58DDiOBmYEiu8=;
        b=hLuOIWV3W/GSXISqesE2HFkpQRxZkOk2LFDLX8NmfT4quFSAIZD8y47qd00TSVzBqX
         XMbo6jQzhnOkzs2R4SUDTQFXGbMvN6MMx2UOQ/rjNgnlLwoHlAVOAKScOozLbb8cnGeS
         UX18VjZo9PdA0UZL71agBeZoXticThivgfCgtSJIeDXjPcKLk4GiJXAqrNnxsrOmBVpR
         V6NHYnuMqnvCuNEfby5Fl3Vik0cFYhCKb9by2yRwwDykVFpw6lvqROB01+SBmC9VUwAW
         UIxT4byMSgQ5neHIcD4bMkdoMD4Ywne8PjQhr7rIW7EalAECx4dBsMcbdNoN+dESYBTN
         OmSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3-paxxqkbajedjk5v66zcvaa3y.19916zfdzcx98ez8e.x97@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3-PAxXQkbAJEDJK5v66zCvAA3y.19916zFDzCx98Ez8E.x97@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id p14sor21653978ios.125.2019.07.19.09.34.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jul 2019 09:34:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3-paxxqkbajedjk5v66zcvaa3y.19916zfdzcx98ez8e.x97@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3-paxxqkbajedjk5v66zcvaa3y.19916zfdzcx98ez8e.x97@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3-PAxXQkbAJEDJK5v66zCvAA3y.19916zFDzCx98Ez8E.x97@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqzXnjpSQV9iFQbyh8yurehonYeDVnnn919X9PLqsJYbWXJy2VpoCVH3ZDalQ76trhEOtpL1aMd4nm27xBBAS+sOD1mk8YpL
MIME-Version: 1.0
X-Received: by 2002:a5d:8c87:: with SMTP id g7mr47222471ion.85.1563554040200;
 Fri, 19 Jul 2019 09:34:00 -0700 (PDT)
Date: Fri, 19 Jul 2019 09:34:00 -0700
In-Reply-To: <000000000000490679058e0245ee@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000027494e058e0b4b3f@google.com>
Subject: Re: KASAN: use-after-free Read in finish_task_switch (2)
From: syzbot <syzbot+7f067c796eee2acbc57a@syzkaller.appspotmail.com>
To: aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io, 
	davem@davemloft.net, ebiederm@xmission.com, elena.reshetova@intel.com, 
	guro@fb.com, hch@infradead.org, james.bottomley@hansenpartnership.com, 
	jasowang@redhat.com, jglisse@redhat.com, keescook@chromium.org, 
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, linux-parisc@vger.kernel.org, luto@amacapital.net, 
	mhocko@suse.com, mingo@kernel.org, mst@redhat.com, namit@vmware.com, 
	peterz@infradead.org, syzkaller-bugs@googlegroups.com, wad@chromium.org, 
	yuehaibing@huawei.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
Author: Jason Wang <jasowang@redhat.com>
Date:   Fri May 24 08:12:18 2019 +0000

     vhost: access vq metadata through kernel virtual address

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=123faf70600000
start commit:   22051d9c Merge tag 'platform-drivers-x86-v5.3-2' of git://..
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=113faf70600000
console output: https://syzkaller.appspot.com/x/log.txt?x=163faf70600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=135cb826ac59d7fc
dashboard link: https://syzkaller.appspot.com/bug?extid=7f067c796eee2acbc57a
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12c1898fa00000

Reported-by: syzbot+7f067c796eee2acbc57a@syzkaller.appspotmail.com
Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual  
address")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

