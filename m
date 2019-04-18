Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B79FC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:01:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 038DE20869
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:01:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 038DE20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 981F96B0271; Thu, 18 Apr 2019 17:01:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92FD96B0272; Thu, 18 Apr 2019 17:01:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81EAB6B0273; Thu, 18 Apr 2019 17:01:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 654F86B0271
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 17:01:57 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id b188so2733562qkg.15
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:01:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=w2uofvvjcpOcTtv6zw7AguCROFu6xIxMOOyWy4hHRzc=;
        b=Ru1NwKMrgO8pJ2x3edtNksz3QT4rmCVdumaJmlg6ePq0I3VjnL6/KQnRxc7C2stk5C
         lVQu0tSM8uURNqEFi98rY6ZrMWKXsnWl/lFn8FTeAg2j2cKoHFKIlTgJ9Hus8eRu596K
         Yk1RKt88Egk2XJKtUOQYv4Q5wn7r6arvC2og1C3N+KVWKofaqBp56tR7tW9vhAjn6w4D
         OiKSMIY2sI15jy1hMlbVZgVK7YF+1gK/urERFPLJXQ6DNCslJQ0k0V7yl1WtJccLT1sd
         rn6MmmG8nwICb8hnzDyXgIvAChzejryQJHI8Jt3puFBTeQApTJuFrBXInEDLxQFlbMS9
         xYYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXJQdGvCXAoc9QvQd/Y+GhLnh5YfIOaJR8462xB5mGO6ZiB0Vl/
	Mvdw8CL3CaCOw5+h5NowWUogmy13BLIGVN+w2q7lNTIOEhxHCV4ZKe3/gO3ub46EnwJFiUrcgew
	NyjWI2E9hompA1SIQNG+hEr1wMonlQCxhxQG2f13YWnUo43LXd7MWeXAD7L2c9qw6nw==
X-Received: by 2002:ac8:2a2e:: with SMTP id k43mr98665qtk.353.1555621317199;
        Thu, 18 Apr 2019 14:01:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnI7O0kWIBvH1P84bqIHxhDYbazVVbjtkrZdzVgB10G5ffU959pDUEkaLg5NXlKMf2JS8E
X-Received: by 2002:ac8:2a2e:: with SMTP id k43mr98619qtk.353.1555621316551;
        Thu, 18 Apr 2019 14:01:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555621316; cv=none;
        d=google.com; s=arc-20160816;
        b=l1NC1pu0L6wc3E/+PVEEeXxg33JOsVSq+5WqK3K2sYf1a3yi7o4aOm1Jktci8dv2dt
         fXjAD/WLHmCKh78hQ0fzdBXHEZI2QErqdpVfb8EA3IKYEoVZ6oNRBlLH6nA5mhy26eJX
         LYMNsZCjrepNRpgewyonvxVpjv3DunHWKtTSNUH7dEiiRihNbOY6kBVOkTlRPeTbZFLP
         4bWICC+PHrcQZW7ijUoCZiFFPc0YUVk7u8msN3eTD1KDHEuyjeK1PR8gRMrVcGDNAnhw
         9QMIdSORt6ICFGtnorEIGJC8c30xuvqKKm/6zcNxhhAna8UHe5aXi+xpbBE4+8gDpYNT
         dcUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=w2uofvvjcpOcTtv6zw7AguCROFu6xIxMOOyWy4hHRzc=;
        b=lZlmLDhIeMKuZQomIFZmCnX59TXTYQxeXSTi0S4JL+aLZqhebdyOWEk5aK4h3gyoU0
         UwYJpgBrz7dZqSEi4hOaHy/YHIvfFcOWvzYXzdyYQDPcM/iirRR04Ekw2uI3cNFbgRrx
         rV/qPjURxH8UuBSqTEnFf1qIIvLWaCWQ4W9SBy/ECmWFuvLagWcBNK54vI3+mvvmG627
         VhvlSsRQuUw0ngWTLgPVUxgfuDI6mLc+jVFqm+BQlB77obMGGJ1oaS12L1xOMcCTZ6Q0
         t389ZUi2LwGe6HqI6p29h+dfy2NPASsI9K9uBjvB7Buapi+o5cUTPSsnXRraKiqRY1FN
         aWVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i16si1418067qtr.138.2019.04.18.14.01.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 14:01:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 997CE301EA86;
	Thu, 18 Apr 2019 21:01:55 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D402060BFC;
	Thu, 18 Apr 2019 21:01:49 +0000 (UTC)
Date: Thu, 18 Apr 2019 17:01:48 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v3 25/28] userfaultfd: wp: fixup swap entries in
 change_pte_range
Message-ID: <20190418210147.GM3288@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190320020642.4000-26-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320020642.4000-26-peterx@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 18 Apr 2019 21:01:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 10:06:39AM +0800, Peter Xu wrote:
> In change_pte_range() we do nothing for uffd if the PTE is a swap
> entry.  That can lead to data mismatch if the page that we are going
> to write protect is swapped out when sending the UFFDIO_WRITEPROTECT.
> This patch applies/removes the uffd-wp bit even for the swap entries.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

This one seems to address some of the comments i made on patch 17
not all thought. Maybe squash them together ?

> ---
> 
> I kept this patch a standalone one majorly to make review easier.  The
> patch can be considered as standalone or to squash into the patch
> "userfaultfd: wp: support swap and page migration".
> ---
>  mm/mprotect.c | 24 +++++++++++++-----------
>  1 file changed, 13 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 96c0f521099d..a23e03053787 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -183,11 +183,11 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  			}
>  			ptep_modify_prot_commit(mm, addr, pte, ptent);
>  			pages++;
> -		} else if (IS_ENABLED(CONFIG_MIGRATION)) {
> +		} else if (is_swap_pte(oldpte)) {
>  			swp_entry_t entry = pte_to_swp_entry(oldpte);
> +			pte_t newpte;
>  
>  			if (is_write_migration_entry(entry)) {
> -				pte_t newpte;
>  				/*
>  				 * A protection check is difficult so
>  				 * just be safe and disable write
> @@ -198,22 +198,24 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  					newpte = pte_swp_mksoft_dirty(newpte);
>  				if (pte_swp_uffd_wp(oldpte))
>  					newpte = pte_swp_mkuffd_wp(newpte);
> -				set_pte_at(mm, addr, pte, newpte);
> -
> -				pages++;
> -			}
> -
> -			if (is_write_device_private_entry(entry)) {
> -				pte_t newpte;
> -
> +			} else if (is_write_device_private_entry(entry)) {
>  				/*
>  				 * We do not preserve soft-dirtiness. See
>  				 * copy_one_pte() for explanation.
>  				 */
>  				make_device_private_entry_read(&entry);
>  				newpte = swp_entry_to_pte(entry);
> -				set_pte_at(mm, addr, pte, newpte);
> +			} else {
> +				newpte = oldpte;
> +			}
>  
> +			if (uffd_wp)
> +				newpte = pte_swp_mkuffd_wp(newpte);
> +			else if (uffd_wp_resolve)
> +				newpte = pte_swp_clear_uffd_wp(newpte);
> +
> +			if (!pte_same(oldpte, newpte)) {
> +				set_pte_at(mm, addr, pte, newpte);
>  				pages++;
>  			}
>  		}
> -- 
> 2.17.1
> 

