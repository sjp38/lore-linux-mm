Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B843C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 20:17:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C36D02070D
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 20:17:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="gx4TZAEO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C36D02070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E21A6B0271; Tue,  4 Jun 2019 16:17:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5929B6B0273; Tue,  4 Jun 2019 16:17:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 433026B0274; Tue,  4 Jun 2019 16:17:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 211C66B0271
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 16:17:45 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id d205so20748280ywe.8
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 13:17:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=Ys4ew+Gn4nTU0UcGzoVS+OBJ0Amfu2GbT4HCKGZeoDg=;
        b=eTbCWzEII/DHjo+Pg8fW2P1YwLTnkXmV9NT2J7Bh87E5YC91e4kmj2fO4ItWz18qAB
         K/+8SG9rAmvhSf7N6SFhIKMhYStHmKUJT3JTTuR/VtanBubN3aYeKa1t6QxsBo6orXFx
         +gqqYreFaz699jFCCQOy1UkeFDl3/ztq2ZJqWLMHnmIW9/STOqJnE0FN6NhdjXC7PIlg
         xTphVCeeTm4ibin6tca24Jpo3/2KxhMZWT+jYKczdYOnIKQrgtDS+TSYsF/602v14lGE
         ydWCXSmJ01yIXgnGEHjgJyAOXytFjKqqZH61vDjh+o17bL+oX6J9OD473tYJ243CjmrP
         LXfQ==
X-Gm-Message-State: APjAAAVUotuPBJlOjm3D8zZwy7MlLzieCBQ9JY/3VoQQdpQQClz1upuf
	h8m/5j35MMBNk/QmSlO94Mg47zSNPA/7IsZlNpvl7KDlWsF5wvxIVinuWIRtaySKNIPK8t7cSji
	8FhgWUlhZsd4iCFR1d3eatWRjLyPj+fRJgNcETaTwFmd+HTa46lkleGLRQgMc7wplpw==
X-Received: by 2002:a25:b7c3:: with SMTP id u3mr15601562ybj.266.1559679464853;
        Tue, 04 Jun 2019 13:17:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoZoklw2hOYxGvGQP3zXlVodX8vlQ+P4G3zpF2GyWxJnu3vySapEKBAOtbp4OHHsRnJxQA
X-Received: by 2002:a25:b7c3:: with SMTP id u3mr15601543ybj.266.1559679464361;
        Tue, 04 Jun 2019 13:17:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559679464; cv=none;
        d=google.com; s=arc-20160816;
        b=FIdzFnHBSiiu51ryGiw9ukJuWIdbGXWaEDW2QO0OPsfrY07wUfPQNV/ALG3Qu0wILa
         6Zu3MoiYJ18rGflLYPiMVYlKpympGrBfpDKA7kH03poBtoXDs8V1Ttpx7fCwfVrYrvKm
         BtGSxuAnhueBmDFZhhfsd2QO8qnBV34zJeAZjvNtzaNia1exPTO77u7CW27W0o8FfebE
         mDf1c8tJq8B1urrPVejXT/shBbW55cyevwGJ/JxAiOO0Q+mEy9t5Wnd5XSNolb3/glCG
         0KQ97F+h9s8WVAfQrT2ESDV2NeXBaCNqwtnVCTJO6NsVrNVR8H/3c797et6nRgU+3R+g
         av6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=Ys4ew+Gn4nTU0UcGzoVS+OBJ0Amfu2GbT4HCKGZeoDg=;
        b=0FsCAXT4vPwEJTV0MqjABWR3bMpJL2HHN1YQvs6WoKEOKnC5WIUoOwjY1uESnG0M8B
         J8m1GakcjrWx8UikKjuxzv4r0nPFaLSDpQwe5nUKRhOa2mBDmWy9ceRwIvjHg4mLwIuN
         aLdg0+6S9BBWDcGSKyTnSUvP7dbFvfHI0kgNe1D2n9JjxBNb1XOCfzWuCs00fALQH/1m
         xpdgffSUAh1VsqT4qdL4k6OYnEBbP/wW/E1rWhZWwWPHk6DtYj6rIgQBKtsGdo78qoTe
         V1eek8W2vixTsxirq67RSjNQ9Qb5ZG314YVsbOdvRYOQq2raeypHnkf57kwPFS0PXNE4
         5R3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=gx4TZAEO;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id t206si5637247ywt.415.2019.06.04.13.17.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 13:17:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=gx4TZAEO;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf6d1da0000>; Tue, 04 Jun 2019 13:17:30 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 04 Jun 2019 13:17:43 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 04 Jun 2019 13:17:43 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 4 Jun
 2019 20:17:43 +0000
Subject: Re: [PATCH v3] mm/swap: Fix release_pages() when releasing devmap
 pages
To: Dan Williams <dan.j.williams@intel.com>
CC: "Weiny, Ira" <ira.weiny@intel.com>, Andrew Morton
	<akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Linux MM
	<linux-mm@kvack.org>, Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>
References: <20190604164813.31514-1-ira.weiny@intel.com>
 <cfd74a0f-71b5-1ece-80af-7f415321d5c1@nvidia.com>
 <CAPcyv4hmN7M3Y1HzVGSi9JuYKUUmvBRgxmkdYdi_6+H+eZAyHA@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <4d97645c-0e55-37c0-1a16-8649706b9e78@nvidia.com>
Date: Tue, 4 Jun 2019 13:17:42 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hmN7M3Y1HzVGSi9JuYKUUmvBRgxmkdYdi_6+H+eZAyHA@mail.gmail.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559679450; bh=Ys4ew+Gn4nTU0UcGzoVS+OBJ0Amfu2GbT4HCKGZeoDg=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=gx4TZAEOnnJoMkQENcIFwkJRTeWMbOPM7mRcK+8rjXNzVqKtDzpAdmm7NnBAGtfQI
	 A0eEnruDTcpmH8hKXEjNLMNckgvcHOStNiReVkWzaHHb1Q/iPZFkiDxQkhArWOMGC+
	 D7lv9c504aqW9XuEkLGvK+i/G2TqEq/rWS6bvB2zbHv4LjdpyUKlZvZLDo0wVQHUj8
	 Hdn4Q+2ZbnsI9Qk+d4lDU2LEf+nvS5D3BIYxFpgLmNtc9ORa9cEkMonoegxqbxAV/7
	 idTsoGv3ZZffMTpLFTJ6pWH+DvyHDvUPnGlSckAa0dLGLYzt1h97UYOsLMnyRPfttx
	 Fsju2MaD0zNcQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/4/19 1:11 PM, Dan Williams wrote:
> On Tue, Jun 4, 2019 at 12:48 PM John Hubbard <jhubbard@nvidia.com> wrote:
>>
>> On 6/4/19 9:48 AM, ira.weiny@intel.com wrote:
>>> From: Ira Weiny <ira.weiny@intel.com>
>>>
...
>>> diff --git a/mm/swap.c b/mm/swap.c
>>> index 7ede3eddc12a..6d153ce4cb8c 100644
>>> --- a/mm/swap.c
>>> +++ b/mm/swap.c
>>> @@ -740,15 +740,20 @@ void release_pages(struct page **pages, int nr)
>>>               if (is_huge_zero_page(page))
>>>                       continue;
>>>
>>> -             /* Device public page can not be huge page */
>>> -             if (is_device_public_page(page)) {
>>> +             if (is_zone_device_page(page)) {
>>>                       if (locked_pgdat) {
>>>                               spin_unlock_irqrestore(&locked_pgdat->lru_lock,
>>>                                                      flags);
>>>                               locked_pgdat = NULL;
>>>                       }
>>> -                     put_devmap_managed_page(page);
>>> -                     continue;
>>> +                     /*
>>> +                      * Not all zone-device-pages require special
>>> +                      * processing.  Those pages return 'false' from
>>> +                      * put_devmap_managed_page() expecting a call to
>>> +                      * put_page_testzero()
>>> +                      */
>>
>> Just a documentation tweak: how about:
>>
>>                         /*
>>                          * ZONE_DEVICE pages that return 'false' from
>>                          * put_devmap_managed_page() do not require special
>>                          * processing, and instead, expect a call to
>>                          * put_page_testzero().
>>                          */
> 
> Looks better to me, but maybe just go ahead and list those
> expectations explicitly. Something like:
> 
>                         /*
>                          * put_devmap_managed_page() only handles
>                          * ZONE_DEVICE (struct dev_pagemap managed)
>                          * pages when the hosting dev_pagemap has the
>                          * ->free() or ->fault() callback handlers
>                          *  implemented as indicated by
>                          *  dev_pagemap.type. Otherwise the expectation
>                          *  is to fall back to a plain decrement /
>                          *  put_page_testzero().
>                          */

I like it--but not here, because it's too much internal detail in a
call site that doesn't use that level of detail. The call site looks
at the return value, only.

Let's instead put that blurb above (or in) the put_devmap_managed_page() 
routine itself. And leave the blurb that I wrote where it is. And then I
think everything will have an appropriate level of detail in the right places.


thanks,
-- 
John Hubbard
NVIDIA

