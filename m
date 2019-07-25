Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98C39C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 20:14:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F55022CBD
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 20:14:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F55022CBD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C73A46B0003; Thu, 25 Jul 2019 16:14:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFE376B0005; Thu, 25 Jul 2019 16:14:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A76328E0002; Thu, 25 Jul 2019 16:14:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0286B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 16:14:26 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id d139so13659623vsc.14
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:14:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=R67epiDcoNuzY0yefkHjHWfUICWJPjzOJKBdE5fiAWk=;
        b=q8Ym+2bKYosevXZ88ZBUSyoL7gqnZj/adRDaWNz50ptaIdUMdOJW578z14xpg/ISFn
         WQH9ya5v/ZDcakDwqQ6244m9DFKIYO0v5CdrBEN4RrFqnDmZXD6RJKXbZsVf0Vq0YrtP
         CxFbbENgSkQrl+AoTHfyevPpzrF1awXKeB6bAWdEM4384GRMrAmeMI4Manzgwcf3EI+N
         R/CV9PRPoukbgARILbZuA7MFLI/j3wxJiFai2mrbP3ehoJ3HEDgLCXToWeDk71Xr7J5u
         KKCUfkvKHnsKrqo52DYnscHYaRbfXmGKOz4avOvJQ2mGXyQ5VsGTgqGzzKNiKFj1lBBx
         6a/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU7H+xNHCdGqfhNf+vZgoU/NULnISSGuuW1zfRDis/6ewApLqKt
	eJC7Pasrf0pDpem5SkOWpqycgiX9ZlCUF2yo1zOYRENRSlKmCbhfqXqXfRhbm4/bYOf+MagfGYd
	ag2Gz6gSnHO/UyZtHn4twrb8bOhGhCm3TBfaLKoOiBenEiHreYVnkuQhbI7hG58SlQA==
X-Received: by 2002:ab0:7782:: with SMTP id x2mr24439850uar.140.1564085666225;
        Thu, 25 Jul 2019 13:14:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNZ8+tX0j4bFRfjmQVaAA/y51VvudeBbtquPJlZtzo9qWWhEPEd9Lk9noTTmpWoLdGCmJK
X-Received: by 2002:ab0:7782:: with SMTP id x2mr24439801uar.140.1564085665504;
        Thu, 25 Jul 2019 13:14:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564085665; cv=none;
        d=google.com; s=arc-20160816;
        b=YnWWoJx28wVI/hcW4mw5Aca59YsB5uPK7TT/MfqnADmXydtmKFUd0fNa5lLR/hhfiz
         xw4Gr6/OaDtzMYNKV6tUxdSBNofm0V6DrJZp8QazCu+f7DAp/51OjXsSjnsHk0w9S2xt
         6gOnkKzAFQxalbW3bHN9q2sGTCZQt+vkgQ9T0V0bkkE7rh9OsUnN8GjCtU8ujsKrDDRH
         gTH23x3C6KbJ65/B2v9sjcVEwMspCBLlbqYqa2++DLWESfShR85FH0Mu5J01zP+2sso3
         xPZoRTUYo2FfBAwVsXmFhs5OCGAkPhPwuWFNJ/5I9mBbvOM81LLWi/xL0wpgJ3jgH0Uq
         SuXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=R67epiDcoNuzY0yefkHjHWfUICWJPjzOJKBdE5fiAWk=;
        b=XJWzeaect23pBjBneVNvoy0j5vNyCp0LD5/ZRwyNHlPsKXtDyxgMKakX7ja8wSYLmD
         jdRbnKm75iUIA3z1AT9GIqdSd5ekBaXc+DdW27WdaTeFUoCkhSWP8hKaaeHCZE5RjIrV
         QUttUH+VlXWfZpT9iHMpCzKgJoX47fJtybAmYdcnKJXjHf9gkNbGWoHY7wi1rIOSFI53
         BQe+b6q0I3VDhaFYH8WuRVzUF37n+/e6PJrVI5HYFh715NmZeNF27UdyprxgQIlQnGtp
         SE31vOBXtpqBCJGbs2ULomd8YJol1ZVWDTizbVjC25zHLmFahE6QS9G+eCrS3ZflLRKQ
         Z4yA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v5si20719627vsk.279.2019.07.25.13.14.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 13:14:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 72BCEC06512B;
	Thu, 25 Jul 2019 20:14:24 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D1F37383F;
	Thu, 25 Jul 2019 20:14:04 +0000 (UTC)
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
 david@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
 pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
 lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
 pbonzini@redhat.com, dan.j.williams@intel.com
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724171050.7888.62199.stgit@localhost.localdomain>
 <20190724173403-mutt-send-email-mst@kernel.org>
 <ada4e7d932ebd436d00c46e8de699212e72fd989.camel@linux.intel.com>
 <fed474fe-93f4-a9f6-2e01-75e8903edd81@redhat.com>
 <bc162a5eaa58ac074c8ad20cb23d579aa04d0f43.camel@linux.intel.com>
 <20190725111303-mutt-send-email-mst@kernel.org>
 <96b1ac42dccbfbb5dd17210e6767ca2544558390.camel@linux.intel.com>
 <cc98f7c9-bcf8-79cb-54b7-de7c996f76e1@redhat.com>
 <6bee80b95885e74a5e46e3bd3e708d092b4a666f.camel@linux.intel.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <3d2bd6cb-5cca-17ec-5ebe-73cbf39f43dd@redhat.com>
Date: Thu, 25 Jul 2019 16:14:02 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <6bee80b95885e74a5e46e3bd3e708d092b4a666f.camel@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 25 Jul 2019 20:14:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/25/19 4:00 PM, Alexander Duyck wrote:
> On Thu, 2019-07-25 at 14:25 -0400, Nitesh Narayan Lal wrote:
>> On 7/25/19 12:16 PM, Alexander Duyck wrote:
>>> On Thu, 2019-07-25 at 11:16 -0400, Michael S. Tsirkin wrote:
>>>> On Thu, Jul 25, 2019 at 08:05:30AM -0700, Alexander Duyck wrote:
>>>>> On Thu, 2019-07-25 at 07:35 -0400, Nitesh Narayan Lal wrote:
>>>>>> On 7/24/19 6:03 PM, Alexander Duyck wrote:
>>>>>>> On Wed, 2019-07-24 at 17:38 -0400, Michael S. Tsirkin wrote:
>>>>>>>> On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
>>>>>>>>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>>>>>>>>
> <snip>
>
>
>>> Ideally we should be able
>>> to provide the hints and have them feed whatever is supposed to be using
>>> them. So for example I could probably look at also clearing the bitmaps
>>> when migration is in process.
>>>
>>> Also, I am wonder if the free page hints would be redundant with the form
>>> of page hinting/reporting that I have since we should be migrating a much
>>> smaller footprint anyway if the pages have been madvised away before we
>>> even start the migration.
>>>
>>>> FWIW Nitesh's RFC does not have this limitation.
>>> Yes, but there are also limitations to his approach. For example the fact
>>> that the bitmap it maintains is back to being a hint rather then being
>>> very exact.
>> True.
>>
>>
>>>  As a result you could end up walking the bitmap for a while
>>> clearing bits without ever finding a free page.
>> Are referring to the overhead which will be introduced due to bitmap scanning on
>> very large guests?
> Yes. One concern I have had is that for large memory footprints the RFC
> would end up having a large number of false positives on an highly active
> system. I am worried it will result in a feedback loop where having more
> false hits slows down your processing speed, and the slower your
> processing speed the more likely you are to encounter more false hits.
>
>

It is definitely an interesting thing to see, I intend to test such a scenario
with large guest before my next posting.

-- 
Thanks
Nitesh

