Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 346F5C28EBD
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 00:16:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5467206E0
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 00:16:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="E6X87sdu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5467206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 329F16B0266; Sun,  9 Jun 2019 20:16:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DAD76B0269; Sun,  9 Jun 2019 20:16:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CA726B026A; Sun,  9 Jun 2019 20:16:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id F04536B0266
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 20:16:10 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id b63so8786218ywc.12
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 17:16:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=xcBhzlVW6R3gFNBTrQqz4x9pqkklyqjUIKM1o42kpyM=;
        b=F3uV027NVLiwrfHfybEBF64aXZCNsJAU1FkJx1dcbXTjBML5LO0TYmhg9EVYvU4f8l
         Awc5l45e1PnWUtyc3UMcAsLoQzbl4af9twRIzOaqSSsXUpLHun0VF8GuDm13Ys5apOrK
         uwrLqpWWpobot3LIHXWrT3/ZrtaJhP6XQbmSkw9Zhe8gYaFvmoXYXphPVqHqhEbIcAKq
         5nZOgV3q3B3LvVNdqXAPBYaxRT/IodUdl5bzYqTlWhALLHS+wBBypWptvUqvfQH/XaGQ
         nmufpfPUf6tGHLiVn10fTvT4Svx3bnwwwCyEm18TFlRNGwo1szIdaL+bvaILj+L1OtMw
         DfDg==
X-Gm-Message-State: APjAAAUdC3buZrRrcMtE3xsby7lN65w1MqhmtXNN4x1H5t7S3Ya2PDxZ
	v6Qf0ZG9mgkKV3ambd3Acq7lM5C+2KtLI6tB5ZR3TpS15b7jaxoo/o0bLbkMnV4FuTfBE7fiSCU
	dWov4F5BHEeV6I9D+JVuDqin7XnzWytms7lKWYY3ySpbgbiBEO79uzBKFEE+lsCG88w==
X-Received: by 2002:a81:2186:: with SMTP id h128mr16047015ywh.467.1560125770636;
        Sun, 09 Jun 2019 17:16:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQNhWTsVzj1/+1jW+iAJJyvCVTYTUr2HWBKL47dOBNa3deZc9HnRZDgvh9B1+yfLxnIT9x
X-Received: by 2002:a81:2186:: with SMTP id h128mr16046999ywh.467.1560125769874;
        Sun, 09 Jun 2019 17:16:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560125769; cv=none;
        d=google.com; s=arc-20160816;
        b=Ej/77O24Kb7wFLBB2/vwUfKaxDfv+l5+zM6+qgPYLNsrW/1bxQ/hfhcMx9gXqjhQSr
         rbGIZqtR8DwtTRsFZtf6rz2uBhnlhdkOshQOjY7B6gedKUoOs4RmxMlqSgdksTId52ph
         X1AiWeTJhllhXYKIgO1T6g2m6XuRXDy2L4BffykRZMRy5AeKtBs1vjcScGQTHGq4C+Rt
         cmpzdsYpB2Ki04ehargs0l7AIye5pYsxyShYfhop8xYr70/uN3VwWOVpWPT2p4EhVMmJ
         LkMxDHhM0pOzLTRYN4HbmPz7B6pixRri95AjDU1ufylBW9tPotszhBztp1/oxZjsQFdd
         IANQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=xcBhzlVW6R3gFNBTrQqz4x9pqkklyqjUIKM1o42kpyM=;
        b=n+EJ7qTOTul9m6s+kCi6BXJ1lDMN1qf7FhGjvtJm+F87lFpNOG3sE1cK8DwgtIT1D0
         P5jc2iT2sEAoAgKHgags5V+VNykfQBbzFQHpmRmcTFHSa9S03y/FeQscMPFkOl2zKrUT
         +vD6rNOsTSaVgdF9SzMfRpmFJ6UBipCtHXONZI9U25YLq/hPGq4ARsnScOnCf1PMsOZm
         XZ5AT/DsVs3t8p3w0TdqCAAS19edQVv1e0ptCpmuSHD0HJZH5jPTzNyYjlkmLhgfAs+t
         UOrq0tYNMllqs5befcD/8yXJU6ioSu/32ByMJy2jknlb/alPlO0WmT9njL81+p8mYwnc
         HKCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=E6X87sdu;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id l64si3009603ybb.135.2019.06.09.17.16.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 17:16:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=E6X87sdu;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfda1490000>; Sun, 09 Jun 2019 17:16:09 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Sun, 09 Jun 2019 17:16:08 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Sun, 09 Jun 2019 17:16:08 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 10 Jun
 2019 00:16:07 +0000
Subject: Re: [RFC] mm/hmm: pass mmu_notifier_range to
 sync_cpu_device_pagetables
To: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@infradead.org>
CC: Ralph Campbell <rcampbell@nvidia.com>, Jerome Glisse <jglisse@redhat.com>,
	"Felix.Kuehling@amd.com" <Felix.Kuehling@amd.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
References: <20190608001452.7922-1-rcampbell@nvidia.com>
 <20190608091008.GC32185@infradead.org> <20190608114133.GA14873@mellanox.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <2be4987a-eede-c864-c69c-382698641d25@nvidia.com>
Date: Sun, 9 Jun 2019 17:16:07 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190608114133.GA14873@mellanox.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560125769; bh=xcBhzlVW6R3gFNBTrQqz4x9pqkklyqjUIKM1o42kpyM=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=E6X87sdu/LBn60CmN02yYjx0e4LyL+XQ/EpyrSmFXI2fQ5Zb+Gh+JZPwwwFyhR9/T
	 DR8oJjqqMJ9r+VrKVwUG2o3JczcXZgsbMi07n3RJ7p29qYbn9AWfErKW4mHKk2FRpv
	 7+ufnoxySLzKTlkINeZdmFMs9VXRW0J/FG4cJKrSvuAOgP6EdI3FxQrq6Z4C9QnMCw
	 zKTDzopKQehlzGuMNc9bmY5FRAUDEloQCDHXi95cyZWmUE2V0UpuPOonrNC/A7AMs4
	 gdRNwHonTHKYQRUAtWc6IMPZ4/G46btrcTuhnh6Q5ec1u46swkktkF4Xs0TKPrStrX
	 C0pK3ycdPHRrA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/8/19 4:41 AM, Jason Gunthorpe wrote:
> On Sat, Jun 08, 2019 at 02:10:08AM -0700, Christoph Hellwig wrote:
>> On Fri, Jun 07, 2019 at 05:14:52PM -0700, Ralph Campbell wrote:
>>> HMM defines its own struct hmm_update which is passed to the
>>> sync_cpu_device_pagetables() callback function. This is
>>> sufficient when the only action is to invalidate. However,
>>> a device may want to know the reason for the invalidation and
>>> be able to see the new permissions on a range, update device access
>>> rights or range statistics. Since sync_cpu_device_pagetables()
>>> can be called from try_to_unmap(), the mmap_sem may not be held
>>> and find_vma() is not safe to be called.
>>> Pass the struct mmu_notifier_range to sync_cpu_device_pagetables()
>>> to allow the full invalidation information to be used.
>>>
>>> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
>>>
>>> I'm sending this out now since we are updating many of the HMM APIs
>>> and I think it will be useful.
>>
>> This is the right thing to do.  But the really right thing is to just
>> kill the hmm_mirror API entirely and move to mmu_notifiers.  At least
>> for noveau this already is way simpler, although right now it defeats
>> Jasons patch to avoid allocating the struct hmm in the fault path.
>> But as said before that can be avoided by just killing struct hmm,
>> which for many reasons is the right thing to do anyway.
>>
>> I've got a series here, which is a bit broken (epecially the last
>> patch can't work as-is), but should explain where I'm trying to head:
>>
>> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/hmm-mirror-simplification
> 
> At least the current hmm approach does rely on the collision retry
> locking scheme in struct hmm/struct hmm_range for the pagefault side
> to work right.
> 
> So, before we can apply patch one in this series we need to fix
> hmm_vma_fault() and all its varients. Otherwise the driver will be
> broken.
> 
> I'm hoping to first define what this locking should be (see other
> emails to Ralph) then, ideally, see if we can extend mmu notifiers to
> get it directly withouth hmm stuff.
> 
> Then we apply your patch one and the hmm ops wrapper dies.
> 

This all makes sense, and thanks for all this work to simplify and clarify
HMM. It's going to make it a lot easier to work with, when the dust settles.

thanks,
-- 
John Hubbard
NVIDIA

