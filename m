Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA7EBC76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 22:17:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1A8A21926
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 22:17:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1A8A21926
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25E076B0006; Tue, 23 Jul 2019 18:17:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E97E6B0007; Tue, 23 Jul 2019 18:17:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0834A8E0002; Tue, 23 Jul 2019 18:17:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD6126B0006
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 18:17:01 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id f22so48765908ioh.22
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 15:17:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=Wc2GRQ8gP6XwuqazuIoFspLdgI5vGhNFmUdsnDHhoCY=;
        b=oyfMyttqJB3Y3Rm1AGYNxCrmaZSi+fIVv1vSYY5Ofxyp3tbvCCjZUGG86B3Ygo6q+W
         Ze/eW+Pej+dAHu+4Tgo+U88KGvjoR6yuCcZI/7AdBt2IYDbAcMiBBWkSRb211T/MKmq7
         gigvfs7LbXr1R8jsV6/AOBaOsizEc4jR94jNnGJtTKjTxTh95hKTQJrFFtHfEl7X4zSZ
         xKy2t9mkSEv5cxsjFABlsX3SrhvBVOr9Bq1ss+yXXbhiozKWVWcDiTa9qVewpjJS0rsL
         bYO9y3thdcc90GQpzTfkEXD09RkQsHekw9P73oapc064EeUts+OG9EnMpaCZteSRQAkS
         Flwg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3xic3xqkbadkntufvggzmvkkdy.bjjbgzpnzmxjiozio.xjh@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3XIc3XQkbADkntufVggZmVkkdY.bjjbgZpnZmXjioZio.Xjh@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAUBNo2ytMldDEEPlfbRTetYzPhQcCLb3OmVQAQXJ+/ItpRslGUl
	CpGHAdsu1rtibAlD9f4WyOKLnXO9gDHkdD3EhMTSTuXV22FwXs2ng6bCNzx6CIzc+VdOdfjS0fV
	+/ie+65/+yDQWQ9ayNjcr1LQ8UagTIAL2AU7V9yvq1tksIyg+LirVqfFYTWb1wMc=
X-Received: by 2002:a5e:c24b:: with SMTP id w11mr63381876iop.111.1563920221589;
        Tue, 23 Jul 2019 15:17:01 -0700 (PDT)
X-Received: by 2002:a5e:c24b:: with SMTP id w11mr63381832iop.111.1563920220892;
        Tue, 23 Jul 2019 15:17:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563920220; cv=none;
        d=google.com; s=arc-20160816;
        b=HBAq1n+gKSQnopqtxD2TzOho4cAf0BzOFlZn3UN1lTL/2xceFPlzdHCQEl19xQG3Cm
         1mxr5D/D3zAzSH083vgCewmxXVXmvgpAt8GPODAG7X/YAyVITmBGpWf6Uzt4xLl8xJ7Q
         JUdMsE6pR9Z+eS+1SebFyCRCksVmGn5rHNsRw3NeY5CRq8EdvjEvgTMexZPXVI3wC02q
         HSVcQzKXdcMSympXz6jqARPI83UtikFqQWK9ZtoLEVPB1vwj2Jrx2kvTlNpmSUT4cIID
         1Na9PD2JrJ4swvmkKz91cU9AW8+RJqm+MfjPyOWcvCUjaAFIjJ/OlujqcM+R4WKYwCVy
         OSew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=Wc2GRQ8gP6XwuqazuIoFspLdgI5vGhNFmUdsnDHhoCY=;
        b=sA43BTuFsPiKKvaeslBKSv6+ysSpGeFZj9/VeAzt/HFVMLY70QnRZvuKbDt9x6JqUd
         I5fc1PWVIQVNtNc1mI0ZkgzvSxFRW0jkoWAo5swZUrwn3SOqg9nA0rYCsCZPgHkH1hh/
         P6QroyzwfkPQi0TAY6jp8g29hpGwGwOnqjt2F9glHRB9CGjm+sfC+RfytSQFo1yC3UfW
         BK/9idYvzbd9GmRKg9ouJzZgaqg9y3jKDCu2P1rEIDexF0ENoZZui8QfRFMfZlGJliVR
         qeLasCRUPk7qNxhl2v+xNCuxhV6Amis5/LNqiv+OnZywzm/tgtpU1UEr+vL23oBiWDVb
         T6/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3xic3xqkbadkntufvggzmvkkdy.bjjbgzpnzmxjiozio.xjh@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3XIc3XQkbADkntufVggZmVkkdY.bjjbgZpnZmXjioZio.Xjh@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id x4sor30364965iob.40.2019.07.23.15.17.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 15:17:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3xic3xqkbadkntufvggzmvkkdy.bjjbgzpnzmxjiozio.xjh@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3xic3xqkbadkntufvggzmvkkdy.bjjbgzpnzmxjiozio.xjh@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3XIc3XQkbADkntufVggZmVkkdY.bjjbgZpnZmXjioZio.Xjh@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqynAoeiP6otUFVILsXnOFuFz0uSuLj1NQooZi4V+EzbzIGh6v4AwqOrxFa7CDpPfgeCk6q5DDGEZIUetLOW5G1d8Jhge8u1
MIME-Version: 1.0
X-Received: by 2002:a6b:6310:: with SMTP id p16mr73998019iog.118.1563920220602;
 Tue, 23 Jul 2019 15:17:00 -0700 (PDT)
Date: Tue, 23 Jul 2019 15:17:00 -0700
In-Reply-To: <000000000000ad1dfe058e5b89ab@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000034c84a058e608d45@google.com>
Subject: Re: memory leak in rds_send_probe
From: syzbot <syzbot+5134cdf021c4ed5aaa5f@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, catalin.marinas@arm.com, davem@davemloft.net, 
	dvyukov@google.com, jack@suse.com, kirill.shutemov@linux.intel.com, 
	koct9i@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-rdma@vger.kernel.org, neilb@suse.de, netdev@vger.kernel.org, 
	rds-devel@oss.oracle.com, ross.zwisler@linux.intel.com, 
	santosh.shilimkar@oracle.com, syzkaller-bugs@googlegroups.com, 
	torvalds@linux-foundation.org, willy@linux.intel.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit af49a63e101eb62376cc1d6bd25b97eb8c691d54
Author: Matthew Wilcox <willy@linux.intel.com>
Date:   Sat May 21 00:03:33 2016 +0000

     radix-tree: change naming conventions in radix_tree_shrink

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=176528c8600000
start commit:   c6dd78fc Merge branch 'x86-urgent-for-linus' of git://git...
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=14e528c8600000
console output: https://syzkaller.appspot.com/x/log.txt?x=10e528c8600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=8de7d700ea5ac607
dashboard link: https://syzkaller.appspot.com/bug?extid=5134cdf021c4ed5aaa5f
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=145df0c8600000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=170001f4600000

Reported-by: syzbot+5134cdf021c4ed5aaa5f@syzkaller.appspotmail.com
Fixes: af49a63e101e ("radix-tree: change naming conventions in  
radix_tree_shrink")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

