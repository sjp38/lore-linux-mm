Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C6FBC19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:40:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E60E721E6E
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:40:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="cZhyddtf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E60E721E6E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8367C6B000A; Wed,  7 Aug 2019 02:40:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E7366B000C; Wed,  7 Aug 2019 02:40:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AEE76B000D; Wed,  7 Aug 2019 02:40:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB6B6B000A
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:40:36 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id k9so50114625pls.13
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:40:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=jn0FnBY7ADCh0laBLX/xGqPiB9Jg8oG9YEaLS2KH1Js=;
        b=sHYZWkyasq2NjPHs1AtxIJZCcBfBjFCaJBoqh2LxAnQ4Adhf6Qmkvwd5sk93UUuYKU
         ScbJAuWvYvlpKCTzCDSJtABbrQ4iIqDHLivFiFH/uqmD3lrTkOaeYsScC6pHlkm5jXpI
         b9UYScwHuO6dKcKXStMMUIPIwHSXjYOAQ5H3XdkKh+pC8gXreqJF2jnsm9yPGHNllGOG
         m41Nz0XaNpV3dSN3dVwb0qLJv3LmjaHCkZJBcaa/f6eKwmoMkwl/UgnKZ/vmMfaeONdd
         I5HVFWxAZflGbadyPZrzy/BB9Xt+XQyIGFguUfzHuwaZh9yV7Rml/b+iXKRybZFjNw3K
         kZRQ==
X-Gm-Message-State: APjAAAWCDh1I49YaTCnSewT2zCGMmGUbs1XHwNadybpaRrJzIPeF1qS/
	ViTNNfoOk5YkNSOf2mRfPjbvxl7576oUEXdh/uyOl49cpAB3n8TKyPGWV1EIzYZkC5IUWTa+DRh
	p+z8WKdYt9dlrI0Wqbdajf0pXp5V/3AMqHG7gNtb+3v77y8Y/MXQYDr2lbwSiZwCqsw==
X-Received: by 2002:a17:902:8a8a:: with SMTP id p10mr6928616plo.88.1565160035855;
        Tue, 06 Aug 2019 23:40:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfDXgsXudhewG1YKUkLZuwRfmBlhhwDH9E5dMXbswhbx7HdoVTi+NkKc59N7RViQbFJtdX
X-Received: by 2002:a17:902:8a8a:: with SMTP id p10mr6928589plo.88.1565160035177;
        Tue, 06 Aug 2019 23:40:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565160035; cv=none;
        d=google.com; s=arc-20160816;
        b=sccVd7SF+n5PJ2izS65ZVhMPL7UGEHZCiUEkbJYoQ6Bj828Gx22D85zkaOhklZqhtW
         JSNoGme6tIxrxXp0c1bK8cYQcZDiuEqQbpfuBG2iMSb8g+8MpktKAZ02CHmmb2CV8Y1f
         Vp7a0J1hYhxip863I/x8vvuF1xk5U+xN+11dUMM6qdhvKIAU8dD7v13qf5DmdTH28K6E
         fGFsyCkMMMtCILJxpR+ydsiZl5T88iYmfKqI82QBdcKVR5I7x2uJEWxbfzZLKqp0EyKZ
         66ulbr3LIo6c4WaiVGU7E/DT6dGE5K0LWYid0KE7BzVBsErgf8y+aGnrRO3x6YjuihD1
         VoRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=jn0FnBY7ADCh0laBLX/xGqPiB9Jg8oG9YEaLS2KH1Js=;
        b=V+bHWxY3ZelTO33gMDjK8xMYbg7rBlYTLtw0c6kkC7Mji5XyS+rT3X6TANJfvPKQkY
         29sVzTIR9hdYFk+GZGSmNW6kxSyt59d4E+kM5QlDzrrJ/eWbB8UclL0hTu3v+k4Eb6F4
         jpCJLYdAvOnMsSiFrAvRz0qHq2N7+Sc3fh/rKpi/u6+YjSf0deHIdgTS3ZzcQjgP5WpT
         sNzamB9gGM/UoPnoL9NTV3g38dlLfM20fQymH+OHzYxNBdobI2aZCFmX/VKkgeuJU61x
         HrBm4mV6WgCqrSyvv2x1EJL47P9DhOD8it2pCN/W9F0J8joYZ9Sm5jAekstASKFlsXW3
         2V6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=cZhyddtf;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id v4si43109863plp.212.2019.08.06.23.40.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 23:40:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=cZhyddtf;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4a726c0000>; Tue, 06 Aug 2019 23:40:44 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 06 Aug 2019 23:40:34 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 06 Aug 2019 23:40:34 -0700
Received: from [10.2.165.207] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 7 Aug
 2019 06:40:34 +0000
Subject: Re: [PATCH 00/12] block/bio, fs: convert put_page() to
 put_user_page*()
To: Christoph Hellwig <hch@infradead.org>
CC: <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>, Anna Schumaker
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
 <20190724061750.GA19397@infradead.org>
 <c35aa2bf-c830-9e57-78ca-9ce6fb6cb53b@nvidia.com>
 <20190807063448.GA6002@infradead.org>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <3ab1e69f-88c6-3e16-444d-cab78c3bf1d1@nvidia.com>
Date: Tue, 6 Aug 2019 23:38:59 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190807063448.GA6002@infradead.org>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565160044; bh=jn0FnBY7ADCh0laBLX/xGqPiB9Jg8oG9YEaLS2KH1Js=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=cZhyddtfeWnuDzmY91G/o97CceVB5RM0qm7xIS+BT+DJS1yACOaMbPnxtDPonJo3O
	 Ckk802AdQClg27dtVTwqZlP1rJ45uR/xJxU2tj1bAWtx6wGx8MnDwDr9/hAcMofdtY
	 YSzbF7dvdBOxPO1CMgg0kHDyQnZ9XI/sZkIaiXVixuZIn5BzSqRh7aOyfPS3OIiva2
	 EdoAoTR8kqTmNnuIpmqz0Mts9lp7nFil4TrfQHcFTrur14aYk9UOgpcZdRREzoyCup
	 0KYEKb/ZJNSFduxPI76a4ilG78VxY7/mJHog1LdnWqMnq4OYf6DhFN3qt02E1MzswR
	 TFH77+TyL//6w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/6/19 11:34 PM, Christoph Hellwig wrote:
> On Mon, Aug 05, 2019 at 03:54:35PM -0700, John Hubbard wrote:
>> On 7/23/19 11:17 PM, Christoph Hellwig wrote:
...
>>> I think we can do this in a simple and better way.  We have 5 ITER_*
>>> types.  Of those ITER_DISCARD as the name suggests never uses pages, so
>>> we can skip handling it.  ITER_PIPE is rejected =D1=96n the direct I/O =
path,
>>> which leaves us with three.
>>>
>>
>> Hi Christoph,
>>
>> Are you working on anything like this?
>=20
> I was hoping I could steer you towards it.  But if you don't want to do
> it yourself I'll add it to my ever growing todo list.
>=20

Sure, I'm up for this. The bvec-related items are the next logical part
of the gup/dma conversions to work on, and I just wanted to avoid solving t=
he
same problem if you were already in the code.


>> Or on the put_user_bvec() idea?
>=20
> I have a prototype from two month ago:
>=20
> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/gup-bvec
>=20
> but that only survived the most basic testing, so it'll need more work,
> which I'm not sure when I'll find time for.
>=20

I'll take a peek, and probably pester you with a few questions if I get
confused. :)

thanks,
--=20
John Hubbard
NVIDIA

