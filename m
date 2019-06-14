Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8503C31E4A
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 01:48:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C1DA21537
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 01:48:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="I8MPAgx2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C1DA21537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 343D86B000D; Thu, 13 Jun 2019 21:48:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F49C6B000E; Thu, 13 Jun 2019 21:48:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E51A6B0266; Thu, 13 Jun 2019 21:48:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id EEA1B6B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 21:47:59 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id g7so288527ybf.10
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 18:47:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=W7HIzAAq5sQ4cds9yVoSXH+lwR7EoHWX9W6ILDXWS68=;
        b=BlwTjhdI1isOSYkBjcb3eDQ5hrWnsG5X4mK93DRgpOck8Hx3XyCKeznu+wikLl0gV3
         WMazfg2QcW/nlzK44jHZU+jeKDhfI9lDDExVpkakTRcig61Rx437YVQAt4pmeBwWkzT8
         IqkNp/4v6ZgCXZLc43WJ0auvL5hKcEtVagkWtAiuVlAXErkzaHMQbGJfT/RzAGTlqkLM
         LhqlqC1TS8+vJt21dXKibOF+beKQVe5JJNeJciaWDWPG/lfVipCtbQ5jGckN3dIiGpMR
         oUcDdUsAvyZ46DghZk2YLQQUnC3eeEzIsEy1LtaoLv0zjxJlac8yMHAivOpMsb0UEjv5
         bEsw==
X-Gm-Message-State: APjAAAUdVfL780rnkbG1KJbCWo9UmfWKWOkwaO64Z5Ati+XkEGgvthQU
	NV/Tsxhzx9HDNA9Gj6Jomodi7awa4TZqSSGxLMGzzoDAkKQSRvD4ejOE/QwBpxotC/t6rTqkYSJ
	VJPQp8kBUJgaKybiuOTDTtTxdiPltQrnS0e4LlrZz9kFn1bYcBepYnPswTmw8V91npA==
X-Received: by 2002:a81:57ce:: with SMTP id l197mr51085431ywb.115.1560476879704;
        Thu, 13 Jun 2019 18:47:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxdLf/mBgNecwHhn5WPDIo8Gt6ntxKgMPrbuk8T6+8Da21Jf0296jPf7Vdt2Li7KtBqT+b
X-Received: by 2002:a81:57ce:: with SMTP id l197mr51085419ywb.115.1560476879282;
        Thu, 13 Jun 2019 18:47:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560476879; cv=none;
        d=google.com; s=arc-20160816;
        b=ZazyuHUod0mfMyQQ2d+VpGvarAD2GMBcl4EetbRCVuobzYhURIlV1cyr355QCmFw4X
         SFTWTYtAi7VQm0kpoOJzZ4lol16StTgeDzOgcch2BexKAQhhAvgaILTIco21vKnacbxo
         UF7/zYkVaL8wL8RVAXbCRCY9QozNrjS8ZKGZ4fJe0dhZCpaJ7lJgme0oPBPB188X3+0J
         DMODEMhZL90JlkjjnoqecKZjzgLiwB2OKpvPW1jcrtwcp5BaHXhFwWXGmGZxs1u3dCDs
         iM32L/9d6Qc2I0V0cJuM+MYFqg5oZcLbCTwJ0wK9TT6fUMeF1ANWD34w99dwrncff1Ra
         HFFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=W7HIzAAq5sQ4cds9yVoSXH+lwR7EoHWX9W6ILDXWS68=;
        b=YQsW6qgHbmsKF4Lp9bPRH1eRW3S/FvEcO+renPEnfY40GO6mDbQ++hcvhqnYSqiT/E
         hkn4J/F+pyVwff1o5gSjz7WgViUJXv+2BYThcWRBRbxgQpusZ0mhoMGrA2xH+a6PD0sA
         0THQfaJBw6Fj+sAf/N39uqRYPEX5YCIqQw7KOJO7EhFt0q4LkMR+qlJaCL6iELgj2yur
         cY730NOSIjPiURfwGZEKHR0ewzfw1cyUqt9D+4jDO5CLcV+XavpdnoYyX44tDZe55BD8
         RKE6efsq0luYdJTRLHrRYNW5tvIY77COhjMp36R/0NL6/TWH5E8R37ueUEwTX1qfbk2c
         kAgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=I8MPAgx2;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id s67si490191yba.270.2019.06.13.18.47.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 18:47:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=I8MPAgx2;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d02fcce0000>; Thu, 13 Jun 2019 18:47:58 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 13 Jun 2019 18:47:58 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 13 Jun 2019 18:47:58 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 14 Jun
 2019 01:47:57 +0000
Subject: Re: [PATCH 05/22] mm: export alloc_pages_vma
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
CC: <linux-mm@kvack.org>, <nouveau@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <linux-nvdimm@lists.01.org>,
	<linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-6-hch@lst.de>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <d83280b5-8cca-3b28-1727-58a70648e2b9@nvidia.com>
Date: Thu, 13 Jun 2019 18:47:57 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190613094326.24093-6-hch@lst.de>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560476879; bh=W7HIzAAq5sQ4cds9yVoSXH+lwR7EoHWX9W6ILDXWS68=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=I8MPAgx2vYT6KwhZqE7Iz0XmBDUAPkhjJ2muXoBXvyuvRRzqt+N/vYMC8nbdYG25/
	 WSlmXfyDpPT5QeLCb+OCPbYjTfqvYqP4DCyLjNUFaxdOx4cGM1afGuLLi0esWZSgMu
	 A8GQ9BiCgUF44kc2o88bVgpXE3mC+ZezmwWJQmLHcMqWujgPfAbqMUvlo+s7Iiq7sU
	 WHoYSAAnR0/4orH9jeAbwNklddZnxg4UewSkrDUWY6MGnu9yd4bNKuRV1sh4wBzCNg
	 U+IAYEyyzX1/h2C96Uiqk0lQ+n/ZSuk409t8qWCUpSU856fphT2d9dv2ddj3jG5GUT
	 /1wLT1eB7j1+w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/13/19 2:43 AM, Christoph Hellwig wrote:
> noveau is currently using this through an odd hmm wrapper, and I plan

  "nouveau"

> to switch it to the real thing later in this series.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---

Reviewed-by: John Hubbard <jhubbard@nvidia.com> 

thanks,
-- 
John Hubbard
NVIDIA

>  mm/mempolicy.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 01600d80ae01..f9023b5fba37 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2098,6 +2098,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  out:
>  	return page;
>  }
> +EXPORT_SYMBOL_GPL(alloc_pages_vma);
>  
>  /**
>   * 	alloc_pages_current - Allocate pages.
> 

