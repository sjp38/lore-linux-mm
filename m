Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD163C48BE3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:44:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC0A22085A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:44:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC0A22085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E8476B0005; Thu, 20 Jun 2019 12:44:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 699078E0003; Thu, 20 Jun 2019 12:44:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5604D8E0001; Thu, 20 Jun 2019 12:44:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 325DF6B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 12:44:36 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id o4so4353446qko.8
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 09:44:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=x1QqEoLtWyPcwSkisAsF+INk5iai7HcfeWLw8vNPLYM=;
        b=ABpOhGpEmi50dTLtBTe4QMIQfzpZ/uRRmaerAM+j++LBeEussB5fPwBP+lJTahd254
         JfEl/BqhwMQ6SgDKoAMSHpbV8GWU7/7V71nXrYvcxckLQW+k0nbsfnh2Y34fm4jkVrXG
         Yx7OQxYMoFjGFCEU3XDKPMkBe7STk+KWEQktavmjzyxjefLTVEwfjlgpHw3AF2wnH9jD
         Zb2ofTVA04dx6/3r2tpSAtsIsQmnWKjY3zh+Le1a/2YuCSbfhp3iqtBh60yOy3X9Rw5X
         vGblg49XtGOVt0kfHZyAmk6tg/WMKAEAQOQ0VA3NGKmbQrQbHmExMyO32fBNixpXTJ9G
         Nf1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXnz8w7Av+PixPTFJjFkHpwQKk4RfwO3xpu/OjsheswQL5nrxnb
	t6rBCnI9WJggLi0Wmr1BMDIbUb9D8LcApT2ACxE80I2OKmBXsV+iGKlDPiR2xdNqkWln+iqjzZi
	8rQHszGTmJZq+RNfJNRPuxKC55XE+kwf9oNm9JDeOu48turiJELXn8AOVkUP5KU0Q9g==
X-Received: by 2002:ac8:f13:: with SMTP id e19mr111473883qtk.11.1561049075964;
        Thu, 20 Jun 2019 09:44:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4DDyBU+XwUF2TTVnKl7cYFIK/JdmUQFs+lbYJX8Bin0aT/Mn8W8YbbKbuZpUsxKPoOze4
X-Received: by 2002:ac8:f13:: with SMTP id e19mr111473845qtk.11.1561049075497;
        Thu, 20 Jun 2019 09:44:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561049075; cv=none;
        d=google.com; s=arc-20160816;
        b=zYXRlLaZ6hsPTlvaFXnILggd1+1jUHZ9N19pcHZcF4do5mdpbvbZdr5Rf+3FkNxKQy
         hUZEUrBEZjQ1QVzjX4OsmAoFc0/R9seXd35hVHYXrSWPuR5ABBcgyfB0jnD1opInedop
         aJYTOZrNcgWRZPlCkS/+3WKXrDwFBHf77/+6wKrFWRP4CL2mNVn7kSa7U0WBGu5lNXds
         JcctOtP+xLbkqP0D4BKwRTDJHQhJSeO/2ok1WcJZbh9G7qlJXYZ5zJgPbPAe0je10966
         JK4c1GVhILwbnIPnzMvpMBoI/cBif3a9sFyOJHGmF1Pdq91j94yr5RhMIIXSNG+RuHtl
         ymag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:to:subject;
        bh=x1QqEoLtWyPcwSkisAsF+INk5iai7HcfeWLw8vNPLYM=;
        b=m0rp96j6XWe3BBD/foCuqT5tVapqpoFE5z/whzmROXhQX4Q/MJIqzuld7Qx4xfutG2
         FrEZcYDE33QTxjF5gpkumx0Y7ySsQi4TXnT3dn+p030nfGknEiR1Moinru83OGHs/bkT
         K6KWWQJpYBZWbMg+oE4pB4p6JgJ6hWuoO6jDxrNX4ExH2EHIhG9juHxA9tIgrNZ7eMsH
         HlYqfB9FWAB5CqGzvW6INGjsVlftxe6/0ltyEBG67zePH5maTdBIX62SLBBPxXpoDdSb
         XROjfs1d5a1/OYs8Za0pi/r1WG96f0MilPnDkHJB3bdpw6EuWAO0hx/+SjLF/yC9VTPZ
         /Gig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t3si151181qvt.202.2019.06.20.09.44.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 09:44:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7CD8A307D91F;
	Thu, 20 Jun 2019 16:44:29 +0000 (UTC)
Received: from [10.36.116.54] (ovpn-116-54.ams2.redhat.com [10.36.116.54])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 66AA15C21E;
	Thu, 20 Jun 2019 16:44:27 +0000 (UTC)
Subject: Re: mmotm 2019-06-19-20-32 uploaded (drivers/base/memory.c)
To: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org,
 broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org,
 sfr@canb.auug.org.au
References: <20190620033253.hao9i0PFT%akpm@linux-foundation.org>
 <bbc205e3-f947-ad46-6b62-afb72af7791e@infradead.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <20f6cca9-42f7-848f-e782-2c9240ec84f6@redhat.com>
Date: Thu, 20 Jun 2019 18:44:26 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <bbc205e3-f947-ad46-6b62-afb72af7791e@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Thu, 20 Jun 2019 16:44:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 20.06.19 17:48, Randy Dunlap wrote:
> On 6/19/19 8:32 PM, akpm@linux-foundation.org wrote:
>> The mm-of-the-moment snapshot 2019-06-19-20-32 has been uploaded to
>>
>>    http://www.ozlabs.org/~akpm/mmotm/
>>
>> mmotm-readme.txt says
>>
>> README for mm-of-the-moment:
>>
>> http://www.ozlabs.org/~akpm/mmotm/
>>
>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
>> more than once a week.
>>
> 
> on i386 or x86_64:
> 
> ../drivers/base/memory.c: In function 'find_memory_block':
> ../drivers/base/memory.c:621:43: error: 'hint' undeclared (first use in this function); did you mean 'uint'?
>   return find_memory_block_by_id(block_id, hint);
>                                            ^~~~
> 
> 

Thanks, see

[PATCH v2 0/6] mm: Further memory block device cleanups

-- 

Thanks,

David / dhildenb

