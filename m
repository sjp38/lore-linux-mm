Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 88A0A6B003A
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 16:39:56 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id rr13so3492152pbb.18
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 13:39:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id sy3si11258107pab.158.2014.06.20.13.39.55
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 13:39:55 -0700 (PDT)
Date: Fri, 20 Jun 2014 13:39:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 141/230] include/linux/kernel.h:744:28: note: in
 expansion of macro 'min'
Message-Id: <20140620133954.3cc60a53f60edac2d8001b63@linux-foundation.org>
In-Reply-To: <xa1tppi3vc9w.fsf@mina86.com>
References: <53a3c359.yUYVC7fzjYpZLyLq%fengguang.wu@intel.com>
	<20140620055210.GA26552@localhost>
	<xa1tppi3vc9w.fsf@mina86.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Hagen Paul Pfeifer <hagen@jauu.net>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 20 Jun 2014 17:19:55 +0200 Michal Nazarewicz <mina86@mina86.com> wrote:

> On Fri, Jun 20 2014, Fengguang Wu <fengguang.wu@intel.com> wrote:
> >>> include/linux/kernel.h:744:28: note: in expansion of macro 'min'
> >     #define clamp(val, lo, hi) min(max(val, lo), hi)
> >                                ^
> >>> drivers/net/ethernet/intel/i40e/i40e_debugfs.c:1901:11: note: in expansion of macro 'clamp'
> >       bytes = clamp(bytes, (u16)1024, (u16)I40E_MAX_AQ_BUF_SIZE);
> >               ^
> 
> The obvious fix:
> 
> ----------- >8 --------------------------------------------------------------
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> index 44649e0..149864b 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -719,8 +719,8 @@ static inline void ftrace_dump(enum ftrace_dump_mode oops_dump_mode) { }
>         (void) (&_max1 == &_max2);              \
>         _max1 > _max2 ? _max1 : _max2; })
>  
> -#define min3(x, y, z) min(min(x, y), z)
> -#define max3(x, y, z) max(max(x, y), z)
> +#define min3(x, y, z) min((typeof(x))min(x, y), z)
> +#define max3(x, y, z) max((typeof(x))max(x, y), z)

I don't get it.  All the types are u16 so we should be good.

What is the return type of

	_max1 > _max2 ? _max1 : _max2;

when both _max1 and _max2 are u16?  Something other than u16 apparently
- I never knew that.

Maybe we should be fixing min() and max()?

--- a/include/linux/kernel.h~a
+++ a/include/linux/kernel.h
@@ -711,13 +711,13 @@ static inline void ftrace_dump(enum ftra
 	typeof(x) _min1 = (x);			\
 	typeof(y) _min2 = (y);			\
 	(void) (&_min1 == &_min2);		\
-	_min1 < _min2 ? _min1 : _min2; })
+	(typeof(x))(_min1 < _min2 ? _min1 : _min2); })
 
 #define max(x, y) ({				\
 	typeof(x) _max1 = (x);			\
 	typeof(y) _max2 = (y);			\
 	(void) (&_max1 == &_max2);		\
-	_max1 > _max2 ? _max1 : _max2; })
+	(typeof(x))(_max1 > _max2 ? _max1 : _max2); })
 
 #define min3(x, y, z) min(min(x, y), z)
 #define max3(x, y, z) max(max(x, y), z)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
