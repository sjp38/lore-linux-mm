Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F760C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:36:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FBD5206A2
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:36:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FBD5206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C648F6B0003; Tue,  6 Aug 2019 04:36:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C15CD6B0006; Tue,  6 Aug 2019 04:36:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B042F6B0269; Tue,  6 Aug 2019 04:36:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D84B6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:36:09 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i9so53323101edr.13
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:36:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=usHodNDDdHnrrq29Ie86wdnv1GycZfA8HH8x6PHNn/I=;
        b=Dymw8c92XLRmAVh8t960vLRwhodeS6YtXYgv9uIcbEGbIcl1XPZOMFqKRWQPe0NY0E
         hhHk2xDlpKzMTQl6zjGpL0oW1K0yJFajXvrME0/7Dv3PrYKZ2YYzEmuQ49gkinMAWUHh
         POnNBwi0dVqh8cKymGzV9ikNbgtsVRWCF3gI+1t3AtyHN/ZZFr/6iOFfFqWQRQZy1c8G
         B7y7g7t27+ENpK0+8evUPVJTWMeKNMUIuefeS+Qnhdv+w7PpnarGKqNDAvb+hvyJxlCe
         pIRDmeufsj3QO3bMjEgeYDhOuZP7NQ3NR468eXdxZIbSN/ok8Xl2gxCrpYEB1M9/6ekQ
         lO1g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWhbIjBuca7YHjA5NyCSqBfrgN1UiNmHcAhlJw5Yi/GW25Us97d
	DOxO2BF7t7TjBT8CH0BfgTUmYPu45K/DruYvpBD+ORTKRt5bZAUvE5i+fG52SIs5sLhkVf4Yb7Z
	NjN9OriKBxjfN82a4qLVO+YTzDKzfDlCTmdPgn7x3OIfTeMBiakxOwjB4P/65blk=
X-Received: by 2002:a17:906:1916:: with SMTP id a22mr1938878eje.271.1565080568926;
        Tue, 06 Aug 2019 01:36:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcbDuLYAVtcw3YnV0iWKbhvZLl/Usl2TIb9lL7sR/X1SGWP7mI589gJ7DXVIQAFoPyB9M9
X-Received: by 2002:a17:906:1916:: with SMTP id a22mr1938826eje.271.1565080568105;
        Tue, 06 Aug 2019 01:36:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565080568; cv=none;
        d=google.com; s=arc-20160816;
        b=gDsN22uSJiNRu7HoPpyGIoLwqUCFAaETm+WPChv6Qa61/GvH5gr5vEnclpqhDbdpqd
         FOK/6eVtFiqHRN/rDsxlff9uLQBYnJeVeitWBR9wTuASOcY+pX9Iaa0+kdeP3oDgPQck
         tFD35lInHhFB2AFOpZByKu4ulAFnBBfUxn/I9cU35RNGBZT7OzYNwkRPQe/qObc/K8z2
         S8zC9544/bOTb/R0DAR5pnZwsnRHJOlQkZsVCEx5BdB/Yi8fn0loIeTWnZyYM1GCcImj
         EMmoFkj0Lh02LlXDCWH4sX3Jz6wVp8H76kj+dA71XaTEXING8N7xb/B574mi/nAQ4qjV
         sy2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=usHodNDDdHnrrq29Ie86wdnv1GycZfA8HH8x6PHNn/I=;
        b=P4Gh2sYk0GkWCzyjHK1QL9Fkcx6szuQV/uOstCF5g17JwalefigjWzw3LRfRlKixTu
         7zjzRO4Sd/OJHj5MHqWxJ4LTCOS79BIjiYudwbRVYvi66kjt92yC6IbneKv5DAxasyUe
         rrt09e4GGaD1qjCF27kFztTUcrFGnX2Jjig9l96/qMj7i8F6ct197HWppQksJMi7tpgf
         4LPxGzYU8Ry0snKmBbXqg3JRr6vdVQbbeiBLQtSWWjzT49gI/hETaE3x9W9zwPuxsNu5
         nRnJaFXfiQE0bov1JXosNDpF+MOKwJ95mo4KwLjuaGnTRa12Xnw9PFWIoZckpH0om9ZC
         t+sQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c45si31426833eda.303.2019.08.06.01.36.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 01:36:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3ACB5ABC7;
	Tue,  6 Aug 2019 08:36:07 +0000 (UTC)
Date: Tue, 6 Aug 2019 10:36:05 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com,
	Ingo Molnar <mingo@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH V2] fork: Improve error message for corrupted page tables
Message-ID: <20190806083605.GA19060@dhcp22.suse.cz>
References: <3ef8a340deb1c87b725d44edb163073e2b6eca5a.1565059496.git.sai.praneeth.prakhya@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3ef8a340deb1c87b725d44edb163073e2b6eca5a.1565059496.git.sai.praneeth.prakhya@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 05-08-19 20:05:27, Sai Praneeth Prakhya wrote:
> When a user process exits, the kernel cleans up the mm_struct of the user
> process and during cleanup, check_mm() checks the page tables of the user
> process for corruption (E.g: unexpected page flags set/cleared). For
> corrupted page tables, the error message printed by check_mm() isn't very
> clear as it prints the loop index instead of page table type (E.g: Resident
> file mapping pages vs Resident shared memory pages). The loop index in
> check_mm() is used to index rss_stat[] which represents individual memory
> type stats. Hence, instead of printing index, print memory type, thereby
> improving error message.
> 
> Without patch:
> --------------
> [  204.836425] mm/pgtable-generic.c:29: bad p4d 0000000089eb4e92(800000025f941467)
> [  204.836544] BUG: Bad rss-counter state mm:00000000f75895ea idx:0 val:2
> [  204.836615] BUG: Bad rss-counter state mm:00000000f75895ea idx:1 val:5
> [  204.836685] BUG: non-zero pgtables_bytes on freeing mm: 20480
> 
> With patch:
> -----------
> [   69.815453] mm/pgtable-generic.c:29: bad p4d 0000000084653642(800000025ca37467)
> [   69.815872] BUG: Bad rss-counter state mm:00000000014a6c03 type:MM_FILEPAGES val:2
> [   69.815962] BUG: Bad rss-counter state mm:00000000014a6c03 type:MM_ANONPAGES val:5
> [   69.816050] BUG: non-zero pgtables_bytes on freeing mm: 20480

I like this. On any occasion I am investigating an issue with an rss
inbalance I have to go back to kernel sources to see which pte type that
is.

> Also, change print function (from printk(KERN_ALERT, ..) to pr_alert()) so
> that it matches the other print statement.

good change as well. Maybe we should also lower the loglevel (in a
separate patch) as well. While this is not nice because we are
apparently leaking memory behind it shouldn't be really critical enough
to jump on normal consoles.

> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
> Acked-by: Dave Hansen <dave.hansen@intel.com>
> Suggested-by: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
> Changes from V1 to V2:
> ----------------------
> 1. Move struct definition from header file to fork.c file, so that it won't be
>    included in every compilation unit. As this struct is used *only* in fork.c,
>    include the definition in fork.c itself.
> 2. Index the struct to match respective macros.
> 3. Mention about print function change in commit message.
> 
>  kernel/fork.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index d8ae0f1b4148..f34f441c50c0 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -125,6 +125,13 @@ int nr_threads;			/* The idle threads do not count.. */
>  
>  static int max_threads;		/* tunable limit on nr_threads */
>  
> +static const char * const resident_page_types[NR_MM_COUNTERS] = {
> +	[MM_FILEPAGES]		= "MM_FILEPAGES",
> +	[MM_ANONPAGES]		= "MM_ANONPAGES",
> +	[MM_SWAPENTS]		= "MM_SWAPENTS",
> +	[MM_SHMEMPAGES]		= "MM_SHMEMPAGES",
> +};
> +
>  DEFINE_PER_CPU(unsigned long, process_counts) = 0;
>  
>  __cacheline_aligned DEFINE_RWLOCK(tasklist_lock);  /* outer */
> @@ -649,8 +656,8 @@ static void check_mm(struct mm_struct *mm)
>  		long x = atomic_long_read(&mm->rss_stat.count[i]);
>  
>  		if (unlikely(x))
> -			printk(KERN_ALERT "BUG: Bad rss-counter state "
> -					  "mm:%p idx:%d val:%ld\n", mm, i, x);
> +			pr_alert("BUG: Bad rss-counter state mm:%p type:%s val:%ld\n",
> +				 mm, resident_page_types[i], x);
>  	}
>  
>  	if (mm_pgtables_bytes(mm))
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

