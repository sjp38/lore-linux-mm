Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B3FAC7618F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 20:04:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F14E82186A
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 20:04:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F14E82186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E1C86B0007; Fri, 19 Jul 2019 16:04:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7930B6B0008; Fri, 19 Jul 2019 16:04:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65B2A8E0001; Fri, 19 Jul 2019 16:04:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 480056B0007
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 16:04:01 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id h4so35840459iol.5
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 13:04:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=aPsM7izy0lsHgieRMKZNuSLjrGTa3/1dak1h6g1FuBU=;
        b=ZJ36a9BF1Ce81aYqKmeWJlkfw+KhxTceP7KPmAdQqNUGux0jMmo5X7FtRttXsHmUzQ
         2KReJdFvk9ksPpa/GZ/K67tVjmrMqosPJpV53xTQhez8tEcxmh8/tPr0Sd0+mRxjBgc0
         AT18YKW6L5fgguVypRCSqAHrrFDPVL5fYCCDFTksLxXA8iwExXgIgRrMoIDG0DqUi16O
         I5EzqAMke+z7Mp84G4GPdxGgm5b7QBQP5mXOvJS0eZ2JzPSv+Mb0LelW5Ke/uzFIUzzd
         LegpeqsIRNgSOWyQBx8eVz1DexUP5TkGsKg76Rbe+LTgWYd5rd6dvTrz5KYNEds3vllB
         UTRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3mciyxqkbac0bhitjuunajyyrm.pxxpundbnalxwcnwc.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3MCIyXQkbAC0bhiTJUUNaJYYRM.PXXPUNdbNaLXWcNWc.LXV@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAWhkLHdjKLZMaXq92uA/qwqnysp1vLMctiuToIloyZklLFmOcT1
	eKOsHAWV3Bt96mBoc53lytUZtn/drxqdxjCfQwADua564PMZbRnztujzZ0omD6AZPwrD5uVDuth
	9bENhFJPRFSJoGSRnk6XATMVBKhLtkQ8owvdDkfHodS/I1IavEK806yJa87eRnc4=
X-Received: by 2002:a5e:9304:: with SMTP id k4mr52758945iom.206.1563566641089;
        Fri, 19 Jul 2019 13:04:01 -0700 (PDT)
X-Received: by 2002:a5e:9304:: with SMTP id k4mr52758897iom.206.1563566640478;
        Fri, 19 Jul 2019 13:04:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563566640; cv=none;
        d=google.com; s=arc-20160816;
        b=x4d7BQc9ep+4YGWIgoSH7djvZ31+QgtraWBAda5BjNkCgqWAe8a4Bk7fLIm1Cuv38Z
         3EHCuqntcPTSxUGEq5gwxbKNsagu7F7cpajBat4QA52+dV+6IhBKXxM2q84tsk1gX69/
         +O7kmYb6VoE4ehlJVyPpJTBJ5kzEyexo+ErRs9vLN36Ap6ioB5GrRnDquEkgxEtUVxbs
         GW3/wiTVAeIgn28+8ius5Dc8Vna7LSw3FQ+CGwlayR4wdj+CQvg9I5I02An1hNj+pSQP
         NfRHk0zmCb1aO45y3y243mgA8XVjY7eT3sp6TbWZ053GPY+61GOpFPWnIEv2e0BcVC67
         QquA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=aPsM7izy0lsHgieRMKZNuSLjrGTa3/1dak1h6g1FuBU=;
        b=CJjowhrgMf1fXW8+k2Cu/ReTAUdKOE+rDCWTfep8UhjSqGnyorjot+A9C2tE7rilmC
         /HatjeiD5rbuqN5naZl084Q7uaeZfhtOHLuNqpnNRHDIRwlh8681+CYhplpoJLf66S1d
         qwq1FNJzO25b0C3mSFoMFT3wFgVxuhtF4V7m/UakezJ/lUa/ncYu6JP/Fij7DSCVN603
         qUF9tb1AtxyW5DGICjtYTMv4cVjDs9b76XbzlEVen+KSRcqdfkv1coptjFRVNxex1FMd
         ZQF7vgrxe7CBUaPSgATyg3dklkDo17dm+j3X2wuAIdLMzA9QC+QZOeY0OMlpOn/S8pC/
         7nFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3mciyxqkbac0bhitjuunajyyrm.pxxpundbnalxwcnwc.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3MCIyXQkbAC0bhiTJUUNaJYYRM.PXXPUNdbNaLXWcNWc.LXV@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id e1sor21942224ioc.49.2019.07.19.13.04.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jul 2019 13:04:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3mciyxqkbac0bhitjuunajyyrm.pxxpundbnalxwcnwc.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3mciyxqkbac0bhitjuunajyyrm.pxxpundbnalxwcnwc.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3MCIyXQkbAC0bhiTJUUNaJYYRM.PXXPUNdbNaLXWcNWc.LXV@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqxidYggLhCDlKDPPoGD3FSWeBWxwtOzAyrvnQyzo3ixpa+XRzwDjKZfxioOdAVAMIp4fTiorW0EVPKAU++mh06/cyXjSy0g
MIME-Version: 1.0
X-Received: by 2002:a5d:87c6:: with SMTP id q6mr29436327ios.115.1563566640206;
 Fri, 19 Jul 2019 13:04:00 -0700 (PDT)
Date: Fri, 19 Jul 2019 13:04:00 -0700
In-Reply-To: <00000000000045e7a1058e02458a@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000002c183d058e0e3abd@google.com>
Subject: Re: KASAN: use-after-free Write in tlb_finish_mmu
From: syzbot <syzbot+8267e9af795434ffadad@syzkaller.appspotmail.com>
To: aarcange@redhat.com, davem@davemloft.net, hch@infradead.org, 
	james.bottomley@hansenpartnership.com, jasowang@redhat.com, 
	jglisse@redhat.com, linux-arm-kernel@lists.infradead.org, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-parisc@vger.kernel.org, mst@redhat.com, syzkaller-bugs@googlegroups.com
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

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=11642a58600000
start commit:   22051d9c Merge tag 'platform-drivers-x86-v5.3-2' of git://..
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=13642a58600000
console output: https://syzkaller.appspot.com/x/log.txt?x=15642a58600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=d831b9cbe82e79e4
dashboard link: https://syzkaller.appspot.com/bug?extid=8267e9af795434ffadad
userspace arch: i386
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10d58784600000

Reported-by: syzbot+8267e9af795434ffadad@syzkaller.appspotmail.com
Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual  
address")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

