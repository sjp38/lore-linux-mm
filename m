Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8530CC46460
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 14:48:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D0E521530
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 14:48:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D0E521530
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 991E16B0005; Mon,  6 May 2019 10:48:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 941096B0006; Mon,  6 May 2019 10:48:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 830066B0007; Mon,  6 May 2019 10:48:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 31A0A6B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 10:48:52 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x16so12373408edm.16
        for <linux-mm@kvack.org>; Mon, 06 May 2019 07:48:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OW9mMR3aRNe5ztpkQ0JSKuvyvJh6tD06EQ8JynNcLrc=;
        b=Rl2m1iCn+GCI3CsfdTmiefwrItMJDxoVhEmf4165hwrtxCayGyurXMq5DWPFYvlq1t
         FzwatRSBqrQJz75ptadyYcxKoxgi33H47HfItjooONNRI1FFllN+JDFNKsi/roHdk/vi
         GP2RlFMB4+JkwtBdrantCO+RLUfqxufCDZyMU+/A4Mtyc8SrcVI9N/WxbO7qzo9ClwpD
         LTM7TJ2nT1D6w5k7mcCgHpDnELUaSE3gvhq3tbpV4MLFh7Hg84DpTueIdFD5CiihUr4W
         t7mzdfwEeLrCAlzepituAGUDDK7/u/l1aOxbjjgukiJcYGxmwuCZ57XdLzVOp92nK9WY
         CpkA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXnve1CnEzOkKDsNPmeuRK0HD2t/QBIGHXvqkAmF9ZNpIRYbSvC
	De8ugvK4ADIBPb7+UuiPHg8dsw0pXAHdu9ovjwm3chL4rrdF0xTneHRIXe9BnGTBSFS0rNysaFN
	XcYAHj8jHm5tiApGi13Ia/8u703olgdNTG/jrRJugWq7gLSn0DExHLv/FOuVlTdfFcw==
X-Received: by 2002:a17:906:4f87:: with SMTP id o7mr19867404eju.11.1557154131766;
        Mon, 06 May 2019 07:48:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjRZMzTzUGvDAQqih2SjujsPaV/OCmrsC7pCx0vpR76xe78hk18Bu2hqUw1T4/VQISHlrI
X-Received: by 2002:a17:906:4f87:: with SMTP id o7mr19867303eju.11.1557154130521;
        Mon, 06 May 2019 07:48:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557154130; cv=none;
        d=google.com; s=arc-20160816;
        b=I4TNV8v5rz9oQ+2lVdfHjPKcHK6/gmTDxZDmKgPjEGTMIcwIo01E/EWx6OSLkRyZHO
         ugoIQKtJ7GpWLVEmtjoHPIYNAd9ZKyBajjQlP3SSeZyn7oi9b5j1O8raSMeQHCs7XyeV
         pFul4kiJqvHwnOjfp8x6vzLC/C3nOcANJAjHxQbMTsiLOoIYrbviamfF5hBLIKfPI/KC
         yQvDt0Hq2y2ABh1+Pf/KTdlWf95WI9jmaItjapiTEqiQP4W+LKZZgQDwYt+vyvU/7GEt
         fyrjWgF/wKdlQYw0fGwFXiH2gqjlm9bBRUIZ4IFmu9Doypmab87mrmTiUPDXyV1/S/R/
         6xfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OW9mMR3aRNe5ztpkQ0JSKuvyvJh6tD06EQ8JynNcLrc=;
        b=x0q7FvKIOlLG7IXQO+acBUWn7gC34bRZzgbLyAPgTeYwyVgFU4qBgJly3Kd6QdeWcN
         UuTKJ5Ud/7xCVlM7rqckvj9eB3Noppm9TSed3jWxRo+JNWeEmDWzl+qonSHJT1kGkmd2
         BD5SyrtJQr7mk8XyaWPIDIBnYdQ17P2twIg6Y1UMQZFPds0i2BNHr4ZJng6q+DC2Upy+
         fbjKGcQoHFDv1KLa6CavbORA80bnndUO2yUCzGghxMgTocnk/7DcWsvMACr0+C9awm2x
         5n9d4Q/Fn+8I1yOL+mbaQtuP+/uLp9Nli9lvd0eJ3JVcvfVB2uLe7NjPRBUthRziUA5a
         tiBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 10si5083900eds.443.2019.05.06.07.48.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 07:48:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7C17EABE7;
	Mon,  6 May 2019 14:48:49 +0000 (UTC)
Date: Mon, 6 May 2019 16:48:46 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Zhiqiang Liu <liuzhiqiang26@huawei.com>
Cc: mhocko@suse.com, mike.kravetz@oracle.com, shenkai8@huawei.com,
	linfeilong@huawei.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, wangwang2@huawei.com,
	"Zhoukang (A)" <zhoukang7@huawei.com>,
	Mingfangsen <mingfangsen@huawei.com>, agl@us.ibm.com,
	nacc@us.ibm.com
Subject: Re: [PATCH v2] mm/hugetlb: Don't put_page in lock of hugetlb_lock
Message-ID: <20190506144835.GA10427@linux>
References: <12a693da-19c8-dd2c-ea6a-0a5dc9d2db27@huawei.com>
 <b8ade452-2d6b-0372-32c2-703644032b47@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b8ade452-2d6b-0372-32c2-703644032b47@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 10:06:38PM +0800, Zhiqiang Liu wrote:
> From: Kai Shen <shenkai8@huawei.com>
> 
> spinlock recursion happened when do LTP test:
> #!/bin/bash
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> 
> The dtor returned by get_compound_page_dtor in __put_compound_page
> may be the function of free_huge_page which will lock the hugetlb_lock,
> so don't put_page in lock of hugetlb_lock.
> 
>  BUG: spinlock recursion on CPU#0, hugemmap05/1079
>   lock: hugetlb_lock+0x0/0x18, .magic: dead4ead, .owner: hugemmap05/1079, .owner_cpu: 0
>  Call trace:
>   dump_backtrace+0x0/0x198
>   show_stack+0x24/0x30
>   dump_stack+0xa4/0xcc
>   spin_dump+0x84/0xa8
>   do_raw_spin_lock+0xd0/0x108
>   _raw_spin_lock+0x20/0x30
>   free_huge_page+0x9c/0x260
>   __put_compound_page+0x44/0x50
>   __put_page+0x2c/0x60
>   alloc_surplus_huge_page.constprop.19+0xf0/0x140
>   hugetlb_acct_memory+0x104/0x378
>   hugetlb_reserve_pages+0xe0/0x250
>   hugetlbfs_file_mmap+0xc0/0x140
>   mmap_region+0x3e8/0x5b0
>   do_mmap+0x280/0x460
>   vm_mmap_pgoff+0xf4/0x128
>   ksys_mmap_pgoff+0xb4/0x258
>   __arm64_sys_mmap+0x34/0x48
>   el0_svc_common+0x78/0x130
>   el0_svc_handler+0x38/0x78
>   el0_svc+0x8/0xc
> 
> Fixes: 9980d744a0 ("mm, hugetlb: get rid of surplus page accounting tricks")
> Signed-off-by: Kai Shen <shenkai8@huawei.com>
> Signed-off-by: Feilong Lin <linfeilong@huawei.com>
> Reported-by: Wang Wang <wangwang2@huawei.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

