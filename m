Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AC2DC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:38:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00AE72086D
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:38:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="piG3eQeP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00AE72086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B9276B0003; Fri,  9 Aug 2019 14:38:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96A316B0005; Fri,  9 Aug 2019 14:38:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 831E56B0006; Fri,  9 Aug 2019 14:38:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE676B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 14:38:20 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m19so45746411pgv.7
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 11:38:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=AWUDkVLqdIORGIbcTInm0lQJHtik3ucba+VqqEeNdtM=;
        b=SalFslJBBbKosPu1E24DpUGCW78+A8Wl2zwGj849k9RyNDHbxy8bytsTB+6ECBRJVp
         fLvTz8BTjMQ0pdoqYEpbo76psnl48xkj+QrjMeAAL2t3eOmYaz3H7RnelMfvnGgwvDC1
         SAbinY2vhAmSCrfOOYZ1U5FDLf2NRwWaEld67QGFO5S8B+b31uweVXhRlS0MaTa3q++M
         Ler9q+AAq6RQKEec++Pb1Arw1ePOflZEVzdzQjtsjOlO8qvP3YfJjLBk3IpPXj3Qf50I
         FypgVcJg5LXZnkDdDv9/QKXAcWcQqL6ne0Jg2IvVOlq5856aNceYCljlphmcje8ULoxL
         IXkw==
X-Gm-Message-State: APjAAAVplin5N3QN/JsA2Gfe31nMw5utedRxG9zVXgEuwwBHjV/Q/+i6
	/5EdYDi5/MN40Y/Y1bMzTd33RDqJjILx0Oeuwmbi6/pCm+4Dgd9SBvVxhyViFWfYVEE3b/wDl02
	hm++6E+ySjBzEwCR5ZL1hAZud32HIiRMzFluCsCE4uBUsCR5k2Gk6K441Cba8QXk8Jg==
X-Received: by 2002:aa7:925a:: with SMTP id 26mr4619452pfp.198.1565375899918;
        Fri, 09 Aug 2019 11:38:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLdDTuWyaTGS3v5PrjV+zCAFDPXco741+ozsvlYw50Z2PpemcnHyw2V0Szen2x1rTPt3fI
X-Received: by 2002:aa7:925a:: with SMTP id 26mr4619415pfp.198.1565375899228;
        Fri, 09 Aug 2019 11:38:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565375899; cv=none;
        d=google.com; s=arc-20160816;
        b=qJ8rlCaHCp/OcSzIOZVeo+rorSnrQiiVgyF05D8ps7MRtsMBkI5Cm/nKY6KTanZv/Z
         8bqleCqfQAfAlR4CBu/Lb7pEJ6egduZxH0heCRdeNLcbF0zeQb06yPUXc2hTFaEFPcy7
         4YMbRKESR6JiH0THEOlCtDxJsrSOINzTbEw5IbiDBiquu7ZKYt83sXMmJyaMMy3q0kw4
         uNsMk40LFbMuuC9s9SeQSWuOkT3Dio6Itkz48Rqs/EgcLv+1tmY3Rf4vG9NrYwia1SaN
         emw59dQNW1R5fLa+tS2ZasvYI4n/EJT/ax34lxpbdCsEBUtIckgLHcPfaPm0BmHWXMT8
         zCUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=AWUDkVLqdIORGIbcTInm0lQJHtik3ucba+VqqEeNdtM=;
        b=qudrxid2HzUg1wyzUnY4FmkekTJxX4mIEdHnMrsZKU3cVBgOuuE+eDAF10W4/sLqcy
         kXLZqnF/1KHqVzOemQXY2l7wL96la5atgVWAW2r++3l+j5+OPUT03HPF7laPFnMVsUJ/
         zPyuFAgcaLhaUz+/WO4/KaB5u828ZxR5C6gtqbF4oxSTmj1dfhpAAp5NJsbVqr4q7CJd
         YNoFwjlFaQR8Q9ziK5nc31PAdksg1yWQhU+mblAoIuWbX7AS3PubWkUSgYO+my+g3Epe
         Kii0bGYcWGim9fOqHS7piq5Apc/WXtAIL4nWMZnu+KRveEi0rhV7NLvfjzbjuhCNhv1q
         /g0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=piG3eQeP;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id p9si2271178pjn.4.2019.08.09.11.38.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 11:38:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=piG3eQeP;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4dbd9b0000>; Fri, 09 Aug 2019 11:38:20 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 09 Aug 2019 11:38:18 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 09 Aug 2019 11:38:18 -0700
Received: from [10.2.165.207] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 9 Aug
 2019 18:38:17 +0000
Subject: Re: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
To: "Weiny, Ira" <ira.weiny@intel.com>, Michal Hocko <mhocko@kernel.org>, Jan
 Kara <jack@suse.cz>
CC: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton
	<akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Jason
 Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "Williams,
 Dan J" <dan.j.williams@intel.com>, Daniel Black <daniel@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>
References: <20190805222019.28592-2-jhubbard@nvidia.com>
 <20190807110147.GT11812@dhcp22.suse.cz>
 <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
 <20190808062155.GF11812@dhcp22.suse.cz>
 <875dca95-b037-d0c7-38bc-4b4c4deea2c7@suse.cz>
 <306128f9-8cc6-761b-9b05-578edf6cce56@nvidia.com>
 <d1ecb0d4-ea6a-637d-7029-687b950b783f@nvidia.com>
 <420a5039-a79c-3872-38ea-807cedca3b8a@suse.cz>
 <20190809082307.GL18351@dhcp22.suse.cz>
 <20190809135813.GF17568@quack2.suse.cz>
 <20190809175210.GR18351@dhcp22.suse.cz>
 <2807E5FD2F6FDA4886F6618EAC48510E79E7F3E7@CRSMSX101.amr.corp.intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <e2bad873-137a-0c35-0674-f5dea6c61f3a@nvidia.com>
Date: Fri, 9 Aug 2019 11:36:45 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <2807E5FD2F6FDA4886F6618EAC48510E79E7F3E7@CRSMSX101.amr.corp.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565375900; bh=AWUDkVLqdIORGIbcTInm0lQJHtik3ucba+VqqEeNdtM=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=piG3eQePf8V+mHT9Zce3BSUjqk9l6uDwFxA9H2EedRCzVUFYtqH1h4nXGte/KWFlN
	 xZGLguGJGcQxYhB9IuSFjRUgaOPgTkpVIZwP5arOrYCiPtgtzTeltSOIXvrqdit/Tn
	 QJB5ptzF8lyqgfmHRnDKP0NfUjUrgTHNEGsqbfkGedUbma1Pp7ya87wnpiMvF6edFa
	 ZxlzE6K3WTkJs9WNAUxATkydOVAVg7+N+mvCq8IvQjUZS/BAOXY5nA51BLkM1THFHj
	 ij+lLOsW/RZi/WiFtmvTVe6QCJM0XbxuH8T0lKRw7Q9uY/Oy3N9nHUIVaqJ7ZFxMCx
	 2iVeFvON8EsvQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/9/19 11:14 AM, Weiny, Ira wrote:
>> On Fri 09-08-19 15:58:13, Jan Kara wrote:
>>> On Fri 09-08-19 10:23:07, Michal Hocko wrote:
>>>> On Fri 09-08-19 10:12:48, Vlastimil Babka wrote:
>>>>> On 8/9/19 12:59 AM, John Hubbard wrote:
...
>>> In principle, I'm not strongly opposed to a new FOLL flag to determine
>>> whether a pin or an ordinary page reference will be acquired at least
>>> as an internal implementation detail inside mm/gup.c. But I would
>>> really like to discourage new GUP users taking just page reference as
>>> the most clueless users (drivers) usually need a pin in the sense John
>>> implements. So in terms of API I'd strongly prefer to deprecate GUP as
>>> an API, provide
>>> vaddr_pin_pages() for drivers to get their buffer pages pinned and
>>> then for those few users who really know what they are doing (and who
>>> are not interested in page contents) we can have APIs like
>>> follow_page() to get a page reference from a virtual address.
>>
>> Yes, going with a dedicated API sounds much better to me. Whether a
>> dedicated FOLL flag is used internally is not that important. I am also for
>> making the underlying gup to be really internal to the core kernel.
> 
> +1
> 
> I think GUP is too confusing.  I've been working with the details for many months now and it continues to confuse me.  :-(
> 
> My patches should be posted soon (based on mmotm) and I'll have my flame suit on so we can debate the interface.
> 

OK, so: use FOLL_PIN as an internal gup flag. FOLL_PIN will get set by the
new vaddr_pin_pages*() wrapper calls. Then, put_user_page*() shall only be
invoked from call sites that use FOLL_PIN.

With that approach in mind, I can sweep through my callsite conversion
patchset and drop a few patches. There are actually quite a few patches that
just want to find the page, not really operate on its data.

And the conversion of the actual gup() calls can be done almost independently
of the put_user_page*() conversions, if necessary (and it sounds like with your
patchset, it is).

btw, as part of the conversion, to make merging and call site conversion
smoother, maybe it's OK to pass in FOLL_PIN to existing gup() calls, with
the intent to convert them to use vaddr_pin_pages.)

thanks,
-- 
John Hubbard
NVIDIA
  

