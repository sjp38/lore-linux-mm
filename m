Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CC32C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 08:55:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDBBC2063F
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 08:55:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDBBC2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 711D46B0005; Tue, 13 Aug 2019 04:55:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C23B6B0006; Tue, 13 Aug 2019 04:55:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D8736B0007; Tue, 13 Aug 2019 04:55:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0221.hostedemail.com [216.40.44.221])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9086B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 04:55:26 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id D4CC362C0
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:55:25 +0000 (UTC)
X-FDA: 75816795810.11.vest35_4c7a65522392d
X-HE-Tag: vest35_4c7a65522392d
X-Filterd-Recvd-Size: 4304
Received: from mail-wm1-f66.google.com (mail-wm1-f66.google.com [209.85.128.66])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:55:25 +0000 (UTC)
Received: by mail-wm1-f66.google.com with SMTP id v19so737708wmj.5
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 01:55:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=sPUyfB4muaIr59fd4usHXqxooogTzwXwDuPC1t7ce04=;
        b=OtrFMzq4E5Ze8sIYD+L39pOWq4CAKa34vEffLL693XgfORfYu+rQLX+eyfnyepUl7h
         DXcgmIIeg+h4V4ogxyxV8WgHHR9JLjxSdgebUpFkb1RASZlcO/mmR56wesBFWXSRhzYe
         KT/EU7QBlcQHmOrd0cvqQPqTNU1feHJbw0k0nH0iYRKMTU3rV+fGyv6OWLFqfvubk2m9
         jzTztq2HXH6S9w8PXYNmNBm8HmU9nqzFmUJEUKEzFz5hmLM1SP+IgOpQGa7r4smYURPC
         GH0q/8QwyePkKrjtGDxwFqar2bV5cWmK4I+6qZyvUXdJ4Z7JTSLU/LAJnhiVK1UeFC6O
         viUw==
X-Gm-Message-State: APjAAAXaerEkKa+dL4spQB7BXu/0BTfEC+vczfccEeayqoTnCi+Uu8h/
	HQhTB6bzoC/QS1Gca9GN++B69g==
X-Google-Smtp-Source: APXvYqxbrJjpte7v8LCdT4TY1BMezIoEu72MDVQxtXaSnj9GyHSbv3Go1giiz3C/PIGfATdRGc3mYg==
X-Received: by 2002:a05:600c:2292:: with SMTP id 18mr1851704wmf.156.1565686524175;
        Tue, 13 Aug 2019 01:55:24 -0700 (PDT)
Received: from [192.168.10.150] ([93.56.166.5])
        by smtp.gmail.com with ESMTPSA id n14sm212546507wra.75.2019.08.13.01.55.22
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 01:55:23 -0700 (PDT)
Subject: Re: [RFC PATCH v6 16/92] kvm: introspection: handle events and event
 replies
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
 <20190809160047.8319-17-alazar@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <08325b3b-3af9-382b-7c0f-8410e8fcb545@redhat.com>
Date: Tue, 13 Aug 2019 10:55:21 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809160047.8319-17-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/19 17:59, Adalbert Laz=C4=83r wrote:
>=20
> +			 reply->padding2);
> +
> +	ivcpu->reply_waiting =3D false;
> +	return expected->error;
> +}
> +
>  /*

Is this missing a wakeup?

> =20
> +static bool need_to_wait(struct kvm_vcpu *vcpu)
> +{
> +	struct kvmi_vcpu *ivcpu =3D IVCPU(vcpu);
> +
> +	return ivcpu->reply_waiting;
> +}
> +

Do you actually need this function?  It seems to me that everywhere you
call it you already have an ivcpu, so you can just access the field.

Also, "reply_waiting" means "there is a reply that is waiting".  What
you mean is "waiting_for_reply".

The overall structure of the jobs code is confusing.  The same function
kvm_run_jobs_and_wait is an infinite loop before and gets a "break"
later.  It is also not clear why kvmi_job_wait is called through a job.
 Can you have instead just kvm_run_jobs in KVM_REQ_INTROSPECTION, and
something like this instead when sending an event:

int kvmi_wait_for_reply(struct kvm_vcpu *vcpu)
{
	struct kvmi_vcpu *ivcpu =3D IVCPU(vcpu);

	while (ivcpu->waiting_for_reply) {
		kvmi_run_jobs(vcpu);

		err =3D swait_event_killable(*wq,
				!ivcpu->waiting_for_reply ||
				!list_empty(&ivcpu->job_list));

		if (err)
			return -EINTR;
	}

	return 0;
}

?

Paolo

