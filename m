Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD5A5C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 23:24:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7638B227BF
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 23:24:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="FMl+YlnD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7638B227BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 141796B0003; Tue, 23 Jul 2019 19:24:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11A276B0005; Tue, 23 Jul 2019 19:24:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 008A88E0002; Tue, 23 Jul 2019 19:24:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id D4B0A6B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 19:24:27 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id n139so33206638ywd.22
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 16:24:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=Dc+54X4TKuVoIQ6IGOnhUFUhE0Dy4dW4jkSZ2LHVHns=;
        b=CXcJ7vo4ZYgCte3IbVJkzxfaPQoqbDIyFTq85yHuUAtq5WJ5XPRjcdwqm5rffUFTJ+
         YBKvCA6WnwcNmlIYXehCzqUNh3OspQEfeSI0HuMpwZ4CPMi/8a5qgigrRQFYy/y9PhHk
         fKs6/k6Nw2DMYc+xg9LrLsIt16VbKdjIZ3rqWPgjt2d9DaAwuHA22KD3ekVWptmFJbhI
         I+dixV4K7fEYKH5X14/ZBHhpXDQkRdCDVzNFGVEtBmY/epf1DRKKT/jGotS2ncJtu8Wa
         Nps/qOZ+kJkULOoLsQJ4Ra66QRolAA3cJqo8Pa9s4jOBfnd/lPPGHZ8J/1giLJkPPp/a
         IikA==
X-Gm-Message-State: APjAAAUKXo1piuE2AEXMf0lTuHaiJmxYilnGCjUVKWUgSoEZi6zkwMdt
	BJyJTQCC4QFU9WK9eip601+kSaTaWJ8IfOyfW87iAdvOnvLJZGrlYcQL8bJp6WNWcUoLqg6rG9g
	wHlX0keifmw/5Oo0+6W+AAMSLEEUXUajs+Ui7NjKoql20Lz+P1fsPXlNY33kyeW1B4w==
X-Received: by 2002:a25:5f44:: with SMTP id h4mr49320162ybm.471.1563924267596;
        Tue, 23 Jul 2019 16:24:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvvsC1VSdVwC+eknNWehjEtYjNT+yOkUizpHTDTFYg6+Hhsu4YiZXotZ1VLHRjmkq/LSyO
X-Received: by 2002:a25:5f44:: with SMTP id h4mr49320125ybm.471.1563924266820;
        Tue, 23 Jul 2019 16:24:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563924266; cv=none;
        d=google.com; s=arc-20160816;
        b=yjMpiIMAVNh1MyDd9NISVDvZ5T5TNRgWWQYifX/KBozz+gBOn4jteLOOcL/80sM852
         Uq9GwW4AIiObLa8uczxzE/GFsnhYSFluO1NyEClehpWBao3estmhT1GFhud2HOddL17I
         +G8OgSEcTJhb35M4h+IhlKVh2WKtuS3sDBtcNhHPjLFeX64T/Jh09RcHUY7Up4K2Jaik
         c2XN6RVwj1K933TGECbCkt2TbslNQtmWn5puQU9YdkmmCDXJsPkvT9O1IZYAgi8bFZEy
         YWy4M/NOtAoO9hSFzjwRSafzYlMD/gAzBFf3pW8oJHM16r/wjjKunku1rHSGTxey3uyd
         neSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=Dc+54X4TKuVoIQ6IGOnhUFUhE0Dy4dW4jkSZ2LHVHns=;
        b=MhJtESnI+O60zXY2CbLGDAYlNsb08gYrSNzwYdQIdjoJcjm/dGC7ycF7T2XI64mtdf
         bpniEV+CE4aIOFDZl6uYQTc8+76U7Utp1C+xQtLAq0Pqk2ag/+SlggCOFrNBHcTAepCb
         4X1WhfSK/v/ZR+FMgJysq07dhVKuuArQ7jgXbgS3/9vOojzcZIsNOQRn66s0WAdnyrto
         0MRhOkukmTgzltcwhJTVcroZyu678XLL06kiWp4SnglOo3vL+aLF48hSXHOrMTPceM+K
         KEGp+noL3YzzjdL1c+grsMFSmeAvbNzDN4jPauYQVt+N33Qz705z5wPdaR7+/6ipkClG
         Z0HQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=FMl+YlnD;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id f20si16167247yba.3.2019.07.23.16.24.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 16:24:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=FMl+YlnD;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3797290000>; Tue, 23 Jul 2019 16:24:25 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 23 Jul 2019 16:24:24 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 23 Jul 2019 16:24:24 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 23 Jul
 2019 23:24:24 +0000
Subject: Re: [PATCH 3/3] net/xdp: convert put_page() to put_user_page*()
To: Ira Weiny <ira.weiny@intel.com>
CC: <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?=
	<bjorn.topel@intel.com>, Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig
	<hch@lst.de>, Daniel Vetter <daniel@ffwll.ch>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, David Airlie
	<airlied@linux.ie>, "David S . Miller" <davem@davemloft.net>, Ilya Dryomov
	<idryomov@gmail.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jens Axboe <axboe@kernel.dk>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Johannes Thumshirn
	<jthumshirn@suse.de>, Magnus Karlsson <magnus.karlsson@intel.com>, Matthew
 Wilcox <willy@infradead.org>, Miklos Szeredi <miklos@szeredi.hu>, Ming Lei
	<ming.lei@redhat.com>, Sage Weil <sage@redhat.com>, Santosh Shilimkar
	<santosh.shilimkar@oracle.com>, Yan Zheng <zyan@redhat.com>,
	<netdev@vger.kernel.org>, <dri-devel@lists.freedesktop.org>,
	<linux-mm@kvack.org>, <linux-rdma@vger.kernel.org>, <bpf@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
References: <20190722223415.13269-1-jhubbard@nvidia.com>
 <20190722223415.13269-4-jhubbard@nvidia.com>
 <20190723002534.GA10284@iweiny-DESK2.sc.intel.com>
 <a4e9b293-11f8-6b3c-cf4d-308e3b32df34@nvidia.com>
 <20190723180612.GB29729@iweiny-DESK2.sc.intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <69540e85-b527-0252-7b29-8932660af72d@nvidia.com>
Date: Tue, 23 Jul 2019 16:24:23 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723180612.GB29729@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563924265; bh=Dc+54X4TKuVoIQ6IGOnhUFUhE0Dy4dW4jkSZ2LHVHns=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=FMl+YlnDhGCsZKKh1L0ErV+31siNAXGqpbM4Ti099eQ263WNqONoZoDhA6w28dloW
	 DANKq7E2Y7kdWPUACeMGcsz7IGCwEWqiwPgDnX3E9DHqqaxxYj9TrmIKWYGcLWA8z9
	 HaYbTpYicIHv06kxhQ58/gdGYse2x3h25DFKRTKYtQq+80JPY4IzGMpBTYSaFvHkoA
	 7F9/p/2HEcQ7syxo9toMK0sf5uUtUlNauO/KxNX+D2TkcJKNWZP3//+ZXgl5mcNywg
	 K1EWHc3E5G7xnnEUtcQBaKfZD5VJFBdwU+bLpLJtcvUt/rKIgSGElbmpHYwBZFPLKu
	 YnW6V/fpJl4Ag==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/23/19 11:06 AM, Ira Weiny wrote:
> On Mon, Jul 22, 2019 at 09:41:34PM -0700, John Hubbard wrote:
>> On 7/22/19 5:25 PM, Ira Weiny wrote:
>>> On Mon, Jul 22, 2019 at 03:34:15PM -0700, john.hubbard@gmail.com wrote:
...
>> Obviously, this stuff is all subject to a certain amount of opinion, but I
>> think I'm on really solid ground as far as precedent goes. So I'm pushing
>> back on the NAK... :)
> 
> Fair enough...  However, we have discussed in the past how GUP can be a
> confusing interface to use.
> 
> So I'd like to see it be more directed.  Only using the __put_user_pages()
> version allows us to ID callers easier through a grep of PUP_FLAGS_DIRTY_LOCK
> in addition to directing users to use that interface rather than having to read
> the GUP code to figure out that the 2 calls above are equal.  It is not a huge
> deal but...
> 

OK, combining all the feedback to date, which is:

* the leading double underscore is unloved,

* set_page_dirty() is under investigation, but likely guilty of incitement
  to cause bugs,


...we end up with this:

void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
			       bool make_dirty)

...which I have a v2 patchset for, ready to send out. It makes IB all pretty 
too. :)


thanks,
-- 
John Hubbard
NVIDIA

