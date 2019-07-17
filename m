Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BF7FC76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 14:10:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F76C21848
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 14:10:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F76C21848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C520D6B0003; Wed, 17 Jul 2019 10:10:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C03D16B0005; Wed, 17 Jul 2019 10:10:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACBE58E0001; Wed, 17 Jul 2019 10:10:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A1C06B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 10:10:55 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id h47so21326566qtc.20
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 07:10:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=xwCK0TK56VM++9mQaLXBFC0FijDmj4o9eJc09COEf+g=;
        b=hPSvt3kQXkSXTs4xsHdViBrqL7g2an4IPwxJViAbgOjXN+98z9gwuDZ25RHXKoYzsD
         i4WnUFfsSizyG/alH3DBKkR1CkUYAQ++7kJHojZHkAI8zmzf2w95VcWtj/iP5uFOWWCp
         ytFaMVf/HUDGxyOmxx4JEiVaZFjqyVVZboV4Qz5j6qxnWHHNtt+yWskxGxjTpVlN68yW
         u49D33uMs3DG/ORIjgeNLw92vjVTefVLSqIOeq+2BDJmUiO+R5XpBuYd/Ap7ycJ3FlJ+
         PX7Vnb4rtrDdZq0ZAEqc9iC/qI5Tulpqk/Zn1fdRrM/o/FKOmt757gLcPe94D0zdesnG
         Wg9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU2fUi97EgU4CYMhlqupQ2xjnwkXHFFMpgTsq3VR8JaqcZBz/ol
	4q5+MwD7PZCHNuoxMMkNUVKYv+/EzihibuGvlqOZm08qExVTiJNL70XA+uBPlsQjGMyVasY8nfz
	h0nN46a06iUaIHPYREZbwzJW/4mgDymYumS2ZYYNpccheYOieEaekivnWZoUUagv74g==
X-Received: by 2002:a37:6944:: with SMTP id e65mr24457554qkc.119.1563372655295;
        Wed, 17 Jul 2019 07:10:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3JJZuMX7MVzGOYZoS9PUVhd060bJZjvhfYYIbF77M5ZAav+AuJxpR9gf2OY5HIsMwVdsT
X-Received: by 2002:a37:6944:: with SMTP id e65mr24457449qkc.119.1563372653958;
        Wed, 17 Jul 2019 07:10:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563372653; cv=none;
        d=google.com; s=arc-20160816;
        b=MA8RwbRh+u/H9rXTiQgP51QIzvI2cQfUQP5phv6SbOGmTcVLDbBB97qpLJEWpeSCyj
         5AjTr/HDHRSp5tPb6vLAAtV2Q8tHvLCBDtw3Hk30QzIBEQnQC8dvku3JzzxqWN7sHC+O
         ZRChtoMkPwRjmi2QFNDoX9Q3Lbz5iDjWBLIM3NV0hFsVmO5fNeHf3IsfL+dPIJEBahBr
         RxX5VagHC9NrBUdJsyTwBSsGOCsdh4nq2s6cHaHOXauG169Y/tsCIGSmfty/Hg9uCmN1
         dhIRtBNLkAjlddhpTM0d7GY7oxmT1NraBzM+qaP403bsoF5QRaR1McDo6i+TyYsblV/4
         4XjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=xwCK0TK56VM++9mQaLXBFC0FijDmj4o9eJc09COEf+g=;
        b=e08nD0ji/ddNypgRZGXBy6ja0g4pbNYh2FGsmklNR9y7IhAitqtxMkTDCiKppTl9on
         0bFgMupXNMJhN8H31gBYYMCXeAf2DLzhDZCisEUOw5/bN85WqH5nAQNUuzdrw7InqDol
         FAXjwDZxiJXxQJ/vHd+fIrh3Zd76Q94xr0bQjkKo7AmV9BCZN+OitopXEW2Z2B7XZXX/
         c0TM9tRgsjLQw5u3dpsEXMLxigZxy2rxq+AGrz1nwtcDGnRHphW21Ip2xX/8ySAqHE30
         zPYVdgQOIWGfKBwoviDj25h9dlMdMACEr4xurDNQzcomfvyC7jHqAbS6uMfDAMAvHxLu
         6sEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k39si16521561qtc.271.2019.07.17.07.10.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 07:10:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 02D833082141;
	Wed, 17 Jul 2019 14:10:52 +0000 (UTC)
Received: from [10.36.116.213] (ovpn-116-213.ams2.redhat.com [10.36.116.213])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 81B7360A35;
	Wed, 17 Jul 2019 14:10:48 +0000 (UTC)
Subject: Re: use of shrinker in virtio balloon free page hinting
To: "Michael S. Tsirkin" <mst@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Cc: wei.w.wang@intel.com, Nitesh Narayan Lal <nitesh@redhat.com>,
 kvm list <kvm@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com,
 Rik van Riel <riel@surriel.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com,
 Andrea Arcangeli <aarcange@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>,
 dan.j.williams@intel.com, Alexander Duyck <alexander.h.duyck@linux.intel.com>
References: <20190717071332-mutt-send-email-mst@kernel.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <959237f9-22cc-1e57-e07d-b8dc3ddf9ed6@redhat.com>
Date: Wed, 17 Jul 2019 16:10:47 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190717071332-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 17 Jul 2019 14:10:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17.07.19 13:20, Michael S. Tsirkin wrote:
> Wei, others,
> 
> ATM virtio_balloon_shrinker_scan will only get registered
> when deflate on oom feature bit is set.
> 
> Not sure whether that's intentional.  Assuming it is:
> 
> virtio_balloon_shrinker_scan will try to locate and free
> pages that are processed by host.
> The above seems broken in several ways:
> - count ignores the free page list completely
> - if free pages are being reported, pages freed
>   by shrinker will just get re-allocated again

Trying to answer your questions (not sure if I fully understood what you
mean)

virtio_balloon_shrinker_scan() will not be called due to inflation
requests (balloon_page_alloc()). It will be called whenever the system
is OOM, e.g., when starting a new application.

I assume you were expecting the shrinker getting called due to
balloon_page_alloc(). however, that is not the case as we pass
"__GFP_NORETRY".


To test, something like:

1. Start a VM with

-device virtio-balloon-pci,deflate-on-oom=true

2. Inflate the balloon, e.g.,

QMP: balloon 1024
QMP: info balloon
-> 1024

See how "MemTotal" in /proc/meminfo in the guest won't change

3. Run a workload that exhausts memory in the guest (OOM).

See how the balloon was automatically deflated

QMP: info balloon
-> Something bigger than 1024


Not sure if it is broken, last time I played with it, it worked, but
that was ~1-2 years ago.

-- 

Thanks,

David / dhildenb

