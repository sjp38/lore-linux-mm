Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66A24C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 13:52:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 361A920693
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 13:52:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 361A920693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9CEF6B0278; Thu,  6 Jun 2019 09:52:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4D1B6B0279; Thu,  6 Jun 2019 09:52:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3BC26B027A; Thu,  6 Jun 2019 09:52:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 912736B0278
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 09:52:12 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id m1so214408iop.1
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 06:52:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=yRMkhc7yuKfa2dw31vxobwmwLPW+9z7XoM/maofKdPk=;
        b=TVXncaVIQWonQi8/sN/1qVWKNAB6XSvRTeJ344yCqacHD8HzWCVx9qgbH37gwuJi84
         gsGOFxmA0qLYAVXmDjA95lZ0WoNPtHGo94iqfAXCydfjMxGpswd6ofFdZS8uS4/3Mxng
         WzQOY1axEWYi2rvrcTllaOswhoR4kH34mTDnPcQ9R2QMvozkJR6Ww0M4kDC2H/QGS6q5
         HnjKyrWICTjohDihiov0kI0PgqgIitARzcQ1pOzTtnM2gVvEmYTgAGbrhAN4DlzA9rCj
         kMhXDhqUn/11nSEP+6/A1e3r5Pk4jHftliaYDK4LtBN+LdpCxvswOx+IIGhLHaT5OLfL
         JhLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3ixr5xakbajiekl6w770dwbb4z.2aa270ge0dya9f09f.ya8@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3ixr5XAkbAJIEKL6w770DwBB4z.2AA270GE0DyA9F09F.yA8@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAXI3GkO2zAWLx251H+gjE9lzsYl++3LzKieikapGTSGANKJI4yh
	oojMSAghNb59EvdvzPV9KxKfMH9jpN33IONHg839pg8ClI/gNRYJVc0PuGjQcsItFxLOSiiWToG
	r9arZKHmTQQTS5jqQ3eNJLTYKu8CSVy4luDAGO5mcaxut2A/ysxQ3+rKHj6lMqR4=
X-Received: by 2002:a24:1a81:: with SMTP id 123mr109906iti.46.1559829132340;
        Thu, 06 Jun 2019 06:52:12 -0700 (PDT)
X-Received: by 2002:a24:1a81:: with SMTP id 123mr109870iti.46.1559829131646;
        Thu, 06 Jun 2019 06:52:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559829131; cv=none;
        d=google.com; s=arc-20160816;
        b=ZIm7Cdr4Flird6uGBuLMo+i1VhLV6VFs8jdPxD8GrLUr/0qvlVL5K/pXFzPbPwmoAD
         dTU3G2O6Ysv21RT/CWaRY58M3sbI/aX7hfn1joZXmwxjvpe3GPaLkSi2d7SMMPOWZcpN
         GosyoqKN130XwjreRvmtqgSHpkKN4YuqDFzZUbWx0UQ1oyTu5f40gKf4SpmpiHXstzRX
         XH4qTDvDvEWtHxoyWfrb3Py/hyaYkLVT7vYk0jDaRE6g7i1Pw10m55mVS2o8ZvzV2gnR
         YmAw2ceUS9FBWoAFMulqeLfPyeJyWL2XzdvULqlM4OavBE8+hUebaTMdt21/x5eCEkME
         f2YA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=yRMkhc7yuKfa2dw31vxobwmwLPW+9z7XoM/maofKdPk=;
        b=CpCOyZgVEYG4B6gCWGhiNraxw+jR7SGPKAkeNuxmAbeb5OqQxFDbtHCHliXwRydDuO
         h8N7mN2itkauBQYuV3egz1j94ENwSLBk5V+AHSkKOyVLPI8HDf1+APCVzC2y/CqaQ2Jd
         98eRynS2CxB/QSKQMG9An7oYrCx+Le2J1pDT1VaAopSlXcV8P82J1sFboeLNKitUQry4
         vsZZjyxUGxaWalg1ZaE6+CK3UtmE/EgIsJVvAOJD7yvGBL3GfTPRm39T6skMLvzZS+8w
         u84goXdnp3+eL/gCxSeB0gzeoucEODxgH03gGYIyrtDCNj3ayOeKCVzTJ0uufilWN18k
         4CuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3ixr5xakbajiekl6w770dwbb4z.2aa270ge0dya9f09f.ya8@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3ixr5XAkbAJIEKL6w770DwBB4z.2AA270GE0DyA9F09F.yA8@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id i133sor1064853iof.39.2019.06.06.06.52.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 06:52:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ixr5xakbajiekl6w770dwbb4z.2aa270ge0dya9f09f.ya8@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3ixr5xakbajiekl6w770dwbb4z.2aa270ge0dya9f09f.ya8@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3ixr5XAkbAJIEKL6w770DwBB4z.2AA270GE0DyA9F09F.yA8@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqxsOSemHsUbujSph9lEzIDYC7+nk5LCzhefqqwo192xfbCeFrUgqyeODNjVlpcURg4PEu+WR9j7lfp6hBZjNe0whweIPjv3
MIME-Version: 1.0
X-Received: by 2002:a6b:4f14:: with SMTP id d20mr14000242iob.219.1559829131378;
 Thu, 06 Jun 2019 06:52:11 -0700 (PDT)
Date: Thu, 06 Jun 2019 06:52:11 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000004945f1058aa80556@google.com>
Subject: KASAN: slab-out-of-bounds Read in corrupted (2)
From: syzbot <syzbot+9a901acbc447313bfe3e@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, cai@lca.pw, crecklin@redhat.com, 
	keescook@chromium.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    156c0591 Merge tag 'linux-kselftest-5.2-rc4' of git://git...
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=13512d51a00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=60564cb52ab29d5b
dashboard link: https://syzkaller.appspot.com/bug?extid=9a901acbc447313bfe3e
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=11a4b01ea00000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+9a901acbc447313bfe3e@syzkaller.appspotmail.com

==================================================================
BUG: KASAN: slab-out-of-bounds in vsnprintf+0x1727/0x19a0  
lib/vsprintf.c:2503
Read of size 8 at addr ffff8880a91c7d00 by task syz-executor.0/9821

CPU: 0 PID: 9821 Comm: syz-executor.0 Not tainted 5.2.0-rc3+ #13
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:

Allocated by task 1024:
(stack is not available)

Freed by task 2310999008:
------------[ cut here ]------------
Bad or missing usercopy whitelist? Kernel memory overwrite attempt detected  
to SLAB object 'skbuff_head_cache' (offset 24, size 1)!
WARNING: CPU: 0 PID: 9821 at mm/usercopy.c:78 usercopy_warn+0xeb/0x110  
mm/usercopy.c:78
Kernel panic - not syncing: panic_on_warn set ...
Shutting down cpus with NMI
Kernel Offset: disabled


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

