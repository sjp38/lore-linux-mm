Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12401C4646C
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:07:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB9C9215EA
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:07:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="PAE6OEZ8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB9C9215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59DB58E0002; Fri, 21 Jun 2019 09:07:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 574738E0001; Fri, 21 Jun 2019 09:07:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 463E08E0002; Fri, 21 Jun 2019 09:07:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EF5D78E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:07:40 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i9so9146095edr.13
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:07:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/K0/kvf7+EWXr6rQfoz7UxMfktgW7/4j5Pgej3x77XM=;
        b=HDdyJrDCZfzncZZ/vTtllyMTs3FVfamy11ZC2bPaD4ztz1IymM4IfFAyajGrcSgxHy
         yeX3MXy/+nmKp3rDbtW7yJKf6YCrb05DI0odOaFj+tVgGuCelTbWI74TZwlwjLbt0YRe
         gN6Hec3z+tLB+C6fC6Gi3tGBKAnBQ5eb4ErmlMhdlJ2pcxnxiJ+hF8+uXZR92l4u8AXT
         kNHSs/7216re8kTVDfX+gwHRsDJAWFpaMao3xHDYLcqPZxqyCqhgCTU2dKXHCkZk9VBx
         ESjbFsGt8rxRU8he6+eSpWWeNN0ngOZR/dxxaY/RAVtdVcyV97AQ6xVN5NXRRcCgfMWw
         Kzfw==
X-Gm-Message-State: APjAAAX7R0DycfVd8Tm3v08Rf+VRKjdwdnBHehBR1KrBZcbiy0/waKxC
	jW2ZLXTPtUsE+0NeFWOa+FNHiNXeZRqxSgofCHeG6wcYJ1QmVq+mlSQ+M5A/0XylIv7b+TSyGAL
	2MsnvTZhC7Ejenm4Xo0X/KDnTFcoba/OWrsejVlIu1XZSzWbhqddQqdXdixdLGEi88w==
X-Received: by 2002:a50:a48a:: with SMTP id w10mr39979800edb.1.1561122460507;
        Fri, 21 Jun 2019 06:07:40 -0700 (PDT)
X-Received: by 2002:a50:a48a:: with SMTP id w10mr39979705edb.1.1561122459713;
        Fri, 21 Jun 2019 06:07:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561122459; cv=none;
        d=google.com; s=arc-20160816;
        b=NLAByCnHxlT754x8/vZ83cdba2fzKCr7SchhYy+qnjp3pYqnpbKjiqd1W6UVK0zHk2
         tMT0s144MH3WEp9use3lGwxw9+MVGQFlPSRn/F7EDAj8MTwKwDawMXRbWZxcPXaK6gl/
         MEsGymvmxZNYK6xovXtbymjBEYnkxvvq+wyO5BmYp7Wo6pHkPnObVUHMifTzoTv6helY
         jul9uURcObxv0xO7fMzFDFFkyB03BrmMjI42Qk4S7UuHWLJsPt6bObgvjoParjmW5vMJ
         KuhtZlnx7cUD5sODLZa4/XJuIeVn/Mdd9ApyBCT6pNs3gqeFRIvapStoe8KYkKk1KBf5
         kiRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/K0/kvf7+EWXr6rQfoz7UxMfktgW7/4j5Pgej3x77XM=;
        b=IW2jdIYCCZKZFbUvmFNivsN9rY8vt9lP+8jktkUs8LxpunrZ+4Z1uihsXp+aKfemeg
         kl/ZRn1iuSqX4yw9Qdg7ujanzBPg65OI2+z8JlCxSZW19EytZVbYbIOOh5ToWb2p8lae
         CF+8dJJ+THW+mCF1dT/F9WmhvgLyNYLT75ekMlXhfB12qdKYL5nL5mAfHNejkqNCVDzE
         8dOcGOaAHVO5gOYj+9MkR1prTbybWJ8F0oEMLHLgu3uJvuT5kykKPPn0LgTV5h8ELzEh
         gUIm4oqSXvBF9Gx6PTeKg5P6XWRJiTa2qb9hMGao7Ai6PdxgBer+yIL89A28Qo3QxPgs
         688w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=PAE6OEZ8;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h14sor2882376ede.5.2019.06.21.06.07.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 06:07:39 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=PAE6OEZ8;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/K0/kvf7+EWXr6rQfoz7UxMfktgW7/4j5Pgej3x77XM=;
        b=PAE6OEZ8NC/qeGpE32S7WnaYR8nyncYe408Jq0CgpSEX5qzdvqxgDZs5ZCZwf9z2M/
         MfmA07u7v2Dcvj6N9Gc4vkUdsz3EIDYCqEMeeoBYxLeIb/y9bGSed3H8d9o3PlC4Ytxn
         oA+VlnKMSsS7quvovP4p8aKwmbYWhZkd0zTnk3u9Du+67+nLBJwp5bknGKkUG+ONwhjz
         tkTJX8Bq4oIKNeZVi+bbrVcdMW8Y1t9Y67TTb0mrmwBheAxfAtMwJDljsYfa7Ogu0jLk
         RAaOEsejUFYQQpQXuZEuxRWQuaGtNp10HL9BRM8wQxljKfSAywRlF4E5te+9lTIG2AOz
         S/QQ==
X-Google-Smtp-Source: APXvYqwSIu9UphVAwE3sOjCJhhXK/jVAbMQD+iKQGW5Qdf6dAWE8bX5wKC8SIAJa13mOWwqqReekHg==
X-Received: by 2002:a50:913c:: with SMTP id e57mr95497578eda.257.1561122459409;
        Fri, 21 Jun 2019 06:07:39 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id e12sm813636edb.72.2019.06.21.06.07.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 06:07:38 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id C59BE10289C; Fri, 21 Jun 2019 16:07:40 +0300 (+03)
Date: Fri, 21 Jun 2019 16:07:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, akpm@linux-foundation.org
Subject: Re: [PATCH v5 6/6] mm,thp: avoid writes to file with THP in pagecache
Message-ID: <20190621130740.ehobvjjj7gjiazjw@box>
References: <20190620205348.3980213-1-songliubraving@fb.com>
 <20190620205348.3980213-7-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620205348.3980213-7-songliubraving@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 01:53:48PM -0700, Song Liu wrote:
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
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
>  fs/inode.c         |  3 +++
>  fs/namei.c         | 22 +++++++++++++++++++++-
>  include/linux/fs.h | 31 +++++++++++++++++++++++++++++++
>  mm/filemap.c       |  1 +
>  mm/khugepaged.c    |  4 +++-
>  5 files changed, 59 insertions(+), 2 deletions(-)
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
> +	struct inode *inode = file_inode(file);
> +
> +	if (inode_is_open_for_write(inode) && filemap_nr_thps(inode->i_mapping))
> +		truncate_pagecache(inode, 0);
> +#endif
> +}
> +
>  /*
>   * Handle the last step of open()
>   */
> @@ -3418,7 +3434,11 @@ static int do_last(struct nameidata *nd,
>  		goto out;
>  opened:
>  	error = ima_file_check(file, op->acc_mode);
> -	if (!error && will_truncate)
> +	if (error)
> +		goto out;
> +
> +	release_file_thp(file);

What protects against re-fill the file with THP in parallel?


-- 
 Kirill A. Shutemov

