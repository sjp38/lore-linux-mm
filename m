Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C418C10F05
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 08:49:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 237EB20855
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 08:49:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 237EB20855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B59166B0005; Thu,  4 Apr 2019 04:49:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE2BB6B0006; Thu,  4 Apr 2019 04:49:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95B666B0007; Thu,  4 Apr 2019 04:49:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7176C6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 04:49:23 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id i124so1569567qkf.14
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 01:49:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=T7ZlFQgeBQo/D9kReCYoWeH1L/Suz12Ic6hxKUb+v04=;
        b=ECG9w7UN/DH5p1IFOyqOv8UFwD7nwyOaOPo5djtWRfwHtQ6ppt04I9p6g4XxfA0OPp
         gqmLK7dLDTliKymVnGVi/+MHkl1ZuZnefns0ZxV+eOIxqLoOmpw0DJxznXWo5xrZ1apB
         eDF6RLo15FTrIFhq/oMzu2K1dpUrKNKu2Wlau45gCLX4dcbJt84wTQeHo40ZbEpEChco
         gaWsbYxclkIYFtRR+Vr0xQeHFkW0fOGqG2k+2pyj0kt0q3m1BksCLAV5QzALdP0JCs0W
         7aOt3cM6vH1XaDNFqVxcNm3GuH0L5+tfH8wgnQOYAzcngO+Nb04ZzV1lS/aH3pGDdeh3
         PsAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVNpOqetzLmLp6s3rHDDzmD/+uA6pkzKOQreaL4pVb7TMpDxYNp
	FeJccegLWmoeAtt9vyOnHaC7TmthremArJK97ai1mDcZNIObzXHXPTP21YpyB+ljc3H7W3Ndz5J
	Bl7jfWLJ9WB0I6ydvSl+Nv34goZd/ykY7MHV0k4MWK7QhAliZvfkhavW/HtlaYxC1UQ==
X-Received: by 2002:a37:aa8c:: with SMTP id t134mr4080287qke.93.1554367763222;
        Thu, 04 Apr 2019 01:49:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwl8Gp26ImFhFDRHo3jUdcR4oUJ8na18vT3/eHw4QAx/vrtbZUJsRtSBUgKH04WCpr83Yzk
X-Received: by 2002:a37:aa8c:: with SMTP id t134mr4080267qke.93.1554367762671;
        Thu, 04 Apr 2019 01:49:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554367762; cv=none;
        d=google.com; s=arc-20160816;
        b=xJZeYQlb8n/s4GhmLEGi03zz7ohkGZ5mDqi/LCLQg8SRP3Y6Kjpb32j2QhUzAdS/bX
         3bg1A+I0ynPeOMYIcYbLZ3U2iX9+14c1FJ/C+RYmcYtqF4stYydqsT5MURz4oFO96Hyc
         NY4I+dIerUqlQ4f4Xzx+qlPpvg2c2pX9n0uXfM4P9tzlQT6h8DEe0dzfDAu6xk4NoNOq
         7UuM9fjlPcK/7na9xT8depFgaDJjJlmY/33ZS+b5WFjKrqP+n7nGgsbkT0WCtTODSlS5
         N7/eZY3yGFCoFx6ObpT5y8u06I5+NJWWIu9Lqs11XZfXeUEmMbCsAYanretyFLP9MDpJ
         t9kA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=T7ZlFQgeBQo/D9kReCYoWeH1L/Suz12Ic6hxKUb+v04=;
        b=UaF9guTNryu6tnFyGJJBfekDo6FYPk5IAd96ZhWtqMbTXBucgxy59o3q5P6LEd40Xg
         sm1LFl3WsC3CV/MtS918/HeuzMY3Wq0qiPZJear5Q3Wsg/qSD+Pg1aYAhHi+Hudu43jo
         vJcA6lsJxX3aSWlaADJ3gHICU85ar/1Vrdn1LDGnOVI7+f7BtDPeDJMbvCmM6XrwIt3d
         ++nl2jImLC3MZgedptVAeHtDlJ6VCmiP8wwPtkme7nLgA45HoL+UHfzALAoe+A/Boj1G
         WERCQPBoYxAZMz9iLhvzrVpKO5quv4KcpAJWfbdYtaWRkF5npqHg9Mymgd+VvCTWsAOj
         lFGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d4si4366884qkk.210.2019.04.04.01.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 01:49:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 738E730821A5;
	Thu,  4 Apr 2019 08:49:21 +0000 (UTC)
Received: from [10.36.117.116] (ovpn-117-116.ams2.redhat.com [10.36.117.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D700298A9;
	Thu,  4 Apr 2019 08:49:17 +0000 (UTC)
Subject: Re: [PATCH 1/6] arm64/mm: Enable sysfs based memory hot add interface
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 logang@deltatee.com, pasha.tatashin@oracle.com, cai@lca.pw
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-2-git-send-email-anshuman.khandual@arm.com>
 <4b9dd2b0-3b11-608c-1a40-9a3d203dd904@redhat.com>
 <fc9dadfa-6557-ecef-f027-7f3af098b55b@arm.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <53c380bf-5896-69db-a054-eba1363fce66@redhat.com>
Date: Thu, 4 Apr 2019 10:49:17 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <fc9dadfa-6557-ecef-f027-7f3af098b55b@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 04 Apr 2019 08:49:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04.04.19 07:25, Anshuman Khandual wrote:
> 
> 
> On 04/03/2019 01:50 PM, David Hildenbrand wrote:
>> On 03.04.19 06:30, Anshuman Khandual wrote:
>>> Sysfs memory probe interface (/sys/devices/system/memory/probe) can accept
>>> starting physical address of an entire memory block to be hot added into
>>> the kernel. This is in addition to the existing ACPI based interface. This
>>> just enables it with the required config CONFIG_ARCH_MEMORY_PROBE.
>>>
>> We recently discussed that the similar interface for removal should
>> rather be moved to a debug/test module.
> 
> Can we maintain such a debug/test module mainline and enable it when required. Or
> can have both add and remove interface at /sys/kernel/debug/ just for testing
> purpose.

I assume we could put such a module into mainline. It could span up an
interface in debugfs.

-- 

Thanks,

David / dhildenb

