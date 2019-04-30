Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1832CC43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:18:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB78521707
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:18:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="YFOApBlh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB78521707
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68FFC6B0007; Tue, 30 Apr 2019 11:18:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 641236B0008; Tue, 30 Apr 2019 11:18:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 508856B000A; Tue, 30 Apr 2019 11:18:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 15D5C6B0007
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 11:18:20 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o1so9200803pgv.15
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 08:18:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=jzZU5S7D0PFnQHhGt++IzIfE4eQUJO0gpL6CGYFTVfQ=;
        b=i0cI/9maMX9tL76LrGRqSVS3zsDclpwgpF6Nf70MmgTRt8Z9tWaKjGx4RIpot9IN6f
         DIFpeCWaytwhwVn17bpg9ChKBgox+uRVfjegzag8J3cSJ/YaXvucqQmYF4MHixll5SzL
         uxXvXPNycX/YuzB+s7A0mTSphJQvRKp8FI2OxYJj9v9Rb0VCi/SYf8vLDGmHekOEFR49
         +GNFTBe5G7RLURCD1UGF1MBloZVws4YH320VFuaxh6j0Xsbgp/PdIJCkvibjP/X149M2
         ucthIA9XvhgrS9MmoK1TSC9a/g4xG3eVdJ61LZ53f6qvY62NYmE2kiv9llRTMJ5/V6bv
         cyqQ==
X-Gm-Message-State: APjAAAVHJ6z/OTTT3CGxP2wroxcZguW+CM+B+XRv22Vjtxzv+nPRJ+Kh
	Ow/spX8Bi6/jnRn9Fp0ipJZN/glQpGVLcEiLBPTiS4MxD7kQITMUupK2av7FBsuKfUzCs90Qz85
	tFmzCt1CR2Qnlm9PgJtS5SYjbU/rbJv4OiRpRseSvnuR1EQjgROt90w1z5ieVn/LJvg==
X-Received: by 2002:a63:2118:: with SMTP id h24mr19325048pgh.320.1556637499629;
        Tue, 30 Apr 2019 08:18:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPDtl/8xeNGvwEk18T00PFlwBhTqVEu0rxqy8lQv2SJ2sCkClkkH1BO2Qv8pZVzX1h0i/I
X-Received: by 2002:a63:2118:: with SMTP id h24mr19324968pgh.320.1556637498910;
        Tue, 30 Apr 2019 08:18:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556637498; cv=none;
        d=google.com; s=arc-20160816;
        b=07CT0bYIaYT0TiiCE4qoeiRPy5fxTNVhXfXyFk0xkwdGMyn1bGm5t6MrE1988rJbGQ
         t2EGtEHVJKhxOZlOY6gHzaSkcik8WTc/iuUYruy1oxpMxuo2ZAdnqiWBY5pB0xXTJGgM
         1P2ya5cx/rXJOMul/oxgDXSglCn+z9SPi/msA4urLavuWl7YnNan9WRQRXYZqV31QBjr
         KHC2bS0rpxZ5WfrLFUpTKABOqmxwaZ6szyrbpzqiuM5WSbRasS3eOhVQPHUeX8jDXHRx
         H1dB5JLB0BOhYoK0Eqxp+d8UNTuWkGETQSsyz0yhcEfGsxJy1rwK/XVuUd6mZtbC5cfW
         5g0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=jzZU5S7D0PFnQHhGt++IzIfE4eQUJO0gpL6CGYFTVfQ=;
        b=Xdv9mSf4PbioS+XJUQ0AQJnqxHKwF7KZrUpoyuqnL5HPpsuUxv96cd4HkzuYM2MCHo
         T6kpl1U03+RlgTVuv+2zEUKozL5oF32cTj9fMuemMDy7v1wzk1C+PBoy6jPNyj5Yx18K
         CJ2rmTuur5eqmk6oYGZiR/a/pQsmFs3UP2Dl2iTlGeyhp1oI04V7+bRxxeFFsEPDpEmr
         FJXSylKH14lxBJsWfvyngX7qzT4NTb25ZKuKPyp6/r8EH3huJuFBc+n3/VJTjXoVXnRR
         7gsDMDcwQZBa9c4rxgJiw6pC4kqkzcyQrFpq0ejeadJZiTJDYM2SKJlaDq6yTyfbbbei
         CwNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=YFOApBlh;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id y1si9956845pli.411.2019.04.30.08.18.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 08:18:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=YFOApBlh;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3UF9Q7t096269;
	Tue, 30 Apr 2019 15:17:25 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=jzZU5S7D0PFnQHhGt++IzIfE4eQUJO0gpL6CGYFTVfQ=;
 b=YFOApBlhGiuCaYb6++ewapKgPoSL4iOOzBV7zYcz5BObHaeOejH7TMl7fs98iak3891M
 1MZDYP7A459ryCVgS/wDbMEQpcAvzqXkEVRg80/UC8HyVGmGE4Ji+N0EYWthcQJaKy3y
 Sy8WK4W/Ca9RyCujC9h9qa8nORdZ5BdtxmlD4O8SgfniYw6t/xQQ5Xvi1mdXgUJpjtdf
 zKdyy+U7SL6WnX5v+cM/EzX9gX2eqsSmjKe5weFgoxuj7dfhsSV0Kakm3+lPsvosWYPY
 RCJW0d3yXi48yHus+BsasbYluenCGQf4hta1dnNGD9F+xlI1GOzSUm2PnqpiXEc09he4 9w== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2s5j5u1xa8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Apr 2019 15:17:14 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3UFGfFi064844;
	Tue, 30 Apr 2019 15:17:14 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2s4d4ajyg2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Apr 2019 15:17:13 +0000
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3UFHCVQ021587;
	Tue, 30 Apr 2019 15:17:12 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 30 Apr 2019 08:17:12 -0700
Date: Tue, 30 Apr 2019 08:17:10 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
        Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>,
        Dave Chinner <david@fromorbit.com>,
        Ross Lagerwall <ross.lagerwall@citrix.com>,
        Mark Syms <Mark.Syms@citrix.com>,
        Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v7 2/5] fs: Turn __generic_write_end into a void function
Message-ID: <20190430151710.GC5200@magnolia>
References: <20190429220934.10415-1-agruenba@redhat.com>
 <20190429220934.10415-3-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429220934.10415-3-agruenba@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9242 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904300094
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9242 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904300094
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 12:09:31AM +0200, Andreas Gruenbacher wrote:
> The VFS-internal __generic_write_end helper always returns the value of
> its @copied argument.  This can be confusing, and it isn't very useful
> anyway, so turn __generic_write_end into a function returning void
> instead.

(Also weird that @copied is unsigned but the return value is signed...)

> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>

Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/buffer.c   | 6 +++---
>  fs/internal.h | 2 +-
>  fs/iomap.c    | 2 +-
>  3 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index ce357602f471..e0d4c6a5e2d2 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -2085,7 +2085,7 @@ int block_write_begin(struct address_space *mapping, loff_t pos, unsigned len,
>  }
>  EXPORT_SYMBOL(block_write_begin);
>  
> -int __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
> +void __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
>  		struct page *page)
>  {
>  	loff_t old_size = inode->i_size;
> @@ -2116,7 +2116,6 @@ int __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
>  	 */
>  	if (i_size_changed)
>  		mark_inode_dirty(inode);
> -	return copied;
>  }
>  
>  int block_write_end(struct file *file, struct address_space *mapping,
> @@ -2160,7 +2159,8 @@ int generic_write_end(struct file *file, struct address_space *mapping,
>  			struct page *page, void *fsdata)
>  {
>  	copied = block_write_end(file, mapping, pos, len, copied, page, fsdata);
> -	return __generic_write_end(mapping->host, pos, copied, page);
> +	__generic_write_end(mapping->host, pos, copied, page);
> +	return copied;
>  }
>  EXPORT_SYMBOL(generic_write_end);
>  
> diff --git a/fs/internal.h b/fs/internal.h
> index 6a8b71643af4..530587fdf5d8 100644
> --- a/fs/internal.h
> +++ b/fs/internal.h
> @@ -44,7 +44,7 @@ static inline int __sync_blockdev(struct block_device *bdev, int wait)
>  extern void guard_bio_eod(int rw, struct bio *bio);
>  extern int __block_write_begin_int(struct page *page, loff_t pos, unsigned len,
>  		get_block_t *get_block, struct iomap *iomap);
> -int __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
> +void __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
>  		struct page *page);
>  
>  /*
> diff --git a/fs/iomap.c b/fs/iomap.c
> index 2344c662e6fc..f8c9722d1a97 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -777,7 +777,7 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
>  		ret = __iomap_write_end(inode, pos, len, copied, page, iomap);
>  	}
>  
> -	ret = __generic_write_end(inode, pos, ret, page);
> +	__generic_write_end(inode, pos, ret, page);
>  	if (iomap->page_done)
>  		iomap->page_done(inode, pos, copied, page, iomap);
>  
> -- 
> 2.20.1
> 

