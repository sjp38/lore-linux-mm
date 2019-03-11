Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8A2CC43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 13:08:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7433C2075C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 13:08:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7433C2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09F2D8E0003; Mon, 11 Mar 2019 09:08:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 050998E0002; Mon, 11 Mar 2019 09:08:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA71F8E0003; Mon, 11 Mar 2019 09:08:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id C2BE48E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 09:08:02 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id v12so4979047itv.9
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 06:08:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=jV0TIOFNu+hVCGZgL94GVpwyNNbbjqUpazKlNnc3uFo=;
        b=LKqfgLeCVlv4zALU324H3DjRUuWucGgJEn5UYB6ZQ6dLe371l6KgMhnYlAtCNNfNOg
         tw4esXxNhaQCsShoqPnR5MwDvaY5B0IHkMmSMYaoyhmPP0vkLx3ies7YoNgQ8eSMGoed
         xMIISflW4vS697E8G28fo6uqDobHu0z/eijywniy4B9k7vj1sINq3JbWzBXOZ9gZHAN5
         egCX1ua1capiDZBOk7iVxCa45oAj+gPKS1nRZVoHTWXJMZ6J3gZSzrOGQzHTZL6oiE3v
         YBsx9bxpJZ0GOADA8EAK0ZSOYL3fWITaVwpTLuzgry8sGVqRHcNHa6xKiWEa76LlwrsJ
         kzCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3sv2gxakbahagmnyozzsfoddwr.uccuzsigsfqcbhsbh.qca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3sV2GXAkbAHAgmnYOZZSfOddWR.UccUZSigSfQcbhSbh.Qca@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAUbxQzMSTUO4S1sooLB9KbHBmqZFhdysHR+tvFdPKsYuqsvFSjK
	i+f6tAm15qnTGty3/LsNUDOcpGJ6zM/98Bjge40NAgZGJOx53L7wTw2F87oM4HUi5KpUUPYAf8c
	V55+AMW0Q4UloMxwgvfF9swyg0MUSHOrQE6LfvoxJkwS2bYyTwQYhneH2ahNAZrPaRueS28HQGX
	SCzk8z03NW0e+lY6TkZD6WcVDIBjpRpOjBpt4ICydjYB5hwuaffLmbINEitfOw2YPoRtFNf8RIE
	pBwJBABzOUku6kiKMxA26CBjHZEHnAFASyd1ptOBfe4DwzP6IomaRcKEv3aRt/oBekRmrUjaYHc
	uJdyD9aDB+PJCo871BmhfV2S/ABs+0HnC6Nx9DFqurMkmy0+lCWTo+T5sgzXcaT/8RvoMkqO2g=
	=
X-Received: by 2002:a6b:6214:: with SMTP id f20mr15567431iog.213.1552309682607;
        Mon, 11 Mar 2019 06:08:02 -0700 (PDT)
X-Received: by 2002:a6b:6214:: with SMTP id f20mr15567346iog.213.1552309681341;
        Mon, 11 Mar 2019 06:08:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552309681; cv=none;
        d=google.com; s=arc-20160816;
        b=nH6PeRbIvfXYcnDZM7cvOwipn6C3W1ArXnII+f70n0C3ZuhgqghRVNF5eX/25jgD05
         3wiWS3k+2Jxb0pzCRaZzeX02ssbaTsa7kUHPtVbmsgrCQ2hBRzRaGNsYwiP34cYyh4uN
         3KvxfxHjOz6sfzC9oFWrzRk1onxE/LL6CRRHyZOnX7mFKeOQpeEnucaG9zc3w0J/TbxD
         yIdWfGxFUxSi3foGOp+EjX4xNsskEvHzwlVaaE7zVq9rjdPS9h+4Odc3cckhSGTO5DC+
         vRYKSqC9OqzBt91QKjYJUizfHOhbkRJM2KOCoFltGHNMB8GAZOj9YjXIuslePqoV8y/1
         z6fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=jV0TIOFNu+hVCGZgL94GVpwyNNbbjqUpazKlNnc3uFo=;
        b=syWBE80nOnQfQoZMqSX69FyTYPWNB5uuf8h/tIAu90QFydPU9rGDYNEhKgno4MsQgP
         pRUuMJOJGPnu7+2Z1JdasLIYD/higWe850XmQJ2aQbWHYiC1rAlfBP3Xk8RRToP5XT9M
         R+Qwkcg4q8KQpfLctpLdJCsnHWGQ4BLkTrlJg4tQYYNeVv6TAxGfcMsJk2X4LfczxQtD
         OdnmuWUdaJpLbjZ2OrLMBWT0kLOi3glaEvu1i9OpLVD8am2JMJIfaDXEioxCXSCsjyKe
         DPp0hF66Plf/wsxvVkbIlIEO3cFFSmlZm26Zzizrdh+IOMWUysCoZYUgrcneHVu8SlNv
         Lm+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3sv2gxakbahagmnyozzsfoddwr.uccuzsigsfqcbhsbh.qca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3sV2GXAkbAHAgmnYOZZSfOddWR.UccUZSigSfQcbhSbh.Qca@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id i13sor2722531ion.48.2019.03.11.06.08.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 06:08:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3sv2gxakbahagmnyozzsfoddwr.uccuzsigsfqcbhsbh.qca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3sv2gxakbahagmnyozzsfoddwr.uccuzsigsfqcbhsbh.qca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3sV2GXAkbAHAgmnYOZZSfOddWR.UccUZSigSfQcbhSbh.Qca@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqxMWqYladm/NuaaRcwSzK/ttla74H8jKKFHCdgh/T+j32JYKNzD0KzruYXhlxc68jbCk92jCqJ8tzbdub8vUeRjgDEPOdul
MIME-Version: 1.0
X-Received: by 2002:a5d:954c:: with SMTP id a12mr19448883ios.14.1552309681113;
 Mon, 11 Mar 2019 06:08:01 -0700 (PDT)
Date: Mon, 11 Mar 2019 06:08:01 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000001fd5780583d1433f@google.com>
Subject: KASAN: null-ptr-deref Read in reclaim_high
From: syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, cgroups@vger.kernel.org, hannes@cmpxchg.org, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, 
	mhocko@suse.com, sfr@canb.auug.org.au, shakeelb@google.com, 
	syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit 29a4b8e275d1f10c51c7891362877ef6cffae9e7
Author: Shakeel Butt <shakeelb@google.com>
Date:   Wed Jan 9 22:02:21 2019 +0000

     memcg: schedule high reclaim for remote memcgs on high_work

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=155bf5db200000
start commit:   29a4b8e2 memcg: schedule high reclaim for remote memcgs on..
git tree:       linux-next
final crash:    https://syzkaller.appspot.com/x/report.txt?x=175bf5db200000
console output: https://syzkaller.appspot.com/x/log.txt?x=135bf5db200000
kernel config:  https://syzkaller.appspot.com/x/.config?x=611f89e5b6868db
dashboard link: https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
userspace arch: amd64
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14259017400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=141630a0c00000

Reported-by: syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com
Fixes: 29a4b8e2 ("memcg: schedule high reclaim for remote memcgs on  
high_work")

