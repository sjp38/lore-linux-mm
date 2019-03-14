Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA9A8C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 21:49:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E1A32087C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 21:49:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="M0OtEsjL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E1A32087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53D6F6B0007; Thu, 14 Mar 2019 17:49:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B6A06B0008; Thu, 14 Mar 2019 17:49:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B6CF6B000A; Thu, 14 Mar 2019 17:49:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF1346B0007
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 17:49:00 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z34so1699159qtz.14
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 14:49:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=c4IczZcemQJBUyUO4U++jGJlzY5GklZ2NZ3zCflWwn8=;
        b=EOlGPm8yXfjXgVaCfnmUB4j2eGQauvbJ9Kw7JDq2ujxMNow2BshU9h5FqkM8kyU8QF
         iJKDHbFohOmZXe5jyBBOEFqvlxu7MGCD06BvVwHqYEOHySzq82mHVopfGT+5XsQTbLmN
         30O9SLO3O3rfovULZa5WF/LpkMvL38OqeSMuv+L50UcfmK3EBV1Ozs8a3iYCph7Ip1cG
         M3vqa+3Qm/VVEk4Jxv8i92Dg8/ZkzYkjpp2hmSP+1xERVyS8+CaIHLWWh1S24JZjiCwD
         dyu5D8lr0xTXpQFwEKbHWptHyvDq/5doGqyzWcmSzK32U4eF9sdclxulS7bZycKOXrHh
         Byiw==
X-Gm-Message-State: APjAAAW7WmL9l1s4wEN2Fjcb7NyjBH/YM4/hhY8lH5nbs9wKhqfZ8+l8
	Xclu71cP2o5K3ofLiWSU28zdzfilXdmHTZmtWkQj3ateUbggVr4iG5tfVwBjN4RqZhgC33TNz9A
	F20B/LZrvzow6rDnQZewJA0iXb/VCZzl2aD6JFagIjP2SKLY8bz3Vdzv0cvZBiobW3g==
X-Received: by 2002:a37:4d57:: with SMTP id a84mr383660qkb.35.1552600140696;
        Thu, 14 Mar 2019 14:49:00 -0700 (PDT)
X-Received: by 2002:a37:4d57:: with SMTP id a84mr383631qkb.35.1552600139891;
        Thu, 14 Mar 2019 14:48:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552600139; cv=none;
        d=google.com; s=arc-20160816;
        b=F6rW/uQxhzLVGObWF8FkHrEf0IQRY0MdzUVuzkTIt8FlijxzCAXtGc7sxIZojLe7sC
         9QMBwpdHtScpQbMRWEySBdB91F9KHHL2iaGXax/8CXX9oHhpiSugurjPGXYg0tohAwgd
         7I16e9iJVTgvHh+V8pR9yzZ/o01Byh6ZsH9c4QRannPiIlXu6ethXnyqUbxW0MYY1Had
         84bHpshacP+mfWYuPBuIeZ+5JjUn2E871KNf9R66tyakPFVoGs67Ime6cLfTVGqAjjcO
         x6jFHPpkvKP5iPvaMEL3QGayhughUMDfrWl7yM3fXVOSvaF6PDtPpuaFDHXAWYppqh3Q
         6pyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=c4IczZcemQJBUyUO4U++jGJlzY5GklZ2NZ3zCflWwn8=;
        b=qzp4MLEMxItmYQrZMX+8mEybOODOVff89/N8xGT3uTjsjZTeHaRz/CIKfTqDZ9jGf6
         HaD4UlnV+a0YGjJZhJs1+LK6LvgODcL3nmNQUN0JHPjMExVyzOR4pvKveTnlgmfcxrpd
         0aMAO39hLW4cUyJ7P/aU0bkhb+pcIfQib3a99b2ke1xIZkDERAtnaD1Lx6Wl0f6rDs6k
         MU/teVWNAUHCYqOL3fm+8WgD+dJQW+8OG0YgF4IjFd9b3NoSWG8fLzowRBc+sY/cO36Z
         i8Rbz63l/RP4NqWf1v03BV7vGHIsDNaESfGkqkNmt0VZMQ2UcKjpwHWRSlFWg8oHpdDh
         YF5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=M0OtEsjL;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h125sor124515qkc.37.2019.03.14.14.48.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 14:48:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=M0OtEsjL;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=c4IczZcemQJBUyUO4U++jGJlzY5GklZ2NZ3zCflWwn8=;
        b=M0OtEsjLT3o1G8Q3cafkdUpSCoPUJkTZfiitOqIY/qB0DzM1YqY3uqhLBbfA9+V0Oa
         EN/oUeiAwOzo95ZkqAk9F9sAPhvGCeZSf2mLcS/e3Ycm7ncrL5R/vin/2ADy6Dd53hCM
         xxmbtuIFYjnvYBEdGJrtGL6CVVbx1a/UH0lXc=
X-Google-Smtp-Source: APXvYqxzcuUnWSzeDwWPdHSSmi1kpNflcGQvZsrcJZqSXfwdL86aFq6BWRW0Kgb3udVE8q2hNgpkyQ==
X-Received: by 2002:ae9:f101:: with SMTP id k1mr387571qkg.111.1552600139578;
        Thu, 14 Mar 2019 14:48:59 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id o19sm96827qkl.65.2019.03.14.14.48.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 14:48:58 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
To: linux-kernel@vger.kernel.org,
	mtk.manpages@gmail.com
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Lutomirski <luto@kernel.org>,
	dancol@google.com,
	Jann Horn <jannh@google.com>,
	John Stultz <john.stultz@linaro.org>,
	kernel-team@android.com,
	linux-api@vger.kernel.org,
	linux-man@vger.kernel.org,
	linux-mm@kvack.org,
	Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Shuah Khan <shuah@kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH -manpage 2/2] memfd_create.2: Update manpage with new memfd F_SEAL_FUTURE_WRITE seal
Date: Thu, 14 Mar 2019 17:48:44 -0400
Message-Id: <20190314214844.207430-3-joel@joelfernandes.org>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
In-Reply-To: <20190314214844.207430-1-joel@joelfernandes.org>
References: <20190314214844.207430-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

More details of the seal can be found in the LKML patch:
https://lore.kernel.org/lkml/20181120052137.74317-1-joel@joelfernandes.org/T/#t

Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 man2/memfd_create.2 | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/man2/memfd_create.2 b/man2/memfd_create.2
index 15b1362f5525..3b7f032407ed 100644
--- a/man2/memfd_create.2
+++ b/man2/memfd_create.2
@@ -280,7 +280,15 @@ in order to restrict further modifications on the file.
 (If placing the seal
 .BR F_SEAL_WRITE ,
 then it will be necessary to first unmap the shared writable mapping
-created in the previous step.)
+created in the previous step. Otherwise, behavior similar to
+.BR F_SEAL_WRITE
+can be achieved, by using
+.BR F_SEAL_FUTURE_WRITE
+which will prevent future writes via
+.BR mmap (2)
+and
+.BR write (2)
+from succeeding, while keeping existing shared writable mappings).
 .IP 4.
 A second process obtains a file descriptor for the
 .BR tmpfs (5)
@@ -425,6 +433,7 @@ main(int argc, char *argv[])
         fprintf(stderr, "\et\etg \- F_SEAL_GROW\en");
         fprintf(stderr, "\et\ets \- F_SEAL_SHRINK\en");
         fprintf(stderr, "\et\etw \- F_SEAL_WRITE\en");
+        fprintf(stderr, "\et\etW \- F_SEAL_FUTURE_WRITE\en");
         fprintf(stderr, "\et\etS \- F_SEAL_SEAL\en");
         exit(EXIT_FAILURE);
     }
@@ -463,6 +472,8 @@ main(int argc, char *argv[])
             seals |= F_SEAL_SHRINK;
         if (strchr(seals_arg, \(aqw\(aq) != NULL)
             seals |= F_SEAL_WRITE;
+        if (strchr(seals_arg, \(aqW\(aq) != NULL)
+            seals |= F_SEAL_FUTURE_WRITE;
         if (strchr(seals_arg, \(aqS\(aq) != NULL)
             seals |= F_SEAL_SEAL;
 
@@ -518,6 +529,8 @@ main(int argc, char *argv[])
         printf(" GROW");
     if (seals & F_SEAL_WRITE)
         printf(" WRITE");
+    if (seals & F_SEAL_FUTURE_WRITE)
+        printf(" FUTURE_WRITE");
     if (seals & F_SEAL_SHRINK)
         printf(" SHRINK");
     printf("\en");
-- 
2.21.0.360.g471c308f928-goog

