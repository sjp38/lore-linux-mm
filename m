Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C9D0C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 12:49:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C754B212F5
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 12:49:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="rK1fCVjr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C754B212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 698416B0003; Mon, 24 Jun 2019 08:49:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 649138E0003; Mon, 24 Jun 2019 08:49:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5379D8E0002; Mon, 24 Jun 2019 08:49:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0764E6B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:49:33 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k22so20370571ede.0
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 05:49:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=GO2oBSDlPl0PNRYpRAnBbZVvBmybpqwS00Has79olYk=;
        b=luhdPoY1mFwt0ECAta6R8yI/aTeeMJJRZXMNGLOxPFofRYWxnLn5Y11kqV0JaXhwyT
         p8Jitsu3LxmTBaslR/KdawB2Bks9f1D71mpOGg4qURX+hll6NEpN/WCvyfPp1MQf+Vdy
         WwSfCMzxaB1ANEEik1wqRLUFK0niiQ+tpE/Ow2kNubHSnInrir0Mb/xutJ3R3AhjFHkN
         c7NvNJEw6Xu1RC039C4W9Gan3A43niIp4CpOHHnJ3xxBInZW5R877xJkwQFpzvnI3loi
         qKTnCgoZA0YNoe5xT9myT5L/HhhPiOnt32++WgdtVVyDnQ594VP10CF5W0p/m0nkm0Z/
         E79A==
X-Gm-Message-State: APjAAAVZv1+yD7MIOg9bY3i0YNgXctb3+TcZuI4dSIN6srfMeXsUi4xn
	eYQaC6iaFLddNcx9i7Lo0JA+RE4mayOWFSHy6YAeFStysKOzKKk8eib6ratyx4Q2BpP/t6V5VP4
	pNa6Fuj1j0upo0wZmf6YFnGa0Na/o9EBkOc2n6ksg0Dsq/MMyyoJ4+q+1OIRM++iX1g==
X-Received: by 2002:a50:d1c6:: with SMTP id i6mr46451110edg.110.1561380572446;
        Mon, 24 Jun 2019 05:49:32 -0700 (PDT)
X-Received: by 2002:a50:d1c6:: with SMTP id i6mr46451048edg.110.1561380571671;
        Mon, 24 Jun 2019 05:49:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561380571; cv=none;
        d=google.com; s=arc-20160816;
        b=ZT+yi6D/9eJxstlaLrn1MYSrIVo5PJFIET3j/Vy8FS9nJGEDCn4cJ5KYz9Z9CH8C2P
         /CjdxMqqD+LMLn6cKng2/Df0CiySpRenxXu5EE5UjYIr9AMtk2LcbrsLQQybGqtiiVrZ
         xOwMHRHFZimvQ9Wld1tFMcLDBK8KDiS3cf1gC78XFnRuHmWqDlPw9Qk8FuGbIjEfv6/Q
         0RKcMdelh7C+BnEKmvOjn+KA10yCdYo9qvJvsueOYXt7DXLV5INu0eIJ6cPI+RLHttWD
         XBBoHVC5b3sZXSaUtskO/+tDV22Ilx7DMY7talLvNrl5u80LfvII7WXyDeh9Z4ILHQAJ
         oqLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=GO2oBSDlPl0PNRYpRAnBbZVvBmybpqwS00Has79olYk=;
        b=o+3OM/BdekEv9RkoZEW9pjoLbUeZV//L6wLBBKJ4lrYh+huqFvbkRNWb3xOOF0L3ww
         /lPlkTnp/N8mrZ3x4Zd8zTeOFMO8rTyvA0snlJODkF4HriIygALBwr9hoDrQHw9mFfU8
         zmpimkxWr+T/R2IslX5bvNOXvhWBJhF245KX7NjkJnv4KFgRdap+kNPHsiPyJyFibe0o
         5Hn6SohZD/b83XSP8BH6eANccF8mDv+RscF+ao520XdjKlMh08EBZE2aqNhqnEbfrb2s
         2oByfkgUzx5HJN1IddkNBqzRU3+0MlOSRnHVyINyjPyaeXfAZnrzQANSTOlWrVuf6Ff4
         mtaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=rK1fCVjr;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h12sor3346459ejc.9.2019.06.24.05.49.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 05:49:31 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=rK1fCVjr;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=GO2oBSDlPl0PNRYpRAnBbZVvBmybpqwS00Has79olYk=;
        b=rK1fCVjro0ij0GY/+VmDa/DZKR+COsmWCeos7/Mw946RphPMrKr5mg9az3IsT3y++Y
         ZQnjSo1yDT9CeRpH++R+6uudXOuGpxZ6ouEp1OO+tcQ8QYKslWyDjoQD7nfVXstHh4Nm
         ZcEnUf1XxbmrYZmYczc5DNmFV349K8x1UTCIeinfMDSQYe0VCgaNOKER6vB8DAWiyJ4c
         oPKVW+X0co8AsiLlaF1hnbjq9I9YFpmk53bmhZl0/FgP5+v+Z4b+Uuz9sJNtGlqG+Z5c
         fTTqIU3ihnunnjAq0x22EnO3IVDCDiA13XWfT8AEcvtFd2QMGB2nvcNfjtPnqTGwP5VO
         U7iw==
X-Google-Smtp-Source: APXvYqyp72hr1uxp/CILmlYg6sj6ztU4rrUmEIE/YZVKldHuBkXQ0HHxrQ0g87k/RrqZ4HGv20IDAw==
X-Received: by 2002:a17:906:c106:: with SMTP id h6mr82142308ejz.112.1561380571354;
        Mon, 24 Jun 2019 05:49:31 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id f36sm3693648ede.47.2019.06.24.05.49.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 05:49:30 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 1BE4210439E; Mon, 24 Jun 2019 15:49:36 +0300 (+03)
Date: Mon, 24 Jun 2019 15:49:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, akpm@linux-foundation.org,
	hdanton@sina.com
Subject: Re: [PATCH v7 6/6] mm,thp: avoid writes to file with THP in pagecache
Message-ID: <20190624124936.2vq55jc3qstxrujj@box>
References: <20190623054749.4016638-1-songliubraving@fb.com>
 <20190623054749.4016638-7-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190623054749.4016638-7-songliubraving@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 22, 2019 at 10:47:49PM -0700, Song Liu wrote:
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
>  fs/namei.c         | 22 +++++++++++++++++++++-
>  include/linux/fs.h | 32 ++++++++++++++++++++++++++++++++
>  mm/filemap.c       |  1 +
>  mm/khugepaged.c    |  4 +++-
>  5 files changed, 60 insertions(+), 2 deletions(-)
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
> index 20831c2fbb34..de64f24b58e9 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -3249,6 +3249,22 @@ static int lookup_open(struct nameidata *nd, struct path *path,
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
> +#ifdef CONFIG_READ_ONLY_THP_FOR_FS

Please, use IS_ENABLED() where it is possible.


-- 
 Kirill A. Shutemov

