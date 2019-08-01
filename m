Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7CC9C41514
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:18:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E385216C8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:18:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E385216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0264F8E0005; Thu,  1 Aug 2019 03:18:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 006A48E0001; Thu,  1 Aug 2019 03:18:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2E5B8E0005; Thu,  1 Aug 2019 03:18:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C39918E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 03:18:52 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d11so60340750qkb.20
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 00:18:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Cq+tXOw2Fwg6ROCGDYvBuZdVCWKoBLrowG8odcyxqLw=;
        b=E+FQTHy5pppoR9ZK2DMVXui9b5XTSdLU8OXSI+T4guuM2lpiWvjhOjlRCDZouSzwOd
         0yJLGxFFMPmAvOMsTLfAwiBL6tWe/MkWfGimOHWR6jhgWV9f3unIc9nmOTT5gZL4vzW8
         2a6eeCu8CgxWXmMzMBvQRaEPFjUuSJmi051VaR4SJk0Oti6SQNO0MCjVS6Jt7J2uSfi7
         uLs6LR2pk/PkKdAQN6GyX6XCdNn0OBtQVtg4or3zGVLmyHMQBEoHkLAD79SaLnH3Dbnv
         RkIF2i0mp/2ery4F8AyF9jbv/7KlLMy8YZdHIUSTJiCSAMlzYJ6qT34syVolf6wv+7CJ
         62/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVV0yjzyqj7lObURJ5sYBsV0UoGoZVsHdD9AJjxfqbml8a4Vx0q
	XzGB91qIYoi6sWWshuubbFHKNo7V4hwoL7VKlU4SWoctfrEuXp2uRNnOC+cSl7NfCyw5FA5m0Ht
	RIe6x6h8CI4M0nA4PbIF2uCca7Iqh6KA7HeHGH6r/k1eFNDhF0X7QxwmDlvFCW3qFIg==
X-Received: by 2002:a0c:ea4b:: with SMTP id u11mr51695803qvp.143.1564643932570;
        Thu, 01 Aug 2019 00:18:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzM/pwgh3MOMwORxDYR9Wa6aNZ7cX1yY73W455poNPQ9tApojCWfdYHRHTBjCmtv4fnPTs5
X-Received: by 2002:a0c:ea4b:: with SMTP id u11mr51695777qvp.143.1564643932053;
        Thu, 01 Aug 2019 00:18:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564643932; cv=none;
        d=google.com; s=arc-20160816;
        b=B/2q5nu/A7gwy05Yj4JOFwEGSXjedG9viiE01g3KQIUFnbd6ni+HfGYfvmG1nayXL7
         GzXpsiF0L79XfbdpTWLfQAWrqreIQXIbnVeuV395AaCarErZWjSM+UVe2xFEUAf6xx0d
         LGJo0UWj3hDJttCc6r+J9zFjCyWGXhDiCZzSdtAD94tGXYq36jDXqeX6HngMRKJBDOKf
         x6EeJothGJRY8CpapZZkXSZK9zYT3Dkm8fnhqeCoUmJXm9roa7dmDpdXiaZuxqB+xV3f
         p7nw7juf1+YHzSg/QlHo+7tHWjMQncP7VAfpJGhFC8FKaQ++ob6rjtGQ8rrdZHi9FLCG
         QjCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Cq+tXOw2Fwg6ROCGDYvBuZdVCWKoBLrowG8odcyxqLw=;
        b=hOUpLk7VnqTooEk6tkNuo4gYRDSAfZXIBElH6whPBrMj0AX2aLC59vfZzlDw5CsAmy
         9B7uGCROycQYBowcBB4qUgnyyYtfzsVhTERhQRDxuXQsk09bSXJkmCbbCCHmObJcYf5Z
         Mo01pekrw6309Y14uXCKQr35HVGv3QHygYQSYHVNLEMOSt8oYIdcLVcvHylYzjGCxpmS
         JbcDwQSz9ldzvKpV5Zb+zRW1PVROSwPhEtdiFDeiEITFIzsBWNVk/CDGD3Wr4QFjBzWP
         H9ICzs0m74rc2AChHXMa+n0fZ+K+vHQiRUSLresVZ4IG61x3uZGElvx89Y6FRXb5jsaY
         yTlA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y8si3438585qkj.369.2019.08.01.00.18.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 00:18:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0426BC04BD48;
	Thu,  1 Aug 2019 07:18:51 +0000 (UTC)
Received: from [10.36.116.245] (ovpn-116-245.ams2.redhat.com [10.36.116.245])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6D6CC60623;
	Thu,  1 Aug 2019 07:18:48 +0000 (UTC)
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
To: Michal Hocko <mhocko@kernel.org>, Rashmica Gupta <rashmica.g@gmail.com>
Cc: Oscar Salvador <osalvador@suse.de>,
 Andrew Morton <akpm@linux-foundation.org>,
 Dan Williams <dan.j.williams@intel.com>, pasha.tatashin@soleen.com,
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
 Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
 <20190626080249.GA30863@linux>
 <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
 <20190626081516.GC30863@linux>
 <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
 <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
 <20190702074806.GA26836@linux>
 <CAC6rBskRyh5Tj9L-6T4dTgA18H0Y8GsMdC-X5_0Jh1SVfLLYtg@mail.gmail.com>
 <20190731120859.GJ9330@dhcp22.suse.cz>
 <4ddee0dd719abd50350f997b8089fa26f6004c0c.camel@gmail.com>
 <20190801071709.GE11627@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <9bcbd574-7e23-5cfe-f633-646a085f935a@redhat.com>
Date: Thu, 1 Aug 2019 09:18:47 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190801071709.GE11627@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 01 Aug 2019 07:18:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.08.19 09:17, Michal Hocko wrote:
> On Thu 01-08-19 09:06:40, Rashmica Gupta wrote:
>> On Wed, 2019-07-31 at 14:08 +0200, Michal Hocko wrote:
>>> On Tue 02-07-19 18:52:01, Rashmica Gupta wrote:
>>> [...]
>>>>> 2) Why it was designed, what is the goal of the interface?
>>>>> 3) When it is supposed to be used?
>>>>>
>>>>>
>>>> There is a hardware debugging facility (htm) on some power chips.
>>>> To use
>>>> this you need a contiguous portion of memory for the output to be
>>>> dumped
>>>> to - and we obviously don't want this memory to be simultaneously
>>>> used by
>>>> the kernel.
>>>
>>> How much memory are we talking about here? Just curious.
>>
>> From what I've seen a couple of GB per node, so maybe 2-10GB total.
> 
> OK, that is really a lot to keep around unused just in case the
> debugging is going to be used.
> 
> I am still not sure the current approach of (ab)using memory hotplug is
> ideal. Sure there is some overlap but you shouldn't really need to
> offline the required memory range at all. All you need is to isolate the
> memory from any existing user and the page allocator. Have you checked
> alloc_contig_range?
> 

Rashmica mentioned somewhere in this thread that the virtual mapping
must not be in place, otherwise the HW might prefetch some of this
memory, leading to errors with memtrace (which checks that in HW).

-- 

Thanks,

David / dhildenb

