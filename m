Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BAFBC04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 16:30:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F31526C24
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 16:30:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="f/GyB5Aj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F31526C24
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCEDF6B026C; Fri, 31 May 2019 12:30:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D80906B0274; Fri, 31 May 2019 12:30:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C953D6B0278; Fri, 31 May 2019 12:30:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id A847C6B026C
	for <linux-mm@kvack.org>; Fri, 31 May 2019 12:30:30 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 18so8349302qkl.13
        for <linux-mm@kvack.org>; Fri, 31 May 2019 09:30:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=Q5G8+82ntOUP6LsPY/2FoFYtaIUU0yVJDral6+z2qOM=;
        b=Y5RY+AWKoA5AL77ybXcFhUoc7+1M8G3ZvBLYaZ3nG0qZMrIoEL/L0q1coqFLWebT+e
         +Tj0iSOTrqWLs9Yt/BTu+BpWAvNucwDOXzOdHC/ykIPemilGC83R5Y/Xlgi0OtP8hp9+
         p545OZSRcAT1HTPdjPm1+uw08G5tVNjDZJ4c6odNP8c4Bm8iGHo+syLUtaJ/f7qvsxUF
         JAfQTnW8SWwcO7WHyaiW1Xt9TvVnu8oMsXfUwoLRgyon+7uRE1IR2Ta5WUQgBxe18Q0H
         amicVmjEQ2gTY7S56Q8IPdNnz6oILG6rp3Hww3zHspDvsmbgZXzNm1nHmqUiJwOY95Vc
         anjQ==
X-Gm-Message-State: APjAAAVqlXa4+D46JrTzWcGtCpyYP+7LIXZasU4ijJxDkWA43GPJ2tqr
	+WsgNPtKU9TY6VlXsXC4pvWCyRw48Voa0BYSu+W849wbXrBovk+Yb13VdWSOGf6y+ViTXdgvsEx
	Jd7buGFOEOscSd6/upPVm9eFO0BjNPzZN/HP+/Z1GMGiBJLfXUu/tPd5T0w8fzokd5Q==
X-Received: by 2002:ae9:ed48:: with SMTP id c69mr9234363qkg.114.1559320230346;
        Fri, 31 May 2019 09:30:30 -0700 (PDT)
X-Received: by 2002:ae9:ed48:: with SMTP id c69mr9234316qkg.114.1559320229741;
        Fri, 31 May 2019 09:30:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559320229; cv=none;
        d=google.com; s=arc-20160816;
        b=Z7vqRGPj7ycEk6IDnNVwV5WVtqkCcPvo7Yx+ftK6sLlD+SBeZPeFiLNYH8pF0LrT3+
         qc045vbPdJGhc7WS4NUL/ow+5Z976ClKVdrWlMOEsAn+8YcCYGeFXFMsrr9eVJdjEDW4
         Z+ytaCk+aYlaMENT0fOJkTg8RF+5yW3ikfOhNHWmzWh+CkN5y9bbZ+IlX/97NJzpFVG+
         fgkyZ0aE/7kO3JBMeOrtaeex9FpSoBZpUtDb7OyaoW8ctfXdP9oO2SQr/Qj2aZlOTfjK
         ygfjkyhd/bz28uiZd7q0npXrDxk6iBwtTyaRE6EKBwneoonTOVTA5QKlUWkrD04dNFLa
         /YIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=Q5G8+82ntOUP6LsPY/2FoFYtaIUU0yVJDral6+z2qOM=;
        b=EJ2WiZULvU7onw1GPgT/8bvEKOUPm1xT3DSy9BopU+truGSINL/iBeW5hCvT6ImyFx
         MlGmhX6vN5UGObF9WpWQsaK/NawoLCWFQwPTIL/vWr4MLiB1k/VXHB5K2r3Q4Pew1eSL
         F/vAjPPG2V0MrZia6fLv4/yvpZ5l8t8nZ9B5yJhClON3VfCmCuyMGtjFhXdXK3CBzUmK
         VwJbfItv5fAEwkorDr9tS08B8TnR6o61+LjWEDPj/GC23M8H9+3E6J8cp3wnjXOwpQlE
         nVGwcGOiWp9r5IkHP7stJzMqtkOOeCR8+kjFIPdX4JVlUJ2XGUNYwYFPSU4lIHq/DIi/
         iUfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="f/GyB5Aj";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 56sor8497926qtq.15.2019.05.31.09.30.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 09:30:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="f/GyB5Aj";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=Q5G8+82ntOUP6LsPY/2FoFYtaIUU0yVJDral6+z2qOM=;
        b=f/GyB5AjpKNQpbIgXn1dL/HsR1xUokrKYkDcpzYtXRAlsDBOGwokCPAaMLbb8OnyNe
         MmXj1kMMS/VOy41vMPmph5ei+NB6KGqNIPKz/8CpysWcD6Uw8JY6UOFwLuy3/R+QJt/a
         CP7lMVo5defF9kNZhZUx134A8NolLuVAHub3M51cg6MMtyVyEF0tH38vOoGdZA84SbwG
         r+RvULz1qN+CUNW/pkVA8+YRy+bIsnl/eVz19dlVqFHFoiodl0MrGcmENHdizvbomriG
         bBJ8PzXbqczvWrUalngcVbk00UaMX+XBHoO8GgxE17t5lZgR2V/6FBe20ya6yybIiZtr
         M40A==
X-Google-Smtp-Source: APXvYqwh0MZsXG7rMTmxjY1aYZor4YQ3T8qzjntqPH4bM9WwE22dEwE5LPtml1s2IhWnws4mwHunBg==
X-Received: by 2002:aed:237b:: with SMTP id i56mr9727574qtc.370.1559320228181;
        Fri, 31 May 2019 09:30:28 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id f33sm4533179qtf.64.2019.05.31.09.30.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 09:30:27 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: gregkh@linuxfoundation.org,
	rafael@kernel.org,
	david@redhat.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next] drivers/base/memory: fix a compilation warning
Date: Fri, 31 May 2019 12:29:46 -0400
Message-Id: <1559320186-28337-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000559, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The linux-next commit 8553938ba3bd ("drivers/base/memory: pass a
block_id to init_memory_block()") left an unused variable,

drivers/base/memory.c: In function 'add_memory_block':
drivers/base/memory.c:697:33: warning: variable 'section_nr' set but not
used [-Wunused-but-set-variable]

Also, rework the code logic a bit.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 drivers/base/memory.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index f28efb0bf5c7..826dd76f662e 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -694,17 +694,13 @@ static int init_memory_block(struct memory_block **memory, int block_id,
 static int add_memory_block(int base_section_nr)
 {
 	struct memory_block *mem;
-	int i, ret, section_count = 0, section_nr;
+	int i, ret, section_count = 0;
 
 	for (i = base_section_nr;
 	     i < base_section_nr + sections_per_block;
-	     i++) {
-		if (!present_section_nr(i))
-			continue;
-		if (section_count == 0)
-			section_nr = i;
-		section_count++;
-	}
+	     i++)
+		if (present_section_nr(i))
+			section_count++;
 
 	if (section_count == 0)
 		return 0;
-- 
1.8.3.1

