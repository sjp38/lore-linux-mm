Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 100A3C76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:25:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6271218D4
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:25:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="HTBAoz1a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6271218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 655D16B0005; Tue, 23 Jul 2019 17:25:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6078D8E0002; Tue, 23 Jul 2019 17:25:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CEB16B0007; Tue, 23 Jul 2019 17:25:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D34F6B0005
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 17:25:52 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id f15so33241455ywb.5
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 14:25:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=ScttwGqLrhEb0twi6RY7tFc+yqiFYp5H9qvTzCFtqzA=;
        b=Zn+7Y+VgOiw9HqM1bGnzaScXE1594LcCeb/12vFTVTanOWSwj5pR2FDMn7hRfB3p04
         XfCwAQrBtE71NeSjh1jVZt8qFCfKKpJKRXKOGLAxjCUGdshqyKLvXQKZ6kbhak6lpPx6
         BNqaoGDINtL2r7dD4s5eRF4lDnG4wEnDaXW7xTPVMIGkLtNA42rwDngqpDQOYSVPFyly
         RXOi+satNF4DuFy4CPY5D252lqVQMlk6Ane0N2n99/o/gPVipJO7ofuOJxTjGC8m3uri
         a3ZRmiqvrx3zuLM9plOSNjCdf2BbsvB1+pYqi2lTzsRBwm8u0j5vPuR2VDWxnS3MZWnb
         MDZw==
X-Gm-Message-State: APjAAAUo+awjob2db08whfp3hCPjj87Hy7k3m8exVTn6zqTssL/56wqI
	Lw3qAgbq0dPV3e5Xih51nudKhyvTskDrb6FaTp6KiF6NwSLI5ktskb0Zku6cn9C9CRxDfmJ+9EF
	aI0UL5n7rpBFHtFK/sgBZDLjHuanNKmwj7UAMCGutqw6AyBtIkBOmlRr9glCIFnermQ==
X-Received: by 2002:a81:22c3:: with SMTP id i186mr49239138ywi.448.1563917151974;
        Tue, 23 Jul 2019 14:25:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzK+BGxNMxavKX44ENs89z+JTn88hlTbmqujGqeDxYkesDh6htSFsu0PMLByI+60/RvAHm
X-Received: by 2002:a81:22c3:: with SMTP id i186mr49239116ywi.448.1563917151381;
        Tue, 23 Jul 2019 14:25:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563917151; cv=none;
        d=google.com; s=arc-20160816;
        b=LA1YJN4GqeeR0FK53KasECyw4orXr6c4zUcvI+qywyJ+a02n3mY1T9/w2/JInsin4O
         YHxMOvt1+1Qw3gfyVAmoBjXns/2uVJdAyBvfwlg4o85VoeXVFC5Km0tEsNtTt68aoUYC
         kW5+4wKH+7cNFcbYRUFHp/X5ozCzLj5j23NgkwyeyNDDAVrdetRpGg+GlgCIBk63qfB2
         bHks6x6HMGj4ZLWSj/qPSM8uqX9q2Cgz/26T4E4J65odTHcH/MApPatTEJn/GStgXi6C
         yVnI6mK62oX8fJI/3d6TOWLsk/aOK5HAPeQ8Rx8kJCWFX1+7Z++TVITj2trAuoQwH02e
         vM1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=ScttwGqLrhEb0twi6RY7tFc+yqiFYp5H9qvTzCFtqzA=;
        b=PHNffwXTWn7QM2MKgj1O9CjCvql05P3SPNIenR2jK60UMUGkslgToG02j0DZoEnXhs
         MBMBQs/zE9LvN3uoYXtQPVNs7KeYhJxuH7nL2d4Epte1XMqG79c5UKhqOwX+hNoODZCA
         XwICq8z4RQQ/1VOMfZ4hCW3b9bJ1aRPDGuCzed63zRmP+bJ5YKLaWBBSQmIQadwb57xk
         in82ziVpcYqO6fu8krcE6Mj2sBJRmjLQrLNZYXQJxQDW5L2N6yyw8IqbZWkouFkTXrc7
         3v5tfbbXaIAW3jLT3LCeNNSTAeA5vUidKUnFY2pYCGVYdCcxdXzinoYl/CQobjfvroIc
         yMQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=HTBAoz1a;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id d11si2931447ybm.475.2019.07.23.14.25.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 14:25:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=HTBAoz1a;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d377b5a0000>; Tue, 23 Jul 2019 14:25:46 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 23 Jul 2019 14:25:49 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 23 Jul 2019 14:25:49 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 23 Jul
 2019 21:25:44 +0000
Subject: Re: [PATCH v2 1/3] mm: document zone device struct page field usage
To: Matthew Wilcox <willy@infradead.org>, Ira Weiny <ira.weiny@intel.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, John Hubbard
	<jhubbard@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter
	<cl@linux.com>, Dave Hansen <dave.hansen@linux.intel.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "Kirill A . Shutemov"
	<kirill.shutemov@linux.intel.com>, Lai Jiangshan <jiangshanlai@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>, Pekka Enberg
	<penberg@kernel.org>, Randy Dunlap <rdunlap@infradead.org>, Andrey Ryabinin
	<aryabinin@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe
	<jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds
	<torvalds@linux-foundation.org>
References: <20190719192955.30462-1-rcampbell@nvidia.com>
 <20190719192955.30462-2-rcampbell@nvidia.com>
 <20190721160204.GB363@bombadil.infradead.org>
 <20190722051345.GB6157@iweiny-DESK2.sc.intel.com>
 <20190722110825.GD363@bombadil.infradead.org>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <80dbf7fc-5c13-f43f-7b87-8273126562e9@nvidia.com>
Date: Tue, 23 Jul 2019 14:25:43 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190722110825.GD363@bombadil.infradead.org>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563917146; bh=ScttwGqLrhEb0twi6RY7tFc+yqiFYp5H9qvTzCFtqzA=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=HTBAoz1a35vMm9dEfCZ9ucGpRtfWn50k5XdHWQVnukyE3m4YsOS4KQVKIsztIfDG9
	 Jr0YpCMG6BmNA6okSTPpFptOsHIM0sypKIueyTnOAfpztK5966N2vMbYPQmDP4B/Y7
	 nM8KL1CHebF5U+sP0Ndew6xc0qN4osk2ZJYTr2Ag/Igr6KRGSfW5rniAruh3Y2bbV5
	 0UxiCI+wk73K5fjrq9UsYu+brV/O+JnzOO6nCO2lRcCAyYpfjvNrXVVWHOjhoNc0jA
	 tgK7zRpvNHjr24v+oVtRKra2bSx28Xtg/4UpRVPaLqu+X/p0Tjb0chqcVlzoG6WqNC
	 GYZ89VE/Dp4sA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/22/19 4:08 AM, Matthew Wilcox wrote:
> On Sun, Jul 21, 2019 at 10:13:45PM -0700, Ira Weiny wrote:
>> On Sun, Jul 21, 2019 at 09:02:04AM -0700, Matthew Wilcox wrote:
>>> On Fri, Jul 19, 2019 at 12:29:53PM -0700, Ralph Campbell wrote:
>>>> Struct page for ZONE_DEVICE private pages uses the page->mapping and
>>>> and page->index fields while the source anonymous pages are migrated to
>>>> device private memory. This is so rmap_walk() can find the page when
>>>> migrating the ZONE_DEVICE private page back to system memory.
>>>> ZONE_DEVICE pmem backed fsdax pages also use the page->mapping and
>>>> page->index fields when files are mapped into a process address space.
>>>>
>>>> Restructure struct page and add comments to make this more clear.
>>>
>>> NAK.  I just got rid of this kind of foolishness from struct page,
>>> and you're making it harder to understand, not easier.  The comments
>>> could be improved, but don't lay it out like this again.
>>
>> Was V1 of Ralphs patch ok?  It seemed ok to me.
> 
> Yes, v1 was fine.  This seems like a regression.
> 

This is about what people find "easiest to understand" and so
I'm not surprised that opinions differ.
What if I post a v3 based on v1 but remove the _zd_pad_* variables
that Christoph found misleading and add some more comments
about how the different ZONE_DEVICE types use the 3 remaining
words (basically the comment from v2)?

