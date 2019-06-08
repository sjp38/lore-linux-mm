Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76CECC2BCA1
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 01:37:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13D82204FD
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 01:37:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="FjXO3DJQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13D82204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D6766B0271; Fri,  7 Jun 2019 21:37:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95F216B0273; Fri,  7 Jun 2019 21:37:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FF3F6B0276; Fri,  7 Jun 2019 21:37:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9706B0271
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 21:37:24 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id y205so3682717ywy.19
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 18:37:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=M2sIXUfHOY4caJ1/GSTT6zN+FY4XjAfM+4N4CfP5+0w=;
        b=pU8pRVitl2ypiFKUx+a5mQ+5umwg8GqAaFewT4z4cY1FemjfkmF+atVQg4jFb4RJbc
         jESEkJMFe7hCKKfhJrJ26NwLqxPaMJhub3fyht/8bGJ4Epzzs6PZidrDYseu/LwwO512
         XOOzxWElxp3D1dQwebvgPxvujbxIfATfjd5DG57rdxxXmkhSo229XLEzn7oANl5Zt8c6
         I445UVAbiT8pVvMaLE4REdaEfYkajYro+el8YV+jFhtVD89BtDaMoNNVGrId1mV2yN9i
         hdkBCOadBOvuz51I7XHKJVId6Fi3j1LwjyQWVBe+uB/10vb+ihnP6zXpbEm4Fpqurdgx
         Dh4A==
X-Gm-Message-State: APjAAAV82MWtwxjTaLTpOXIxDIGsULgXoQq8JlIC7lnFJ9C7Vc2kU8qM
	nFS9n3jKWKnTcL2jTlum7Bkp0tHrCbkYOFFKca5NRpmnwgehmE0HDL2tZWrb/+IPwilMsyLu1sm
	e0n8bcl1tfJjG3GwQb5vB2BZjYIYe577NQuugphEhan30BuF9NjsVbVxcRLX6rQQwvA==
X-Received: by 2002:a81:2343:: with SMTP id j64mr29700353ywj.224.1559957844152;
        Fri, 07 Jun 2019 18:37:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIhOAppQdYU/8XEG93tnIPUFffhEiT0c9tSZYYbFhuD007NVxGfV4DtcHJ3QOh64OVtS0W
X-Received: by 2002:a81:2343:: with SMTP id j64mr29700341ywj.224.1559957843599;
        Fri, 07 Jun 2019 18:37:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559957843; cv=none;
        d=google.com; s=arc-20160816;
        b=OohAomXRLVcFsha5cuKMZlwD4GEP9x7XNd1MuvPv5dEHK2mBZMu2XfC7hfzvlb4uX+
         5Zhqds/H177zeztgw1n+Uc5YPPKvbWNjpRRLshuF681IOYlfaVJFl8iIP1E4+BP2DxGV
         k/SOqlMBAro8/rEDMXPzDynyJzv3mDmIDXLS14ZeTao/Sup91wpUcYJ/yml0xNU0oyIy
         W9E2c+yy9M1iwz4xVfWyrEK1vBrMRU4uGw6jlXFzDX+du1aLxkc+esTiOxeMBThcuze9
         aFya4nLlBWoX0p2RoHvouXpQtXIEO/KEVP7NRlmUYRDFhO07PJcWupaMqHBvXuPaEWYi
         /2vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=M2sIXUfHOY4caJ1/GSTT6zN+FY4XjAfM+4N4CfP5+0w=;
        b=zdgaXCIeR0w7nYcb5wYRTQrYvVQPNzMWzBvQM17dhN1P7tAqbT5Zd5DmXycl+R8wYu
         TmA9SBCNmzGUSHd22w06Wnyi/7CNytk1PR5OHbKfne0JwsgBg8LLSUWcsylb7rKdd5sA
         bOBEwTFKZvIwHBo7VmEFIodGXliH0nARu1L7Zat4BXBsQInwmuXlAIvAbNKqLQc/mjO6
         TSKnAdskpmQdT4YYSOutgk9FZy/kUxTkmDMgBxYhvUF0sZjfOQaSPGZ975bvL2gNyh0n
         fM7KpJXwlYn9WZpwThVGjoAKH5marOxnxUqlF+Ti0cdUuRDXQJ4/bYi48H2Lr6UduE47
         hUKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=FjXO3DJQ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id d9si1065886ybb.4.2019.06.07.18.37.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 18:37:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=FjXO3DJQ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfb11520000>; Fri, 07 Jun 2019 18:37:22 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 18:37:22 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 07 Jun 2019 18:37:22 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sat, 8 Jun
 2019 01:37:22 +0000
Subject: Re: [PATCH v2 hmm 01/11] mm/hmm: fix use after free with struct hmm
 in the mmu notifiers
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: Jerome Glisse <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>,
	<Felix.Kuehling@amd.com>, <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-2-jgg@ziepe.ca>
 <9c72d18d-2924-cb90-ea44-7cd4b10b5bc2@nvidia.com>
 <20190607123432.GB14802@ziepe.ca>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <771c9b7b-983a-934b-a507-76aa0e8aceaf@nvidia.com>
Date: Fri, 7 Jun 2019 18:37:22 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190607123432.GB14802@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559957842; bh=M2sIXUfHOY4caJ1/GSTT6zN+FY4XjAfM+4N4CfP5+0w=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=FjXO3DJQC3v99wu3gjrQndwbgGxJGQ3SEeqG6TFvKt1w8r53KkjAm5XGISySd7/Dm
	 KLix8M+qphUJiEIxz8Y3hQB0oYZaiIAeoBkX9pa0tzwdBg2beA71/hN66V58sKJ/Gl
	 GsBt0SeJWOAr27yT3YO0qWzVqE+qm57g4x2hJ0tPPIcDxmY0MVfpMNRJpBiNZRA5+O
	 Hlr8TVddXcJqFVeZwSJrflfkrUQ/oDXy6uzdvHLmWUjJrkAsi7dR/wNzUdJdnlq0ll
	 D7efeHpKaM+iJpMEls+jYjF7AMwgFUPpMleyuHXmzsG1896UdCqXNxclh3QfcubGCq
	 PE9i3yKPcaVHQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/7/19 5:34 AM, Jason Gunthorpe wrote:
> On Thu, Jun 06, 2019 at 07:29:08PM -0700, John Hubbard wrote:
>> On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
>>> From: Jason Gunthorpe <jgg@mellanox.com>
>> ...
>>> @@ -153,10 +158,14 @@ void hmm_mm_destroy(struct mm_struct *mm)
>>>  
>>>  static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>>>  {
>>> -	struct hmm *hmm = mm_get_hmm(mm);
>>> +	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>>>  	struct hmm_mirror *mirror;
>>>  	struct hmm_range *range;
>>>  
>>> +	/* hmm is in progress to free */
>>
>> Well, sometimes, yes. :)
> 
> It think it is in all cases actually.. The only way we see a 0 kref
> and still reach this code path is if another thread has alreay setup
> the hmm_free in the call_srcu..
> 
>> Maybe this wording is clearer (if we need any comment at all):
> 
> I always find this hard.. This is a very standard pattern when working
> with RCU - however in my experience few people actually know the RCU
> patterns, and missing the _unless_zero is a common bug I find when
> looking at code.
> 
> This is mm/ so I can drop it, what do you think?
> 

I forgot to respond to this section, so catching up now:

I think we're talking about slightly different things. I was just
noting that the comment above the "if" statement was only accurate
if the branch is taken, which is why I recommended this combination
of comment and code:

	/* Bail out if hmm is in the process of being freed */
	if (!kref_get_unless_zero(&hmm->kref))
		return;

As for the actual _unless_zero part, I think that's good to have.
And it's a good reminder if nothing else, even in mm/ code.

thanks,
-- 
John Hubbard
NVIDIA

