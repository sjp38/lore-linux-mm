Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEC65C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 03:46:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4EFB20880
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 03:46:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="caNdsK+H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4EFB20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 347296B0007; Wed,  7 Aug 2019 23:46:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F7716B0008; Wed,  7 Aug 2019 23:46:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1985D6B000A; Wed,  7 Aug 2019 23:46:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6BCF6B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 23:46:54 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k20so56886519pgg.15
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 20:46:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=oa/UlzMF1BY8hfwSUK2E34E4BK86wv0rI2GL87o8kWQ=;
        b=rvbhQbEacdTnR97fMdvGnbD+1nG87GwlZLWn8zbNMqaF4rI7RW0OQoyiP92D49jZoD
         Ygmt5g7wEYTtql3+mRhNmKaRNjJLbNyssqzjPoygPXDY2yC4mHQQDM8keWBV9RFbfhrQ
         TXTzn7mrgjHluQmbqrqum4BXwTqVcZpZdQ9rUq4NVLOGyIjej+/HNFUB5RkAZ8emqhvZ
         xl6uEn3a9OFgddEm2UDSMahEXKTkqhCq6+M4WT+KAutdMNq2hDFMrkNLZDw6gGJOWVZw
         SfEOz1s9nHOLU44x6b5xSaqkhIVqcfBWqrwWBOn3N8caaxDaGJEaqeRZ7SAkDYTxpP2+
         fnKQ==
X-Gm-Message-State: APjAAAXJ1KUlCl/ARDH5LUtejV7lpP4LG6z8gdjmZ0yoV51U1aigPz+c
	r6MCIbNCBAQNnRA4pPc2/B0l0Osnkg95DYfW6LAkJoDiWd2bIjOL348M7n7TWgAhFitJnji0lmp
	EoCT4iSxeOuMBVkMamBV0t4mxUkoXKGCrGAlUI7e/Q5LruJXpXCNIbExWgGRyprAXRA==
X-Received: by 2002:a17:902:8a8a:: with SMTP id p10mr11666748plo.88.1565236014409;
        Wed, 07 Aug 2019 20:46:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUP5wJqs361YHVftUul6hu1aT6fjISExleC+8XLk/seCtrcVVyn1BcgK+Dz7JGFkiErAD4
X-Received: by 2002:a17:902:8a8a:: with SMTP id p10mr11666694plo.88.1565236013456;
        Wed, 07 Aug 2019 20:46:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565236013; cv=none;
        d=google.com; s=arc-20160816;
        b=sRsWvoMgUhmZqmva4t2R008r4xz0py481WpmOgbrWfv2lKwggKyEUO+02hR7sl/Ev1
         hs6ilyt6ut2hSjq7QPuH5uOh3yqXc1r+TFe1jmiccFSKjo0spClhXFPPGR2mCSSP2Ln8
         FXM+o2kIRtgT+ZCmFkB9kd4pvuSodhXkAXiCU/Ez1hqXXs/277Oja9uSm7UUyMNbg9V6
         qmN2bSk3NOK7Jz/U6Anpowi+xo+tWN0EO641n2PGK5pjWpyjxpdLHkktZS/j1rBDPh9Y
         hcR67hsvz9ILA5BDbgKo8ypiUAL1KkHfb2VPDYnpodTI802h3mCXrPAVIrp0/1pecXyY
         KlpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=oa/UlzMF1BY8hfwSUK2E34E4BK86wv0rI2GL87o8kWQ=;
        b=d/X7nhdt2qtLcL8Do3owMkqquaTD6kgEkn66TYWidnWwMu3FkL6vQtJSkdj2R6DUYl
         OFK9dFcZlrxKEQMn+F/4fKZ8IVKfTaZVTYK6mKiU+hnyqcOgqAv2y53/aEMNjYl/rP7C
         udAT8lyLT0YxPNu5Mb+MO2eooeR37eGZsVXmqIRwICZHIYI67iBGdY3dsjXqwmCErY9G
         wZ1nBXrZ/6GS1yRvDd9A3lYZb4TEvP8FLMt2PAUOykxtzw7armyRjz/dKU/a/KkzUW0g
         ScE61HfQJh8PE2jKT93X1THZcDNszVL8uJIWEAQAg9Bj34/vt+it4IIxOTypuRvhhhau
         xRvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=caNdsK+H;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id w11si55217484pgk.384.2019.08.07.20.46.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 20:46:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=caNdsK+H;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4b9b2c0000>; Wed, 07 Aug 2019 20:46:53 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 07 Aug 2019 20:46:51 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 07 Aug 2019 20:46:51 -0700
Received: from ngvpn01-164-84.dyn.scz.us.nvidia.com (172.20.13.39) by
 HQMAIL107.nvidia.com (172.20.187.13) with Microsoft SMTP Server (TLS) id
 15.0.1473.3; Thu, 8 Aug 2019 03:46:50 +0000
Subject: Re: [PATCH 00/34] put_user_pages(): miscellaneous call sites
To: Ira Weiny <ira.weiny@intel.com>, Michal Hocko <mhocko@kernel.org>
CC: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Andrew
 Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<ceph-devel@vger.kernel.org>, <devel@driverdev.osuosl.org>,
	<devel@lists.orangefs.org>, <dri-devel@lists.freedesktop.org>,
	<intel-gfx@lists.freedesktop.org>, <kvm@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-block@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>, <linux-fbdev@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-media@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <linux-rpi-kernel@lists.infradead.org>,
	<linux-xfs@vger.kernel.org>, <netdev@vger.kernel.org>,
	<rds-devel@oss.oracle.com>, <sparclinux@vger.kernel.org>, <x86@kernel.org>,
	<xen-devel@lists.xenproject.org>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802091244.GD6461@dhcp22.suse.cz>
 <20190802124146.GL25064@quack2.suse.cz>
 <20190802142443.GB5597@bombadil.infradead.org>
 <20190802145227.GQ25064@quack2.suse.cz>
 <076e7826-67a5-4829-aae2-2b90f302cebd@nvidia.com>
 <20190807083726.GA14658@quack2.suse.cz>
 <20190807084649.GQ11812@dhcp22.suse.cz>
 <20190808023637.GA1508@iweiny-DESK2.sc.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <e648a7f3-6a1b-c9ea-1121-7ab69b6b173d@nvidia.com>
Date: Wed, 7 Aug 2019 20:46:50 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190808023637.GA1508@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565236013; bh=oa/UlzMF1BY8hfwSUK2E34E4BK86wv0rI2GL87o8kWQ=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=caNdsK+H718e8IaMHboxAo7N5kSDjdO0aPPP7qMD/uXC6LIuseTU5yocCYztoyhLS
	 A8theOeNn9DFbaKSyltNZVy/0B3VPZPEr/7HwHnfipqBI1W9E/1RXgk4cYboMCcd2v
	 K1AubOjDxM7RJmlTd1q1ZO/DARZkbUQqfdDa7AtzCGn8CgjUMfboXlhtit5supcfVJ
	 t3SF5BlWoOZ+ktHQ+Gy0QbysjhXaepl4K0zI9Pv3YsYauPp0cOOqMsTfKIdJYZp847
	 qDjXLEk745BEl9a58mwF6yYg4Z7StCZBL718mfzBDBCPCwNZsIoTbJbWCkazTDd50+
	 NvHzitKycTv2g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/7/19 7:36 PM, Ira Weiny wrote:
> On Wed, Aug 07, 2019 at 10:46:49AM +0200, Michal Hocko wrote:
>> On Wed 07-08-19 10:37:26, Jan Kara wrote:
>>> On Fri 02-08-19 12:14:09, John Hubbard wrote:
>>>> On 8/2/19 7:52 AM, Jan Kara wrote:
>>>>> On Fri 02-08-19 07:24:43, Matthew Wilcox wrote:
>>>>>> On Fri, Aug 02, 2019 at 02:41:46PM +0200, Jan Kara wrote:
>>>>>>> On Fri 02-08-19 11:12:44, Michal Hocko wrote:
>>>>>>>> On Thu 01-08-19 19:19:31, john.hubbard@gmail.com wrote:
  [...]
> Before I go on, I would like to say that the "imbalance" of get_user_pages()
> and put_page() bothers me from a purist standpoint...  However, since this
> discussion cropped up I went ahead and ported my work to Linus' current master
> (5.3-rc3+) and in doing so I only had to steal a bit of Johns code...  Sorry
> John...  :-(
> 
> I don't have the commit messages all cleaned up and I know there may be some
> discussion on these new interfaces but I wanted to throw this series out there
> because I think it may be what Jan and Michal are driving at (or at least in
> that direction.
> 
> Right now only RDMA and DAX FS's are supported.  Other users of GUP will still
> fail on a DAX file and regular files will still be at risk.[2]
> 
> I've pushed this work (based 5.3-rc3+ (33920f1ec5bf)) here[3]:
> 
> https://github.com/weiny2/linux-kernel/tree/linus-rdmafsdax-b0-v3
> 
> I think the most relevant patch to this conversation is:
> 
> https://github.com/weiny2/linux-kernel/commit/5d377653ba5cf11c3b716f904b057bee6641aaf6
> 

ohhh...can you please avoid using the old __put_user_pages_dirty()
function? I thought I'd caught things early enough to get away with
the rename and deletion of that. You could either:

a) open code an implementation of vaddr_put_pages_dirty_lock() that
doesn't call any of the *put_user_pages_dirty*() variants, or

b) include my first patch ("") are part of your series, or

c) base this on Andrews's tree, which already has merged in my first patch.


thanks,
-- 
John Hubbard
NVIDIA

