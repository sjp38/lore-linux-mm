Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59E25C41514
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:22:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C6E5216C8
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:22:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C6E5216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A78318E0005; Fri, 26 Jul 2019 04:22:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A29E78E0003; Fri, 26 Jul 2019 04:22:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F04D8E0005; Fri, 26 Jul 2019 04:22:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 717D68E0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 04:22:40 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id m25so46652927qtn.18
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 01:22:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=RPfsEX0i6+Qgq0v7isIYi2YJm0OZ1y6UcSJin8+SmYA=;
        b=AWTEeJ1ertQ+jbKWnAOXXyM1rhd2WGwfCzg4wATrVwuBKAtWQTXkitNkfo8a7Qvq/b
         S1Neld/GNjuGiSM2s26VjfzqZyjMMmcM6K1IJyBcPPz1zqtyuq9DSXQsnG1mMpL6ZlRy
         AxNcDgRHUVQcZlc+FmugFXE5qMoZp96REe9gk1mhE8QY7Bop/1EE3F6xuZxkVF3BPgkE
         xA5QYqurExDp0js59xvhIL3hL91YZGkwFQ9Y6A1fmuT6+JzBMAkquvKIoGrKn61tnkLu
         cJ26cBIgQJ3tZHbFnHK37ACqTXJ5FvgHA73WD3g0MMcIcGOU3R3BzzluCW69uMCrB5Yf
         o5hA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWhpEs4oZFj4rPCOqVScJ9zSZHMkjG7DBthGdakp5qWyYr2tN+6
	63Xqb4inwIjgL5yZrz0eQMm1/RsLwzaRMMAZlPZRkbWQ2z2fzX1wiJmxHVrTdU+vYWap+Esxi0X
	Nx/yHnKh5LDITmcrBDEv2GaSutRKcoTC4UF4brNFAF4NoIMNpyN5UHj+uGX7oAjihhQ==
X-Received: by 2002:a05:620a:5a7:: with SMTP id q7mr63164472qkq.477.1564129360202;
        Fri, 26 Jul 2019 01:22:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSaBjaFmwtW6ul6x+sH6eOcdBCuyj7t/eePAtz9gH3Rzl+1VV9ctSFq+NkJ2FdYSGmvIiB
X-Received: by 2002:a05:620a:5a7:: with SMTP id q7mr63164456qkq.477.1564129359681;
        Fri, 26 Jul 2019 01:22:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564129359; cv=none;
        d=google.com; s=arc-20160816;
        b=DIBm2sRsA2bBfnFU89yw0Q+nLQxmK6dh40M8Fm1dxDvqIOF4/tshe+b/nmnrFGWoQa
         hMANDwU9Ktv1LlirubbVmB9uLKfUEssGrCJyRxoVDw3yMPZ9Jth3jiKPKt3n8IeqDhIs
         RvYyk5fTB9Rvu2PviHvq7GbjeavIpqiFmORO+Te4q5cNSXTXJLGfY7uOEuFGVvas61JQ
         z9aDoVBwaR6DpsDl9vEvhudYHZY8NVjiWMGKXjWoXvxCMfyPJYXxiWcI5W4u8Jt8x4Jn
         6T/hk4UFe4ZBID2uhKEBAAmOrVyimYBFr2UuvjJjIcGbABHNE7939BYS6j8FhPtf/IpE
         0q5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=RPfsEX0i6+Qgq0v7isIYi2YJm0OZ1y6UcSJin8+SmYA=;
        b=zZz0xMUsy0Gmpg+Enw+hejVyBBr3sA0Btmo/NZlg3+DB1WaDxzyubUAmOyNPJKqPQc
         uyykkqXeMAT9ONZ0nZUxw0gluU2ykRSGj3FiacwR0kaFnwYNS5YsZhbLuXCTDP52Vtss
         IaILkhRFom1/Vnln01gnmAajhPoVZpBufsTPQcM6KIxtEg/krki5wED9b6rMU5c3qXh3
         cwhwaMcr3PB7M+sNyZsjIP/unUB+RbGUN/nH2GRoUeSn/xZQSrL7wDbn5fvubrJow4SQ
         0sM+Y33DAlIO2/nk1XuBGrMkgBjONeowHSQJgHqqVUbyfQgcLC1EtglWSLce2ltHHYs6
         oRqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 10si32608951qtv.339.2019.07.26.01.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 01:22:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D272C4E908;
	Fri, 26 Jul 2019 08:22:38 +0000 (UTC)
Received: from [10.36.116.244] (ovpn-116-244.ams2.redhat.com [10.36.116.244])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1BD5A6092D;
	Fri, 26 Jul 2019 08:22:36 +0000 (UTC)
Subject: Re: [PATCH RFC] mm/memory_hotplug: Don't take the cpu_hotplug_lock
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador
 <osalvador@suse.de>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 Dan Williams <dan.j.williams@intel.com>, Thomas Gleixner <tglx@linutronix.de>
References: <20190725092206.23712-1-david@redhat.com>
 <20190726081919.GI6142@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <6eae7403-c793-7ba2-d866-c306a1956f48@redhat.com>
Date: Fri, 26 Jul 2019 10:22:36 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190726081919.GI6142@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 26 Jul 2019 08:22:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.07.19 10:19, Michal Hocko wrote:
> On Thu 25-07-19 11:22:06, David Hildenbrand wrote:
>> Commit 9852a7212324 ("mm: drop hotplug lock from lru_add_drain_all()")
>> states that lru_add_drain_all() "Doesn't need any cpu hotplug locking
>> because we do rely on per-cpu kworkers being shut down before our
>> page_alloc_cpu_dead callback is executed on the offlined cpu."
>>
>> And also "Calling this function with cpu hotplug locks held can actually
>> lead to obscure indirect dependencies via WQ context.".
>>
>> Since commit 3f906ba23689 ("mm/memory-hotplug: switch locking to a percpu
>> rwsem") we do a cpus_read_lock() in mem_hotplug_begin().
>>
>> I don't see how that lock is still helpful, we already hold the
>> device_hotplug_lock to protect try_offline_node(), which is AFAIK one
>> problematic part that can race with CPU hotplug. If it is still
>> necessary, we should document why.
> 
> I have forgot all the juicy details. Maybe Thomas remembers. The
> previous recursive home grown locking was just terrible. I do not see
> stop_machine being used in the memory hotplug anymore.
>  
> I do support this kind of removal because binding CPU and MEM hotplug
> locks is fragile and wrong. But this patch really needs more explanation
> on why this is safe. In other words what does cpu_read_lock protects
> from in mem hotplug paths.

And that is the purpose of marking this RFC, because I am not aware of
any :) Hopefully Thomas can clarify if we are missing something
important (undocumented) here - if so I'll document it.

-- 

Thanks,

David / dhildenb

