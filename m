Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 35C0F6B0039
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:22:54 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id up15so3583681pbc.8
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:22:53 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id i4si7913082pad.112.2014.01.30.13.22.52
        for <linux-mm@kvack.org>;
        Thu, 30 Jan 2014 13:22:53 -0800 (PST)
Date: Thu, 30 Jan 2014 13:22:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 1/2] mm: add kstrimdup function
Message-Id: <20140130132251.4f662aeddc09d8410dee4490@linux-foundation.org>
In-Reply-To: <1391116318-17253-2-git-send-email-sebastian.capella@linaro.org>
References: <1391116318-17253-1-git-send-email-sebastian.capella@linaro.org>
	<1391116318-17253-2-git-send-email-sebastian.capella@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Capella <sebastian.capella@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Joe Perches <joe@perches.com>, Mikulas Patocka <mpatocka@redhat.com>, Michel Lespinasse <walken@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, 30 Jan 2014 13:11:57 -0800 Sebastian Capella <sebastian.capella@linaro.org> wrote:

> kstrimdup will duplicate and trim spaces from the passed in
> null terminated string.  This is useful for strings coming from
> sysfs that often include trailing whitespace due to user input.
>
> ...
> 
> --- a/include/linux/string.h
> +++ b/include/linux/string.h
>
> ...
>
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
> +	size_t len = strlen(begin);
> +
> +	while (len > 1 && isspace(begin[len - 1]))
> +		len--;

That's off-by-one isn't it?  kstrimdup("   ") should return "", not " ".

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
