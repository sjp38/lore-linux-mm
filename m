Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CECCC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 17:44:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22D4B20818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 17:44:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22D4B20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B82948E009C; Thu, 21 Feb 2019 12:44:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B57758E0094; Thu, 21 Feb 2019 12:44:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6DF28E009C; Thu, 21 Feb 2019 12:44:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C08D8E0094
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 12:44:54 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id d134so5770061qkc.17
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 09:44:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=1bWksWkd5Zax3s/V7dAtyalHs5RVLStKYh3P7bbPAxI=;
        b=OYSX45alB/TsOjC2j55CQ8uj8geE5VYRzUPQiXhuYJ3X9yJ3XGqBvZkehDUd918SKN
         fHEXKN2YxdVAI7mMhdGE68Z3VTVe9TWWOc3KgJ4hKLmdlUU4xTmQb/B2hDlMNT8m0rCY
         BH5fRRTu3qoDat7iDV2ComUcxDuR5Y27tLgJtHyKXZpMec2polzGxtpfV7CLUbqLHQaN
         W0Lhjp+Y+IVgKcNyT9tTB3WOPATSwegQNYAYKgmVU4QEUDGlB8aFOUuWV8euhR+1MzSa
         ngAqAGXwvNJjc1SE+pRzzmrLlfIjyaReRQBn1grgAJEP9/ERM1ciuT5eTbeoaylhXpiQ
         uvng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZIhzyi3eV9PX/4Mwj3QWF969E2VG2cRi5i4MrNpms8Lzp2cYca
	qSmwssh4nCO41h6RLvYPEcTtSxIgN7r/ERFBReUQ/v3PzPBi9uiJ2yrOfvoLc+bxzKM22rGx7Nq
	I7tYP7Am6kwi5XkmjDis1YpHj6gUWve6m8YHABnx1zP0aLxT6jFKatO4FilOVOOMqyQ==
X-Received: by 2002:ac8:1aa6:: with SMTP id x35mr33188036qtj.218.1550771094292;
        Thu, 21 Feb 2019 09:44:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia3fzrKaNV5Q0ywOBHftdfzpON7MAMmfIq+Hv/+2uYsq2xFYEQbQnCN60WTrKJ9Q+jTCXvH
X-Received: by 2002:ac8:1aa6:: with SMTP id x35mr33188008qtj.218.1550771093864;
        Thu, 21 Feb 2019 09:44:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550771093; cv=none;
        d=google.com; s=arc-20160816;
        b=A1gjW4oONsZRwd+ce1qnUi+75dstbCCExtG5zEH9wzbAmbfTq/w41+ORsha+BpkHtr
         nJcHtSQLs4RT3kXNrAsJzM1vra10T9ZSjA7FDoZikw8MBXlZjGctprGH4IeEmL0cN3MQ
         5d4zk9l4dBcoruJb7kl5tZrqAjhwzCjsEabORkAmrBx2/Dh9us/qpPSHXfkyRXBsx8I1
         I/n0pkorKLAWADL3mfDgudpYv85Bm1TDCSlX22EVyWpZRFaIVHzP/ci6VvxeBgtTrtJ7
         21mhaRNnPNgythVN34FY+8xuiUEC8iq9vqzInbhGriFp4yFVCr1yd00hmWaVx8Kh8hX0
         TogQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=1bWksWkd5Zax3s/V7dAtyalHs5RVLStKYh3P7bbPAxI=;
        b=ZlWHG1ZEMunw8lQsGk6m+aZWcQbzX/xllihKoxFMuYlK5O8BMe/JQ3a0AHSbI9fJpa
         1cDj/FQz5BS/9/0gkEaDcZ2/enjtbdnwMYo2C6iNA7GaElaMZ+tViF6vFMswsv5g0mLo
         qULjjfnZtOtbUa78ZN4x6Ay4TjQxWTWDAaI7rjYkNH1YwsM41uziFwLEZN84Vlu4h3Gg
         7iX2GXSEFmYWM5EdEvI6FDNkslWq8wYKcLWCMHXeqYhf77MOya0N2vxIZSATb2ZhfPu0
         dvxXst0GXTTgmZ85Q5IU8sIWznoPbcgW1AK8p+qG4NCo52z+Klkn5mCW4Bu6XMxYZcM/
         unsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z4si1316521qvm.216.2019.02.21.09.44.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 09:44:53 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 087373082AF0;
	Thu, 21 Feb 2019 17:44:53 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5AF5E5C290;
	Thu, 21 Feb 2019 17:44:46 +0000 (UTC)
Date: Thu, 21 Feb 2019 12:44:44 -0500
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
Subject: Re: [PATCH v2 13/26] mm: export wp_page_copy()
Message-ID: <20190221174444.GM2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-14-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-14-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Thu, 21 Feb 2019 17:44:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:19AM +0800, Peter Xu wrote:
> Export this function for usages outside page fault handlers.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  include/linux/mm.h | 2 ++
>  mm/memory.c        | 2 +-
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index f38fbe9c8bc9..2fd14a62324b 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -405,6 +405,8 @@ struct vm_fault {
>  					 */
>  };
>  
> +vm_fault_t wp_page_copy(struct vm_fault *vmf);
> +
>  /* page entry size for vm->huge_fault() */
>  enum page_entry_size {
>  	PE_SIZE_PTE = 0,
> diff --git a/mm/memory.c b/mm/memory.c
> index f8d83ae16eff..32d32b6e6339 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2239,7 +2239,7 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
>   *   held to the old page, as well as updating the rmap.
>   * - In any case, unlock the PTL and drop the reference we took to the old page.
>   */
> -static vm_fault_t wp_page_copy(struct vm_fault *vmf)
> +vm_fault_t wp_page_copy(struct vm_fault *vmf)
>  {
>  	struct vm_area_struct *vma = vmf->vma;
>  	struct mm_struct *mm = vma->vm_mm;
> -- 
> 2.17.1
> 

