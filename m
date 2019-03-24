Return-Path: <SRS0=4n/l=R3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E7AFC10F00
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 18:51:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43D48218D0
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 18:51:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43D48218D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13F6E6B0003; Sun, 24 Mar 2019 14:51:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0ED796B0005; Sun, 24 Mar 2019 14:51:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 029446B0007; Sun, 24 Mar 2019 14:51:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAE7D6B0003
	for <linux-mm@kvack.org>; Sun, 24 Mar 2019 14:51:02 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id 186so6188539iox.15
        for <linux-mm@kvack.org>; Sun, 24 Mar 2019 11:51:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=TaangaKNWHHNGJoroNhagOABp65E/ZLZreVI8iJPwSY=;
        b=qVc5oTeKhvhdQ3LuBFLLCL9tmtzoxm3Y74kxH/ScgFdKq5DBXfvpZCb6xOFWGU9x1C
         skjPSWGVXf97ft+a0NuAntrJjh+bKuDEpLxA3MLVe661XPKz/VT6L0WXPI7xABM1cWc0
         oI8Ta8InnhOD+zpxx0Jt9TN5WlXNeGeqIZW7x5BIiAGjjLIhOvvgrk1/0EkQev/MxQkU
         U3ulXf5c/w1rVQpErAb0fmtoSFWkuKKbLIbuyN87hD1sz49SfBFyixjgD3+GyYLsbM6y
         x2g7Z15TFUcVbIKBl9qDpwqBy7RFHVHHsuZlhfwIUW/FTBby+hzMYhUnBLpQ3vM2XOTM
         JTpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3ldgxxakbaiiy45qgrrkxgvvoj.muumrk0ykxiutzktz.ius@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3ldGXXAkbAIIy45qgrrkxgvvoj.muumrk0ykxiutzktz.ius@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAVK78lGzP+5D7WbwOSSZGgqNOCJ1JUoJmlfCbw5M3uDLBY4psqF
	0qlBphAsT+0yxFwm5qaevNylx2PneKsiKQgUsxYY9S2rHpqjqCsG+mmkXUr0Zbi9kaGUbEWVMDX
	bozZC5uPPkJOOljI39oislx9Iy8NngvTKhtTu6y80oazti1iLiBuFhBj4JQfb7sA=
X-Received: by 2002:a24:d244:: with SMTP id z65mr5010736itf.76.1553453462247;
        Sun, 24 Mar 2019 11:51:02 -0700 (PDT)
X-Received: by 2002:a24:d244:: with SMTP id z65mr5010725itf.76.1553453461521;
        Sun, 24 Mar 2019 11:51:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553453461; cv=none;
        d=google.com; s=arc-20160816;
        b=G/ZuqXHR3xTEBKkAhjEgX0fXHZaDNEReAv1kiqcBBXnfzsLJjShlHqhAjX8+kSAjOv
         dLWpAWGO7Ib6A5yif77sCi4Z5kr+73rDiSxZrdjDJl1lFK7FkoYhSR7jnj8bUp55vNls
         4U6dJYO5lvtKhDeOi13auGwpdkki/HPp7VrvRMcLI8wfLoGWpH9kDe5deKSoazqIdbpv
         OAIwrP9a5azQ+eLtYUy3uKV3RFRJIjoieZ9Jzrz4sRMcHLG3KVY/wDcSohsXLt8dxuPm
         obkJ1WSmYnMkJ0z9Jka9dS6f+6ssyw5jYMZQsirxEHz/R4M4Z/205b8dqUtog4bl0NQW
         De4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=TaangaKNWHHNGJoroNhagOABp65E/ZLZreVI8iJPwSY=;
        b=Ow4IeCL2G5mLS9rE94GNnjHuRzSieGRGmcrDd89nYW2Nx6+dYccS7L5C+FtJmaGxnH
         vcamQrA9k3cfa1G3BZepfbioW7Ife3j8X3hIHsAWUMaeEVAJqsBJNyeCjUMlo/fdMZbD
         ChOCK6Tj96B2MbVYzfXDJXBN6LlM5HYOd0KuuPHx38VAmTw6SwAFIJ+6qts2Wa76mlgF
         j4yaPhj/kJwPciHpoSIcEVuKYyitnNf3kXopT8ZXKMLPwDeuVxxncwCkHZjb6qnYibLY
         NOh5FROFgiJuWh15m4ZOSDGmB/N2ILK+8SotWhVsVMLtF2uN92CXDlFPG3LdchpI2q6C
         uKWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3ldgxxakbaiiy45qgrrkxgvvoj.muumrk0ykxiutzktz.ius@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3ldGXXAkbAIIy45qgrrkxgvvoj.muumrk0ykxiutzktz.ius@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id z15sor9271080iob.135.2019.03.24.11.51.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Mar 2019 11:51:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ldgxxakbaiiy45qgrrkxgvvoj.muumrk0ykxiutzktz.ius@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3ldgxxakbaiiy45qgrrkxgvvoj.muumrk0ykxiutzktz.ius@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3ldGXXAkbAIIy45qgrrkxgvvoj.muumrk0ykxiutzktz.ius@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqzc9e/z98OxuXRxxQ50Lz2rJE46NLiCvVxUfI9UU2qdGoDiv0mpmd4hG8DBq3QJHc8JyrfvzfUlI2scySlli5ilYbQx95Sw
MIME-Version: 1.0
X-Received: by 2002:a6b:d913:: with SMTP id r19mr6437307ioc.76.1553453461289;
 Sun, 24 Mar 2019 11:51:01 -0700 (PDT)
Date: Sun, 24 Mar 2019 11:51:01 -0700
In-Reply-To: <0000000000000e2b4e057c80822f@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000bc42080584db9121@google.com>
Subject: Re: general protection fault in freeary
From: syzbot <syzbot+9d8b6fa6ee7636f350c1@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, arnd@arndb.de, dave@stgolabs.net, 
	dvyukov@google.com, ebiederm@xmission.com, gregkh@linuxfoundation.org, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, 
	manfred@colorfullife.com, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000032, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit 86f690e8bfd124c38940e7ad58875ef383003348
Author: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date:   Thu Mar 29 12:15:13 2018 +0000

     Merge tag 'stm-intel_th-for-greg-20180329' of  
git://git.kernel.org/pub/scm/linux/kernel/git/ash/stm into char-misc-next

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=17d653a3200000
start commit:   74c4a24d Add linux-next specific files for 20181207
git tree:       linux-next
final crash:    https://syzkaller.appspot.com/x/report.txt?x=143653a3200000
console output: https://syzkaller.appspot.com/x/log.txt?x=103653a3200000
kernel config:  https://syzkaller.appspot.com/x/.config?x=6e9413388bf37bed
dashboard link: https://syzkaller.appspot.com/bug?extid=9d8b6fa6ee7636f350c1
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=16e19da3400000

Reported-by: syzbot+9d8b6fa6ee7636f350c1@syzkaller.appspotmail.com
Fixes: 86f690e8bfd1 ("Merge tag 'stm-intel_th-for-greg-20180329' of  
git://git.kernel.org/pub/scm/linux/kernel/git/ash/stm into char-misc-next")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

