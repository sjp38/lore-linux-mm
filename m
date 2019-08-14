Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D08BC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 12:53:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE6D420679
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 12:53:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE6D420679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 77D7B6B0008; Wed, 14 Aug 2019 08:53:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 705E16B000A; Wed, 14 Aug 2019 08:53:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A71D6B000C; Wed, 14 Aug 2019 08:53:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0089.hostedemail.com [216.40.44.89])
	by kanga.kvack.org (Postfix) with ESMTP id 360286B0008
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:53:50 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D8063180AD801
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:53:49 +0000 (UTC)
X-FDA: 75821025378.30.chain77_2163f11149b13
X-HE-Tag: chain77_2163f11149b13
X-Filterd-Recvd-Size: 3903
Received: from mail-wm1-f67.google.com (mail-wm1-f67.google.com [209.85.128.67])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:53:49 +0000 (UTC)
Received: by mail-wm1-f67.google.com with SMTP id i63so4358717wmg.4
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 05:53:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=w/9WmrcXj+WSf8mG3UP1CEm5oCxjeGmdpSMvc0IgVzQ=;
        b=Erykp7pxvCdxs7kdlRXgYlJFy301t8pPf+se6mDsIteHPedQSXbAu3gRbu9qO4msOR
         ImVAwUBfFeBjlJ/AlL5ik4lUMRUK6dDQCk9oYRQQEvtzMi7JTPD6ROL8xfR1RD+I/bJS
         2DeMXZZWheJ0EQLqjO89q3sb0DfPWL4/OT6NcOeGUSpCkLufuefm0f3MEYMnOWnT87KW
         qmdlVcps+vXjrH1Ry0/0jEeXYZ/4Bl2wo6/Kz3UVGn4YdnfJHnNdO2HVhJocC35kirlD
         MaIF+h0SM2uPcf60KxDK2AG0MIHrWDts1ZSFjj4UYVJuwtLCwwNQXGvcG5vxCIMsdqGj
         Tc0A==
X-Gm-Message-State: APjAAAUsfUW+v6taJ/S89TndQu3SfHSetYe5O/HlkT+VVPsA2zJ5mAzx
	lGuihGI4v+xAM2UUiixXeIz+bg==
X-Google-Smtp-Source: APXvYqzEPFLFieg69AnBNaGIyKSm/YC4cyNCjZwla3TXgTG28lqZ11s6Gsx1a538xj5khmA4ksXdvw==
X-Received: by 2002:a1c:c018:: with SMTP id q24mr8315429wmf.162.1565787228293;
        Wed, 14 Aug 2019 05:53:48 -0700 (PDT)
Received: from [192.168.10.150] ([93.56.166.5])
        by smtp.gmail.com with ESMTPSA id d19sm28086256wrb.7.2019.08.14.05.53.46
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Aug 2019 05:53:47 -0700 (PDT)
Subject: Re: [RFC PATCH v6 64/92] kvm: introspection: add single-stepping
To: Nicusor CITU <ncitu@bitdefender.com>,
 Sean Christopherson <sean.j.christopherson@intel.com>,
 =?UTF-8?Q?Adalbert_Laz=c4=83r?= <alazar@bitdefender.com>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "virtualization@lists.linux-foundation.org"
 <virtualization@lists.linux-foundation.org>,
 =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 Tamas K Lengyel <tamas@tklengyel.com>,
 Mathieu Tarral <mathieu.tarral@protonmail.com>,
 =?UTF-8?Q?Samuel_Laur=c3=a9n?= <samuel.lauren@iki.fi>,
 Patrick Colp <patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
 Stefan Hajnoczi <stefanha@redhat.com>,
 Weijiang Yang <weijiang.yang@intel.com>,
 "Zhang@linux.intel.com" <Zhang@linux.intel.com>, Yu C
 <yu.c.zhang@intel.com>, =?UTF-8?Q?Mihai_Don=c8=9bu?=
 <mdontu@bitdefender.com>, Jim Mattson <jmattson@google.com>,
 Joerg Roedel <joro@8bytes.org>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-65-alazar@bitdefender.com>
 <20190812205038.GC1437@linux.intel.com>
 <f03ff5fbba2a06cd45d5bebb46da4416bc58e968.camel@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <5851eb00-3d00-1213-99cb-7bab2da3ba89@redhat.com>
Date: Wed, 14 Aug 2019 14:53:46 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <f03ff5fbba2a06cd45d5bebb46da4416bc58e968.camel@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14/08/19 14:36, Nicusor CITU wrote:
> Thank you for signaling this. This piece of code is leftover from the
> initial attempt to make single step running.
> Based on latest results, we do not actually need to change
> interruptibility during the singlestep. It is enough to enable the MTF
> and just suppress any interrupt injection (if any) before leaving the
> vcpu entering in guest.
> 

This is exactly what testcases are for...

Paolo

