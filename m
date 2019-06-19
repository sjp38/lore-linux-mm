Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DF6BC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:23:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1D7820B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:23:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1D7820B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DC188E0006; Wed, 19 Jun 2019 02:23:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48B9B8E0003; Wed, 19 Jun 2019 02:23:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 379CA8E0006; Wed, 19 Jun 2019 02:23:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DA8198E0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:23:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l26so24672308eda.2
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:23:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZazGDObRvA6ihltT67SyH2WSEN7/MIUfpCYaYcTwKu0=;
        b=M2YgCZGol19n3FZ+RySNP8Tn85gcpqVSDcMbIebUF+/KOsv8NwUE3LoftqvvXkkdA2
         4/0X1kmNtGyHnRWw/thbEdBdIj+RJFHfAmaRXboiggHxz+6Jf36RHiQJ5N4LNl/Lf4NQ
         zvaegNmgbFOzbQNlJo8Kf2KnV4rA5CmHZUuciVmFpsGik+cJt5gWeSHDFdYTxNRkg08Q
         ycFt036t4Kzhu55/lQyy8Z4e1F4br1yJ1zr0oGOeKF9bPLQO9O0OpSukyWSY8Q4j8XQU
         9jEN8S6KtWH7lifNco3pArjQau7cQAZwXxRSBjGR+Fxg9HuyjxJbMlcwMQ6ZRFObpKX/
         xHcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAW0WuGXvHtkrmDBCdwS7tyLab6GQAZr5S5a2Ct830oYd2mthh5u
	NbvESPT2w8wlfoyZK10pwXH93U2vK4846yhiRlUrqlBqmIJTcINJA3mIDF8Aw5zRCrg0R1RN/4f
	K05cJBEbxKHDEcCctsIHmVyAbSKMioNNTJflg6wbcj07x0ofvJF6lQLlFEcvBWStnlw==
X-Received: by 2002:aa7:c149:: with SMTP id r9mr42411431edp.92.1560925414384;
        Tue, 18 Jun 2019 23:23:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzH5A3Vb9CBkhgfKnfC3IgRTnySAo8tC7ZDO9IvrLgLQpuVUEEBATf03oHxlWrW6TVcOGd7
X-Received: by 2002:aa7:c149:: with SMTP id r9mr42411389edp.92.1560925413726;
        Tue, 18 Jun 2019 23:23:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560925413; cv=none;
        d=google.com; s=arc-20160816;
        b=zdp4C1JMvHzr3Qu6QLtYwEsUxXkjtL5jJMfgPxW7c053FvAlJM/I1nzmabgrAZQQyw
         +elE9vePVun/Z0r45m6l12cdz16rZW3NbLvR8tvtP4tIFrCjzhUWLkUOV6BhM0WGkWoS
         lZ8zJ9ZkWjznW6rmp3NqBm/EXoK+FTekjGlsSuEt1zXcAzbQfZZGUiSnwOb+j1Oex1XZ
         ERRebF6JHWfMGiRToVHHmKJhTXh+qF400ouW+gh3hhT5Jq2YOyRCHRRthLgPgCrKAhxA
         nPzE2P3DOM0wIwFy07ORUr+ma4bmBz9ZxY0+c7diuN40nHIAGPriV8lRIERmc/DUgfHX
         5Iaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZazGDObRvA6ihltT67SyH2WSEN7/MIUfpCYaYcTwKu0=;
        b=JpLc+RCjjynII/DtOyUgnzSl5km8IwDdJf/dMT3AUNKCD5X3V8ghbZIJJ9O4MLvDyf
         WshpAoOhFsSPWWHEJRCM7BDRpIa3eKDr65S0/DRRTuj9/ZgmaLMs9j7IH31/FZUqHGv7
         nI8/0UMJnWhSkc45sLvEctVJsnBnMjnYVxV3eVBOei1Qjegpy/EhaIKGLTxkqOw0Ptf6
         wYo78XuA8KiTo+rPolp7dThibWVPo/oWoktnoAV/BArtxc93lp8Pph0KYa6jGEU8ioSm
         4nLmeXLvS1aFErUGAR4QbroSQamJPLbGE491txMxFlN8Ocb1na+c1vJyHPjaTuIAhqTG
         TTOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r18si1893497eda.193.2019.06.18.23.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:23:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4C5C2ACB8;
	Wed, 19 Jun 2019 06:23:32 +0000 (UTC)
Date: Wed, 19 Jun 2019 08:23:30 +0200
From: Michal Hocko <mhocko@suse.com>
To: Wei Yang <richardw.yang@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, osalvador@suse.de,
	david@redhat.com, anshuman.khandual@arm.com
Subject: Re: [PATCH v2] mm/sparse: set section nid for hot-add memory
Message-ID: <20190619062330.GB5717@dhcp22.suse.cz>
References: <20190618005537.18878-1-richardw.yang@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190618005537.18878-1-richardw.yang@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 18-06-19 08:55:37, Wei Yang wrote:
> In case of NODE_NOT_IN_PAGE_FLAGS is set, we store section's node id in
> section_to_node_table[]. While for hot-add memory, this is missed.
> Without this information, page_to_nid() may not give the right node id.

Which would mean that NODE_NOT_IN_PAGE_FLAGS doesn't really work with
the hotpluged memory, right? Any idea why nobody has noticed this
so far? Is it because NODE_NOT_IN_PAGE_FLAGS is rare and essentially
unused with the hotplug? page_to_nid providing an incorrect result
sounds quite serious to me.

Could you identify when we have introduced this problem? A Fixes tag
would sound very useful to me.

> BTW, current online_pages works because it leverages nid in memory_block.
> But the granularity of node id should be mem_section wide.

This is not really helpful because nothing except for the hotplug really
cares about mem blocks. The whole MM really does care about page_to_nid
and that is why it matters much more so spending a word or two on that
would be more helpful.

> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: David Hildenbrand <david@redhat.com>
> Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

The patch itself looks good to me.
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
> 
> ---
> v2:
>   * specify the case NODE_NOT_IN_PAGE_FLAGS is effected.
>   * list one of the victim page_to_nid()
> 
> ---
>  mm/sparse.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 4012d7f50010..48fa16038cf5 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -733,6 +733,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  	 */
>  	page_init_poison(memmap, sizeof(struct page) * PAGES_PER_SECTION);
>  
> +	set_section_nid(section_nr, nid);
>  	section_mark_present(ms);
>  	sparse_init_one_section(ms, section_nr, memmap, usemap);
>  
> -- 
> 2.19.1

-- 
Michal Hocko
SUSE Labs

