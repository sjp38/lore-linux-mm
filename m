Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8533C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 20:17:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70F41217F4
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 20:17:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70F41217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 108C96B0005; Wed, 17 Apr 2019 16:17:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B7CC6B0006; Wed, 17 Apr 2019 16:17:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC2926B0007; Wed, 17 Apr 2019 16:17:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C94AD6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 16:17:48 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id b188so21830038qkg.15
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 13:17:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=8NGgAvSV4ZSwZPXnJp/FM7ySoy1B/DWtY7HqkkVGwM0=;
        b=fLs9Tbq0dv0r+XJAe4ZXxP5Fcj98GLFgH/CrTaFIDJGHZL0yI/IpJyswACOZxug9ey
         P1sdMPQYaZNKdf1Ce0WdhtEYm/NooUYfpQuTRNE4GwBo/fLgQv8KO86w4eJSyK4E0RvJ
         1VTX/AlAaypDR9M04oVlSRUhk+UNKrhSCmv+vHK8yAE+1jtA8M1/gqVokgb4/8CrO1hN
         db2JUCZqXWqee+jeVOdWZaSO5djAjdAMLBSYTi7AJnPHS/zdidulTDeYkkT8yUf+31l7
         IwK+c/b6UYHkKY0uvouePnSieP5OmGATKSw46cjOAKBEyOEy2N6TZXbqSJyWGcfBcO5V
         rTRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWcdy3LgypYUHsVDhV8CS+TY1FzizaC/XKWsAjJDDhltYx94qWO
	5o/tRFe70WZv9JNmn0tGL3d7+brrUqELh/ukYUqcHZIGOxoyHgC7722WPhkxFHgBB//Rki9Shmx
	gQOY1AyQnOaRrNyiMQ19vDWAZ1QGxRlLvDW0xkpJZEle/UYZzWZyeEKuyR+V8wmXz1A==
X-Received: by 2002:ac8:1771:: with SMTP id u46mr66891233qtk.186.1555532268583;
        Wed, 17 Apr 2019 13:17:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwk3qUC90F10+csyga/fZ72EWI8c+0ovXYBg6mHJ2Vn4Haps754zjXSx1H7JgOLYiqGevBT
X-Received: by 2002:ac8:1771:: with SMTP id u46mr66891196qtk.186.1555532267633;
        Wed, 17 Apr 2019 13:17:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555532267; cv=none;
        d=google.com; s=arc-20160816;
        b=Ssyp+Xl40mSaOqm+JXOU55tDoyeTrHZ+I+FBajWbKe5v90Dy9jbyL6Ctc7XQX1MLfw
         3FQbIyHGJPPLLS/NsNkxQyXNYgqt15Qvqf/FxFI8/+U50hX548re0hCnbOUZhvUXmZU/
         Qz6wS9k/tw0ZyRKhHGHZ+BsBEHhkLO5HtO3lgUq8Lzgb2RX9h3xlnWZN7SC9BjZ0r7Xh
         ZZvzWIbrQfik6w6TXOM4vVYp3dYk0Ky9sG6YrSAxAWU/DFVEPlLo/Ail5bgyPQhrSD2b
         fEHTZftNxIK26SU+F8/v/dr5XaR90Z8/tKKY6P1Ms/4Jr5OUssPz0V9ZIzoJ8DYgXB1R
         OVpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=8NGgAvSV4ZSwZPXnJp/FM7ySoy1B/DWtY7HqkkVGwM0=;
        b=VzPsLftoPnOUHl5e4jT2z1D+/n13EWeD9/A12Pj5e5mMZGAHfDbRWdA+7y7lobTJiB
         urvhhfRW1jpStTECmzOgg24Ybi/kqufkC8whxvoQqwxO4enAp9M1pOu4EmiJYfjLe/2B
         k+S6eLldJGN/A14wTsYPar7ZHRgt3hObo1raiNsFiQote9U2nxrbDQNMZsb8Grzu/U5v
         hI8fZP78brc1mklvmZ2SN115MOpZAtFcMaX75YoDO4ZT92x00eAikHWMnreO0c6cfuuG
         rtAY6/Zew5yditmwhdLboVzxJR6AGXHdQ8Wak7QBsIL2r5faXUKnxe9yJ5T+HnZEVrnz
         2V4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w25si1706488qkj.107.2019.04.17.13.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 13:17:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9E3B2F74A0;
	Wed, 17 Apr 2019 20:17:46 +0000 (UTC)
Received: from [10.36.116.26] (ovpn-116-26.ams2.redhat.com [10.36.116.26])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E634A5C205;
	Wed, 17 Apr 2019 20:17:44 +0000 (UTC)
Subject: Re: [PATCH v6 07/12] mm: Kill is_dev_zone() helper
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Logan Gunthorpe <logang@deltatee.com>,
 linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552637207.2015392.16917498971420465931.stgit@dwillia2-desk3.amr.corp.intel.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <f189190c-4d70-be54-e194-fb736505f38e@redhat.com>
Date: Wed, 17 Apr 2019 22:17:44 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <155552637207.2015392.16917498971420465931.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 17 Apr 2019 20:17:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17.04.19 20:39, Dan Williams wrote:
> Given there are no more usages of is_dev_zone() outside of 'ifdef
> CONFIG_ZONE_DEVICE' protection, kill off the compilation helper.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/mmzone.h |   12 ------------
>  mm/page_alloc.c        |    2 +-
>  2 files changed, 1 insertion(+), 13 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index b13f0cddf75e..3237c5e456df 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -855,18 +855,6 @@ static inline int local_memory_node(int node_id) { return node_id; };
>   */
>  #define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
>  
> -#ifdef CONFIG_ZONE_DEVICE
> -static inline bool is_dev_zone(const struct zone *zone)
> -{
> -	return zone_idx(zone) == ZONE_DEVICE;
> -}
> -#else
> -static inline bool is_dev_zone(const struct zone *zone)
> -{
> -	return false;
> -}
> -#endif
> -
>  /*
>   * Returns true if a zone has pages managed by the buddy allocator.
>   * All the reclaim decisions have to use this function rather than
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c9ad28a78018..fd455bd742d5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5844,7 +5844,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
>  	unsigned long start = jiffies;
>  	int nid = pgdat->node_id;
>  
> -	if (WARN_ON_ONCE(!pgmap || !is_dev_zone(zone)))
> +	if (WARN_ON_ONCE(!pgmap || zone_idx(zone) != ZONE_DEVICE))
>  		return;
>  
>  	/*
> 

I like seeing that go

Acked-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

