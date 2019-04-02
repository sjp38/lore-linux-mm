Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A690C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:33:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51C6C2075E
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:33:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51C6C2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAAF06B0275; Tue,  2 Apr 2019 16:33:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5A326B0276; Tue,  2 Apr 2019 16:33:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D24C06B0277; Tue,  2 Apr 2019 16:33:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF83A6B0275
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 16:33:10 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id f89so14677374qtb.4
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 13:33:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=i4HplNV5P3s3QmOHt6Yz/xKAFijUxu05uoBUBR8bozY=;
        b=H+MU4lHuV+jMZ6KlQAmOie4sZOeVdC9JPJ9s21uZxSoHAiTYdMpstwGo+JourGScYd
         KiMkrDuM/WYJUHr4HLpWvzCAMSxnGG/2InNwcVN1GXapelDCRwG098AfXaYfQBIBWbFT
         J/fPEQuoVX9NJWY7w7ooTWntbMGAkQz0GPa6M0zfHiwr3tX6tHs5EV4ibA55v5uDWOc4
         NJ0/VoqsQn8tt5ypLBOVoq3sSzeoDuvPvQYj2Obsm9FP9RkWZ9KC/AOKp6iKvo8DdOUk
         EdSrqVVwHsFYY2lmp0zAXf8/4UVfRrD65LhNVJ6X4Esyp7tyFLjWGzLmubP7aktiABjJ
         p/cg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXodRbfc0/bnaKtI0i37NOmstpJLcBL1ZA7coBnoZ6W2zWTJ65U
	y5Jt40JwX9Z3OlfgSAijNLm//zMK3U38SXiDZsqYEQ4wWvshadNaJOar10SAeprkyRvLbmHCiSx
	Rm7Uj8q+CqzbsLs8uFZLOD9GbXAv1uEfjf+ouW7JGhDNj1GQ3oM6RMpRPOc+eH0mOtg==
X-Received: by 2002:a37:a390:: with SMTP id m138mr56159769qke.72.1554237190466;
        Tue, 02 Apr 2019 13:33:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYG2aV4bnbnrs2OBFUu1pIPGoRMhll3GpCgl1DIpXgaZUk8CCLxlfJlquQOPQXLLgFJ9uz
X-Received: by 2002:a37:a390:: with SMTP id m138mr56159732qke.72.1554237190009;
        Tue, 02 Apr 2019 13:33:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554237190; cv=none;
        d=google.com; s=arc-20160816;
        b=nZAecjgEy39WEBGl/KDTP4waLmyHO1SrcqnESlAzW3eCLcyXK0Pu6ZXJoqQrwKxTBk
         rLW0Wn3omF5M7yPxX9Y+1/PRq/e2kHGQSVFvCnDHtKXCUOMCjoESqkcBbCtaT3PGPSts
         jCbBXi1rZGC4GUuBw02ZRfs66P/M5F3l8+TiI82F6wg65EG1oJbCO1dkn8YrG9UfRm1d
         bj0IVWm6evm9iud+gonJwEb2NRbJ8KQuS4y6JiDhQPhcybwMFMHjH4GA1PuDx5siTri1
         sizDS/zV9wBNoPi/qSAwhzkAdVzORqX9knZ7AVJe8isc23lCooM7MufMm2DqyORrnur3
         h8jQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=i4HplNV5P3s3QmOHt6Yz/xKAFijUxu05uoBUBR8bozY=;
        b=iVorzSyvNNR7dAJ/JECpnP0u13yqhLZp8ImsXbU6Wx/pYGL9GHQS+dEYCDUbrIspyk
         httLiPn3FV4izZFFMdHCPaGtx+uuj4ZTxJiTI/ukrD2VN/fvuubGi6gGPFZv71rhq8Pt
         5gXelqCMKhr4OjodT2HjxmSWO57Pn96HRlgLg5dvsGu0mewn5YFVl2xI1YCFzipXW6KS
         fG29PFu2+Wn7AX5BAj4bKrp74Glor7mOLEZZ1hcGUmoY6dQJMHRitW7gUaHGmYz1ysrp
         1vfqeCUoZtHP7l3HJDE5zK9hfAECMp/D7gDXOMSnsKh8cvmHXsTAXGAkuB7jnunTlSgF
         sF/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o48si1360166qto.140.2019.04.02.13.33.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 13:33:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0D12E8B962;
	Tue,  2 Apr 2019 20:33:09 +0000 (UTC)
Received: from [10.36.116.90] (ovpn-116-90.ams2.redhat.com [10.36.116.90])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3848D7D147;
	Tue,  2 Apr 2019 20:32:59 +0000 (UTC)
Subject: Re: On guest free page hinting and OOM
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
 Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, Yang Zhang <yang.zhang.wz@gmail.com>,
 Rik van Riel <riel@surriel.com>, dodgen@google.com,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
 Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>
References: <20190401104608-mutt-send-email-mst@kernel.org>
 <CAKgT0UcJuD-t+MqeS9geiGE1zsUiYUgZzeRrOJOJbOzn2C-KOw@mail.gmail.com>
 <6a612adf-e9c3-6aff-3285-2e2d02c8b80d@redhat.com>
 <CAKgT0Ue_By3Z0=5ZEvscmYAF2P40Bdyo-AXhH8sZv5VxUGGLvA@mail.gmail.com>
 <20190402112115-mutt-send-email-mst@kernel.org>
 <3dd76ce6-c138-b019-3a43-0bb0b793690a@redhat.com>
 <CAKgT0Uc78NYnva4T+G5uas_iSnE_YHGz+S5rkBckCvhNPV96gw@mail.gmail.com>
 <6b0a3610-0e7b-08dc-8b5f-707062f87bea@redhat.com>
 <CAKgT0UdHA66z1j=3H06AfgtiF4ThFdXwQ6i8p1MszdL2bRHeZQ@mail.gmail.com>
 <d105e3c7-52b4-de94-9f61-0aee5442d463@redhat.com>
 <20190402154732-mutt-send-email-mst@kernel.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <bf90043d-e592-1cb1-182d-1cc805b68050@redhat.com>
Date: Tue, 2 Apr 2019 22:32:58 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190402154732-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 02 Apr 2019 20:33:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02.04.19 21:49, Michael S. Tsirkin wrote:
> On Tue, Apr 02, 2019 at 08:21:30PM +0200, David Hildenbrand wrote:
>> The other extreme is a system that barely frees (MAX_ORDER - X) pages,
>> however your thread will waste cycles scanning for such.
> 
> I don't think we need to scan as such. An arch hook
> that queues a job to a wq only when there's work to
> do will fix the issue, right?
> 

Well, even a system that is basically idle can theoretically free a
handful of pages every now and then you would like to report. There
would have to be a mechanism to detect if pages worth hinting have been
freed and need processing, IOW something like a callback after buddy
merging we are already dealing with.

That can then be a simple flag which the hinting thread considers (e.g.
wake up every X seconds to check if there is work) or kicking the
hinting thread like you suggest.

-- 

Thanks,

David / dhildenb

