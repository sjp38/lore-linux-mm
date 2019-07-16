Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A16BFC76188
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 12:07:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6107720651
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 12:07:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6107720651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E0E66B0003; Tue, 16 Jul 2019 08:07:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06C376B0005; Tue, 16 Jul 2019 08:07:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E74DC8E0001; Tue, 16 Jul 2019 08:07:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 945A46B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:07:31 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so15890988eds.14
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 05:07:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=FsdI4LI8mLBIh3jlIFQpOcREI68rlkAeGI0fLjEIAyk=;
        b=FcFUj4/H8St98iCX35P/FuUR+SvwBdDZwSuQu7tA66RvD25x6VHPhp0ck77aI2BLLi
         7LGGHeaQ8sDqP9hJIEzwruZfcwisw7j+c8XaxWx3/7nqqRmen3Azr5EWrdkLdbxB61zc
         O+NjXZ5senesuANpNngxbysrL6E2Pn+5NrKrxfNl6/26ACw39/AAAwr9dG622fxvTtph
         h30u/U2f76YlwyhC/8o47CdOzxqD2qqYl1s5qFSsAdZGcbTnj1IlMlRmG3QqKAM8hVqM
         5qYJhGva/hFlv0+qdA+505nRuOf7ptC003EHFWvEMACPqRX4CoENDiDzp0I+mTERwUXV
         s6Iw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUJ9YnfWJXzsjO5xhlRZ85WAhzSbwQkXb27wM3HE9w5DIRkC4vj
	QxP3+/Z1CUrT+ZvH1jIjf7779GkQG5aQTMkMkE2H3yBh38GIQqa9/ndWjUeaDVKHa1LRfEg9+Lg
	FFfPDdl/s34b0vai/in+JtrchyLgcGtRd2nobwa7PbxCWo6B2FMATkFN6oSeetpDFow==
X-Received: by 2002:a05:6402:28e:: with SMTP id l14mr27907635edv.11.1563278851147;
        Tue, 16 Jul 2019 05:07:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzexdTSD+BWO2nSeICDyfvwEjIiwm5klwi6R6x5gT7YL6WjtQ3te+kPXIHT0l7gxuhGH/z1
X-Received: by 2002:a05:6402:28e:: with SMTP id l14mr27907578edv.11.1563278850433;
        Tue, 16 Jul 2019 05:07:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563278850; cv=none;
        d=google.com; s=arc-20160816;
        b=EoAoBGqH33WGLa/EDtDDiumUIG7JjWKF/x/hOgZoAdIieJhZBBaYw3AXhw65BIeoGs
         VQEA02RfbOwQCSHfqQC8RDEnrfnAE0R+J6NwX5SrwPBKiyn1cEI+EUdE1sp3xB50pz/F
         3QS3kLwFdHl/zxrjjpUJptrAnqkL51ocIOqDhxWdYQ3pDh5/QoTcLNAXZAr4hDeiwQ4O
         lf+l4YhYKpAfYzSmB8rO4DESGVl5jXKpNA9MMSnOELYBypje/Nwo39Jo+0VB2BlJpmTu
         4L8COEC35NKgVmZ+5RSNUzHpLJOPBN56dAe5w0sO1QhTLqgj5kuFOSG6NZJIcR771BiK
         QQKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=FsdI4LI8mLBIh3jlIFQpOcREI68rlkAeGI0fLjEIAyk=;
        b=SwXBj3HH8y2gln3fG3dg8tmn4Vu0cEIsKryCioMh220Xqk+jm111AXNv6exgxICKJY
         dm7iZEah0ElL+VwWqLnILElN702XqavAHnWP8yJkmee3Vmtz6B4tdC99eC8i3bxGPYeC
         BAG3g+5Pm5Eksv8o3zlaCt/WAuRftoXHe3QBgV+NS5Fyhn9SZZhjsecE8xsxLzHP1iS/
         +1nwWjXwH6PkuIwotpk+NX6DxEhGk2NKjottsYFeJQPO6gWVMYSdMverOQ6KdhHDIv8i
         2C1OTlQ5JEWIz4XfDccZar0qE2G6nH0U5y/tMZAlpJ7NevjFxPXpbeRYRIBx1j8sseZb
         RVZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s3si13296332edm.335.2019.07.16.05.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 05:07:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 978BEAD18;
	Tue, 16 Jul 2019 12:07:29 +0000 (UTC)
Subject: Re: [v2 PATCH 2/2] mm: mempolicy: handle vma with unmovable pages
 mapped correctly in mbind
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org,
 mgorman@techsingularity.net, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
 <1561162809-59140-3-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <0cbc99f6-76a9-7357-efa7-a2d551b3cd12@suse.cz>
Date: Tue, 16 Jul 2019 14:07:18 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <1561162809-59140-3-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/22/19 2:20 AM, Yang Shi wrote:
> @@ -969,10 +975,21 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
>  /*
>   * page migration, thp tail pages can be passed.
>   */
> -static void migrate_page_add(struct page *page, struct list_head *pagelist,
> +static int migrate_page_add(struct page *page, struct list_head *pagelist,
>  				unsigned long flags)
>  {
>  	struct page *head = compound_head(page);
> +
> +	/*
> +	 * Non-movable page may reach here.  And, there may be
> +	 * temporaty off LRU pages or non-LRU movable pages.
> +	 * Treat them as unmovable pages since they can't be
> +	 * isolated, so they can't be moved at the moment.  It
> +	 * should return -EIO for this case too.
> +	 */
> +	if (!PageLRU(head) && (flags & MPOL_MF_STRICT))
> +		return -EIO;
> +

Hm but !PageLRU() is not the only way why queueing for migration can
fail, as can be seen from the rest of the function. Shouldn't all cases
be reported?

>  	/*
>  	 * Avoid migrating a page that is shared with others.
>  	 */
> @@ -984,6 +1001,8 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
>  				hpage_nr_pages(head));
>  		}
>  	}
> +
> +	return 0;
>  }
>  
>  /* page allocation callback for NUMA node migration */
> @@ -1186,9 +1205,10 @@ static struct page *new_page(struct page *page, unsigned long start)
>  }
>  #else
>  
> -static void migrate_page_add(struct page *page, struct list_head *pagelist,
> +static int migrate_page_add(struct page *page, struct list_head *pagelist,
>  				unsigned long flags)
>  {
> +	return -EIO;
>  }
>  
>  int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
> 

