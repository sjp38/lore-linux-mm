Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30859C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:10:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB52C2087C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:10:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB52C2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87C0B6B000E; Wed, 27 Mar 2019 16:10:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 809096B0010; Wed, 27 Mar 2019 16:10:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67E0A6B0266; Wed, 27 Mar 2019 16:10:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 42E606B000E
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 16:10:02 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id b16so13986077iot.5
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:10:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=M9LZ+bMimI4PbDOfuBNIBaRlNMQDprLBDf38mjJfhKc=;
        b=Uwn9wy7zDnNCMzRRQIulHdK+zmykwhGCfogw7mAEmXbXuh9aBxetNWdOjNzUQG7TJ9
         Cak4ivTeLHnh72DWAx+LBbXlMJTEXi6qwjTNSIbQUQF6/vtvsZDhbDYJaprTQ50FOKYs
         tgI7BhTNnrpsbhPRb+TOvZt6SIREBsGGgrjHVxiYg69mejt2z16EmzmEgpsn5burRJhW
         8jna+bRaI824zhuaD8mrUfNgE1Bn1ms45DnIEJ4Tx7119SEYtecs+GI/cZLIOrD5v60v
         4IA2dFoQpIj/4q80alj+6JZuobwJ53YVmcMz/mXiW7mOmxvzVl/DwpW0tt+2OOarV8pF
         E0Rg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3mdibxakbakqwcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3mdibXAkbAKQWcdOEPPIVETTMH.KSSKPIYWIVGSRXIRX.GSQ@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAXzZoIp/ZZ7j5W0R9B1tFyqzxCy6IVymC6ocS18AhXxDVI9UM2H
	Uiz1EGdq87vQDxlsVr4zCsKE1nm9ysnewASgaSEnVPWn8sad3T6yETd39ZA6XYYTqYQVVSc1LKE
	K2LfCE/tcbL+zMq602XdTpRvBBpiKiTqGSJQxqjQikxr9yxp/sLUHyhNah2aVK6g=
X-Received: by 2002:a6b:5c0f:: with SMTP id z15mr26194907ioh.26.1553717402050;
        Wed, 27 Mar 2019 13:10:02 -0700 (PDT)
X-Received: by 2002:a6b:5c0f:: with SMTP id z15mr26194868ioh.26.1553717401343;
        Wed, 27 Mar 2019 13:10:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553717401; cv=none;
        d=google.com; s=arc-20160816;
        b=ujj4kA0Ltmz1ghJlKebeOlwYOuRT0VkWaUrIYVICIsB7E4bTNit/enVHvtqIAs3gA8
         CFMEdXO9MF0RvAZwXUWjR6x+hBt6LbNX0Uw/jvXLl21P8NGJ+FIv96xuLtHNqDeLpnNZ
         z+PciZVC8XAPiAbLROuVmzgJnvGcv9MquJrqE70l0S1tluBIGAdBnBhXSCS49HmcVvZK
         HYd3yk95FZ8B4urJow5GHtUlPd4qlcX6rDNYeIImrL5kXYmOhOUClWrdWhQhz1MAnWIa
         wUU6cSYTAbPPw4KWDoB1ALKV8M8u9wtWJ5D+vCa1tjiUvW+Ul3WOXTGXOjF/hF4V8qFv
         6yYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=M9LZ+bMimI4PbDOfuBNIBaRlNMQDprLBDf38mjJfhKc=;
        b=InYZYn5B2sOJBHoaKhdNzmFutWSjS837BaRpSYnaXdX7GmtUNvDc0H93AlBUss0VUV
         LVPPrCnjft4Fiyb4wyTyljDkGTuMZ3W9sN2YSfEOT7CAFQwqAJSSoDYwDCJ7VtRHUKTR
         SJbIOnsOtsQc6Bz//LowSEBOHXeIJTzBZR6zY4S0MFqjCDG83A9wetRJrw8b27eaW6IF
         KvDcD5WfM0t94bxV/znd39bsQ1V55xf5ssWOsliR4qqXNxqRYEgAJbFsxa6cSu2wPveP
         kbgHi/PXQRskHqWbruKEFgUS3DQIXD64cfUMBSh4O1fDbOftf54bauwf36DIAEiaAWwg
         e0Cg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3mdibxakbakqwcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3mdibXAkbAKQWcdOEPPIVETTMH.KSSKPIYWIVGSRXIRX.GSQ@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id y101sor2005241ita.6.2019.03.27.13.10.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Mar 2019 13:10:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3mdibxakbakqwcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3mdibxakbakqwcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3mdibXAkbAKQWcdOEPPIVETTMH.KSSKPIYWIVGSRXIRX.GSQ@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqyDAf4ploxQXeYfC+CFYQgbOcopu+jJ1sXdRok24pSP1DcDyVjvzKS+bGYT+67jK4ftl65L/WTLJk3QASrrZ0jfVnqyzKD5
MIME-Version: 1.0
X-Received: by 2002:a24:2704:: with SMTP id g4mr1307352ita.36.1553717401059;
 Wed, 27 Mar 2019 13:10:01 -0700 (PDT)
Date: Wed, 27 Mar 2019 13:10:01 -0700
In-Reply-To: <00000000000051ee78057cc4d98f@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000c58fcf058519059e@google.com>
Subject: Re: general protection fault in put_pid
From: syzbot <syzbot+1145ec2e23165570c3ac@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, clm@fb.com, dan.carpenter@oracle.com, 
	dave@stgolabs.net, dhowells@redhat.com, dsterba@suse.com, dvyukov@google.com, 
	ebiederm@xmission.com, jbacik@fb.com, ktkhai@virtuozzo.com, 
	ktsanaktsidis@zendesk.com, linux-btrfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, manfred@colorfullife.com, 
	mhocko@suse.com, nborisov@suse.com, penguin-kernel@I-love.SAKURA.ne.jp, 
	penguin-kernel@i-love.sakura.ne.jp, rppt@linux.vnet.ibm.com, 
	sfr@canb.auug.org.au, shakeelb@google.com, syzkaller-bugs@googlegroups.com, 
	vdavydov.dev@gmail.com, willy@infradead.org
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit b9b8a41adeff5666b402996020b698504c927353
Author: Dan Carpenter <dan.carpenter@oracle.com>
Date:   Mon Aug 20 08:25:33 2018 +0000

     btrfs: use after free in btrfs_quota_enable

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=14155a1f200000
start commit:   f5d58277 Merge branch 'for-linus' of git://git.kernel.org/..
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=16155a1f200000
console output: https://syzkaller.appspot.com/x/log.txt?x=12155a1f200000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c8970c89a0efbb23
dashboard link: https://syzkaller.appspot.com/bug?extid=1145ec2e23165570c3ac
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=16803afb400000

Reported-by: syzbot+1145ec2e23165570c3ac@syzkaller.appspotmail.com
Fixes: b9b8a41adeff ("btrfs: use after free in btrfs_quota_enable")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

