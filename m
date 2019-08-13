Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2D34C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 08:13:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8771420663
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 08:13:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8771420663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A66636B0006; Tue, 13 Aug 2019 04:12:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F0A76B0007; Tue, 13 Aug 2019 04:12:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B6C46B0008; Tue, 13 Aug 2019 04:12:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0139.hostedemail.com [216.40.44.139])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6556B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 04:12:59 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0F8A555F9D
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:12:59 +0000 (UTC)
X-FDA: 75816688878.01.land85_8e63f8d0f9503
X-HE-Tag: land85_8e63f8d0f9503
X-Filterd-Recvd-Size: 3609
Received: from mail-wr1-f67.google.com (mail-wr1-f67.google.com [209.85.221.67])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:12:58 +0000 (UTC)
Received: by mail-wr1-f67.google.com with SMTP id z11so4951687wrt.4
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 01:12:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=C4MCH+wiKyoHDLRZTqdi1HE4ZG69Yx/Z30XMFS1Md78=;
        b=rcERKHJqFYZoZ2StCW3DHJeaFsa05sd9dJ3zPiy+wC9vy2p22S3xfBPqioIZHuuLGn
         OMHilz5oEhRxeF0HSlaDiUWEF4orhrdXky0A9Yf7LTaxuoAl2u9zr4+mIrbbIKHUZuvy
         G3reB8kB32p1eOImn/2syeGgwt0h0aDDd4And8nO5PR1U3U6jc5UH5FDXmBHOiaR8CmB
         n3fo8TmdGOSfWzdWzU6UU7/PAWyah/q5gde2rq010U8lQkkbBdSney1tH6TLu2QJwqMY
         vCo7NNAyTcSGkqNzuPY32INXKKJo8KS0+TR2rnF4k8WsFd6xEtxWgMp7rLdInu6fvi1c
         /mEw==
X-Gm-Message-State: APjAAAXecfScGN9ItU5ma4HSCtl1LEgCTNDY3V/uBtI2pW8eHJC4Z7Vr
	GRhwg/GLyjD8Q7oUo30muUd7sA==
X-Google-Smtp-Source: APXvYqzTGkTsXHr6zZizzD6ULkYclIovnz3N2V8vDYZOluWG0ibcVz+1hwoKcaSTeMWJVha1MYq4yw==
X-Received: by 2002:adf:c613:: with SMTP id n19mr44936601wrg.109.1565683977128;
        Tue, 13 Aug 2019 01:12:57 -0700 (PDT)
Received: from ?IPv6:2001:b07:6468:f312:5d12:7fa9:fb2d:7edb? ([2001:b07:6468:f312:5d12:7fa9:fb2d:7edb])
        by smtp.gmail.com with ESMTPSA id a8sm826262wma.31.2019.08.13.01.12.55
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 01:12:56 -0700 (PDT)
Subject: Re: [RFC PATCH v6 26/92] kvm: x86: add kvm_mmu_nested_pagefault()
To: =?UTF-8?Q?Adalbert_Laz=c4=83r?= <alazar@bitdefender.com>,
 kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
 =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 Tamas K Lengyel <tamas@tklengyel.com>,
 Mathieu Tarral <mathieu.tarral@protonmail.com>,
 =?UTF-8?Q?Samuel_Laur=c3=a9n?= <samuel.lauren@iki.fi>,
 Patrick Colp <patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
 Stefan Hajnoczi <stefanha@redhat.com>,
 Weijiang Yang <weijiang.yang@intel.com>, Yu C Zhang <yu.c.zhang@intel.com>,
 =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>,
 =?UTF-8?B?TmljdciZb3IgQ8OuyJt1?= <ncitu@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-27-alazar@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <a35a1d7c-fa36-c4f2-e8e6-7a242789364e@redhat.com>
Date: Tue, 13 Aug 2019 10:12:54 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809160047.8319-27-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/19 17:59, Adalbert Laz=C4=83r wrote:
> +static bool vmx_nested_pagefault(struct kvm_vcpu *vcpu)
> +{
> +	if (vcpu->arch.exit_qualification & EPT_VIOLATION_GVA_TRANSLATED)
> +		return false;
> +	return true;
> +}
> +

This hook is misnamed; it has nothing to do with nested virtualization.
 Rather, it returns true if it the failure happened while translating
the address of a guest page table.

SVM makes the same information available in EXITINFO[33].

Paolo

