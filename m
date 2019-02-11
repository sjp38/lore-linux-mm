Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 172A1C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:19:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C694021B24
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:19:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C694021B24
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73CDF8E0122; Mon, 11 Feb 2019 13:19:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6EC838E0115; Mon, 11 Feb 2019 13:19:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58DAF8E0122; Mon, 11 Feb 2019 13:19:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 149268E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:19:16 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t65so6148094pfj.19
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:19:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=DlVeiZlXpHBGDhnP1NSo+yfANstvSp/dFAeSkT7skIQ=;
        b=eb9sPj5wkAzTO+G2oqfZD8VRsP6komyILQfFGXenm1Wue3saQuJ8GvM9ynnY2TzuRV
         lciYJU0wbTl6q5j7kKqPTqv9JFwKIi4LqC8y5wSjp8u5oTd45YY5V/thHJp775gCOAsS
         2v11BHVpNOmjZ3Zo5cdfgA+KHZouuJKvwIz1DmpIeMc/8NfwQ/fYgxLraeyctBe8NRHp
         aGBvgAxRUI4OSCdQdrCuMlaP9HVsdkEDsKpf6htAvKqBjVoH5g+oEiSObF31Ch5ag20C
         9r5QgZ91+KJsp31yPNHcgRdFFdOq6TzBfcrAwo65zP7/hkreIpKO0AzqhoL1UZO/fGXV
         3C0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaxuLaOcggoDC1NG65ju+B5kfUkEqnuhSn5amz9uRgIXS3gKeSM
	9AV3qdg0lwraUG/vh+VKi1B8cadu8LxAtrxB3f0p+jnm94cyuv8YOBJkz93XI9vxJTffmr9doQu
	Hy8/v/RZfOSAf15QR5xUw43kTMFIwiFx2XUrZgA8YfmGlrIRrFuBITGCRzNsPPfzhPA==
X-Received: by 2002:a63:5343:: with SMTP id t3mr830368pgl.415.1549909155766;
        Mon, 11 Feb 2019 10:19:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZAtcF9QAqmxl1r5pWsE80Oma/Fmn+AsUSndXdEiENpMDNgXfNHfwc9z8hk/HaUMjxnOpd2
X-Received: by 2002:a63:5343:: with SMTP id t3mr830332pgl.415.1549909155106;
        Mon, 11 Feb 2019 10:19:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549909155; cv=none;
        d=google.com; s=arc-20160816;
        b=xPX7V8f7364t4ztOOkmmR9Wo4RLVv1wx9CJqT4VZtuWU9tzhrILJZ2kLog1sTTOvbI
         4WZv9tmRBDNTIHYC4iqJxOucYpD7JqF9K4W7mqJYigePuWLFXq0p6F4wR7248giyZmpn
         CBto7Sa2Ze6dVLbmHG4RJNVmXjVRzQyi0IqKIzqdANzQCf2DjQ5aUl9wC7sruq5Eg9R7
         E3HKRNId/J5rSeEBx4Hf6U0ZxK70tUEUMy1m0/e4H+JlPmTd9LEjab6oIkjzYiCYRfjU
         3ZCuvKU3M232rMTME3xRyRPQUq9OrekkpP5uYrht8UyX/0d9foC2qVGLADSPROPxGFIo
         qj+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=DlVeiZlXpHBGDhnP1NSo+yfANstvSp/dFAeSkT7skIQ=;
        b=OFxLadvG+yb7QbkMLTJhNTAJvswqTf6UQVqCtETGnsBlfWzeLwTBpBpLATT4px4Nsq
         nWE4psisIEk79qfLtS/mZyvbnTouVmaZMRuO1MDN4doj6+qSwmxVqQTOrta9zcHvHoIs
         Cts0YChfzv7VSdv0eeLpKMRbh5c+LW9g8DJuoMSyeVZxdOdSoQ48p7Zt61EQsHJLwzuF
         aOGejIeAht/aNAchwqruj9HuNUVV9X1OfhgW/HcpXI92xBL8BJVbJQZYbq85LIxTq0Ru
         om8w91TthTI0O0cCGoXV1Ov3Kefj+4movJnt9vvMp+DbR+D/9kp+Wtu1A8wgeHi1sqxP
         FHvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 91si11029294ply.222.2019.02.11.10.19.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 10:19:15 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 10:19:14 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,359,1544515200"; 
   d="scan'208";a="298907299"
Received: from ray.jf.intel.com (HELO [10.7.201.16]) ([10.7.201.16])
  by orsmga005.jf.intel.com with ESMTP; 11 Feb 2019 10:19:14 -0800
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory hints
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com,
 alexander.h.duyck@linux.intel.com, x86@kernel.org, mingo@redhat.com,
 bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181552.12095.46287.stgit@localhost.localdomain>
 <20190209194437-mutt-send-email-mst@kernel.org>
 <0d12ccec-d05f-80b8-9498-710d521c81d2@intel.com>
 <20190211124925-mutt-send-email-mst@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <d0610465-1655-1fd0-4847-7a6ba233df85@intel.com>
Date: Mon, 11 Feb 2019 10:19:17 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190211124925-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/11/19 9:58 AM, Michael S. Tsirkin wrote:
>>> Really it seems we want a virtio ring so we can pass a batch of these.
>>> E.g. 256 entries, 2M each - that's more like it.
>> That only makes sense for a system that's doing high-frequency,
>> discontiguous frees of 2M pages.  Right now, a 2M free/realloc cycle
>> (THP or hugetlb) is *not* super-high frequency just because of the
>> latency for zeroing the page.
> Heh but with a ton of free memory, and a thread zeroing some of
> it out in the background, will this still be the case?
> It could be that we'll be able to find clean pages
> at all times.

In a systems where we have some asynchrounous zeroing of memory where
freed, non-zeroed memory is sequestered out of the allocator, yeah, that
could make sense.

But, that's not what we have today.

>> A virtio ring seems like an overblown solution to a non-existent problem.
> It would be nice to see some traces to help us decide one way or the other.

Yeah, agreed.  Sounds like we need some more testing to see if these
approaches hit bottlenecks anywhere.

