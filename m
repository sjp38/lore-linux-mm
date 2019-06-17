Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C94A9C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 05:39:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FA65218AD
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 05:39:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ozlabs.org header.i=@ozlabs.org header.b="q8UH+np3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FA65218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=ozlabs.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDA8E8E0001; Mon, 17 Jun 2019 01:39:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A12878E0005; Mon, 17 Jun 2019 01:39:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83DC08E0001; Mon, 17 Jun 2019 01:39:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 44FF78E0003
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 01:39:03 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i27so1774951pfk.12
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 22:39:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MfuM4fRiuyhbGnnpExOOezm72lU0uhlDwrLdkmY7OTQ=;
        b=gW+/CBuzyJCXxqNzsOca2NCC11VcY5atYOsahz8Mgzw62MCDYI75/1jQdyIV7KemRs
         tDUFH+4wXyjPYvoCIQqLMK5mRle+G0PTYJtSnZeLyGOdPkuzirMP4CHeTKls3v8fW4J3
         GZwzH4ZHRyPP3AmZY05+SSAIYgJIOiZzB9mpz6pLSYnaOPSA8FoYdV1v7gbJxBVi4tLo
         qJD6XPaXqW+IrlzFnOaBiDvUO3z9AF9KrwBtNH+DTwG07tRhOq5mTQ0BQS7q9uZ1avQ6
         n013ajAzMmzJd2qHKOU9s0t4ELiCT4VPfQzDK0PfErrVF35kV9ACxwK75Py2j4d5wa7S
         P0Fw==
X-Gm-Message-State: APjAAAVga/63Xb3u7X73E8Och5tH/Di6G7Xu/4E3E/DQ4KGVidgXAEGd
	4hIHMmykgVgy4mf5RidHmhnZpKJ3CPwE8KJirylbYJ+r26gisosUeTvzDOID7zcx6ggskkW04ph
	AS56xGC/+w1GzaRr2GjRtcatFyD4pS+PxM4taePGEV9cJwdQYn5jI8K/ohmoKTC0Ulw==
X-Received: by 2002:a63:8f09:: with SMTP id n9mr46879413pgd.249.1560749942844;
        Sun, 16 Jun 2019 22:39:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzV5s2uvVMvvfGbGNowwk+9swckrSkVfJjbotl/LTgQGD5QwrLiNrM70m0qqJwLq0KoTplO
X-Received: by 2002:a63:8f09:: with SMTP id n9mr46879380pgd.249.1560749942085;
        Sun, 16 Jun 2019 22:39:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560749942; cv=none;
        d=google.com; s=arc-20160816;
        b=rC2NesGrR3S17InQHlZAHzetSFpqcMm0Z89RcgrqE/EfokZj9eOYic38gci1dkgUCR
         qeAFWHPJx6a+j7PHnxGBEpioUzQzXQqEjDsVJHm/TGHp6NMDYP1oo75REQU9lN7otWa9
         4XjMADg1JR6GnnxPTHRCEOOToCg5KdEhkZoJXssfj6gxMMQ/CBdeIzf1ryeUDF2lSCOK
         dOQ9Staa1j3UG59qv9Zzuksk3lbgmHF/77CRHfhiLxtuIqo1WWtYwJ41b9txrFYXip9h
         ACxuIYjCRwc8UkqTEg8HGdaKIHZlpEqX/OfbF5+9uaX6d7jjPznLEq6BZtaW/JpMq5J7
         91AA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MfuM4fRiuyhbGnnpExOOezm72lU0uhlDwrLdkmY7OTQ=;
        b=AZpowksLi+8pzoW5DC99Sgd7axYsq55WBhi/pQXR3wVIr07CV5q7xy09CbZNoszSdX
         QkXQuY+bM8yrikCtEMnAGVUbkVfsGRS4pzD7rcu1bVifEfWjZqfBp1eNhbkw0v7brGbJ
         bBlxZXUKn/jjr6KHZ4Qw6dRinv3ewu3Z2vzICfSzxzkU59YIKRDdcw84DA0hFUVKVeyC
         lgYlL0kN1Ba4X7C8RUyaEnKpMbOW14U/dMiROdq/Lm/n/zf11QxNp/hrHaZJ2SCmy0RE
         s9BYvOjHb+WEun28QZZShRZGm8FuO6JIS7GPQ8V8A5N7Zc3Jczf0qVlh4C6+dqENhnS8
         habw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ozlabs.org header.s=201707 header.b=q8UH+np3;
       spf=pass (google.com: domain of paulus@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=paulus@ozlabs.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ozlabs.org
Received: from ozlabs.org (bilbo.ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id z20si9353074pfa.282.2019.06.16.22.39.01
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 16 Jun 2019 22:39:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of paulus@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ozlabs.org header.s=201707 header.b=q8UH+np3;
       spf=pass (google.com: domain of paulus@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=paulus@ozlabs.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ozlabs.org
Received: by ozlabs.org (Postfix, from userid 1003)
	id 45S0Ps4DC5z9s7h; Mon, 17 Jun 2019 15:38:57 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=ozlabs.org; s=201707;
	t=1560749937; bh=jR54jSADlnieO8pB4/tHH0OwHqfcoZjTjfV+h+EHZcg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=q8UH+np3k8PiZHUFh7G7kdpoPLQbqzVVldUzKvRzM9Z/EajwRjN2hZ2E6c59i+z0U
	 xw12GhPxmJJ2LtmUd092wbw2V7mKpw/vb947ObuutVzuQX26xmCgKUi9wwW7u8aB5S
	 dfwNpEeMUWNE8ERsyrMYTlhTtKuoZhh4NTvpFUKWB6uJqP5BhEaT+gG3Ky4VKhNUS2
	 RDIjOe7x8YX3Tig3IxavQsVxhxPHJmU695FHZ6Ui1rwWzb2eBrAAZbz0idza3oGz1Q
	 4I+lDT1c5EFyFGr4CnunnCKs+lknH2cmXDt1iWSy2Y22pgeO8fTSTVOmuDbcrGLSpq
	 5VwSiRkpYsAyg==
Date: Mon, 17 Jun 2019 15:38:54 +1000
From: Paul Mackerras <paulus@ozlabs.org>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org,
	linux-mm@kvack.org, paulus@au1.ibm.com,
	aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
	linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
	cclaudio@linux.ibm.com
Subject: Re: [PATCH v4 4/6] kvmppc: Handle memory plug/unplug to secure VM
Message-ID: <20190617053854.5niyzcrxeee7vvra@oak.ozlabs.ibm.com>
References: <20190528064933.23119-1-bharata@linux.ibm.com>
 <20190528064933.23119-5-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528064933.23119-5-bharata@linux.ibm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 12:19:31PM +0530, Bharata B Rao wrote:
> Register the new memslot with UV during plug and unregister
> the memslot during unplug.
> 
> Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>

Acked-by: Paul Mackerras <paulus@ozlabs.org>

