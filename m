Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF4EAC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:36:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75DE6214C6
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:36:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75DE6214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23D826B000E; Thu,  8 Aug 2019 12:36:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1ED3C6B0010; Thu,  8 Aug 2019 12:36:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DC856B0266; Thu,  8 Aug 2019 12:36:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE64E6B000E
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 12:36:56 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id e22so20348820qtp.9
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 09:36:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yKYvrkkqWP4ANGNeVIwT/FtMwOf7VhIOleIxOvaNdAQ=;
        b=gJFRClnruQEtSwEa+pyLDQkEiyOS1gFxE2nQZCsEr91RWw+MG9tGXeHJ6rukwKo39r
         XIFDRepQcfqv9bJdHyJE6/8JtPTOtEiHXcjZjJElaiMqIM63WVYJm72VluMI5m8Umal2
         A1Es+0RLnghk63JE8bocLKx56Q8J7GGxLpe8KIpihyKCZdz3NpjpTbie+wKiTOZVCQSg
         uCvczINcZI6o7wKaEP6wWP0cldBzbPyPeiLTCaFIZpNGoqjlFI+wGayChkXKw9ioJQGf
         99wFopvjBBtl1V0vEqDElTOdlyBQVw99vncEbK6dqZnCCILf8O6YkuMG/G7ZPM/i1g97
         LNdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX+GgJN7L0DhZaEJltqF+FMYYzz9jcUyTTfDXvRGLX4tMkpK2kn
	d/eLlOhgcGqTlXwmCzoC5bM9UtwbZqgWSPlQ0p0sm4DP9UlYWHWA4hqHvZmpP4K9Rqfk8YGjxUd
	Mqyi5p6o9koMYvvJY5x8Ht2viXzoJWeN1a2apkho5YrF81kqw+Nc074qx9VgnzOOKEw==
X-Received: by 2002:ac8:5294:: with SMTP id s20mr13832998qtn.279.1565282216687;
        Thu, 08 Aug 2019 09:36:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPA8uPWdsWRTNBlOjHTRam5VydqISH90YaA9lWnGYy+yqMW0c2plzP9WU/qqx1nizL6or9
X-Received: by 2002:ac8:5294:: with SMTP id s20mr13832961qtn.279.1565282216106;
        Thu, 08 Aug 2019 09:36:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565282216; cv=none;
        d=google.com; s=arc-20160816;
        b=Z/KGGSButLBQ7ZPH2XImh+OinsrQnE3gXyM1cQgFZqMlgw0M3L8/gZetG5Y+WRFMND
         bKdfVEiQaXK0xuND+HwZmJv+vFsLAPTG22bKEq+2E6c/r31IPK4toB4xBwvGKQMrFHMI
         GbxCuMIhBjpH+hDkB/RKWQUaVYQ4XATZJP8EbskAzT/QYiJ7vETKPzxnBqgztUL5SNmS
         jdc6yBeGRWWjYZSR9B55K4T8e5NC4Vwh94xpoLTMnUN4aiGSHWncYDEcBo66p1J4izZV
         0PWxRGLr9/D1+/suq07MIKMvTr3FcnpOU3mOnUULmTMv84YsPWCvC5Y3TcUGPy+3abFg
         vSiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yKYvrkkqWP4ANGNeVIwT/FtMwOf7VhIOleIxOvaNdAQ=;
        b=t0snA5RKk1e0rt6MFPjE1JUNJh+X5p2rwYgkXPsreLDWGiYUg+QJAroKhkGAsxXIqH
         4VBDf05nJ0vFNOIugjgmPLoi5NRI/G6LFC2HIwOTaODehJsTZhQWb/x2LNOx7p6ymQo4
         PlgBcZ9i4+YqpAEdbIRDuTo3iww8gmRjq2eFv2aUjCrjexdpBvqg1vM9u/m+n03qJM5D
         18SVIDFyKA5Ui5/TuBddo3y5U88B4dYQCYpHdnZTqh6VLw7wQLmAZzsWJ4894q1ehqiP
         2KmIW+uiWggi0dv77+3jN26CxiusGEHIKIQmWZL074+V4m6qmo+t4IFOAdrl/aE+JFko
         rvYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u72si51317633qka.171.2019.08.08.09.36.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 09:36:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6010664467;
	Thu,  8 Aug 2019 16:36:55 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D3D7710016EB;
	Thu,  8 Aug 2019 16:36:54 +0000 (UTC)
Date: Thu, 8 Aug 2019 12:36:53 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 22/24] xfs: track reclaimable inodes using a LRU list
Message-ID: <20190808163653.GB24551@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-23-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801021752.4986-23-david@fromorbit.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 08 Aug 2019 16:36:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 12:17:50PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Now that we don't do IO from the inode reclaim code, there is no
> need to optimise inode scanning order for optimal IO
> characteristics. The AIL takes care of that for us, so now reclaim
> can focus on selecting the best inodes to reclaim.
> 
> Hence we can change the inode reclaim algorithm to a real LRU and
> remove the need to use the radix tree to track and walk inodes under
> reclaim. This frees up a radix tree bit and simplifies the code that
> marks inodes are reclaim candidates. It also simplifies the reclaim
> code - we don't need batching anymore and all the reclaim logic
> can be added to the LRU isolation callback.
> 
> Further, we get node aware reclaim at the xfs_inode level, which
> should help the per-node reclaim code free relevant inodes faster.
> 
> We can re-use the VFS inode lru pointers - once the inode has been
> reclaimed from the VFS, we can use these pointers ourselves. Hence
> we don't need to grow the inode to change the way we index
> reclaimable inodes.
> 
> Start by adding the list_lru tracking in parallel with the existing
> reclaim code. This makes it easier to see the LRU infrastructure
> separate to the reclaim algorithm changes. Especially the locking
> order, which is ip->i_flags_lock -> list_lru lock.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/xfs/xfs_icache.c | 31 +++++++------------------------
>  fs/xfs/xfs_icache.h |  1 -
>  fs/xfs/xfs_mount.h  |  1 +
>  fs/xfs/xfs_super.c  | 31 ++++++++++++++++++++++++-------
>  4 files changed, 32 insertions(+), 32 deletions(-)
> 
...
> diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
> index a59d3a21be5c..b5c4c1b6fd19 100644
> --- a/fs/xfs/xfs_super.c
> +++ b/fs/xfs/xfs_super.c
...
> @@ -1801,7 +1817,8 @@ xfs_fs_nr_cached_objects(
>  	/* Paranoia: catch incorrect calls during mount setup or teardown */
>  	if (WARN_ON_ONCE(!sb->s_fs_info))
>  		return 0;
> -	return xfs_reclaim_inodes_count(XFS_M(sb));
> +
> +	return list_lru_shrink_count(&XFS_M(sb)->m_inode_lru, sc);

Do we not need locking here, or are we just skipping it because this
apparently maintains a count field and accuracy isn't critical? If the
latter, a one liner comment would be useful.

Brian

>  }
>  
>  static long
> -- 
> 2.22.0
> 

