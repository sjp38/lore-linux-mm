Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C44CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 23:37:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3060F218D0
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 23:37:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3060F218D0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF9028E0003; Tue, 26 Feb 2019 18:37:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7F0D8E0001; Tue, 26 Feb 2019 18:37:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A47698E0003; Tue, 26 Feb 2019 18:37:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D07C8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 18:37:36 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id z24so10547359pfn.7
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 15:37:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=466/OpdYxoDfO5xhb3pJuuAtEOS/EW5nbS3xEA6mxBc=;
        b=iGeLPavAlIUCkmS7B+lbWhN7lb9XV2TjCUO562hTNEM235S6XnybfRFcJSfDFVsKo+
         IVYUqXYOFU/HzfKu3Ox1FzZOPu0N54liZv+VZNQPbQScSv0MuvAIlfKK9un20WlfXauT
         HOpNKSjqR1DTjocX2kIZEMcqLWa5yaQvKykp7auwbKMo3SVqFQ4dzba0Po4W8xKlyMH+
         K6U15zfn74FUPPWize1tAFuXB+lZbBxprcoyeHayR4tC3qACQfwVsIfZWebs2BPl9ItY
         5plhFxGN8540Fcd7as9obRs9rPm2Dvrubx73R+8Lh5pxnuYxomi60SYOHTcm8u0gCSGo
         44Mw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuaaqINK2USnb05JJ4RcCR6RtKeLFKe/r5zZH9T01slW+v57N++7
	pXiw+lAYgTLqhs3m7IYT5/UHtbrDBhb1VPEH1Rl+LucttV8r3Zijx9zfFBWTId2xHHZU5bpOIBG
	Mhnnz5NG9nm3EFmeAAp9dDQAEv5hCGXWVFRvejHUyACys9C6ULW531xisQ/7VBZeHxg==
X-Received: by 2002:a63:6a88:: with SMTP id f130mr26640594pgc.114.1551224256022;
        Tue, 26 Feb 2019 15:37:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ8J2qTEET9tMezVh6ZZL8PmhdjXe8FgDq0SoppOYUYLTbfxHafVVo98tha767HnczQYdpX
X-Received: by 2002:a63:6a88:: with SMTP id f130mr26640553pgc.114.1551224255287;
        Tue, 26 Feb 2019 15:37:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551224255; cv=none;
        d=google.com; s=arc-20160816;
        b=mC73igbk6MEfNoU2xMAAx1zR4zIguLz2LH65+CDVEI8grvEgFtYYfDOPwBfeQNhBQA
         /C9B9fqyimKLgGj6G0mAXoJ8Ze+ouLdijim2btUpB6vXw7qZohplEBsyG2QhKyQ8u4ig
         ODLNbx2icA6iww5GTqhlI4F/s49Zcl8FkW1vzK94/cGuhlbYhSEyNOgG8FjAcvMJspls
         SceNl8VOMw8y/50WwmbGUgP1hLA6fKIvOP20UpcvwOy4jxcFiBDXKw9msMx/DZl+y41I
         lAa7uwXkiMk68LFqBbdWlP1KtFgmGXYMIXjwGwZNC4pfymLDKWdn0bINZnsKHZAFiuxl
         wa5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=466/OpdYxoDfO5xhb3pJuuAtEOS/EW5nbS3xEA6mxBc=;
        b=QmjrEJ4BBMdmTucpj3D7vyYFvPd2jDb0+xptwtAtsJ+dJYO2Ux+XK/5WZ6gMnhRkMO
         bDMcvxEp/zgCzw9qkmoIiMas68fryy2d1339nvWfbhM60vyQjNVnp3G03h7dElVGktth
         eUiTggm9yWQIblHciGnbgDRB95hd5tHPOZHX+jh96JLIEUgqmq4GN3nfZ0+dhw9orDHO
         eBu3hY9+bpmM3Hvvc7f+vp4JuzAeVOIxMxaO6uhTc7PXucFYwGWVdtX1lmhNSWNlI7dm
         TgPhIhtuxENrBS+5/ZFnQarmcOZ7lgduabg0Fq9WPw+xUFs1MUnbtTdXr1BsHn0LW/SM
         LgPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r8si13120971plo.203.2019.02.26.15.37.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 15:37:35 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 78B6A832E;
	Tue, 26 Feb 2019 23:37:34 +0000 (UTC)
Date: Tue, 26 Feb 2019 15:37:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org,
 mpe@ellerman.id.au, x86@kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-mm@kvack.org
Subject: Re: [PATCH V5 0/5] NestMMU pte upgrade workaround for mprotect
Message-Id: <20190226153733.2552bb48dd195ae3bd46c3ef@linux-foundation.org>
In-Reply-To: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com>
References: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[patch 1/5]: unreviewed and has unaddressed comments from mpe.
[patch 2/5]: ditto
[patch 3/5]: ditto
[patch 4/5]: seems ready
[patch 5/5]: reviewed by mpe, but appears to need more work

