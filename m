Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 037F56B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 19:58:42 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id n7so4052707qcx.30
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 16:58:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id j78si3106282qgd.62.2014.01.29.16.58.42
        for <linux-mm@kvack.org>;
        Wed, 29 Jan 2014 16:58:42 -0800 (PST)
Date: Wed, 29 Jan 2014 19:58:36 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH v4 1/2] mm: add kstrimdup function
In-Reply-To: <1391039304-3172-2-git-send-email-sebastian.capella@linaro.org>
Message-ID: <alpine.LRH.2.02.1401291956510.8304@file01.intranet.prod.int.rdu2.redhat.com>
References: <1391039304-3172-1-git-send-email-sebastian.capella@linaro.org> <1391039304-3172-2-git-send-email-sebastian.capella@linaro.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Capella <sebastian.capella@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>



On Wed, 29 Jan 2014, Sebastian Capella wrote:

> kstrimdup will duplicate and trim spaces from the passed in
> null terminated string.  This is useful for strings coming from
> sysfs that often include trailing whitespace due to user input.
> 
> Signed-off-by: Sebastian Capella <sebastian.capella@linaro.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Rik van Riel <riel@redhat.com> (commit_signer:5/10=50%)
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Jerome Marchand <jmarchan@redhat.com>
> Cc: Mikulas Patocka <mpatocka@redhat.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/string.h |    1 +
>  mm/util.c              |   19 +++++++++++++++++++
>  2 files changed, 20 insertions(+)
> 
> diff --git a/include/linux/string.h b/include/linux/string.h
> index ac889c5..f29f9a0 100644
> --- a/include/linux/string.h
> +++ b/include/linux/string.h
> @@ -114,6 +114,7 @@ void *memchr_inv(const void *s, int c, size_t n);
>  
>  extern char *kstrdup(const char *s, gfp_t gfp);
>  extern char *kstrndup(const char *s, size_t len, gfp_t gfp);
> +extern char *kstrimdup(const char *s, gfp_t gfp);
>  extern void *kmemdup(const void *src, size_t len, gfp_t gfp);
>  
>  extern char **argv_split(gfp_t gfp, const char *str, int *argcp);
> diff --git a/mm/util.c b/mm/util.c
> index a24aa22..da17de5 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -63,6 +63,25 @@ char *kstrndup(const char *s, size_t max, gfp_t gfp)
>  EXPORT_SYMBOL(kstrndup);
>  
>  /**
> + * kstrimdup - Trim and copy a %NUL terminated string.
> + * @s: the string to trim and duplicate
> + * @gfp: the GFP mask used in the kmalloc() call when allocating memory
> + *
> + * Returns an address, which the caller must kfree, containing
> + * a duplicate of the passed string with leading and/or trailing
> + * whitespace (as defined by isspace) removed.

It doesn't remove leading whitespace. To remove them, you need to do

char *p = strim(ret);
memmove(ret, p, strlen(p) + 1);

Mikulas

> + */
> +char *kstrimdup(const char *s, gfp_t gfp)
> +{
> +	char *ret = kstrdup(skip_spaces(s), gfp);
> +
> +	if (ret)
> +		strim(ret);
> +	return ret;
> +}
> +EXPORT_SYMBOL(kstrimdup);
> +
> +/**
>   * kmemdup - duplicate region of memory
>   *
>   * @src: memory region to duplicate
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
