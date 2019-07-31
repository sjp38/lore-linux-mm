Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F1D9C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:23:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4E14208E3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:23:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4E14208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EE248E0005; Wed, 31 Jul 2019 10:23:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 677B98E0001; Wed, 31 Jul 2019 10:23:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5403F8E0005; Wed, 31 Jul 2019 10:23:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 319AC8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:23:50 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id g30so61544986qtm.17
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:23:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=ySGHMBNSa2vNjiA17TlvKKgGaFfT4Jxyr00x1x2lUzw=;
        b=rum7/PueywgDDDOf8PHc+prA1jhDLOvZtNAWYc3Oe/PAtfE1ZFL2coQTm8uEGUKrPT
         JPr2MeKIOPgK2UABNj0O6YqRA1PJowBRDf1Rk1o1BhnF6z+9vmNR513CdT972dJ8/Xh1
         eeJI3N5Mq6eLfGurYNWS29Fne4+yX8wZJvNiuxWPrBw9C3GY8jKA//t862SafN2WwRcY
         p1Rc0G6CMvkQiAXon8PjOaz7zuFBcj9JlilsLxhrbgL/NagGRL2mqWBRP0m793zlfORe
         yN1N3Pf9XxYipxnXXunmQD9iXfWY1r9XXxA2IP+gQogoN71C0Fe/oLHAG/SdZY7nja0q
         9N/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWdrJUj0Lnd//H1UWyYSXEx2dO6VitIjv/JHMEOkgiiXAOnXjO1
	fuX2wi39vWNfr1gk2iIcWWhc/0U7CePe9fTmMuxRPX3GrO1PEK4hbIASue0aafgZY6uuDYgvpXE
	o17hp+nt/dleQ5+AqVPHQF3z5F1ha35UGSWE9XJZcp4t25vj9oa87GGCc2lm6/LIk4g==
X-Received: by 2002:aed:36c5:: with SMTP id f63mr1367135qtb.239.1564583029971;
        Wed, 31 Jul 2019 07:23:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzF8qmIy5JxD4MJ2744KSnRoQTVGd+AJu8nYwPmICnRdx4aE2ntn9/PDUKCkebWy0WrBdjy
X-Received: by 2002:aed:36c5:: with SMTP id f63mr1367082qtb.239.1564583029464;
        Wed, 31 Jul 2019 07:23:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564583029; cv=none;
        d=google.com; s=arc-20160816;
        b=YI7NQkCv3zT0BaIi8t/XcPPqGobcLtHdaPVFVlQ/vDFu89TgHFMtupulTt/xUVOrME
         WYU7WbEvi+/gDMN1+oH8ZegfAgUpebEG3FDBD5CHGlwfIjly860CQrkVBHhgw8EN+oFM
         g30n+fHYa9u2QBrUg/fTLugXerlMn3+QNSzFvvq6MaJDdH+7/85LM9mDYog+E3JkVPGP
         1NOUwV+chHnYW5+N+6K4P12Kk9IYdaavaVp+ld9w3aOzKP25mPfAX+/wjsBi+WywOJsU
         JhlSgGO57PmZFtsBL6pAMDI0g9Oany5tJQY4+9r8OOGV6WEX21jVlP59fITPJjZUrkBX
         0aLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=ySGHMBNSa2vNjiA17TlvKKgGaFfT4Jxyr00x1x2lUzw=;
        b=rlHelXIHSGKo3I8fNX/qbT5CAvJz6mkawbzGujVwvIeyy/5pu9hSpS8O03htGqCyso
         bwudUh960DVxvsJohQr2R+PS+LBSryUV3RID8hLXnmjo3GSMZs4DXxLE4wiwxMX4Baok
         HTIq9SfU+Xn+cceGllWW+IOU6mtNs9bQyH7iHcgfx/jCA/vrERjg3ds5epuBuimVLfk5
         iInIRKJM9aIOqjm+FcVvICdWErfm8wgkZ8So5IsXhhhkXY4eRwcumjDruyonBi7Howx/
         4lRroSaqUK6spNvus7CNGJvIyXvzFWC7976RM3EfaRKL/8OB1Vnf57tC0KKleFZWJ7Rt
         ZFhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v63si39312563qkc.17.2019.07.31.07.23.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 07:23:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 83ECB3091D55;
	Wed, 31 Jul 2019 14:23:48 +0000 (UTC)
Received: from [10.36.117.240] (ovpn-117-240.ams2.redhat.com [10.36.117.240])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B447A5D9CA;
	Wed, 31 Jul 2019 14:23:46 +0000 (UTC)
Subject: Re: [PATCH v1] drivers/base/memory.c: Don't store end_section_nr in
 memory blocks
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>
References: <20190731122213.13392-1-david@redhat.com>
 <20190731124356.GL9330@dhcp22.suse.cz>
 <f0894c30-105a-2241-a505-7436bc15b864@redhat.com>
 <20190731132534.GQ9330@dhcp22.suse.cz>
 <58bd9479-051b-a13b-b6d0-c93aac2ed1b3@redhat.com>
 <92a8ba85-b913-177c-66a2-d86074e54700@redhat.com>
 <20190731141545.GV9330@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <21d48bda-dfc8-1c7e-6b3a-81a33c8ea4ac@redhat.com>
Date: Wed, 31 Jul 2019 16:23:45 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190731141545.GV9330@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 31 Jul 2019 14:23:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 31.07.19 16:15, Michal Hocko wrote:
> On Wed 31-07-19 16:04:10, David Hildenbrand wrote:
>> On 31.07.19 15:42, David Hildenbrand wrote:
> [...]
>>> Powerpc userspace queries it:
>>> https://groups.google.com/forum/#!msg/powerpc-utils-devel/dKjZCqpTxus/AwkstV2ABwAJ
>>
>> FWIW, powerpc-utils also uses the "removable" property - which means
>> we're also stuck with that unfortunately. :(
> 
> Yeah, I am aware of that and I strongly suspect this is actually in use
> because it is terribly unreliable for any non-idle system. There is
> simply no way to find out whether something is offlinable than to try
> it.

According to the introducing commit "removable" is only used to not even
try some memory blocks (IOW to save cpu cycles) - not treated as a
guaranteed (which is correct).

-- 

Thanks,

David / dhildenb

