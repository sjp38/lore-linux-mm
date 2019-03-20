Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A4BFC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:49:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3660A20835
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:49:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3660A20835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5AB56B0003; Tue, 19 Mar 2019 20:49:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0B906B0006; Tue, 19 Mar 2019 20:49:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A48506B0007; Tue, 19 Mar 2019 20:49:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5BD6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:49:01 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id r136so704622ith.3
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:49:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=34TooLQdVcI8lagfhQc4CIT5WCnP1wTTjoUvFK/95jI=;
        b=VFkXWxBREwOxwwVX979tP80yf5aPrZEBRVM1XUwfYpCf/48iFvLDzejx/26ZveGvtZ
         QxmmNEh8QCG2Q5tw5dczsT+7buG7rvZJRorhYqIxb47M4sku0zOSy/yJSLLidv/KuirL
         Ai1oe7ScADBGSa2bdB7JEDNdFZu/nHdr7q5PrzeYpNolsDwh8+reAWp5voGjJwXrsQNK
         0viW/SmlRYd27yNoNX3n2tFoaZYwe8vHbgAx4vK0KCE1vWbPDqmwQc/s64CoOMF1ahxD
         jO/WSTMU7dZTDkzaSc0Iqxf2AtncEkzVO1wUkgsqXaZ647QPAu16Hqdw7QNKb6sDItzM
         rHRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3_i2rxakbaek39avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3_I2RXAkbAEk39Avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAWK35g/Uctm2u+ZaVYhjkPFa2suXkZo93NqZ79ic6eRNDUweDCi
	RFaV3wQ8NUBEmcyf+Tf8rkvqIzLruLh5PY444GvPO90p/NEL7MvAJLlkNRKrK27EU/HN1ZDDa/S
	Lc9mVdgAUsnvkOG8mSYTSSYu4ZJ0sac4/mN+EX6PzkZQo8uvjB87/GFdlfwDsRGI=
X-Received: by 2002:a24:1153:: with SMTP id 80mr3177359itf.69.1553042941282;
        Tue, 19 Mar 2019 17:49:01 -0700 (PDT)
X-Received: by 2002:a24:1153:: with SMTP id 80mr3177341itf.69.1553042940603;
        Tue, 19 Mar 2019 17:49:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553042940; cv=none;
        d=google.com; s=arc-20160816;
        b=Tl4WXrKoPcoSMjBldeNwDj31LKhpC0qOCyxe3gqNbkYrCeuRnSe6amLE6H8Bbc/WBK
         +LT32w7++xCrUofJkN1Af/T8uyqDaPMOqegoodD1B0pb734mb9VusTeSjvfdzE6oC1Vk
         kIzS728ZFq5+dgK0qw3zUcQuZ2C6H7JpxMHKwtQuxqbjb1FcIBIpZ95IEEi7wv/Jz4SR
         TpdBLEc7oEZoUxoZDRc5Zqu1Ef+MIJ/KkSLDzJGEqCTihT247eSsdQde1TYWB6qTOEvW
         XqFHNgV9FpEJdvMat83dSiHw7Z4zK9oP3MoU4TKmJhvhZ/fP+s/EdSZbU4CurvcyT0Jd
         VI7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=34TooLQdVcI8lagfhQc4CIT5WCnP1wTTjoUvFK/95jI=;
        b=r8NA7ys3fLSe6NyoCMWK974n5moaCjfEiIOSSiV84S92F0px1lfdXGHKTo+JSkA/p4
         OzEoxrtKB634o7GB2T5h0yCc45mklgKo8KdwbXOCaG6PAZ0fGF+1g5wHEE31t41X2I7M
         V18wUpwWxwrVPEvrxKp+U6B/ayFmLGEdnn4tCTW0hTbvb3jQWWUnKJjdoezZ5VfkD89R
         wmWE8wn4Lf6DVxs+ViAX8xjfL3binIU2VXqY2HB9pewk1qKjcqTh7CjCxNlPuxYGZnWC
         T5faNZNV856SgqYEy2dPZq9hy0owgWDJBk065lBrr0GfdfLldZMMPBR4rl5Rm3wkgiBv
         36ug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3_i2rxakbaek39avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3_I2RXAkbAEk39Avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id a17sor796457itk.9.2019.03.19.17.49.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 17:49:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3_i2rxakbaek39avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3_i2rxakbaek39avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3_I2RXAkbAEk39Avlwwp2l00to.rzzrwp53p2nzy4py4.nzx@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqx7zS+H4Jedbpdn1TRb3cKYCoifugmmZXSC2gmMDFAPET4Z0ljW/5N29EtJlpPvU8a6P85Fgix8M3QmQ/HQEE8qv2MLrnXP
MIME-Version: 1.0
X-Received: by 2002:a24:220a:: with SMTP id o10mr3308113ito.22.1553042940333;
 Tue, 19 Mar 2019 17:49:00 -0700 (PDT)
Date: Tue, 19 Mar 2019 17:49:00 -0700
In-Reply-To: <000000000000f7cb53057b7ee3cb@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000c7bd5c05847bfcab@google.com>
Subject: Re: WARNING: bad usercopy in corrupted (2)
From: syzbot <syzbot+d89b30c46434c433dbf8@syzkaller.appspotmail.com>
To: crecklin@redhat.com, davem@davemloft.net, dvyukov@google.com, 
	keescook@chromium.org, kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, linux-net@vger.kernel.org, netdev@vger.kernel.org, 
	sbrivio@redhat.com, sd@queasysnail.net, syzkaller-bugs@googlegroups.com, 
	willy@infradead.org, yoshfuji@linux-ipv6.org
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.004660, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit b8a51b38e4d4dec3e379d52c0fe1a66827f7cf1e
Author: Stefano Brivio <sbrivio@redhat.com>
Date:   Thu Nov 8 11:19:23 2018 +0000

     fou, fou6: ICMP error handlers for FoU and GUE

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=14a57f83200000
start commit:   b8a51b38 fou, fou6: ICMP error handlers for FoU and GUE
git tree:       net-next
console output: https://syzkaller.appspot.com/x/log.txt?x=12a57f83200000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c36a72af2123e78a
dashboard link: https://syzkaller.appspot.com/bug?extid=d89b30c46434c433dbf8
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=170f6a47400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12e1df7b400000

Reported-by: syzbot+d89b30c46434c433dbf8@syzkaller.appspotmail.com
Fixes: b8a51b38 ("fou, fou6: ICMP error handlers for FoU and GUE")

