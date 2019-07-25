Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95F0AC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:23:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A4E5218EA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:23:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A4E5218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 003C76B029A; Thu, 25 Jul 2019 05:23:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF6F16B029B; Thu, 25 Jul 2019 05:23:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D97206B029C; Thu, 25 Jul 2019 05:23:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B8C4C6B029A
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:23:39 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x10so43896862qti.11
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:23:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=/YzmhmlMrSxdl8UFYy438P48/OxEeVFVrnYS8vMqqD8=;
        b=IhnFkjZgCfJ+jGFViOjZvzkaULw6So5oFCKzos/vtY+1kar3doNA2zsPtxv6oqN4Ug
         bdv+o9qEr71YFgdLfm0Uf6y9Z3Jg8g/OjwjeErEcvKpDQ4p5d3slzOhjPyIt0QIfa7Rp
         ZOtueK/OT3bLY17EfH8doOKBEioIuPCN0ah3DotBFKiFUXyJjJYK1rb4rIBYsMYwbb/v
         Hm4AG6sRxMltNQ2Z6JhDRhwP/j4tCKydhTpFUpquU0divTXkrYv3Bb4DNvApmqY9iFEK
         ha1t8Rhacyp6VGD7KMUHXsqlYKb2DNx1mHF0G3+9BBHwxJtlJmmmDepFvOuqjp+HG3ug
         1TBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV5ApoZXrN8dEZ/xql7pyzA+fd5sdMRan94GHQl6Jj1cPdLM5Lt
	FlAGpOMhPcJTr7H2J2MPqxriVCc89aWkeJV8lwKRSq0GhCXHzV4q0++PvsqD6IAaqHsK3L2xNXu
	+EnwBQTPpONtC6aa1gnp4OkFaIsoB9FHlq0x+q8vjsNuJrcP/GiX8lwCk+cZgBdtD1w==
X-Received: by 2002:ac8:394b:: with SMTP id t11mr60246651qtb.286.1564046619527;
        Thu, 25 Jul 2019 02:23:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSRamzKu/X1Lqq61QVbbkKhib7/Es34PfZ8y1ktES5J25ulxKuSsSklSGz9bZ41MdVzqHG
X-Received: by 2002:ac8:394b:: with SMTP id t11mr60246635qtb.286.1564046619061;
        Thu, 25 Jul 2019 02:23:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564046619; cv=none;
        d=google.com; s=arc-20160816;
        b=t/nnKIsbEjc9sZ1n5+0yKnF9pU6w94hkhyONwaY29t4T/b5xW+LRxjpjI0Rc6Hlzqm
         +NWdfuD5t4otyPQhQX8EPrAqo6bd3ZoL+qChNyMCiGijF0DYeaADvh/+o/nTPMw7xtKK
         pBpY3pzSzJTZpuhRiSPUn6bmHqhVc7OpCZiWjAJ4FpP0yNBEX6pcLz1xvo3PPuDboylU
         n1gHeVzFuZvBooVOP8EgB8N8DngE6iCLFMfRN0GtcQNa/Oflj+SkpDXQJIslfWOHpAQj
         HLAhRvhQmopyW9OASrtgOX2b2mmjDhlJ9EuAJb0edOSBpeqYecVsUARW/C4PQ8K/X0H3
         qbXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=/YzmhmlMrSxdl8UFYy438P48/OxEeVFVrnYS8vMqqD8=;
        b=nG41PG2nnhoYZ90w2CfkTjZn0gmte28liifqX0jncbDdgqj3KxXZIy4gaJtpvGSBVU
         moCP4fBB4qHjr6d7yTMl6QDGPZUZRmM/28a/c63x5yq3tvwVHF3VXp+nujoeVibfUxyj
         kOUeKCu6EpK4db+7SJjC6kBSYtORPxt2AKDEveBAPbtqzUFJzd3poJA9sGXvEsz4O6Lx
         Kl7HbGIOogp4ny4sy+/rjiX/qGYArtP2Gfeg5SuBYk6/mAPz4JQgRpWJD420vYQpbwW6
         0Y0qiLVSVTsCckEh76ngl2aK96YspGkr60auYkjkQfLiYL7NaJnxBxb5WxCHsmckoef3
         L2QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f54si32472813qtk.348.2019.07.25.02.23.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 02:23:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 527C27FDCD;
	Thu, 25 Jul 2019 09:23:38 +0000 (UTC)
Received: from [10.36.117.212] (ovpn-117-212.ams2.redhat.com [10.36.117.212])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A5338546E0;
	Thu, 25 Jul 2019 09:23:36 +0000 (UTC)
Subject: Re: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in
 acpi_scan_init()
To: "Rafael J. Wysocki" <rafael@kernel.org>,
 Oscar Salvador <osalvador@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
References: <20190724143017.12841-1-david@redhat.com>
 <20190725091625.GA15848@linux>
 <CAJZ5v0iBntT1c7gKkXG-RJpabZne2n-Afq40GKeA6-tUViVZuQ@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <ad2d85a0-e7a5-1d76-3984-fa4972853496@redhat.com>
Date: Thu, 25 Jul 2019 11:23:35 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <CAJZ5v0iBntT1c7gKkXG-RJpabZne2n-Afq40GKeA6-tUViVZuQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 25 Jul 2019 09:23:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.07.19 11:22, Rafael J. Wysocki wrote:
> On Thu, Jul 25, 2019 at 11:18 AM Oscar Salvador <osalvador@suse.de> wrote:
>>
>> On Wed, Jul 24, 2019 at 04:30:17PM +0200, David Hildenbrand wrote:
>>> We end up calling __add_memory() without the device hotplug lock held.
>>> (I used a local patch to assert in __add_memory() that the
>>>  device_hotplug_lock is held - I might upstream that as well soon)
>>>
>>> [   26.771684]        create_memory_block_devices+0xa4/0x140
>>> [   26.772952]        add_memory_resource+0xde/0x200
>>> [   26.773987]        __add_memory+0x6e/0xa0
>>> [   26.775161]        acpi_memory_device_add+0x149/0x2b0
>>> [   26.776263]        acpi_bus_attach+0xf1/0x1f0
>>> [   26.777247]        acpi_bus_attach+0x66/0x1f0
>>> [   26.778268]        acpi_bus_attach+0x66/0x1f0
>>> [   26.779073]        acpi_bus_attach+0x66/0x1f0
>>> [   26.780143]        acpi_bus_scan+0x3e/0x90
>>> [   26.780844]        acpi_scan_init+0x109/0x257
>>> [   26.781638]        acpi_init+0x2ab/0x30d
>>> [   26.782248]        do_one_initcall+0x58/0x2cf
>>> [   26.783181]        kernel_init_freeable+0x1bd/0x247
>>> [   26.784345]        kernel_init+0x5/0xf1
>>> [   26.785314]        ret_from_fork+0x3a/0x50
>>>
>>> So perform the locking just like in acpi_device_hotplug().
>>>
>>> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
>>> Cc: Len Brown <lenb@kernel.org
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Oscar Salvador <osalvador@suse.de>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Signed-off-by: David Hildenbrand <david@redhat.com>
>>
>> Given that that call comes from a __init function, so while booting, I wonder
>> how bad it is.
> 
> Yes, it probably does not matter.

It can at least confuse lockdep, but I agree that this is not stable
material.

> 
>> Anyway, let us be consistent:
> 
> Right.
> 


-- 

Thanks,

David / dhildenb

