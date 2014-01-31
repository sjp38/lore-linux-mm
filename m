Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3F21C6B0035
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 05:31:53 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id jt11so4248680pbb.25
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 02:31:52 -0800 (PST)
Received: from mail-pb0-x22d.google.com (mail-pb0-x22d.google.com [2607:f8b0:400e:c01::22d])
        by mx.google.com with ESMTPS id va10si9948069pbc.308.2014.01.31.02.31.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Jan 2014 02:31:51 -0800 (PST)
Received: by mail-pb0-f45.google.com with SMTP id un15so4263416pbc.32
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 02:31:51 -0800 (PST)
Date: Fri, 31 Jan 2014 02:31:48 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v6 1/2] mm: add kstrimdup function
In-Reply-To: <1391129654-12854-2-git-send-email-sebastian.capella@linaro.org>
Message-ID: <alpine.DEB.2.02.1401310230310.7183@chino.kir.corp.google.com>
References: <1391129654-12854-1-git-send-email-sebastian.capella@linaro.org> <1391129654-12854-2-git-send-email-sebastian.capella@linaro.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Capella <sebastian.capella@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Mikulas Patocka <mpatocka@redhat.com>, Michel Lespinasse <walken@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, 30 Jan 2014, Sebastian Capella wrote:

> kstrimdup creates a whitespace-trimmed duplicate of the passed
> in null-terminated string.  This is useful for strings coming
> from sysfs that often include trailing whitespace due to user
> input.
> 
> Thanks to Joe Perches for this implementation.
> 
> Signed-off-by: Sebastian Capella <sebastian.capella@linaro.org>

Acked-by: David Rientjes <rientjes@google.com>

> ---
>  include/linux/string.h |    1 +
>  mm/util.c              |   30 ++++++++++++++++++++++++++++++
>  2 files changed, 31 insertions(+)
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
> index 808f375..a8b731c 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -1,6 +1,7 @@
>  #include <linux/mm.h>
>  #include <linux/slab.h>
>  #include <linux/string.h>
> +#include <linux/ctype.h>
>  #include <linux/export.h>
>  #include <linux/err.h>
>  #include <linux/sched.h>
> @@ -63,6 +64,35 @@ char *kstrndup(const char *s, size_t max, gfp_t gfp)
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
> + */
> +char *kstrimdup(const char *s, gfp_t gfp)
> +{
> +	char *buf;
> +	char *begin = skip_spaces(s);

This could be const.

> +	size_t len = strlen(begin);
> +
> +	while (len && isspace(begin[len - 1]))
> +		len--;
> +
> +	buf = kmalloc_track_caller(len + 1, gfp);
> +	if (!buf)
> +		return NULL;
> +
> +	memcpy(buf, begin, len);
> +	buf[len] = '\0';
> +
> +	return buf;
> +}
> +EXPORT_SYMBOL(kstrimdup);
> +
> +/**
>   * kmemdup - duplicate region of memory
>   *
>   * @src: memory region to duplicate

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
