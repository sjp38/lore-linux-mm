Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A871C76191
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:50:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD10D22BEF
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:50:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="rI6tcfKj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD10D22BEF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 788626B0008; Thu, 25 Jul 2019 13:50:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 739D98E0003; Thu, 25 Jul 2019 13:50:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64E9C8E0002; Thu, 25 Jul 2019 13:50:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 460A36B0008
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:50:06 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id d135so37734692ywd.0
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:50:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=oG7iW18JoTbi7qpLIpRxo4HqaxvkInQKbpTpVVtqeEU=;
        b=U0OYEAlIny/xg2AgQJUxkTeJ3ArdloZ7MIVANmupeeFBKNkMVsXzixWlqiZY+YGZim
         m1kGTMnD3wuxswDXRi+fmzzzBTYxCkKQ4yQ1M/Eh00ok07LFwQ2Nb3C6apM11vNLjFo9
         feBWEpKPp14W7AybJ/StbpWNW83bGPDl39Uhbu/h52AcDVWxvuVVE7KceBsLwdVBrwQC
         1GKLOAhFTo7zUlHUWwgGbYqsP3eRaIdnYTx0AsTBkBTOo59pdCEtTLA50fhj3dZZM63x
         MBGeTeNvHeSIqzfqEx/6W7IaFQ+9odOxqDJh0avSjmIHQQ38dqINj8tLHUfX1RPLQg9T
         GdpA==
X-Gm-Message-State: APjAAAWHMpQiIKYvqifYZ184UA+sADrgiuKINvdb7eStSEXpInADq5X7
	n+9QZ6N0SOi9Hu0ZRjDMF0KREqKALCgg0CUBxxgaWs+I5/Wv7SmAAYMiaJ9K4AKoRegCSyUdIhv
	Q816KS4NXhYDmTXhi2EBy0K3kwEREBlFJ1L6YVNmu5271H4VrgnO+j5+YGhr/zrRYtg==
X-Received: by 2002:a81:5248:: with SMTP id g69mr54729312ywb.500.1564077006024;
        Thu, 25 Jul 2019 10:50:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweJWxn5MWt8q5O3Te2h3wT6H4lr5tbwJ6QvR0Klb/ikniFomygSa3w/rfMe/8yu7UT7DQX
X-Received: by 2002:a81:5248:: with SMTP id g69mr54729285ywb.500.1564077005410;
        Thu, 25 Jul 2019 10:50:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564077005; cv=none;
        d=google.com; s=arc-20160816;
        b=WPKhWz8sDnWRn0v+y8Dwrsod1NMGQ5/mYxI5uiMOzzGI7cS25POxXbEVcVG5ONgQfC
         4lMxg5YTcV68lI+rpf/GSFrXInKTB4pdf7kUwO164YL/Hk7tQ2LN8U6X97dGmr6CSRdv
         0cprZRZxwWXFmM6QR0ibMJpFScLtGPM9H7uyi0TZp9XIy3rMhk6R5HJxivtXPX34G15p
         4Sx91G2L/Tjps5sAPRI6sJHK+HzZNpL+hStjWC/w3N9Zt/5BhkHE3Xi9GmS5+wMlCnuG
         scLyzrjsr+AVVHMvDc1T50wmWeGKWZlnfWutyhLnQV/fAah1YnB7hdMHD0E7XdFBW4tP
         sEGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=oG7iW18JoTbi7qpLIpRxo4HqaxvkInQKbpTpVVtqeEU=;
        b=g9rublYDd3XaQHMTc9SeSAVDj3oEmQPtdDOgcmuQepCGqmGdbbZ4/Ru5mwTfSu+nBb
         Jfb815e4UfvtK5gzc3be0YMZeAyZRbqnCKtAoNdWuS1h2S3qmn+4eBE6Ct5Dml0iV5dN
         UDPfwVEFzwSOOZKzd/kTxGoOQQj0VmIcz9RYSv6yDNAMbdbZaqKstUDcZfy2I9GJudtB
         5/K/WzFB8fag731YE64VuN6S28x3CUwg5PxdHls3zwmFovph1mSST3nhpmg2TAVr/wz4
         iKyrCtTYyHqe4+ooCf72X9XKeiKK3rH7z/bXBGZg7+THQ76FUo1pm+Y600s8jwCpsYsO
         M5Mg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=rI6tcfKj;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id e13si9437876ybp.164.2019.07.25.10.50.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 10:50:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=rI6tcfKj;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d39ebc90001>; Thu, 25 Jul 2019 10:50:01 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 25 Jul 2019 10:50:03 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 25 Jul 2019 10:50:03 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 25 Jul
 2019 17:49:59 +0000
Subject: Re: [PATCH v3 1/3] mm: document zone device struct page field usage
To: Jason Gunthorpe <jgg@mellanox.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, "Matthew
 Wilcox" <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, "Christoph
 Lameter" <cl@linux.com>, Dave Hansen <dave.hansen@linux.intel.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "Kirill A . Shutemov"
	<kirill.shutemov@linux.intel.com>, Lai Jiangshan <jiangshanlai@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>, Pekka Enberg
	<penberg@kernel.org>, Randy Dunlap <rdunlap@infradead.org>, Andrey Ryabinin
	<aryabinin@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton
	<akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
References: <20190724232700.23327-1-rcampbell@nvidia.com>
 <20190724232700.23327-2-rcampbell@nvidia.com>
 <20190725012225.GB32003@mellanox.com>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <131f7c2d-704e-6f58-a330-e62d2ef5539e@nvidia.com>
Date: Thu, 25 Jul 2019 10:49:59 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190725012225.GB32003@mellanox.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564077001; bh=oG7iW18JoTbi7qpLIpRxo4HqaxvkInQKbpTpVVtqeEU=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=rI6tcfKjR1LQ254m/IBmbYjmdPRO+O414xxVE9H4xpU4Cf8g4LrW5czg2J7R/E9UK
	 IuCJmkMOGHg5UbU9py+N6/OsZqu0i3kxRiq72lxvyBAr4R/SRk3Ph9b4cPcj0+1LeQ
	 HcTMy4xeIFVIAR/fE4ZXX5aJEY1rtnMNaOKBxofLLtl/zXXuVCCDs4bXhLpGBDLgQt
	 jjmro4lglHz8GYKuKJiGVMABgSpyow5/WGddYIcOrx8yIJ0mqOfTMoW7AvMdQppRqc
	 XVh3RCs98U6YxWpnWEHvzQGz1G2j+AT6dv7iCO4T/AZ4bzZCYxC97uD7qOLtgfVRr8
	 Xb1mVLma/E6qQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/24/19 6:22 PM, Jason Gunthorpe wrote:
> On Wed, Jul 24, 2019 at 04:26:58PM -0700, Ralph Campbell wrote:
>> Struct page for ZONE_DEVICE private pages uses the page->mapping and
>> and page->index fields while the source anonymous pages are migrated to
>> device private memory. This is so rmap_walk() can find the page when
>> migrating the ZONE_DEVICE private page back to system memory.
>> ZONE_DEVICE pmem backed fsdax pages also use the page->mapping and
>> page->index fields when files are mapped into a process address space.
>>
>> Add comments to struct page and remove the unused "_zd_pad_1" field
>> to make this more clear.
>>
>> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
>> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: Dave Hansen <dave.hansen@linux.intel.com>
>> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
>> Cc: Lai Jiangshan <jiangshanlai@gmail.com>
>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>> Cc: Pekka Enberg <penberg@kernel.org>
>> Cc: Randy Dunlap <rdunlap@infradead.org>
>> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Cc: Christoph Hellwig <hch@lst.de>
>> Cc: Jason Gunthorpe <jgg@mellanox.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Linus Torvalds <torvalds@linux-foundation.org>
>>   include/linux/mm_types.h | 11 ++++++++++-
>>   1 file changed, 10 insertions(+), 1 deletion(-)
>=20
> Ralph, you marked some of thes patches as mm/hmm, but I feel it is
> best if Andrew takes them through the normal -mm path.
>=20
> They don't touch hmm.c or mmu notifiers so I don't forsee conflicts,
> and I don't feel comfortable to review this code.
>=20
> Regards,
> Jason
>=20

Fine with me. I should have been clear in the cover letter which
tree to target.

