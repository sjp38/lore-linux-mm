Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C66E7C282CB
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 01:17:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 713BE2183E
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 01:17:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 713BE2183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rustcorp.com.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6F5F8E009B; Tue,  5 Feb 2019 20:17:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1F018E001C; Tue,  5 Feb 2019 20:17:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0D568E009B; Tue,  5 Feb 2019 20:17:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 689718E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 20:17:44 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 74so3980314pfk.12
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 17:17:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=6npO0/DTcwgy3uDM0b70llZh5hUhZ1HHmCQHbbkyEfA=;
        b=cvaM5B+FWy1jlfQlPkPPC/dCPmsdKHb91tPPSJePb+hrim2eJEYC1dePuLJ2s/rhqK
         SVV11p2m/AJFU8ESdle920rHGZs6mbjL5LHEFFgtRQTC3VUbuCZ9dBkipd57PQlc6ETE
         G/iXfkZXIdqBbTiLc9vLiJITOIprlIzVjLgJcseYLk6XcqqWrzgn+OWIFMVKR+/pZEUM
         CxVCjioV0QzYsCAusPiTFOf01P/MV4zoyJ9F8oQ17iglIGm5Iv6Q+0kzJO3mWFQmiO1L
         5LQYYavAa71O1fCQjioWZ14vL6t5SNAtdonzM7jTwxlSrt1NbwFL9FOw7jMXiYBTldw3
         wmaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rusty@ozlabs.org designates 203.11.71.1 as permitted sender) smtp.mailfrom=rusty@ozlabs.org
X-Gm-Message-State: AHQUAuZ2IsG90MUeMhRkhFY6TX3PeV3PVfGSNGX6Z8MQF2ixBY5ct32V
	z4NTaDqqtH/h06ou4bnanovRUE98d8lSh5e7LLrybeHlG+vnsrhZ6wPPFTeozzu2VAMRX+drGm1
	xteAD4IoXt4LCk019L6nzJtADZD0ksU3Gw2DmjbXXz5e40icPumZW5EGQaSADXno=
X-Received: by 2002:a62:5486:: with SMTP id i128mr7716921pfb.215.1549415864074;
        Tue, 05 Feb 2019 17:17:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ6aOgTYkMxiNF7kSstJHFuQiPH+CNXyfWzjMno4rmyU8+OcyF8qNr6fgbj3KKROsvBN2jC
X-Received: by 2002:a62:5486:: with SMTP id i128mr7716882pfb.215.1549415863406;
        Tue, 05 Feb 2019 17:17:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549415863; cv=none;
        d=google.com; s=arc-20160816;
        b=Mc1m1cOoojCF5iDqaM61RW7uThf+uOkqvQSpT3K95KllFg1G53l2dwriEpdUUCBEgQ
         FZoCb7Bxnxp+jJ+xH4AIv0OkMs3Af24Wgx+msk25obyPrZKlSz7kAUl7EcCvKy6u9rmp
         CQzRF+STWGf2aa2q8ysdQb2WlcSSD/fYg0eGtkW5FMmEgemmXORF809hmOUdXXFMHByb
         0Jbozr9pCecNgdbQ1bKtRgKcWjZNCHu5r9cg7kTlighcquD82gEJpIBYE0DL88sx8h28
         8RC5bilsSzbwUWg1jXEWpkZzUr4+BpjELUeRJxD3sQe47vozQwQBleCuKCibFTpJA3qZ
         MuiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=6npO0/DTcwgy3uDM0b70llZh5hUhZ1HHmCQHbbkyEfA=;
        b=Kh5L++MxZgjqRXE5X+bCfZZQahoDwe/kuRu9kMKXCVWv70mQDDbhZ+GOdoBDdq2q0o
         gh7Lon9qdRrK7uEsfzWh+7NM9TopdTu0GknSj8kGvC9h7INxUovhgjuXgQlzzH0lF8sL
         2FWIR/BOShB+XRdm7ssv7Bjp5XmTWpVYtI5Cbh3X89fF43GP3JPiWfXrjOfgZOVXuZAH
         t+ImRQ75LwkQxqX6dSs3lmgcyy0YIcr+CMBOZSOdk/pJQdTwRJ7nDqezAeulK14uz/qP
         0cZOvwoPIs6VfLOisLBa6I1zTlVFtfV2Sy0Fr9kk3VxnppxBgaUq39woWpqlre8SSzha
         9+9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rusty@ozlabs.org designates 203.11.71.1 as permitted sender) smtp.mailfrom=rusty@ozlabs.org
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id j5si4277911pgq.82.2019.02.05.17.17.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Feb 2019 17:17:43 -0800 (PST)
Received-SPF: pass (google.com: domain of rusty@ozlabs.org designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rusty@ozlabs.org designates 203.11.71.1 as permitted sender) smtp.mailfrom=rusty@ozlabs.org
Received: by ozlabs.org (Postfix, from userid 1011)
	id 43vNpr2SQQz9s3x; Wed,  6 Feb 2019 12:17:40 +1100 (AEDT)
From: Rusty Russell <rusty@rustcorp.com.au>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Guenter Roeck <linux@roeck-us.net>, Chris Metcalf <chris.d.metcalf@gmail.com>
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: linux-next: tracebacks in workqueue.c/__flush_work()
In-Reply-To: <72e7d782-85f2-b499-8614-9e3498106569@i-love.sakura.ne.jp>
References: <18a30387-6aa5-6123-e67c-57579ecc3f38@roeck-us.net> <72e7d782-85f2-b499-8614-9e3498106569@i-love.sakura.ne.jp>
Date: Mon, 04 Feb 2019 10:16:12 +1030
Message-ID: <87munc306z.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> writes:
> (Adding Chris Metcalf and Rusty Russell.)
>
> If NR_CPUS == 1 due to CONFIG_SMP=n, for_each_cpu(cpu, &has_work) loop does not
> evaluate "struct cpumask has_work" modified by cpumask_set_cpu(cpu, &has_work) at
> previous for_each_online_cpu() loop. Guenter Roeck found a problem among three
> commits listed below.
>
>   Commit 5fbc461636c32efd ("mm: make lru_add_drain_all() selective")
>   expects that has_work is evaluated by for_each_cpu().
>
>   Commit 2d3854a37e8b767a ("cpumask: introduce new API, without changing anything")
>   assumes that for_each_cpu() does not need to evaluate has_work.
>
>   Commit 4d43d395fed12463 ("workqueue: Try to catch flush_work() without INIT_WORK().")
>   expects that has_work is evaluated by for_each_cpu().
>
> What should we do? Do we explicitly evaluate has_mask if NR_CPUS == 1 ?

No, fix the API to be least-surprise.  Fix 2d3854a37e8b767a too.

Doing anything else would be horrible, IMHO.

Cheers,
Rusty.

