Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DA7BC7618F
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 00:03:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEA48218BE
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 00:03:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEA48218BE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 422EB6B0005; Mon, 22 Jul 2019 20:03:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D5118E0003; Mon, 22 Jul 2019 20:03:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C3A58E0001; Mon, 22 Jul 2019 20:03:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E937D6B0005
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 20:03:37 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t2so20828390plo.10
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 17:03:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=G2KDi8J+eLxk9PnNxZ4AOboVee294jxqoOE5+8lh0u8=;
        b=NlzsQkSF8b7SMiH+P5Bbbc1TseykwDhTttEXur7qqxW0WdGEg7Rrn6OfeR9T3hHgSv
         qWIuJkjtihXScqhhQqjI7Ov+F2lwdNO7knOtwqBHVI05k3GE4knoozBVs7yodwavf8vJ
         xczyu1ce5V1kbuKXvjVUBsUlCn0uDXigGmul6tUPNRIGrsVL5opGqydpAtxMGXK8Sgu8
         GEF7vVad0o0JdOGGV4cq5p1OQ5cQbpYPrfjPo7ZiLBNLLBiR3qc6F3f82nwxVu1AWtsm
         oEq3c98jg4f5bC1cY0aAuJiwDC63bZb0Tm/Q1FpQZhcy8WyYJmJRe0odK34boEOlisL+
         O5nw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWFNXvfz3O7xMuWCvXmjYOqvX2xgJLpsetYRZjZVBaffmTae2lA
	lH5czGVpQ64wQYPBWWeIeasjhoQMp0G6Vos0iMvQlI/Zyi+l/WROkvD8zWfdO9Y4VRzFfYKM/DO
	3dqVw4ckEUGJ6Bup0dO3y7xEa0arf3YKPHLycjNiozYHg0xBKNNNuKwNIL52rmdg=
X-Received: by 2002:a17:902:aa41:: with SMTP id c1mr77216740plr.201.1563840217560;
        Mon, 22 Jul 2019 17:03:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcQi9h8r98urp/UzzwtcK05s197cFh1uCsVseA8I4RS9icJX8ois4Yuzu3jUwe+2UajhAt
X-Received: by 2002:a17:902:aa41:: with SMTP id c1mr77216683plr.201.1563840216713;
        Mon, 22 Jul 2019 17:03:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563840216; cv=none;
        d=google.com; s=arc-20160816;
        b=buL2jD+gaAS/h84Qs4JPgMxlXw5bBwQGr+U43vixgB5kzZ8Tv5oYTD/2n5CUtfKJT7
         3Cg7xqi7+iObndsjShZc6YWRGK9+0X747Qstjp5lDz2xmyGu08z1A3ofJj1mT7vHLSqn
         Ndt+fGG3O7V5qBGClRHQ+qWRYirVycktPA54VKZsiLIi4pPI4lesnyy1nRzAB3wo5LUj
         5fVm0NKB2uKQr+iHc0KN/g4H8LlupKYIYBV4RA2PJV4Br1LJa74YSsjeqcdbkIQQz1TR
         VWfXMVtPoMY2wBHMOQ5kyFsas/3VNJwVxjVrkPXzHIUqnOEFYDtCSrSYrxSHpqwPgApX
         aJiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=G2KDi8J+eLxk9PnNxZ4AOboVee294jxqoOE5+8lh0u8=;
        b=afcfheBSC2WwdUedZkRHrf6iwYcjF64DWRTsKS3jD138bCB5LxnVDNYgBEJNQs+siN
         LvAbtFtn0mYeOf5k9LBeXJX92panWmjps7PZ1ZTmnC2WkBpjsiPThJxDi1PDf+t6mzWa
         ZHKauPPUa5J7enbuqaV8Dgl2PuW/5E/Qm1aYioSIb2u5UdD32OYBIxr8EDqBdhNjMoqc
         wzyiQcr5lXU6aFwCkvgm94Ca+r3cU+DzYDA/CMFlgrSFZasj44SGXFK1zkjHMZCcymbr
         wEOI5pZ2abrYQcvUyCoMz+OhsTMrLle5+JhMnjpmz6ChjEjpjfm80Esp4OBEUSbmXbP7
         3Uqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id w18si10933809pgi.37.2019.07.22.17.03.36
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 17:03:36 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 4C6C843B788;
	Tue, 23 Jul 2019 10:03:33 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hpiGA-0001mL-5I; Tue, 23 Jul 2019 10:02:26 +1000
Date: Tue, 23 Jul 2019 10:02:26 +1000
From: Dave Chinner <david@fromorbit.com>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] psi: annotate refault stalls from IO submission
Message-ID: <20190723000226.GV7777@dread.disaster.area>
References: <20190722201337.19180-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722201337.19180-1-hannes@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=0o9FgrsRnhwA:10
	a=ufHFDILaAAAA:8 a=7-415B0cAAAA:8 a=o-jcnmsilH93K4pHmdQA:9
	a=EdKfoW5OtvoDdtON:21 a=SJvZlBx9A85TV0R8:21 a=CjuIK1q_8ugA:10
	a=ZmIg1sZ3JBWsdXgziEIF:22 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 04:13:37PM -0400, Johannes Weiner wrote:
> psi tracks the time tasks wait for refaulting pages to become
> uptodate, but it does not track the time spent submitting the IO. The
> submission part can be significant if backing storage is contended or
> when cgroup throttling (io.latency) is in effect - a lot of time is
> spent in submit_bio(). In that case, we underreport memory pressure.
> 
> Annotate the submit_bio() paths (or the indirection through readpage)
> for refaults and swapin to get proper psi coverage of delays there.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  fs/btrfs/extent_io.c | 14 ++++++++++++--
>  fs/ext4/readpage.c   |  9 +++++++++
>  fs/f2fs/data.c       |  8 ++++++++
>  fs/mpage.c           |  9 +++++++++
>  mm/filemap.c         | 20 ++++++++++++++++++++
>  mm/page_io.c         | 11 ++++++++---
>  mm/readahead.c       | 24 +++++++++++++++++++++++-
>  7 files changed, 89 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
> index 1eb671c16ff1..2d2b3239965a 100644
> --- a/fs/btrfs/extent_io.c
> +++ b/fs/btrfs/extent_io.c
> @@ -13,6 +13,7 @@
>  #include <linux/pagevec.h>
>  #include <linux/prefetch.h>
>  #include <linux/cleancache.h>
> +#include <linux/psi.h>
>  #include "extent_io.h"
>  #include "extent_map.h"
>  #include "ctree.h"
> @@ -4267,6 +4268,9 @@ int extent_readpages(struct address_space *mapping, struct list_head *pages,
>  	struct extent_io_tree *tree = &BTRFS_I(mapping->host)->io_tree;
>  	int nr = 0;
>  	u64 prev_em_start = (u64)-1;
> +	int ret = 0;
> +	bool refault = false;
> +	unsigned long pflags;
>  
>  	while (!list_empty(pages)) {
>  		u64 contig_end = 0;
> @@ -4281,6 +4285,10 @@ int extent_readpages(struct address_space *mapping, struct list_head *pages,
>  				put_page(page);
>  				break;
>  			}
> +			if (PageWorkingset(page) && !refault) {
> +				psi_memstall_enter(&pflags);
> +				refault = true;
> +			}
>  
>  			pagepool[nr++] = page;
>  			contig_end = page_offset(page) + PAGE_SIZE - 1;
> @@ -4301,8 +4309,10 @@ int extent_readpages(struct address_space *mapping, struct list_head *pages,
>  		free_extent_map(em_cached);
>  
>  	if (bio)
> -		return submit_one_bio(bio, 0, bio_flags);
> -	return 0;
> +		ret = submit_one_bio(bio, 0, bio_flags);
> +	if (refault)
> +		psi_memstall_leave(&pflags);
> +	return ret;

This all seems extremely fragile to me. Sprinkling magic,
undocumented pixie dust through the IO paths to account for
something nobody can actually determine is working correctly is a
bad idea.  People are going to break this without knowing it, nobody
is going to notice because there are no regression tests for it,
and this will all end up in frustration for users because it
constantly gets broken and doesn't work reliably.

e.g. If this is needed around all calls to ->readpage(), then please
write a readpage wrapper function and convert all the callers to use
that wrapper.

Even better: If this memstall and "refault" check is needed to
account for bio submission blocking, then page cache iteration is
the wrong place to be doing this check. It should be done entirely
in the bio code when adding pages to the bio because we'll only ever
be doing page cache read IO on page cache misses. i.e. this isn't
dependent on adding a new page to the LRU or not - if we add a new
page then we are going to be doing IO and so this does not require
magic pixie dust at the page cache iteration level

e.g. bio_add_page_memstall() can do the working set check and then
set a flag on the bio to say it contains a memstall page. Then on
submission of the bio the memstall condition can be cleared.

Cheers,

-Dave.
-- 
Dave Chinner
david@fromorbit.com

