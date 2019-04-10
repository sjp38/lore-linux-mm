Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 417CAC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 12:48:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECBA520818
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 12:48:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECBA520818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 750396B0293; Wed, 10 Apr 2019 08:48:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 700096B0294; Wed, 10 Apr 2019 08:48:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EEAD6B0295; Wed, 10 Apr 2019 08:48:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 403366B0293
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 08:48:51 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id b1so2077966qtk.11
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 05:48:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=RxrkUY0KBvOVaRUpJjN213GDT4Jy3LzdpMX+ftB+F+A=;
        b=jzydix/fkBwUCIo3IURxlWjJ4ra2Q5zftoNNxg84cdAd7m+6/83+vevn360W85W6FH
         AITDl3YwB6WNn3KJ+pNjXXsp20sWpna90AJ3omjUvwUKtcHs/+7eiupi2ZPCnbr4FcWJ
         W/QijGsvGugO2flzkj4RzAjYGxvYYoWUvEGW5jeYsCqMblwpXDxtFyXtEexijz9oq+F+
         TMzzCsqdguNiO0wnQodG4bHvCtwCQL3jdG23lnGnzoeq3NLTKVmh4FO5xcwzcibuam6C
         ygejgzI/25dXJDAkSyx8CUCSm3gjcbB2YvMPgeeA378IahtOHWSZ6RUJKncFucoZdKPN
         iJsg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUHfsVFSaN8/pYZDtfT0Eeb8gkvew5Bq/kyxXpYVowH86U1AhIa
	8D8ksCMMGo4nrIDzeVo8ui7aDOXv9m7xdyfgOqe2OfpB4owQUtIaJlqOh9deqR9helbtg+5sYiK
	ne7oDP+UUn+2oOTTw5i3t7bV02UdxaOSTny72K5NU/xO7XjP/IY3IFpIwFCnfLoRuiA==
X-Received: by 2002:aed:3b09:: with SMTP id p9mr36695131qte.152.1554900531022;
        Wed, 10 Apr 2019 05:48:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXL7N4w6XtSQm3sQZmqGT9huopbekrlZuBqFQ+4x2EvUehz3T5Rj86EBvmXdkxFy14siQW
X-Received: by 2002:aed:3b09:: with SMTP id p9mr36695098qte.152.1554900530383;
        Wed, 10 Apr 2019 05:48:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554900530; cv=none;
        d=google.com; s=arc-20160816;
        b=iCs9NzyO0KLYmiyrDJm+3bDWramWcZ9ldfHYRLw+Vpd+NRLGbAgyScu4vZhnLzU2+B
         FdgGLClnP/8IjQf5oK2dtq8HNWzhvEoUo8Dejd4p8qkdS/AMNt5Yy5q6rExTQr0bbww2
         pCL1IeCHgwj/kknElX6aGtLveyGWNq6xNkVjEwkupiLhpNSeD+XOsOy4p+qXh0hITjJy
         Dn2fqOFN3rnna6WcfFvI+OspdDRgLaOPcQUI2sn2mSYwNKwIyX44qnMY0gB9PmBpun2/
         3sPDs8jOmj8ugCVqc6/jzkXWQnQxcXYoPDY2fzFTHNp476yJToidyseoup0CZSyzW6GG
         YYzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=RxrkUY0KBvOVaRUpJjN213GDT4Jy3LzdpMX+ftB+F+A=;
        b=SKgDhMgOQ1YdiMqtWp3DYAokXwWypjMvnLgm5DgnIAOGHhMhJ+HDE5uzPDtS8ttwbu
         +tpOWiC4q/8sLfQMWKFIDX5LvUpczfpoBn2NYTghVTh2JUgjhCHCVFnBMeeJyHwiwoId
         n7tJFxx0vAJ7kqAeLAKjRLItj35E5nmNBJTfBrz3mkej9IpAuFpUqZEKAfYD++KWNL2K
         x5lCtewbBvOsk6IAWrZo23f5q3qNpl8iEmPUi96TDsEWaaZsnodBclYjqP9bqQgUvR4m
         OnuTnzpOje0JOzrbSo5GS2k/5ZoJSZujYpFPnXIQ46I6Jqxzbqez+QHu/ayYZZUhQvtr
         KE8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l14si2364328qtf.213.2019.04.10.05.48.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 05:48:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 56236356F6;
	Wed, 10 Apr 2019 12:48:49 +0000 (UTC)
Received: from [10.36.118.36] (unknown [10.36.118.36])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2DF905C73E;
	Wed, 10 Apr 2019 12:48:47 +0000 (UTC)
Subject: Re: [PATCH] mm/memory_hotplug: Drop memory device reference after
 find_memory_block()
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
 Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>
References: <20190410101455.17338-1-david@redhat.com>
 <20190410122811.jqlusigqc2a22647@d104.suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <701f0748-c99e-7e68-caf1-6b701f8d3bff@redhat.com>
Date: Wed, 10 Apr 2019 14:48:46 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190410122811.jqlusigqc2a22647@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 10 Apr 2019 12:48:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 10.04.19 14:28, Oscar Salvador wrote:
> On Wed, Apr 10, 2019 at 12:14:55PM +0200, David Hildenbrand wrote:
>> While current node handling is probably terribly broken for memory block
>> devices that span several nodes (only possible when added during boot,
>> and something like that should be blocked completely), properly put the
>> device reference we obtained via find_memory_block() to get the nid.
> 
> We even have nodes sharing sections, so tricky to "fix".
> But I agree that the way memblocks are being handled now sucks big time.
> 

I'm planning to eventually tackle this via memblocks directly, using
"nid" to indicate if mixed sections are contained. So we don't have to
scan all the pages ...

-- 

Thanks,

David / dhildenb

