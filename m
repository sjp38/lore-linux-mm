Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B511C76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 04:43:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0318420449
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 04:43:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Qa3lZLE8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0318420449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48AED6B0003; Tue, 23 Jul 2019 00:43:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43C706B0005; Tue, 23 Jul 2019 00:43:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3026D8E0001; Tue, 23 Jul 2019 00:43:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2F56B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 00:43:05 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id 77so31429698ywp.14
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 21:43:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=6Lt/z2MUaW0HLuGN6nPZXpx+R7NECtbBk4FafHzD+OU=;
        b=bVL2W508jcZK3GXFE1lHV9/X532ZhCDtPo6xAsQe0XH31Vkv/Zh+3RILDBLQC+Xido
         l/UaaNmOW1HPx+DRDWnBxdbdOhhea7wC7VycyqxM6PwDsm/vR+RXWsA/N2UEN5gf0Zgh
         U3vsUd/iaSWeYr1imLLcrDSA9QppxRiAT/Jf2hYAUsqZ3JHP1W32C5W3NKH73c6ICfgr
         FnIzwF6dvMQYfKUvYvqcYUwSpOblIQNj4JRMGIXa+Ozi9CGeW+bKL+EsHqurlxwUQKBE
         wLpLGO+IW7rVOPRzeUmeRCM1hpb76a7gJnnivTYBErUyLydjoznY9bHE4jMpC5VpT1OB
         KXqg==
X-Gm-Message-State: APjAAAVS50kbhUMWT3FSXXxZflUBhdQJgIw/OmT8NagUJlKpyxxMpOoq
	qZqu6WSjXVZE4JHYGH6R285K1/bV6+ObTf11SAMgN3yMRh8Y8oVLNINYib71YxtOSshdWXXeqFz
	mf4eL7esNi+qCpBnTlj/DLNPo+G29swm7HAPLsDo904nEUIfqJrkNBDy4aWAgltzl0w==
X-Received: by 2002:a81:9a93:: with SMTP id r141mr39140952ywg.469.1563856984728;
        Mon, 22 Jul 2019 21:43:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzm2mxAOO55p/u1ZVpXFOTaFb+uBi9euY/Csl24QR8vvSC88PqJ+Un43KVJNoj2GfYlUQ5b
X-Received: by 2002:a81:9a93:: with SMTP id r141mr39140942ywg.469.1563856984082;
        Mon, 22 Jul 2019 21:43:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563856984; cv=none;
        d=google.com; s=arc-20160816;
        b=R9py645FmwNYHGgHizDa1FrurxcmlR2Wpc6eu8iwvjpG63lHHUkMdkXdstcfYEqC+G
         m6eVKxpjtU0BXx11R525oGJFEctGcFV+kAzCHPQcQK/4TI47lVx07Iinv0lZvBx3+JrS
         U5dBnnr8/O9j+lwbPBw1LxHCIprWgFx2cCpLJbBXcr7e9NeKrCWWrGKm5Sz/C4t2u7kJ
         FeYcwKr0ozLzXwFZymxML3c2TxRZLLVjPqb2xpsZ61w8f+DwnAaS2iUiEsXZUhXtDhpn
         r8J7VcSE4ap6I4ZrJ8MZtdgJBZAI4N9ycQ7/X/+F5icn+R9JA8+Oaxblx/Ovh+FeDKdP
         Ufag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=6Lt/z2MUaW0HLuGN6nPZXpx+R7NECtbBk4FafHzD+OU=;
        b=lcB2s073Hefrqiw1ZStIuY1A6J8FX4eB1cxqKTvhJh1UDZe8RM5L6BbEcC+P2e9I3Z
         8b48xvmJXsF6OB2h2wjDuDfmrMwdn41ldhC7zUMbCr1Wq2wBmefCU38/n4yVUmUrVs4Z
         R1U36wIF9N8LDq4HvzhScMZrjy3D9Fvhxo04c4qMkOayE5v/bkXqQmIB3lz7HoFWWnCn
         VNLfyG2LfdYSdR9tjuQ1ypx9tSErnUmWQa7xjlcJfJ88sJuaAMUxJSKtuC5pdFzXUM9n
         0XYpJw+ikobF/97s+ToOO/X0BhZJSIxUHyNYFhyygLY4VUGcEwS36/efePjmSIzyzOfT
         NzGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Qa3lZLE8;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id a18si6668996ybn.357.2019.07.22.21.43.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 21:43:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Qa3lZLE8;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3690560000>; Mon, 22 Jul 2019 21:43:02 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 22 Jul 2019 21:43:02 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 22 Jul 2019 21:43:02 -0700
Received: from [10.2.164.38] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 23 Jul
 2019 04:43:01 +0000
Subject: Re: [PATCH 3/3] net/xdp: convert put_page() to put_user_page*()
To: Ira Weiny <ira.weiny@intel.com>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro
	<viro@zeniv.linux.org.uk>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?=
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
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <a4e9b293-11f8-6b3c-cf4d-308e3b32df34@nvidia.com>
Date: Mon, 22 Jul 2019 21:41:34 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723002534.GA10284@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563856982; bh=6Lt/z2MUaW0HLuGN6nPZXpx+R7NECtbBk4FafHzD+OU=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Qa3lZLE8Kf/RL8KhFgPo9Jkt7HFiKw1Is4rV87XoFGEKvWzwvIu+hxfTzr2uraY59
	 XErNMpPf1Qu2zCNLtYfVRqCa3/zsPozeqvDkM44qxxIpWE47R8YoLoPjAb9uunMk0+
	 2+b5UcPkOzZtt+IdgVMrvpTMyr/Pdu3kowZiYCl3u00yAyQSmsitBmCoJle4OhJXpe
	 bMuJ8grmilp9xNLC2hggYcxZ/uAvyWeQge9toK1cze9EOdK1UUkTm+VI05DdS87kNs
	 cGOrzWdia2G/F74bOT0v75OXAOE8VdSB9dSxGpUKwW6BkxObVy2erx/jSiG+ZKKb1I
	 5O4vdoqzeZX4g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/22/19 5:25 PM, Ira Weiny wrote:
> On Mon, Jul 22, 2019 at 03:34:15PM -0700, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> For pages that were retained via get_user_pages*(), release those pages
>> via the new put_user_page*() routines, instead of via put_page() or
>> release_pages().
>>
>> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
>> ("mm: introduce put_user_page*(), placeholder versions").
>>
>> Cc: Bj=C3=B6rn T=C3=B6pel <bjorn.topel@intel.com>
>> Cc: Magnus Karlsson <magnus.karlsson@intel.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: netdev@vger.kernel.org
>> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
>> ---
>>   net/xdp/xdp_umem.c | 9 +--------
>>   1 file changed, 1 insertion(+), 8 deletions(-)
>>
>> diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
>> index 83de74ca729a..0325a17915de 100644
>> --- a/net/xdp/xdp_umem.c
>> +++ b/net/xdp/xdp_umem.c
>> @@ -166,14 +166,7 @@ void xdp_umem_clear_dev(struct xdp_umem *umem)
>>  =20
>>   static void xdp_umem_unpin_pages(struct xdp_umem *umem)
>>   {
>> -	unsigned int i;
>> -
>> -	for (i =3D 0; i < umem->npgs; i++) {
>> -		struct page *page =3D umem->pgs[i];
>> -
>> -		set_page_dirty_lock(page);
>> -		put_page(page);
>> -	}
>> +	put_user_pages_dirty_lock(umem->pgs, umem->npgs);
>=20
> What is the difference between this and
>=20
> __put_user_pages(umem->pgs, umem->npgs, PUP_FLAGS_DIRTY_LOCK);
>=20
> ?

No difference.

>=20
> I'm a bit concerned with adding another form of the same interface.  We s=
hould
> either have 1 call with flags (enum in this case) or multiple calls.  Giv=
en the
> previous discussion lets move in the direction of having the enum but don=
't
> introduce another caller of the "old" interface.

I disagree that this is a "problem". There is no maintenance pitfall here; =
there
are merely two ways to call the put_user_page*() API. Both are correct, and
neither one will get you into trouble.

Not only that, but there is ample precedent for this approach in other
kernel APIs.

>=20
> So I think on this patch NAK from me.
>=20
> I also don't like having a __* call in the exported interface but there i=
s a
> __get_user_pages_fast() call so I guess there is precedent.  :-/
>=20

I thought about this carefully, and looked at other APIs. And I noticed tha=
t
things like __get_user_pages*() are how it's often done:

* The leading underscores are often used for the more elaborate form of the
call (as oppposed to decorating the core function name with "_flags", for
example).

* There are often calls in which you can either call the simpler form, or t=
he
form with flags and additional options, and yes, you'll get the same result=
.

Obviously, this stuff is all subject to a certain amount of opinion, but I
think I'm on really solid ground as far as precedent goes. So I'm pushing
back on the NAK... :)

thanks,
--=20
John Hubbard
NVIDIA

