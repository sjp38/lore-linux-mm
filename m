Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8117C10F0B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 08:39:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64F7C2084C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 08:39:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64F7C2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F17DC6B026F; Tue,  2 Apr 2019 04:39:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9F8F6B0270; Tue,  2 Apr 2019 04:39:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1B7C6B0271; Tue,  2 Apr 2019 04:39:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id AAA926B026F
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 04:39:27 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c67so10965657qkg.5
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 01:39:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=GpucqIHBejI4Q28K1QezMLKjaRPElwLRVEfM2B/cIl8=;
        b=FRly0TTqjIUM93Lv0OSHCovy01QAb6sKXh2aOHA+pWRVuTe+xhqkMna1jwMvpXbp0x
         j1JSnW5ZJbFAvpYtFNx07SgWZp1toFazSTZEXb5XYsHCMsh21vPwHJLTK7BFmxvJTFs5
         3HtR+jYw2KoILlwWoikNtpQ1jHjo1FNtxp0B2sNbiqzWwj1VNE0dIyDdbCFWa+eGe8iK
         dM34YmxkXJjqADPj+ow7KPaqyAUSY0FIWV82ayay4gTI45daoeLlWZ6iJMm2dKKEOKcF
         t07cKVsa8sQmB8CDRAApsFatUt8SaIefHqmnOtibKzrXSRJg3Fo8d8n4uMbDmeUwGBXu
         AwZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXWl9w0zW0e0frIC+hIMPIJEwzB3oTIoCl+b1/+fcKn9S6Q+PEF
	jeIUoqfmCurNW4YyI/kdrTr/2lmZ3RIWBU4DVTZoweTUgIK/dxJjsHqikO6PML5BTJ8UdfGfeSb
	N9VsZRTG7GTxyMZ06FIn+DP6AL1nWCY3imRnFLdTA0gktEZ8j2dgWtd83c/TlaCPVHw==
X-Received: by 2002:ac8:26e7:: with SMTP id 36mr58419803qtp.37.1554194367417;
        Tue, 02 Apr 2019 01:39:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWCxeV/zNLwESAW7m5+FCaP0yxgIxtTlhvdcw3rEzuBUAikx8EIbYKPJdwBrVKlzWkuQS9
X-Received: by 2002:ac8:26e7:: with SMTP id 36mr58419751qtp.37.1554194366524;
        Tue, 02 Apr 2019 01:39:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554194366; cv=none;
        d=google.com; s=arc-20160816;
        b=VkxxtuHbYGRq6LlQTYo1Ywzf0ROVLFaeEvgliivsSGUKayoHtl43Oer1x8PAwhSqdd
         arm68sXFM8jOiC7aIG8zOqP4+MtYuIl8CpTZYXaZ0ggQKmnIymm9swoX0nXKXhhqhE4W
         HfEDKFWxVEsul9Nq1sKm4HneDG0Zvp3paKZzdpFhdQjglVj+HGNYHX/lk6QBm8MRB09a
         AryjFkO4kIvVjapAL5s0D+jbNFda0U+GGpSV+aUpRYhm5nARmKTffVJfkdmaDuu+rmr5
         hkHW+k5+FoVE5b6OpXwjy7QtvP8TP26lvYxcTEvvyRiAchtE4xxyN8L9eqGD6/F0vZGq
         UDZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=GpucqIHBejI4Q28K1QezMLKjaRPElwLRVEfM2B/cIl8=;
        b=Z4P5sV6YEAF5ES6wDwIke0rJTmPalRTn1PFKQ/irfK/9k9uRmTbAyA7Wivud3sM1eP
         PxKgFC4Zq17CQZB3o5oPFfZdl9nJ4zqYg6hSh0UcXtq6C7AW6G7PEMix0DBJChuQIp6l
         8HWU0JLKeExNF7MUPDvZI7OVZ9JVJFQ+kKd79aQx7qGvAQ+vwhx45AB25ulSiP1zeah9
         dut5Tn7n3n+WHDNPqvGhKamVxDSSceUo4WDSozRKzNe9WBAmLUnmgv3c+zcig+QpLrMF
         FB4CfEGC+d3PO0MSE1W6qcCKMyEJ6DdaA4C/vgQ+GRFJ5tq4WaHN2v5dRPtMeBNhDvWs
         ygpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x14si122861qtb.125.2019.04.02.01.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 01:39:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5B6BB81250;
	Tue,  2 Apr 2019 08:39:25 +0000 (UTC)
Received: from [10.36.117.141] (ovpn-117-141.ams2.redhat.com [10.36.117.141])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9AFD8173B9;
	Tue,  2 Apr 2019 08:39:23 +0000 (UTC)
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
To: Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@kernel.org>
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
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <40a84fa8-c1b0-185e-8c6d-230a381099a2@redhat.com>
Date: Tue, 2 Apr 2019 10:39:22 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 02 Apr 2019 08:39:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02.04.19 10:28, Oscar Salvador wrote:
> On Mon, Apr 01, 2019 at 01:53:06PM +0200, Michal Hocko wrote:
>> On Mon 01-04-19 09:59:36, Oscar Salvador wrote:
>>> On Fri, Mar 29, 2019 at 02:42:43PM +0100, Michal Hocko wrote:
>>>> Having a larger contiguous area is definitely nice to have but you also
>>>> have to consider the other side of the thing. If we have a movable
>>>> memblock with unmovable memory then we are breaking the movable
>>>> property. So there should be some flexibility for caller to tell whether
>>>> to allocate on per device or per memblock. Or we need something to move
>>>> memmaps during the hotremove.
>>>
>>> By movable memblock you mean a memblock whose pages can be migrated over when
>>> this memblock is offlined, right?
>>
>> I am mostly thinking about movable_node kernel parameter which makes
>> newly hotpluged memory go into ZONE_MOVABLE and people do use that to
>> make sure such a memory can be later hotremoved.
> 
> Uhm, I might be missing your point, but hot-added memory that makes use of
> vmemmap pages can be hot-removed as any other memory.
> 
> Vmemmap pages do not account as unmovable memory, they just stick around
> until all sections they referred to have been removed, and then, we proceed
> with removing them.
> So, to put it in another way: vmemmap pages are left in the system until the
> whole memory device (DIMM, virt mem-device or whatever) is completely
> hot-removed.

Indeed, separate memblocks can be offlined, but vmemmap is removed along
with remove_memory().

-- 

Thanks,

David / dhildenb

