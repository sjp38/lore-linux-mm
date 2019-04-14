Return-Path: <SRS0=+oA7=SQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4032FC10F11
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 02:55:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8A6D2147A
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 02:55:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8A6D2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 374536B0003; Sat, 13 Apr 2019 22:55:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34DF46B0005; Sat, 13 Apr 2019 22:55:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23C216B0006; Sat, 13 Apr 2019 22:55:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0EABF6B0003
	for <linux-mm@kvack.org>; Sat, 13 Apr 2019 22:55:02 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id w11so11266861iom.20
        for <linux-mm@kvack.org>; Sat, 13 Apr 2019 19:55:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=EpmA7tOPMeXxvHBfABlmb8FTDps5VZ6P9Hzfo+3xEOc=;
        b=PPj1hWnZiCSINCg/+2PxH8dGSg/V4jUsOn1qwnvglUInps6orlhUt/EU0U2LEUDM1j
         zL1ffZ/FNiU++urR+51gVezpoD4JwgP6vhXiBctz6Fa8fJ2uo8a6XemvOSw9OeYnm8wX
         IIo5dxc5wpEPKCs+rihoxVHG8689AM7VXxD10KOZqETmw/0kmmCoi9reZFO9GzO7d4Qc
         b/fVhmjRtWYO+KlipSmeSm/rY08eKlAYMZzi0fGmHZ/fcboBgEY48+4vQNQpXqLbBw/L
         TComr9cw1x7XuHeq9p35zB9NQrNhT4diNTIKDacwJeSWUQwqStSsUndsaY11LCGKxR3u
         9Erg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3bkgyxakbapsv12ndoohudsslg.jrrjohxvhufrqwhqw.frp@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3BKGyXAkbAPsv12ndoohudsslg.jrrjohxvhufrqwhqw.frp@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAULlsI70NNLivvlzcN3ruz0ZkZi4b+hnK5aDvFpkAiFpDbxy3Ox
	zaK/Q8sVkAiFndv/xdKXzD18PDUdbc4iLnMey+sOFShqb1Ej9T4u7PtGMu+GwazqEuloRnPYlwp
	6uRGL+VFIXIufRtwrlff6X7H2Vux04o/37Weo3volzwiprobHQxvLedakP1jiJao=
X-Received: by 2002:a24:4614:: with SMTP id j20mr20766187itb.72.1555210501867;
        Sat, 13 Apr 2019 19:55:01 -0700 (PDT)
X-Received: by 2002:a24:4614:: with SMTP id j20mr20766170itb.72.1555210501214;
        Sat, 13 Apr 2019 19:55:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555210501; cv=none;
        d=google.com; s=arc-20160816;
        b=sqXKoqKeKsUSP8DPBErgDrp1DPddoNMRWHhQ58M+DtEBIXyfEo0DvAKrcYfWqB5RLi
         NQFNE7cQU3obkVYIg2ebZ1DC1RwRQ/99L9H4evIRQvUeKtH9ptsTnWtucfHRgcOaxO3S
         jL0OQBOjuyBxwk+Ifilj2+djx6fJaFSws+5V0B3xASJQAaCbm6L+HNxef27+hGZ2Ssji
         rePkY7KNIBtBJmY+7psVOcCnoMx1+Fa+i1ZqVxNcXECqYFaSMUvYEDzBXTTkOnMhaY1z
         s9udNsTXAPrx3lUX1jVCQLhOwsQKjFoxA7ShBo45TWYh40ieAo4mlH2HAkrnqYaAO3u6
         o7gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=EpmA7tOPMeXxvHBfABlmb8FTDps5VZ6P9Hzfo+3xEOc=;
        b=N00oUjMCWbsk3oUNtvHvecFa3YrQUu9LVXAIpfnLfi/kxINq1b17Ps1CsG80dZifga
         lH6J2reIfBhEot5qYRRtgZBbyZo/8pRvQ3Yq5q7OASS7Ls656zVoj0WsazhO5w1IVJXd
         FehG+mogOsnVSFeLbeARQdmakY9se653Js9JGuqgI4gPUqF51wgz9gtKI5Udh4tuZmfr
         kFylRjfDoDO1u36VDwxOZ33g1dFkyCP1Wg8OCertoQm9LC9AFwOn29Bt7qP9VWNavpcr
         UOpoDWZQBAkbXmgSWsNKnKrjYLgasoS3G0tqKLrj9zaR3KhjYQb2kZ6gAIMqkRhngWaZ
         pULQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3bkgyxakbapsv12ndoohudsslg.jrrjohxvhufrqwhqw.frp@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3BKGyXAkbAPsv12ndoohudsslg.jrrjohxvhufrqwhqw.frp@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id q140sor20814511itb.26.2019.04.13.19.55.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 13 Apr 2019 19:55:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3bkgyxakbapsv12ndoohudsslg.jrrjohxvhufrqwhqw.frp@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3bkgyxakbapsv12ndoohudsslg.jrrjohxvhufrqwhqw.frp@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3BKGyXAkbAPsv12ndoohudsslg.jrrjohxvhufrqwhqw.frp@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqzxNqYArsgazGGOVEkorCoGxLAaBWKxHsEiTFGk8Oo2mZx5TvxIT9Dm+TrXC2QKEJLPhy/K+Offgzn9+L2tgZqNzDaG9X15
MIME-Version: 1.0
X-Received: by 2002:a24:6f81:: with SMTP id x123mr4742934itb.29.1555210500891;
 Sat, 13 Apr 2019 19:55:00 -0700 (PDT)
Date: Sat, 13 Apr 2019 19:55:00 -0700
In-Reply-To: <000000000000e02bf505866414ae@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000074e9d5058674a94f@google.com>
Subject: Re: INFO: task hung in do_exit
From: syzbot <syzbot+9880e421ec82313d6527@syzkaller.appspotmail.com>
To: amitoj1606@gmail.com, ap420073@gmail.com, avagin@gmail.com, dbueso@suse.de, 
	ebiederm@xmission.com, jacek.anaszewski@gmail.com, 
	linux-kernel@vger.kernel.org, linux-leds@vger.kernel.org, linux-mm@kvack.org, 
	oleg@redhat.com, pavel@ucw.cz, prsood@codeaurora.org, rpurdie@rpsys.net, 
	syzkaller-bugs@googlegroups.com, tj@kernel.org
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.002950, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit 430e48ecf31f4f897047f22e02abdfa75730cad8
Author: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date:   Thu Aug 10 16:28:09 2017 +0000

     leds: lm3533: constify attribute_group structure

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=15f4cee3200000
start commit:   8ee15f32 Merge tag 'dma-mapping-5.1-1' of git://git.infrad..
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=17f4cee3200000
console output: https://syzkaller.appspot.com/x/log.txt?x=13f4cee3200000
kernel config:  https://syzkaller.appspot.com/x/.config?x=4fb64439e07a1ec0
dashboard link: https://syzkaller.appspot.com/bug?extid=9880e421ec82313d6527
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=149b89af200000

Reported-by: syzbot+9880e421ec82313d6527@syzkaller.appspotmail.com
Fixes: 430e48ecf31f ("leds: lm3533: constify attribute_group structure")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

