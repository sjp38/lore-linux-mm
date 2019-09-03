Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3D63C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 13:12:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9D822341E
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 13:12:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9D822341E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 154926B0003; Tue,  3 Sep 2019 09:12:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 105F96B0005; Tue,  3 Sep 2019 09:12:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 043306B0006; Tue,  3 Sep 2019 09:12:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0061.hostedemail.com [216.40.44.61])
	by kanga.kvack.org (Postfix) with ESMTP id D45A66B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 09:12:50 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 68731824CA35
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 13:12:50 +0000 (UTC)
X-FDA: 75893649300.21.book43_35d977ad43657
X-HE-Tag: book43_35d977ad43657
X-Filterd-Recvd-Size: 2341
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 13:12:49 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6DFE6AF38;
	Tue,  3 Sep 2019 13:12:47 +0000 (UTC)
Date: Tue, 3 Sep 2019 15:12:46 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Kefeng Wang <wangkefeng.wang@huawei.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: do not hash address in print_bad_pte()
Message-ID: <20190903131246.GX14028@dhcp22.suse.cz>
References: <20190831011816.141002-1-wangkefeng.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190831011816.141002-1-wangkefeng.wang@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 31-08-19 09:18:16, Kefeng Wang wrote:
> Using %px to show the actual address in print_bad_pte()
> to help us to debug issue.

Yes, those values are of no use when hashed. At least __dump_page prints
mapping directly so there is no reason to differ here. anon_vma doesn't
really disclose much more AFAICS. Printing the addr might disclose
randomization offset for a vma but process usually doesn't live for long
after a bad pte is detected so it should be reasonably safe unless I
miss something
 
> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index e2bb51b6242e..3f0874c9ca38 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -518,7 +518,7 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
>  		 (long long)pte_val(pte), (long long)pmd_val(*pmd));
>  	if (page)
>  		dump_page(page, "bad pte");
> -	pr_alert("addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
> +	pr_alert("addr:%px vm_flags:%08lx anon_vma:%px mapping:%px index:%lx\n",
>  		 (void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
>  	pr_alert("file:%pD fault:%ps mmap:%ps readpage:%ps\n",
>  		 vma->vm_file,
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs

