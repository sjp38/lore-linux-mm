Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0538C6B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 16:45:24 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id lj1so4760646pab.18
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 13:45:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fa16si17412019pac.82.2014.09.22.13.45.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 13:45:24 -0700 (PDT)
Date: Mon, 22 Sep 2014 13:45:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1 2/5] mm: add full variable in swap_info_struct
Message-Id: <20140922134522.00725f561fdae318446a41cb@linux-foundation.org>
In-Reply-To: <1411344191-2842-3-git-send-email-minchan@kernel.org>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>
	<1411344191-2842-3-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com

On Mon, 22 Sep 2014 09:03:08 +0900 Minchan Kim <minchan@kernel.org> wrote:

> Now, swap leans on !p->highest_bit to indicate a swap is full.
> It works well for normal swap because every slot on swap device
> is used up when the swap is full but in case of zram, swap sees
> still many empty slot although backed device(ie, zram) is full
> since zram's limit is over so that it could make trouble when
> swap use highest_bit to select new slot via free_cluster.
> 
> This patch introduces full varaiable in swap_info_struct
> to solve the problem.
> 
> ...
>
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -224,6 +224,7 @@ struct swap_info_struct {
>  	struct swap_cluster_info free_cluster_tail; /* free cluster list tail */
>  	unsigned int lowest_bit;	/* index of first free in swap_map */
>  	unsigned int highest_bit;	/* index of last free in swap_map */
> +	bool	full;			/* whether swap is full or not */

This is protected by swap_info_struct.lock, I worked out.

There's a large comment at swap_info_struct.lock which could be updated.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
