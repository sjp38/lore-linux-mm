Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 686516B0005
	for <linux-mm@kvack.org>; Tue,  1 May 2018 03:05:56 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id d131-v6so9632494itc.8
        for <linux-mm@kvack.org>; Tue, 01 May 2018 00:05:56 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0030.hostedemail.com. [216.40.44.30])
        by mx.google.com with ESMTPS id 203-v6si6555253itz.110.2018.05.01.00.05.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 May 2018 00:05:55 -0700 (PDT)
Message-ID: <e854ad5b8798efc2e33af153c4bdae2c16031e54.camel@perches.com>
Subject: Re: [RFC v5 PATCH] mm: shmem: make stat.st_blksize return huge page
 size if THP is on
From: Joe Perches <joe@perches.com>
Date: Tue, 01 May 2018 00:05:48 -0700
In-Reply-To: <20180430164000.00f92084ecb1876e481c6a11@linux-foundation.org>
References: <1524665633-83806-1-git-send-email-yang.shi@linux.alibaba.com>
	 <20180430164000.00f92084ecb1876e481c6a11@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yang Shi <yang.shi@linux.alibaba.com>
Cc: kirill.shutemov@linux.intel.com, hughd@google.com, mhocko@kernel.org, hch@infradead.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2018-04-30 at 16:40 -0700, Andrew Morton wrote:
> On Wed, 25 Apr 2018 22:13:53 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:
> 
> > Since tmpfs THP was supported in 4.8, hugetlbfs is not the only
> > filesystem with huge page support anymore. tmpfs can use huge page via
> > THP when mounting by "huge=" mount option.
[]
> > @@ -571,6 +571,16 @@ static unsigned long shmem_unused_huge_shrink(struct shmem_sb_info *sbinfo,
> >  }
> >  #endif /* CONFIG_TRANSPARENT_HUGE_PAGECACHE */
> >  
> > +static inline bool is_huge_enabled(struct shmem_sb_info *sbinfo)
> > +{
> > +	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE) &&
> > +	    (shmem_huge == SHMEM_HUGE_FORCE || sbinfo->huge) &&
> > +	    shmem_huge != SHMEM_HUGE_DENY)
> > +		return true;
> > +	else
> > +		return false;
> > +}
> 
> Nit: we don't need that `else'.  Checkpatch normally warns about this,
> but not in this case.

because there are those that like symmetry.

> --- a/mm/shmem.c~mm-shmem-make-statst_blksize-return-huge-page-size-if-thp-is-on-fix
> +++ a/mm/shmem.c
> @@ -577,8 +577,7 @@ static inline bool is_huge_enabled(struc
>  	    (shmem_huge == SHMEM_HUGE_FORCE || sbinfo->huge) &&
>  	    shmem_huge != SHMEM_HUGE_DENY)
>  		return true;
> -	else
> -		return false;
> +	return false;
>  }

Perhaps this case is better without the if/else as just

	return <logic>;
