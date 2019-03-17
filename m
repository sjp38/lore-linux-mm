Return-Path: <SRS0=9bJk=RU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA3E2C10F05
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 10:43:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E96E2184C
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 10:43:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E96E2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3C306B02E7; Sun, 17 Mar 2019 06:43:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEB776B02E8; Sun, 17 Mar 2019 06:43:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E046B6B02E9; Sun, 17 Mar 2019 06:43:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id C10726B02E7
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 06:43:02 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id c2so10994411ioh.11
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 03:43:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=QSzsPUt8vxZ35tdHZ1qW8SYxaq0LFUJlh8G5w5k1f74=;
        b=DMDMWBgNH8w5KGB4bs7pjOMsLhmFi+Ju2CzoXbjV8TWqpc6NqIl4G22cbP6AharXob
         Js353hlLwgqe5vEyl6LK4FJUoR4dSEsB6WZ7aD2jRv6MaJXs8nGhn07z7pPMDAQ1eHEf
         icf0iQbTa9Q2bOACgwH3CM5OGG7duu+VdUw1kguwrOcn5uDLwzOGLhidOzk521+iqsTM
         FQ57JLcdK+WP2PGECyjXv1hQ8VPCcfcYVmwyTDeNg2IXXgOpeHllwEL35dFVT5pb0FKn
         a5aYgjv3UK3PUfHesxX3FyFy7c1ejIsq3pBI9VJStdVtJvwehXJYWFaIbeQMfpEKGm5K
         i0nQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3tssoxakbaciqwxi8jjcp8nngb.emmejcsqcpamlrclr.amk@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3tSSOXAkbACIQWXI8JJCP8NNGB.EMMEJCSQCPAMLRCLR.AMK@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAVS4zI7VlfyppE2z5PaDzAkUzY6CLgYIuikUJvPeEoYinFsiYn9
	a38eqUORbxAWkOWAl28go3CXh+i+AqE79xw+Mpq63RLWvWePFjERuxLkDB7zIQckE9HvmsAca+P
	18nM5DwUPFIC/f4nB/q6uXqucjz7pz8X+ZrkSqdYWYRUCDtdOZ4Pm/+OcsVQWbwE=
X-Received: by 2002:a6b:7708:: with SMTP id n8mr7103490iom.141.1552819382475;
        Sun, 17 Mar 2019 03:43:02 -0700 (PDT)
X-Received: by 2002:a6b:7708:: with SMTP id n8mr7103463iom.141.1552819381393;
        Sun, 17 Mar 2019 03:43:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552819381; cv=none;
        d=google.com; s=arc-20160816;
        b=NlLwBVmMvGuAzGO0vmitabnLdOIiwydjjy3XgAzc4KYBhO9YwmxCE4LRqog0k+G2nA
         JZhkNNf4DgP2PndYAGYBxqeEourn3mbkD/VOc3qkvHa0PLeawERYBdSkrIQ8JdARzLCD
         HK6HvpLebkFEEqghqugWzlO+X7+UyChF+EDkZjsGfCD//ptP4ptK5vXllfDLRiCw8yez
         CaBFYmZtt4xIJj5g18oPmkjJkRGU++6LSxIPGS9tsatig447N0R60JPjMeTOSRrWHUou
         IdnGJysJBPPC9/ORk4GN+Q16/cYIonIaS3y9ecRPp6GEYpIrkbz+muiAb3AeAPUvT4ye
         U7Ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=QSzsPUt8vxZ35tdHZ1qW8SYxaq0LFUJlh8G5w5k1f74=;
        b=x50TFO5PAoLhwz3h9/Sw7n07elqQZUJsrbdQtN74zOogDase2EdsNY9b/SbFPMyvFI
         VtaJC38mLGL9VQ9B98mZR1ap5iBBgAAm3/cFWtc0MnNH48u1GC7OoHfIGX9zeCb8Hx7I
         mxwcud+8DdyuTe925MsLuvC8t+dGd/ATaWqIyCvkIU5SgdSzx6X4t5fLxwwnZlMABcpK
         sXnMogLHnBlmljWN6xvti9MrggsY0gja9UIQfig8sNKAuIjgaYm04ffIwk8Atl6ZHp06
         Sl0h+yphrwH1FHtNAd+PBJMtfNE+OWrJ/pQVtSoME15//EU45tEy337x95CDodewQcZH
         tzAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3tssoxakbaciqwxi8jjcp8nngb.emmejcsqcpamlrclr.amk@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3tSSOXAkbACIQWXI8JJCP8NNGB.EMMEJCSQCPAMLRCLR.AMK@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id 8sor12009834itv.28.2019.03.17.03.43.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Mar 2019 03:43:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3tssoxakbaciqwxi8jjcp8nngb.emmejcsqcpamlrclr.amk@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3tssoxakbaciqwxi8jjcp8nngb.emmejcsqcpamlrclr.amk@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3tSSOXAkbACIQWXI8JJCP8NNGB.EMMEJCSQCPAMLRCLR.AMK@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqwmFgNETKk0NZNGIFDQO6tfxXsdbGSANkbo1eM0unEk2mcATYVGrz/aP6blrqkfeHH/+t9TXK5IGYK99fcL0GbKb+NEdQwr
MIME-Version: 1.0
X-Received: by 2002:a24:6b55:: with SMTP id v82mr7150302itc.37.1552819381045;
 Sun, 17 Mar 2019 03:43:01 -0700 (PDT)
Date: Sun, 17 Mar 2019 03:43:01 -0700
In-Reply-To: <0000000000007da94e05827ea99a@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000009b8d8a058447efc5@google.com>
Subject: Re: WARNING in rcu_check_gp_start_stall
From: syzbot <syzbot+111bc509cd9740d7e4aa@syzkaller.appspotmail.com>
To: bp@alien8.de, devel@driverdev.osuosl.org, douly.fnst@cn.fujitsu.com, 
	dvyukov@google.com, forest@alittletooquiet.net, gregkh@linuxfoundation.org, 
	hpa@zytor.com, konrad.wilk@oracle.com, len.brown@intel.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@redhat.com, 
	peterz@infradead.org, puwen@hygon.cn, syzkaller-bugs@googlegroups.com, 
	tglx@linutronix.de, tvboxspy@gmail.com, wang.yi59@zte.com.cn, x86@kernel.org
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit f1e3e92135202ff3d95195393ee62808c109208c
Author: Malcolm Priestley <tvboxspy@gmail.com>
Date:   Wed Jul 22 18:16:42 2015 +0000

     staging: vt6655: fix tagSRxDesc -> next_desc type

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=111856cf200000
start commit:   f1e3e921 staging: vt6655: fix tagSRxDesc -> next_desc type
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=131856cf200000
console output: https://syzkaller.appspot.com/x/log.txt?x=151856cf200000
kernel config:  https://syzkaller.appspot.com/x/.config?x=7132344728e7ec3f
dashboard link: https://syzkaller.appspot.com/bug?extid=111bc509cd9740d7e4aa
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=16d4966cc00000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=10c492d0c00000

Reported-by: syzbot+111bc509cd9740d7e4aa@syzkaller.appspotmail.com
Fixes: f1e3e921 ("staging: vt6655: fix tagSRxDesc -> next_desc type")

