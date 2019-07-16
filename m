Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67596C76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:02:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C36221743
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:02:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C36221743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF6858E0005; Tue, 16 Jul 2019 11:02:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA7086B000C; Tue, 16 Jul 2019 11:02:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6E218E0005; Tue, 16 Jul 2019 11:02:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 856AB6B000A
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 11:02:42 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id m25so18205253qtn.18
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:02:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=OSsxPBe0QQRxVrfI1a9OPxkmqlCQI1vgW1T3Xdzi6NY=;
        b=O8wOExqQzY/IbZe3zRfsEzmCjpQOYYNX+FtxJ4w2Brv0FrtvH0a5phZEleY1muOvG7
         UBp6+xNvVXmGagUSIIPPr2l6pgu98ZgvCVBvdMkQ/hfzbqlpUdUclEOXOxgErbar8lxn
         mK3VXcGSV/GYTvg34ZiIiLdg0w5udQt3XY3v8hYAoBWzMqB27AiBG7pPT3pNFpyihXjc
         VnxTEQZcx39YXHNtIq8c7MKVPckzcg1FAsgML3Hs5dcGziVGKcbz3HgWuVpz8k7+zedg
         MsVMyMAyCzPm6+/T/WH+lWYPRZFXRhJAj1X56FYVVO9LQanH3XZnS1HBsOMaHbxwpI+p
         D1gQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX3YjbnRzPvz8ffq0O0xd+d1ueVUWWJomO+M3NhVXkbFQhzyCqf
	4fo+zVnBb0rwzlJt4O1tQaaPpoj4kXseLYiPi98VafpTOnxb5+SpBJbAMLr3hnVWrxE1kl1y10N
	4ap/nJG304+6R4WPOUs4/rzkP7NR9tt8xSnlAqRMo4VyTxm0A55delb3DTJ4U8KJgyg==
X-Received: by 2002:ac8:2646:: with SMTP id v6mr22935957qtv.205.1563289362311;
        Tue, 16 Jul 2019 08:02:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSl7/ijtkAQFPl4oN0pvb5JDZpDhhJNYCZ6Islyl6kqNBpzzvs7t+0+umIjSZoPx2wnn9t
X-Received: by 2002:ac8:2646:: with SMTP id v6mr22935892qtv.205.1563289361619;
        Tue, 16 Jul 2019 08:02:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563289361; cv=none;
        d=google.com; s=arc-20160816;
        b=0HTSJ0GEY86yRoaWPG0Zco9Tn+m7IkXakipxN5Hn6xgIjiKiaehNKqrJCbX30I4XPd
         uZ41L9PwiMfDqa5Qf6BC2PKkR1iHuNySIoAT9nq3uUcrSg1uyuAdUMzYF1S83Wjy66aw
         9GHqwbm2i00SI+FVfZ7jf+Wz33J4a9DQHEeJ5aiNHOKcfaXQLNip2ChfwjFqca0mua0Z
         rYEdTAWT9Bf2Dt1OE9SY7xi+iSTw3BVVs7DHJ89ZUakPhiUHlUHAQKLY7+2sk0v5U2iA
         78dfjmDgrL7JV/IEdFM2U9iljOYVt4daUOkL4YVumiybGqse1C7hLNd8fHi8o0qGXavf
         13qA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=OSsxPBe0QQRxVrfI1a9OPxkmqlCQI1vgW1T3Xdzi6NY=;
        b=MekwanNdrRvux+BDJiSMsRdxGcxIguxvSfHkhTdNYdqXMIoITvoETrrQls9j6u81xc
         f6fCb9C1RPuqO9xVpCXFkSH88cI1mSkAVvQ8X5EBAvHHElvHGFdPm42bZFSLO9Jh/VN9
         KhOf1wiOJhQ5/GyyD5j9rcX9Lw5VTw362ipAVr+wDWbHMZGjhFS64JzxnOjTZdv/R7jn
         1oUEY74uaz2Vri33i1zmhBQTMeJyhYOagdksoGruxcjlcKX1lzpzK6PRlf6rgQIhPj+N
         KUlGHOr6IwljGfSatc1zxo4ppe5JP1JdB+xCRARQs9NlL7B9IOf/bjfYmtxpC5ro/ZKv
         jOXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v81si5157178qka.27.2019.07.16.08.02.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 08:02:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A34192BE93;
	Tue, 16 Jul 2019 15:02:40 +0000 (UTC)
Received: from [10.36.116.218] (ovpn-116-218.ams2.redhat.com [10.36.116.218])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7367C5DAA4;
	Tue, 16 Jul 2019 15:02:30 +0000 (UTC)
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
To: Dave Hansen <dave.hansen@intel.com>, "Michael S. Tsirkin"
 <mst@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
 pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
 lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
 pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <20190619223338.1231.52537.stgit@localhost.localdomain>
 <20190716055017-mutt-send-email-mst@kernel.org>
 <cad839c0-bbe6-b065-ac32-f32c117cf07e@intel.com>
 <3f8b2a76-b2ce-fb73-13d4-22a33fc1eb17@redhat.com>
 <bdb9564d-640d-138f-6695-3fa2c084fcc7@intel.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <a4fc0192-839e-72c4-6d37-a8b4f7b05d1e@redhat.com>
Date: Tue, 16 Jul 2019 17:02:29 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <bdb9564d-640d-138f-6695-3fa2c084fcc7@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 16 Jul 2019 15:02:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 16.07.19 16:41, Dave Hansen wrote:
> On 7/16/19 7:12 AM, David Hildenbrand wrote:
>> On 16.07.19 16:00, Dave Hansen wrote:
>>> On 7/16/19 2:55 AM, Michael S. Tsirkin wrote:
>>>> The approach here is very close to what on-demand hinting that is
>>>> already upstream does.
>>> Are you referring to the s390 (and powerpc) stuff that is hidden behind
>>> arch_free_page()?
>>>
>> I assume Michael meant "free page reporting".
> 
> Where is the page allocator integration?  The set you linked to has 5
> patches, but only 4 were merged.  This one is missing:
> 
> 	https://lore.kernel.org/patchwork/patch/961038/
> 

I don't recall which version was actually merged (there were too many :)
). I think it was v37:

https://lore.kernel.org/patchwork/cover/977804/

And I remember that there was a comment from Linus that made the patch
you mentioned getting dropped.

-- 

Thanks,

David / dhildenb

