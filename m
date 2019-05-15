Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D9A4C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:41:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50C2B2082E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:41:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="YMkmG2co"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50C2B2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF12E6B000E; Wed, 15 May 2019 04:41:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7B266B0010; Wed, 15 May 2019 04:41:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6A1D6B0266; Wed, 15 May 2019 04:41:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 73BCC6B000E
	for <linux-mm@kvack.org>; Wed, 15 May 2019 04:41:23 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id e9so295609ljk.0
        for <linux-mm@kvack.org>; Wed, 15 May 2019 01:41:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=wvnT3PULz7mp/5rmrkYmIaE3b+NEu8QwgpbJMZv7HlI=;
        b=oRP7GiUvNcFxPAOXBydE8BZ16vtyJLd8N9DEjk44DZwWWIUEhYeL3EzETV78ScafWT
         EJfA8LP1wUgXUbLgpifnF8xcNMEMIeNSY515Sw6Uq8mH+S8jMkwvFjVHOdznKF2IIzlF
         9Ze+Z2Ud4Bj/tLDGeOAHf/pYZ1sSEWjNDIu+qY/fJzlxbHSnry88PufrHLi0UxGy/F3W
         8onfd8/a2av7zYCKKlUGWsz5rgFX5NdkUdkGf5w0GCS7Lk3zTC3vX4LDN2C2hBZ+RzL0
         hpKxLrza45/BVSDkHcqwDDhTrMH8IAJIuzmPplBCb0SCdJsJ26tij9VawKTDeHs3esef
         memw==
X-Gm-Message-State: APjAAAXLpEnyMJoBjhFLRG21w9Tp7B1Gew4xKO6OQrljbQkez3oEFBwb
	LRBgc6PhGIxdt4VXeB0mCVOqqU9HRXCa1KV98WemSW5WXUD8EIqDR/yxkFY+tx0zfcGlWPSyMnr
	3m8BvmSk9k4QJbGmy9IDD2Fm8Xe31uoU4gjfjYOwojOm/XzxnqE+fgmFlWpDoT3OoNg==
X-Received: by 2002:a19:3f4f:: with SMTP id m76mr19264633lfa.17.1557909682876;
        Wed, 15 May 2019 01:41:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoC0G2lIh1YBMGsVGpHtZ9llMyVmM7XSEypG9o4OGenbnh3PQ29vERITiMKwpQHn1Ix1MM
X-Received: by 2002:a19:3f4f:: with SMTP id m76mr19264484lfa.17.1557909679557;
        Wed, 15 May 2019 01:41:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557909679; cv=none;
        d=google.com; s=arc-20160816;
        b=kxzt6/jImy+Tdw1QIlBuGwk6vf5oU+qB9AylYAIRMkVBy7HzQFu9GyXgzVn0Jwk/aF
         69ll9K8D31ewXENFKd+TkLRDtnQMBaLbLtmrqtP3q9RR5a9FHv9UOPB+ZrFBc7a2Xt8E
         YKSkcm3hXOHzBAy5BXC4bnwkR9y5GQ4ceKrvyEJ4YVDijVVzJ7kKMkKN9I/m1AqQ/yMm
         ZCb3EzBlpvwHS4dhkcTOaYI7ec2OK5pFOKqU8X4lWIh4i+tJ4c96QjQ2YroS96wF/Eb/
         6TQDMvxrRDo5Gx2SI8RJdumMnsEW4/rEXv92wOsgTxZjcZ2Wt7QCYqhbp9PrQIS3C9wf
         /4VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=wvnT3PULz7mp/5rmrkYmIaE3b+NEu8QwgpbJMZv7HlI=;
        b=Vz/4cxOie6Gc9T2U30ui0eGzQt+QiDca9Bsy9QpwOwl3WbWPzUsVIznydFGBna2YmK
         wduHqxI/JoeH1nf/2DTZUKTVCh56+c987mCUo5zauePUOmkJu0c9nm0TS5KpVPhS+I5c
         Hn6KIP2XXySjGnaDfzgAv2tbkmqPjrdCG5y2xvzYCB2fSvY9r0jelT5YkXF8/F3gF9rQ
         1MPjov6A512yonoPlgCElXXG7Fo8nZQxXGquZLV/p2rUgqvEIvgNp/S53g18aN15dXiC
         ndyGGq0vUG7/le2SWbMLBkLee4Q5i7M2OCR7xGZuiiqBdYghGevxv9ktE88wI/1nmVT6
         W0GA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=YMkmG2co;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [2a02:6b8:0:1a2d::193])
        by mx.google.com with ESMTP id s18si1088955lji.90.2019.05.15.01.41.18
        for <linux-mm@kvack.org>;
        Wed, 15 May 2019 01:41:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) client-ip=2a02:6b8:0:1a2d::193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=YMkmG2co;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 8563F2E1468;
	Wed, 15 May 2019 11:41:18 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id fGJe6SgsV0-fFwWAmiP;
	Wed, 15 May 2019 11:41:18 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1557909678; bh=wvnT3PULz7mp/5rmrkYmIaE3b+NEu8QwgpbJMZv7HlI=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=YMkmG2cooQOcVa0FiLi1MVU1FVZP2M+lDPTbbBlfsbr/FOwm+nsx7EqzTFFcRvWSV
	 ynbQAZnHcsQr4l4bHuiiUQdiV8Qpzg/7Z4sn6TGToJpcCwe8vR6+QmRClEcwZYE5Cy
	 MR1+Ep1QcQMZHH8y12Gc3P/spGChKkSK/vgqVCm8=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:ed19:3833:7ce1:2324])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id GTPPl6MHyV-fF8GxvWP;
	Wed, 15 May 2019 11:41:15 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH 2/5] proc: use down_read_killable for /proc/pid/smaps_rollup
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Kirill Tkhai <ktkhai@virtuozzo.com>,
 Al Viro <viro@zeniv.linux.org.uk>
Date: Wed, 15 May 2019 11:41:14 +0300
Message-ID: <155790967469.1319.14744588086607025680.stgit@buzz>
In-Reply-To: <155790967258.1319.11531787078240675602.stgit@buzz>
References: <155790967258.1319.11531787078240675602.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Ditto.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 fs/proc/task_mmu.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 2bf210229daf..781879a91e3b 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -832,7 +832,10 @@ static int show_smaps_rollup(struct seq_file *m, void *v)
 
 	memset(&mss, 0, sizeof(mss));
 
-	down_read(&mm->mmap_sem);
+	ret = down_read_killable(&mm->mmap_sem);
+	if (ret)
+		goto out_put_mm;
+
 	hold_task_mempolicy(priv);
 
 	for (vma = priv->mm->mmap; vma; vma = vma->vm_next) {
@@ -849,8 +852,9 @@ static int show_smaps_rollup(struct seq_file *m, void *v)
 
 	release_task_mempolicy(priv);
 	up_read(&mm->mmap_sem);
-	mmput(mm);
 
+out_put_mm:
+	mmput(mm);
 out_put_task:
 	put_task_struct(priv->task);
 	priv->task = NULL;

