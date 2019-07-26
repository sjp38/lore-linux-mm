Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A0BBC7618F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 23:26:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02F2D20869
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 23:26:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02F2D20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C2136B0005; Fri, 26 Jul 2019 19:26:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64BE18E0003; Fri, 26 Jul 2019 19:26:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EC108E0002; Fri, 26 Jul 2019 19:26:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2E1656B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 19:26:02 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id e20so59986156ioe.12
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 16:26:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=jU9fP+7H8MVZejaHdG74+bs1E1cZqrGALTWcbghPSM4=;
        b=nnoB5A+WNqR0UnczmNKoq++Q9QJlyX1P8+DnXEoWGAYElYpcvLDDLqf35AYCzy0PFd
         2N9rRLPsvTyrVeXqsKeTEjwP6cgyUd0X5j3k/jxDwQFgZFO913ghb8n3PKNNj481b0VE
         xBy8A/ZFYSmj2DGA7fKHhJz264tWFOmM8c5wdvQPtYX+HLABJUJYOgIsvUnLjigZcvsQ
         EgHBSeUF56Jrp6ppqYnNmLBy3A0o8N1fXMnQPFeuXaopFbdwtDBHE1Pb7mmj74cPOPa6
         E9DN6ag3P4hLKJg7mcy080p3bmyZX/UpQpOf2N0smfGLtJgxVPyQ9Vp+bcjRhLOWzNiN
         0V9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3ciw7xqkbap0x34pfqqjwfuuni.lttlqjzxjwhtsyjsy.htr@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3CIw7XQkbAP0x34pfqqjwfuuni.lttlqjzxjwhtsyjsy.htr@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAUvVTBKHpypDwuqzT4+5211VR4EDUSD+3F/ie1hkOsRAoH+KAFu
	ii81K5WAkRSX7yKoeN1NeVm25GU7aTqPzlgTSGdZldJTF5u9WlzcbKEQ2nK48Aqh8fUq1YkK0IZ
	yMwfg1kjX27M4jLyUJSaD6XTLjzFnP27ctgpqH6KMMAW3/YgMrMRgDEGK6tISX/Q=
X-Received: by 2002:a05:6638:63a:: with SMTP id h26mr24329244jar.92.1564183561976;
        Fri, 26 Jul 2019 16:26:01 -0700 (PDT)
X-Received: by 2002:a05:6638:63a:: with SMTP id h26mr24329196jar.92.1564183561349;
        Fri, 26 Jul 2019 16:26:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564183561; cv=none;
        d=google.com; s=arc-20160816;
        b=kxmqpWkergNDbbh1kznRtcNeLt1q4URngbcADombldtVPxfk55vr0+u+psZEbVK9Yt
         jm7b3wlM8xguS5ZlRt9/+LHisI+S/gKgszBF/xjHfzap+QIh3A9qvAGEq4yAMgBgfHor
         0YrWzBD3ZgWoh1benG22LGx7/Vprs1MTPzzzUZw0f47s0vcUlM4osY9whw7S/kNROqLU
         grEQAXPO5th2njHU7owD2NBBlqbMHHZB4pCjNbE6Q4BwIF7f0yJ+ExWMjj/SjWALYM9b
         5NGQoQGqUph9KB9+wdR63CZNUNumMTfDVJ1QXbKrNZu36o3NFgLXErBlxtMcVrNBHhfe
         DydA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=jU9fP+7H8MVZejaHdG74+bs1E1cZqrGALTWcbghPSM4=;
        b=YLSeThgPJ9F8aBMQTSkJiUbUtF/BQ0Ek+3zNS6VysACogJasth5kchfFLuudBylqKo
         l5TfJx4/rfOuuITpYOj+39qD5RX2m3qa8UlECc+6lX4aYGQsN8IIxGz2yGuaIJRJoGCI
         w6E6JlIxngWZdU2NdoPoVJrUQ23UFOlCexOtLRoNMiz9Zep72h7dZBfydnrieUj9Mk3l
         h16payYDcdhNv0uaob/cfv20s+ks9ajna8D5vU4Iu74q3MxRRTTySzc2gE0uynN3+JIj
         2mhSaXOlfo6zowMvS3Y9ucLkEZND8+WmUsEV0f6UMzafEhJ+V3bAPK4rIS01r49XAH4h
         gSTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3ciw7xqkbap0x34pfqqjwfuuni.lttlqjzxjwhtsyjsy.htr@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3CIw7XQkbAP0x34pfqqjwfuuni.lttlqjzxjwhtsyjsy.htr@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id m187sor37289193ioa.46.2019.07.26.16.26.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 16:26:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ciw7xqkbap0x34pfqqjwfuuni.lttlqjzxjwhtsyjsy.htr@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3ciw7xqkbap0x34pfqqjwfuuni.lttlqjzxjwhtsyjsy.htr@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3CIw7XQkbAP0x34pfqqjwfuuni.lttlqjzxjwhtsyjsy.htr@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqxovLmXIv75laVrMtZvlr79yeQWRntZAt1hwL6RBmKRhi84q3dBc8vJmpG72hkv1CJ8iH3NYbDZi9CnPAFhes4c6TPcq2Lv
MIME-Version: 1.0
X-Received: by 2002:a5e:d611:: with SMTP id w17mr24902658iom.63.1564183560976;
 Fri, 26 Jul 2019 16:26:00 -0700 (PDT)
Date: Fri, 26 Jul 2019 16:26:00 -0700
In-Reply-To: <000000000000edcb3c058e6143d5@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000083ffc4058e9dddf0@google.com>
Subject: Re: memory leak in kobject_set_name_vargs (2)
From: syzbot <syzbot+ad8ca40ecd77896d51e2@syzkaller.appspotmail.com>
To: catalin.marinas@arm.com, davem@davemloft.net, dvyukov@google.com, 
	herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru, kvalo@codeaurora.org, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, luciano.coelho@intel.com, 
	netdev@vger.kernel.org, steffen.klassert@secunet.com, 
	syzkaller-bugs@googlegroups.com, torvalds@linux-foundation.org, 
	yoshfuji@linux-ipv6.org
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit 0e034f5c4bc408c943f9c4a06244415d75d7108c
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Wed May 18 18:51:25 2016 +0000

     iwlwifi: fix mis-merge that breaks the driver

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=10f955f0600000
start commit:   3bfe1fc4 Merge tag 'for-5.3/dm-changes-2' of git://git.ker..
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=12f955f0600000
console output: https://syzkaller.appspot.com/x/log.txt?x=14f955f0600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=dcfc65ee492509c6
dashboard link: https://syzkaller.appspot.com/bug?extid=ad8ca40ecd77896d51e2
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=135cbed0600000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=14dd4e34600000

Reported-by: syzbot+ad8ca40ecd77896d51e2@syzkaller.appspotmail.com
Fixes: 0e034f5c4bc4 ("iwlwifi: fix mis-merge that breaks the driver")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

