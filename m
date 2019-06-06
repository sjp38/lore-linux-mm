Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F3F2C28EB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 21:26:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF168208E3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 21:26:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF168208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DC086B02E6; Thu,  6 Jun 2019 17:26:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68C926B02E8; Thu,  6 Jun 2019 17:26:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57BED6B02E9; Thu,  6 Jun 2019 17:26:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 392366B02E6
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 17:26:02 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id p19so110958itm.3
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 14:26:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=8FLsmzT5fuRYDlPRpXfsHV8R+x45zmFIlbaKQu+jQrU=;
        b=GOWA8KJmxIW5LnR/jHm249k730m5J4j6HSUjtLADOyIyfHi3+pz/+WPVE9+wRnRIQx
         TS6ZEDHzrJVy+aKsLwWTzU37lvlX1QAHBBebJXUdCq9P8AY97eguGSwmCl4SrQFCKuKF
         D08t2i/jtDyBqCFm4E2acnrZ2Fg3M27TFpnnWXrHoXejdtysnJmQ7VOupYTupLjbCl0l
         pRtaCPcEmkfRCT/WNzD7RtVzDUvItWZ1AvovwG+vRzyB3t4ZmW8M2Etz9zsSeCjOy3JG
         INMWdM99hSm7//vf+UcK6Iv9xgj+u6SUENqLIFrO9GT67TfKbJAME9YK0BhLb6ssXy5U
         nNiA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 36it5xakbamu39avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=36IT5XAkbAMU39Avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAU/Sc6QeGzCAS5QBV1cecjUKDr0l/Umeb+M5ZJHvCpVQrG3fGdD
	hfHAxRZwrGq5ItOcjBC85E5g5CjAZKYKbGNQz28b15mMrDJaq7YiHgMkktIJlq+aNZACXDiCfon
	q2M5KI44G+/AUO+x24FXBztVLbIVxbAQy37Tjci6jKhEUTq1P3aCBqUqZQzDt63Q=
X-Received: by 2002:a02:16c5:: with SMTP id a188mr32978016jaa.86.1559856361994;
        Thu, 06 Jun 2019 14:26:01 -0700 (PDT)
X-Received: by 2002:a02:16c5:: with SMTP id a188mr32977977jaa.86.1559856361267;
        Thu, 06 Jun 2019 14:26:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559856361; cv=none;
        d=google.com; s=arc-20160816;
        b=nv9zmVx8g/Dmt3ZxUSIJT+UVyivTGTQ+EY6YLaxNAAcwDEGXir39CIX1eWu7v7Nj3P
         0x0EPj1D/OV6KURruv3zjWglcASfnNQWyMvMqmTC9W4JYdBfgAz5uvcFw9OYOE7eiXYf
         2QE0r9jByh4izB6HLhF7ur8eGR2o6rIk4UQHEM5aLkFe4A+2OMrIpZtM364BjtK1euSA
         UqG6Uw1OZ0f/zMhqJmBfaJ5IZnhEvHD8H6JjQd/lU97LTOStf8xkD47ImjGs11/A95zm
         I2rqJOeASp2KMZV0KoTrQWmFFBTzEvaXQDyHel1hktRWMGfj8rcG6rVrK54EyMGG/thl
         DVLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=8FLsmzT5fuRYDlPRpXfsHV8R+x45zmFIlbaKQu+jQrU=;
        b=Bl6qbTDq/d1gZc612il90luksOwGLr5S8RpA9L1JpuxI7TAYg/ZrwHrXhYLJPCxb4a
         C3NJoDniUzU7lAtT0CJ/vj/+dkD68n+pHOIaBP34n6BNXdvtF47sqbzydmLNSHsNjtDL
         2lGk9LuokREBL76jz+nzyqk2d5nSsMkxNSf3iNun3w7hZ2lh5J0ECCwchHyVzYG8hEOK
         NfGC5PhUg749R34zsPfiDY/ytb6qa/mbeHKPyK+zWqPSDoiBrK60y10aiYByPaOTSyZQ
         JZE1p0L2s4CIqA/4jTRMTrt/7f8DTK7eLslbhLK9v0/75L6KNPVVAbTPix2+koYfhd/M
         W4wQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 36it5xakbamu39avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=36IT5XAkbAMU39Avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id e192sor142879iof.45.2019.06.06.14.26.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 14:26:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 36it5xakbamu39avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 36it5xakbamu39avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=36IT5XAkbAMU39Avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqxl7JOalyt2i6XIsXn7vQ0MIDr2sMsgZJhOcVtzOU7sAoQq0Rfvs8Y/n2P0+sXCktgx3+s7D4eQfn486z0A1OdlZGHlD5Za
MIME-Version: 1.0
X-Received: by 2002:a6b:1488:: with SMTP id 130mr29049755iou.304.1559856360982;
 Thu, 06 Jun 2019 14:26:00 -0700 (PDT)
Date: Thu, 06 Jun 2019 14:26:00 -0700
In-Reply-To: <0000000000004945f1058aa80556@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000004c11d6058aae5c30@google.com>
Subject: Re: KASAN: slab-out-of-bounds Read in corrupted (2)
From: syzbot <syzbot+9a901acbc447313bfe3e@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, ast@kernel.org, cai@lca.pw, crecklin@redhat.com, 
	daniel@iogearbox.net, dvyukov@google.com, john.fastabend@gmail.com, 
	keescook@chromium.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	netdev@vger.kernel.org, songliubraving@fb.com, 
	syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000006, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit d40b0116c94bd8fc2b63aae35ce8e66bb53bba42
Author: Daniel Borkmann <daniel@iogearbox.net>
Date:   Thu Aug 16 19:49:08 2018 +0000

     bpf, sockmap: fix leakage of smap_psock_map_entry

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=1137e90ea00000
start commit:   156c0591 Merge tag 'linux-kselftest-5.2-rc4' of git://git...
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=1337e90ea00000
console output: https://syzkaller.appspot.com/x/log.txt?x=1537e90ea00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=60564cb52ab29d5b
dashboard link: https://syzkaller.appspot.com/bug?extid=9a901acbc447313bfe3e
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=11a4b01ea00000

Reported-by: syzbot+9a901acbc447313bfe3e@syzkaller.appspotmail.com
Fixes: d40b0116c94b ("bpf, sockmap: fix leakage of smap_psock_map_entry")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

