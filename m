Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B970DC28CC3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 01:16:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84C922082F
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 01:16:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84C922082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 021B86B000D; Tue,  4 Jun 2019 21:16:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEC506B0266; Tue,  4 Jun 2019 21:16:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E29B26B026A; Tue,  4 Jun 2019 21:16:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id C852D6B000D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 21:16:01 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id u25so11682136iol.23
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 18:16:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=tq94hQ5Or5MBqoFOhglGdojFAqBC1MTKP/WSj5YIV/8=;
        b=Cty3+Ui3mZDLn/FXKD5fpvDWgcZOim3L6K268fk75dMGy0GUDgqABHDcvXiI+8/upJ
         vTGX2E51W93TJCHGlJ5+zrt8luafsY7SM49QyhF4IMq6obN8u3qRMckXHylnJIBFzpBw
         wupAi5xQc1KSa/XZvzVf2xLfaQ7Mv6NnklS8keOxDjMy9mnvIp6t+fTyJ/8LXVrLjdlc
         /60jUrRRd9LsWUvriEpngFGrwngqEJL0J0YprQ1CWhkGfawSllEw2cQqzV7kMeHXqeyA
         qpc0nplWBeap2jFQJez3rv+c73P20D2W2fgS5ZPlGfjYANKK7ghIYZNZ336EOEa/Q9JL
         FbMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 30bf3xakbamk7dezp00t6p44xs.v33v0t97t6r328t28.r31@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=30Bf3XAkbAMk7DEzp00t6p44xs.v33v0t97t6r328t28.r31@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAX5Yd1w5m8Et553ZFhMG62p1NF8WNy3bByf2eV9Ttz6L/lKUFZQ
	6cr2dAsk34VmdV9+jJ13a7zWCQ1zYFfNvneDGNJMLHJ9ApFTYr9T15dYWhh/IV6YTqCAF/wmtXU
	P2e5VBXlVw8TsbbyvYqAAwLKgjmH+0WCVGN2dYpl5fSgbkJGfISfJRZdJDHTVN8s=
X-Received: by 2002:a02:9567:: with SMTP id y94mr23806112jah.28.1559697361609;
        Tue, 04 Jun 2019 18:16:01 -0700 (PDT)
X-Received: by 2002:a02:9567:: with SMTP id y94mr23806069jah.28.1559697360547;
        Tue, 04 Jun 2019 18:16:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559697360; cv=none;
        d=google.com; s=arc-20160816;
        b=Drwnc/nS4D3OADYBTF3z9Psiz6qgjBJtqaQYQ9wIXLWcEH/mSkqVODhFF7c9DlhUxD
         pUerIVPEiZleUY3s9RrbNSRREQWpE0Rz0tFoNFV/HaIWQQ2PdiqUaJRFeja5S7g0vRkL
         PRiCaULczeSAsCXYKnBKBiCnbj0Spfo4kc3OJG/24SFeS/fFrGojNjjF/pUbJ+yi/x02
         BTcpuRFWVNtghRtXNnHF/cS1epbPdIPE4TkkuN9CVC9E1t6UWOdZLxbbata93oPDHUdT
         85On8BzeHi2L6ZwlAY69R28tKNJvAMlV60h+SLdx6QodsORXEM3jh9DOji9QJIqVERe2
         iE5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=tq94hQ5Or5MBqoFOhglGdojFAqBC1MTKP/WSj5YIV/8=;
        b=UwAAEsvprjTQURUTEC4wVMjOd3G3f6hel7Grk1YNBzPXCpQU1I+EaWC/V0Q07vdXt7
         PKp/vE5JsgsWmHr/IMus4w0XFUjy+FIdKnd6Kx/a3pTw0/ejQgSeP2YfSbXGHrOngPVX
         sUVOC/4759p1V/aSGRnwtIfzceRoT3BWD6u32HAF2pl7QPPMfxDKNAO6Wi/MZzQOZdji
         YM/65t3vpvSsxOrUpckGGR5BVrzA+7+Xpn+qdig6V98ZnP+BlsnFdCpYEo2eFJHQm3U2
         i9lsOKCnwKzRk4lVktCqIptvWS5xr3fjycQP+fM/1EUv6YgFa5N8kANhlOzYofwthHgx
         m36Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 30bf3xakbamk7dezp00t6p44xs.v33v0t97t6r328t28.r31@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=30Bf3XAkbAMk7DEzp00t6p44xs.v33v0t97t6r328t28.r31@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id e13sor3518644ioh.112.2019.06.04.18.16.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 18:16:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of 30bf3xakbamk7dezp00t6p44xs.v33v0t97t6r328t28.r31@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 30bf3xakbamk7dezp00t6p44xs.v33v0t97t6r328t28.r31@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=30Bf3XAkbAMk7DEzp00t6p44xs.v33v0t97t6r328t28.r31@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqyZ29aiETxQGapPeY5BBEdXLC0rlE3NJCR2G4dNoGSX9gBRxgTLHXrDZB5y+iumqWQ8OcygrjVAkKZaPDKVOogeeEOvOhLK
MIME-Version: 1.0
X-Received: by 2002:a6b:e00b:: with SMTP id z11mr6761741iog.27.1559697360239;
 Tue, 04 Jun 2019 18:16:00 -0700 (PDT)
Date: Tue, 04 Jun 2019 18:16:00 -0700
In-Reply-To: <000000000000543e45058a3cf40b@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000001d42b5058a895703@google.com>
Subject: Re: possible deadlock in get_user_pages_unlocked (2)
From: syzbot <syzbot+e1374b2ec8f6a25ab2e5@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, aneesh.kumar@linux.ibm.com, 
	dan.j.williams@intel.com, ira.weiny@intel.com, jack@suse.cz, 
	jhubbard@nvidia.com, jmorris@namei.org, keith.busch@intel.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-security-module@vger.kernel.org, richard.weiyang@gmail.com, 
	rppt@linux.ibm.com, serge@hallyn.com, sfr@canb.auug.org.au, 
	syzkaller-bugs@googlegroups.com, willy@infradead.org, zohar@linux.ibm.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit 69d61f577d147b396be0991b2ac6f65057f7d445
Author: Mimi Zohar <zohar@linux.ibm.com>
Date:   Wed Apr 3 21:47:46 2019 +0000

     ima: verify mprotect change is consistent with mmap policy

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=1055a2f2a00000
start commit:   56b697c6 Add linux-next specific files for 20190604
git tree:       linux-next
final crash:    https://syzkaller.appspot.com/x/report.txt?x=1255a2f2a00000
console output: https://syzkaller.appspot.com/x/log.txt?x=1455a2f2a00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=4248d6bc70076f7d
dashboard link: https://syzkaller.appspot.com/bug?extid=e1374b2ec8f6a25ab2e5
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=165757eea00000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=10dd3e86a00000

Reported-by: syzbot+e1374b2ec8f6a25ab2e5@syzkaller.appspotmail.com
Fixes: 69d61f577d14 ("ima: verify mprotect change is consistent with mmap  
policy")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

