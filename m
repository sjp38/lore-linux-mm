Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5EB0C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:24:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C2A620665
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:24:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="a+ZyqbSB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C2A620665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9A9D8E0023; Thu,  1 Aug 2019 11:24:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C237E8E0001; Thu,  1 Aug 2019 11:24:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC4AC8E0023; Thu,  1 Aug 2019 11:24:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 87A2D8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 11:24:44 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s22so64831563qtb.22
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 08:24:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=O8sp7Ivz1alrz3xXygPalicyjdu3OPu+GkykS7h2DZg=;
        b=Cqq/6/DTcno2dtjUttbgfRBz31e43xl2+pnzcvFMDN4uwgwtIW1Oa62ZeoOFReMKkL
         3ozEGZcMSRYg3C7c3fv9OE/KQpvK4qoqZEL1zIbSUL+31xXACZ5Lubljy+WKORWLOyRN
         IaTXRMGxhc0P1sNFCtyvJgsvhRvqYdCCtGw0ousPOStygmBqvLEx3sKt1XjiG7MzHIx5
         b7Zrkoc/Wvft8f2NKlSsJGQbHVYPvWXxSQI/hTYh9e8GslpqwUhSdYChxYsbqP5mN0Ww
         ylDwZ18wynEMTgiMkCt3HQR0UylBTJcxsvhLYdjyDh8xq6A69FLvuPYe04un61X1kIe2
         uWng==
X-Gm-Message-State: APjAAAXkJSWVuTrpdpPEMKXh9h0WyFm8QMG1JjfKoQL73H5IPZNqCWNQ
	aZQDb+6CGx/MRMc/Y0GmukJQkSfQfRDNCwqJ8TLwlUzzJfYDvPwYHCb35229z7QzfEhQDYSwd8i
	Rx9+9IGLMeeVghxmWqeRq+f3agzAhSeTSLnIBEoQNrSXCd98lEgcLUbp65N5SnPRF4g==
X-Received: by 2002:a0c:c688:: with SMTP id d8mr2004579qvj.86.1564673084309;
        Thu, 01 Aug 2019 08:24:44 -0700 (PDT)
X-Received: by 2002:a0c:c688:: with SMTP id d8mr2004519qvj.86.1564673083558;
        Thu, 01 Aug 2019 08:24:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564673083; cv=none;
        d=google.com; s=arc-20160816;
        b=zfIKOZhitZiQAKVNwJisTbgGajDhubzLHhvfHZSg30Sp+RRNpEs96EjX/q0azD5asl
         JIIpHx87qXvUhnxZgD7M4uYRpDktWDUTG11eGARINLB35UdI3OIetnS6NQop8gPIkoDZ
         pLlSZDx92pGUDgvAY5YsOwQKT7SjfUcevQlKgV8sTQOVLgA4YH/dbmV1bH4YtOfAFVTL
         ebL+q+obku3oOotyf0g1x+1MY1IMrYy2d2aJPlugf2QBCPRe4l4GfiPY2onj+QtS8iIk
         IuCZJoYtIz0ELViJPLMyEEyKO0gj85/C2VNy6vubvWCKTgcN7K70e8VEmDf0KkFR35JU
         xPnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=O8sp7Ivz1alrz3xXygPalicyjdu3OPu+GkykS7h2DZg=;
        b=TxP2iFOn6z3LSe/eBAKpT5UkH4esplvPgcuSXiTvs2UEK3vTPXjfujWM8C7FZvWbzS
         FMyVXqhnR1AuBspqGy4y/3Myzhtujy07W0ttPbTlQS11OfFSk0O75Xix9BeUhl3gnkP5
         a1sKE5VE1Ko2JkxFWgOCXD/1M3aLB5/KkfYbZHRHZCcVRDB+qK0YpsYt2zPOMTu3WjdV
         DW3dJAUoOTghCXue2t4vEySJMlUMR1B2khm6PRtVDZwhQL/3EMYB1ATtaTe3DVjmbymL
         zQ/2BmaAVo3+7+HjuqRgIx1ZRwGWVQ5EZR+sfWOI58yy3MFRsw7sHhPfR527i6u+Xyhk
         p0ew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=a+ZyqbSB;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g41sor93267368qte.46.2019.08.01.08.24.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 08:24:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=a+ZyqbSB;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=O8sp7Ivz1alrz3xXygPalicyjdu3OPu+GkykS7h2DZg=;
        b=a+ZyqbSBLkROpB7/yFWxbV2nj0nJ9hDxmgh4mRALQnnKBGnNtH8T0nQUrv8UkRBg/i
         4WX88zAuhNmFQq77+4y9mbgKsQZx5e9p3+RTf3BDWqFUkEYmwTQiOs5gYkKye9q+UvGm
         rrW5X8jWdRpvHieYaQYWoZO7jd7RenFKNBqyDhphJmxbDqSMnHn0S9ugABAV4ojKAMrt
         WMN9dfleQMPrUVx/sM+TkzfX29W6VxjDfELNF5QfxwUOSuvm2EHT5TT4TGH3P1ovyQfC
         Tun6cAtooJ8I/i3nI/74KesTqVzHXq8LFMEI+AszpJeoxYJQBZnZJq8ze4JJS7mFJy2d
         N/jA==
X-Google-Smtp-Source: APXvYqwsbycuknfqaOcSU+c+nk0JiA4YbLBMUrdb658pVMpdB83rdKhorAeSqVY6ZrvSIKM3oMvfcA==
X-Received: by 2002:aed:355d:: with SMTP id b29mr90861643qte.12.1564673083294;
        Thu, 01 Aug 2019 08:24:43 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o5sm30899952qkf.10.2019.08.01.08.24.41
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 08:24:42 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	ebiederm@xmission.com,
	kexec@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	corbet@lwn.net,
	catalin.marinas@arm.com,
	will@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	marc.zyngier@arm.com,
	james.morse@arm.com,
	vladimir.murzin@arm.com,
	matthias.bgg@gmail.com,
	bhsharma@redhat.com,
	linux-mm@kvack.org
Subject: [PATCH v1 1/8] kexec: quiet down kexec reboot
Date: Thu,  1 Aug 2019 11:24:32 -0400
Message-Id: <20190801152439.11363-2-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801152439.11363-1-pasha.tatashin@soleen.com>
References: <20190801152439.11363-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Here is a regular kexec command sequence and output:
=====
$ kexec --reuse-cmdline -i --load Image
$ kexec -e
[  161.342002] kexec_core: Starting new kernel

Welcome to Buildroot
buildroot login:
=====

Even when "quiet" kernel parameter is specified, "kexec_core: Starting
new kernel" is printed.

This message has  KERN_EMERG level, but there is no emergency, it is a
normal kexec operation, so quiet it down to appropriate KERN_NOTICE.

Machines that have slow console baud rate benefit from less output.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: Simon Horman <horms@verge.net.au>
---
 kernel/kexec_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index d5870723b8ad..2c5b72863b7b 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -1169,7 +1169,7 @@ int kernel_kexec(void)
 		 * CPU hotplug again; so re-enable it here.
 		 */
 		cpu_hotplug_enable();
-		pr_emerg("Starting new kernel\n");
+		pr_notice("Starting new kernel\n");
 		machine_shutdown();
 	}
 
-- 
2.22.0

