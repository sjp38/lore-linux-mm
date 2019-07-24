Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBA89C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 01:31:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D55D2253D
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 01:31:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="L8+8TSTf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D55D2253D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 379498E0003; Tue, 23 Jul 2019 21:31:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 329B48E0002; Tue, 23 Jul 2019 21:31:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F1698E0003; Tue, 23 Jul 2019 21:31:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEE538E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:31:42 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id d135so33677717ywd.0
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 18:31:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=81R/Z2rovzmAa3O7DCJ8y2Mm5lAz4O2B1wbIdVhO0d8=;
        b=XgEYMDYiOnWTe+RRGXee6pcICKUSNbQd+e5irciAvG+rblipaTD98oQvCCrRj+bIig
         Fm8GQjr+637K0PIbU0ILH46uMzxK5IkMW8hnKuPtsZG5RK5YdCrjR11P9e/ISA5QUJ1p
         IXIOteAu9Omro1xvHvzvNoTlu7TgC0JRUPbOoYWV8m/V2lXMhv4zqvJwtTDRgiTQgyQC
         J3H4aQdlQKc4plUh+3HqKOMUaDlznrVSX00RRmxWCERgeXpHecm4eunDYWl87z4jM0Fr
         UwY0adsTplivcdD0cQyv2hIVjGhlOaE4GOurvMCfroTecI+Rv5vXnmrR/3Zt0Wo9EZVC
         Bejw==
X-Gm-Message-State: APjAAAXA4cuVftctdvoivIEYc6HdVxZ/AeK00ani4YIJ4WtHGJr9vle7
	4vShL7A7E3nlh3QaRJaYAM79j+oUZmYg/bk/n26EYt2CUPuw+FTA5rU2HIAzhh2G2v+UNsr/NHp
	ZnKwg8k/LpRdvkqenb2mMrWTYvGTCn1hPHe9J53vulSxAXZSr+3Ageh+QLhWHmgUhyQ==
X-Received: by 2002:a81:3557:: with SMTP id c84mr45497004ywa.67.1563931902663;
        Tue, 23 Jul 2019 18:31:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVwLjBn9bZin1LvK2n//nv9ht6geQ1Gys6TKec21f2NKyuqRddfIQ4mJ8t0oSnBIs2yb5V
X-Received: by 2002:a81:3557:: with SMTP id c84mr45496995ywa.67.1563931902250;
        Tue, 23 Jul 2019 18:31:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563931902; cv=none;
        d=google.com; s=arc-20160816;
        b=0GWfdZ1Z1ut7nStVVhJ/60EwpQgkqPnwVJwi35b7Pg+Vgzsk557kZIK2dIH/7MNkcU
         pynKwwlUpqbHLGkf/9qd/qDdmkCZEhb6C32xcQvhZHD91XdtGuj9MV5s0lRaWvXC7Cxf
         osGOvRNRD6yXjJ++XdBYCIQkOxZXmbVz4Q4qzQHtCoQBr4ZTTGUP58v6mxj84P3bWgyY
         /wo0VIKJbyFiG9mHhFYyxMfJHB4fnXHMIxi5r5k3p3IRNSabTpp6787n4BGZ6cEGVsRR
         7pi6JGcnfVfV65lWxjKUj34/pP05twARE3CK1f1+GVG1nEBkW1vfHh157yKBY6ICJfxm
         3DHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=81R/Z2rovzmAa3O7DCJ8y2Mm5lAz4O2B1wbIdVhO0d8=;
        b=CTugAOAOBoDf5f13MQ4xZQpbxQDP1xrb6zs2+nIV6HVuZqVfuWdURsx4mVlgYR0huB
         fj+Aq/VStg+UzqrA/Y0+G9n/QttHFH54PYb7ZxdsAsNtvrT3jD0NkOuo6sxud6caXNca
         ck/K4aKqt3k/nXiCHwNhK1kYsQLDcEFydkPbRP3DhWW9aSi4GmtTgmE3Og0DAN6snfAI
         LXUT3J/i9AlXnqKMWY4YUj1E+Y6y+ojmj3Ai8IiEzVNcgFzGZqn7SglPim2jrAYnxGM5
         d3Mj/KQgNe6JjwvLg0WAMkkE5UTfpVX+Q1dnQr7IYVNrfFocTkWXpaPYP5WjWQwqc1FX
         q3fw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=L8+8TSTf;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id r185si18444800ywf.281.2019.07.23.18.31.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 18:31:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=L8+8TSTf;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d37b5040000>; Tue, 23 Jul 2019 18:31:48 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 23 Jul 2019 18:31:41 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 23 Jul 2019 18:31:41 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 24 Jul
 2019 01:31:40 +0000
Subject: Re: [PATCH v2 1/3] mm/gup: add make_dirty arg to
 put_user_pages_dirty_lock()
To: <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
CC: Alexander Viro <viro@zeniv.linux.org.uk>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?=
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
	LKML <linux-kernel@vger.kernel.org>, Ira Weiny <ira.weiny@intel.com>
References: <20190724012606.25844-1-jhubbard@nvidia.com>
 <20190724012606.25844-2-jhubbard@nvidia.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <5c303c80-57fd-d278-44d5-942597051c9b@nvidia.com>
Date: Tue, 23 Jul 2019 18:31:40 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190724012606.25844-2-jhubbard@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563931908; bh=81R/Z2rovzmAa3O7DCJ8y2Mm5lAz4O2B1wbIdVhO0d8=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=L8+8TSTfHtIkC1xowWnZPPItlJoP+leFf6ucvU5E2owqzMuOQ9jIZ8vvOAmRE48gG
	 nJc2BkzeiefBvFmLrdVIpofi+FqWCxnLVVCD8Km+TEsxK75nMF86BzzMDvJhOtd4Sv
	 tv/oBJtf5JB77EfsmMmPFfjUqHdF8FrA9NTbWBGktbrAYnfNv/v7rTGnTIY6IQINWA
	 7KWjSbQNfLlkpCFtMta3TS57pn2JgRvHM6UCjTP01IAnW414t4BHJWGwnR2xyxPuNo
	 ve66cppddE8vW2LUpVK1xyY3WfDsi+6f6NZZzv7rod362wLBdY3VFm9CgxAGyrUul/
	 iXE/3sT5XunbA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/23/19 6:26 PM, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
...
> +		 * 2) This code sees the page as clean, so it calls
> +		 * set_page_dirty(). The page stays dirty, despite being
> +		 * written back, so it gets written back again in the
> +		 * next writeback cycle. This is harmless.
> +		 */
> +		if (!PageDirty(page))
> +			set_page_dirty_lock(page);
> +		break;

ahem, the above "break" should not be there, it's an artifact, sorry about 
that. Will correct on the next iteration.

thanks,
-- 
John Hubbard
NVIDIA


> +		put_user_page(page);
> +	}
>  }
>  EXPORT_SYMBOL(put_user_pages_dirty_lock);
>  
> 

