Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C43FC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:06:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1E682063F
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:06:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1E682063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EF0A6B0007; Tue, 13 Aug 2019 05:06:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97AA86B0008; Tue, 13 Aug 2019 05:06:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 818886B000A; Tue, 13 Aug 2019 05:06:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0051.hostedemail.com [216.40.44.51])
	by kanga.kvack.org (Postfix) with ESMTP id 59D026B0007
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:06:55 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E949F8E7F
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:06:54 +0000 (UTC)
X-FDA: 75816824748.04.coach64_1f3b7a47c6e05
X-HE-Tag: coach64_1f3b7a47c6e05
X-Filterd-Recvd-Size: 3763
Received: from mail-wr1-f68.google.com (mail-wr1-f68.google.com [209.85.221.68])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:06:54 +0000 (UTC)
Received: by mail-wr1-f68.google.com with SMTP id z1so107032332wru.13
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 02:06:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=MRboZnkOwIqMqx46t0ZQ9zepiSGdc691QK9w7wR1ygw=;
        b=JzLfqpbOi8TQNm4LhTv1Kds/fulocMJ5/BgtRIe8d4EsypaDTgdjbj/HbkqJnkf3Ic
         eD/XKaOPf8i7Ap74gnqH3ndGIAtPPYcosLfOIDuCoEuH5xXXZH/9o7oPYW0gNr2kiS96
         DCRNm+4v/zIn8Mpg75JBAWRi/Pw8uiDX/mbw1fcc8aPzlEL87pDTAepHIhwP0FEDEhGW
         hxB7lz04QVMsbBREn1a8/7I64IJWSnGjOkq0ZqJAklUL0YA+USfKFewAyV/SDYar7b2o
         RPAmYc6Hxj70fSkkC9TQ8Lxf2PHWpytKaGN2hWYh8eags8jECaMQQKtnAt0dDlszNN/R
         1m9w==
X-Gm-Message-State: APjAAAUAO9wYeqhKx2IBCSBI6ynaSr1CppNtPXcvFpARkjHsaUUYgK/W
	7CrprpeI0mV4AhvUeE2YSDVrCg==
X-Google-Smtp-Source: APXvYqweK6uM1R3qYisV+zwsl38ikaVzEXE80NEPe0UggCtqMVhBk6tbs9HWluPuTVYiwrckbrYbsA==
X-Received: by 2002:adf:aa8d:: with SMTP id h13mr39037899wrc.307.1565687213313;
        Tue, 13 Aug 2019 02:06:53 -0700 (PDT)
Received: from [192.168.10.150] ([93.56.166.5])
        by smtp.gmail.com with ESMTPSA id a17sm677722wmm.47.2019.08.13.02.06.51
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 02:06:52 -0700 (PDT)
Subject: Re: [RFC PATCH v6 27/92] kvm: introspection: use page track
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
 =?UTF-8?B?TmljdciZb3IgQ8OuyJt1?= <ncitu@bitdefender.com>,
 Marian Rotariu <marian.c.rotariu@gmail.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-28-alazar@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <0e6703cd-2d0b-ccd2-c353-c5f5de659837@redhat.com>
Date: Tue, 13 Aug 2019 11:06:50 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809160047.8319-28-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/19 17:59, Adalbert Laz=C4=83r wrote:
> +
> +	/*
> +	 * This function uses kvm->mmu_lock so it's not allowed to be
> +	 * called under kvmi_put(). It can reach a deadlock if called
> +	 * from kvm_mmu_load -> kvmi_tracked_gfn -> kvmi_put.
> +	 */
> +	kvmi_clear_mem_access(kvm);

kvmi_tracked_gfn does not exist yet.

More in general, this comment says why you are calling this here, but it
says nothing about the split of responsibility between
kvmi_end_introspection and kvmi_release.  Please add a comment for this
as soon as you add kvmi_end_introspection (which according to my earlier
review should be patch 1).

Paolo

