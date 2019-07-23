Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 820F8C76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:35:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C8552238C
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:35:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="rtKKKX6s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C8552238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE99A6B000A; Tue, 23 Jul 2019 02:35:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C73D68E0003; Tue, 23 Jul 2019 02:35:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B13D48E0001; Tue, 23 Jul 2019 02:35:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8BFC96B000A
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 02:35:04 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id 199so32380164ybe.6
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 23:35:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=MYQG8fRNI4z6ZFJij9qzWoyJeD7sXuD24txEZDtHeVo=;
        b=aqYwZ6lFx/53RTNxPmvr9glGNNLCdRrC8zTxoL7aklfOX8n8bFfzlN+Y0N/KTzKZIK
         fYuZW83LSH57R4OQ/GHMXGoWg+5G5kBhAupliaUQgd7EVFBYRPaznWJiVIyqczIxXuTP
         r8wDsdbqmMS4IaVGkVlJA71zzIKlCMLnIFAm4FOmWdQf+inHckPtvTCN4jTrlbyIuL7Q
         is2kWxjfUoK45cr/OeJ+e4wkjYwmChReQm3mSsHRzjygmz1GyJpSsGx4s5iahO+2Zzy3
         ybo6HXpONCdY9DEnawh54lraQQreP8D5K3PTEOt/eyoZkqIH+l9AXcDl0flkTNEoNLor
         C04Q==
X-Gm-Message-State: APjAAAXBExRXXBTg9T2zFJptf6ufvfk9n0HyLTojWh/3uSYhZ/r3zZyL
	jiQCAuariZwJ5lQwyeCjntK94dJ7KPmqcXQVaDkxZ0G9GMEDWg+1Qp9k2pXsAIVJS/AK6G3ylp6
	Cdy97ufzK/hxbfbccxlc6P7+/CetAqJ0roJAdHp0j80559bS8n+h9oXj8Afe1/kM37w==
X-Received: by 2002:a5b:88e:: with SMTP id e14mr46593946ybq.353.1563863704330;
        Mon, 22 Jul 2019 23:35:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQETzO304b5VUUaYH0lms4y1Rm53Ib86U9re6modHa8wSpDsLXNBPHMobKihTuRcQBmVgS
X-Received: by 2002:a5b:88e:: with SMTP id e14mr46593928ybq.353.1563863703659;
        Mon, 22 Jul 2019 23:35:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563863703; cv=none;
        d=google.com; s=arc-20160816;
        b=JvlFY8K18MTwqWU0s91CqwkAMOR31ANIObsF6cW8HcWHO8XkuBs2IYd+apxu75uMYB
         vsGrDPPdpRAAzdlCA5NWCIaqux/kOwUoryEYFpRHt2I50UKiecIFTQUJ273tqkAxj4wp
         fxLx3jOQhLsKnachW8ThgRj+nleImJhAT76JtkaeR3NVT0Ic07jvRCVdJzsg8bTnUNuO
         MGybE7eVmtJtJzRBlMqcaSqMS9XwJQXLMmFD2BGjTJwzcFD/iTtTRTnNQgRvq+wTkxHE
         Vx2Q24uXNtD44fuojJqGuoQwM70TpUSkHw/0YxkSxLwOvwD5r/uUXw7DkG4NU3EyapCp
         E8Ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=MYQG8fRNI4z6ZFJij9qzWoyJeD7sXuD24txEZDtHeVo=;
        b=YPNJaNDt8c3+uunzjsb/ZO4v1dttPR58Q9R4wBXhBbb3ihtX+WyahirVm6Z4G4age1
         iaGMPH9Ccdf+LVMPeEc4guZJ4XW8kykSPDTroHmM5ZXjx6tbkS0z+vpItoohuIdYAlHa
         NjE/arv593FBGsTS7hdc3stkuaY1JgYsSR6KC1hc+eINyN1kpg4bgSqRYAURoBiieYYC
         yPM+EILmDkzoWFW5CgyS9LWCcYA8TWai6gNIO/CV501zWvVh5GRfp0kDHbPUWXdn8bfU
         DTO6QCNoQSi6EN4d/sAPPYX6u2ThkMmGPHNBnORM4rJspBu4zETMUDt7YDtEoXs5iIzT
         DSFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=rtKKKX6s;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id e66si16915100ywb.443.2019.07.22.23.35.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 23:35:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=rtKKKX6s;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d36aa920000>; Mon, 22 Jul 2019 23:34:58 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 22 Jul 2019 23:35:00 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 22 Jul 2019 23:35:00 -0700
Received: from [10.2.160.36] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 23 Jul
 2019 06:35:00 +0000
Subject: Re: [PATCH 1/3] mm/gup: introduce __put_user_pages()
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
References: <20190722223415.13269-1-jhubbard@nvidia.com>
 <20190722223415.13269-2-jhubbard@nvidia.com> <20190723055359.GC17148@lst.de>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <8ab4899c-ec12-a713-cac2-d951fff2a347@nvidia.com>
Date: Mon, 22 Jul 2019 23:33:32 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723055359.GC17148@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563863698; bh=MYQG8fRNI4z6ZFJij9qzWoyJeD7sXuD24txEZDtHeVo=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=rtKKKX6s7ujNQbvClnxWqMxjAQN+orwb0XG6bE7MY9CBmVMoLos6YZJhDRHzOwcu7
	 MgcwjgXGmxu08uFN3j7xmVuYQfp+YxGQWwPqbSk2XS0jFo6zkI7t0qFXNXXmSLtY3s
	 DGCNjuilmS9RDcCRCHUhnaNFu0w5UNnZE0mpdDsgv5muKWSHcc/MN7abz3aSfjB2u5
	 qlQsi1M3emKcIzuJhFxTyC574Iqg5IsJdZeBsu4z0jgKJGZ42JrJbgbbwRMmTsSxBC
	 Tyyk+jkxxDt8HzFfD/xTR3nVTUPGoNCjGukvHrN0rnk9ywKCisRW6Y45T378RNPzwb
	 ZYjYbcdp2Tx7w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/22/19 10:53 PM, Christoph Hellwig wrote:
> On Mon, Jul 22, 2019 at 03:34:13PM -0700, john.hubbard@gmail.com wrote:
>> +enum pup_flags_t {
>> +	PUP_FLAGS_CLEAN		= 0,
>> +	PUP_FLAGS_DIRTY		= 1,
>> +	PUP_FLAGS_LOCK		= 2,
>> +	PUP_FLAGS_DIRTY_LOCK	= 3,
>> +};
> 
> Well, the enum defeats the ease of just being able to pass a boolean
> expression to the function, which would simplify a lot of the caller,
> so if we need to support the !locked version I'd rather see that as
> a separate helper.
> 
> But do we actually have callers where not using the _lock version is
> not a bug?  set_page_dirty makes sense in the context of a file systems
> that have a reference to the inode the page hangs off, but that is
> (almost?) never the case for get_user_pages.
> 

I'm seeing about 18 places where set_page_dirty() is used, in the call site
conversions so far, and about 20 places where set_page_dirty_lock() is
used. So without knowing how many of the former (if any) represent bugs,
you can see why the proposal here supports both DIRTY and DIRTY_LOCK.

Anyway, yes, I could change it, based on your estimation that most of the 
set_page_dirty() calls really should be set_page_dirty_lock().
In that case, we would end up with approximately the following:

/* Here, "dirty" really means, "call set_page_dirty_lock()": */
void __put_user_pages(struct page **pages, unsigned long npages,
		      bool dirty);

/* Here, "dirty" really means, "call set_page_dirty()": */
void __put_user_pages_unlocked(struct page **pages, unsigned long npages,
			       bool dirty);

?


thanks,
-- 
John Hubbard
NVIDIA

