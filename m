Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08253C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:17:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA5342084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:17:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA5342084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 524D96B0008; Wed,  3 Apr 2019 04:17:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D01B6B000A; Wed,  3 Apr 2019 04:17:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 332DC6B000C; Wed,  3 Apr 2019 04:17:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9F26B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:17:31 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id g7so13942776qkb.7
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:17:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=vDWFrrrmVN71h31ZLDbUO5HYDV9P0xTCBEXzKPdo/oQ=;
        b=n5z8A20dVOUlSs6dvq5w2PcCNhp4t+eaVaKSMvFTlnWn1T/eN98bHqMLuJlb4qGjSN
         WiMXkwbnp41Z6XZD7avXOMaaj+BxrEBmWH2/SiRQJSq+AS26Ywt2RWmr+pAykv+Zw3bH
         XMRFRSxhuMekEkh5x2DQgVsPOkyJbKggdV3Isx/o02EzvGFFmSFHe2/4WieQwoDvLuH3
         bF9dnhzvbh06KfZ9alpqvmy3HQLRj3D8dZNZq8M963gtsBIUNtTrMJ2MnTlwWaO6SrkB
         1Iz1sOsRzx72gQLNGP2eaZam4YM7xZsc5npomd2wQ21flS4gHC7TiAfRpaub/ZbOHt5o
         QQpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXYvlQXFx7tKKwE4rMpUKrZvRmBv1kSjsgrS1aDr9efnQ5Q1Ypp
	T2iIwa3JdQhODhEMcC3c5LnXW8VdZrNzCroYL/ZWsIuROhRzrReEQS1XyyCw/1yr2YxgO4p/V4E
	Bkhf4u3oG7MxcssCLrxzADGYqaUgJ9syXf4KdahrkUVie7M/x2dxmk3j46CeaNmq8GA==
X-Received: by 2002:ac8:37c7:: with SMTP id e7mr53782843qtc.46.1554279450807;
        Wed, 03 Apr 2019 01:17:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWbYlOd7Ue2edGyys+03dnLyloIVK0YWPpTGEwBMa2NDvad8QcataWXrW2FYilsRw+Jbwy
X-Received: by 2002:ac8:37c7:: with SMTP id e7mr53782812qtc.46.1554279450281;
        Wed, 03 Apr 2019 01:17:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554279450; cv=none;
        d=google.com; s=arc-20160816;
        b=Wdr77NnFiziwKa6sjauuO7CLrmBfKSheD/lDLKJodemv9JabSs7FxYih8OMjLW8txF
         Jvw5SFm0P97irNglwp7N4970Yc0RBZGBBOPC83fivGICHX8kpa+TVFyX7YQs+DDFBZW7
         AGiiT5WA+QFiglgInXElwJtc9eFQJPRZJC0yT2/q7z1Vu53vmfRkTZEy/dtHSpNe44eg
         OjBeI92e33eyaPt1e8OOPOb1rRTPjQNV//kTHWrt0ToucBxLpE4pKUvrjzlnuUzyPdh7
         Xwtvx7T8C05nuaZaaIqH8tLqv9KYE08A/NKBzi3TuwPVVLBSfxFZ5nThNdg3nNt2OHSi
         PAkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=vDWFrrrmVN71h31ZLDbUO5HYDV9P0xTCBEXzKPdo/oQ=;
        b=AXTXk8MKMZvfVWUkLIZ+tkuntY+n5Pm6nzvUloYEv2IEMtGwiHZM4mUgtahWqqQ5D2
         kpmiMz2f/hvv6j/l7trqVEEWIw0ewVgYH57TBpqTgPVtXOb5NidAAoWZWY013gnrbR5b
         lJ9AcRBwWXocR7m+vVJOdP1iLmgYAcGdKTnPafuxcAyKJGk/29EtQkVaSMoiSCqfopGs
         mCYHZ63Y++rpH/sjk2GPMmx6o4+Iwh+sxs2qPmMJUoKZvK95GDFtnnSJq1NZ8hRKkOeG
         LgNRM2A75XI/IZMVzNplhsk4yuiFX8qrNip2ZredhyT5a6ZJKTmu0e3V8ABxick2151D
         MaOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c47si3520147qve.197.2019.04.03.01.17.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 01:17:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5B3DA30B9318;
	Wed,  3 Apr 2019 08:17:29 +0000 (UTC)
Received: from [10.36.117.246] (ovpn-117-246.ams2.redhat.com [10.36.117.246])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A5D5C608D4;
	Wed,  3 Apr 2019 08:17:27 +0000 (UTC)
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
To: Michal Hocko <mhocko@kernel.org>, Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com,
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190328134320.13232-1-osalvador@suse.de>
 <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
 <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
 <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
 <20190329134243.GA30026@dhcp22.suse.cz>
 <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
 <20190401115306.GF28293@dhcp22.suse.cz>
 <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
 <20190402124845.GD28293@dhcp22.suse.cz>
 <20190403080113.adj2m3szhhnvzu56@d104.suse.de>
 <20190403081232.GB15605@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <d55aa259-56c0-9601-ffce-997ea1fb3ac5@redhat.com>
Date: Wed, 3 Apr 2019 10:17:26 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190403081232.GB15605@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 03 Apr 2019 08:17:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03.04.19 10:12, Michal Hocko wrote:
> On Wed 03-04-19 10:01:16, Oscar Salvador wrote:
>> On Tue, Apr 02, 2019 at 02:48:45PM +0200, Michal Hocko wrote:
>>> So what is going to happen when you hotadd two memblocks. The first one
>>> holds memmaps and then you want to hotremove (not just offline) it?
>>
>> If you hot-add two memblocks, this means that either:
>>
>> a) you hot-add a 256MB-memory-device (128MB per memblock)
>> b) you hot-add two 128MB-memory-device
>>
>> Either way, hot-removing only works for memory-device as a whole, so
>> there is no problem.
>>
>> Vmemmaps are created per hot-added operations, this means that
>> vmemmaps will be created for the hot-added range.
>> And since hot-add/hot-remove operations works with the same granularity,
>> there is no problem.
> 
> What does prevent calling somebody arch_add_memory for a range spanning
> multiple memblocks from a driver directly. In other words aren't you

To drivers, we only expose add_memory() and friends. And I think this is
a good idea.

> making  assumptions about a future usage based on the qemu usecase?
> 

As I noted, we only have an issue if add add_memory() and
remove_memory() is called with different granularity. I gave two
examples where this might not be the case, but we will have to look int
the details.

-- 

Thanks,

David / dhildenb

