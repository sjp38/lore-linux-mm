Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 82E516B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 04:35:58 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 97so3063054wrb.1
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 01:35:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a46si9413145eda.73.2017.09.19.01.35.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Sep 2017 01:35:57 -0700 (PDT)
Date: Tue, 19 Sep 2017 10:35:54 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2] mm: introduce validity check on vm dirtiness settings
Message-ID: <20170919083554.GC3216@quack2.suse.cz>
References: <1505775180-12014-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505775180-12014-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: jack@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.com, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, tytso@mit.edu, mawilcox@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 19-09-17 06:53:00, Yafang Shao wrote:
> we can find the logic in domain_dirty_limits() that
> when dirty bg_thresh is bigger than dirty thresh,
> bg_thresh will be set as thresh * 1 / 2.
> 	if (bg_thresh >= thresh)
> 		bg_thresh = thresh / 2;
> 
> But actually we can set vm background dirtiness bigger than
> vm dirtiness successfully. This behavior may mislead us.
> We'd better do this validity check at the beginning.
> 
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>

The patch looks mostly good now. Just some small comments below.

> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 9baf66a..5de02f6 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -156,6 +156,8 @@ read.
>  Note: the minimum value allowed for dirty_bytes is two pages (in bytes); any
>  value lower than this limit will be ignored and the old configuration will be
>  retained.
> +dirty_bytes can't less than dirty_background_bytes or
> +available_memory / 100 * dirty_ratio.

I would phrase this like:

Note: the value of dirty_bytes also cannot be set lower than
dirty_background_bytes or the amount of memory corresponding to
dirty_background_ratio.

>  ==============================================================
>  
> @@ -176,6 +178,9 @@ generating disk writes will itself start writing out dirty data.
>  
>  The total available memory is not equal to total system memory.
>  
> +Note: dirty_ratio can't less than dirty_background_ratio or
> +dirty_background_bytes / available_memory * 100.
> +

And similarly here:

Note: dirty_ratio cannot be set lower than dirty_background_ratio or
ratio corresponding to dirty_background_bytes.


> @@ -511,15 +511,68 @@ bool node_dirty_ok(struct pglist_data *pgdat)
>  	return nr_pages <= limit;
>  }
>  
> +static bool vm_dirty_settings_valid(void)
> +{
> +	bool ret = true;
> +	unsigned long bytes;
> +
> +	if (vm_dirty_ratio > 0) {
> +		if (dirty_background_ratio >= vm_dirty_ratio) {
> +			ret = false;
> +			goto out;
> +		}
> +
> +		bytes = global_dirtyable_memory() * PAGE_SIZE / 100 *
> +				vm_dirty_ratio;
> +		if (dirty_background_bytes >= bytes) {
> +			ret = false;
> +			goto out;
> +		}
> +	}
> +
> +	if (vm_dirty_bytes > 0) {
> +		if (dirty_background_bytes >= vm_dirty_bytes) {
> +			ret = false;
> +			goto out;
> +		}
> +
> +		bytes = global_dirtyable_memory() * PAGE_SIZE / 100 *
> +				dirty_background_ratio;
> +
> +		if (bytes >= vm_dirty_bytes) {
> +			ret = false;
> +			goto out;
> +		}
> +	}
> +
> +	if (vm_dirty_bytes == 0 && vm_dirty_ratio == 0 &&
> +		(dirty_background_bytes != 0 || dirty_background_ratio != 0))
> +		ret = false;

Hum, why not just:
	if ((vm_dirty_bytes == 0 && vm_dirty_ratio) ||
	    (dirty_background_bytes == 0 && dirty_background_ratio == 0))
		ret = false;

IMHO setting either tunable to 0 is just wrong and actively dangerous...

> +out:
> +	if (!ret)
> +		pr_err("vm dirtiness can't less than vm background dirtiness\n");

I would refrain from spamming logs with the error message. In my opinion it
is not needed.

>  int dirty_background_ratio_handler(struct ctl_table *table, int write,
>  		void __user *buffer, size_t *lenp,
>  		loff_t *ppos)
>  {
>  	int ret;
> +	int old_ratio = dirty_background_ratio;
>  
>  	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
> -	if (ret == 0 && write)
> -		dirty_background_bytes = 0;
> +	if (ret == 0 && write) {
> +		if (dirty_background_ratio != old_ratio &&
> +			!vm_dirty_settings_valid()) {

Why do you check whether new ratio is different here? If it is really
needed, it would deserve a comment.

> +			dirty_background_ratio = old_ratio;
> +			ret = -EINVAL;
> +		} else
> +			dirty_background_bytes = 0;
> +	}
> +
>  	return ret;
>  }
>  
> @@ -528,10 +581,17 @@ int dirty_background_bytes_handler(struct ctl_table *table, int write,
>  		loff_t *ppos)
>  {
>  	int ret;
> +	unsigned long old_bytes = dirty_background_bytes;
>  
>  	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
> -	if (ret == 0 && write)
> -		dirty_background_ratio = 0;
> +	if (ret == 0 && write) {
> +		if (dirty_background_bytes != old_bytes &&
> +			!vm_dirty_settings_valid()) {

The same here...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
