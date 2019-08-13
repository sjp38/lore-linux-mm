Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37E35C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:03:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6C7520842
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:03:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6C7520842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A94306B0282; Tue, 13 Aug 2019 17:03:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FFF46B0283; Tue, 13 Aug 2019 17:03:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8221B6B0284; Tue, 13 Aug 2019 17:03:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0216.hostedemail.com [216.40.44.216])
	by kanga.kvack.org (Postfix) with ESMTP id 53F8D6B0282
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:03:15 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id EB332181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:03:14 +0000 (UTC)
X-FDA: 75818629908.27.slip98_1c3bdd00df055
X-HE-Tag: slip98_1c3bdd00df055
X-Filterd-Recvd-Size: 3763
Received: from mail-wr1-f66.google.com (mail-wr1-f66.google.com [209.85.221.66])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:03:13 +0000 (UTC)
Received: by mail-wr1-f66.google.com with SMTP id j16so6787284wrr.8
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:03:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=tEhHgLcqlA5tSM/U7PsVGRMmj61U+t1w86jQUqeFNZo=;
        b=n4ovmk9dwvlL3Qod9OgxQnpipPM9MYi7LB1FSm6C6fepf33xeQV50FrhaWwRVjQVpv
         /3hBYzU++tNGOM3Tv3r4gmKQGnUMfXZq5aeC7urc/AjAcvDyrK6T0iNMRtGrhjVMrZmS
         HCG6vgxsNArsBwPHyoHJsPIUiV3Sq7IxrPzmHannqyWt/bLxHdeiru6l8J/McEP3Vpiv
         x9nZHkk7WAxAyEh/jwydZkBl+ZnxvjF+3yy/qC9HhoL0LHLDmm/Ypj2ne7ZwyN46RtEc
         24BZfUL7Aztl05QH8qVlGSQQVjULzWhQyJsVYA12q3e7YF5Pgoe/LEjCe5WwCqY452Ea
         PI8Q==
X-Gm-Message-State: APjAAAUJeF4M9su3OgY/l7n55a65GxfptDNBsixiT6TpHxfm8xYQvZxf
	Flbuw6jFrYXGWadd+U4/t7/Yew==
X-Google-Smtp-Source: APXvYqzCH0YYNT+mm2NCMtG/p/XSQ0nRVPLtvaYvNv2whhtGv6yScErnL+PDu/Cb4oX9gIIDZ6+Shg==
X-Received: by 2002:a05:6000:14b:: with SMTP id r11mr48965825wrx.196.1565730192616;
        Tue, 13 Aug 2019 14:03:12 -0700 (PDT)
Received: from [192.168.10.150] ([93.56.166.5])
        by smtp.gmail.com with ESMTPSA id u8sm1872737wmj.3.2019.08.13.14.03.11
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 14:03:11 -0700 (PDT)
Subject: Re: [RFC PATCH v6 01/92] kvm: introduce KVMI (VM introspection
 subsystem)
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: =?UTF-8?Q?Adalbert_Laz=c4=83r?= <alazar@bitdefender.com>,
 kvm@vger.kernel.org, linux-mm@kvack.org,
 virtualization@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?=
 <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 Tamas K Lengyel <tamas@tklengyel.com>,
 Mathieu Tarral <mathieu.tarral@protonmail.com>,
 =?UTF-8?Q?Samuel_Laur=c3=a9n?= <samuel.lauren@iki.fi>,
 Patrick Colp <patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
 Stefan Hajnoczi <stefanha@redhat.com>,
 Weijiang Yang <weijiang.yang@intel.com>, Zhang@vger.kernel.org,
 Yu C <yu.c.zhang@intel.com>, =?UTF-8?Q?Mihai_Don=c8=9bu?=
 <mdontu@bitdefender.com>, =?UTF-8?Q?Mircea_C=c3=aerjaliu?=
 <mcirjaliu@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-2-alazar@bitdefender.com>
 <20190812202030.GB1437@linux.intel.com>
 <5d52a5ae.1c69fb81.5c260.1573SMTPIN_ADDED_BROKEN@mx.google.com>
 <5fa6bd89-9d02-22cd-24a8-479abaa4f788@redhat.com>
 <20190813150128.GB13991@linux.intel.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <add4f505-7011-c7f4-2361-c8814cac2424@redhat.com>
Date: Tue, 13 Aug 2019 23:03:10 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190813150128.GB13991@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13/08/19 17:01, Sean Christopherson wrote:
>>> It's a bit unclear how, but we'll try to get ride of the refcount object,
>>> which will remove a lot of code, indeed.
>> You can keep it for now.  It may become clearer how to fix it after the
>> event loop is cleaned up.
> By event loop, do you mean the per-vCPU jobs list?

Yes, I meant event handling (which involves the jobs list).

Paolo

