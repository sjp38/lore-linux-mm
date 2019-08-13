Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 157CDC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:18:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7B5D20663
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:18:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7B5D20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6159C6B026B; Tue, 13 Aug 2019 05:18:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C67D6B026C; Tue, 13 Aug 2019 05:18:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48D506B026D; Tue, 13 Aug 2019 05:18:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0006.hostedemail.com [216.40.44.6])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD6F6B026B
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:18:03 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id BBEF18248AA1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:18:02 +0000 (UTC)
X-FDA: 75816852804.23.spoon68_8062a8c13e424
X-HE-Tag: spoon68_8062a8c13e424
X-Filterd-Recvd-Size: 6122
Received: from mail-wm1-f68.google.com (mail-wm1-f68.google.com [209.85.128.68])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:18:02 +0000 (UTC)
Received: by mail-wm1-f68.google.com with SMTP id g67so810514wme.1
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 02:18:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=jW0tub2UzbL05NcO2bVMEMoWnqz9PpoPHHdwwy4/hhI=;
        b=HtHl2DjZL/tVo6L5aEnFoHj0cClRyNKFZ5fsd9qP7aQPpEBdHAMrehIKIrzL4aUn9K
         R2bdf0OxYH6BsSJQH9kZ6gR48eCe/ObMgD7LuKibuJ6i8rAZXiRqNNgG9pyrnapIe/Eu
         1+93+Ox3eetngpDGV9ORtKOA2KFf8FIExaWjtnF7f8xmLPrRwkkMfADkI5rJcArq40n1
         4mRVEMn0W8p716tEW6Yn/y2NG1YI4dzrx13I42VkywWD0I+hEVEVeC2mUAG6ODUSOFrV
         yIvlJye7tz0Pg6FeZSn/kmhbXZHZCQnqThre0KB1tYQneefnEfVsYDk09cXg2pvw6BYG
         07ZQ==
X-Gm-Message-State: APjAAAXkL/WnDK1n3eGhwPh6rPA7/bz3gTheHSVm+qwUugAuHjc1/K4p
	N8xQZbmRw0C2nBbp2Jn2bMQUzw==
X-Google-Smtp-Source: APXvYqy54+DaW4YK3FY/VYnqSfCxjCt45GhtNezxaN2179OBpbvne3bv8avk2VnkQaQfREwmbAyE2A==
X-Received: by 2002:a1c:c747:: with SMTP id x68mr2086476wmf.14.1565687881016;
        Tue, 13 Aug 2019 02:18:01 -0700 (PDT)
Received: from ?IPv6:2001:b07:6468:f312:5d12:7fa9:fb2d:7edb? ([2001:b07:6468:f312:5d12:7fa9:fb2d:7edb])
        by smtp.gmail.com with ESMTPSA id a19sm43628167wra.2.2019.08.13.02.17.59
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 02:18:00 -0700 (PDT)
Subject: Re: [RFC PATCH v6 79/92] kvm: x86: emulate movsd xmm, m64
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
 <20190809160047.8319-80-alazar@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <32506209-7b16-4660-664b-4f6c73dc9433@redhat.com>
Date: Tue, 13 Aug 2019 11:17:58 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809160047.8319-80-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/19 18:00, Adalbert Laz=C4=83r wrote:
> From: Mihai Don=C8=9Bu <mdontu@bitdefender.com>
>=20
> This is needed in order to be able to support guest code that uses movs=
d to
> write into pages that are marked for write tracking.
>=20
> Signed-off-by: Mihai Don=C8=9Bu <mdontu@bitdefender.com>
> Signed-off-by: Adalbert Laz=C4=83r <alazar@bitdefender.com>
> ---
>  arch/x86/kvm/emulate.c | 32 +++++++++++++++++++++++++++-----
>  1 file changed, 27 insertions(+), 5 deletions(-)
>=20
> diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
> index 34431cf31f74..9d38f892beea 100644
> --- a/arch/x86/kvm/emulate.c
> +++ b/arch/x86/kvm/emulate.c
> @@ -1177,6 +1177,27 @@ static int em_fnstsw(struct x86_emulate_ctxt *ct=
xt)
>  	return X86EMUL_CONTINUE;
>  }
> =20
> +static u8 simd_prefix_to_bytes(const struct x86_emulate_ctxt *ctxt,
> +			       int simd_prefix)
> +{
> +	u8 bytes;
> +
> +	switch (ctxt->b) {
> +	case 0x11:
> +		/* movsd xmm, m64 */
> +		/* movups xmm, m128 */
> +		if (simd_prefix =3D=3D 0xf2) {
> +			bytes =3D 8;
> +			break;
> +		}
> +		/* fallthrough */
> +	default:
> +		bytes =3D 16;
> +		break;
> +	}
> +	return bytes;
> +}
> +
>  static void decode_register_operand(struct x86_emulate_ctxt *ctxt,
>  				    struct operand *op)
>  {
> @@ -1187,7 +1208,7 @@ static void decode_register_operand(struct x86_em=
ulate_ctxt *ctxt,
> =20
>  	if (ctxt->d & Sse) {
>  		op->type =3D OP_XMM;
> -		op->bytes =3D 16;
> +		op->bytes =3D ctxt->op_bytes;
>  		op->addr.xmm =3D reg;
>  		read_sse_reg(ctxt, &op->vec_val, reg);
>  		return;
> @@ -1238,7 +1259,7 @@ static int decode_modrm(struct x86_emulate_ctxt *=
ctxt,
>  				ctxt->d & ByteOp);
>  		if (ctxt->d & Sse) {
>  			op->type =3D OP_XMM;
> -			op->bytes =3D 16;
> +			op->bytes =3D ctxt->op_bytes;
>  			op->addr.xmm =3D ctxt->modrm_rm;
>  			read_sse_reg(ctxt, &op->vec_val, ctxt->modrm_rm);
>  			return rc;
> @@ -4529,7 +4550,7 @@ static const struct gprefix pfx_0f_2b =3D {
>  };
> =20
>  static const struct gprefix pfx_0f_10_0f_11 =3D {
> -	I(Unaligned, em_mov), I(Unaligned, em_mov), N, N,
> +	I(Unaligned, em_mov), I(Unaligned, em_mov), I(Unaligned, em_mov), N,
>  };
> =20
>  static const struct gprefix pfx_0f_28_0f_29 =3D {
> @@ -5097,7 +5118,7 @@ int x86_decode_insn(struct x86_emulate_ctxt *ctxt=
, void *insn, int insn_len)
>  {
>  	int rc =3D X86EMUL_CONTINUE;
>  	int mode =3D ctxt->mode;
> -	int def_op_bytes, def_ad_bytes, goffset, simd_prefix;
> +	int def_op_bytes, def_ad_bytes, goffset, simd_prefix =3D 0;
>  	bool op_prefix =3D false;
>  	bool has_seg_override =3D false;
>  	struct opcode opcode;
> @@ -5320,7 +5341,8 @@ int x86_decode_insn(struct x86_emulate_ctxt *ctxt=
, void *insn, int insn_len)
>  			ctxt->op_bytes =3D 4;
> =20
>  		if (ctxt->d & Sse)
> -			ctxt->op_bytes =3D 16;
> +			ctxt->op_bytes =3D simd_prefix_to_bytes(ctxt,
> +							      simd_prefix);
>  		else if (ctxt->d & Mmx)
>  			ctxt->op_bytes =3D 8;
>  	}
>=20

Please submit all these emulator patches as a separate series, complete
with testcases for kvm-unit-tests.

Paolo

