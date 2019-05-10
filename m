Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0E9EC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 23:59:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9141420820
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 23:59:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9141420820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD0C26B0003; Fri, 10 May 2019 19:59:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D80136B0005; Fri, 10 May 2019 19:59:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6ED46B0006; Fri, 10 May 2019 19:59:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE536B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 19:59:12 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so5185659pfn.8
        for <linux-mm@kvack.org>; Fri, 10 May 2019 16:59:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FAeI3XXD4u5Wy4a3OsVoY/iFy64+Ukex/xW/1KMAPVE=;
        b=hKj6sMNU2pGOTj7sQmDAc8mOc5EBEzxtkODkFn7t6JxD0P0Yo3/Fm2YGtGuOvlsqB6
         lBU9u4QK21X3WXXY2Beq53c+or5wpH0obiNgoF2o6vQAzFwdcSUzRK5PV+GZ5bSYiC2E
         4MdeCPB/9Pbpe18G07swLj6/dsD+Ou6T+28pQa2Hee7HDRVb422AjTwyYajXeV4/yWCv
         2Tq+Dby5eJ5yDDMjck9gj7xpQ+maBR0HluW3zrvpjOhaXpR+Kq1BjGJauZC8UzCIwfNe
         GMSgZ34u59hC7K96nhSampIgn/YOECkTjrPfiUbkEbXf5AOk5b9ArZU83zdWGo1wAUN8
         iJDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUyVjhTbkQ2E+O1wlSv0aBtZyJ3jNdS0zSnXcqyPx/R+6CnjLyK
	RGt2laZcC5MY6mk/xBCIlxqwjwSzW/mxstRGkOmk4nT54QO/ztv8UHueI9qoe/YdynW1fz37Rbm
	ysFgcpMhfSQAonVOPZa3uIDc4ydEByqFjwtI9w/CGfBLoKGDihWWTtgtZ08rtV+a6ng==
X-Received: by 2002:a62:6842:: with SMTP id d63mr18154627pfc.9.1557532752144;
        Fri, 10 May 2019 16:59:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6FyC7odDUnhAF7eZpIU0FFx1593qEgFty+GRVGspCsO/BciMhNf132jyms6rLop+l4hCr
X-Received: by 2002:a62:6842:: with SMTP id d63mr18154588pfc.9.1557532751316;
        Fri, 10 May 2019 16:59:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557532751; cv=none;
        d=google.com; s=arc-20160816;
        b=ePhnuusE2utx3mAns0cdMNZ05kaoAmnO0A+7bc4p5qXe2amfLwor8A/HRLzRYHnQ85
         T8v+xFGw8gb/0EAvz0+oiKE/jlSkI6Ia6iH2eVDtBNtWBHy3kqMTdbN8/AHpqGufwara
         dklGYfejAxyAPeBf8XzoaFRQS9DmmhXwRkSnYf1EQeBtvIOxUoQyFj3bwQIaQCU4cF9z
         5nmn12tOx9FsxiAQgeD6Mr+HGhRvi1qtokJYHIzplSFbTa2WMu9qFmQa5a70rV7sm602
         6ITulvxJPN7nEMaeVwJQRx2aGlRkPP+Gf3OIpoK8y70JcRCs0J+yPOxeTnxOcI0+09uS
         YIUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FAeI3XXD4u5Wy4a3OsVoY/iFy64+Ukex/xW/1KMAPVE=;
        b=mDhaT2WGVKhxDa/fv49T11ATkF5USnj1Y+KIsd5ywmiOqqyQS6OrkEA55/w8sZPWyl
         T87dVVGVd4jm4OX4HIVxpb/0A9VZVBISvD1gBCaScGC9pCDXDkXVnrV89Tg6Hz4mMtXX
         1kwoesp1f6YDCCCXDYqF/nOpUiR/DRfC0yliy2hFeSFoQCng9qbZm2JGyyTHJIgFGBIw
         f7cpDXIxwZ+UKLKDVut8a/Ca0GMT1iaGtzIKmrWH5XrBOCHVAiOzjnlilHw/GPhEw4Hz
         e/Brty0nexIPZpSawRUPoB1W2EB3mpo6kbm1v18rxWrKqioWI2B3dJWvCNpgQ0sVYyXm
         rQLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id r9si8437903pls.323.2019.05.10.16.59.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 16:59:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 May 2019 16:59:10 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by FMSMGA003.fm.intel.com with ESMTP; 10 May 2019 16:59:10 -0700
Date: Fri, 10 May 2019 16:59:47 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: akpm@linux-foundation.org, jack@suse.cz, keith.busch@intel.com,
	aneesh.kumar@linux.ibm.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/gup.c: Make follow_page_mask static
Message-ID: <20190510235946.GA14927@iweiny-DESK2.sc.intel.com>
References: <20190510190831.GA4061@bharath12345-Inspiron-5559>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190510190831.GA4061@bharath12345-Inspiron-5559>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, May 11, 2019 at 12:38:32AM +0530, Bharath Vedartham wrote:
> follow_page_mask is only used in gup.c, make it static.
> 
> Tested by compiling and booting. Grepped the source for
> "follow_page_mask" to be sure it is not used else where.
> 
> Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
>  mm/gup.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 91819b8..e6f3b7f 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -409,7 +409,7 @@ static struct page *follow_p4d_mask(struct vm_area_struct *vma,
>   * an error pointer if there is a mapping to something not represented
>   * by a page descriptor (see also vm_normal_page()).
>   */
> -struct page *follow_page_mask(struct vm_area_struct *vma,
> +static struct page *follow_page_mask(struct vm_area_struct *vma,
>  			      unsigned long address, unsigned int flags,
>  			      struct follow_page_context *ctx)
>  {
> -- 
> 2.7.4
> 

