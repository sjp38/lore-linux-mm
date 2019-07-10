Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C39EC74A3D
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 19:11:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3820120651
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 19:11:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="j9c62XFE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3820120651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B361D8E008B; Wed, 10 Jul 2019 15:11:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE7188E0032; Wed, 10 Jul 2019 15:11:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D5FB8E008B; Wed, 10 Jul 2019 15:11:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67F128E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 15:11:23 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j22so1893839pfe.11
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 12:11:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3RBKExhVhuO8dUwdopkobYrfDp83fiSSvdj+BjPC70s=;
        b=Lzt4PVldo9zs/to3xqLjZbWieZwZ3TzqkB6w/Jj++uTAp+SF6mkZ6Dnd3/+VfNyGJQ
         hjEXLakl8tZBqUJnLN319u+lDWWl8dG4JOWUg0mMkbmRVdfiRorisMwSOs0EtGUh1m+D
         PNWmJmUKOlb58fZvA0sMSImljzmHOZ15gQlaLcjiFBG5ucE3HjnGRXj6VQmlme7VFO8s
         +8bk2HhZQG2C6TpsVzOp4RW9F+rrks/2W8nDvDgCTiokoaW8E/TY4EvZfdkPbwg0fBXE
         TfxP5ZxrJsbrz6FXYX/JEkzwnHOInLlxUZGa60mcTVrzz5rQ77vbwuQ6JEEnvA1VXsLt
         jmWw==
X-Gm-Message-State: APjAAAXtCNrCxh8yc/m4Pi7LUHVkXeQLbJg7vrQta8qP7mC/iJWN4hns
	48PoZplR/2doNDpFGaB6KxMJZPtS2/ITebzJszHZoB2qkpxJvb4Pw5t3Yt5hgmflJ76ZCncWb/i
	zXytV6xTjuq/Wm1SuH+otx+65cHo8nDpvFPr3Y5497aDuFf2KgQ8xkuGYfVIzGMZJYg==
X-Received: by 2002:a63:5402:: with SMTP id i2mr38548674pgb.414.1562785882821;
        Wed, 10 Jul 2019 12:11:22 -0700 (PDT)
X-Received: by 2002:a63:5402:: with SMTP id i2mr38548596pgb.414.1562785881718;
        Wed, 10 Jul 2019 12:11:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562785881; cv=none;
        d=google.com; s=arc-20160816;
        b=FTJMgYYvICidwZXEsZFmkm0BpGYSHg+cJZM8Cos5d/0xmauJFyGOYNB+qsdB7h8wOy
         GDl+hr0sNAzYHUA08UQRsHwUXHNrbze6W8Ty4I7F/a3oeJn62L41oD7AgpF0tU98N3JN
         R0b9UCbXjlzWXi2gCp9HlmEOw97o5tD+/xX5gFbOuhMOzV8cQz91tLHiLukFE11KQQMF
         r6/jt+1pwBLVodvrB9hP5aatYmZEhHBNUkyNq3QLYE/zpM5kQ4aHNphStpZTq9iMQ9WR
         GbwuzHKsN4PCJW+PpX+eeY6HonI/7/IVveQIBqsyC3zPFUhOZyzlTNEjB0ZemFA6Hbqu
         3lWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3RBKExhVhuO8dUwdopkobYrfDp83fiSSvdj+BjPC70s=;
        b=WKAhipzznxcbwzbsyNHTNmqlqte+REctAsvBMAXtRni/fK3HZ0uMe2Y5aqxH5pE09q
         Ey/TxV5Na3hYiUH2IqUHTqiT1enpddLYdCoUTUbmTjGA72rRZRfEd6Qvt28blOt//nHk
         L5lwzkC2HH3Q0ntOFrUjl1gvum/fFij9ggDZS++Df7tv7s77ltjkTVPh+8MVVJ59CXvb
         Hg981M8JHswELuTo6iMS9Kn6gQcM6OaPESxIxp4XfaxmiRDbG/rcg4On8oElK3bbplJX
         j1HFR1+ZN0huP8pjIZUQKKEKbaJkZ5cuWV2NcNqtE46915qZyFm6RsNm9biGCSCxrCpP
         BrPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=j9c62XFE;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s13sor3803400plr.24.2019.07.10.12.11.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 12:11:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=j9c62XFE;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3RBKExhVhuO8dUwdopkobYrfDp83fiSSvdj+BjPC70s=;
        b=j9c62XFEZ9kneeuEMtK85d/vkG2d0b3HHa2TZlXsQSuaSKSRug6eb1bl4cKUZZkmJK
         6IS8RZlqzhzFjwNz+zV5QgphhyNsbooUbliEaAnL4/k7y78mowllauMGCE5dCXCUR5+L
         thZKWFHCr6OTl+X4yZ6gTpNHZ3qUDwhE+4uFb5Kl6OwMqJTXO/DGXzNq1TGMG1BZkTdw
         HGxldShXjkSPmX1j5S9pdclx8uY3JXY7bNK29ZFVh0twxvORyjed8MOPePpt96DK/DaI
         5BDryfetRewi2JhNcZ3WsMMVy0mvAAX2JwEk1fsuD/9i0kMVR5sAqIqGyMl0WVWas+N/
         NEiQ==
X-Google-Smtp-Source: APXvYqzFRRFWfxpescU3C0myEwOeav3RIPv9v2eiOwcuRGi+UKzV4Z/k6Bf+F4vc1CD5unHTdPoy5A==
X-Received: by 2002:a17:902:a50d:: with SMTP id s13mr40889083plq.12.1562785878616;
        Wed, 10 Jul 2019 12:11:18 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:5b9d])
        by smtp.gmail.com with ESMTPSA id t11sm3066474pgb.33.2019.07.10.12.11.17
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 12:11:17 -0700 (PDT)
Date: Wed, 10 Jul 2019 15:11:16 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, akpm@linux-foundation.org,
	hdanton@sina.com
Subject: Re: [PATCH v9 6/6] mm,thp: avoid writes to file with THP in pagecache
Message-ID: <20190710191116.GG11197@cmpxchg.org>
References: <20190625001246.685563-1-songliubraving@fb.com>
 <20190625001246.685563-7-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625001246.685563-7-songliubraving@fb.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 05:12:46PM -0700, Song Liu wrote:
> In previous patch, an application could put part of its text section in
> THP via madvise(). These THPs will be protected from writes when the
> application is still running (TXTBSY). However, after the application
> exits, the file is available for writes.
> 
> This patch avoids writes to file THP by dropping page cache for the file
> when the file is open for write. A new counter nr_thps is added to struct
> address_space. In do_last(), if the file is open for write and nr_thps
> is non-zero, we drop page cache for the whole file.
> 
> Reported-by: kbuild test robot <lkp@intel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
>  fs/inode.c         |  3 +++
>  fs/namei.c         | 23 ++++++++++++++++++++++-
>  include/linux/fs.h | 32 ++++++++++++++++++++++++++++++++
>  mm/filemap.c       |  1 +
>  mm/khugepaged.c    |  4 +++-
>  5 files changed, 61 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/inode.c b/fs/inode.c
> index df6542ec3b88..518113a4e219 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -181,6 +181,9 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
>  	mapping->flags = 0;
>  	mapping->wb_err = 0;
>  	atomic_set(&mapping->i_mmap_writable, 0);
> +#ifdef CONFIG_READ_ONLY_THP_FOR_FS
> +	atomic_set(&mapping->nr_thps, 0);
> +#endif
>  	mapping_set_gfp_mask(mapping, GFP_HIGHUSER_MOVABLE);
>  	mapping->private_data = NULL;
>  	mapping->writeback_index = 0;
> diff --git a/fs/namei.c b/fs/namei.c
> index 20831c2fbb34..3d95e94029cc 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -3249,6 +3249,23 @@ static int lookup_open(struct nameidata *nd, struct path *path,
>  	return error;
>  }
>  
> +/*
> + * The file is open for write, so it is not mmapped with VM_DENYWRITE. If
> + * it still has THP in page cache, drop the whole file from pagecache
> + * before processing writes. This helps us avoid handling write back of
> + * THP for now.
> + */
> +static inline void release_file_thp(struct file *file)
> +{
> +	if (IS_ENABLED(CONFIG_READ_ONLY_THP_FOR_FS)) {
> +		struct inode *inode = file_inode(file);
> +
> +		if (inode_is_open_for_write(inode) &&
> +		    filemap_nr_thps(inode->i_mapping))
> +			truncate_pagecache(inode, 0);
> +	}
> +}
> +
>  /*
>   * Handle the last step of open()
>   */
> @@ -3418,7 +3435,11 @@ static int do_last(struct nameidata *nd,
>  		goto out;
>  opened:
>  	error = ima_file_check(file, op->acc_mode);
> -	if (!error && will_truncate)
> +	if (error)
> +		goto out;
> +
> +	release_file_thp(file);
> +	if (will_truncate)
>  		error = handle_truncate(file);

This would seem better placed in do_dentry_open(), where we're done
with the namespace operation and actually work against the inode.

Something roughly like this?

diff --git a/fs/open.c b/fs/open.c
index b5b80469b93d..cae893edbab6 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -799,6 +799,11 @@ static int do_dentry_open(struct file *f,
 		if (!f->f_mapping->a_ops || !f->f_mapping->a_ops->direct_IO)
 			return -EINVAL;
 	}
+
+	/* XXX: Huge page cache doesn't support writing yet */
+	if ((f->f_mode & FMODE_WRITE) && filemap_nr_thps(inode->i_mapping))
+		truncate_pagecache(inode, 0);
+
 	return 0;
 
 cleanup_all:

