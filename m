Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9A3FC32753
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 08:26:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9610220663
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 08:26:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9610220663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2943B6B0005; Tue, 13 Aug 2019 04:26:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 244C26B0006; Tue, 13 Aug 2019 04:26:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 136BB6B0007; Tue, 13 Aug 2019 04:26:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0038.hostedemail.com [216.40.44.38])
	by kanga.kvack.org (Postfix) with ESMTP id E1F306B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 04:26:34 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 90EBC180AD7C1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:26:34 +0000 (UTC)
X-FDA: 75816723108.12.crow55_738d32e747b17
X-HE-Tag: crow55_738d32e747b17
X-Filterd-Recvd-Size: 3877
Received: from mail-wr1-f66.google.com (mail-wr1-f66.google.com [209.85.221.66])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:26:33 +0000 (UTC)
Received: by mail-wr1-f66.google.com with SMTP id t16so16804029wra.6
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 01:26:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=xxqnQ+CnehHQ/Z2KjoSVBMjf9aqW8bf9s9y55Oqxpus=;
        b=EG7KXGtjhiGYWoWUZYma2sWBsb1dFjYjCYFTJtpat1fYHaJdm8xzc8PLhn1v0iI7lZ
         cjwoUcSKGXg6opBiZMVNb7F5uci3krX5pOBwBnLSiWpld8yHdYhOt8AOepqkSPn3H+Iv
         2s0OlNR7EwTvGOZtZjuQRUxhuI6ST4nSY8lzfVfDen8XBsqsQ3gbZD+hTYYPvgRw0Q+4
         1wn+Nczpq0LvbQjPtgX+C9hlQT0HFYwsVkwAi5VB0QNn1HzHX2ogiqNfiUK9rl4k7pS4
         a/FvEITepMzYbNizXvrG9haknd8IbsDpWRIsoiLYwumun8OrF0YnPuJ7+Yl0+yeY+1D+
         Pj8Q==
X-Gm-Message-State: APjAAAVmK0N0vCaBLHBFUusZXtlTY/8qBVmsi+Uc6pCCD9SjSQd9c0uP
	hRTfPYtKzvjXio5G1GKNbtR6uw==
X-Google-Smtp-Source: APXvYqz4uFItaxiCcQv78nTDKp0pJqOC6D9k/pJKcDrE7Ren7xe2XjGO7pxUM1GtjA16i5a4LjG6iw==
X-Received: by 2002:adf:dec8:: with SMTP id i8mr3468071wrn.217.1565684792723;
        Tue, 13 Aug 2019 01:26:32 -0700 (PDT)
Received: from ?IPv6:2001:b07:6468:f312:5d12:7fa9:fb2d:7edb? ([2001:b07:6468:f312:5d12:7fa9:fb2d:7edb])
        by smtp.gmail.com with ESMTPSA id y7sm595385wmm.19.2019.08.13.01.26.31
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 01:26:32 -0700 (PDT)
Subject: Re: [RFC PATCH v6 14/92] kvm: introspection: handle introspection
 commands before returning to guest
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
 =?UTF-8?Q?Mircea_C=c3=aerjaliu?= <mcirjaliu@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-15-alazar@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <645d86f5-67f6-f5d3-3fbb-5ee9898a7ef8@redhat.com>
Date: Tue, 13 Aug 2019 10:26:29 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809160047.8319-15-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/19 17:59, Adalbert Laz=C4=83r wrote:
> +			prepare_to_swait_exclusive(&vcpu->wq, &wait,
> +						   TASK_INTERRUPTIBLE);
> +
> +			if (kvm_vcpu_check_block(vcpu) < 0)
> +				break;
> +
> +			waited =3D true;
> +			schedule();
> +
> +			if (kvm_check_request(KVM_REQ_INTROSPECTION, vcpu)) {
> +				do_kvmi_work =3D true;
> +				break;
> +			}
> +		}
> =20
> -		waited =3D true;
> -		schedule();
> +		finish_swait(&vcpu->wq, &wait);
> +
> +		if (do_kvmi_work)
> +			kvmi_handle_requests(vcpu);
> +		else
> +			break;
>  	}

Is this needed?  Or can it just go back to KVM_RUN and handle
KVM_REQ_INTROSPECTION there (in which case it would be basically
premature optimization)?

Paolo

