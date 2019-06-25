Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=FROM_LOCAL_DIGITS,
	FROM_LOCAL_HEX,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B34CC48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:07:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46A572084B
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:07:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46A572084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A302E6B0003; Tue, 25 Jun 2019 19:07:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E36F8E0003; Tue, 25 Jun 2019 19:07:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 880AE8E0002; Tue, 25 Jun 2019 19:07:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 66F8E6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 19:07:02 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id s83so237981iod.13
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:07:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=5XO6NDSi7o9UCx31IdKa++vNGr4w4sFZNOdIzxhXeB0=;
        b=Aj/kw4URUpxvErhX2VK3CWx6tNzee3eeX2rK04lfziIjCCaEVk2VkcGtMeSB6/IukC
         hd0cDv6iH+SKSH7O9J20PoZqTilmuyPLBbHGSrPKIAtplH2bXgC04QaHjIrYF+6eu4Kr
         Rl4qmbSOZaonubvGgXHE8n2K6p1qFrj3W502fP+htcBsMShJgHlwp9nXgfdhzRRBRuOc
         tgLJIPr5gmoec0HpngX8anu3xioEwzgIbZSstmKwKIi9sX9ju8hZFXYhyQV5QYuMlb+l
         oLa/CEecxD3CMBoZHeSngbx70jJkeEOnw4988VtSN2AxgMDtPEwaHqNwHVFPD+vr5Orw
         +Cug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3fkksxqkbaj8rxyj9kkdq9oohc.fnnfkdtrdqbnmsdms.bnl@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3FKkSXQkbAJ8RXYJ9KKDQ9OOHC.FNNFKDTRDQBNMSDMS.BNL@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAXEbwpgQJhJBctSht3/3IIxjR1l6thm0t0F3pso6WUO/lBrcZqa
	MEPDMB2/lAgKCUDkwENiluh9Mq3EAUnjZGp5822/EAbTvez78CYkJxeCYicMBcJpAypmSmlzh+l
	CT8OmrYB3/Rk/KDMJyk/9B564BXcwMT0uA4Josw6ROuDq2EkGWTeXHkIUSyDCRy0=
X-Received: by 2002:a6b:14c2:: with SMTP id 185mr1444141iou.69.1561504022206;
        Tue, 25 Jun 2019 16:07:02 -0700 (PDT)
X-Received: by 2002:a6b:14c2:: with SMTP id 185mr1444044iou.69.1561504021214;
        Tue, 25 Jun 2019 16:07:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561504021; cv=none;
        d=google.com; s=arc-20160816;
        b=uI+hIpx667z8xbGS6oGR0Wb6SeQxpN21RUUUYMnII67T7n4K2RqIG4roHkea/MXwHH
         G5sOJOF7kCTy58ofICe+vzzL7MfxBgTTbuty7Wj3TzWWcJ3fDe+t3zDGmkIPM5gtAxpg
         sQ7SGxqsmRkj5Pd3n0w22kZhY+RskmM11+qTXKLUCje9Jr6yT30Gj51atifoPYn1mC1Z
         yTKWEVaA/wf/XqLPJPOmaircgtf/WRk7X/AfOiES9ZlfGVEI+df+5ao6SJZihy0N1YA0
         TTOQ1sNyvXNELy9JRHCTN0WEP+4j9I3mq446Q17zF2QUE0MX/vqmBDYINdndqEJvksSw
         +LQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=5XO6NDSi7o9UCx31IdKa++vNGr4w4sFZNOdIzxhXeB0=;
        b=rfaF5Ypq5V6+zbWo1nB9ShojpOxTFKVD3iCP6TRXgT69WgJudEgsBliAgb9ZEHtaFl
         zLRGWnRJQRRF1CAPWk0fU1N/ZkCYGfbq61BNdtuogBDa6uGB1cHIJcGnYrYKs+PalTDb
         Yu8gP+4c7bXye5Oq8h3YFuUVJYjAFecNR1X4CG70BGETeMaH5b1C3EdVgUkm3ufE4ICz
         TlQ3lxZ4rKyThabAMLUJSUwj0HURciTXRljYmAs5RcshU35XZ5rhJXCWGjgrJxNKhMbX
         oMfiUIEgjf/sc2UYE/hCx4wbOWZuLg0H5YQysnmeJJaFy1/8fIJUI3ypIN6dJP/fhuRn
         GyKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3fkksxqkbaj8rxyj9kkdq9oohc.fnnfkdtrdqbnmsdms.bnl@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3FKkSXQkbAJ8RXYJ9KKDQ9OOHC.FNNFKDTRDQBNMSDMS.BNL@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id b2sor11615194iog.90.2019.06.25.16.07.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 16:07:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3fkksxqkbaj8rxyj9kkdq9oohc.fnnfkdtrdqbnmsdms.bnl@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3fkksxqkbaj8rxyj9kkdq9oohc.fnnfkdtrdqbnmsdms.bnl@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3FKkSXQkbAJ8RXYJ9KKDQ9OOHC.FNNFKDTRDQBNMSDMS.BNL@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqxg7Q43zU7eDdjWCJJjMc20VKLoF6D1yLiqI3SKjTQAMQ214QUyVPvfOOK+luu/cmFimcz2QkEtvpAEzFW2H5AaIqwEW1Z8
MIME-Version: 1.0
X-Received: by 2002:a5e:c00a:: with SMTP id u10mr1423993iol.24.1561504020634;
 Tue, 25 Jun 2019 16:07:00 -0700 (PDT)
Date: Tue, 25 Jun 2019 16:07:00 -0700
In-Reply-To: <000000000000e672c6058bd7ee45@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000007724d6058c2dfc24@google.com>
Subject: Re: KASAN: slab-out-of-bounds Write in validate_chain
From: syzbot <syzbot+8893700724999566d6a9@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, ast@kernel.org, cai@lca.pw, crecklin@redhat.com, 
	daniel@iogearbox.net, john.fastabend@gmail.com, keescook@chromium.org, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, 
	syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit e9db4ef6bf4ca9894bb324c76e01b8f1a16b2650
Author: John Fastabend <john.fastabend@gmail.com>
Date:   Sat Jun 30 13:17:47 2018 +0000

     bpf: sockhash fix omitted bucket lock in sock_close

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=14a4e9b5a00000
start commit:   abf02e29 Merge tag 'pm-5.2-rc6' of git://git.kernel.org/pu..
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=16a4e9b5a00000
console output: https://syzkaller.appspot.com/x/log.txt?x=12a4e9b5a00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=28ec3437a5394ee0
dashboard link: https://syzkaller.appspot.com/bug?extid=8893700724999566d6a9
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=167098b2a00000

Reported-by: syzbot+8893700724999566d6a9@syzkaller.appspotmail.com
Fixes: e9db4ef6bf4c ("bpf: sockhash fix omitted bucket lock in sock_close")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

