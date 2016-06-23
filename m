Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 889CA6B0260
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 08:43:01 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l184so52230389lfl.3
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 05:43:01 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id ju7si7110412wjc.112.2016.06.23.05.43.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 05:43:00 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id c82so10675520wme.3
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 05:43:00 -0700 (PDT)
Date: Thu, 23 Jun 2016 14:42:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory:bugxfix panic on cat or write /dev/kmem
Message-ID: <20160623124257.GB30082@dhcp22.suse.cz>
References: <1466703010-32242-1-git-send-email-chenjie6@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466703010-32242-1-git-send-email-chenjie6@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chenjie6@huawei.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David.Woodhouse@intel.com, zhihui.gao@huawei.com, panxuesong@huawei.com, akpm@linux-foundation.org

On Fri 24-06-16 01:30:10, chenjie6@huawei.com wrote:
> From: chenjie <chenjie6@huawei.com>
> 
> cat /dev/kmem and echo > /dev/kmem will lead panic

Writing to /dev/kmem without being extremely careful is a disaster AFAIK
and even reading from the file can lead to unexpected results. Anyway
I am trying to understand what exactly you are trying to fix here. Why
writing to/reading from zero pfn should be any special wrt. any other
potentially dangerous addresses

> 
> Signed-off-by: chenjie <chenjie6@huawei.com>
> ---
>  drivers/char/mem.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/drivers/char/mem.c b/drivers/char/mem.c
> index 71025c2..4bdde28 100644
> --- a/drivers/char/mem.c
> +++ b/drivers/char/mem.c
> @@ -412,6 +412,8 @@ static ssize_t read_kmem(struct file *file, char __user *buf,
>  			 * by the kernel or data corruption may occur
>  			 */
>  			kbuf = xlate_dev_kmem_ptr((void *)p);
> +			if (!kbuf)
> +				return -EFAULT;
>  
>  			if (copy_to_user(buf, kbuf, sz))
>  				return -EFAULT;
> @@ -482,6 +484,11 @@ static ssize_t do_write_kmem(unsigned long p, const char __user *buf,
>  		 * corruption may occur.
>  		 */
>  		ptr = xlate_dev_kmem_ptr((void *)p);
> +		if (!ptr) {
> +			if (written)
> +				break;
> +			return -EFAULT;
> +		}
>  
>  		copied = copy_from_user(ptr, buf, sz);
>  		if (copied) {
> -- 
> 1.8.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
