Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 739A3C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 21:05:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28D142184E
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 21:05:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="RBMHQkFT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28D142184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F1C26B0007; Fri, 19 Jul 2019 17:05:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C97A6B0008; Fri, 19 Jul 2019 17:05:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 591C88E0001; Fri, 19 Jul 2019 17:05:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3AAAE6B0007
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 17:05:27 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id f126so25416256ybg.16
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 14:05:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=uXXZ8OaRelUTVBhhS709HcwBaF4jbMLR5EBDQ41vffw=;
        b=VVONLQJ8KWnSQL3jbNTIkGnKjYkJmRBmdMwREbuKicYd9JnlySJaxAt65VOTm0MxGk
         gi7QMOa6lPFHxvmQpWIvzpn8AO9EilU6uIrCv2D6dDP8Ndr1iYcXgFe4i07Bt0vgisjb
         HlKIMRnDf3iGvEyIiPfTtDvGRpy59xbPpPiHyAH534Q/GbSEG3lhLv7AMsosy+ndWFlB
         ftkX1jS/Xqc9CuXw2FNLRwRCCk7BFOsSV/y0fLQMDoczF9C2MR31E/f1mke1xdbdQ5ga
         efMmHpFXN5r2uhE6xQK8y07AbnMUWlfUplHJGMWdGIUlKsl1BCsH9tuReYDti0EbDuIR
         U83A==
X-Gm-Message-State: APjAAAWZWkkYHtciNepIA8rLvAqt2fDM8XWwnh1eUFYAkVkO3K24Z3v4
	IK6O5kNOhoHv5QxC6uTwIkiQWWMj8NlRXvPyIAlwkuEB1ZLESR0KFhvXdBqfYuaRjcdyPZ+ceTN
	ZjON9X9+HCfMqx1KxaEtqnMBUgwm96SujOnL5kx3yhxhWr/Wfk67eMw31hLbpc0e/OA==
X-Received: by 2002:a81:e11:: with SMTP id 17mr33991136ywo.231.1563570326962;
        Fri, 19 Jul 2019 14:05:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnoldD1Ad9yHSuuJRjGnpTwPCcbpacAzZTD7+nrDai9xTuiK3sxcGPK3MKpi8hQcruLmK4
X-Received: by 2002:a81:e11:: with SMTP id 17mr33991075ywo.231.1563570325839;
        Fri, 19 Jul 2019 14:05:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563570325; cv=none;
        d=google.com; s=arc-20160816;
        b=E+KVp0CP6V5hBwbMzWVMaP7tsW/rF4dhms9gnKxwEMeHWHdwX1DDR0rMPqmN7d84S4
         XRG8v3gx9t2k0BBjvtBMum2nXit1SrYgYHoVEbmPfr6y3a3/yjn9UAitda7Xgnxlku8w
         V6COPAGiM8gDtlJvnQ4iluwrs65TsGTY7MUfWCa6zB3KzSS8/Gi3I+pexhJ9nkgM4524
         4E2kuIRf918rnKc3p9uoud2SkD6wfxJIWWxoHLdZ1WduuntAJ9DuhryL3GS6CDaGVy3e
         FHkiwPhxrJBfbObxaHaA88irWteynbvnT9frm6h0uIcviuTyXvJiogs4eGiSjDPPZe+1
         Ka+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=uXXZ8OaRelUTVBhhS709HcwBaF4jbMLR5EBDQ41vffw=;
        b=xAIXxDhYHakRfG2WOg7ow8v7npPnth1kLZIs2F12at2shMiKnDeYNk1u03bl/FOfxQ
         kacfSEBVuUi8cB/YRwJUvDWLyg1/D/gZ2Ge17t3EXPHXcr29liiAqLmPKroUJmVrBaKI
         K6UaeWJF1wBrRAKQdPjSSaOJjXQSSST3Piko9STGUefoluxNrjlCivjNOUMV/FCbcNqR
         rt8Al4Y/jL9jFQPLLhex204ZGUmcMdmo71Pg6bQqayndjoVo2eBF55KMyd6t3jWFRs1j
         pUY1FLxlic/ihxg59DD1cZf1ekOs31Wv+2jqjtw4CqYBMSqX91SSLY1rr86/5wTdWsEB
         N5Aw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=RBMHQkFT;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id m2si12932919ybp.153.2019.07.19.14.05.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 14:05:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=RBMHQkFT;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3230950000>; Fri, 19 Jul 2019 14:05:25 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 19 Jul 2019 14:05:24 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 19 Jul 2019 14:05:24 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 21:05:24 +0000
Subject: Re: [PATCH v3] staging: kpc2000: Convert put_page to put_user_page*()
To: Matt Sickler <Matt.Sickler@daktronics.com>, Bharath Vedartham
	<linux.bhar@gmail.com>, "ira.weiny@intel.com" <ira.weiny@intel.com>,
	"jglisse@redhat.com" <jglisse@redhat.com>, "gregkh@linuxfoundation.org"
	<gregkh@linuxfoundation.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "devel@driverdev.osuosl.org"
	<devel@driverdev.osuosl.org>
References: <20190719200235.GA16122@bharath12345-Inspiron-5559>
 <SN6PR02MB4016754FE1BB6200746281A2EECB0@SN6PR02MB4016.namprd02.prod.outlook.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <3948879c-5764-4245-e950-eb4749aafe5b@nvidia.com>
Date: Fri, 19 Jul 2019 14:05:23 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <SN6PR02MB4016754FE1BB6200746281A2EECB0@SN6PR02MB4016.namprd02.prod.outlook.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563570325; bh=uXXZ8OaRelUTVBhhS709HcwBaF4jbMLR5EBDQ41vffw=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=RBMHQkFTRPQgCd7gP4P+7u6BJdhh2b31ep8178Yi5S3jKNIPqrnwL2KL1601Z+iuQ
	 9V44LCZdjYVWOPr8mb/RBqFqi+lWyoa4VLjFHCODAHQmfqss6YPvwRWYQ24WU7q3lW
	 JEhvpFzEci71ms+nbfMOZqVZJIL7B2u3yJJhe+lnLiFchga6FTAWxwHtKCj2i1af+G
	 tWD9LYiUxhJnZ6l0hzXLh3TFsed9xgGzTVtHb8LdrvqemTRFs0fukUMZ0VogQapToK
	 fOZyAxJ+lOP22NjLrdU81USY8v73UiGyZDvqTYlE+oi5v9TNpmoafHVddNgLIgfFML
	 fmlLIcQLM3yuQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/19/19 1:59 PM, Matt Sickler wrote:
>> From: Bharath Vedartham <linux.bhar@gmail.com>
>> Changes since v2
>>        - Added back PageResevered check as suggested by John Hubbard.
>>
>> The PageReserved check needs a closer look and is not worth messing
>> around with for now.
>>
>> Matt, Could you give any suggestions for testing this patch?
> 
> Myself or someone else from Daktronics would have to do the testing since the
> hardware isn't really commercially available.  I've been toying with the idea
> of asking for a volunteer from the mailing list to help me out with this - I'd
> send them some hardware and they'd do all the development and testing. :)
> I still have to run that idea by Management though.
> 
>> If in-case, you are willing to pick this up to test. Could you
>> apply this patch to this tree and test it with your devices?
> 
> I've been meaning to get to testing the changes to the drivers since upstreaming
> them, but I've been swamped with other development.  I'm keeping an eye on the
> mailing lists, so I'm at least aware of what is coming down the pipe.
> I'm not too worried about this specific change, even though I don't really know
> if the reserved check and the dirtying are even necessary.
> It sounded like John's suggestion was to not do the PageReserved() check and just
> use put_user_pges_dirty() all the time.  John, is that incorrect?
> 

That's what I suggested at first. But then I saw at least one other place where 
this pattern is being used, and it shook my confidence. I don't clearly see what
the PageReserved check is protecting against here, but it's better to be
safe, and do things in two steps: step 1 is *only* convert from put_page()
to put_user_page(), and step 2 is to maybe remove the PageReserved() check,
once fully understood. 


thanks,
-- 
John Hubbard
NVIDIA

