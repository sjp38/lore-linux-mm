Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDDB3C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 01:36:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 712DF20872
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 01:36:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 712DF20872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C02A86B0003; Sun, 31 Mar 2019 21:36:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB2496B0006; Sun, 31 Mar 2019 21:36:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA0B66B0007; Sun, 31 Mar 2019 21:36:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 896B26B0003
	for <linux-mm@kvack.org>; Sun, 31 Mar 2019 21:36:02 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id k2so6994620ioj.2
        for <linux-mm@kvack.org>; Sun, 31 Mar 2019 18:36:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=A/qvTuzWzcXrKwk5I9hqWbCkLBHuV3PpWBSNby7m4MI=;
        b=h2mJea8T5YutBF29bKcHz4ZPPj80Vuk7CjxfRx3IOuOyIRoM2dbR0/LO3rP26x4GBt
         vpM1iy0wDRC0EcB4mOO2ureKbebseVBlGO1oGNVoH7TAKx3UHOhwYtJ6jpj4sW6g7She
         Y8Y+aMsiXrvaNI+A2vTCT/1ZGCvClJDHn+Nb8q/coIoh+HiZScI0ZB3RwQ6cFLCFgv5I
         K4PNDhCZcLPHvly3cvU5gHz2Hyazrf+akfqT1LhgNt+P79dF0cITHpeLYNX9osMlngwV
         g0ROD/dxBBXfl/BN3ftAaxUyfI1AMUnaZFdbBbs/3XGzYOp7R0pgHrRkz60N28K1J9YM
         Z3DQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3awuhxakbaeg289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3AWuhXAkbAEg289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAVdyKdzd2l7sabzYtm73roTkIMjIlB54ZY16pBzp2snQnCfWnxR
	wQj2x7XOJSCc/clW75NjCFA6SfaM96dhMyIZS3x8M0q67OFd/VSzV347sK5HXxYTVlpy32UrDjf
	TFYgWMRWBjxEP7alReWcm1VYMt80gHlJh1KPHTfN2G+b9q5Kmiw+V4dbdacyftBY=
X-Received: by 2002:a24:730f:: with SMTP id y15mr13614333itb.126.1554082562327;
        Sun, 31 Mar 2019 18:36:02 -0700 (PDT)
X-Received: by 2002:a24:730f:: with SMTP id y15mr13614309itb.126.1554082561559;
        Sun, 31 Mar 2019 18:36:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554082561; cv=none;
        d=google.com; s=arc-20160816;
        b=fIU9X0PBFc5+ErLZ5YIpgyax665f4TS1YqE00olhYMiAz2mbvVElQBQh2MgvbahLGD
         rc6PCCQTNbL+fOAj1tcKzQz74FHfRcf2WNYExR7scxFtRxQIRjTOSeSPRu/z2XlGuL42
         M1Qw9IljtedIc3EfcxtYvka1Jrs3KfYG2cHLovTwfBbrYJd4zKkQMxvQ8CqjZ6i1wrC3
         yrRcGerd9yFhEXJHFSdsr7k1PMd9OZ5dbVnkdW01JoPiXOLJGBbhPirTUm2P47ItS4JR
         oKnku0jZghV1gi68SD4B0ttqGxiSWhcLYYVu1yUOdVnTBei2XQmr3bylV3YPtX5rfFYx
         fi9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=A/qvTuzWzcXrKwk5I9hqWbCkLBHuV3PpWBSNby7m4MI=;
        b=KRlb/7npHxz87U6xQurPi5RZkQVw3rDOpUhPue7jjPq+w2+uptf7dqrWUu3DvyA3Rl
         Y+SSOWY9FoX5awX+elkImykZS6uVg5T93Jb1L7exRZxU11KPFPYQHaqil5QBTb9U8kSe
         nCMFmqTeM3iR+0Tu65ChtvdD/TRIBkSxHrmsvfkXvLb4VF0rhAb0PcCE/xrJl4ZnNILM
         iZzucxs6+oKNtrpz1T6J9y+m0oxsE9MH1Q2a+0UnjXh1ybPIJt60jJshdoqLCthburzM
         5N4nj2rWOcq7dA7l0yDi93MmLytxPt/li/cZqhP58qJnjsaMpctz2iPII9yCYrKPOTOH
         Ozcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3awuhxakbaeg289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3AWuhXAkbAEg289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id 142sor14100473itz.7.2019.03.31.18.36.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 31 Mar 2019 18:36:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3awuhxakbaeg289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3awuhxakbaeg289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3AWuhXAkbAEg289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqwvoXmhoAUfBKfjExPABvmIvM/cQrgmMgsL4VzBfhkMrbpnSevW8i8VZDVHAuWq+5SwN8DJMO6jLKKNdNX1eDjxksB6795s
MIME-Version: 1.0
X-Received: by 2002:a24:43c5:: with SMTP id s188mr5327781itb.25.1554082561338;
 Sun, 31 Mar 2019 18:36:01 -0700 (PDT)
Date: Sun, 31 Mar 2019 18:36:01 -0700
In-Reply-To: <00000000000010c9390570bc0643@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000000531f105856e0b18@google.com>
Subject: Re: general protection fault in _vm_normal_page
From: syzbot <syzbot+120abb1c3f7bfdc523f7@syzkaller.appspotmail.com>
To: aarcange@redhat.com, akpm@linux-foundation.org, 
	dave.hansen@linux.intel.com, dvyukov@google.com, dwmw@amazon.co.uk, 
	jglisse@redhat.com, kirill.shutemov@linux.intel.com, kirill@shutemov.name, 
	ldufour@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux@dominikbrodowski.net, mhocko@suse.com, minchan@kernel.org, 
	oleg@redhat.com, rientjes@google.com, ross.zwisler@linux.intel.com, 
	sfr@canb.auug.org.au, syzkaller-bugs@googlegroups.com, ying.huang@intel.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit 4a110365f1da9d5cabbd0a01796027c0a6d5e80b
Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Date:   Wed Jul 11 00:45:42 2018 +0000

     mm: drop unneeded ->vm_ops checks

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=10b0650f200000
start commit:   98be4506 Add linux-next specific files for 20180711
git tree:       linux-next
final crash:    https://syzkaller.appspot.com/x/report.txt?x=12b0650f200000
console output: https://syzkaller.appspot.com/x/log.txt?x=14b0650f200000
kernel config:  https://syzkaller.appspot.com/x/.config?x=3f3b3673fec35d01
dashboard link: https://syzkaller.appspot.com/bug?extid=120abb1c3f7bfdc523f7
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12a46568400000

Reported-by: syzbot+120abb1c3f7bfdc523f7@syzkaller.appspotmail.com
Fixes: 4a110365f1da ("mm: drop unneeded ->vm_ops checks")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

