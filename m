Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB604C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 16:59:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90A5326CA2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 16:59:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="f8WPz/+h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90A5326CA2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 297FD6B026F; Fri, 31 May 2019 12:59:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26DB56B0272; Fri, 31 May 2019 12:59:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 183986B0274; Fri, 31 May 2019 12:59:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB6466B026F
	for <linux-mm@kvack.org>; Fri, 31 May 2019 12:59:34 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id r58so1102673qtb.5
        for <linux-mm@kvack.org>; Fri, 31 May 2019 09:59:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=e3NDCjv26v8d/6GmHIuWCh8rhIogpl4fMn5sXvVuI0c=;
        b=oWU7g6MPCXZLABV05dz7zFLa1NsLsfMrXReZOXePo8tKuRFAIRTxM9qq3/QYkZ6AMm
         X+VhmHCOlRK9tgNEQZBzJko2Nq4MF2b+3wZzDQPabtxTCwfKvXKyUyOLPzworBH9xxD5
         bU3V8lxblntweOmM4OW/wT2K5SC8qniAXmjUCVTUoRbNP19JyW/KKlXvS7kbLbdC5h97
         GEfDcKHE1VmszEyI5V+baRNgwVkXZ7sCviM59wPVzLL1EW7sJ0d/lDacTynP99Wqyilk
         1PejXPCUsRWp9uMnW/yBRPFDKTDP1UKkG4vvRRwLbe93jQXXlKmVUuBal0QgGxzON1/T
         pRyA==
X-Gm-Message-State: APjAAAW+lfZUlGYmAS9SFe/+de0GxdS4IIIPnQp7FQMcxbLGozhQgd2V
	qjRsT+no0PZIV2u62d2drSSKNaJ6oc2Tuw9AtqWPTF3HYZLnubi9FT/YfxGbR5tDHFZM0XGxGb/
	NvPXma13+mq9yR/qIQY9zzfDkrWnVxQOuCaUODkpFQk20ixbEA5/j6oGrOOiUYkou3A==
X-Received: by 2002:a0c:b98d:: with SMTP id v13mr9714255qvf.11.1559321974665;
        Fri, 31 May 2019 09:59:34 -0700 (PDT)
X-Received: by 2002:a0c:b98d:: with SMTP id v13mr9714226qvf.11.1559321974042;
        Fri, 31 May 2019 09:59:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559321974; cv=none;
        d=google.com; s=arc-20160816;
        b=yri5TeOMDDXCl2Z1Ie6HznIt10z8F3+G9zBS12UY010gnGPVJn36k0l/b1wqrxuEHh
         RmszIo1F9dUfp8lsR5/Sr0gGFWJqjn2IQoCZvnTVhJCQhzNxEBXOqjY22YmltpZLkSno
         8Wkx7bMqnYs65UI7jVOb02C9qEZK4RQVQVFXedoLyqYw3fg6VL6QiN3hEIIp1JfFakua
         fLWbH34kPe22SCYl9EfcW/3G/oHBDXEW5pAXM2rtF2UGenwpgGX0nmUhE/yjctIFGqz8
         tYqo+YjPIB9Pip6dT5fRsRFnAv9pJ7rQQv8hMhuEx9eYnMZ4+Mn4gTfeLETVBy72sre2
         iA1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=e3NDCjv26v8d/6GmHIuWCh8rhIogpl4fMn5sXvVuI0c=;
        b=WK3cpX5iulqx0dZ8ibFElaahWx9lB2aAgWWm+lQ47jmLV+vhBgqhwj2Il1Sv8phW9P
         y9Gz4iIWN2vImwK4LI+BRw9d+2n00SGA0Mt/mQr5tmV+R6MPXoABNGfAPhmlpw4cAZV4
         mI1axvESWexIdnVVdivz4pYEnnSbEH2TIquHUiHOgYfwHZnW6cZqrIq2fP0A0+QrXIoq
         vHuaQ1kObKQYF5mjdJ36GNS7byLnm1fBD668X2ckfPBuvwxj/uv6UoUm289zhmWcUyV4
         ZAgmsmeSUGPEegyDK0qFzCFqifdOBJtJNgqbYXZlt06T8Opr4pbdB4xDpbUEtqIfLKQB
         Sbjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="f8WPz/+h";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t10sor5167402qvm.12.2019.05.31.09.59.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 09:59:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="f8WPz/+h";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=e3NDCjv26v8d/6GmHIuWCh8rhIogpl4fMn5sXvVuI0c=;
        b=f8WPz/+hD8iie5whEpGer0vyU0wOgv311IGNFCXMOj/NFL+1xQv5rdq/sLr0vTGqyR
         D6cgjU6mJcydC2jbjchTtkfzjxQEhtKuhmZI5YdJqCj3Ohw0b/OOQ3QicxR77uGLCTSs
         tNJeznJPLPhwE2A8dhYmVKeOkBegUCxn8GC87aElTzNPvaLVwzoxqNKoG8OuHJPolcr8
         QDLJyRD84j7hLlmTwwwkBOFvc65tS5RO6ip0IJxG28S5uNa0GTZ2GXR/BlShA8I4Zngn
         bIVsIScBIk8K9a5HRlG5NsLb9Q/MvJtZw5Ay8p/0G7CAxHPRREYcTfTCO3UzAgv3Gzmm
         NXow==
X-Google-Smtp-Source: APXvYqzaN7Osp+sFUz/UO2xtX8ksDYOwDOi8/ZwHvqZxRo9bRaBiMSUChy138SG9ks/ETIGz6vQ6cg==
X-Received: by 2002:a0c:93e1:: with SMTP id g30mr9477692qvg.194.1559321969216;
        Fri, 31 May 2019 09:59:29 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id y29sm4638814qkj.8.2019.05.31.09.59.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 31 May 2019 09:59:28 -0700 (PDT)
Date: Fri, 31 May 2019 12:59:27 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 3/6] mm: introduce MADV_PAGEOUT
Message-ID: <20190531165927.GA20067@cmpxchg.org>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-4-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531064313.193437-4-minchan@kernel.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Michan,

this looks pretty straight-forward to me, only one kink:

On Fri, May 31, 2019 at 03:43:10PM +0900, Minchan Kim wrote:
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2126,6 +2126,83 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  			nr_deactivate, nr_rotated, sc->priority, file);
>  }
>  
> +unsigned long reclaim_pages(struct list_head *page_list)
> +{
> +	int nid = -1;
> +	unsigned long nr_isolated[2] = {0, };
> +	unsigned long nr_reclaimed = 0;
> +	LIST_HEAD(node_page_list);
> +	struct reclaim_stat dummy_stat;
> +	struct scan_control sc = {
> +		.gfp_mask = GFP_KERNEL,
> +		.priority = DEF_PRIORITY,
> +		.may_writepage = 1,
> +		.may_unmap = 1,
> +		.may_swap = 1,
> +	};
> +
> +	while (!list_empty(page_list)) {
> +		struct page *page;
> +
> +		page = lru_to_page(page_list);
> +		if (nid == -1) {
> +			nid = page_to_nid(page);
> +			INIT_LIST_HEAD(&node_page_list);
> +			nr_isolated[0] = nr_isolated[1] = 0;
> +		}
> +
> +		if (nid == page_to_nid(page)) {
> +			list_move(&page->lru, &node_page_list);
> +			nr_isolated[!!page_is_file_cache(page)] +=
> +						hpage_nr_pages(page);
> +			continue;
> +		}
> +
> +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
> +					nr_isolated[0]);
> +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
> +					nr_isolated[1]);
> +		nr_reclaimed += shrink_page_list(&node_page_list,
> +				NODE_DATA(nid), &sc, TTU_IGNORE_ACCESS,
> +				&dummy_stat, true);
> +		while (!list_empty(&node_page_list)) {
> +			struct page *page = lru_to_page(&node_page_list);
> +
> +			list_del(&page->lru);
> +			putback_lru_page(page);
> +		}
> +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
> +					-nr_isolated[0]);
> +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
> +					-nr_isolated[1]);
> +		nid = -1;
> +	}
> +
> +	if (!list_empty(&node_page_list)) {
> +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
> +					nr_isolated[0]);
> +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
> +					nr_isolated[1]);
> +		nr_reclaimed += shrink_page_list(&node_page_list,
> +				NODE_DATA(nid), &sc, TTU_IGNORE_ACCESS,
> +				&dummy_stat, true);
> +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
> +					-nr_isolated[0]);
> +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
> +					-nr_isolated[1]);
> +
> +		while (!list_empty(&node_page_list)) {
> +			struct page *page = lru_to_page(&node_page_list);
> +
> +			list_del(&page->lru);
> +			putback_lru_page(page);
> +		}
> +
> +	}

The NR_ISOLATED accounting, nid parsing etc. is really awkward and
makes it hard to see what the function actually does.

Can you please make those ISOLATED counters part of the isolation API?
Your patch really shows this is an overdue cleanup.

These are fast local percpu counters, we don't need the sprawling
batching we do all over vmscan.c, migrate.c, khugepaged.c,
compaction.c etc. Isolation can increase the counter page by page, and
reclaim or putback can likewise decrease them one by one.

It looks like mlock is the only user of the isolation api that does
not participate in the NR_ISOLATED_* counters protocol, but I don't
see why it wouldn't, or why doing so would hurt.

There are also seem to be quite a few callsites that use the atomic
versions of the counter API when they're clearly under the irqsafe
lru_lock. That would be fixed automatically by this work as well.

