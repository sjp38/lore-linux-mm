Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9954EC76192
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 11:10:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CF4D2086C
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 11:10:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CF4D2086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D33A46B0271; Mon, 15 Jul 2019 07:10:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE3E46B0272; Mon, 15 Jul 2019 07:10:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAB0B6B0273; Mon, 15 Jul 2019 07:10:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 99B766B0271
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 07:10:40 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 41so8597591qtm.4
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 04:10:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Mp2y8mwZEuxb8qDOgxAcRaj+bK58NxWSXXgw95Fc5e4=;
        b=hFQS2agz9hAVr6IkVe+0B3uEwAiWHLHHs3CNChcibnpoL/vyUOnsG+3Xm7JMgF5tQ9
         B9XA1tLIJbOuftbWqzk7/Ez0xG7blp+2el78Jk3EskSatkwUjUmkHPjXAuuJLwBQ+D9u
         2fQ6M/PpEi5/idATj9CNlAicZYJ5HUeKQYTgqbJNL69XaAk/KEuVYzy6oq16aBQgWgsj
         v0CmyAXTARZAeD5GPLu6I2yfOYwwU8GqCnDP1KGefkXUvB5xQ2q6XLNWioxJXGacP6Bu
         WtYUvNhaCGwGTxOb983zs1MsGJAUJrZe10y7wiuyj16PuuK7+H9FvI4l+QlPeO9yYIQS
         LQKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUoBnQe47g9BhPCi1xW2L87wnIuhg8xtINirX7QWa+ZCwfB/4kq
	XsngvbMnj2XAT9vI+e/18oGFmJnomFe3oQaAszHGTKx7+Ax9LqrLQ9Yie/+MLd0K49Yr+U+ARzl
	juST/eNakXoIGPGSyGYocYkXDKGNQmV8TMCJ8gT/yC5QKzHXWOkSPGuTB0t9+A8r0Bg==
X-Received: by 2002:ac8:35f6:: with SMTP id l51mr11718904qtb.109.1563189040413;
        Mon, 15 Jul 2019 04:10:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrYFUIXw8PrI1lmspgr6ntwmHoqsRXy+P5qVae843r/noWtK5fRiJxHiKQ7twrvYABIDqj
X-Received: by 2002:ac8:35f6:: with SMTP id l51mr11718860qtb.109.1563189039858;
        Mon, 15 Jul 2019 04:10:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563189039; cv=none;
        d=google.com; s=arc-20160816;
        b=L+3dW5Wuopmyzds9VQGzP1R3A+9xkoPxmHJbnmkgFze6/CaRTLlv51aeC8m6lNoiNf
         M02YHqX6EYiUY3INKq1338krkhiHsnp1+lMfhvmlbemO2ZRr5pZRcVMc3RXBjtWhGqGO
         adhko+/qargzmphCQ4nXAzSS6U+8x2d2zuNfgUvFyc7bSb0baFscA9GxtZmfIFSfvjQt
         FPRBJ5oXkqLCyCD8aL1+fO3diAUVy2vrclYdy3YjabD27VGERdRY6L2p16bW8vSe2lGc
         eIHwij0t9k0brPYMgFWB4q5jrW7+XEMqGVbJkT/ezeoiegQsba7wDM2F6l7iN7LtJbSF
         lVPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Mp2y8mwZEuxb8qDOgxAcRaj+bK58NxWSXXgw95Fc5e4=;
        b=Q+GEwEWqMpD+MN2RZB93cQ/JQHEfAt0+fwTb0aXNJlhAFGQQhwNenNkMJycGaMHnpB
         bnRD4rzzr8sUkWsSrrE5ArVf7U4PM8V2iT3WUpZX8G3v1dvuywzC7qhfv5Cmvoc9dmES
         Q6FCV4i1hEtuz6+/lxbI1kEzT0r3tKL5e5nbcCZSQHFDWsxy5lfuGlft27/9o/+w1xoa
         KejpSEVQc0fWUnVBJ3X6P1+0eonLxLEaCdEQoPlJ10ptjDzLCBaX3Sk4EvHnn11A1x0o
         jAVOhkaTaDqT5edL7Y3lvkvnuuKt9LRrJDOUf+7eExcKyAl9/rs0KRYuaKcJk7e4hhe/
         /V8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d26si9896569qkl.360.2019.07.15.04.10.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 04:10:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B4EAA308427C;
	Mon, 15 Jul 2019 11:10:38 +0000 (UTC)
Received: from [10.36.117.137] (ovpn-117-137.ams2.redhat.com [10.36.117.137])
	by smtp.corp.redhat.com (Postfix) with ESMTP id F17431001B18;
	Mon, 15 Jul 2019 11:10:34 +0000 (UTC)
Subject: Re: [PATCH v3 10/11] mm/memory_hotplug: Make
 unregister_memory_block_under_nodes() never fail
To: Michal Hocko <mhocko@kernel.org>, Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 Dan Williams <dan.j.williams@intel.com>, Wei Yang
 <richard.weiyang@gmail.com>, Igor Mammedov <imammedo@redhat.com>,
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
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <d450488d-7a82-f7a9-c8d3-b69a0bca48c6@redhat.com>
Date: Mon, 15 Jul 2019 13:10:33 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190701102756.GO6376@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Mon, 15 Jul 2019 11:10:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.07.19 12:27, Michal Hocko wrote:
> On Mon 01-07-19 11:36:44, Oscar Salvador wrote:
>> On Mon, Jul 01, 2019 at 10:51:44AM +0200, Michal Hocko wrote:
>>> Yeah, we do not allow to offline multi zone (node) ranges so the current
>>> code seems to be over engineered.
>>>
>>> Anyway, I am wondering why do we have to strictly check for already
>>> removed nodes links. Is the sysfs code going to complain we we try to
>>> remove again?
>>
>> No, sysfs will silently "fail" if the symlink has already been removed.
>> At least that is what I saw last time I played with it.
>>
>> I guess the question is what if sysfs handling changes in the future
>> and starts dropping warnings when trying to remove a symlink is not there.
>> Maybe that is unlikely to happen?
> 
> And maybe we handle it then rather than have a static allocation that
> everybody with hotremove configured has to pay for.
> 

So what's the suggestion? Dropping the nodemask_t completely and calling
sysfs_remove_link() on already potentially removed links?

Of course, we can also just use mem_blk->nid and rest assured that it
will never be called for memory blocks belonging to multiple nodes.

-- 

Thanks,

David / dhildenb

