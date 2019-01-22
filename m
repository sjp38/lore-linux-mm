Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id B52AD8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 11:08:08 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id v16so12377101wru.8
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 08:08:08 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id p7si12995513wmh.162.2019.01.22.08.08.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 22 Jan 2019 08:08:07 -0800 (PST)
Date: Tue, 22 Jan 2019 17:07:59 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] backing-dev: no need to check return value of
 debugfs_create functions
Message-ID: <20190122160759.mx3h7gjc23zmrvxc@linutronix.de>
References: <20190122152151.16139-8-gregkh@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190122152151.16139-8-gregkh@linuxfoundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Anders Roxell <anders.roxell@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org

On 2019-01-22 16:21:07 [+0100], Greg Kroah-Hartman wrote:
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 8a8bb8796c6c..85ef344a9c67 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -102,39 +102,25 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
>  }
>  DEFINE_SHOW_ATTRIBUTE(bdi_debug_stats);
>  
> -static int bdi_debug_register(struct backing_dev_info *bdi, const char *name)
> +static void bdi_debug_register(struct backing_dev_info *bdi, const char *name)
>  {
> -	if (!bdi_debug_root)
> -		return -ENOMEM;
> -
>  	bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);

If this fails then ->debug_dir is NULL 

> -	if (!bdi->debug_dir)
> -		return -ENOMEM;
> -
> -	bdi->debug_stats = debugfs_create_file("stats", 0444, bdi->debug_dir,
> -					       bdi, &bdi_debug_stats_fops);
> -	if (!bdi->debug_stats) {
> -		debugfs_remove(bdi->debug_dir);
> -		bdi->debug_dir = NULL;
> -		return -ENOMEM;
> -	}
>  
> -	return 0;
> +	debugfs_create_file("stats", 0444, bdi->debug_dir, bdi,
> +			    &bdi_debug_stats_fops);

then this creates the stats file in the root folder and

>  }
>  
>  static void bdi_debug_unregister(struct backing_dev_info *bdi)
>  {
> -	debugfs_remove(bdi->debug_stats);
> -	debugfs_remove(bdi->debug_dir);
> +	debugfs_remove_recursive(bdi->debug_dir);

this won't remove it.

If you return for "debug_dir == NULL" then it is a nice cleanup.

Sebastian
