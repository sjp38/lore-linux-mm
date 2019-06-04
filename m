Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E266C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 04:21:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB07424A31
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 04:21:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB07424A31
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52CFB6B0010; Tue,  4 Jun 2019 00:21:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DE896B0266; Tue,  4 Jun 2019 00:21:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A4A56B0269; Tue,  4 Jun 2019 00:21:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC936B0010
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 00:21:04 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id y5so15564873ioj.10
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 21:21:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=PzsE8Xe5wdtA0vzCZv53azqtNwuE2JrRI6jUnTQne0M=;
        b=IeQaAXKLLzES8l428xgAdc6a1fUM5cZf4zwzXlZ2r9XHRiS8mbHbJrgTS5znl3iODq
         k20zooxrUhSVFu6pwN1+jyK2ZuUBYW6s2MZXPiTPgKtxzafcWyCNBdrIPfF8GeTo1LLz
         z22gTWJs0recc+79aLsNTy2dDKr36vV9jEosbjqo11WaZOg9cZtdAYL74GExddkBXwED
         3mpUEzMY6vVYaWgrrl+cCcwvNvl5LvKBiagMOnidoyBhFiNd6IJpoVPPWxS+XN/dfSiA
         iCvxYCrRErJmhOjYovQlir296tHfYx0fndjOYwULk0i7FvlpSqPrvfO8Po/6BqunUOEg
         T3aw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAU7Aa2KsUk5dZraWVEeYBTRo5CDPd+AyV0wCuacGS9XNJfaYCzD
	3YX7meS1pbmSBbBe6dvcS6Ivkyh8z51pj8cc9L4HfTElgWK9Lb5au085TBoh40tUki+liGp2iZg
	HXdhDxBa40BRpg2PGZI9ymJ/uN/2+vWe8AHRcXXNOtdcItHdwCqBC34hwF6VFO300vw==
X-Received: by 2002:a6b:8d92:: with SMTP id p140mr18202106iod.144.1559622063852;
        Mon, 03 Jun 2019 21:21:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuiY//r1kZZErEWX9+/ly1cqsdSJOQv2ShV/d7gOHzO5i2Gq1A74S/TOicZboaBRhfAuyC
X-Received: by 2002:a6b:8d92:: with SMTP id p140mr18202082iod.144.1559622063082;
        Mon, 03 Jun 2019 21:21:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559622063; cv=none;
        d=google.com; s=arc-20160816;
        b=d1nMf0eXTPi2Z4qz8kpQ9llDsgN819ewojXKrE3JgFB0tjaLSry4kpiAOr/bBlFaRd
         ueuTzJ3uBk2YINbafexJ0MF2Pjq08NoiXWOnjqAyp8AJDGGcbP8JnLiQjZidCgDG6S/G
         XbDy/6ywHzTYmjDLWA5mSZ6sHp9DmWUhNc+fMafP24+EyHkQMDf0zldkdNxbvHNz0mJX
         g3OUmSVE2+fleHFRu/pUB5/MEW2IjJ5YhNWBqtisSZYH5AjhFgjt3mExv6c9h8j1I/gO
         Ar8vIf38qpTn5noMmLQB0fhB3sdY3CYHisQ4+MAFcbcypeoOp2sDFG+pd1eB/5DDUlur
         AT7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=PzsE8Xe5wdtA0vzCZv53azqtNwuE2JrRI6jUnTQne0M=;
        b=Rt+CCakGR0fKQIoVUCOVEwrDTTko2FCyzbZGsOToQdctEhvS/wtTjezHhaa6ZCawLz
         hSjmbi4C/cbrtnCNlz/psiG6PV7fwpsvi38d59nXgHv3/zCIrdV2JhoGnASKypHeH/M1
         I4lAXECY+8RvZT/WYtxx/C04Qm6vercQ8mKtCdEv6VyNlRjOOud8v0bCeFBnDyqnnOL0
         7JVADr7VLwy7eBiA5pIUqalsaijJ/XFXTGFp8tG0YgTl2+paFCtBSPURshfmq4QNtpa9
         I1RlBSD5dMVZwcmjtC4c+k38021ozxUlvwgJRE9eKA3CQlxg0lv0aed44byQLlN8tzCF
         aexA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-165.sinamail.sina.com.cn (mail3-165.sinamail.sina.com.cn. [202.108.3.165])
        by mx.google.com with SMTP id r126si1404405itc.90.2019.06.03.21.21.02
        for <linux-mm@kvack.org>;
        Mon, 03 Jun 2019 21:21:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) client-ip=202.108.3.165;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([123.112.52.63])
	by sina.com with ESMTP
	id 5CF5F1A90000260D; Tue, 4 Jun 2019 12:21:00 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 995851395288
From: Hillf Danton <hdanton@sina.com>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	"jannh@google.com" <jannh@google.com>,
	"oleg@redhat.com" <oleg@redhat.com>,
	"christian@brauner.io" <christian@brauner.io>,
	"oleksandr@redhat.com" <oleksandr@redhat.com>,
	"hdanton@sina.com" <hdanton@sina.com>
Subject: Re: [PATCH v1 3/4] mm: account nr_isolated_xxx in [isolate|putback]_lru_page
Date: Tue,  4 Jun 2019 12:20:47 +0800
Message-Id: <20190604042047.13492-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hi Minchan

On Mon, 3 Jun 2019 13:37:27 +0800 Minchan Kim wrote:
> @@ -1181,10 +1179,17 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>  		return -ENOMEM;
> 
>  	if (page_count(page) == 1) {
> +		bool is_lru = !__PageMovable(page);
> +
>  		/* page was freed from under us. So we are done. */
>  		ClearPageActive(page);
>  		ClearPageUnevictable(page);
> -		if (unlikely(__PageMovable(page))) {
> +		if (likely(is_lru))
> +			mod_node_page_state(page_pgdat(page),
> +						NR_ISOLATED_ANON +
> +						page_is_file_cache(page),
> +						hpage_nr_pages(page));
> +		else {
>  			lock_page(page);
>  			if (!PageMovable(page))
>  				__ClearPageIsolated(page);

As this page will go down the path only through the MIGRATEPAGE_SUCCESS branches,
with no putback ahead, the current code is, I think, doing right things for this
work to keep isolated stat balanced.

> @@ -1210,15 +1215,6 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>  		 * restored.
>  		 */
>  		list_del(&page->lru);
> -
> -		/*
> -		 * Compaction can migrate also non-LRU pages which are
> -		 * not accounted to NR_ISOLATED_*. They can be recognized
> -		 * as __PageMovable
> -		 */
> -		if (likely(!__PageMovable(page)))
> -			mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
> -					page_is_file_cache(page), -hpage_nr_pages(page));
>  	}
> 

BR
Hillf

