Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 08F446B0069
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 11:43:24 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id kq3so63200791wjc.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 08:43:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z4si14053049wmb.59.2017.01.30.08.43.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Jan 2017 08:43:22 -0800 (PST)
Subject: Re: [PATCH 7/9] md: use kvmalloc rather than opencoded variant
References: <20170130094940.13546-1-mhocko@kernel.org>
 <20170130094940.13546-8-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d80af165-9af1-97dc-edda-b1f8701164cd@suse.cz>
Date: Mon, 30 Jan 2017 17:42:18 +0100
MIME-Version: 1.0
In-Reply-To: <20170130094940.13546-8-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Mikulas Patocka <mpatocka@redhat.com>, Mike Snitzer <snitzer@redhat.com>

On 01/30/2017 10:49 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> copy_params uses kmalloc with vmalloc fallback. We already have a helper
> for that - kvmalloc. This caller requires GFP_NOIO semantic so it hasn't
> been converted with many others by previous patches. All we need to
> achieve this semantic is to use the scope memalloc_noio_{save,restore}
> around kvmalloc.
>
> Cc: Mikulas Patocka <mpatocka@redhat.com>
> Cc: Mike Snitzer <snitzer@redhat.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  drivers/md/dm-ioctl.c | 13 ++++---------
>  1 file changed, 4 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/md/dm-ioctl.c b/drivers/md/dm-ioctl.c
> index a5a9b17f0f7f..dbf5b981f7d7 100644
> --- a/drivers/md/dm-ioctl.c
> +++ b/drivers/md/dm-ioctl.c
> @@ -1698,6 +1698,7 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kern
>  	struct dm_ioctl *dmi;
>  	int secure_data;
>  	const size_t minimum_data_size = offsetof(struct dm_ioctl, data);
> +	unsigned noio_flag;
>
>  	if (copy_from_user(param_kernel, user, minimum_data_size))
>  		return -EFAULT;
> @@ -1720,15 +1721,9 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kern
>  	 * Use kmalloc() rather than vmalloc() when we can.
>  	 */
>  	dmi = NULL;
> -	if (param_kernel->data_size <= KMALLOC_MAX_SIZE)
> -		dmi = kmalloc(param_kernel->data_size, GFP_NOIO | __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN);
> -
> -	if (!dmi) {
> -		unsigned noio_flag;
> -		noio_flag = memalloc_noio_save();
> -		dmi = __vmalloc(param_kernel->data_size, GFP_NOIO | __GFP_HIGH | __GFP_HIGHMEM, PAGE_KERNEL);
> -		memalloc_noio_restore(noio_flag);
> -	}
> +	noio_flag = memalloc_noio_save();
> +	dmi = kvmalloc(param_kernel->data_size, GFP_KERNEL);
> +	memalloc_noio_restore(noio_flag);
>
>  	if (!dmi) {
>  		if (secure_data && clear_user(user, param_kernel->data_size))
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
