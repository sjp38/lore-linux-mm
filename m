Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DAE7C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:34:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31673217D7
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:34:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="p41wr3D4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31673217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF5556B0003; Wed,  7 Aug 2019 19:34:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA36E6B0006; Wed,  7 Aug 2019 19:34:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6B526B0007; Wed,  7 Aug 2019 19:34:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1156B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 19:34:36 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g18so54338815plj.19
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 16:34:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=aoh0mQBWSJjDZTkXsDLT7mSUCXnBIfsGxB12+qPVeX8=;
        b=VGSCDrCId3M4AtCNTxG9zmYNNc4mxLzrXiG18D9gM1JqngXmi7p+EtblWOm3Jg8iai
         2VJ8gdU95dWKjW/wczgj4SSLAqQ3BhpTk0PF/0DVzOAgsHFgBYjMSczOXrjKckHKdsTa
         NDkbydZ+nYJ9B6YT9USmlkaKCro94eJWHN5ekIptTbOuBDnH7GDf0w18dpPxj0bCoxOo
         3LSg9ODehm+qr1/sQULdD7bkUhNP4uqBBF7CK8BdsubRxQBM92ttljfARFyw5nGziH8f
         mEsGITRYV1B+sPAkjun3ZZFkN4iReROzMgFK7x1eVAAiIuT0jCScnN/4VQwgb63WSoJ/
         PHjg==
X-Gm-Message-State: APjAAAXNoV14QuY2sS60eNue+nlzyE6sL/GYHV9DGvmrvjIzdZadB6mw
	5tu8sssA6WMAyAwYE19ji6DeTnDizMl74wZUZCxsGdqYRaZgPDi2f0/4QsEHXAqgwxasMEKxsg8
	KIQPGFl5lhdnY9Hl96qMQXqTC0+OYpHXD9nH4wEcpuvWl3HQQpBNxeunFQubBc8Mw+w==
X-Received: by 2002:a17:902:f216:: with SMTP id gn22mr10323844plb.118.1565220876109;
        Wed, 07 Aug 2019 16:34:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1ExbzLiHf/mJq2qrOD/V4Bt5NjO3xNojBPV+Q0B25NPJ4CwBKYFeQMRlbXkAutWstYpt9
X-Received: by 2002:a17:902:f216:: with SMTP id gn22mr10323803plb.118.1565220875250;
        Wed, 07 Aug 2019 16:34:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565220875; cv=none;
        d=google.com; s=arc-20160816;
        b=d+pGsLQRDxfH7l5s/BtzqbWNiz/Xq0d03lhYVlEiw1IbjyB/RD4aDO0sXzPqc/IVoJ
         uamUHAnh28dLIWJr+XG3wH1NrsAT6hDVU5aEwF3MVJyfaqbO+ssq3zONhYoUo9ly5h1n
         CXHIHTuxNTQ/0VGh+XSGUeK7ZNc6sQ2n/5tHCFtw4CkUBjjOU7yb6xTaN5ulxKrfcoK1
         mEW08SYU5dfn45QzerVDlLoH9hADKVELFP1QB7Yzxrf3hnWTb6+9FylFS/ttqcGY5hEr
         AmLfN0ECu6AIHwJrNuOd4+sxQGeLbMDxsMz/WONwyiA2dxWQ8l3vilOVXAhOn0JJVYAZ
         v8NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=aoh0mQBWSJjDZTkXsDLT7mSUCXnBIfsGxB12+qPVeX8=;
        b=vHcef0TQc+qBdUpOZWN8r6mFq0O4RAvi3x8DIQLuwky1Nhev9h6qscSKYDxfYf7/Ja
         pmWNHo51KnlVvRsIulfvkZdz5uekIs3LozpBkN/g8/6Yju0pt7TkG+9TgfZj1m2w3swS
         TgiwcX2poMkmuuLES4NjbEcIbeWN3Y9icvsUjACATcN2tl1PB8KeqNZsdVqX2yLsCvt3
         gyIR7A4M6lM2cpLhjpVtndBsvYdqWESo1AG48JohFCFmYd8YWPC3Jv5dXBjSohEnNMQn
         wLXPqhyPRqVmE7JnrmTEpRVWyHzoKyHZY5skzfU7SUveMgiAxLPCBKLEFAryjxo4cSCw
         d0fQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=p41wr3D4;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id l2si466148pjw.0.2019.08.07.16.34.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 16:34:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=p41wr3D4;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4b600a0000>; Wed, 07 Aug 2019 16:34:34 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 07 Aug 2019 16:34:33 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 07 Aug 2019 16:34:33 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 7 Aug
 2019 23:34:32 +0000
Subject: Re: [PATCH] powerpc: convert put_page() to put_user_page*()
To: kbuild test robot <lkp@intel.com>, <john.hubbard@gmail.com>
CC: <kbuild-all@01.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph
 Hellwig <hch@infradead.org>, Ira Weiny <ira.weiny@intel.com>, Jan Kara
	<jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse
	<jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>, Benjamin Herrenschmidt
	<benh@kernel.crashing.org>, Christoph Hellwig <hch@lst.de>, Michael Ellerman
	<mpe@ellerman.id.au>, <linuxppc-dev@lists.ozlabs.org>
References: <20190805023819.11001-1-jhubbard@nvidia.com>
 <201908080609.5QdIClpX%lkp@intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <eb413c9f-0328-271e-7599-a1c073504f1d@nvidia.com>
Date: Wed, 7 Aug 2019 16:34:32 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <201908080609.5QdIClpX%lkp@intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565220874; bh=aoh0mQBWSJjDZTkXsDLT7mSUCXnBIfsGxB12+qPVeX8=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=p41wr3D4+Y3n+Nm4ltunCU+D7vT5RXCg2yQ3Ba4WjuwRYBmZMjB+3Gub9GxPXVRU1
	 Zz9g/A5cFijCEOU7FRRcvhjF9VtLkqhmME/dEtR6fojjDyewaejxWsN54PGUGb+7nH
	 PdBWMc7o17ax0XC6D919YztkTPHTFLaKlvxr7ywRn2lyklERKBAwjcf12v0YU0EQSl
	 lOJm0Ih5EzqXqFr898tFVex/aGijitShEirMpg98XcSa5ANL2gw4wLaku9G4yg81PF
	 sUrhvTND8GCKzKYrE0pwBNgPaDyKMhmuzL18iiIYlTk0Oa8b//QA9vndZp6rHC2FlZ
	 3042+uGmLkG6w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/7/19 4:24 PM, kbuild test robot wrote:
> Hi,
> 
> Thank you for the patch! Yet something to improve:
> 
> [auto build test ERROR on linus/master]
> [cannot apply to v5.3-rc3 next-20190807]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/john-hubbard-gmail-com/powerpc-convert-put_page-to-put_user_page/20190805-132131
> config: powerpc-allmodconfig (attached as .config)
> compiler: powerpc64-linux-gcc (GCC) 7.4.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.4.0 make.cross ARCH=powerpc 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> All errors (new ones prefixed by >>):
> 
>    arch/powerpc/kvm/book3s_64_mmu_radix.c: In function 'kvmppc_book3s_instantiate_page':
>>> arch/powerpc/kvm/book3s_64_mmu_radix.c:879:4: error: too many arguments to function 'put_user_pages_dirty_lock'
>        put_user_pages_dirty_lock(&page, 1, dirty);
>        ^~~~~~~~~~~~~~~~~~~~~~~~~

Yep, I should have included the prerequisite patch. But this is obsolete now,
please refer to the larger patchset instead:

   https://lore.kernel.org/r/20190807013340.9706-1-jhubbard@nvidia.com

thanks,
-- 
John Hubbard
NVIDIA

