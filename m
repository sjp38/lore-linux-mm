Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A229C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:54:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7824206B7
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:54:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7824206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 728036B000A; Wed,  3 Apr 2019 04:54:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D7B16B000C; Wed,  3 Apr 2019 04:54:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59FB36B000D; Wed,  3 Apr 2019 04:54:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 33D476B000A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:54:32 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id t22so16190118qtc.13
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:54:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=6yOJorzNGGU5HiAje+tjFE1jELyyrXzt9SSVwrWzt9M=;
        b=FN2iRHByEA3+bqlm2uTceS3ajV5zVUh+E0PW1Qxq/P/SZspfjSaBU+6vUesLh7f0Dm
         LTI2/cteZ+GevKXT2EDa/p2mP7yI+diNE0SoNLnB8UI0BGZWJf7CPTqq6dT7UBv7hSBU
         tmeShJcBBOtFFhNXNpMIm1CFSWgmsiaLZLnEatUxd96hBer+yqvb9RIbVU0mNwbcV6lA
         f4eV96XQXAlu8UMnXrlGgIEi63rQY6RH+gUcK+TmDFtlw4JOryQOFmWw+Ao25JI/TjQe
         aDI5jB3sJUPUiayloYZakmh+Z86RlMJ0Nyf/67HHhia5VoMuqLoGkW+JyRDR+LbDUNKJ
         o8Ww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVqvXV7f8/PpZZYFgzMXt5tiDk6MDn9m7G+UA2rSYLqzBRmPeqR
	Eg1SBx9LnfYAaMK5Ulcrpda7ZnNllRucmPmhvCP9216MGUSE8Gc040tMhEWhe19VM/4UU9Gwasj
	plyYoV6FEMsX98vx8QX0TwbiU0LR1mF/J/zsAqfsHeEidBcq1MeRSzW0MzLOIn+f7bw==
X-Received: by 2002:a05:620a:1529:: with SMTP id n9mr50548829qkk.190.1554281671998;
        Wed, 03 Apr 2019 01:54:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZwYWJN5MC3f4h/ijJTERsk9NAiD5Y0Blz9ejVC5InW5vvcfORI0H2n7kYHxIzAlVVJe4o
X-Received: by 2002:a05:620a:1529:: with SMTP id n9mr50548805qkk.190.1554281671504;
        Wed, 03 Apr 2019 01:54:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554281671; cv=none;
        d=google.com; s=arc-20160816;
        b=mqwtta76r2M24fd3rZf//9ud5F4GxUKVEs3BhAbghHoeMm60zq4St55gbZjRx6r9/7
         WgWaqYeupXXNHuMAvoTIqjlNRzEtvvB2SzJujnt2NijcReWMX9mzFUQEfKWAljbNiQij
         q4uI9PEx2+9dMqEXNn8Qk3+oajpAXIz/IxrR0HhYIcLnIkE3a1Iq/TM2EM9W06FoDrEO
         Nl/VtzhqbrsfTSEdwZ0+YVEfFNNulVuGua5B/ZSyMTPq3uI7FxYqPg4ye4cZV6Imyhla
         Ah8O709/+8Wrw95DX6S5cpnvRK+vug8c8elOUla8C7nVIs8tB0kVBhDq8PA+Ha41lwTq
         N49g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=6yOJorzNGGU5HiAje+tjFE1jELyyrXzt9SSVwrWzt9M=;
        b=o1lPHSQgbE6c5x/919IHPoFhMECwnkVINVdm7Zq6j5j03gThWZIg0+HHxHoZ3GoRQo
         ep0By7BmH9+8NdjY4TkG4MND8a0G2v/bZVPKBsif2gbh0MK50HBNDeAMz5BBtrG4l5lf
         BVQgnfg94pvYIdlencug5Ia3DAusPOTCbe7Ps6xWwNm6S6ML8L+CNV1Ek0jarvyy5S8L
         Y9nAStjgRrBbq3NORZgNdlUM8qlvrfY1zStC6YODoqGET6EDmBlle7100VLpiIaGtpaJ
         hQcMtOGyQQuUVedAZCArToe2ArNO3czQy5SAqgO2m6QTdDtWc/jDCE5ed3n7o5RdxkQE
         dSjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t36si3852747qvj.49.2019.04.03.01.54.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 01:54:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9117B3086206;
	Wed,  3 Apr 2019 08:54:30 +0000 (UTC)
Received: from [10.36.117.246] (ovpn-117-246.ams2.redhat.com [10.36.117.246])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D623E60145;
	Wed,  3 Apr 2019 08:54:28 +0000 (UTC)
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
To: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org,
 dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
 anshuman.khandual@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190329134243.GA30026@dhcp22.suse.cz>
 <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
 <20190401115306.GF28293@dhcp22.suse.cz>
 <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
 <20190402124845.GD28293@dhcp22.suse.cz>
 <20190403080113.adj2m3szhhnvzu56@d104.suse.de>
 <20190403081232.GB15605@dhcp22.suse.cz>
 <d55aa259-56c0-9601-ffce-997ea1fb3ac5@redhat.com>
 <20190403083757.GC15605@dhcp22.suse.cz>
 <04a5b856-c8e0-937b-72bb-b9d17a12ccc7@redhat.com>
 <20190403085042.t5wcyvaolxiw65rr@d104.suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <815a98e1-3b2e-e5c8-5074-7f46a363adb8@redhat.com>
Date: Wed, 3 Apr 2019 10:54:28 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190403085042.t5wcyvaolxiw65rr@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 03 Apr 2019 08:54:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03.04.19 10:50, Oscar Salvador wrote:
> On Wed, Apr 03, 2019 at 10:41:35AM +0200, David Hildenbrand wrote:
>>> That being said it should be the caller of the hotplug code to tell
>>> the vmemmap allocation strategy. For starter, I would only pack vmemmaps
>>> for "regular" kernel zone memory. Movable zones should be more careful.
>>> We can always re-evaluate later when there is a strong demand for huge
>>> pages on movable zones but this is not the case now because those pages
>>> are not really movable in practice.
>>
>> Remains the issue with potential different user trying to remove memory
>> it didn't add in some other granularity. We then really have to identify
>> and isolate that case.
> 
> If we let the caller specify whether it wants vmemmaps per memblock or range,
> I would trust that caller to do the correct thing and specify one thing or
> another depending on what it wants to do in the future.
> 
> So, say a driver adds 512MB memory and it specifies that it wants vmemmaps per
> memblock because later on it will like to hot-remove in chunks of 128MB.
> 

I am talking about the memtrace and ACPI thing. Otherwise I agree, trust
the user iff the user is the same person adding/removing memory.

-- 

Thanks,

David / dhildenb

