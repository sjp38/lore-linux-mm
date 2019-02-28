Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8725DC10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 07:38:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EBB4205C9
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 07:38:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EBB4205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC0518E0003; Thu, 28 Feb 2019 02:38:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6E548E0001; Thu, 28 Feb 2019 02:38:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B385E8E0003; Thu, 28 Feb 2019 02:38:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 862C58E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 02:38:38 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id z198so15364148qkb.15
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 23:38:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=R0jQNkuhw/197OCv08iNHyM4AFPEcDeLOoP9zLE22w0=;
        b=ndeCbX/P9Zc31Qx6sXWWXU3LUHTCo5woKg/GESatAqNVDIin/3WqO/TjNFQTJPAbKi
         47FFn6x0CqkUW7AOnPgmxxpdMW4/yewnSnkHAYcqiYIQ2X+50IzxVlAtVi76UcxbYwK5
         roQVYMdThs0DIcwGYIn71+Yzm+6vByzK4nNotIPqlgCM48J5ZtplrpL9lVy89yZrzhLs
         ByTh4JnVGAHYyxICyi9QJ7UxVlgkcf16BiBLsLZMBE6M/5mDWNAODeeN3D3BvfxleU5K
         dS95LKF83M94moaeyOtH3nbmnj0SRN1Tf6JWzKDi9oho63dYrHcZEuyK+CDeX0F/lXKH
         jzXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXwV92NWxht8bhVCT1L/VI+zeoOXAVVnvsuMoW8Xa+72su20n9u
	N36cWqts+umKFrYw0kNmwMNXC+wxNrYf8ZNPj8KmWMSs82faXyGU4mmhS00xNXp7fU/7drZhjMv
	hDXdiWJZ2TiHyrcOL+yfoHfAo+74fd7lzoLKFMxxLyQNhK/IwiDZtt6kN9pYuoxQZNA==
X-Received: by 2002:aed:2515:: with SMTP id v21mr5067785qtc.191.1551339518269;
        Wed, 27 Feb 2019 23:38:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia872sZUMgehD2GPiyYvafR4R1iZzGiKze+oxFJqecZtXpRWIHZk42+kLn5nEaialc+SE2p
X-Received: by 2002:aed:2515:: with SMTP id v21mr5067748qtc.191.1551339517394;
        Wed, 27 Feb 2019 23:38:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551339517; cv=none;
        d=google.com; s=arc-20160816;
        b=cg4TS9gEqVCxGdrdK0Djnkl6Twg3n5lx20/8DUxMJBnww5t/N09zbOCIRopndJ4eXa
         hBxwWIq65Np12nZpnc5nrqxwIvK6ouuMmOk06+g5yb4qULzVfIC+LA3z1qdLcHosapl4
         eLK8OO2nZHPDt6VxKwkJjQpWrIWJA++5pJ3zR/iaitZvQVGOox9/ASrJQ35SXTz+sRXt
         oFmIm96mrAriDaKGLZLFzpcXFJg+EtJawfqddnN3M4FL7z36ok2be+iTnxyh4glfSID3
         tvDPUOHKEUXgn+ZL3W2C8ELkNvOMbrzmcNMUPmrRlEHdWwIsN7ChiF/wSDiQD5FUX1tS
         wKLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=R0jQNkuhw/197OCv08iNHyM4AFPEcDeLOoP9zLE22w0=;
        b=YSL1q1p5WDZsDVboGxMMv/HXD0XYz6JwgD2ATmfR9RDa+RJ/uu4kx2HTAx/LS5XRck
         ptHq8lTgbxGHK4Ewm2bF3ihilaLE+hxOQcKOePJv8DPHWdS9aZxlj+CIqiYQm6u4nV5o
         Tinl3vBdBf9XZfPfCK++UaBUWsD7dwBdBeaEsD3TzhUJAr+cbuqLIdDCQt6N8EwbREg+
         2ahtVvdk3n6yI5jMqrfOrZ5TAyzBHHOfKbocGyK4+kYKhQOepB5LVNRwABscsYkDGS5g
         63GWM5bgb7tPYG339tGak3K/lbWULgtlMS2gcaYKqciUMd1E3e5VeEjW0yrumQSSRRV0
         7Y4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x69si3136821qka.208.2019.02.27.23.38.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 23:38:37 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 693E6C067C36;
	Thu, 28 Feb 2019 07:38:36 +0000 (UTC)
Received: from [10.36.116.113] (ovpn-116-113.ams2.redhat.com [10.36.116.113])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 386EF619D5;
	Thu, 28 Feb 2019 07:38:35 +0000 (UTC)
Subject: Re: [RFC PATCH] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
To: Mike Kravetz <mike.kravetz@oracle.com>, Oscar Salvador
 <osalvador@suse.de>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mhocko@suse.com
References: <20190221094212.16906-1-osalvador@suse.de>
 <20190227215109.cpiaheyqs2qdbl7p@d104.suse.de>
 <201cc8d8-953f-f198-bbfe-96470136db68@oracle.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <bb71b68e-dc1b-a4d3-d842-b311535b92a8@redhat.com>
Date: Thu, 28 Feb 2019 08:38:34 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <201cc8d8-953f-f198-bbfe-96470136db68@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 28 Feb 2019 07:38:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 27.02.19 23:00, Mike Kravetz wrote:
> On 2/27/19 1:51 PM, Oscar Salvador wrote:
>> On Thu, Feb 21, 2019 at 10:42:12AM +0100, Oscar Salvador wrote:
>>> [1] https://lore.kernel.org/patchwork/patch/998796/
>>>
>>> Signed-off-by: Oscar Salvador <osalvador@suse.de>
>>
>> Any further comments on this?
>> I do have a "concern" I would like to sort out before dropping the RFC:
>>
>> It is the fact that unless we have spare gigantic pages in other notes, the
>> offlining operation will loop forever (until the customer cancels the operation).
>> While I do not really like that, I do think that memory offlining should be done
>> with some sanity, and the administrator should know in advance if the system is going
>> to be able to keep up with the memory pressure, aka: make sure we got what we need in
>> order to make the offlining operation to succeed.
>> That translates to be sure that we have spare gigantic pages and other nodes
>> can take them.
>>
>> Given said that, another thing I thought about is that we could check if we have
>> spare gigantic pages at has_unmovable_pages() time.
>> Something like checking "h->free_huge_pages - h->resv_huge_pages > 0", and if it
>> turns out that we do not have gigantic pages anywhere, just return as we have
>> non-movable pages.
> 
> Of course, that check would be racy.  Even if there is an available gigantic
> page at has_unmovable_pages() time there is no guarantee it will be there when
> we want to allocate/use it.  But, you would at least catch 'most' cases of
> looping forever.
> 
>> But I would rather not convulate has_unmovable_pages() with such checks and "trust"
>> the administrator.

I think we have the exact same issue already with huge/ordinary pages if
we are low on memory. We could loop forever.

In the long run, we should properly detect such issues and abort instead
of looping forever I guess. But as we all know, error handling in the
whole offlining part is still far away from being perfect ...

-- 

Thanks,

David / dhildenb

