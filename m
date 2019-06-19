Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DBB0C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:30:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F08E5206E0
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:30:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F08E5206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 737E96B0003; Wed, 19 Jun 2019 05:30:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7102E8E0002; Wed, 19 Jun 2019 05:30:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FE668E0001; Wed, 19 Jun 2019 05:30:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 40DA96B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 05:30:28 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id p34so15223095qtp.1
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:30:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=RZG0IKbYXGPHUm2zfDLGyZNAyWAHbkru3gGKdWpU9UU=;
        b=LNSgLqESw+H58bKKtwh3OsziUhonDz335es2eCeg4SLPo+qWV8NyPtIM5oqiGud0GD
         Gipf7USXuTYJThMIpYNu+b23QShqkaeCyfpxqOftnmB2mkBP1Rb6oS5o2sz1z8Wp3jOS
         E8Uz5gNAglPjiXHySokUAKIzG3Tb633iqaPayPC+5BXQexdHD/nmxR8PC1OlkdhcYOpw
         EVhO68TesduBxXAOM+8SFpBlvD42NJT7nIqEKK6r0ogYZjrlwd6RVqiPXoMn2UrqhiBL
         Ryj0XJAKmVoZxC1DILrckPOFTUFqU8VYGoIS6cj3hEEqBnGgKostB8vna7V8Jw8rw5Ud
         scow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXo8LXBrWd6SIZu/90YOxBsnacEoOM1hKlzQGgUvOri3eXe3V0f
	Sl4wMujOtbfFicN18WYjuBW8TtfC0WP4IA9WoaiYXlatcYYJ4QAG6HUHTrXpGxSQ4QrVf/xbCKH
	obTp8wKrSRSq82uawC4UQFKigBLOMo9jN0pSG1NXEuZv5udpRQMv1YqxkepOjBhl6cg==
X-Received: by 2002:a37:670e:: with SMTP id b14mr26871454qkc.216.1560936628040;
        Wed, 19 Jun 2019 02:30:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHcR7EbyE6FCyHTAdP28B4yRn8uAbNBizbz/KLKoP6Kg+qruVfjABqrxeZpPAIzS9ThMrx
X-Received: by 2002:a37:670e:: with SMTP id b14mr26871413qkc.216.1560936627414;
        Wed, 19 Jun 2019 02:30:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560936627; cv=none;
        d=google.com; s=arc-20160816;
        b=FHUgDRgJWGcYqcXyBw3QkPt3hVEf85P6/wBN/qbc6QBGzJrZh5IJbAsylOmhfjglUf
         KlxmpWsgcj/3EnS0xhOM5+1Y0NX7yDmrDVFCYPPikU1pDMPlekBhVqU71fptDsJR+E2r
         pkMZLq9xP/SIe0vs05I0c6LCOGbGHJnJfU5q+EjGkgj9sj0/sO0W0gmHB0h5XsSlsW/8
         dWtOIhoMq3Op8qyLC6gIuHjvI5/AkZf4jGzmIdmbSQoRJoVRVRX92VfRuPKLoY7SLM1N
         KEGf6bIGd3DA5mIJu/gNb/O944urCeUEF2VTHB5qV64gzAEJlUefnQD6YSZz5NunueGj
         X8lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=RZG0IKbYXGPHUm2zfDLGyZNAyWAHbkru3gGKdWpU9UU=;
        b=CQTywE4pDnyPLRrr1oGwvNoaJjhRgh5kCmZOvLH6jepmFbSYGfJokipteHjcoGsbsl
         PA8EAnvVJvP5WoEYd08mpDkimuISi4rdsiq1j/tw7xQ9ClhztCu+09Gub/RfQZoXP2Im
         huT6g5+xXqCrILlzEAPCgLRYYqEHIfpVWrC4DZZoDbiCu8Mcfb5DT4HXi4ImjPzOLdjc
         DY9pLgfKh7LVT8QcmPgJy5Ft4V5HTvi/9p5fzXxgzzDTjlPxsAnjlC5sMwhGPWG5R+tL
         bEXJl/AEpdv6pMwazkNrjgtko8Csacn0mEWpp/whBAZjy1MY9GAl6PJP922Rg9bQP5EC
         b+cw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q1si12470769qkd.157.2019.06.19.02.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 02:30:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 70A0C3DE0D;
	Wed, 19 Jun 2019 09:30:21 +0000 (UTC)
Received: from [10.36.117.229] (ovpn-117-229.ams2.redhat.com [10.36.117.229])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1F8005C225;
	Wed, 19 Jun 2019 09:30:17 +0000 (UTC)
Subject: Re: [PATCH v2] mm/sparse: set section nid for hot-add memory
To: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>,
 Wei Yang <richardw.yang@linux.intel.com>, linux-mm@kvack.org,
 akpm@linux-foundation.org, anshuman.khandual@arm.com
References: <20190618005537.18878-1-richardw.yang@linux.intel.com>
 <20190619062330.GB5717@dhcp22.suse.cz> <20190619075347.GA22552@linux>
 <a52a196a-9900-0710-a508-966e725eae03@redhat.com>
 <20190619090405.GJ2968@dhcp22.suse.cz>
 <361b8e87-7c30-c492-cfa9-e068c5f55bf9@redhat.com>
 <20190619091658.GL2968@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <06d98037-160b-a817-1256-49746da42a0e@redhat.com>
Date: Wed, 19 Jun 2019 11:30:17 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190619091658.GL2968@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 19 Jun 2019 09:30:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19.06.19 11:16, Michal Hocko wrote:
> On Wed 19-06-19 11:07:30, David Hildenbrand wrote:
>> On 19.06.19 11:04, Michal Hocko wrote:
>>> On Wed 19-06-19 10:51:47, David Hildenbrand wrote:
>>>> On 19.06.19 09:53, Oscar Salvador wrote:
>>>>> On Wed, Jun 19, 2019 at 08:23:30AM +0200, Michal Hocko wrote:
>>>>>> On Tue 18-06-19 08:55:37, Wei Yang wrote:
>>>>>>> In case of NODE_NOT_IN_PAGE_FLAGS is set, we store section's node id in
>>>>>>> section_to_node_table[]. While for hot-add memory, this is missed.
>>>>>>> Without this information, page_to_nid() may not give the right node id.
>>>>>>
>>>>>> Which would mean that NODE_NOT_IN_PAGE_FLAGS doesn't really work with
>>>>>> the hotpluged memory, right? Any idea why nobody has noticed this
>>>>>> so far? Is it because NODE_NOT_IN_PAGE_FLAGS is rare and essentially
>>>>>> unused with the hotplug? page_to_nid providing an incorrect result
>>>>>> sounds quite serious to me.
>>>>>
>>>>> The thing is that for NODE_NOT_IN_PAGE_FLAGS to be enabled we need to run out of
>>>>> space in page->flags to store zone, nid and section. 
>>>>> Currently, even with the largest values (with pagetable level 5), that is not
>>>>> possible on x86_64.
>>>>> It is possible though, that somewhere in the future, when the values get larger
>>>>> (e.g: we add more zones, NODE_SHIFT grows, or we need more space to store
>>>>> the section) we finally run out of room for the flags though.
>>>>>
>>>>> I am not sure about the other arches though, we probably should audit them
>>>>> and see which ones can fall in there.
>>>>>
>>>>
>>>> I'd love to see NODE_NOT_IN_PAGE_FLAGS go.
>>>
>>> NODE_NOT_IN_PAGE_FLAGS is an implementation detail on where the
>>> information is stored.
>>
>> Yes and no. Storing it per section clearly doesn't allow storing node
>> information on smaller granularity, like storing in page->flags does.
>>
>> So no, it is not only an implementation detail.
> 
> Let me try to put it differently. NODE_NOT_IN_PAGE_FLAGS is not about
> storing the mapping per section. You can do what ever other data
> structure. NODE_NOT_IN_PAGE_FLAGS is in fact about telling that it is
> not in page->flags.

Okay, I get what you are saying. Storing it differently is problematic,
though, if we want o minimize memory consumption and have a fast lookup.

I was also looking into avoiding to store the section number in
page-flags with CONFIG_SPARSEMEM. Especially, because the
CONFIG_HAVE_ARCH_PFN_VALID hack is really ugly. But it's tricky :(

-- 

Thanks,

David / dhildenb

