Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 716A76B0005
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 13:07:27 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i27so118913916qte.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 10:07:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u128si12775894qkc.250.2016.07.29.10.07.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 10:07:26 -0700 (PDT)
Date: Fri, 29 Jul 2016 19:07:28 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't
	reap memory read by vhost
Message-ID: <20160729170728.GB7698@redhat.com>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org> <1469734954-31247-10-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469734954-31247-10-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>

Well. I promised to not argue, but I can't resist...

On 07/28, Michal Hocko wrote:
>
> --- a/include/linux/uaccess.h
> +++ b/include/linux/uaccess.h
> @@ -76,6 +76,28 @@ static inline unsigned long __copy_from_user_nocache(void *to,
>  #endif		/* ARCH_HAS_NOCACHE_UACCESS */
>
>  /*
> + * A safe variant of __get_user for for use_mm() users to have a
> + * gurantee that the address space wasn't reaped in the background
> + */
> +#define __get_user_mm(mm, x, ptr)				\
> +({								\
> +	int ___gu_err = __get_user(x, ptr);			\
> +	if (!___gu_err && test_bit(MMF_UNSTABLE, &mm->flags))	\
> +		___gu_err = -EFAULT;				\
> +	___gu_err;						\
> +})
> +
> +/* similar to __get_user_mm */
> +static inline __must_check long __copy_from_user_mm(struct mm_struct *mm,
> +		void *to, const void __user * from, unsigned long n)
> +{
> +	long ret = __copy_from_user(to, from, n);
> +	if ((ret >= 0) && test_bit(MMF_UNSTABLE, &mm->flags))
> +		return -EFAULT;
> +	return ret;
> +}

Still fail to understand why do we actually need this, but nevermind.

Can't we instead change handle_pte_fault() or do_anonymous_page() to
fail if MMF_UNSTABLE? We can realy pte_offset_map_lock(), MMF_UNSTABLE
must be visible under this lock.

We do not even need to actually disallow to re-populate the unmapped
pte afaics, so we can even change handle_mm_fault() to check
MMF_UNSTABLE after at the ens and return VM_FAULT_SIGBUS if it is set.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
