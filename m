Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B837C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD4F52089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD4F52089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5222C6B026A; Fri,  9 Aug 2019 12:00:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CCC36B0010; Fri,  9 Aug 2019 12:00:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEA596B026A; Fri,  9 Aug 2019 12:00:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2016B0010
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:00:56 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id t10so1727405wrn.10
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:00:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2ehQRbT+dX4MWib6VpWUvpKlBv0GnWk2cRpIN9rEc28=;
        b=ZYH5+mu1o0O0jhxIVE5Z7n34qVdGN7Cg+hWmv/em82tmJrrhTkCI7GAaR7Mskc+N8w
         jByC2NBnyMXajD2MyudTF/frA0JQ+3nkxh7qakT4eMmQig+ABmvqZDp8nWLXpSExQA4j
         Uui91gzBIp7VIJlU7zIlWiRUWjhFySG2An0LtuID2Voe+lS0g7uTYh7WKxpsynoMVI/t
         Z7JBckJrlQYeS1+ktCHy5nxOP1eSUQ7zuSuHO4igDyir6pB59/LArV/eUhbE6kAUgqVQ
         XM0AHA+LVWwpNDEW7GJR4eFKkHgXtqJrNdxvLOfErdAPyefKS4a44h/uFpxAm+1LSG7W
         i+Bw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAX0DCyNkiA12ZDPXO0AZcZsOIzbamInTupSDra5tvT6jOoW3BQ+
	GUyRdjTl1EqPP9E5dckKjuutEU1YrvJxILS7+nYm6choVKFCFL4vfyV5LTRf08LLK+4OmtKCO6L
	QaUTrDq9dTS+ma6KRHWmhKtD+9X2en3C5pdPb8lON/fbJiNeMJfMBFAYR3D23/5AbSA==
X-Received: by 2002:a5d:4e82:: with SMTP id e2mr20133225wru.149.1565366456248;
        Fri, 09 Aug 2019 09:00:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyb+HU3S3ZUvfhaqYuePza+o28UmVy/L7h2qImYyQt5ZmA/JsYOIVBZJF2bwtzAxkirZ6R7
X-Received: by 2002:a5d:4e82:: with SMTP id e2mr20133118wru.149.1565366454937;
        Fri, 09 Aug 2019 09:00:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366454; cv=none;
        d=google.com; s=arc-20160816;
        b=qhOnmP+A9GyGI03z6eQ7FFegyaIlTFnk0fCmu3vzwmWPZ9Wbk9zoOCgi7IzdqtS1P0
         ulpmDM+4ESqork3eq/VEDIRWddA+bJJlnEFNjW2WvOfLxg2zCItvhHQXHlrhMWJho30S
         Cc8SBhV2TeEtxVo6EBWByjoF1UbifpIUjqHr8JirgcTiOKeDC5eufw2Ezn8sJ5p2EnN2
         siA9JozW0NEnXQI6QTz0koWGNCU8W3n9EfXD+JxDLgEQodMiIabj78ehDQWDaHGlTStu
         TprjJiM5piikUWI9WRxJARWFId2bt/JlAu8ZvxzZtWI/TAJhtTHrqjKZyaOeHIm3MNtZ
         wC8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=2ehQRbT+dX4MWib6VpWUvpKlBv0GnWk2cRpIN9rEc28=;
        b=Gprh1Txqqv+1K/iCWd5v5lJ4xw8f8Q3DPxLcd+38cC32Iteky9gH6Ptmt4wk/HXLtC
         w2XBiKYDw1bAzyNqF9uQi3gO71p9DxlEdExpzqrABf2w1lr9+hfgIhOR4JDqTZXpRQja
         bgogJIOsNx/i60siUTGwD7fK/k58nKpGq9QCtc8pafPZha24jY52It+Ci6dib2RbH/xS
         kIxi7qohXHokm4d+8VfKtjsmGdb1YQq8wGGisgChViTYwDyd1qoCXSsf3J9wSVQqElXQ
         +Ns5KRE6xhsJWTSf57f2funYPRlwiSvEPp3rv5y1IjQe1g+mCZVprsyeIpLJ46JEpMDH
         WeLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id b6si475249wrm.287.2019.08.09.09.00.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 5DF7B305D3D0;
	Fri,  9 Aug 2019 19:00:54 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 0C0B7305B7A0;
	Fri,  9 Aug 2019 19:00:54 +0300 (EEST)
From: =?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	=?UTF-8?q?Samuel=20Laur=C3=A9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@kvack.org,
	Yu C <yu.c.zhang@intel.com>,
	=?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>,
	=?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v6 07/92] kvm: introspection: honor the reply option when handling the KVMI_GET_VERSION command
Date: Fri,  9 Aug 2019 18:59:22 +0300
Message-Id: <20190809160047.8319-8-alazar@bitdefender.com>
In-Reply-To: <20190809160047.8319-1-alazar@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Obviously, the KVMI_GET_VERSION command must not be used when the command
reply is disabled by a previous KVMI_CONTROL_CMD_RESPONSE command.

This commit changes the code path in order to check the reply option
(enabled/disabled) before trying to reply to this command. If the command
reply is disabled it will return an error to the caller. In the end, the
receiving worker will finish and the introspection socket will be closed.

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 virt/kvm/kvmi_msg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index ea5c7e23669a..2237a6ed25f6 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -169,7 +169,7 @@ static int handle_get_version(struct kvmi *ikvm,
 	memset(&rpl, 0, sizeof(rpl));
 	rpl.version = KVMI_VERSION;
 
-	return kvmi_msg_vm_reply(ikvm, msg, 0, &rpl, sizeof(rpl));
+	return kvmi_msg_vm_maybe_reply(ikvm, msg, 0, &rpl, sizeof(rpl));
 }
 
 static bool is_command_allowed(struct kvmi *ikvm, int id)

