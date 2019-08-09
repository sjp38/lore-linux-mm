Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD615C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:06:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81F7820B7C
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:06:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="j8hwcxSP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81F7820B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17A0B6B0005; Fri,  9 Aug 2019 05:06:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1042C6B0006; Fri,  9 Aug 2019 05:06:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE6BD6B0007; Fri,  9 Aug 2019 05:06:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B28C26B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 05:06:50 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 30so59362903pgk.16
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 02:06:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=xxX6/xlEYYSgAcMbE9OCsum5lhmSqdMBrVqwD/ALhJM=;
        b=hYW4n3R1fuFTIYqWj8xTZhrMhYyJqAGxjNTBS1tmj+STI+iGtZxJ6eQiCHb4GBuehp
         8iS51Rfvh9evhWqjkNUa3P9SyjRTLp6VKm2fPMgJOEMcoWsd01zoIH8IcLm50cyyh6nB
         Uhs+2LYC1xO1VgVkKf8iy9EEYTdkZttK9jsbv4ydTohHixx6zDJgrPEo0hbmS9eewoU8
         babkQxy0vXaJ42D9HYgpKvsIIrjxOJdtrk4z6QANDFJrjEyWnKnh6pPnhwnE7nhZpvj4
         IVw6AW8U0w5B7JAQ/UaSWCnqpIJtARduOEHFZl6sHM5+teZ5WeiGTRAR0f7q6MVBOUlt
         AzgQ==
X-Gm-Message-State: APjAAAXsGlk9HeLYjkXcFbu37Q0D3bq90s5lYWpLrjab8Kf3yeojVcq8
	TpAyWE4Q5AOiqXgkObZmYGahTPh22OTQeSVelxxeVWEEw3BKKByO+SHmkBASIWVwrwTFbHUXw4S
	S2Se+Gt86euAwW06MHx5gVHB26m/S5pt4eAdB3mO5Y6pJu5xtkHlssoV9zba3sv7t7w==
X-Received: by 2002:a62:2f06:: with SMTP id v6mr20420059pfv.195.1565341610220;
        Fri, 09 Aug 2019 02:06:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpZzYftsQF/MLqs40iY9ETVESgJJlDTJNV52SGmZx/lhyvgScqMgZJbG+FyIrMKJQ0AL5D
X-Received: by 2002:a62:2f06:: with SMTP id v6mr20419982pfv.195.1565341609361;
        Fri, 09 Aug 2019 02:06:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565341609; cv=none;
        d=google.com; s=arc-20160816;
        b=YrgKqXYmSYL/qbBIuxGsq1AzJHBVzEUNXi2G/nYeLijUuuB4Fp+VNb1wc6lePFPAF9
         VhPcCpM/P+21t66ilzze2s9KWxQBhr6pAT+uJsmNndwyxK4aP3lB/om7alF5dHiJ7VbG
         Z5xBu0ER+97H02jzmiP9wMi8fZlygTUVH8XtkdJwZ+yq4V65qluLzSSYVrkX2msCVCYo
         5Fj8sfalReakpbX57QbCV0YR7k/LUmvxcjoMG1hZnhvOgDcpsHFZq+0h6Qc7p26fXzyN
         GzTTCbfaWKHNBhvyNcUCx8AftM3f0VYweeb17/lO8izM1jX59vfAzOhNnSj/7vwxjqGn
         udDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=xxX6/xlEYYSgAcMbE9OCsum5lhmSqdMBrVqwD/ALhJM=;
        b=TVdI3wz5QkZIsmUvkO1wmTo3sxZdqs81QK1kPBngQJAjWmhIyY1eGb2kHc+y1XRsxF
         YTUdcqxzSChZFCQqZmKzVcnvSr6AzJWOH8ERTgN5izXyKlmnIvrCF+j2trj/HdRjUAoQ
         cD8AB10HjrjEarPALNuOtr+r08vUZTjnxK1PacTMCMdy3Xq36kc6TsME2tZMNoRfi0nZ
         bW6amwAkdO8FJhfO1gloMegOev9FRwWL0ZoRXwz71jy+abAoOpR7i9+QNkA5Yd1Sh50K
         VU4n3MbOrYY2TqueClQ7B9qxM07PnPyeCo8m2fwgd2L/WMalSk+EgGRj9HY3lZUrc8ak
         MlZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=j8hwcxSP;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 24si42152950pfn.144.2019.08.09.02.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 02:06:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=j8hwcxSP;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4d37aa0000>; Fri, 09 Aug 2019 02:06:50 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 09 Aug 2019 02:06:48 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 09 Aug 2019 02:06:48 -0700
Received: from [10.2.165.207] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 9 Aug
 2019 09:06:48 +0000
Subject: Re: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
To: Michal Hocko <mhocko@kernel.org>
CC: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton
	<akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Ira Weiny
	<ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-fsdevel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>,
	Daniel Black <daniel@linux.ibm.com>, Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
 <20190805222019.28592-2-jhubbard@nvidia.com>
 <20190807110147.GT11812@dhcp22.suse.cz>
 <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
 <20190808062155.GF11812@dhcp22.suse.cz>
 <875dca95-b037-d0c7-38bc-4b4c4deea2c7@suse.cz>
 <306128f9-8cc6-761b-9b05-578edf6cce56@nvidia.com>
 <d1ecb0d4-ea6a-637d-7029-687b950b783f@nvidia.com>
 <420a5039-a79c-3872-38ea-807cedca3b8a@suse.cz>
 <20190809082307.GL18351@dhcp22.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <a83e4449-fc8d-7771-1b78-2fa645fa0772@nvidia.com>
Date: Fri, 9 Aug 2019 02:05:15 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809082307.GL18351@dhcp22.suse.cz>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565341610; bh=xxX6/xlEYYSgAcMbE9OCsum5lhmSqdMBrVqwD/ALhJM=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=j8hwcxSPSQQ7m/nGMO4zcZKB+HyGn4I5hyxPJMAtoSVYP+yUp53r2/hoxLKbOTaEA
	 Kra5eQySWSmWNcs0Z5HiQTEC7Ds3vYcChlwLJIzcJlJmsU+mQaCJwBGj7s8TY7nU05
	 eHg2mlZvXbM+TER2CGFyvQ4RFppWB3FLbMYL2SdsktQj253jD3tYmUeyqGT0P5X2FD
	 RC9Zljztszfi+1P9PBSu30lEHW3IY0JKjLufsqIfLJH5GnPcxPwukZw4pzC/ezvHeU
	 cADhbvuqEUZCiCTduaINR4cFLGL+WZT+0tDbUSmAou352rwonbnZs4qLfOFGzAp4LX
	 IRkDPPV7ceQHw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/9/19 1:23 AM, Michal Hocko wrote:
> On Fri 09-08-19 10:12:48, Vlastimil Babka wrote:
>> On 8/9/19 12:59 AM, John Hubbard wrote:
>>>>> That's true. However, I'm not sure munlocking is where the
>>>>> put_user_page() machinery is intended to be used anyway? These are
>>>>> short-term pins for struct page manipulation, not e.g. dirtying of page
>>>>> contents. Reading commit fc1d8e7cca2d I don't think this case falls
>>>>> within the reasoning there. Perhaps not all GUP users should be
>>>>> converted to the planned separate GUP tracking, and instead we should
>>>>> have a GUP/follow_page_mask() variant that keeps using get_page/put_page?
>>>>>   
>>>>
>>>> Interesting. So far, the approach has been to get all the gup callers to
>>>> release via put_user_page(), but if we add in Jan's and Ira's vaddr_pin_pages()
>>>> wrapper, then maybe we could leave some sites unconverted.
>>>>
>>>> However, in order to do so, we would have to change things so that we have
>>>> one set of APIs (gup) that do *not* increment a pin count, and another set
>>>> (vaddr_pin_pages) that do.
>>>>
>>>> Is that where we want to go...?
>>>>
>>
>> We already have a FOLL_LONGTERM flag, isn't that somehow related? And if
>> it's not exactly the same thing, perhaps a new gup flag to distinguish
>> which kind of pinning to use?
> 
> Agreed. This is a shiny example how forcing all existing gup users into
> the new scheme is subotimal at best. Not the mention the overal
> fragility mention elsewhere. I dislike the conversion even more now.
> 
> Sorry if this was already discussed already but why the new pinning is
> not bound to FOLL_LONGTERM (ideally hidden by an interface so that users
> do not have to care about the flag) only?
> 

Oh, it's been discussed alright, but given how some of the discussions have gone,
I certainly am not surprised that there are still questions and criticisms!
Especially since I may have misunderstood some of the points, along the way.
It's been quite a merry go round. :)

Anyway, what I'm hearing now is: for gup(FOLL_LONGTERM), apply the pinned tracking.
And therefore only do put_user_page() on pages that were pinned with
FOLL_LONGTERM. For short term pins, let the locking do what it will:
things can briefly block and all will be well.

Also, that may or may not come with a wrapper function, courtesy of Jan
and Ira.

Is that about right? It's late here, but I don't immediately recall any
problems with doing it that way...

thanks,
-- 
John Hubbard
NVIDIA

