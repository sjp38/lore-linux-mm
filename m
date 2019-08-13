Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B74D6C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:18:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76C6920663
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:18:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76C6920663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2458B6B026C; Tue, 13 Aug 2019 05:18:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F50F6B026D; Tue, 13 Aug 2019 05:18:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E62D6B026E; Tue, 13 Aug 2019 05:18:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0022.hostedemail.com [216.40.44.22])
	by kanga.kvack.org (Postfix) with ESMTP id E39E56B026C
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:18:27 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 8CD7710E2
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:18:27 +0000 (UTC)
X-FDA: 75816853854.25.books42_83feb0dc1e423
X-HE-Tag: books42_83feb0dc1e423
X-Filterd-Recvd-Size: 3826
Received: from mail-wr1-f66.google.com (mail-wr1-f66.google.com [209.85.221.66])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:18:26 +0000 (UTC)
Received: by mail-wr1-f66.google.com with SMTP id j16so4802013wrr.8
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 02:18:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=IZRmvHQ/S4hTPY+RjwdslhJjoJMmuhgf33bqPBS5Vo0=;
        b=ZdimJJt4ABfzP0r85v9JOs7yvAB+x1U54UlXdbJ1jpPBYak6TuMFzVMoo/Hh2D9e68
         qAYGrn7gNN/VcWGSQi8pIEOe+j4rEqLRXS2fcpXcmOfAjSRqfNNd1Ay1xyyO6pNDXAOt
         xZ4UQ4Z67akmR7GLzSNmWhA2xIdwujeJ8TtkaxMa8UITH83sXKd528dPIoCPnNkzsT+9
         Ep6LXa4rJd3/2+AQ2DDkEDAq7I6L400DDz3P0/befg93HaN1tWn0GUdcoe90dLNpX17m
         iGMZCGyslTnSQ4y5TO5UIpUhIm70UviQ8RS+EqFG2AsZb2/8mB5TPSAPfuQI1XjwszWk
         +tvA==
X-Gm-Message-State: APjAAAVc5AhkqlyjKduJmIO5BFFGjJqksWVREuEwvkMl0z2Q0keoudYh
	uepdfdLwLZ+huejahTtkIRlVpA==
X-Google-Smtp-Source: APXvYqwtQnCM7sq50W3r0VMXnUEHukyuzwOv/MX6D9s31ZjWhM+QEV2IF+RJkpJzTPaoAknQIFzUOA==
X-Received: by 2002:adf:dbcb:: with SMTP id e11mr4705392wrj.272.1565687905800;
        Tue, 13 Aug 2019 02:18:25 -0700 (PDT)
Received: from ?IPv6:2001:b07:6468:f312:5d12:7fa9:fb2d:7edb? ([2001:b07:6468:f312:5d12:7fa9:fb2d:7edb])
        by smtp.gmail.com with ESMTPSA id w15sm936813wmi.19.2019.08.13.02.18.24
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 02:18:25 -0700 (PDT)
Subject: Re: [RFC PATCH v6 76/92] kvm: x86: disable EPT A/D bits if
 introspection is present
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
 <20190809160047.8319-77-alazar@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <9f8b31c5-2252-ddc5-2371-9c0959ac5a18@redhat.com>
Date: Tue, 13 Aug 2019 11:18:23 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809160047.8319-77-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/19 18:00, Adalbert Laz=C4=83r wrote:
> Signed-off-by: Adalbert Laz=C4=83r <alazar@bitdefender.com>
> ---
>  arch/x86/kvm/vmx/vmx.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
> index dc648ba47df3..152c58b63f69 100644
> --- a/arch/x86/kvm/vmx/vmx.c
> +++ b/arch/x86/kvm/vmx/vmx.c
> @@ -7718,7 +7718,7 @@ static __init int hardware_setup(void)
>  	    !cpu_has_vmx_invept_global())
>  		enable_ept =3D 0;
> =20
> -	if (!cpu_has_vmx_ept_ad_bits() || !enable_ept)
> +	if (!cpu_has_vmx_ept_ad_bits() || !enable_ept || kvmi_is_present())
>  		enable_ept_ad_bits =3D 0;
> =20
>  	if (!cpu_has_vmx_unrestricted_guest() || !enable_ept)
>=20

Why?

Paolo

