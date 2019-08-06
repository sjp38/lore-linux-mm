Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBBCBC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 13:35:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 778A520C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 13:35:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dfTE8QFW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 778A520C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE3406B0003; Tue,  6 Aug 2019 09:35:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C947B6B0006; Tue,  6 Aug 2019 09:35:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B82C86B0007; Tue,  6 Aug 2019 09:35:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 855C36B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 09:35:06 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z35so8566878pgk.10
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 06:35:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LSrTDhsJpuHztoZ1vcQuO446UAhMwmMAYnYunQdQJVw=;
        b=pJ6dxYQ3QG4gCKjbhtY6vWHPhxt6Xr8LjbNh9CNJNLVnAqhSBsKEjMxbKbGTN01/wN
         Zi7SO84TKrxeRWG9eFYfL9QC6wUbckOzuq1N4o/JpqzC6h1hyWzfxdGdmjRmqV/4pPpG
         Yjn3vGXYJNGb8fTrfwdOQvYG2aATL1iU0m3jvSjb1yWT6x4mE9S8EzakfrATI8WmzMcb
         mXU3i1rYl/gwOT2jxVWKBe/8HdqoVi/q4FhBy8T5RqK759OCIBoyxx7Qtk3UIvfqLPIz
         IrFVBn1pzMaVVElOCwRwjVnwzV+T4g3ywKmpL5XwPxby4LlhafzyDBRKfSsNNwNjfxw/
         MenQ==
X-Gm-Message-State: APjAAAUEtJWqaD5qdksPGBUUK9FZvFjkyJe8+EARuOgQkMDoeqgo1UTJ
	L7RjuUjGRk61X85fLnTT5YHrHftzqX/tUj2ZnkAvruD9nffIkFgoI0qVG8WpR9v6/EPPBgkQjhz
	1fkOlmkjIW2vNKYmlPTnT4g8fy4HKhtu1HmhPwAENgRuF7ulWKaV7HgzfNrL4l7edPw==
X-Received: by 2002:a62:d45d:: with SMTP id u29mr3687516pfl.135.1565098506165;
        Tue, 06 Aug 2019 06:35:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxD2x1IUQb+PSYuVzZ1W+cSs8YWYoU6QadM1Bo5SCgdXWpt5Uh7Eg1li4HUvQgI4wHgaOnt
X-Received: by 2002:a62:d45d:: with SMTP id u29mr3687455pfl.135.1565098505408;
        Tue, 06 Aug 2019 06:35:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565098505; cv=none;
        d=google.com; s=arc-20160816;
        b=vXLcNOlRmZ75pXczuNb2DBUMeqjvjuYiXsK1hTz5dBCrbsRuhlQknnDMGZOB/2jdHu
         9QqiVV56IrPlzUjCi25RA2w5wSjts4TdAt8eeZS+JqmxOj5l37WmhMuCMhepCGWzqxUj
         ewqQA6Df5S5g6K9kgVxLUwMdsslzxi/f6TpzXU/NMvxAyWhLB1fPA0pl1Uh3aPkMkpPu
         ppQX3j0wPdYWhhZCP4E27dlHM+Zs9zrdeTNSU57y7PLAGU5bOD4QcAid7YRxPStAdxkh
         m36vjs97P/ip5SEbMbKFApx/fnLipAwx0EssL60h5tRVMTHsMtnAWsX1WsN6BkWpHgjb
         NTVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=LSrTDhsJpuHztoZ1vcQuO446UAhMwmMAYnYunQdQJVw=;
        b=EnBbCIvWOxhv8zJM6+S2tkH2DQBAVMpP4ConVDtacEe86romr8Aao1vXhyS/d5Klp2
         usbODMzp1nOskB374EIEJVqAhoRD8lNv0qQti+iK/WsNspcO1rY2ASILxZpuk6BfTBrC
         43xO352A2e0lB1UN9MZ48WUBXonC/TPtPIIIZyPYGJajnTkwx6NJZa4SANlCOq6zIQ2S
         TjAb8lL3DUGWYOtc5ucw/NES3ZYbsVQtR9AaEv/Jr8o2xgOSesZn64zJoXqrn2jbEDvB
         JdSJTK1bmnUw9GclwbmhrsACT0Tu2+XZXEBEDeVA+nhBqDMtGngeqFafzJRTJVNXaTlP
         t1XQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dfTE8QFW;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o63si15028780pjo.94.2019.08.06.06.35.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 06:35:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dfTE8QFW;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=LSrTDhsJpuHztoZ1vcQuO446UAhMwmMAYnYunQdQJVw=; b=dfTE8QFWDKasKNrl8PXCKENnA
	IsKrDnUGP/zpSEhJ0QG5ygHuuJTq3B7DlBi+/eJWeBsvzw8dnTtST1kAD3YyRToBtRJP58aeFUkiB
	3+HRTgVlp4K8xeDLEison7I8LUYJzN3p7U7CWFDZb7K/qvO/C8zZRSiIQHkz+hR0W88uBNtqkGpe1
	Ppo6E5ronvOPCj5A8eBSS4I6gwTQ6BRzRzAeoXB2LvkUug8dmGHFuyFsE1IBOgJAViCJagElvFJgJ
	iAMHMYibhwEkKHFLQBQdjiRlRVhKF2doWfHNqHwVh8YNPrflGEylFt9NBAx6TV5/ZlXTEVvfpBxWM
	VFYR7EQTA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1huzcF-0005L9-Op; Tue, 06 Aug 2019 13:35:03 +0000
Date: Tue, 6 Aug 2019 06:35:03 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/3] mm/migrate: clean up useless code in
 migrate_vma_collect_pmd()
Message-ID: <20190806133503.GC30179@bombadil.infradead.org>
References: <1565078411-27082-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1565078411-27082-1-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


This needs something beyond the subject line.  Maybe ...

After these assignments, we either restart the loop with a fresh variable,
or we assign to the variable again without using the value we've assigned.

Reviewed-by: Matthew Wilcox (Oracle) <willy@infradead.org>

>  			goto next;
>  		}
> -		pfn = page_to_pfn(page);

After you've done all this, as far as I can tell, the 'pfn' variable is
only used in one arm of the conditions, so it can be moved there.

ie something like:

-               unsigned long mpfn, pfn;
+               unsigned long mpfn;
...
-               pfn = pte_pfn(pte);
...
+                       unsigned long pfn = pte_pfn(pte);
+

