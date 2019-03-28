Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75E94C3E8A3
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:54:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 238702173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:54:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 238702173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B72AF6B026C; Thu, 28 Mar 2019 17:54:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF6526B0272; Thu, 28 Mar 2019 17:54:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9983D6B0275; Thu, 28 Mar 2019 17:54:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 71F096B026C
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:54:40 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d139so28253qke.20
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:54:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=vlLVvi6UPx2NZGhPygKXAeoebswcYONIIP8wsyh8rFg=;
        b=oNNBkeneAwWMJFs4zS6k9AY3ZA68D95l2sj2T/Z4kLk0Vi6d8BR+0nU5Z/HSt//m70
         nMFr1XyMpUy/3nUPHGUc0W7lp0R3YqNGiMzv8FtTz0DzTzbLPmzwHlHRUPk5dZgbZ+Y4
         a6711Qu8Bt1OHZlu5RPgbE21+lhX82bWMtigFdhwYbMP9MCjFtP4/JNGICwzc/DDfO03
         +lMJ9yUTtO/7Mig50eKh/mNs4JzRNv8ZrpsGthd0yTCFm0WnBqRwCd3EqWQ411JVZKQ2
         pDpw8/9aq+XbZQwwFiT+lLXegpWJPmvZO4q74K8jfi/YkYj9+rijWWDzDmn74joSkZKs
         SQwg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXQymsSQn77VXog1SOgzT0vKN+lx7zOozxlStG9AgM5230v98Wo
	v8sYE4MuyDKqfNw0BiLLBOtx93nT0woAVurekhQHZ8bqeHlUnBqWLlyfeeFYOfOkKOXJM69y3x/
	n8s1XYfuHxq5d+0dSJEZDT6iMpZcTOQrzMLz1EgG0OgzgXO2ZdBrMQTmOB/hH3+MQMQ==
X-Received: by 2002:a0c:98a4:: with SMTP id f33mr22333324qvd.130.1553810080182;
        Thu, 28 Mar 2019 14:54:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqys4IVnBh013SN8BVtWAXYleazz7Ni9JFwOor/gLiMmdtPyoDUHu0xyOvqIDxv8Q5USDOA+
X-Received: by 2002:a0c:98a4:: with SMTP id f33mr22333292qvd.130.1553810079291;
        Thu, 28 Mar 2019 14:54:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553810079; cv=none;
        d=google.com; s=arc-20160816;
        b=mGzCn1XHRVi0qQ5TLTurqCHvO+cWGFayCDl5RyIju7q+E8MohNpOqmKPzx0T9mNKMd
         jqV7NNoe3H+9jDOZz0uGeebWestup2BreYcDqSUEsxpUV9SfyfIF8lfxXMB20W8SZ0xE
         9YM+QAobDXBoysdkT1F7w39l/yTHXqZafleBsZ4KQZneviv4BNjjuRhekhmsDnB7CS+h
         lOd447O2gJ7DhWcJ2jSgsgXQZYaQo9Vt8Sd0bapPVd/ZTyp8ttVHjyhA3Tywp2Teu4bw
         eRNJYSVB01eiXf8JjamGvHkjrHYEWR8F96E4qpwbwVbwXt8ou2pohfv3SEGHMKzrhJTT
         kWiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=vlLVvi6UPx2NZGhPygKXAeoebswcYONIIP8wsyh8rFg=;
        b=ERoU55rQ+575i40NcKkB6z7IL7szn+ya+4x1s4mnT2ca3ChOSn77lQXnaFQIMF7Qpz
         +T0tuE5X5J+DgYQh06Mj+7nZqpxBOFjychGRDy9GTM19Rj0AFQJHg+mh79H019BSwsCf
         kfPU6pQyWLB5n+CcQAl6B5b5Msm8p7gUS8VtC8iVu1twBt1Tyf5ViTSe75x5+e1QJhy1
         YbZRSN5HfScdyC5S7dahQVvDjrtJ3DMiZIxOKsY57+ZMJ0wP/Lnkh+0XIIOw3gtJey6E
         AgziTecIqVAjw1C5ID7g3CpnicKyL4JtSWnGZ5v9xvi65DbSUtUA8BFuWxhxiBF67UpD
         8sQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k137si14984qke.115.2019.03.28.14.54.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 14:54:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 303EF308FB9D;
	Thu, 28 Mar 2019 21:54:38 +0000 (UTC)
Received: from [10.36.116.61] (ovpn-116-61.ams2.redhat.com [10.36.116.61])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AA0C65D9C9;
	Thu, 28 Mar 2019 21:54:35 +0000 (UTC)
Subject: Re: [PATCH v5 00/10] mm: Sub-section memory hotplug support
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>,
 Jeff Moyer <jmoyer@redhat.com>, Michal Hocko <mhocko@suse.com>,
 Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>,
 Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
 <cf304a31-70a6-e701-ec3e-c47dc84b81d2@redhat.com>
 <CAPcyv4hgAM=ex0B4EBZ40RNf=bXk2WkEzySTUV4ZzOWd_HZwSQ@mail.gmail.com>
 <24c163f2-3b78-827f-257e-70e5a9655806@redhat.com>
 <CAPcyv4ivBagzsZ1fCDb2Cr3scz+R8ZVgyie5c=LWNd6QZuw36g@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <b76b3a91-a0b5-460d-df5c-9358e6219915@redhat.com>
Date: Thu, 28 Mar 2019 22:54:34 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4ivBagzsZ1fCDb2Cr3scz+R8ZVgyie5c=LWNd6QZuw36g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Thu, 28 Mar 2019 21:54:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>>>> Reason I am asking is because I wonder how that would interact with the
>>>> memory block device infrastructure and hotplugging of system ram -
>>>> add_memory()/add_memory_resource(). I *assume* you are not changing the
>>>> add_memory() interface, so that one still only works with whole sections
>>>> (or well, memory_block_size_bytes()) - check_hotplug_memory_range().
>>>
>>> Like you found below, the implementation enforces that add_memory_*()
>>> interfaces maintain section alignment for @start and @size.
>>>
>>>> In general, mix and matching system RAM and persistent memory per
>>>> section, I am not a friend of that.
>>>
>>> You have no choice. The platform may decide to map PMEM and System RAM
>>> in the same section because the Linux section is too large compared to
>>> typical memory controller mapping granularity capability.
>>
>> I might be very wrong here, but do we actually care about something like
>> 64MB getting lost in the cracks? I mean if it simplifies core MM, let go
>> of the couple of MB of system ram and handle the PMEM part only. Treat
>> the system ram parts like memory holes we already have in ordinary
>> sections (well, there we simply set the relevant struct pages to
>> PG_reserved). Of course, if we have hundreds of unaligned devices and
>> stuff will start to add up ... but I assume this is not the case?
> 
> That's precisely what we do today and it has become untenable as the
> collision scenarios pile up. This thread [1] is worth a read if you
> care about  some of the gory details why I'm back to pushing for
> sub-section support, but most if it has already been summarized in the
> current discussion on this thread.

Thanks, exactly what I am interested in, will have a look!

>>>
>>> I don't see a strong reason why not, as long as it does not regress
>>> existing use cases. It might need to be an opt-in for new tooling that
>>> is aware of finer granularity hotplug. That said, I have no pressing
>>> need to go there and just care about the arch_add_memory() capability
>>> for now.
>>
>> Especially onlining/offlining of memory might end up very ugly. And that
>> goes hand in hand with memory block devices. They are either online or
>> offline, not something in between. (I went that path and Michal
>> correctly told me why it is not a good idea)
> 
> Thread reference?

Sure:

https://marc.info/?l=linux-mm&m=152362539714432&w=2

Onlining/offlining subsections was what I tried. (adding/removing whole
sections). But with the memory block device model (online/offline memory
blocks), this really was in some sense dirty, although it worked.

> 
>> I was recently trying to teach memory block devices who their owner is /
>> of which type they are. Right now I am looking into the option of using
>> drivers. Memory block devices that could belong to different drivers at
>> a time are well ... totally broken.
> 
> Sub-section support is aimed at a similar case where different
> portions of an 128MB span need to handed out to devices / drivers with
> independent lifetimes.

Right, but we are stuck here with memory block devices having certain
bigger granularity. We already went from 128MB to 2048MB because "there
were too many". Modeling this on 2MB level (e.g. subsections), no way.
And as I said, multiple users for one memory block device, very ugly.

What would be interesting is having memory block devices of variable
size. (64MB, 1024GB, 6GB ..), maybe even representing the unit in which
e.g. add_memory() was performed. But it would also have downsides when
it comes to changing the zone of memory blocks. Memory would be
onlined/offlined in way bigger chunks.

E.g. one DIMM = one memory block device.

> 
>> I assume it would still be a special
>> case, though, but conceptually speaking about the interface it would be
>> allowed.
>>
>> Memory block devices (and therefore 1..X sections) should have one owner
>> only. Anything else just does not fit.
> 
> Yes, but I would say the problem there is that the
> memory-block-devices interface design is showing its age and is being
> pressured with how systems want to deploy and use memory today.

Maybe, I guess the main "issue" started to pop up when different things
(RAM vs. PMEM) were started to be mapped into memory side by side. But
it is ABI, and basic kdump would completely break if removed. And of
course memory unplug and much more. It is a crucial part of how system
ram is handled today and might not at all be easy to replace.

-- 

Thanks,

David / dhildenb

