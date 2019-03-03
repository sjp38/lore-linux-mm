Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE6CBC43381
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 11:33:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AD9D20868
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 11:33:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AD9D20868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3A848E0003; Sun,  3 Mar 2019 06:33:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EB098E0001; Sun,  3 Mar 2019 06:33:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B4728E0003; Sun,  3 Mar 2019 06:33:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6973F8E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 06:33:04 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id i24so2170543iol.21
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 03:33:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=fHKEKHdPjoZhYVJRZoCAKKckDq3mCm+7VXF61UEPMbE=;
        b=rscI0cV01jmbTkwuuxg4oM2CniwI0H7CRSTDYStKdm8IsSsZwLe80IUqLyymcmrDMD
         P9JQxdG564jhYeLxHY9tQ2uZxOTcmmGSzDQoyHpZsR8wCMz0h+V4ups+HV35SgS6lgn+
         C4eWt7FNnVBopgOYTEOjoMJ4jTX1OIjohADkPQlMO8inSUJRtwGvAhQovqhkh/3sANUo
         10sQ22SSB5mJnkuUxe5gw6+Vf0ZhujdzW9dNNlTIVX6porA9oL50+b5P90iM9coUSR0t
         yDkvdZ694YBOvBOsqvwByBo7n1jTpciGcHm3FTz+J+nohchWTUbswAStZgD3wJsx4v1n
         O0xw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3b7t7xakbal4w23oeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3b7t7XAkbAL4w23oeppivettmh.ksskpiywivgsrxirx.gsq@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAWiQcF+cMnY/Vy6W1W4IvtEmRiA6bz6wFRXNEoUBSlWKYhPk7LE
	BnxFJ38DYsga6lcnVTqxBePRF83sGHCd1S1Z3/8nBU+J+TRm4juYMoturVxNW4VB+k7ydkCV6SJ
	zuyYNM7yT086hffJ9hJ0h+dwOAMv/FyDNVEZ7+JV1H2Ec52Jw/t4QSSqhZr0WokjztapUoi4t3s
	a5khbJl8D4zmaFOmr8sqP/O1mrnLCTeuGF36y5YXrYWOEXLXbThWxkWBTdPoOE4m9aakhBiyBoh
	Qgu+0M9F8G8C97pQXDDriFHvnx1hpI3OEM+iaTX3dXRK3KMU6QNipq1DNAvoKtV2oUj6SvWfJlG
	y842E387ptf4B/4bOAhcMFLmjyICkoEWmShl8EJMV5t5gOQMDKFWISLOJHrurA3TJhZW9SjFqA=
	=
X-Received: by 2002:a6b:4005:: with SMTP id k5mr4168395ioa.155.1551612784098;
        Sun, 03 Mar 2019 03:33:04 -0800 (PST)
X-Received: by 2002:a6b:4005:: with SMTP id k5mr4168382ioa.155.1551612783463;
        Sun, 03 Mar 2019 03:33:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551612783; cv=none;
        d=google.com; s=arc-20160816;
        b=Gu5TqaGsZBi2EWdqTChyFXbn8nbjpmh5PHdWr4P5fy15j+UmqC0hl2P0nwEFt4hg5I
         kTEXz721zKt+u+cbth+sjy7Yi5DuDoWz7FrC6MB+4tLO9ySebAOH8GhceQwkVhiTs8Hh
         iGeXAZYu1/JanB0fcEmfdBQs1mWS2w2IWCWoNHAwvHK8jPOVpe0bhdLTKFDeiXHfR/Ju
         L1qD0Xc303mCSiHDUIGYWo8eXW3XLEFzfmqVLWHuM3Z7k8Yl10kVnP4WFKviofGNSTRT
         wSDiFsCSp9Wai6FdsIQsgqtpsGd/9bzR33jEeMOCufUN/Tp/Rwu1aDfUIPP01BHaqxQi
         /sXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=fHKEKHdPjoZhYVJRZoCAKKckDq3mCm+7VXF61UEPMbE=;
        b=BFFdBuXrBAmoELOR5ZQ7NNoV7kDhE6bSzvLNyNg3dHh9KCON4OMqxIUhPz0XRV5l1M
         jvB4uOHgJPujjTA3kMcNq7XEqFSbT3i1umO4oo5eCKZWCBKlglyVd3s+8P+eN5yK+3MN
         5yeihfYPcHayMbAcdyyAXuFrhooZl2MumCqu/+4fqHFc1stHoxJKyBNxxZOoxF6k40Mx
         EUvUk7Re+Itg8NwIw/X2wVWNsEUOYwNm1a2BFnj1Qw6EErOsXRTtO27Vcr6va3D6jYbH
         5OlSxmddRzEcSUyEnjitR0egQ/okaBEsaMA7ATjKegzsZLCj/6WrBmAz319TXozHf22k
         cLlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3b7t7xakbal4w23oeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3b7t7XAkbAL4w23oeppivettmh.ksskpiywivgsrxirx.gsq@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id 141sor4786390ity.2.2019.03.03.03.33.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Mar 2019 03:33:03 -0800 (PST)
Received-SPF: pass (google.com: domain of 3b7t7xakbal4w23oeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3b7t7xakbal4w23oeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3b7t7XAkbAL4w23oeppivettmh.ksskpiywivgsrxirx.gsq@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqz4/4YTNyniViWO8otygWcez/K22l7AxSkeB0NO/bGZvJes9HztQ6fmDFAAxS5a8QGF9AkzIqKNkCeDAx0YmWgb3UpFLeYd
MIME-Version: 1.0
X-Received: by 2002:a24:9884:: with SMTP id n126mr8530907itd.4.1551612783106;
 Sun, 03 Mar 2019 03:33:03 -0800 (PST)
Date: Sun, 03 Mar 2019 03:33:03 -0800
In-Reply-To: <0000000000004a6b700575178b5a@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000c41d5f05832f00c9@google.com>
Subject: Re: INFO: task hung in ext4_da_get_block_prep
From: syzbot <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, dvyukov@google.com, linux-mm@kvack.org, 
	mhocko@kernel.org, oleg@redhat.com, penguin-kernel@i-love.sakura.ne.jp, 
	rientjes@google.com, syzkaller-upstream-moderation@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.081974, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Auto-closing this bug as obsolete.
Crashes did not happen for a while, no reproducer and no activity.

