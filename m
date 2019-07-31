Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87A73C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:04:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36691206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:04:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36691206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB7CD8E0003; Wed, 31 Jul 2019 10:04:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B68338E0001; Wed, 31 Jul 2019 10:04:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A30EC8E0003; Wed, 31 Jul 2019 10:04:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 837C98E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:04:15 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x10so61494519qti.11
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:04:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=bH3rSzdHLrvgRRRxuabSKLOoxEKaafyELcVlVLC7BWg=;
        b=ci5JXpMT52AevdOZUXeqD3wfc0eGJCrfU80zYoiAdSSUpTdqa0zoNG30zb7cxCYwZl
         girvlrbTt4cWIzpLDsTnb27JE1kngKbxgBw6K1fir/MLgE5mAaf5beX8u9ECHuqG9tbz
         W6cxJNB19kwOZL25DdNhqs94L9bD+58FmgSV+wHfye+Cm65QZAxRqS6qaRqH5lLBVe1S
         vRTnMpdYsdja5mjx5+AbwzONWlw9MMtpyyjTPNPC4IzblHTb1toVJQbdkaVykyHcndq7
         NkoCFbsPOoNjIwjGH2dHeOKd+r4g3lpGxrTFc8LNKW6T5f/FxqppwdlnW9K3hMN3z0yK
         PR1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVBQykxTX2Y6Dy9b+gj/2vMzEReCDaU1abzQd6ApA5fdFI5Vtwi
	Cay2rPcgNGbTA58t6z1kcja5Okpw1rOkRJoul41K42yUygYt7iPnRkZopI8tFwwo4ylxO4KT68X
	6A8JxesKn4YiCrUApuGT5R6SS2cDC5bKYrQ6eVEijfSU+GHQzaI0GCnRuEKZem7m5Qg==
X-Received: by 2002:aed:3fb0:: with SMTP id s45mr87396493qth.136.1564581855293;
        Wed, 31 Jul 2019 07:04:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyI3FrE/AFkLAgcN4pQT7keKgz/6140iEcgDcUZcwGggiC0NryeB9eOJ/hvOkal+POiKnjn
X-Received: by 2002:aed:3fb0:: with SMTP id s45mr87396428qth.136.1564581854565;
        Wed, 31 Jul 2019 07:04:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564581854; cv=none;
        d=google.com; s=arc-20160816;
        b=AzY8EAy+uCZtRlCS1tQjsSr20GHF/AJMn52ukOmuCGIZjeMsA8YZuV2YaJEt31zqKQ
         XwwWsS1Xn6dapZFzzOmhtbngueXv7KbRl8JPd1qYgoY+HI82E1YIgRihQyGzSJibZFfF
         D4HXfmv9yZn5qgztEC0p+PA3HqX9OGZbxSkw2gVCqV5zr4w29ZNFxHMj8yBV/YWssv6e
         dkwQEyrJQOiqvRgJ3JcQ+frxipPuDYxTt5S9BTrFFTctb2pm8xSJCfZGiWecKT7a7aKh
         BQWlwyLJBAhU7U24X0oFmyp0Ri3JGeCB2gAhAe3yrY0Ic0DrjphcQdtzJ4a+73QaYt93
         YBCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp
         :references:cc:to:from:subject;
        bh=bH3rSzdHLrvgRRRxuabSKLOoxEKaafyELcVlVLC7BWg=;
        b=Dzhc2/+izzXLS+rJQ6/DFQRmXQfvc61tsoU+JRntK0gSplSWbQUbxFEA7e/fKTwnOO
         slL9dUXPMOYO9HixSxV16o514sZYvqL0SyMlo/MS4hl0lWnVpTnunvjw6W1D8Tks506l
         b9fZiTVLsVh4Dmb3s9DcOzZfOeH+KayRV0blfKjD0Gj7jTmeYIR/2qjvyp5LGBtbowmS
         v47EChg0vVInMqduxXJR7ALiD0dQomfyEXMvP/7Fyex8yAhhsVRF4dksT0TlC5KlFzmJ
         vnwg+a/fRtXfdHEORC7L6xkjpToMMi5VCNKFbqmoOPuZ90o6m0MGveucWC7LHiYkR4K3
         PQ/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t54si40114283qth.352.2019.07.31.07.04.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 07:04:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7FE833179156;
	Wed, 31 Jul 2019 14:04:13 +0000 (UTC)
Received: from [10.36.117.240] (ovpn-117-240.ams2.redhat.com [10.36.117.240])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A89141001938;
	Wed, 31 Jul 2019 14:04:11 +0000 (UTC)
Subject: Re: [PATCH v1] drivers/base/memory.c: Don't store end_section_nr in
 memory blocks
From: David Hildenbrand <david@redhat.com>
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
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <92a8ba85-b913-177c-66a2-d86074e54700@redhat.com>
Date: Wed, 31 Jul 2019 16:04:10 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <58bd9479-051b-a13b-b6d0-c93aac2ed1b3@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 31 Jul 2019 14:04:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 31.07.19 15:42, David Hildenbrand wrote:
> On 31.07.19 15:25, Michal Hocko wrote:
>> On Wed 31-07-19 15:12:12, David Hildenbrand wrote:
>>> On 31.07.19 14:43, Michal Hocko wrote:
>>>> On Wed 31-07-19 14:22:13, David Hildenbrand wrote:
>>>>> Each memory block spans the same amount of sections/pages/bytes. The size
>>>>> is determined before the first memory block is created. No need to store
>>>>> what we can easily calculate - and the calculations even look simpler now.
>>>>
>>>> While this cleanup helps a bit, I am not sure this is really worth
>>>> bothering. I guess we can agree when I say that the memblock interface
>>>> is suboptimal (to put it mildly).  Shouldn't we strive for making it
>>>> a real hotplug API in the future? What do I mean by that? Why should
>>>> be any memblock fixed in size? Shouldn't we have use hotplugable units
>>>> instead (aka pfn range that userspace can work with sensibly)? Do we
>>>> know of any existing userspace that would depend on the current single
>>>> section res. 2GB sized memblocks?
>>>
>>> Short story: It is already ABI (e.g.,
>>> /sys/devices/system/memory/block_size_bytes) - around since 2005 (!) -
>>> since we had memory block devices.
>>>
>>> I suspect that it is mainly manually used. But I might be wrong.
>>
>> Any pointer to the real userspace depending on it? Most usecases I am
>> aware of rely on udev events and either onlining or offlining the memory
>> in the handler.
> 
> Yes, that's also what I know - onlining and triggering kexec().
> 
> On s390x, admins online sub-increments to selectively add memory to a VM
> - but we could still emulate that by adding memory for that use case in
> the kernel in the current granularity. See
> 
> https://books.google.de/books?id=afq4CgAAQBAJ&pg=PA117&lpg=PA117&dq=/sys/devices/system/memory/block_size_bytes&source=bl&ots=iYk_vW5O4G&sig=ACfU3U0s-O-SOVaQO-7HpKO5Hj866w9Pxw&hl=de&sa=X&ved=2ahUKEwjOjPqIot_jAhVPfZoKHcxpAqcQ6AEwB3oECAgQAQ#v=onepage&q=%2Fsys%2Fdevices%2Fsystem%2Fmemory%2Fblock_size_bytes&f=false
> 
>>
>> I know we have documented this as an ABI and it is really _sad_ that
>> this ABI didn't get through normal scrutiny any user visible interface
>> should go through but these are sins of the past...
> 
> A quick google search indicates that
> 
> Kata containers queries the block size:
> https://github.com/kata-containers/runtime/issues/796
> 
> Powerpc userspace queries it:
> https://groups.google.com/forum/#!msg/powerpc-utils-devel/dKjZCqpTxus/AwkstV2ABwAJ

FWIW, powerpc-utils also uses the "removable" property - which means
we're also stuck with that unfortunately. :(

-- 

Thanks,

David / dhildenb

