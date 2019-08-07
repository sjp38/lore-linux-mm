Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FE89C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:32:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30AC521871
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:32:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="NrRvMjgZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30AC521871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF7B06B0003; Wed,  7 Aug 2019 19:32:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B30816B0006; Wed,  7 Aug 2019 19:32:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A9636B0007; Wed,  7 Aug 2019 19:32:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE6C6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 19:32:11 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n1so54266662plk.11
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 16:32:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=Vo6bQKtkk9LxLaQR6PE8mmqutIpc3NqGB6BA5P1fNgE=;
        b=cVBhz3jQ7TgA8n7OBgzWE+Vgwc6BeZgz6IB9XmDipwJQs85fbWSxfMoNtrzOTZflBa
         1puw+NyePtnJ6zuo6L1aw+HNutGKkRYReQ9ywMaQRPenk1PR52RhjOdKAIdwcaxnzm9U
         SwDUlr0IWo/Vg3TRU6Ij00oIZgOHR3iKqOR7NN1Z10VlRd3HmllqpxKo3heXNjwvTUMb
         eGHpKGxlhezTJbZ1b0zbfyslGI18YsaUrwCSYii8JMq+KjH5nLG+nAKrRqpFxyC6VP0u
         9E4gJZb2iQZTCy1Jb24jD0UQkYKyjzeS6iihRQ6LNBUVQ12hmnzzQ1T4IqW+z8xn/obW
         w6vQ==
X-Gm-Message-State: APjAAAUEhFJeg90FtMMwvCKmStyNa80x/BLGsf3+1bmp0pFLWembiOZy
	Tk+FkSp5ZK0ax65pdeQmS23wQ1/z4uMK9ehlHDzPh66hHNkFKhzNxJV4/kv7B0kUdqySrMkAPEq
	N158rGDzJ3scESFRZIXPFLBQkSKegAzZhgFeNDhg/wK4WSwpiwzwnXMe+kCgTNXbLWw==
X-Received: by 2002:a62:1456:: with SMTP id 83mr12080666pfu.228.1565220730909;
        Wed, 07 Aug 2019 16:32:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/WwN6LJGkXKLyUDE/LeKmzQx2eFn0o67xsKpKJ6ClH1uVhOHaUU2kRojRAD3xF4xtnJdO
X-Received: by 2002:a62:1456:: with SMTP id 83mr12080606pfu.228.1565220730202;
        Wed, 07 Aug 2019 16:32:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565220730; cv=none;
        d=google.com; s=arc-20160816;
        b=UoVubzTuhFHxBXikfVrvSg51AHb/eUsZ/v1gjeLyZzJDnZBwV7xd9Z48B2u1gQAiB9
         X68ETO0ifizc/ecMogKFd5+65yn2IOwkUG3o6R7yP17mZCYuro8Z5msXVMD+pEQyHoHS
         EEGBXPEjpVn7TAQLTDNMnWofod3z4G9U/Kv+T/PAC+InosuT7hPng/3Sz+s+UOXy87GG
         hWL95j+oNIfT5baa97jeGP61FHJOXI0TyFK4U12PbY926WuyxLUAg7oeByKa6+0hI99g
         BacJC49wGyb3lCoF8vrrK1xBVWluC/7Vre8JjQW2e4WlwtJFtAQ/LYJALb371xwmPy9j
         /ZMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=Vo6bQKtkk9LxLaQR6PE8mmqutIpc3NqGB6BA5P1fNgE=;
        b=DbuU1QsAxtyLeV2w9e/wp0fS9aPEelr/bXFv7Y0JOWidMYK0dLgLju2++hCJVME596
         e71zkI7F2I1OQJ+xkqN6dUjIZ8nlk42wocAU/c0iuTxIBpdvdEaY5yd/j1NMW15P5eVG
         g3sq3ORZTNOMBqbauE4ICcckaxhcm/hkUmAuQ5HUKDvEpqGeydR18shXIlILnznLhtQO
         oWI2gn8CgglqjOuBp6UUrMIcR4OQ4JRzNdFBc3XzJTe4azHYSeKZSo56Ehmlvb6jx00N
         0ruRZYJ+Rr2tlvBEpdX4+/sLvNeU3kDTqNSwaGLDBLY/c3OsDS65rdGln+FcINA8HHva
         H+Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=NrRvMjgZ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id r8si45976597pls.372.2019.08.07.16.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 16:32:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=NrRvMjgZ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4b5f7a0000>; Wed, 07 Aug 2019 16:32:10 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 07 Aug 2019 16:32:08 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 07 Aug 2019 16:32:08 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 7 Aug
 2019 23:32:08 +0000
Subject: Re: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
To: Michal Hocko <mhocko@kernel.org>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
	<hch@infradead.org>, Ira Weiny <ira.weiny@intel.com>, Jan Kara
	<jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse
	<jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>, Dan Williams
	<dan.j.williams@intel.com>, Daniel Black <daniel@linux.ibm.com>, Matthew
 Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
 <20190805222019.28592-2-jhubbard@nvidia.com>
 <20190807110147.GT11812@dhcp22.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
Date: Wed, 7 Aug 2019 16:32:08 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190807110147.GT11812@dhcp22.suse.cz>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565220730; bh=Vo6bQKtkk9LxLaQR6PE8mmqutIpc3NqGB6BA5P1fNgE=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=NrRvMjgZ026fJhY2X/UVob3ZUP7VbfQoX2fWC4rqAKy0rtWi8DdQ+dGpT9myh/Ups
	 oQZ4iC5DhOS8fMX9OAOKdFdxT2+r22p977v74zrvGliO+4rYDr3xwzKQhhiD8261DI
	 uWhhf3tl3zC3GIqtP7JRMFJvIf4rxZN5JgKREREk5KOERB6yo6bMNu88R4p5JniTVQ
	 Ax29c0PctE88ki6fi9CXmAw1JGVRX10gWo12j1SVWJZ5rPCcUjzZjJhHpqbg9efdQP
	 Kg7RC5y9sZF55OYmo73TeO6nKcqchTY2J4u2YycHEXaXJTEPbGcR6Y9t62fH1Tyy9A
	 GpxiBAiRmC1Dg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/7/19 4:01 AM, Michal Hocko wrote:
> On Mon 05-08-19 15:20:17, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> For pages that were retained via get_user_pages*(), release those pages
>> via the new put_user_page*() routines, instead of via put_page() or
>> release_pages().
> 
> Hmm, this is an interesting code path. There seems to be a mix of pages
> in the game. We get one page via follow_page_mask but then other pages
> in the range are filled by __munlock_pagevec_fill and that does a direct
> pte walk. Is using put_user_page correct in this case? Could you explain
> why in the changelog?
> 

Actually, I think follow_page_mask() gets all the pages, right? And the
get_page() in __munlock_pagevec_fill() is there to allow a pagevec_release() 
later.

But I still think I mighthave missed an error case, because the pvec_putback
in __munlock_pagevec() is never doing put_user_page() on the put-backed pages.

Let me sort through this one more time and maybe I'll need to actually
change the code. And either way, comments and changelog will need some notes, 
agreed.

thanks,
-- 
John Hubbard
NVIDIA

