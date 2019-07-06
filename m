Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,GAPPY_SUBJECT,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7741C468AE
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 10:55:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFD3621670
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 10:55:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="U523Em2K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFD3621670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8817C8E0006; Sat,  6 Jul 2019 06:55:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E1E88E000A; Sat,  6 Jul 2019 06:55:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F6148E0006; Sat,  6 Jul 2019 06:55:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 236048E000A
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 06:55:27 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id s19so3487843wmc.7
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 03:55:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=7bgA3KVSNsVJyluNyhiPajryn8BOsiL4nv8POO6e3hg=;
        b=ISKL5OIv3av48LfRJ8mpAe1oJDA2/X4aPwXMsc6ikcwgyDYakHpFIPf4GbMo4zNEIu
         WxhlWoGQXxJrdya4VZ7ciS6EwB4m6n6bRaM/BoTk9RfSWNGR6ZrXN19ogadYYTWKfEmQ
         DD3a22uDkVXkDEAMWzwcsEAg70VLVrXpPy+x3w470AyrGz8mZK/LSZi4hhs787UAjtMY
         lYAyN2xg5ueYwxbFcqCCQeG+loNkKEhasoZWkutfZctyeq6Vi1oTOft88m1X32k1FbvR
         9iasUdCTArIdIEX9fB+4ZMHVnJmaTwf/78/plpik6TDPHfOKdqnlHPeqwbzWm5l4i6jz
         zAkw==
X-Gm-Message-State: APjAAAVUDH1KdIPvlTeTRWM3fPQsJHvXBn8JvFkT2AIUNYv333cQoDML
	kJv2xLHsp23Gij3FYQXr7ut6NdakWxTosBjWk1TJp2FcB91wV4ck73GAvkVFXzXTmyt/gmAleka
	d34kQmFBXwPtvPJbYCvjnecifogeaBqd5BxFcpcQjdTe77fTVyDHXeExjnTfJgfSNTA==
X-Received: by 2002:adf:f812:: with SMTP id s18mr9431566wrp.32.1562410526692;
        Sat, 06 Jul 2019 03:55:26 -0700 (PDT)
X-Received: by 2002:adf:f812:: with SMTP id s18mr9431474wrp.32.1562410525611;
        Sat, 06 Jul 2019 03:55:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562410525; cv=none;
        d=google.com; s=arc-20160816;
        b=XTEEeou3NBRn+zQ1Ds8uLt2Ot3lfDrwvSLDaroTuvG5t2wtodJOvoKTsL52D8zj7Qh
         rknGGa6FFVHH3p+W78zBlYFEC2qp2lwq79Fh++kWCNkLMtCTqA/j62HIair5Eb430HJn
         rWEHcpLmBufN64KWXcTGv3mrq5T37L6nFL7tRUkK4oI4qYsZ7GnX7rlHx7STaS368GQi
         clEWw56+C0QHh/8zep2ZJ+mNjqQau/3DU6sBBzoKXFFfdr21JyKXAV8LE46I/dFSN287
         OGuVkY+g97HD7Swq+8Zc8GCXOBo9Dwqrxk6FEbVG3ADEMHVia4viq4EAobxxkyJQUx79
         Yv4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=7bgA3KVSNsVJyluNyhiPajryn8BOsiL4nv8POO6e3hg=;
        b=Ti4y8keTJ0FDI68OPaTo7jlm2grT0tmZwtPimA22EmKlULQ1BkZ5ZHop4B7pH7l/kl
         L9+ZszAMttK/G7W9NGLwB71UHy7gAlBUIngAxUTzYHHUcMx5rQ0/glvHnPPdRIVGZraC
         dLwqZqQ2Dr3kfkf2MnuZbSapEWxcMdwNe1oLuRDhBGBG7D5POxkMEAkYchn8jXkLO4Km
         d2vlKPf9A3GhxnCYoTQhLM+JQnQb8cKesmSgIfcDbRXwOi4OMTdED5nC5/VlWN3bpC05
         +6knWUT/JsVWOga3T4oTx9YuYarAgV88ujHywkoZs1oKKhJdEeSNrfhg1Ieq4UBMNVwU
         9eaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=U523Em2K;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z12sor233388wrl.13.2019.07.06.03.55.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jul 2019 03:55:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=U523Em2K;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=7bgA3KVSNsVJyluNyhiPajryn8BOsiL4nv8POO6e3hg=;
        b=U523Em2KEtwXXxdV/BGn5jTzA7rwZNHEXsm1OcyY68qXcXEIgtM7G0Cet6d7ccvPCH
         xbNCt3TDC5HduqU/DgmJHVWSZe3KHZA5S97dUyH+Nq+WuUGuXAX0ragXjruWpmzsAxwt
         ZI947WMH7fH0XqCrCOg3eUA/2YAFkYNqtSug+CIUNQQHYURAjMXd6h9N5ALvdD0NpxEB
         AK2lAV8bchfSrDSx25gT6m0BWN8JZu//SbcHOnuqBRH2eqm3G2johuskfOsaaGz6nZlh
         deThmGjYCWPUDpw151T+5llw2TOJGBzuERv8CkChSGkkIYR0JLd+dQLERH79C+pRIoUr
         14dA==
X-Google-Smtp-Source: APXvYqzPbEUIxunmBrxyk9NAIxCXus8RCS7gBuXZApUJVMJ6c1dTQqt5X0xbeRxaG4n4nmyktigDXg==
X-Received: by 2002:adf:e843:: with SMTP id d3mr9048922wrn.249.1562410525376;
        Sat, 06 Jul 2019 03:55:25 -0700 (PDT)
Received: from localhost (net-93-71-3-102.cust.vodafonedsl.it. [93.71.3.102])
        by smtp.gmail.com with ESMTPSA id h11sm12578794wrx.93.2019.07.06.03.55.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 06 Jul 2019 03:55:25 -0700 (PDT)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Brad Spengler <spender@grsecurity.net>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Christoph Hellwig <hch@infradead.org>,
	James Morris <james.l.morris@oracle.com>,
	Jann Horn <jannh@google.com>,
	Kees Cook <keescook@chromium.org>,
	PaX Team <pageexec@freemail.hu>,
	Salvatore Mesoraca <s.mesoraca16@gmail.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH v5 12/12] MAINTAINERS: take maintainership for S.A.R.A.
Date: Sat,  6 Jul 2019 12:54:53 +0200
Message-Id: <1562410493-8661-13-git-send-email-s.mesoraca16@gmail.com>
X-Mailer: git-send-email 1.9.1
In-Reply-To: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 MAINTAINERS | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index f16e5d0..de6dab1 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -13925,6 +13925,15 @@ F:	drivers/phy/samsung/phy-s5pv210-usb2.c
 F:	drivers/phy/samsung/phy-samsung-usb2.c
 F:	drivers/phy/samsung/phy-samsung-usb2.h
 
+SARA SECURITY MODULE
+M:	Salvatore Mesoraca <s.mesoraca16@gmail.com>
+T:	git git://github.com/smeso/sara.git lsm/sara/master
+W:	https://sara.smeso.it
+S:	Maintained
+F:	security/sara/
+F:	arch/x86/security/sara/
+F:	Documentation/admin-guide/LSM/SARA.rst
+
 SC1200 WDT DRIVER
 M:	Zwane Mwaikambo <zwanem@gmail.com>
 S:	Maintained
-- 
1.9.1

