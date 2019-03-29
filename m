Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E4E9C10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:46:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C14E821871
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:46:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C14E821871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F4DB6B0010; Fri, 29 Mar 2019 11:46:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A5516B026B; Fri, 29 Mar 2019 11:46:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 193246B026C; Fri, 29 Mar 2019 11:46:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED5026B0010
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 11:46:07 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id f89so2638784qtb.4
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 08:46:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=RAhb2CxFhtDm9lZhRBry3aPI0rwEAm5c4FJnB5cuNeM=;
        b=nwURwl3KI9KvgBoZUafaTpl0fyJmLXA8tIgLDibtLU2US1WKDuZYui0ETMChWjYnpJ
         iABVY5q6obUQuoDwMLLdquy52SDiuDij3Ht5keNTi3kUAylDIhyXls141jEh2f/RZIY1
         OCFF1oYAyNJztPDJ5sktEWXfA+k+3KiYAWnGUW5GZ4oLYnKYpNJhs7lOHB7tATZimYlV
         uFll2+irWxTJKjB2a3pXPvFqXraRZxXnxiPvCDSVGYY+7VGDyO4bzHzaMr3oZYMXK+0u
         /wI4zJ2rY9aA5Bt+m2OaZh7XAyYgJscrMTrTa4y7VdQ/6HLzhPOc75U/2oRmMaikeuHa
         FlfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXuUd9cPmpltYqDSMUEZ/hqU206w5Q1S3iAk9WqzvX77Vnb3Wez
	1FkNTvukee7A1cjyeL4dLDK0mAoodHAkOL1QxhT/dH5Ey06QUNPEIewifvIKfSYTE8934l77OxQ
	VXb0wk1WXBofGK4l+9bxC2x1lpAyPxvQhr1MoKlSGgE1ykYMMZ1nqOWFqB0roFsv42A==
X-Received: by 2002:a0c:c950:: with SMTP id v16mr40250082qvj.204.1553874367705;
        Fri, 29 Mar 2019 08:46:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgi8RPqYZtvUH9kPdhwqSMnjmrtSDqtEhmPheV2AUPpr6bV9chNowywvA7lGHq7zjBTfcK
X-Received: by 2002:a0c:c950:: with SMTP id v16mr40250040qvj.204.1553874367158;
        Fri, 29 Mar 2019 08:46:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553874367; cv=none;
        d=google.com; s=arc-20160816;
        b=tjkmncoiC6/VUNCOQ79bzmr+mWss7AZHdue4yK2ZgtSY+lfMowzJ4evNgHtdVHD4ef
         y3CbEsJisbCzSnx/SwpX1T+xpF/Zpk1mX7ONsHA6FescxRAe2CF/8vu/9J3HSxiWPWH9
         r8vOJiSA/vMmHBlcdwxF9XfNU1IxEmGpbp7i4+roTj5Zq9I/5ttfu4kA/MJHJz2n/KLK
         c2lM27oeJNhWDx1+dtkdTB0sJUlRW51tCjY9q9w8YB7FpW3wmz+iIlqa8hhcozYbCc3W
         wI5nNuakGTTd8CoMye/f1pHfa+9GfRZds95pXdjX7yTXK/6l/f+Xi5ktG5raB2azVsX3
         kM7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp
         :references:cc:to:from:subject;
        bh=RAhb2CxFhtDm9lZhRBry3aPI0rwEAm5c4FJnB5cuNeM=;
        b=lXXXbm13q9He31mNNCPXcXwH0poIakWbEjuH3h0OmtaP1gxFILK0ju4K3x++PocHl2
         s51o4z4Rt7ZMkFxy4VbNWbXnIM0ro2W9SBek/pOnBqphFu3FN05dNJmJyNUKRv6D4rdb
         PcVRarfMPJM32O8hnB9Lv7OFeuoDU7oy5oebyqGohGppKtijX3LN8LyC/aOVTJgyhcJ0
         lXqw2knF8ArpxrK9S8bpxVflv1NAzGQjDXxEQmQnKIVgrHQJg7Ak/ggarOek2ecVz2nQ
         lNvIsISRNIoW8O+Q8SyT/X1QaKxG5VZPM5Kx06alCf+A70UeEBo8Wph2JgmmmHlnU7Ex
         jd+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v50si1387980qvj.61.2019.03.29.08.46.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 08:46:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3549785528;
	Fri, 29 Mar 2019 15:46:06 +0000 (UTC)
Received: from [10.36.117.0] (unknown [10.36.117.0])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DBA0A619FE;
	Fri, 29 Mar 2019 15:45:58 +0000 (UTC)
Subject: Re: On guest free page hinting and OOM
From: David Hildenbrand <david@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbonzini@redhat.com,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 yang.zhang.wz@gmail.com, riel@surriel.com, dodgen@google.com,
 konrad.wilk@oracle.com, dhildenb@redhat.com, aarcange@redhat.com,
 alexander.duyck@gmail.com
References: <20190329084058-mutt-send-email-mst@kernel.org>
 <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com>
 <20190329104311-mutt-send-email-mst@kernel.org>
 <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
Date: Fri, 29 Mar 2019 16:45:58 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Fri, 29 Mar 2019 15:46:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.03.19 16:37, David Hildenbrand wrote:
> On 29.03.19 16:08, Michael S. Tsirkin wrote:
>> On Fri, Mar 29, 2019 at 03:24:24PM +0100, David Hildenbrand wrote:
>>>
>>> We had a very simple idea in mind: As long as a hinting request is
>>> pending, don't actually trigger any OOM activity, but wait for it to be
>>> processed. Can be done using simple atomic variable.
>>>
>>> This is a scenario that will only pop up when already pretty low on
>>> memory. And the main difference to ballooning is that we *know* we will
>>> get more memory soon.
>>
>> No we don't.  If we keep polling we are quite possibly keeping the CPU
>> busy so delaying the hint request processing.  Again the issue it's a
> 
> You can always yield. But that's a different topic.
> 
>> tradeoff. One performance for the other. Very hard to know which path do
>> you hit in advance, and in the real world no one has the time to profile
>> and tune things. By comparison trading memory for performance is well
>> understood.
>>
>>
>>> "appended to guest memory", "global list of memory", malicious guests
>>> always using that memory like what about NUMA?
>>
>> This can be up to the guest. A good approach would be to take
>> a chunk out of each node and add to the hints buffer.
> 
> This might lead to you not using the buffer efficiently. But also,
> different topic.
> 
>>
>>> What about different page
>>> granularity?
>>
>> Seems like an orthogonal issue to me.
> 
> It is similar, yes. But if you support multiple granularities (e.g.
> MAX_ORDER - 1, MAX_ORDER - 2 ...) you might have to implement some sort
> of buddy for the buffer. This is different than just a list for each node.

Oh, and before I forget, different zones might of course also be a problem.


-- 

Thanks,

David / dhildenb

