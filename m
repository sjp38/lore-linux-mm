Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 7AB166B005A
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 13:01:38 -0400 (EDT)
Message-ID: <1344531695.2393.27.camel@lorien2>
Subject: Re: [PATCH v2] mm: Restructure kmem_cache_create() to move debug
 cache integrity checks into a new function
From: Shuah Khan <shuah.khan@hp.com>
Reply-To: shuah.khan@hp.com
Date: Thu, 09 Aug 2012 11:01:35 -0600
In-Reply-To: <alpine.DEB.2.02.1208090911100.15909@greybox.home>
References: <1342221125.17464.8.camel@lorien2>
	 <CAOJsxLGjnMxs9qERG5nCfGfcS3jy6Rr54Ac36WgVnOtP_pDYgQ@mail.gmail.com>
	 <1344224494.3053.5.camel@lorien2> <1344266096.2486.17.camel@lorien2>
	 <CAAmzW4Ne5pD90r+6zrrD-BXsjtf5OqaKdWY+2NSGOh1M_sWq4g@mail.gmail.com>
	 <1344272614.2486.40.camel@lorien2> <1344287631.2486.57.camel@lorien2>
	 <alpine.DEB.2.02.1208090911100.15909@greybox.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Christoph Lameter (Open Source)" <cl@linux.com>
Cc: penberg@kernel.org, glommer@parallels.com, js1304@gmail.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, shuahkhan@gmail.com

On Thu, 2012-08-09 at 09:13 -0500, Christoph Lameter (Open Source)
wrote:
> On Mon, 6 Aug 2012, Shuah Khan wrote:
> 
> > +#ifdef CONFIG_DEBUG_VM
> > +static int kmem_cache_sanity_check(const char *name, size_t size)
> 
> Why do we pass "size" in? AFAICT there is no need to.

It is an oversight on my part. Will re-work the patch as needed. Please
see more on your second comment below.

> 
> > @@ -53,48 +93,17 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
> >  {
> >  	struct kmem_cache *s = NULL;
> >
> > -#ifdef CONFIG_DEBUG_VM
> >  	if (!name || in_interrupt() || size < sizeof(void *) ||
> >  		size > KMALLOC_MAX_SIZE) {
> > -		printk(KERN_ERR "kmem_cache_create(%s) integrity check"
> > -			" failed\n", name);
> > +		pr_err("kmem_cache_create(%s) integrity check failed\n", name);
> >  		goto out;
> >  	}
> > -#endif
> >
> 
> If you move the above code into the sanity check function then you will be
> using the size as well. These are also sanity checks after all.

Yes these are also sanity checks, however these checks are common to
debug and non-debug paths, hence the reasoning to leave them in
kmem_cache_create(). 

You are right, if these checks get moved into the debug section in
kmem_cache_sanity_check, size will be used.

Moving these checks into kmem_cache_sanity_check() would mean return
path handling will change. The first block of sanity checks for name,
and size etc. are done before holding the slab_mutex and the second
block that checks the slab lists is done after holding the mutex.
Depending on which one fails, return handling is going to be different
in that if second block fails, mutex needs to be unlocked and when the
first block fails, there is no need to do that. Nothing that is too
complex to solve, just something that needs to be handled.

Comments, thoughts on

1. just remove size from kmem_cache_sanity_check() parameters
or
2. move first block sanity checks into kmem_cache_sanity_check()

Personally I prefer the first option to avoid complexity in return path
handling. Would like to hear what others think.

-- Shuah



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
