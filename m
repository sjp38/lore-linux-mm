Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE577C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:50:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DA6620665
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:50:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DA6620665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 255608E001E; Thu,  1 Aug 2019 10:50:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 204208E0001; Thu,  1 Aug 2019 10:50:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F3668E001E; Thu,  1 Aug 2019 10:50:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E29978E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 10:50:36 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s9so64934383qtn.14
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 07:50:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eY99JqEF+0hCtDjU1Pkoo9xqtD6OPHdr/RzCi0NrgNk=;
        b=mNGig8k3EZw4QjJAZphVxD38XBxZk2nUH+XxWkuYmnFNiSynY2M318S4YtzNvXWu3Q
         DB9U2xYMQJn3nxZvLWrNZAzJgCbta3ZIvzetqJWBOz/tdn+QBartGPN/wFcILYxx8/mL
         QadMim8+s80Qpgu+MVuh5G97fqq7qCO84FD/ewnrLkqQB/7U7g9rnZXeiLQLhwOOgOj9
         5wNZsC4oEVSBEWE0+SpxHTHRgobbAOUKDdR4cfD/ku7x348bDHY1L4xQQ6kJVjQJ/Ibv
         ViINyhUsWz/BFHJNg2Z8BxKDl5PIoEN8lOwd0taHOJHmD2a7v4Ht6SafK2G5rH8BXpPn
         2ufw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUEbNO1DvaiiRCikX/z6TZqyn0kIGUdvZU9kxRBZmakCTpa20++
	23t8RxgmWXBFqTAyE4u2mMxefcxEXH6QxvBsON7HiDtnffPg7ntbENlp9IWQ/ZjoIbdEs+GqBjr
	1dIO1IenNMY+grlgWFZyjVCAuFuMN+qxjcYZUl2ZZ6Vvm7QQiG+n8v4pS3guUARC6kA==
X-Received: by 2002:ac8:d9:: with SMTP id d25mr91927762qtg.29.1564671036684;
        Thu, 01 Aug 2019 07:50:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/J923cGWTfaN4FgEaX+xXK/w6tCwxLW4uPl+7FwGwsAeBQWPAC6nmlCkZ2hzZWX1lVvaC
X-Received: by 2002:ac8:d9:: with SMTP id d25mr91927709qtg.29.1564671036033;
        Thu, 01 Aug 2019 07:50:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564671036; cv=none;
        d=google.com; s=arc-20160816;
        b=RIpPsteSYUxuS/rpew7SSlVPJtONmvSw+lmSIjhjlBrSVDRAxcrREaTq/PyYsbNeOP
         QgqOz6V4Xi9rSfsw78UNfKIZuNJkeXWNJDBxTcpiuz8zRrAaC26Qout0pDyH54B3pYTX
         h++cAWzQ58TkLSRlsKrMmRWCzQ7TIe9nT6T3+SOqp3wwdxYFEIhaaF3/Vy2hQsMDPp8f
         9/aJbgfbM4lWWsxI6BrxoTU+4kUJxcQnQOz9SC11f/4+n3jdAEDY1GIYbDOd5l5VILba
         y7K+jafEuBgS1NMUsxuSGV8WqucM18R0w3JIxtZOaPHJxmj2RA9S9QfDdQ2CMNvFbkcJ
         Sl8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eY99JqEF+0hCtDjU1Pkoo9xqtD6OPHdr/RzCi0NrgNk=;
        b=gdZTVpzytfhNe0IS0RmOSEEhyjWC5ZJvl0iNNXENb08Ez1gFDggeHnf9xEYebcVVz5
         4P5N/23uXLe6B1ZKt4QO98uqc2GrB8idLrRmkIvdxIfiMW4IsgEoI0RArLr5hDEZzwtQ
         4TT6f3xPmMmRXfSxEtdMHcjtjIQR8dMwxyWgCx3MVrxS5J3EeD0TTABU5p/t2+RZhAhy
         lOEHfJQXd8py4pjFdkUke/zFzR3NLb/Qnndz00/tV1cpdmvHWOLQvkzs08QvqbTo/oJv
         lYP9VPuD+liCTI6t12LxMyILeVq4t3BCfIRmpKkaoCuPSXN+HzrLxps+iphIMHrX6sRB
         Qy5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j6si36396537qkc.61.2019.08.01.07.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 07:50:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2F8822D0FC7;
	Thu,  1 Aug 2019 14:50:35 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 5531B5C207;
	Thu,  1 Aug 2019 14:50:33 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Thu,  1 Aug 2019 16:50:34 +0200 (CEST)
Date: Thu, 1 Aug 2019 16:50:32 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, srikar@linux.vnet.ibm.com
Subject: Re: [PATCH v2 1/2] khugepaged: enable collapse pmd for pte-mapped THP
Message-ID: <20190801145032.GB31538@redhat.com>
References: <20190731183331.2565608-1-songliubraving@fb.com>
 <20190731183331.2565608-2-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731183331.2565608-2-songliubraving@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 01 Aug 2019 14:50:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/31, Song Liu wrote:
>
> +static int khugepaged_add_pte_mapped_thp(struct mm_struct *mm,
> +					 unsigned long addr)
> +{
> +	struct mm_slot *mm_slot;
> +	int ret = 0;
> +
> +	/* hold mmap_sem for khugepaged_test_exit() */
> +	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
> +	VM_BUG_ON(addr & ~HPAGE_PMD_MASK);
> +
> +	if (unlikely(khugepaged_test_exit(mm)))
> +		return 0;
> +
> +	if (!test_bit(MMF_VM_HUGEPAGE, &mm->flags) &&
> +	    !test_bit(MMF_DISABLE_THP, &mm->flags)) {
> +		ret = __khugepaged_enter(mm);
> +		if (ret)
> +			return ret;
> +	}

could you explain why do we need mm->mmap_sem, khugepaged_test_exit() check
and __khugepaged_enter() ?


> +	spin_lock(&khugepaged_mm_lock);
> +	mm_slot = get_mm_slot(mm);
> +	if (likely(mm_slot && mm_slot->nr_pte_mapped_thp < MAX_PTE_MAPPED_THP))
> +		mm_slot->pte_mapped_thp[mm_slot->nr_pte_mapped_thp++] = addr;

if get_mm_slot() returns mm_slot != NULL we can safely modify ->pte_mapped_thp.
We do not care even if this task has already passed __mmput/__khugepaged_exit,
this slot can't go away.

No?

Oleg.

