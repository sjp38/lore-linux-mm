Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E67F7C76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 18:54:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8269E2190D
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 18:54:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="HArRmCgk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8269E2190D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C8106B0003; Mon, 22 Jul 2019 14:53:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99FAE6B0005; Mon, 22 Jul 2019 14:53:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B5248E0001; Mon, 22 Jul 2019 14:53:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5F56B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 14:53:59 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id l2so19820760ybl.18
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:53:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=dVEAb2CGI+Rcq3kPxf1ySX9mPnHE1aqM1bmhIjbORUc=;
        b=H1bcFrwHUgJJE4gy4mlY4dm3Lr44CDdMIJ5dj0mBfvfQesF/x9EuaTCf0F4oWsmHj5
         G8Ei3GxgTkiCyRWaCietldPFSIS4TV2bFeNcpU8VeXZzJXhuEvPgvuUbr37wCYbtDZPE
         a2I5hjn7qwvSj0zN0C+sSFj6MUYFcWgsPP/ejeUH4gBI0McVlP5EZqZ2eXa9qwPvqjP7
         lc/ocwJ5Nc6yXCQENrj97Z2/ZzKmOg9I6pdoEcauE58dvIIKCaLt0TxJrzNHLaTfBAs1
         nUgY1dSzelJgxGbArAKhYTqAQnt6WkUzfRdS7SmpcpEtGoG3xWTQwdhfJuCs+OGa62xk
         +G7w==
X-Gm-Message-State: APjAAAWTf+Wsz8jG0wX2NiQynQ2akgDDL6VxyAZJszK1LZnnSTbRKDtu
	TvkMMyZ90OWnz+qn/SKyHK07wIroa6D3qawxgoFnk8RKzFFdghH6dXBgao0YutQ5s6m5OR9zmhv
	VrIxngVbED5N9Yp+Lx1CXjsdrJ4tjvnXogFRmO/wGHWQj08V0CsUdkrdNH7HvGt+eKQ==
X-Received: by 2002:a81:a682:: with SMTP id d124mr45202968ywh.302.1563821639142;
        Mon, 22 Jul 2019 11:53:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7Hx12bg701kZ/cnvnk387EzvvhvHMLEJjH5DzuWUNcJ2kF6Qcz2SAIwfKp7cwR7Vll8hn
X-Received: by 2002:a81:a682:: with SMTP id d124mr45202934ywh.302.1563821638315;
        Mon, 22 Jul 2019 11:53:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563821638; cv=none;
        d=google.com; s=arc-20160816;
        b=bGi4Vnv4ora33srS2FicT+l8DgwRPZJNn99Pamp3NxOayvObw4U0uqhnf+NbT84omj
         FnATsWpQZNmSkwqifNygBvQe22xObD9Z51Ao61YSns93D+QQQ/SFJ+wTMTEEu69zPbUW
         oopsY4CBFYJuzeWsA537GAb/DkmkVtPTipZwlm/V60Kb5rjByErJKcHa8dn0xrX/0lqw
         350ugUkX2GeszZGlHuVsAVhOmJfs1TaiksoSn7p5fR9lpsYCSOi0d2wCQ9raO6PtghnG
         OBMM+d2CDgMaZrQRzNK+F8adBBsnGlIg3w+ZLmtaDiYQZFVxr8uwhaIEASZ7kERJKnnU
         +osQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=dVEAb2CGI+Rcq3kPxf1ySX9mPnHE1aqM1bmhIjbORUc=;
        b=ezKYupflaa9ijk0aLNbpZBTszVEXN54Zot0hr1drkP2gqkBYaeiYJmRO8oMGNUZq1M
         iGNjJNuBdyHnpDKM6FK7qlzgVUH2I33IwXfElI3XBQtlTjbOmAv2e7xcmUdgRN7L8rWR
         Ein2m1AN3yK3RX9kFK1rJUjQrlNJ8nThm3qfTPqFvqcDH5vHVzVETYdZGFdA32k1afDT
         HF/KhpfZPXM5YnChyT/EUZPv5Wk0E4xaWftXJ4JHQBS78uF047RCDDJZJzGIhi6AHJdg
         wj1rHNci5nEjMD0vzhEI5l6HB8TfAMw9CNMG2PGFu9jcHplnXuDxCZeNGs7m2y4x962e
         62Lg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=HArRmCgk;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id e9si2849537ybp.399.2019.07.22.11.53.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 11:53:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=HArRmCgk;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3606400002>; Mon, 22 Jul 2019 11:53:52 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 22 Jul 2019 11:53:55 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 22 Jul 2019 11:53:55 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 22 Jul
 2019 18:53:54 +0000
Subject: Re: [PATCH 1/3] drivers/gpu/drm/via: convert put_page() to
 put_user_page*()
To: Christoph Hellwig <hch@lst.de>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro
	<viro@zeniv.linux.org.uk>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?=
	<bjorn.topel@intel.com>, Boaz Harrosh <boaz@plexistor.com>, Daniel Vetter
	<daniel@ffwll.ch>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner
	<david@fromorbit.com>, David Airlie <airlied@linux.ie>, "David S . Miller"
	<davem@davemloft.net>, Ilya Dryomov <idryomov@gmail.com>, Jan Kara
	<jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Jens Axboe <axboe@kernel.dk>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Johannes Thumshirn
	<jthumshirn@suse.de>, Magnus Karlsson <magnus.karlsson@intel.com>, Matthew
 Wilcox <willy@infradead.org>, Miklos Szeredi <miklos@szeredi.hu>, Ming Lei
	<ming.lei@redhat.com>, Sage Weil <sage@redhat.com>, Santosh Shilimkar
	<santosh.shilimkar@oracle.com>, Yan Zheng <zyan@redhat.com>,
	<netdev@vger.kernel.org>, <dri-devel@lists.freedesktop.org>,
	<linux-mm@kvack.org>, <linux-rdma@vger.kernel.org>, <bpf@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
References: <20190722043012.22945-1-jhubbard@nvidia.com>
 <20190722043012.22945-2-jhubbard@nvidia.com> <20190722093355.GB29538@lst.de>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <397ff3e4-e857-037a-1aee-ff6242e024b2@nvidia.com>
Date: Mon, 22 Jul 2019 11:53:54 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190722093355.GB29538@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563821632; bh=dVEAb2CGI+Rcq3kPxf1ySX9mPnHE1aqM1bmhIjbORUc=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=HArRmCgkrni3Mv1zhHNTOrkORst1xu/RkKpSHN9NJ6eHvsCKnyilmR14o7Vu/72+2
	 KzGoGeJ5LPaTaA997Z1lTeEX5TN0QxgL9zU0E1stVph1kaJP/CjI3G/fZC7Su8uSDP
	 zQdMp40Hd3vz1tqkE44dAhr5RuD9olYTaUe61D28D1sEpt/q0j8DDbdv6B2ii7KaIW
	 3XKa/T3Q4mkn6zgOvtasGsucgAaQQ3F4SWgLkmtCnVrJI8UW8FhQBhBRF+eCjxAZDo
	 DjdQKgIytgBgEr6BmAqoJ/KeCGoQ826d60sYBB87S4A1fHrwdDnuUDjUmWCd/fqdhR
	 fU5s088Wpq8BA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/22/19 2:33 AM, Christoph Hellwig wrote:
> On Sun, Jul 21, 2019 at 09:30:10PM -0700, john.hubbard@gmail.com wrote:
>>  		for (i = 0; i < vsg->num_pages; ++i) {
>>  			if (NULL != (page = vsg->pages[i])) {
>>  				if (!PageReserved(page) && (DMA_FROM_DEVICE == vsg->direction))
>> -					SetPageDirty(page);
>> -				put_page(page);
>> +					put_user_pages_dirty(&page, 1);
>> +				else
>> +					put_user_page(page);
>>  			}
> 
> Can't just pass a dirty argument to put_user_pages?  Also do we really

Yes, and in fact that would help a lot more than the single page case,
which is really just cosmetic after all.

> need a separate put_user_page for the single page case?
> put_user_pages_dirty?

Not really. I'm still zeroing in on the ideal API for all these call sites,
and I agree that the approach below is cleaner.

> 
> Also the PageReserved check looks bogus, as I can't see how a reserved
> page can end up here.  So IMHO the above snippled should really look
> something like this:
> 
> 	put_user_pages(vsg->pages[i], vsg->num_pages,
> 			vsg->direction == DMA_FROM_DEVICE);
> 
> in the end.
> 

Agreed.

thanks,
-- 
John Hubbard
NVIDIA

