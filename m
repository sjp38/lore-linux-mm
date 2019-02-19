Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 927DAC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EEA920818
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rGxa/fcU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EEA920818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C39158E000C; Tue, 19 Feb 2019 05:33:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B75318E000D; Tue, 19 Feb 2019 05:33:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C6AB8E000C; Tue, 19 Feb 2019 05:33:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70C4E8E0005
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:33:04 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id x9so3661440ite.1
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:33:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=Xzoq3822VPftHOSX/XRMpwACoEFrdDki2itBY3y0uPM=;
        b=I8utZwxFWg8E5YtVmxug3SqvVYm0QUAGSf5CJmlH27RZbtQBjaban+BW61vJkXTADz
         I579WsJzOQWH//qZuT5oLTbcNuvhlpKtLuv/XDJmIIdl3gGs4RSD6n0xng3opf94ykC6
         lMjL+xIQuq9MJFrn4VnGFhZLR0FjiEbmw3Hura/+NV8Teg7jrcW6JLagNciL0V8oKQUl
         knngt6GAcCcqrS3AlusY/h5TYMXKrgJEjZtbYp0+euucoGNxGVTvQ/A1aKMlGtiz8cpi
         tKTd35PvxYRqfE0d+L/GoFpVa2MByQDp1bVoXPlIPi+I5ZXT/1W7qoQ5HkKMQuU0nIOm
         UE1g==
X-Gm-Message-State: AHQUAubUNZxRws125k62iUOf0GuVgQsVWOmR9UJs/bYvHklfnPg0Je9f
	i1BwRubLidvmxg7WtRL+KqnGdWhlWhuw6xU1ujxCQXWK3Z6D8i1GZ7pVlN+PZrOLjddFi0O00Wm
	HS6kL375sONms6N5duJNZqtdB0lLIWdsaJMkFGV9H2gUsaRM8kqosFtGXr9NzhSU1bQ==
X-Received: by 2002:a24:7a84:: with SMTP id a126mr1692943itc.21.1550572384246;
        Tue, 19 Feb 2019 02:33:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY8kjb6ZMJr+sqIHOfDsfhc9MfhGR5itqlPHPu5ASV7XzRdX0UlxSMRDvs9B3B/uTKI0/gE
X-Received: by 2002:a24:7a84:: with SMTP id a126mr1692914itc.21.1550572383624;
        Tue, 19 Feb 2019 02:33:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572383; cv=none;
        d=google.com; s=arc-20160816;
        b=G1LB0dmu39nmtNaFq1KySITvaCXEIQ+6J58LL05zGw81bxI+HX/Z/opiXhQ+9yIIxe
         I4JduuhRDr+h+KLwGnKuBetLjQVfUU5+2Fk/y7NOZQQ1O2RsFFjH4KUT5dQm6HdOPv/6
         IFL4Bslg/yoqY6KYPRlxDx1uq1ZOwgtVJrSu0b8lc70e4leVUmKw4Y2lBaIyJ9BS6XjX
         gcW5Ms0IwF19wHEW5LR+Ahb6KhXonRGneKAYMO+FwqCo+4hx4wiYwCfxuftYIccd13rA
         lVTpzLzstZHl/C/cV6T9Jnk76csm2sLRDXE18ECrT7RxfBS7lQJpGK0WpT9CtcR7mJwn
         js7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=Xzoq3822VPftHOSX/XRMpwACoEFrdDki2itBY3y0uPM=;
        b=R0oGGq5DYfRZcOsiQv55Ccj+trjTBbLWcCddDhj+i0STic0O9RJMS4Bwm1iNvN1ujk
         nCdoYF+LFlM8WtiPmZJHH61I52nz8bJcNEL8oQIUpstXMKjMqhfCbtmHcZV0Cu/baiKO
         dTGpUWCvNzmlUxj53Lj5FP8TG849JX8cP8mujEd5KkuiTTJZzxaBSMAPJcUbJNOyKzuM
         N36iQ80irnRxTWy0OBWIVDCiLM9VtDQgM1ZcS8GxTCw1ZW/GkIkof6VdAvhJDOySIMdL
         /AZFeIZbxE8fCFoYdEZ7jENrDTQsR2MQQE1wvjpbNM/gxCjRNRh5ZSrGxfA7kItVT5lp
         KSkw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b="rGxa/fcU";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id j197si1036771ita.49.2019.02.19.02.33.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:33:03 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b="rGxa/fcU";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Xzoq3822VPftHOSX/XRMpwACoEFrdDki2itBY3y0uPM=; b=rGxa/fcUPtcZpXT5CV7qV8y0/4
	M/Fj8EB0WmOLN0suzx92w6QVbQn4Wkx4dbJUZdJLuz3GpgbNguH9ijZ6m5p97OIOA3FVErUQ64h3I
	R76XxI/m15st9xBUJqAvMoXQDJ/Eb2so7FbudtAIogDG48JEWxB6lYHPFgR4xj1bEfJdow8fcIZZR
	UwXo0Tkr9omxjLd1HoVT/OFxOd2Til3bkNtbnw63ae6nzQqBp42O8MYSSDyOx9VoYxmq2DYw2oIpN
	rAFeiMneF2AxjVtYwN6R+/aHONB3UdZAXoswzn2foFmmUWJkJqdOPvFQRl3YiBepiDCvEYDekTVM9
	op1RG5Rg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2hn-0000dj-UE; Tue, 19 Feb 2019 10:32:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 59AEA285202C8; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103233.207580251@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:31:54 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: will.deacon@arm.com,
 aneesh.kumar@linux.vnet.ibm.com,
 akpm@linux-foundation.org,
 npiggin@gmail.com
Cc: linux-arch@vger.kernel.org,
 linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,
 peterz@infradead.org,
 linux@armlinux.org.uk,
 heiko.carstens@de.ibm.com,
 riel@surriel.com
Subject: [PATCH v6 06/18] asm-generic/tlb: Conditionally provide tlb_migrate_finish()
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Needed for ia64 -- alternatively we drop the entire hook.

Cc: Will Deacon <will.deacon@arm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@gmail.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/asm-generic/tlb.h |    2 ++
 1 file changed, 2 insertions(+)

--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -539,6 +539,8 @@ static inline void tlb_end_vma(struct mm
 
 #endif /* CONFIG_MMU */
 
+#ifndef tlb_migrate_finish
 #define tlb_migrate_finish(mm) do {} while (0)
+#endif
 
 #endif /* _ASM_GENERIC__TLB_H */


