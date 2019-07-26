Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53251C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 01:24:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED715229F9
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 01:24:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="PQnzJX5x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED715229F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 792738E0003; Thu, 25 Jul 2019 21:24:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 742D78E0002; Thu, 25 Jul 2019 21:24:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 659CB8E0003; Thu, 25 Jul 2019 21:24:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 46E0B8E0002
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 21:24:22 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id f11so38567719ywc.4
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 18:24:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=QKXKINFukbwLIIsnFYM0gxF2tKYcHndEGgwougXKa7I=;
        b=ObW9n6ti93YazbWjxRHSGqfCzTJUMcTVJqpFBNKeDUH8OQKM0qe6/z4JwJDk5aKd01
         Z5yiyBIE0IHxNvIj0R4ryaNdTtZ8SFDsjKkwXdD8BdrPDVebRSGvma1kmK3fT0wRSpPp
         EOHqmT4w5NoIDlGnSDvYocyvDGPB9wp60AdaVQWtfw0sYY+2rUNL7TImJ/us16cUdmqK
         aYc6LsW74KbYDC2014aFegEaZ/ZEmS+XUUY3MbO644AxpVq1g0gr/028K+W59gLNmiHk
         sTyBwvF6AWql4BI3Ty8kgJLI25cjcMiYxikseGDfytAhLzfeyciEemvM1d8jieqVFu/X
         21Ow==
X-Gm-Message-State: APjAAAWQaE39y2dmvEiD9AAJv9g/MII/A2GMoVto7EB7tkBhEU4cUC5u
	uV6IY+1nT/7VFAAA6d5p4jNEgIhG1dAC3AuPoe47HABwHVxKEAe11xHb7Y6ydjD+iboDjXR+5CI
	UtMyGcQj+OBvs8Loa4DgIYoqB727i/Ip9pagiBn5On9KXVoh+1/RALRNcU4Cmo4kIDw==
X-Received: by 2002:a25:a2cb:: with SMTP id c11mr43255448ybn.175.1564104261960;
        Thu, 25 Jul 2019 18:24:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOdZjMShkCKH2IB5snWms3vztYlSLm9b4cJ0np1Vl8YZqwbYohGDlw+C5HR1mlUl8mgUtq
X-Received: by 2002:a25:a2cb:: with SMTP id c11mr43255420ybn.175.1564104261294;
        Thu, 25 Jul 2019 18:24:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564104261; cv=none;
        d=google.com; s=arc-20160816;
        b=ApMGA9j7DZmXVkk/T6IRkzIwYzKgadz8ntoHxl5Hpg7/QSivgWE699qihQsDLWD4hr
         l45rOOdqCm508WCkS9slkq0zFWqzdnV5lSClcKyct8ydXJQfA60kP6e9oAOpRa4dbqz5
         D27p6LCBZKtIzUyDhthcecV8j3EkDr6zzhTyfYMXH4goGn0viaxkNNBc/VQmsbGIryhp
         PM+HVSB5Ppgb7GfY3Xq9ayvqmWY8ynWAPF/50MsVvPHeECzynxZrx2Dvxa8Vi/vnvcDY
         RjMoyh2UwehPsAyJU5hGN8pZKHYmXKz4y9TyLdatFLRaAadyrFxqMsQES4jam7Sns2il
         RNcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=QKXKINFukbwLIIsnFYM0gxF2tKYcHndEGgwougXKa7I=;
        b=BYZQF3gzWxROaMT6V3TNKzTH5xXOoZ/dawS2XBrpd8vWwEDBllPd1Y73WLrQ9AbIkL
         MuJFF4ExHtCX6a1M9s7GCEK5g76THViBmKHmYvIM2lMNmlEr9LTOntiApUnKEmJMlOa8
         01nvSUVOl7eXfy86I+sCUMX9Nz4M2m5hEzEdG/dIucheL4w71f9XvQpnhprkMjqJXqtl
         VDCnOqxVa/VZhvl2AZGF0ISapAz8QObjPlEs26w4L8nIQRCKkq2+Vyuk/m0rNcIKJOqf
         WfGd2gx1FYw9fO+CYcIgz7CoGZ+cSRcX5D83RaEJa9rIVdy7LwNZCFkrKkkOplMmDsk4
         l/VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=PQnzJX5x;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id t188si11249600ywf.84.2019.07.25.18.24.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 18:24:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=PQnzJX5x;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3a563e0000>; Thu, 25 Jul 2019 18:24:14 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 25 Jul 2019 18:24:17 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 25 Jul 2019 18:24:17 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 26 Jul
 2019 01:24:16 +0000
Subject: Re: [PATCH 00/12] block/bio, fs: convert put_page() to
 put_user_page*()
To: Bob Liu <bob.liu@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
CC: Alexander Viro <viro@zeniv.linux.org.uk>, Anna Schumaker
	<anna.schumaker@netapp.com>, "David S . Miller" <davem@davemloft.net>,
	Dominique Martinet <asmadeus@codewreck.org>, Eric Van Hensbergen
	<ericvh@gmail.com>, Jason Gunthorpe <jgg@ziepe.ca>, Jason Wang
	<jasowang@redhat.com>, Jens Axboe <axboe@kernel.dk>, Latchesar Ionkov
	<lucho@ionkov.net>, "Michael S . Tsirkin" <mst@redhat.com>, Miklos Szeredi
	<miklos@szeredi.hu>, Trond Myklebust <trond.myklebust@hammerspace.com>,
	Christoph Hellwig <hch@lst.de>, Matthew Wilcox <willy@infradead.org>,
	<linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	<ceph-devel@vger.kernel.org>, <kvm@vger.kernel.org>,
	<linux-block@vger.kernel.org>, <linux-cifs@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
	<samba-technical@lists.samba.org>, <v9fs-developer@lists.sourceforge.net>,
	<virtualization@lists.linux-foundation.org>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
 <8621066c-e242-c449-eb04-4f2ce6867140@oracle.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <88864b91-516d-9774-f4ca-b45927ac4556@nvidia.com>
Date: Thu, 25 Jul 2019 18:24:16 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <8621066c-e242-c449-eb04-4f2ce6867140@oracle.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564104254; bh=QKXKINFukbwLIIsnFYM0gxF2tKYcHndEGgwougXKa7I=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=PQnzJX5xz5ikEiwrLKM8WsALivZ88h6rrpD5As08defMJIkdP+u4c4qNjj9VJ4tt7
	 nwv4lirmE3zmhFpqjjtQZ51fomZqIx7+Z5K/hIMgtkne3B/lAraavguLY6SA4HXRUi
	 W4SUZZlps8N4rFxPowCNQkldeoVK/fBECjRShYxjtzJx8yvDnyDgvLG3XjCMQgN0HE
	 j0RlPZtSamPdX7GpRyHeIVO0klar+OAGzPGoJx+oiz7wZ/GbisDHnJkR/hoyBrvfQa
	 +HuyKaWvKrWvHxopvgEQcRa8uv0hWn0N0u4M8vDDfrnuUHyPlJZxMytFt1GB3uPYBU
	 1cdZ+M2GXGeqw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/24/19 5:41 PM, Bob Liu wrote:
> On 7/24/19 12:25 PM, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> Hi,
>>
>> This is mostly Jerome's work, converting the block/bio and related areas
>> to call put_user_page*() instead of put_page(). Because I've changed
>> Jerome's patches, in some cases significantly, I'd like to get his
>> feedback before we actually leave him listed as the author (he might
>> want to disown some or all of these).
>>
> 
> Could you add some background to the commit log for people don't have the context..
> Why this converting? What's the main differences?
> 

Hi Bob,

1. Many of the patches have a blurb like this:

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

...and if you look at that commit, you'll find several pages of
information in its commit description, which should address your point.

2. This whole series has to be re-worked, as per the other feedback thread.
So I'll keep your comment in mind when I post a new series.

thanks,
-- 
John Hubbard
NVIDIA

