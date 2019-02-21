Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 920E1C00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:06:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C4952083B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:06:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C4952083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF9A98E00A1; Thu, 21 Feb 2019 13:06:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7FAC8E00A0; Thu, 21 Feb 2019 13:06:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B215A8E00A1; Thu, 21 Feb 2019 13:06:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 857C68E00A0
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:06:41 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id e1so10881010qth.23
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:06:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=DRNhgmJBtSlSuPDp8aev3X17F03xjO5FV3A5Ts+zgps=;
        b=dY14ohBZGacneVPhL5cSPMSOe7NmseaxrEDIaoyHEV9uGy8YVk2obocWWZopTr/soD
         uHuygiJhvIJ6nD6hyNZFfciciAy8ngGik4JtOK7VpG2GIfH+PnhXRkQQ5CAmGR2uUZn0
         gh9yYeJk6LI/+Z7p7Farxls8N7cFEMZhLC078dDur+HgYkt+FmkoLDiM9aZ26T6Z1xVV
         AuOrmy8Kz7XxCkKFXg4IUuYV2ufnqitHqmlYPlc5BACP+GnVXW7Jd1f9bcQgUnScVPu2
         H/p5tss34JWU+6JdmfzXjE9Jg3a1LnZRPwyEIdqHq9sq9HatbdgYF0hfzyeERmbhv+Cy
         YB8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaJUqIEBcJanijL6JRKhLY0i3dIvtKU12FS5UNLpqbFXcqjlkF5
	asFtnKQ8m3UwVQdTGe2xWV2gP2Gh9MKcOdQVfl6JIz5QV72ECBuro1uSHddgBQVEp4z8tXe08xP
	NWiD16ttxQwabMjWk3TsS9dbsKUK9O8Tp/iGTn5zntEhxnNEl1RrDA/Te7N4GnZZ5Xw==
X-Received: by 2002:a0c:ecc5:: with SMTP id o5mr31296795qvq.106.1550772401268;
        Thu, 21 Feb 2019 10:06:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY5FYRIlePVitCMcz/83Gc8+oaqyf4VijxwMDYD7/CdpGEfnJwfbqNbGOThFfbQRDQyRFrM
X-Received: by 2002:a0c:ecc5:: with SMTP id o5mr31296752qvq.106.1550772400646;
        Thu, 21 Feb 2019 10:06:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550772400; cv=none;
        d=google.com; s=arc-20160816;
        b=g7qDXs1EovqVHx3QMXoKyP0v0njcyq/MsQW978rq2i6sd41Nz9hJpxnAHx7q5/dyaN
         z3eQqV44c+zqhEBxMIgRSwOvcFpfcZJp+9g+Wt0eJ42zegLcB1rKHRYGEfHDa/Di1xw+
         6FbbXXbDiGwc75Oux/BmB/86s1Y0Xx38S8l1lwEOEAvxFEm45itMHJ1KbsZTHi3Z0Zrw
         Hh9ZNIqEHYBnhtFMDSoYvKX4BGWcCCVySh8E15l3RgU1nc6Zve9kpmdF74WFysuJazoR
         Q0tGyEmeqc1+p3BXZSRS82whY3I+KpZ7BtNt0o8obm/wP0hbBv3FJ1jZslG4XBIBpJoD
         aa8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=DRNhgmJBtSlSuPDp8aev3X17F03xjO5FV3A5Ts+zgps=;
        b=zzao7CLr0iyfxHr4cw1fJOvpDzYz9v/CZCckv97FRpHn/Hm2gchWxchWRoehn1twuA
         TlzpHLYHeR0tn0x94iJ6BWNSKR0TpZpYmatoTQqHdnqUcJqHl0QWIjBahgJI47635/cI
         nPnXUJf48qzDqyWnTpbEjQogCsp047T7dyjiJSVNKCwE6yYfbe9W7ljQTF3ojsJ51Rw/
         p6JtyLWKMAEirK2QN6r5eNf47CmM6vmVTwzsDA1zfcZ49tAIERXKGs5a8oUO2/UWFlje
         6pUk0k7P9sBbIdlt5hafojbV+op3SVdHrkbkUopo7gRK9O/Mu7MbSh/Q5TlIdJ4LjuaE
         sKyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z26si2892929qta.254.2019.02.21.10.06.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 10:06:40 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8717E59446;
	Thu, 21 Feb 2019 18:06:39 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8717A5C290;
	Thu, 21 Feb 2019 18:06:33 +0000 (UTC)
Date: Thu, 21 Feb 2019 13:06:31 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 15/26] userfaultfd: wp: drop _PAGE_UFFD_WP properly
 when fork
Message-ID: <20190221180631.GO2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-16-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-16-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 21 Feb 2019 18:06:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:21AM +0800, Peter Xu wrote:
> UFFD_EVENT_FORK support for uffd-wp should be already there, except
> that we should clean the uffd-wp bit if uffd fork event is not
> enabled.  Detect that to avoid _PAGE_UFFD_WP being set even if the VMA
> is not being tracked by VM_UFFD_WP.  Do this for both small PTEs and
> huge PMDs.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

This patch must be earlier in the serie, before the patch that introduce
the userfaultfd API so that bisect can not end up on version where this
can happen.

Otherwise the patch itself is:

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  mm/huge_memory.c | 8 ++++++++
>  mm/memory.c      | 8 ++++++++
>  2 files changed, 16 insertions(+)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 817335b443c2..fb2234cb595a 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -938,6 +938,14 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  	ret = -EAGAIN;
>  	pmd = *src_pmd;
>  
> +	/*
> +	 * Make sure the _PAGE_UFFD_WP bit is cleared if the new VMA
> +	 * does not have the VM_UFFD_WP, which means that the uffd
> +	 * fork event is not enabled.
> +	 */
> +	if (!(vma->vm_flags & VM_UFFD_WP))
> +		pmd = pmd_clear_uffd_wp(pmd);
> +
>  #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>  	if (unlikely(is_swap_pmd(pmd))) {
>  		swp_entry_t entry = pmd_to_swp_entry(pmd);
> diff --git a/mm/memory.c b/mm/memory.c
> index b5d67bafae35..c2035539e9fd 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -788,6 +788,14 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  		pte = pte_mkclean(pte);
>  	pte = pte_mkold(pte);
>  
> +	/*
> +	 * Make sure the _PAGE_UFFD_WP bit is cleared if the new VMA
> +	 * does not have the VM_UFFD_WP, which means that the uffd
> +	 * fork event is not enabled.
> +	 */
> +	if (!(vm_flags & VM_UFFD_WP))
> +		pte = pte_clear_uffd_wp(pte);
> +
>  	page = vm_normal_page(vma, addr, pte);
>  	if (page) {
>  		get_page(page);
> -- 
> 2.17.1
> 

