Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0039CC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:46:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA4542171F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:46:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA4542171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48F886B0003; Thu,  8 Aug 2019 03:46:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 440106B0006; Thu,  8 Aug 2019 03:46:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32FB66B0007; Thu,  8 Aug 2019 03:46:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D9EF26B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 03:46:09 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y3so57670337edm.21
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 00:46:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6+0izh6Cmd/zTbWxm1BpS6osjegvRuRSpsJSjXytnNg=;
        b=SI0hnDe+9vtuW059KRTZ5gsh7wOGyod+g2Eqt4KjQv5alu4C+7VGtjpF9JjUiNGFtM
         +r0dHHQDc6vB8YDdRNdlFsBTo8/8AFt1XAycsfycO9Ra8B0+6Sa4nQMXLhhKtjhY83ki
         wDdgO+IYTlWJ9HZdlbq8N6mgGylhrYY/O+N3ojwLiFIpm7U19vAGz2rDRdjuoWP3KTCm
         QGpX9+6Aai7n+oMFRYaYcEHoJ7YHIq4DVgtZAPlvBWXHpnj3ds+OdISE+KWaszaoz8J1
         zTpdGM/3tuczdAWp6pJbDii0OjsNPaK26mWChpy/4ipQZ8ygo2xNhR4UQj+xzFyvw2tq
         Liew==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWdVL2fuG3/ki7H3wRjVXjTVXUSdeXSEmWErBbjPo/zPNcsrXne
	3QV7aoDckBlf9JRAk7IyH68uAaVFhdRA8NKW5ciQjqSIXAd3ZRNgYEqDDFdM2hAngLnVofziASy
	BWP0gqZriONLhIfmbJM3C2Yo3ctSSJJaekmeWlnU4FfwdIXRipjy7N4i2F+wAoWI=
X-Received: by 2002:a50:9846:: with SMTP id h6mr13962712edb.263.1565250369455;
        Thu, 08 Aug 2019 00:46:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrxoEKah0CBpbh6T7urZaHV07uearNx74WhxyVri6drF2u8GYMQu/ejgB0IBgGmLgE2ktM
X-Received: by 2002:a50:9846:: with SMTP id h6mr13962659edb.263.1565250368731;
        Thu, 08 Aug 2019 00:46:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565250368; cv=none;
        d=google.com; s=arc-20160816;
        b=X4pkpaY330Q0JyOHmyohiWndmC/GGMKsqM6CU4tGGTk8WDKMn1aa3VCjyIN6Isa1CX
         /+0eGq03p8RV5jqcZjOy5rlNsE7+18fbfn6njhRVakduWiLe5RAzsJzxvS/dThgKX/gY
         0iAMdRPOs64FuS3CyoBvY9H/BLInxxbSzQD7z5+FGRS/8WdP+he0+noz/4uCAKx4rKxF
         gs6RyC2W2RF2mFNOinubrNkx5f9XbmQLJKJ6UYbsQcYlOpOhEQx/uAY8gF90KHD23rxh
         B8b/HUD2znhfpOsKsn4lFzz/iqtekdEVfHb/UsiDfo8B28P7o+Gnq3qxRVg0tbNElTxp
         AWXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6+0izh6Cmd/zTbWxm1BpS6osjegvRuRSpsJSjXytnNg=;
        b=FFWGo12abdeNOdFg1Gv+kFfOARdIkb+A3vkyDZJqyPM7ezbTW5uRwlljdhCQRFbJh1
         OTCOtIMOC4gUJLJ965SCGOYv6sxfkge7CgL0d54OwdChDQnZDdP19nncW2PbmazaWIGS
         yJp2mNql/o5Xqmfke5yE742QddUlw9FZzIG/EbcVrBGCNCIUfkL36iNzGUK0Bi6C60QS
         JN31h9H1HwVICdVPgXYnaKAhxnhgiYADnNx4vQDluedHs31ip1b31E2dqTNOj7OzXJ5m
         34Ne5qq2NVaMayjNXzJS5prsuQ4q301nKtqWJZVQQznGDT2QzBB65GXMnU+mArvn8vA9
         80Kw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q18si30881719ejz.39.2019.08.08.00.46.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 00:46:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 36F83B11C;
	Thu,  8 Aug 2019 07:46:08 +0000 (UTC)
Date: Thu, 8 Aug 2019 09:46:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ltp@lists.linux.it,
	Li Wang <liwang@redhat.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Cyril Hrubis <chrubis@suse.cz>, xishi.qiuxishi@alibaba-inc.com,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlbfs: fix hugetlb page migration/fault race causing
 SIGBUS
Message-ID: <20190808074607.GI11812@dhcp22.suse.cz>
References: <20190808000533.7701-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808000533.7701-1-mike.kravetz@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 07-08-19 17:05:33, Mike Kravetz wrote:
> Li Wang discovered that LTP/move_page12 V2 sometimes triggers SIGBUS
> in the kernel-v5.2.3 testing.  This is caused by a race between hugetlb
> page migration and page fault.
> 
> If a hugetlb page can not be allocated to satisfy a page fault, the task
> is sent SIGBUS.  This is normal hugetlbfs behavior.  A hugetlb fault
> mutex exists to prevent two tasks from trying to instantiate the same
> page.  This protects against the situation where there is only one
> hugetlb page, and both tasks would try to allocate.  Without the mutex,
> one would fail and SIGBUS even though the other fault would be successful.
> 
> There is a similar race between hugetlb page migration and fault.
> Migration code will allocate a page for the target of the migration.
> It will then unmap the original page from all page tables.  It does
> this unmap by first clearing the pte and then writing a migration
> entry.  The page table lock is held for the duration of this clear and
> write operation.  However, the beginnings of the hugetlb page fault
> code optimistically checks the pte without taking the page table lock.
> If clear (as it can be during the migration unmap operation), a hugetlb
> page allocation is attempted to satisfy the fault.  Note that the page
> which will eventually satisfy this fault was already allocated by the
> migration code.  However, the allocation within the fault path could
> fail which would result in the task incorrectly being sent SIGBUS.
> 
> Ideally, we could take the hugetlb fault mutex in the migration code
> when modifying the page tables.  However, locks must be taken in the
> order of hugetlb fault mutex, page lock, page table lock.  This would
> require significant rework of the migration code.  Instead, the issue
> is addressed in the hugetlb fault code.  After failing to allocate a
> huge page, take the page table lock and check for huge_pte_none before
> returning an error.  This is the same check that must be made further
> in the code even if page allocation is successful.
> 
> Reported-by: Li Wang <liwang@redhat.com>
> Fixes: 290408d4a250 ("hugetlb: hugepage migration core")
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> Tested-by: Li Wang <liwang@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/hugetlb.c | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ede7e7f5d1ab..6d7296dd11b8 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3856,6 +3856,25 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
>  
>  		page = alloc_huge_page(vma, haddr, 0);
>  		if (IS_ERR(page)) {
> +			/*
> +			 * Returning error will result in faulting task being
> +			 * sent SIGBUS.  The hugetlb fault mutex prevents two
> +			 * tasks from racing to fault in the same page which
> +			 * could result in false unable to allocate errors.
> +			 * Page migration does not take the fault mutex, but
> +			 * does a clear then write of pte's under page table
> +			 * lock.  Page fault code could race with migration,
> +			 * notice the clear pte and try to allocate a page
> +			 * here.  Before returning error, get ptl and make
> +			 * sure there really is no pte entry.
> +			 */
> +			ptl = huge_pte_lock(h, mm, ptep);
> +			if (!huge_pte_none(huge_ptep_get(ptep))) {
> +				ret = 0;
> +				spin_unlock(ptl);
> +				goto out;
> +			}
> +			spin_unlock(ptl);
>  			ret = vmf_error(PTR_ERR(page));
>  			goto out;
>  		}
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs

