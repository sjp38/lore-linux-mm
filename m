Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EB8CC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:08:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB55F20663
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:08:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB55F20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8188E6B0010; Tue, 13 Aug 2019 05:08:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CA146B0266; Tue, 13 Aug 2019 05:08:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B8566B0269; Tue, 13 Aug 2019 05:08:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0243.hostedemail.com [216.40.44.243])
	by kanga.kvack.org (Postfix) with ESMTP id 48F8F6B0010
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:08:44 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id DC392181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:08:43 +0000 (UTC)
X-FDA: 75816829326.15.word15_2f139ec979456
X-HE-Tag: word15_2f139ec979456
X-Filterd-Recvd-Size: 4367
Received: from mail-wr1-f65.google.com (mail-wr1-f65.google.com [209.85.221.65])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:08:43 +0000 (UTC)
Received: by mail-wr1-f65.google.com with SMTP id y8so1096106wrn.10
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 02:08:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=vSEPUTqGTvTIlPA47HMgabptB4wTrjlnzVdVCCfiQHw=;
        b=nVLaxZbEsaV8QqUEtAnBG+xO5f51vxk6wwMXTiM+UD5Pzk+R15IDaFFtptOdUmVpsV
         KDdPjJVOVCoq9LHQphfOz6TS7CQqV4Fm9cJJe2aRClgNJZ59lFK8ISVVHqrJZFJ/rokI
         ewFAfESJQf1gq4uwBashtemoUya8Tpfb7eUo65QzUYLoxp7JUot6009WmeGTc8dQBUTw
         OpWOLjMtjM3Z8PTL1JAlCKdoYwEZ2YAjKoI6GFkaY1T8j1tVxKLB5f+5y/jeYZtBGCK8
         I5nuUFP6gNh+aaVopUVkgK5Z83Y0E45rXKY1L5PcztHYDvUhxvK9J/51TH8GAAw38o5Q
         STvw==
X-Gm-Message-State: APjAAAUA0EY33ZqOZ/3Oz2mqbzl2I53Gkf98GQabWhdfZtkdGIAaDEGl
	Yiw0Rf1rWNFFyjHS7QzNYWuhSg==
X-Google-Smtp-Source: APXvYqxphI9IUoLpUIef25ST16HnKb9bpvR5V1zmLOhTuusS26HOW6o20LLiYcUp6Q4TqPyLCN+ZUA==
X-Received: by 2002:adf:b64b:: with SMTP id i11mr29345197wre.114.1565687322206;
        Tue, 13 Aug 2019 02:08:42 -0700 (PDT)
Received: from ?IPv6:2001:b07:6468:f312:5d12:7fa9:fb2d:7edb? ([2001:b07:6468:f312:5d12:7fa9:fb2d:7edb])
        by smtp.gmail.com with ESMTPSA id q18sm134649129wrw.36.2019.08.13.02.08.41
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 02:08:41 -0700 (PDT)
Subject: Re: [RFC PATCH v6 70/92] kvm: x86: filter out access rights only when
 tracked by the introspection tool
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
 <20190809160047.8319-71-alazar@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <8cba6816-8d3a-2498-b3b0-2ce76a98ce12@redhat.com>
Date: Tue, 13 Aug 2019 11:08:39 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809160047.8319-71-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/19 18:00, Adalbert Laz=C4=83r wrote:
> It should complete the commit fd34a9518173 ("kvm: x86: consult the page=
 tracking from kvm_mmu_get_page() and __direct_map()")
>=20
> Signed-off-by: Adalbert Laz=C4=83r <alazar@bitdefender.com>
> ---
>  arch/x86/kvm/mmu.c | 3 +++
>  1 file changed, 3 insertions(+)
>=20
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index 65b6acba82da..fd64cf1115da 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -2660,6 +2660,9 @@ static void clear_sp_write_flooding_count(u64 *sp=
te)
>  static unsigned int kvm_mmu_page_track_acc(struct kvm_vcpu *vcpu, gfn_=
t gfn,
>  					   unsigned int acc)
>  {
> +	if (!kvmi_tracked_gfn(vcpu, gfn))
> +		return acc;
> +
>  	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREREAD))
>  		acc &=3D ~ACC_USER_MASK;
>  	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREWRITE) ||
>=20

If this patch is always needed, then the function should be named
something like kvm_mmu_apply_introspection_access and kvmi_tracked_gfn
should be tested from the moment it is introduced.

But the commit message says nothing about _why_ it is needed, so I
cannot guess.  I would very much avoid it however.  Is it just an
optimization?

Paolo

