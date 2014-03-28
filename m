Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 619466B0037
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 06:13:38 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kp14so4808961pab.33
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 03:13:38 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id k1si3374296pao.306.2014.03.28.03.13.37
        for <linux-mm@kvack.org>;
        Fri, 28 Mar 2014 03:13:37 -0700 (PDT)
Date: Fri, 28 Mar 2014 10:13:15 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v3 2/4] kmemleak: allow freeing internal objects after
 kmemleak was disabled
Message-ID: <20140328101315.GB21330@arm.com>
References: <5335384A.2000000@huawei.com>
 <5335387E.2050005@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5335387E.2050005@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

More nitpicks ;)

On Fri, Mar 28, 2014 at 08:53:18AM +0000, Li Zefan wrote:
> diff --git a/Documentation/kmemleak.txt b/Documentation/kmemleak.txt
> index 6dc8013..a7e6a06 100644
> --- a/Documentation/kmemleak.txt
> +++ b/Documentation/kmemleak.txt
> @@ -51,7 +51,8 @@ Memory scanning parameters can be modified at run-time by writing to the
>  		  (default 600, 0 to stop the automatic scanning)
>    scan		- trigger a memory scan
>    clear		- clear list of current memory leak suspects, done by
> -		  marking all current reported unreferenced objects grey
> +		  marking all current reported unreferenced objects grey.
> +		  Or free all kmemleak objects if kmemleak has been disabled.

Comma after "unreferenced objects grey" and lower-case "or free ..."

> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index be7ecc0..6631df8 100644
[...]
> @@ -1690,17 +1711,16 @@ static const struct file_operations kmemleak_fops = {
>   */
>  static void kmemleak_do_cleanup(struct work_struct *work)
>  {
> -	struct kmemleak_object *object;
> -
>  	mutex_lock(&scan_mutex);
>  	stop_scan_thread();
>  
> -	if (!kmemleak_has_leaks) {
> -		rcu_read_lock();
> -		list_for_each_entry_rcu(object, &object_list, object_list)
> -			delete_object_full(object->pointer);
> -		rcu_read_unlock();
> -	}
> +	if (!kmemleak_has_leaks)
> +		__kmemleak_do_cleanup();
> +	else
> +		pr_info("Disable kmemleak without freeing internal objects, "
> +			"so you may still check information on memory leaks. "
> +			"You may reclaim memory by writing \"clear\" to "
> +			"/sys/kernel/debug/kmemleak\n");

Alternative text:

		pr_info("Kmemleak disabled without freeing internal data. "
			"Reclaim the memory with \"echo clear > /sys/kernel/debug/kmemleak\"\n");

(I'm wouldn't bother with long lines in printk strings)

Otherwise:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
