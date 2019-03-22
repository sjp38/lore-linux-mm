Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6540C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 09:36:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BA45218D3
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 09:36:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BA45218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09C596B0010; Fri, 22 Mar 2019 05:36:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 025A06B0266; Fri, 22 Mar 2019 05:36:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E57A16B0269; Fri, 22 Mar 2019 05:36:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id C53576B0010
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 05:36:02 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id a7so1279862ioq.3
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 02:36:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=6UX/TgGDLibE8vTJYl3LV3CO8yMVAlVvPPDilbU+4Xs=;
        b=PizipCiZgk/b1MeLvgnJTGx6KHBrANn2CEQBpTyexersY/GJ7V2Tmm8picDxKmRFqC
         xtRsPx6+IEArsBR5K8//RCb6YaL8cL5NVTaaI6IxNoEIiiUNEK+nKxNzKgNYPM2c5JXS
         WgeTkPtKwyn9HX4B8kzcobHC9+lwxOinvD5YkUxqKrvpqpyoiKH4Y5z8FmbpDajm74hO
         JFkCVXoix0i/hgsuZPdUR7AvC9VZwPwYI1u1XwHeYmupDW7LrYlIotQiDf4sUNs+HqfK
         DmKyIpCpCkEvQKvtnWmTxJjVc9+qx1h/oLlxbH8bsKox4oHpbkUbs4XHnTUS44s4qf+G
         0xPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3gayuxakbabggmn8y992fydd61.4cc492ig2f0cbh2bh.0ca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3gayUXAkbABgGMN8y992FyDD61.4CC492IG2F0CBH2BH.0CA@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAX7zsGLdtRd0ExzY3dltQpIaQe+kL9vN6FNE+BQd9zA27ba94i3
	OlEwEGx3Ug3KXltQgjEH+c6IOa2p+HH6WRnBjS9cGRojsNAwNrzWn2hjXNy06dDXdx6Ft4Uph7W
	O7CD5wuCztO5A7xPyBsbzVB7Me8iejwNY3dOgsw7Un1GTv/l1r1B0Ae3b4PKZ1Vc=
X-Received: by 2002:a5d:8d93:: with SMTP id b19mr6329403ioj.54.1553247362528;
        Fri, 22 Mar 2019 02:36:02 -0700 (PDT)
X-Received: by 2002:a5d:8d93:: with SMTP id b19mr6329365ioj.54.1553247361481;
        Fri, 22 Mar 2019 02:36:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553247361; cv=none;
        d=google.com; s=arc-20160816;
        b=q8DOLHtAbmbAyL7IZM8VFgH0DyHtwgLdNFnfDfFZ6b4ekkI0EPD0GBYbxKDESLraQ8
         thQt8dEUALc+ySVqUaqCowxB5Su1+v1qPYOXltzqHNHx0Zbbqkjdzsl/zOXbh/VIauVj
         dBbIjscWbRNunISLwIRxQB8r8OOyBLL1tl99EOeU5TXBfrExPWFFEUbXOyjHYJ65dvlT
         DJEUy2wIg6x9UutJqowSxAwhoRvNnKcgiO1Mohbibvbmg6zc6aXtCyDVLyPV3euJ+oMi
         3TUsILKqwXeoAK12cnhYsUpnqqJK7ohWmMiC1hT/r4U+uoyAJRYZKypbc93bo+1gzJFZ
         /BpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=6UX/TgGDLibE8vTJYl3LV3CO8yMVAlVvPPDilbU+4Xs=;
        b=lLqqtipKvaaXkBVepzXjRC7ZQIic+tgEJhL9XA5/SwnlOB2QUPUnJ0CPuhjkRVhj1g
         7HGFpLMKXQGMV0KcPHuF22kmgM9S4/jrsP7G+Feur7YxYqtOPQrzkM9yv5AuwHRzrcib
         waN+7ezlQzs945CdcsMPal+C69K/+LnGbuzaVav7xx6B7fHOalhp0XJv30ZOWgJarkGT
         fOlfa8ymOuSkOradlgdqAXE9tXCCu/k8OdL+0ybQ3HoZoiRfnXdSYUr2wp8UZV6aA9Mf
         JG9W9+jlURbNnYa642+Q+tGXiZuHHPOy3O2hHJ1r97NGo+4EdtpWsFtX8sEV1oUbXlIB
         454Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3gayuxakbabggmn8y992fydd61.4cc492ig2f0cbh2bh.0ca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3gayUXAkbABgGMN8y992FyDD61.4CC492IG2F0CBH2BH.0CA@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id k5sor5489991ioc.64.2019.03.22.02.36.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 02:36:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3gayuxakbabggmn8y992fydd61.4cc492ig2f0cbh2bh.0ca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3gayuxakbabggmn8y992fydd61.4cc492ig2f0cbh2bh.0ca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3gayUXAkbABgGMN8y992FyDD61.4CC492IG2F0CBH2BH.0CA@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqzMAvq5h5tuI8AFCrBQB9bsrog7Ubvr5HoFyyOpwxjOaS0CGLcPugujchKTBIdK8BoQ36vtRG4nBXk8UQdBEqmLQ/eiqzRQ
MIME-Version: 1.0
X-Received: by 2002:a6b:e307:: with SMTP id u7mr6079118ioc.208.1553247361157;
 Fri, 22 Mar 2019 02:36:01 -0700 (PDT)
Date: Fri, 22 Mar 2019 02:36:01 -0700
In-Reply-To: <000000000000601367057a095de4@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000035d0e70584ab952b@google.com>
Subject: Re: KASAN: use-after-free Read in get_mem_cgroup_from_mm
From: syzbot <syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com>
To: aarcange@redhat.com, akpm@linux-foundation.org, cgroups@vger.kernel.org, 
	dvyukov@google.com, hannes@cmpxchg.org, hughd@google.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, 
	mhocko@kernel.org, peterx@redhat.com, rientjes@google.com, rppt@linux.ibm.com, 
	rppt@linux.vnet.ibm.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, 
	vdavydov.dev@gmail.com, willy@infradead.org, zhongjiang@huawei.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Bisection is inconclusive: the first bad commit could be any of:

2c43838c sched/isolation: Enable CONFIG_CPU_ISOLATION=y by default
bf29cb23 sched/isolation: Make CONFIG_NO_HZ_FULL select CONFIG_CPU_ISOLATION
d94d1053 sched/isolation: Document boot parameters dependency on  
CONFIG_CPU_ISOLATION=y
4c470317 Merge branch 'sched-urgent-for-linus' of  
git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=1592b037200000
start commit:   0072a0c1
git tree:       upstream
dashboard link: https://syzkaller.appspot.com/bug?extid=cbb52e396df3e565ab02
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12835e25400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=172fa5a3400000

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

