Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33226C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:19:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E660B2082E
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:19:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iwdoEbbn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E660B2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D7368E0054; Mon,  4 Feb 2019 13:19:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 685828E001C; Mon,  4 Feb 2019 13:19:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 527478E0054; Mon,  4 Feb 2019 13:19:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0531A8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 13:19:52 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id y6so495311pfn.11
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 10:19:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Y7C467UHY1ApxkxNkde5pS9++k5K00rvSuCeNYW/XeQ=;
        b=HsAZdHa0xwUuBBXTO4Qs2gArY8D5wYecoWba2wjkRMGA5XzXRv3v1rDldmWIPKrle+
         GR1FguUG0pa9XkcFLC5rQLEm9JS3IQkrxcvsr1Coq7KC0lqNKzkvHyGYETxwbxyvnGWf
         LH0vhuOlUfl0fajPqBvSXMwdu89PUkvx/HET4VqIdbp//NiXEd8CZoZg7akVRrihUZIW
         lTVpHPXqNaS11OIy0mGXU0A/nC7eqajd6OaDRa8/EzziFZOR3pa+o8T5/ketYbAkq50S
         tiFYMkpQbbRnyDJgQqkaMJG+u/MdSbjYdoZyPnPmPwL7fbyMRKJ7UxxHAnGhe4LDZ38c
         aHvA==
X-Gm-Message-State: AHQUAuYA1CvALa0+v4dsxCal3VD7U/rMswjhGoAp1bhLPXNDMdvAGWSR
	Lhru9guv84PjIDS4nQ8e9FN8wZlJr6hKuQnkhPQjk4yJY+L5dAL0kR1ngk1h5EfLHCEgNqqhrHL
	+fpY/wVFHJJkaIaStXnqL+93RxrjvYfKUCOfpdwR0PE0vGH+G+krcDxFsunYeY9V6lX15XCmT2n
	FaMYb9vT6dwZpe6YUpxgJJb9QUGOPJ8Oqr22aYVW5/bujCOudgTdlT4QZOGhe9sbec284c9wFNI
	fSdljftUFRyowb6hc6jSkNjdmMGmc1rstndknjBmraKa79cYd0ycWtHsgJpDIcoXQTkt/t4srvK
	s8t5enSx/435ktLD/qv4balUF91Ki+oWojsW5YSEObIyC4EcDBbkXb/l1cXUBt5h0mwB+tmbNKH
	2
X-Received: by 2002:a65:43c5:: with SMTP id n5mr653959pgp.250.1549304391651;
        Mon, 04 Feb 2019 10:19:51 -0800 (PST)
X-Received: by 2002:a65:43c5:: with SMTP id n5mr653923pgp.250.1549304390996;
        Mon, 04 Feb 2019 10:19:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549304390; cv=none;
        d=google.com; s=arc-20160816;
        b=RZJry8HzVrBwVW4RnSWtTF+Qe/+ho8J+qhszBG1sWeIX+sdqZnONCBL3wsroIgfhNi
         lgCjBKFLfMeRxJwpqGFJ4Bj5xGV/dhzUONOsQ+PgDonb/iAjsjS2DbNCb1hNGbdgWLL8
         dGrQG0qfwhmDIm+SMCBeVJvwbTV3Hz0eaTmeBg84Rl9ZDBe/YC3Vmjrfad8Jy4NW+02V
         /p/R4XBfVtXZ1idkOB4V9JUQyv2O/IyCiHa8xgIpgtLpIQoilp065WOW8e7iOv0Sv5zw
         zasGGmb1qGIr41jzzYOQLcuQL/sMDcn79GRPTMzQ88K+s1qA35dJgecFqdAX2l8m1kO5
         n7uQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=Y7C467UHY1ApxkxNkde5pS9++k5K00rvSuCeNYW/XeQ=;
        b=kF+P1MPG1R6DT3d0YvCEtmXzzCrrKnZv5NRWVUILFb2CPAl8Xc4NmJ65Qc3X43f+Fv
         mhKkLQCpLz6/GVqf3aW+mqNTddMMu3u+P4Ndt12Xi6XMXUcyP6ak3Q/STw3iiKtg1gAR
         AwljP4aTKWVNvWISB9x+A4PP23G86LLnDRyJMJX8gNNl9weeNORLYgaTx7xcjPWoMV11
         AQdK8C55PfDjV01s/ENVTGCTSXItNihjq61IRi0ZfoEzRWek74pZNza3qVfqMeoco6S8
         X7lWHu5b7NdmGcesYggOWTGzCy4wOIH6WCtjII1qcepYyDMBfPWyaZtSWDmTQqJEoSDx
         IfvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iwdoEbbn;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13sor1285518pgb.56.2019.02.04.10.19.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 10:19:50 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iwdoEbbn;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Y7C467UHY1ApxkxNkde5pS9++k5K00rvSuCeNYW/XeQ=;
        b=iwdoEbbnl4vZrbishwBQADfm0EjzsEvtHQeQ6GN0r++6qhZmzJ4ra5tLQ/peaafWbw
         GVn04HzCjogTvmqOQVez+ktoUNo643bJP+Voe3yD2BNf9GGKcUiuhld+hFM99JLyyuTy
         Yfz+Ft0DJiABsRnpy8YvYeISWquaVnSpYfsfr9te6EaUtjikDvw7UUfjGd56lzJLLwUf
         UV2OAV5ORXguYBBzpKG2kFVB0EB0xq4Vf7tQTZmqIoFZypIHOX1vmeJh7cCZkmMmUx3j
         UsBBFie+qczkJY7HzLQgkDB6dyJPnGBJ9UsDEHwX3DIS1/Cw/wbIEYGaAxVDoqrkJw9V
         wlWw==
X-Google-Smtp-Source: AHgI3IaZ5KYOLTDHY5ylXp1cXQI1eFxJVc/+W8nm45glPPlIfvBa3WiT3NNRTVLf89Oqk2rOV4wjQQ==
X-Received: by 2002:a63:3206:: with SMTP id y6mr627427pgy.338.1549304390629;
        Mon, 04 Feb 2019 10:19:50 -0800 (PST)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id d21sm811265pgv.37.2019.02.04.10.19.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 10:19:50 -0800 (PST)
Subject: [RFC PATCH QEMU] i386/kvm: Enable paravirtual unused page hint
 mechanism
From: Alexander Duyck <alexander.duyck@gmail.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com, x86@kernel.org,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com,
 tglx@linutronix.de, akpm@linux-foundation.org
Date: Mon, 04 Feb 2019 10:19:49 -0800
Message-ID: <20190204181825.12252.81443.stgit@localhost.localdomain>
In-Reply-To: <20190204181118.12095.38300.stgit@localhost.localdomain>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

This patch adds the flag named kvm-pv-unused-page-hint. This functionality
is enabled by kvm for x86 and provides a mechanism by which the guest can
indicate to the host which pages it is no longer using. By providing these
hints the guest can help to reduce the memory pressure on the host as
dirtied pages will be cleared and not written out to swap if they are
marked as being unused.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 target/i386/cpu.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/target/i386/cpu.c b/target/i386/cpu.c
index 2f5412592d30..0d19a9dc64f1 100644
--- a/target/i386/cpu.c
+++ b/target/i386/cpu.c
@@ -900,7 +900,7 @@ static FeatureWordInfo feature_word_info[FEATURE_WORDS] = {
             "kvmclock", "kvm-nopiodelay", "kvm-mmu", "kvmclock",
             "kvm-asyncpf", "kvm-steal-time", "kvm-pv-eoi", "kvm-pv-unhalt",
             NULL, "kvm-pv-tlb-flush", NULL, "kvm-pv-ipi",
-            NULL, NULL, NULL, NULL,
+            "kvm-pv-unused-page-hint", NULL, NULL, NULL,
             NULL, NULL, NULL, NULL,
             NULL, NULL, NULL, NULL,
             "kvmclock-stable-bit", NULL, NULL, NULL,

