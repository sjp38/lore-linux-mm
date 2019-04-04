Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CE4DC10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 10:06:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8D222184B
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 10:06:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8D222184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68BAE6B0007; Thu,  4 Apr 2019 06:06:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 616646B0008; Thu,  4 Apr 2019 06:06:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B9526B0269; Thu,  4 Apr 2019 06:06:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 21E056B0007
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 06:06:26 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id f196so1738613qke.4
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 03:06:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=QZbBiQmtrF4j5GOuYw/Tekpv7hx4YaR73WxSA0Pnm3o=;
        b=EUKgo2AHDUjwVm1vJnVl3S3tbqZ33LAKMuIgpr6jg50vNGA0CvdFskyN+JlEcQXKFs
         ratyX4vDMW8gri3V6BsYDCYBc+2qyqh2zm+RvJjCMrIdaF7HoUbMKR1raQ8nkc9Cm+Nu
         9YTqOGtmQmPKy0mB/zVSkvWl43V1D0BMenMpwO8kRnu602YjbTyy07rJG52FkSZv/buw
         C4dKPXNBwpVRAX+nR00JAdHzloeSybTkZHEVA78URXdFWgZmiBF+lfhjdUPh6y1DwOuR
         SO5J1N4aNTFqtAvuyeOvd/XciHFIx5R098qT/zC8mZ0HdunaEt3oyH1gblvtMdilV5WP
         w3dQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXGPFkFJ95pcDqdWrA1vOkoE7TaQLKIoRh5Vb0cl7OFbTGpBOzd
	YnNqBF608Vlhwqxmn+kdoXAMkOPAu+xeiU6BpknlhvWMS1U7K6uDrNU4boRDYgLdzJSJmOBDjW9
	gxRnbkqBcHNJDCizvL1P3PDN+DuFyklurB5rpk2kyuQ8o1RZzmLVILJuFF5w7/BHhGw==
X-Received: by 2002:a0c:d4a2:: with SMTP id u31mr4051680qvh.139.1554372385893;
        Thu, 04 Apr 2019 03:06:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztOfWan+lc+jaxiyfY6qQW2DyvCtEfFaX/QyEu7HpdQkE9pKlL+To3ByE/2h5ThPMS2DhD
X-Received: by 2002:a0c:d4a2:: with SMTP id u31mr4051638qvh.139.1554372385331;
        Thu, 04 Apr 2019 03:06:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554372385; cv=none;
        d=google.com; s=arc-20160816;
        b=mePzEkZc5yjoPaKBw58KkZfpMaGBXwXFGVc3Iu+UKBOCR1pOXfMmfM5Pw9KzZv0/Pl
         kjSVamBRqbGSZ8LefrHLCyWR6Qh8Mp6kKnBSWAPJAkPdnBfOhPEF/rxm26e1XrDRIdvV
         5wdUggrpgQT8eskVYjD44aG5EitYP7kJDxwtNYL8PDU0TIJWxs+bQalc6dgCwKTVqYW4
         OjUvde2foJ/Wr2mhOde30v36QLhUekYLsEIuXiDInRJUDvIz0iyEU4z3zBgudTkSwSN1
         sR2Yl8zkT6vy5nG03mp7UMQhgOIiGjFSZ6fl5N6SLg50hedsZXbauLhf/FBD6ae5HsHz
         G6CQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=QZbBiQmtrF4j5GOuYw/Tekpv7hx4YaR73WxSA0Pnm3o=;
        b=KgrMKPLMeecK6eX0M+V46EU9fmzWP7mC/gsEO4eg2032I2Z4RVjPM5KctUbDiOhHhb
         pcOUtluvQKTwzeGyMu3f+pA6MTuHrPjljJ8sdMMOJVLELtluLzr6ROBCRdTiXwcpioyk
         vgWatDFje7ex/4okmMeDu9LfnwCGEnuyARLhe4czLMKME8dh7eoOQCy1UXDJXiLLaLrW
         LViwrvSjM6BwQrY+r14RsLyDyL7OMLCWh0rCGQnFFj8WQgUs/dOZ8jyhvDfmaHCAZKzR
         CjS84mTfCltAGb/rfc+8L0czm3GmCGRrrp3Qv+oxKcTsVgZ0ClmEJ7Qvyi2bdRvf8Syc
         Edow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d44si7376964qvd.22.2019.04.04.03.06.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 03:06:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 672D33082B71;
	Thu,  4 Apr 2019 10:06:24 +0000 (UTC)
Received: from [10.36.117.116] (ovpn-117-116.ams2.redhat.com [10.36.117.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A33D14149;
	Thu,  4 Apr 2019 10:06:22 +0000 (UTC)
Subject: Re: [PATCH 2/4] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
To: Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com,
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190328134320.13232-1-osalvador@suse.de>
 <20190328134320.13232-3-osalvador@suse.de>
 <20190403084603.GE15605@dhcp22.suse.cz>
 <20190404100403.6lci2e55egrjfwig@d104.suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <9cc998c7-4e01-20b2-8765-77bfccfaebbc@redhat.com>
Date: Thu, 4 Apr 2019 12:06:16 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190404100403.6lci2e55egrjfwig@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Thu, 04 Apr 2019 10:06:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04.04.19 12:04, Oscar Salvador wrote:
> On Wed, Apr 03, 2019 at 10:46:03AM +0200, Michal Hocko wrote:
>> On Thu 28-03-19 14:43:18, Oscar Salvador wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>> arch_add_memory, __add_pages take a want_memblock which controls whether
>>> the newly added memory should get the sysfs memblock user API (e.g.
>>> ZONE_DEVICE users do not want/need this interface). Some callers even
>>> want to control where do we allocate the memmap from by configuring
>>> altmap.
>>>
>>> Add a more generic hotplug context for arch_add_memory and __add_pages.
>>> struct mhp_restrictions contains flags which contains additional
>>> features to be enabled by the memory hotplug (MHP_MEMBLOCK_API
>>> currently) and altmap for alternative memmap allocator.
>>>
>>> Please note that the complete altmap propagation down to vmemmap code
>>> is still not done in this patch. It will be done in the follow up to
>>> reduce the churn here.
>>>
>>> This patch shouldn't introduce any functional change.
>>
>> Is there an agreement on the interface here? Or do we want to hide almap
>> behind some more general looking interface? If the former is true, can
>> we merge it as it touches a code that might cause merge conflicts later on
>> as multiple people are working on this area.
> 
> Uhm, I think that the interface is fine for now.
> I thought about providing some callbacks to build the altmap layout, but I
> realized that it was overcomplicated and I would rather start easy.
> Maybe the naming could be changed to what David suggested, something like
> "mhp_options", which actually looks more generic and allows us to stuff more
> things into it should the need arise in the future.
> But that is something that can come afterwards I guess.

I'd vote to rename it right away, but feel free to continue how you prefer.

-- 

Thanks,

David / dhildenb

