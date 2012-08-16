Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id B75B56B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 02:40:12 -0400 (EDT)
Received: by weys10 with SMTP id s10so1933561wey.14
        for <linux-mm@kvack.org>; Wed, 15 Aug 2012 23:40:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120815165324.f6e16eee.akpm@linux-foundation.org>
References: <1342221125.17464.8.camel@lorien2>
	<CAOJsxLGjnMxs9qERG5nCfGfcS3jy6Rr54Ac36WgVnOtP_pDYgQ@mail.gmail.com>
	<1344224494.3053.5.camel@lorien2>
	<1344266096.2486.17.camel@lorien2>
	<CAAmzW4Ne5pD90r+6zrrD-BXsjtf5OqaKdWY+2NSGOh1M_sWq4g@mail.gmail.com>
	<1344272614.2486.40.camel@lorien2>
	<1344287631.2486.57.camel@lorien2>
	<alpine.DEB.2.02.1208090911100.15909@greybox.home>
	<1344531695.2393.27.camel@lorien2>
	<alpine.DEB.2.02.1208091406590.20908@greybox.home>
	<1344540801.2393.42.camel@lorien2>
	<1344789618.5128.5.camel@lorien2>
	<20120815165324.f6e16eee.akpm@linux-foundation.org>
Date: Thu, 16 Aug 2012 09:40:10 +0300
Message-ID: <CAOJsxLFkrNVLhojV=id67xuhXDHyEzZiDo=_peRJtgcfAjC9bg@mail.gmail.com>
Subject: Re: [PATCH v3] mm: Restructure kmem_cache_create() to move debug
 cache integrity checks into a new function
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: shuah.khan@hp.com, "Christoph Lameter (Open Source)" <cl@linux.com>, glommer@parallels.com, js1304@gmail.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, shuahkhan@gmail.com

On Thu, Aug 16, 2012 at 2:53 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Sun, 12 Aug 2012 10:40:18 -0600
> Shuah Khan <shuah.khan@hp.com> wrote:
>
>> kmem_cache_create() does cache integrity checks when CONFIG_DEBUG_VM
>> is defined. These checks interspersed with the regular code path has
>> lead to compile time warnings when compiled without CONFIG_DEBUG_VM
>> defined. Restructuring the code to move the integrity checks in to a new
>> function would eliminate the current compile warning problem and also
>> will allow for future changes to the debug only code to evolve without
>> introducing new warnings in the regular path. This restructuring work
>> is based on the discussion in the following thread:
>
> Your patch appears to be against some ancient old kernel, such as 3.5.
> I did this:
>
> --- a/mm/slab_common.c~mm-slab_commonc-restructure-kmem_cache_create-to-move-debug-cache-integrity-checks-into-a-new-function-fix
> +++ a/mm/slab_common.c
> @@ -101,15 +101,8 @@ struct kmem_cache *kmem_cache_create(con
>
>         get_online_cpus();
>         mutex_lock(&slab_mutex);
> -
> -       if (kmem_cache_sanity_check(name, size))
> -               goto oops;
> -
> -       s = __kmem_cache_create(name, size, align, flags, ctor);
> -
> -#ifdef CONFIG_DEBUG_VM
> -oops:
> -#endif
> +       if (kmem_cache_sanity_check(name, size) == 0)
> +               s = __kmem_cache_create(name, size, align, flags, ctor);
>         mutex_unlock(&slab_mutex);
>         put_online_cpus();

Yup. Shuah, care to spin another version against slab/next?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
