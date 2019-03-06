Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CAC5C10F00
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 16:08:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9F5A206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 16:08:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9F5A206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5EB528E0023; Wed,  6 Mar 2019 11:08:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 59A5D8E0015; Wed,  6 Mar 2019 11:08:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 489338E0023; Wed,  6 Mar 2019 11:08:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 26A128E0015
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 11:08:54 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 35so11986857qtq.5
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 08:08:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=EKFB8D0qVF0WPKvVoOsdIHshwq45qGd6+k3S79Bfb8c=;
        b=JvHEKDmzYHcF8Glg74wuGOj4HbtK5v0XMfZIU6sVfn5u1VIbaz44WK/46HNXq2PP8Z
         pyLkRpx8vDnMAUmDAAkNrDImHsmAYlpplb/Ilv+VKWxWW9XqiWhqEadSW1hJZP/rFWhA
         klDiWEuJq2D4l4jUW/3s+BPEE3HwSBIeD2eL5JM8JTMG+1e6Pqp8x6B31X27/VP/fTID
         BEp1/zZd3VRKC1WcteaNl8r/xbDnUL5y+/x3Z4OfUNiF6YM1JkEG9jUUfhr2UEAGn1u6
         sxlfstlRTGyLx9ChHqUsQeT9zmx96wTeU4IoPJI5oAPnj3NdYgvNpA8Yl6dEvCZNf5uB
         cE8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXqG8dLA1ibulT/5VRe9S5X3ZAZldN85FsjL3BeBXnizJVk92Ew
	pqkSUvFS8l6tjR5gHPb6TlwllVw5eCtWaDz36EGItmvFswv90vfU3hq++NSMm6gL1QyyJVpi+c+
	XbItIuKlhv0e3k2+0NTXjB/lD0cyiFYILqZobLaze9Kmd5N4Iei+G45zt2J60kwdRlQ==
X-Received: by 2002:ac8:2ca1:: with SMTP id 30mr6424225qtw.245.1551888533917;
        Wed, 06 Mar 2019 08:08:53 -0800 (PST)
X-Google-Smtp-Source: APXvYqywAOlDnZ2SuVC/11fscVf0gsIfsJehU82e54sQMKoqbFWtfG7Aktcn9OHC6QuhedQZYGaq
X-Received: by 2002:ac8:2ca1:: with SMTP id 30mr6424176qtw.245.1551888533210;
        Wed, 06 Mar 2019 08:08:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551888533; cv=none;
        d=google.com; s=arc-20160816;
        b=0P+t/63y6E8G/M9ppDh6RQX4EVlfE8UDubOaaJrhnRTHmHbFAXa9QtnwCf47z5u58H
         pqhlMJmyAfzagDlIgUeQzCDxv2J0+QeM2QlMnS9iHX3JaO+l+1FwvF7goDGV0V7ODWcs
         OzLKIu+sd35uOoAXgpElQCWyAoDBnS2n6KDUymUMSwsZraYDw8n7WudAuVgR8S7Ad8dS
         /yEgZKKc3vYJla72WPKVAWZjkm8dfs7Xn9sJvCNegvOOCTtbMvn4Aqa0K/frB8mTiAUr
         c9DWMGxSdSSAb9AfXZhQVILAIMykF/65yVa0mZzNmeKpKAwvU98XN3Uj2eVhSWNJ5Sir
         MZMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=EKFB8D0qVF0WPKvVoOsdIHshwq45qGd6+k3S79Bfb8c=;
        b=g3BXaFm7O7DaHI8aPUAhienjP7RwNNb//+6UbnxmmhOFly41jlZ5ZZcEbqBCUNnriN
         Ow/Ci8DssOD0Rva6awSEZjBHMUN6DoQZA+N925Ya1eFpRkbX9YFAkV3mva1EDEmAG9VV
         Xto62SMZheh+MQCiVqPtUzMEBQQyv68TH2SNEODL441aSHlNtSmCt0htp4C58abXJib/
         sb0eH65Pg0DlnNRaJ7YnRMJ6Uxpx/cfhQkLNuc5514enFhBaWH9UGAMJdH9xAtKRZYhO
         9fYh75cAtAYqjUwvCB66EVuyHzRGC1njK0ybzxfnpEuvEwvDRcv7wS7Ftx7AdsJiiLm9
         37cw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u7si1199164qki.138.2019.03.06.08.08.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 08:08:53 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 64B02C0528D8;
	Wed,  6 Mar 2019 16:08:52 +0000 (UTC)
Received: from redhat.com (ovpn-125-142.rdu2.redhat.com [10.10.125.142])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6DE781001DCE;
	Wed,  6 Mar 2019 16:08:51 +0000 (UTC)
Date: Wed, 6 Mar 2019 11:08:48 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Arnd Bergmann <arnd@arndb.de>
Cc: John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hmm: fix unused variable warning in hmm_vma_walk_pud
Message-ID: <20190306160847.GA4076@redhat.com>
References: <20190306110109.2386057-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190306110109.2386057-1-arnd@arndb.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 06 Mar 2019 16:08:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 12:00:55PM +0100, Arnd Bergmann wrote:
> Without CONFIG_HUGETLB_PAGE, the 'vma' variable is never referenced
> on x86, so we get this warning:
> 
> mm/hmm.c: In function 'hmm_vma_walk_pud':
> mm/hmm.c:764:25: error: unused variable 'vma' [-Werror=unused-variable]
> 
> Remove the local variable by open-coding walk-vma in the only
> place it is used.
> 
> Reported-by: John Hubbard <jhubbard@nvidia.com>
> Suggested-by: John Hubbard <jhubbard@nvidia.com>
> Fixes: 1bed8a07a556 ("mm/hmm: allow to mirror vma of a file on a DAX backed filesystem")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
> Andrew, you already took a similar patch from me for a different
> warning in the same file. Feel free to fold both patches into
> one if you haven't already forwarded the first patch, or leave
> them separate. Note that the warnings were introduced by different
> patches from the same series originally.
> ---
>  mm/hmm.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index c4beb1628cad..c1cbe82d12b5 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -761,7 +761,6 @@ static int hmm_vma_walk_pud(pud_t *pudp,
>  {
>  	struct hmm_vma_walk *hmm_vma_walk = walk->private;
>  	struct hmm_range *range = hmm_vma_walk->range;
> -	struct vm_area_struct *vma = walk->vma;
>  	unsigned long addr = start, next;
>  	pmd_t *pmdp;
>  	pud_t pud;
> @@ -807,7 +806,7 @@ static int hmm_vma_walk_pud(pud_t *pudp,
>  		return 0;
>  	}
>  
> -	split_huge_pud(vma, pudp, addr);
> +	split_huge_pud(walk->vma, pudp, addr);
>  	if (pud_none(*pudp))
>  		goto again;
>  
> -- 
> 2.20.0
> 

