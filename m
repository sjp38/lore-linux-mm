Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 102D2C32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:21:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6B3E20679
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:21:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6B3E20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78E5B8E0006; Wed, 31 Jul 2019 10:21:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73E898E0001; Wed, 31 Jul 2019 10:21:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DF098E0006; Wed, 31 Jul 2019 10:21:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E00A8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:21:51 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g30so61539066qtm.17
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:21:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=0hc+kHzLlf1nEWzNhGSl5zMJyxUuQicbG1x2CFjDZyY=;
        b=VI/Hz3QMmePVJw9/VQVjD6/bZehFJvJWaR0ozzQd5LK9ZZJhGfh6si8evgZPy71JUk
         3CFnl7vTVoHl1GxYmECCOvL2ERqOEZzuFnip1PZGukGz1WojtylKjXOiC63+AIL6WoUK
         SqnySmRmVA7BoyyotR/24aW7ttp8uU0CMXCglqIGai1Gw1h+MgM6P1NKGfJT7c1vAdta
         WSL2+ukDGtePfvCyg4bXS+dk8kejMczk4kxceKWvSg5N8tzR5B88dDAaYA/z/TiNyJbm
         4evhDoaCAD3ougZJ80NhFKp0sDs+dKDKrcQ5rx5x/6L/s8SZjfhnxt14yxlkWXtVpWDM
         4pSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXlRSDJ/NwJ25/pWrdRStBg1dLDXlJyP4Wz7rmdoXBLGUEwl0CS
	9ntk80e0RLe8O9SzrzLuFNlTQjJimR+OM+PGa/FQVZMcN5GZ97SUDgo211afYwhOsT5XAEqwfdz
	KO/vJvS/SPblqhr51XE43jU25t8O6HIxSk3dT9LB6YQ5SKoxZZi+Gs5Dimme2ObP7Pw==
X-Received: by 2002:aed:3667:: with SMTP id e94mr80543272qtb.382.1564582911003;
        Wed, 31 Jul 2019 07:21:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2uQh43foUd16tpFWgEXdne5pB7pr5A4OBmuk2LDRIqyyga1tNOncZ0+usV79j5Opn1Iy9
X-Received: by 2002:aed:3667:: with SMTP id e94mr80543215qtb.382.1564582910379;
        Wed, 31 Jul 2019 07:21:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564582910; cv=none;
        d=google.com; s=arc-20160816;
        b=ZVo0ww5nJcDt/HcQBhTFCWu7yKuLPwJda1lFnPIHOjHdIOu5m2O6Jntbb8tJuThUi0
         Ij3a6T2GX7orpGObYsKrHPuXV8bDu+buRwaa+nnQFaxHFXbFL3FLD38KemPaTRnCbAxF
         Stc47pfNPddHsE4VC1QDPzsuUurynFsLLyZhX20wVefQ2CIsgZAYTnfYKu8eN20ry1P3
         Mt3ruWPwb90gA3Si4ugCyRR5fOm3Qas6BKZYuJTRfoS4Hcj2oiNv0mRZTtxFfpS4T37w
         3r99wsZ90vQnlXwT+bDdXlZkXkmHODGM/76d/d9p9timll3qzEJ9TTd01PEDbr19yx0B
         oJ5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=0hc+kHzLlf1nEWzNhGSl5zMJyxUuQicbG1x2CFjDZyY=;
        b=epj9zjPEtb6tMJ4q9qtB2bbEip+85VBA8n6s8DxJb17ogEWQgEuMKJ+tIAnZBZTUCo
         bPbcZfjQl1o5O4SHtoCxbhzD6Frye4ES5VGJRq+8rMKKhjbQTi/AQTqtJqVh+gbze0Su
         EdrRXl2C/sGj7Tzd1aLeEZKnHY1E1Nr2WqdcAD2vCFoHqZMLNkEvzCak2HT0ZoY7vPUI
         63VUjidI1DM04TvxXvLv+dCOEIaQp6drwE0DMHDmoDDOM92OnKWWxkIOek6CuVmwt3h6
         5E4+d3Va2vzva+Ue1V592567JVHYcfCjJjA7FFw9G4dGk5oW5kSmRRREliRyumd3EA2q
         3ddg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h9si19936151qke.337.2019.07.31.07.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 07:21:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8C73430C1345;
	Wed, 31 Jul 2019 14:21:49 +0000 (UTC)
Received: from [10.36.117.240] (ovpn-117-240.ams2.redhat.com [10.36.117.240])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AB92410016EA;
	Wed, 31 Jul 2019 14:21:47 +0000 (UTC)
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
 <20190731141411.GU9330@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <c92a4d6f-b0f2-e080-5157-b90ab61a8c49@redhat.com>
Date: Wed, 31 Jul 2019 16:21:46 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190731141411.GU9330@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 31 Jul 2019 14:21:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 31.07.19 16:14, Michal Hocko wrote:
> On Wed 31-07-19 15:42:53, David Hildenbrand wrote:
>> On 31.07.19 15:25, Michal Hocko wrote:
> [...]
>>> I know we have documented this as an ABI and it is really _sad_ that
>>> this ABI didn't get through normal scrutiny any user visible interface
>>> should go through but these are sins of the past...
>>
>> A quick google search indicates that
>>
>> Kata containers queries the block size:
>> https://github.com/kata-containers/runtime/issues/796
>>
>> Powerpc userspace queries it:
>> https://groups.google.com/forum/#!msg/powerpc-utils-devel/dKjZCqpTxus/AwkstV2ABwAJ
>>
>> I can imagine that ppc dynamic memory onlines only pieces of added
>> memory - DIMMs AFAIK (haven't looked at the details).
>>
>> There might be more users.
> 
> Thanks! I suspect most of them are just using the information because
> they do not have anything better.

powerpc-utils actually seem to use the fine-grained API to dynamically
manage memory assignment to the VM.

> 
> Thinking about it some more, I believe that we can reasonably provide
> both APIs controlable by a command line parameter for backwards
> compatibility. It is the hotplug code to control sysfs APIs.  E.g.
> create one sysfs entry per add_memory_resource for the new semantic.

Yeah, but the real question is: who needs it. I can only think about
some DIMM scenarios (some, not all). I would be interested in more use
cases. Of course, to provide and maintain two APIs we need a good reason.

(one sysfs per add_memory_resource() won't cover all DIMMs completely as
far as I remember - I might be wrong, I remember there could be a
sequence of add_memory(). Also, some DIMMs might actually overlap with
memory indicated during boot - complicated stuff)

> 
> It is some time since I've checked the ACPI side of the matter but that
> code shouldn't really depend on a particular size of the memblock
> either when trigerring udev events. I might be wrong here of course.

It only has to respect the alignment/size restriction when calling
add_memory() right now. That would map to a "minimum block size"

-- 

Thanks,

David / dhildenb

