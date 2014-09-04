Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id D45C66B0038
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 05:22:29 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h15so744693igd.14
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 02:22:29 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ec3si2590227pbc.36.2014.09.04.02.22.07
        for <linux-mm@kvack.org>;
        Thu, 04 Sep 2014 02:22:08 -0700 (PDT)
Message-ID: <1409822387.30155.77.camel@linux.intel.com>
Subject: Re: [mmotm:master 251/287] lib/test-string_helpers.c:293:1:
 warning: the frame size of 1316 bytes is larger than 1024 bytes
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Thu, 04 Sep 2014 12:19:47 +0300
In-Reply-To: <20140903152619.c26f0c7b9031a1d39d729fab@linux-foundation.org>
References: <54010c8c.wA2PyooCbGtrpuaG%fengguang.wu@intel.com>
	 <20140903152619.c26f0c7b9031a1d39d729fab@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Wed, 2014-09-03 at 15:26 -0700, Andrew Morton wrote:
> On Sat, 30 Aug 2014 07:28:12 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   8f1fc64dc9b39fedb7390e086001ce5ec327e80d
> > commit: 626105764fd29c75bd8b01d36b54d0aaca61ac36 [251/287] lib / string_helpers: introduce string_escape_mem()
> > config: make ARCH=i386 allyesconfig
> > 
> > All warnings:
> > 
> >    lib/test-string_helpers.c: In function 'test_string_escape':
> > >> lib/test-string_helpers.c:293:1: warning: the frame size of 1316 bytes is larger than 1024 bytes [-Wframe-larger-than=]
> >     }
> 
> 1k isn't excessive for an __init function but I guess we should fix it
> to avoid drawing attention to ourselves.
> 
> Andy, please review, test, etc?

Sorry, living in the other timezone :-)

Now confirm it works. Compiled and real run testing.

Thanks for fixes!

> 
> 
> I figure the out-of-memory warning means we don't need a warning
> printk.  It won't happen anyway.
> 
> 
> --- a/lib/test-string_helpers.c~lib-string_helpers-introduce-string_escape_mem-fix
> +++ a/lib/test-string_helpers.c
> @@ -5,6 +5,7 @@
>  
>  #include <linux/init.h>
>  #include <linux/kernel.h>
> +#include <linux/slab.h>
>  #include <linux/module.h>
>  #include <linux/random.h>
>  #include <linux/string.h>
> @@ -62,10 +63,14 @@ static const struct test_string strings[
>  static void __init test_string_unescape(const char *name, unsigned int flags,
>  					bool inplace)
>  {
> -	char in[256];
> -	char out_test[256];
> -	char out_real[256];
> -	int i, p = 0, q_test = 0, q_real = sizeof(out_real);
> +	int q_real = 256;
> +	char *in = kmalloc(q_real, GFP_KERNEL);
> +	char *out_test = kmalloc(q_real, GFP_KERNEL);
> +	char *out_real = kmalloc(q_real, GFP_KERNEL);
> +	int i, p = 0, q_test = 0;
> +
> +	if (!in || !out_test || !out_real)
> +		goto out;
>  
>  	for (i = 0; i < ARRAY_SIZE(strings); i++) {
>  		const char *s = strings[i].in;
> @@ -100,6 +105,10 @@ static void __init test_string_unescape(
>  
>  	test_string_check_buf(name, flags, in, p - 1, out_real, q_real,
>  			      out_test, q_test);
> +out:
> +	kfree(out_real);
> +	kfree(out_test);
> +	kfree(in);
>  }
>  
>  struct test_string_1 {
> @@ -255,10 +264,15 @@ static __init void test_string_escape(co
>  				      const struct test_string_2 *s2,
>  				      unsigned int flags, const char *esc)
>  {
> -	char in[256];
> -	char out_test[512];
> -	char out_real[512], *buf = out_real;
> -	int p = 0, q_test = 0, q_real = sizeof(out_real);
> +	int q_real = 512;
> +	char *out_test = kmalloc(q_real, GFP_KERNEL);
> +	char *out_real = kmalloc(q_real, GFP_KERNEL);
> +	char *in = kmalloc(256, GFP_KERNEL);
> +	char *buf = out_real;
> +	int p = 0, q_test = 0;
> +
> +	if (!out_test || !out_real || !in)
> +		goto out;
>  
>  	for (; s2->in; s2++) {
>  		const char *out;
> @@ -289,7 +303,12 @@ static __init void test_string_escape(co
>  
>  	q_real = string_escape_mem(in, p, &buf, q_real, flags, esc);
>  
> -	test_string_check_buf(name, flags, in, p, out_real, q_real, out_test, q_test);
> +	test_string_check_buf(name, flags, in, p, out_real, q_real, out_test,
> +			      q_test);
> +out:
> +	kfree(in);
> +	kfree(out_real);
> +	kfree(out_test);
>  }
>  
>  static __init void test_string_escape_nomem(void)
> _
> 


-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
