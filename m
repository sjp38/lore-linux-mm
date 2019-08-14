Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D01DBC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 12:33:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76CC82084D
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 12:33:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76CC82084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 122D16B0003; Wed, 14 Aug 2019 08:33:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D3EF6B0005; Wed, 14 Aug 2019 08:33:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2E086B0007; Wed, 14 Aug 2019 08:33:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0133.hostedemail.com [216.40.44.133])
	by kanga.kvack.org (Postfix) with ESMTP id D483E6B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:33:20 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 788B78248AA1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:33:20 +0000 (UTC)
X-FDA: 75820973760.18.run64_916ef7d5aa94e
X-HE-Tag: run64_916ef7d5aa94e
X-Filterd-Recvd-Size: 6414
Received: from mail-wr1-f65.google.com (mail-wr1-f65.google.com [209.85.221.65])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:33:19 +0000 (UTC)
Received: by mail-wr1-f65.google.com with SMTP id t16so20812273wra.6
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 05:33:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=upTbxgSaXX7vP3fRyuPdfadpq9YVtUPTVjwym3KEr4Y=;
        b=HwVEzimBAVlDzdXVra10BDjIWIuRN5OqKex0w31YZEQd4rBaYIoP9BNnmYPAW8G/rm
         cnyO07uLw47IEcV7m0wG+Br90lQ2EFv/dqEpf+xOoJ8vsOVaRND05+g7kdl3Qpxp7yKa
         dXCMzEBiTxfTtqbi7iKwbRaHCXA490Vxr8i1ApzUVAiuJvr+EdZyZ7lsbDDrk5q5ytTd
         Vn2QU40hjy2lDpJy5AkWvfHLt9f2U+3PTQ+Vs6sI8lKIjVBvnEAtsAKlDI/+wNXr+uWz
         ybg/WTk8XtR40i3/ESQIhHBCRy+e+zo7LvaE9VR8jCWOXw+2o/ntDyqTNdZQgm8t+g6F
         lDrw==
X-Gm-Message-State: APjAAAXHaWPv2LQOirh/RGCYl14/ISbAxkweIuaDLoaGOFT0HNhRjVkx
	hzRtpmCUg5Szu/RwJAwha1kcug==
X-Google-Smtp-Source: APXvYqz1e95Qa1i40o6nza1DKDGFvEdbi2CRAHDnxQjpMJXDtInVEHY/zM9v7riSirWigzFbE4Rhgg==
X-Received: by 2002:adf:db49:: with SMTP id f9mr5035161wrj.112.1565785997898;
        Wed, 14 Aug 2019 05:33:17 -0700 (PDT)
Received: from [192.168.10.150] ([93.56.166.5])
        by smtp.gmail.com with ESMTPSA id j10sm191268142wrd.26.2019.08.14.05.33.16
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Aug 2019 05:33:17 -0700 (PDT)
Subject: Re: [RFC PATCH v6 74/92] kvm: x86: do not unconditionally patch the
 hypercall instruction during emulation
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
 Joerg Roedel <joro@8bytes.org>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-75-alazar@bitdefender.com>
 <1362cc5c-d0cd-6b7c-1151-9df3996fefa9@redhat.com>
 <5d53f965.1c69fb81.cd952.035bSMTPIN_ADDED_BROKEN@mx.google.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <50bade53-c584-504d-7c02-1238af731666@redhat.com>
Date: Wed, 14 Aug 2019 14:33:16 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <5d53f965.1c69fb81.cd952.035bSMTPIN_ADDED_BROKEN@mx.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14/08/19 14:07, Adalbert Laz=C4=83r wrote:
> On Tue, 13 Aug 2019 11:20:45 +0200, Paolo Bonzini <pbonzini@redhat.com>=
 wrote:
>> On 09/08/19 18:00, Adalbert Laz=C4=83r wrote:
>>> From: Mihai Don=C8=9Bu <mdontu@bitdefender.com>
>>>
>>> It can happened for us to end up emulating the VMCALL instruction as =
a
>>> result of the handling of an EPT write fault. In this situation, the
>>> emulator will try to unconditionally patch the correct hypercall opco=
de
>>> bytes using emulator_write_emulated(). However, this last call uses t=
he
>>> fault GPA (if available) or walks the guest page tables at RIP,
>>> otherwise. The trouble begins when using KVMI, when we forbid the use=
 of
>>> the fault GPA and fallback to the guest pt walk: in Windows (8.1 and
>>> newer) the page that we try to write into is marked read-execute and =
as
>>> such emulator_write_emulated() fails and we inject a write #PF, leadi=
ng
>>> to a guest crash.
>>>
>>> The fix is rather simple: check the existing instruction bytes before
>>> doing the patching. This does not change the normal KVM behaviour, bu=
t
>>> does help when using KVMI as we no longer inject a write #PF.
>>
>> Fixing the hypercall is just an optimization.  Can we just hush and
>> return to the guest if emulator_write_emulated returns
>> X86EMUL_PROPAGATE_FAULT?
>>
>> Paolo
>=20
> Something like this?
>=20
> 	err =3D emulator_write_emulated(...);
> 	if (err =3D=3D X86EMUL_PROPAGATE_FAULT)
> 		err =3D X86EMUL_CONTINUE;
> 	return err;

Yes.  The only difference will be that you'll keep getting #UD vmexits
instead of hypercall vmexits.  It's also safer, we want to obey those
r-x permissions because PatchGuard would crash the system if it noticed
the rewriting for whatever reason.

Paolo

>>> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
>>> index 04b1d2916a0a..965c4f0108eb 100644
>>> --- a/arch/x86/kvm/x86.c
>>> +++ b/arch/x86/kvm/x86.c
>>> @@ -7363,16 +7363,33 @@ int kvm_emulate_hypercall(struct kvm_vcpu *vc=
pu)
>>>  }
>>>  EXPORT_SYMBOL_GPL(kvm_emulate_hypercall);
>>> =20
>>> +#define KVM_HYPERCALL_INSN_LEN 3
>>> +
>>>  static int emulator_fix_hypercall(struct x86_emulate_ctxt *ctxt)
>>>  {
>>> +	int err;
>>>  	struct kvm_vcpu *vcpu =3D emul_to_vcpu(ctxt);
>>> -	char instruction[3];
>>> +	char buf[KVM_HYPERCALL_INSN_LEN];
>>> +	char instruction[KVM_HYPERCALL_INSN_LEN];
>>>  	unsigned long rip =3D kvm_rip_read(vcpu);
>>> =20
>>> +	err =3D emulator_read_emulated(ctxt, rip, buf, sizeof(buf),
>>> +				     &ctxt->exception);
>>> +	if (err !=3D X86EMUL_CONTINUE)
>>> +		return err;
>>> +
>>>  	kvm_x86_ops->patch_hypercall(vcpu, instruction);
>>> +	if (!memcmp(instruction, buf, sizeof(instruction)))
>>> +		/*
>>> +		 * The hypercall instruction is the correct one. Retry
>>> +		 * its execution maybe we got here as a result of an
>>> +		 * event other than #UD which has been resolved in the
>>> +		 * mean time.
>>> +		 */
>>> +		return X86EMUL_CONTINUE;
>>> =20
>>> -	return emulator_write_emulated(ctxt, rip, instruction, 3,
>>> -		&ctxt->exception);
>>> +	return emulator_write_emulated(ctxt, rip, instruction,
>>> +				       sizeof(instruction), &ctxt->exception);
>>>  }


