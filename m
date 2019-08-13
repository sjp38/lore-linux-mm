Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDE14C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:45:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B737020651
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:45:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B737020651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62FFD6B000C; Tue, 13 Aug 2019 10:45:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E1176B000D; Tue, 13 Aug 2019 10:45:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D0376B000E; Tue, 13 Aug 2019 10:45:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0219.hostedemail.com [216.40.44.219])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0CA6B000C
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:45:16 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id D30564FED
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:45:15 +0000 (UTC)
X-FDA: 75817677390.12.quill96_4afccaae34f18
X-HE-Tag: quill96_4afccaae34f18
X-Filterd-Recvd-Size: 4154
Received: from mail-wr1-f67.google.com (mail-wr1-f67.google.com [209.85.221.67])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:45:15 +0000 (UTC)
Received: by mail-wr1-f67.google.com with SMTP id k2so22161484wrq.2
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:45:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=jWtEd3owCPSOaSqnFheJ8jWjvLGAgQi5lkfcBCpyD7o=;
        b=cSzBjXckt7pMA06+Mmrwle8cY5Y4bmgZlTB0pZrIfGalTc8yucL9traNckWpYi5qHL
         8jaeFFuTmvEpXkLWscsjNYoVCiykUEsq6SVrvSy1tcVRxkoLnqdKTwM0yrik5Kh375t9
         x29c/36fkpOXWkllcls5l7yeUYJIOKIYpr1UsXhHOaUWMzPvbcCulHIZrd3p/uXyTxIB
         PFTWkNeIxbTcyStUb/5JdFlgLBVO61NMzMZwDcgp+DDm9bqWMW04KtXZlzCyhCw1MZT1
         awmuDGsRc3rmVj3ANmoNAC4n5zbWaHDbTQbf2Z3b2Cwqfnr8/a/dTutET5XaEzrMpUb9
         cEtA==
X-Gm-Message-State: APjAAAWn4XHCKdh4qkgn0JBmn5E1ttAt4sV3ZkIoNz4IEdmD9Q9YwU8A
	knl+j+99qVBCtcU7o8N1ckH3eg==
X-Google-Smtp-Source: APXvYqwcGE4nFuUbUV12L+CuV8ssqEc28LeuFzgoubUsbyKYX9+fTashqIpI1VrJDY8+MqB+OZnDSA==
X-Received: by 2002:adf:fc51:: with SMTP id e17mr43958026wrs.348.1565707513708;
        Tue, 13 Aug 2019 07:45:13 -0700 (PDT)
Received: from ?IPv6:2001:b07:6468:f312:5193:b12b:f4df:deb6? ([2001:b07:6468:f312:5193:b12b:f4df:deb6])
        by smtp.gmail.com with ESMTPSA id x20sm237275027wrg.10.2019.08.13.07.45.12
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 07:45:13 -0700 (PDT)
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
 <645d86f5-67f6-f5d3-3fbb-5ee9898a7ef8@redhat.com>
 <5d52c10e.1c69fb81.26904.fd34SMTPIN_ADDED_BROKEN@mx.google.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <97cdf9cb-286c-2387-6cb5-003b30f74c7e@redhat.com>
Date: Tue, 13 Aug 2019 16:45:11 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <5d52c10e.1c69fb81.26904.fd34SMTPIN_ADDED_BROKEN@mx.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13/08/19 15:54, Adalbert Laz=C4=83r wrote:
>     Leaving kvm_vcpu_block() in order to handle a request such as 'paus=
e',
>     would cause the vCPU to enter the guest when resumed. Most of the
>     time this does not appear to be an issue, but during early boot it
>     can happen for a non-boot vCPU to start executing code from areas t=
hat
>     first needed to be set up by vCPU #0.
>    =20
>     In a particular case, vCPU #1 executed code which resided in an are=
a
>     not covered by a memslot, which caused an EPT violation that got
>     turned in mmu_set_spte() into a MMIO request that required emulatio=
n.
>     Unfortunatelly, the emulator tripped, exited to userspace and the V=
M
>     was aborted.

Okay, this makes sense.  Maybe you want to handle KVM_REQ_INTROSPECTION
in vcpu_run rather than vcpu_enter_guest?

Paolo

