Return-Path: <SRS0=pjJT=VR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.4 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7797C76195
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 10:08:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FA2F206DD
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 10:08:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FA2F206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78D826B0005; Sat, 20 Jul 2019 06:08:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73D1A6B0006; Sat, 20 Jul 2019 06:08:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6536E8E0001; Sat, 20 Jul 2019 06:08:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4705A6B0005
	for <linux-mm@kvack.org>; Sat, 20 Jul 2019 06:08:02 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id f22so37447960ioj.9
        for <linux-mm@kvack.org>; Sat, 20 Jul 2019 03:08:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=aIptGodPgqjQ+OCeW9XKeJdzrs6DHyh1FKeEsnaxVbM=;
        b=AzOrzT9vUTK6ltydCNdde6NcQ56J9jY47tfutX25Bn2MGnqXBivDFAyoaEbPthMbog
         SSPog3N/MtuzGPHF6YeVf7cI8z8g22ViXzmqcslZkRRs+1v3+G1/ltRbqimpQwrvbCo1
         6qyOg1TxD60DKjzU/OJAuDaV/vJEhWPD+bZsyjTGAlj8oDOLcaNh7H5UFLQ+uXUt8sMK
         D4tyX67+I3pMnwz1YThgq8nGo0kBw41oXjCg2l4dTwZeHQn/7cSrifhHny1EAlelphL1
         onJYmXMW5ixKNx04VERSICSkeDqPP5ooalc1AfJ4zIlZ4D4u0htLM30xWTx0gT+4xbbp
         C33Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3aogyxqkbais7dezp00t6p44xs.v33v0t97t6r328t28.r31@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3AOgyXQkbAIs7DEzp00t6p44xs.v33v0t97t6r328t28.r31@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAXyWudMvG0KUzUcaScU+aWK9aQEevzYFcSpwmik3FF4qtPYLwKr
	LtOSyymL8up4wJEmV1MZDHy6Sv7CBsCVoOkYd8wmqzQ5WQYLonzZqHxI26vRe4heIh3Q+deY2G/
	8DoyyUuv8zL2Fy0HVNS/oIVjWTW+lfKCEo52GeO5S5sjeqPbtiRzK3zpVI6DUh0Q=
X-Received: by 2002:a5d:9942:: with SMTP id v2mr22291714ios.177.1563617281940;
        Sat, 20 Jul 2019 03:08:01 -0700 (PDT)
X-Received: by 2002:a5d:9942:: with SMTP id v2mr22291668ios.177.1563617281215;
        Sat, 20 Jul 2019 03:08:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563617281; cv=none;
        d=google.com; s=arc-20160816;
        b=y81GSYZPAr9PlokKEA1YalwW4Aq2JE1ZWCFN6TAGWDhy3AD55F5M3QwlMIT8ZL2875
         Iydu0IaOHaZ2nNLr++stDsubetD45OjtrGslSVRyi4mhtsuH6OI7zDi+ObeK+7Pt01TT
         lfevBKjD9IGKJ/7zmUEaS/39u2q58iWT1a2alVqX6wDnMthQgOTjVdt2M72gSkJ5tM2v
         4/QdAfBvNFtKhkaSd/Obxx4quF4pePKZDMpehYNMA4k3rsBJgBRS4uFUguzFUHdkSoxc
         wjwtwyOXCsbUgVl3Xs1++qrtr9SAMnBbszcLoy0gNTnrVIK4XG+IP+Own4ndj0zEf/A9
         NFUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=aIptGodPgqjQ+OCeW9XKeJdzrs6DHyh1FKeEsnaxVbM=;
        b=W3gPA2KGeULp4bv0m+orVNHLKJI5iucnYJY/88JnKR/9Od+Hk0bfdQrnk4t49eXCgi
         C+Uc8RwJA9lyrvpbcG/rlj7seVbIxz5tcHJMN4zN4lgLXzWtTUd5jEM5hggCyLaFF4cm
         YuRqLGjRx11qxnEeUR0kB5vME3DTD3+r3Ve6dfLG5r7hh3d9QmSdRWubMZ1hk8+25ill
         6Uk0dNUxqTSH7unPqf3/JFqp/pOQNFSGVN6elaT4/c701vrbtVXGtKf2WnP4HlDHUVBh
         17abp+tFF9y2meeBwIHB4Hqwg17s7GwZuUffa3uQyJGeL4gC9LgpjE946/julkvVb3+Y
         hjPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3aogyxqkbais7dezp00t6p44xs.v33v0t97t6r328t28.r31@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3AOgyXQkbAIs7DEzp00t6p44xs.v33v0t97t6r328t28.r31@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id v16sor23624377ioj.130.2019.07.20.03.08.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Jul 2019 03:08:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3aogyxqkbais7dezp00t6p44xs.v33v0t97t6r328t28.r31@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3aogyxqkbais7dezp00t6p44xs.v33v0t97t6r328t28.r31@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3AOgyXQkbAIs7DEzp00t6p44xs.v33v0t97t6r328t28.r31@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqxejQK5TJXgPG7zDzFOcVKgb6JtNNiEgaZkAwUZNQxIY+uT88/YtfjAsG3qEv0NnxidVHOC8aWEo8R9Py88FYjmq9+IoaCH
MIME-Version: 1.0
X-Received: by 2002:a6b:f90f:: with SMTP id j15mr48006883iog.43.1563617280803;
 Sat, 20 Jul 2019 03:08:00 -0700 (PDT)
Date: Sat, 20 Jul 2019 03:08:00 -0700
In-Reply-To: <0000000000008dd6bb058e006938@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000964b0d058e1a0483@google.com>
Subject: Re: WARNING in __mmdrop
From: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>
To: aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io, 
	davem@davemloft.net, ebiederm@xmission.com, elena.reshetova@intel.com, 
	guro@fb.com, hch@infradead.org, james.bottomley@hansenpartnership.com, 
	jasowang@redhat.com, jglisse@redhat.com, keescook@chromium.org, 
	ldv@altlinux.org, linux-arm-kernel@lists.infradead.org, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-parisc@vger.kernel.org, luto@amacapital.net, mhocko@suse.com, 
	mingo@kernel.org, mst@redhat.com, namit@vmware.com, peterz@infradead.org, 
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, wad@chromium.org
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

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
start commit:   6d21a41b Add linux-next specific files for 20190718
git tree:       linux-next
final crash:    https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
console output: https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
dashboard link: https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000

Reported-by: syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual  
address")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

