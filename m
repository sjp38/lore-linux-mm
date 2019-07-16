Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16C77C76188
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 11:09:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2FEF2145D
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 11:09:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2FEF2145D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52D996B0005; Tue, 16 Jul 2019 07:09:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5033E6B0006; Tue, 16 Jul 2019 07:09:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CC0F8E0001; Tue, 16 Jul 2019 07:09:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4AB6B0005
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 07:09:15 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id k13so16557713qkj.4
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 04:09:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=/4lfnS4XTqSDOECN3JNw7gRL6dyqLEsf0JaSTFFtIAA=;
        b=KVa/3uomUlBiG1T65jDAU7xH3F7n7AI1HLPRm6MdS3iQqn1u3Eee1Sr2zg5i4YVS8t
         YnE7zdNjO+THsUsVQBFk3VtwkoaEIozyigGqEvvjDh69ceO8pEhoMARt+UgdtiAz3XvN
         DVsEacg9A687R+tsOyIODMG5xWTYuoqFtwjpwSSJL2jbFir+/Fn2XUy7IlmOFKTamVvf
         iGWC4v5NpRE+hGwNEOVcDxv0/go7yD7Pci1oO+ShwfA7yhyzD8modlWWSfD8tnHa91cX
         awKtKevuDshGhDHJG1q+Y1koFn5qayLkvlOjEv7Rr8pgE+DJBDTGfrIlTLWQwdLAocE/
         hufA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWrJ3SE0B+3+8toqvITNq1ZCDaBtMGp0HtaSVZCIOq6nVKmIdB4
	vL0LCTqQRqK8rCf/7CgQ+2+DMlemSHI+UbY68IXn5GTYbr1NsVkrwU0T3BEe27/oimnRMZuPsgq
	1v+JNJ9RCIpTTxdFliPvmJ3OQy3roHqtH4j+X/5vTPSxEGTdl7rjoj8xnQbO/nvUT3Q==
X-Received: by 2002:a0c:b90a:: with SMTP id u10mr23514589qvf.201.1563275354900;
        Tue, 16 Jul 2019 04:09:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+el3b1jGZ0ybf3lKOAah2vFZlIU+iX6Me5L+5Z/OMypoW/b8fz7R+gIIL7GfLVIw0fCJ5
X-Received: by 2002:a0c:b90a:: with SMTP id u10mr23514556qvf.201.1563275354347;
        Tue, 16 Jul 2019 04:09:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563275354; cv=none;
        d=google.com; s=arc-20160816;
        b=u9jKh2lr+O6Sm3ouSe9xWM6vtCictr4XnwaHiXcZh/XW/tE86OQAkbAJ9wxljdLkiD
         5NOfYRDGq8swO19ywqWO85W3zQeoxcHstTueLc74pv5t9wBrbfydveZVfUJCAGQkMd1R
         cna4p+9Vq2BibDcrSloy0BpGHdbZpM2b92ct+Xk8xfuZ8jcqzHP1+BPPycpvaiP14vHK
         5XOs/KORJqdfSiuzBfMcFtRsY3M/mOLKYd2TOA/0WdpfPvacHIXlWZUUHo9Lu1MGrOP6
         bidv3lKTfKo0JYlvYxhLAuY93Kww6gLjycrfjHVkQ3NN1J3BUuLroRGZt5qQbx7r0gYu
         yKlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=/4lfnS4XTqSDOECN3JNw7gRL6dyqLEsf0JaSTFFtIAA=;
        b=g05Cl8oudiRXq+tTkBwPdf2w6vAV9qlDEcOvYZC13GG4BPSpbh8Ov9ztzcUlw6aHgt
         7pgDNEXtVkg3unvALLQRP1B81DqPVObJ9tYmWGRmsQZkGEZyISV7AaJadQTlNaUz6IOo
         wbC+JYTdZyNwbOvuRMbiYbrZSECWxglK09L9J+zUUqwqruuKIkXG1vfUCj3N0HpKkYY0
         JsgLh0EL5KRUEDBeKh6ZRK9uRkQtOlpeYTZyjx313u9r29/X7VS9zDFuhp53CMVi9YAx
         ZjgRWKZ0cOf3Mq+LbXiBrcd0RdK3TSvJ1GilMgu49htM8864p+QSrJiqw4iK3j8cb63B
         IGyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f15si11873547qkg.57.2019.07.16.04.09.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 04:09:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 623062BE9A;
	Tue, 16 Jul 2019 11:09:13 +0000 (UTC)
Received: from [10.36.116.218] (ovpn-116-218.ams2.redhat.com [10.36.116.218])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6DC9519C68;
	Tue, 16 Jul 2019 11:09:07 +0000 (UTC)
Subject: Re: [PATCH v3 10/11] mm/memory_hotplug: Make
 unregister_memory_block_under_nodes() never fail
To: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>,
 Wei Yang <richard.weiyang@gmail.com>, Igor Mammedov <imammedo@redhat.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 Alex Deucher <alexander.deucher@amd.com>,
 "David S. Miller" <davem@davemloft.net>, Mark Brown <broonie@kernel.org>,
 Chris Wilson <chris@chris-wilson.co.uk>,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-11-david@redhat.com>
 <20190701085144.GJ6376@dhcp22.suse.cz> <20190701093640.GA17349@linux>
 <20190701102756.GO6376@dhcp22.suse.cz>
 <d450488d-7a82-f7a9-c8d3-b69a0bca48c6@redhat.com>
 <20190716084626.GA12394@linux>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <eb51f770-b0a3-f50c-daa4-babe6e8d3fc4@redhat.com>
Date: Tue, 16 Jul 2019 13:09:06 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190716084626.GA12394@linux>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 16 Jul 2019 11:09:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 16.07.19 10:46, Oscar Salvador wrote:
> On Mon, Jul 15, 2019 at 01:10:33PM +0200, David Hildenbrand wrote:
>> On 01.07.19 12:27, Michal Hocko wrote:
>>> On Mon 01-07-19 11:36:44, Oscar Salvador wrote:
>>>> On Mon, Jul 01, 2019 at 10:51:44AM +0200, Michal Hocko wrote:
>>>>> Yeah, we do not allow to offline multi zone (node) ranges so the current
>>>>> code seems to be over engineered.
>>>>>
>>>>> Anyway, I am wondering why do we have to strictly check for already
>>>>> removed nodes links. Is the sysfs code going to complain we we try to
>>>>> remove again?
>>>>
>>>> No, sysfs will silently "fail" if the symlink has already been removed.
>>>> At least that is what I saw last time I played with it.
>>>>
>>>> I guess the question is what if sysfs handling changes in the future
>>>> and starts dropping warnings when trying to remove a symlink is not there.
>>>> Maybe that is unlikely to happen?
>>>
>>> And maybe we handle it then rather than have a static allocation that
>>> everybody with hotremove configured has to pay for.
>>>
>>
>> So what's the suggestion? Dropping the nodemask_t completely and calling
>> sysfs_remove_link() on already potentially removed links?
>>
>> Of course, we can also just use mem_blk->nid and rest assured that it
>> will never be called for memory blocks belonging to multiple nodes.
> 
> Hi David,
> 
> While it is easy to construct a scenario where a memblock belongs to multiple
> nodes, I have to confess that I yet have not seen that in a real-world scenario.
> 
> Given said that, I think that the less risky way is to just drop the nodemask_t
> and do not care about calling sysfs_remove_link() for already removed links.
> As I said, sysfs_remove_link() will silently fail when it fails to find the
> symlink, so I do not think it is a big deal.
> 
> 

As far as I can tell we

a) don't allow offlining of memory that belongs to multiple nodes
already (as pointed out by Michal recently)

b) users cannot add memory blocks that belong to multiple nodes via
add_memory()

So I don't see a way how remove_memory() (and even offline_pages())
could ever succeed on such memory blocks.

I think it should be fine to limit it to one node here. (if not, I guess
we would have a different BUG that would actually allow to remove such
memory blocks)

-- 

Thanks,

David / dhildenb

