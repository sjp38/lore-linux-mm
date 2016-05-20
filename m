Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1EB6B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 00:08:58 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 129so26572636pfx.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 21:08:58 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id pb2si24924449pac.41.2016.05.19.21.08.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 21:08:57 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id 145so10050295pfz.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 21:08:57 -0700 (PDT)
Date: Fri, 20 May 2016 13:08:36 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCHv2] mm/zsmalloc: don't fail if can't create debugfs info
Message-ID: <20160520040836.GA573@swordfish>
References: <CADAEsF-kaCQnNN_9gySw3J0UT4mGh8KFp75tGSJtaDAuN1T10A@mail.gmail.com>
 <1463671123-5479-1-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1463671123-5479-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Yu Zhao <yuzhao@google.com>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On (05/19/16 11:18), Dan Streetman wrote:
[..]
>  	zs_stat_root = debugfs_create_dir("zsmalloc", NULL);
>  	if (!zs_stat_root)
> -		return -ENOMEM;
> -
> -	return 0;
> +		pr_warn("debugfs 'zsmalloc' stat dir creation failed\n");
>  }
>  
>  static void __exit zs_stat_exit(void)
> @@ -573,17 +575,19 @@ static const struct file_operations zs_stat_size_ops = {
>  	.release        = single_release,
>  };
>  
> -static int zs_pool_stat_create(struct zs_pool *pool, const char *name)
> +static void zs_pool_stat_create(struct zs_pool *pool, const char *name)
>  {
>  	struct dentry *entry;
>  
> -	if (!zs_stat_root)
> -		return -ENODEV;
> +	if (!zs_stat_root) {
> +		pr_warn("no root stat dir, not creating <%s> stat dir\n", name);
> +		return;
> +	}

just a small nit, there are basically two warn messages now for
`!zs_stat_root':

	debugfs 'zsmalloc' stat dir creation failed
	no root stat dir, not creating <%s> stat dir

may be we need only one of them; but no strong opinions.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
