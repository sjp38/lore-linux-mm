Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FEE3C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 08:44:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 584BE20679
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 08:44:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 584BE20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1FEF6B0006; Tue, 13 Aug 2019 04:43:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCFB16B0007; Tue, 13 Aug 2019 04:43:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE5036B0008; Tue, 13 Aug 2019 04:43:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0108.hostedemail.com [216.40.44.108])
	by kanga.kvack.org (Postfix) with ESMTP id AB8546B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 04:43:59 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 58C1F181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:43:59 +0000 (UTC)
X-FDA: 75816766998.07.wood09_7a14e54372049
X-HE-Tag: wood09_7a14e54372049
X-Filterd-Recvd-Size: 3574
Received: from mail-wr1-f67.google.com (mail-wr1-f67.google.com [209.85.221.67])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:43:58 +0000 (UTC)
Received: by mail-wr1-f67.google.com with SMTP id k2so21123678wrq.2
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 01:43:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=QrW7dS2ds3pbrdiGP+Xfw3R+Xx+cVjaMWqFORv9YS00=;
        b=k03W7h7TbH031P4gjgYhwjkGqUUmDhLz0fsG8axxSisjiMrK1h4Yqo+LxmbAObheST
         XMHmVe6/AEmfoLjmg9pEd9YjwzNjOJxS3g5L8dM3wwyeH5tGq//nS9gkKABSBpSANC9n
         RsDKj5V78mV9GTMw86RES/O/AGqZODTiwyfoeRAG4AAbpgpnLdaZbsg7OzbIBATRQEoo
         to2Ku/3djeVW0F/LHrms6Z2z1TQRzUsnYQCOJoGcjZmJDntp0BfaBsStDM/G6K6KTiJA
         emKePJVeiNZhHojraWvArwEFDNYrz33G3ZzOfy9n6vdBBiFImCdp7fZLeoNCnDJO1RSJ
         h3LQ==
X-Gm-Message-State: APjAAAWqYZ3+9W+QzPOU78TOQVLeaJ5et953d5uUdpo95I/tm1tkwif0
	hOhkHBg2yn6dZDlkMhL2zeMpbg==
X-Google-Smtp-Source: APXvYqxuWhc1YpCqxMrLLcWkuQ8VY9K/YArqTGXAb48mAXYstqGvOVyemZekybg0GEAvyY/bBnxajA==
X-Received: by 2002:a5d:4e06:: with SMTP id p6mr21211891wrt.336.1565685837546;
        Tue, 13 Aug 2019 01:43:57 -0700 (PDT)
Received: from [192.168.10.150] ([93.56.166.5])
        by smtp.gmail.com with ESMTPSA id g14sm16821663wrb.38.2019.08.13.01.43.53
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 01:43:56 -0700 (PDT)
Subject: Re: [RFC PATCH v6 13/92] kvm: introspection: make the vCPU wait even
 when its jobs list is empty
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
 =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-14-alazar@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <c82b509a-86a7-6c2c-943e-f78a02e6efb1@redhat.com>
Date: Tue, 13 Aug 2019 10:43:52 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809160047.8319-14-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/19 17:59, Adalbert Laz=C4=83r wrote:
> +void kvmi_handle_requests(struct kvm_vcpu *vcpu)
> +{
> +	struct kvmi *ikvm;
> +
> +	ikvm =3D kvmi_get(vcpu->kvm);
> +	if (!ikvm)
> +		return;
> +
> +	for (;;) {
> +		int err =3D kvmi_run_jobs_and_wait(vcpu);
> +
> +		if (err)
> +			break;
> +	}
> +
> +	kvmi_put(vcpu->kvm);
> +}
> +

Using kvmi_run_jobs_and_wait from two places (here and kvmi_send_event)
is very confusing.  Does kvmi_handle_requests need to do this, or can it
just use kvmi_run_jobs?

Paolo

