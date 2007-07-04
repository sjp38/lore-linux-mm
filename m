Date: Wed, 4 Jul 2007 04:27:21 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Re: [PATCH] Re: Sparc32: random invalid instruction occourances on
 sparc32 (sun4c)
In-Reply-To: <1183505787.29081.62.camel@shinybook.infradead.org>
Message-ID: <Pine.LNX.4.61.0707040335230.30946@mtfhpc.demon.co.uk>
References: <468A7D14.1050505@googlemail.com>  <Pine.LNX.4.61.0707031817050.29930@mtfhpc.demon.co.uk>
  <Pine.LNX.4.61.0707031910280.29930@mtfhpc.demon.co.uk>
 <1183490778.29081.35.camel@shinybook.infradead.org>
 <Pine.LNX.4.61.0707032209230.30376@mtfhpc.demon.co.uk>
 <1183499781.29081.46.camel@shinybook.infradead.org>
 <Pine.LNX.4.61.0707032317590.30376@mtfhpc.demon.co.uk>
 <1183505787.29081.62.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org, David Miller <davem@davemloft.net>, Christoph Lameter <clameter@engr.sgi.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Hi David,

I tried the previous patch and it looks like it fixes the issue however 
one of the test builds I did caused depmod to use up all available memory 
(40M - kernel memory) before taking out the kernel with the oom killer.
At present, I do not know if it is a depmod issue or a kernel issue.
I will have to do some more tests later on to day.

I have looked at the latest patch below and am I am still not sure about 
two areas. Please take a look at my offering based on your latest 
patch (included here to it will probably get mangled).

Note the change to lines 2178 to 2185. I have also changed/moved the 
alignment of size (see lines 2197 to 2206) based on your changes.

--- linux-2.6/mm/slab.c	2007-07-03 19:09:48.000000000 +0100
+++ linux-test/mm/slab.c	2007-07-04 04:14:15.000000000 +0100
@@ -137,6 +137,7 @@

  /* Shouldn't this be in a header file somewhere? */
  #define	BYTES_PER_WORD		sizeof(void *)
+#define RED_ZONE_ALIGN_MASK	(max(__alignof__(void *), __alignof(unsigned long long)) - 1)

  #ifndef cache_line_size
  #define cache_line_size()	L1_CACHE_BYTES
@@ -547,7 +548,7 @@ static unsigned long long *dbg_redzone2(
  	if (cachep->flags & SLAB_STORE_USER)
  		return (unsigned long long *)(objp + cachep->buffer_size -
  					      sizeof(unsigned long long) -
-					      BYTES_PER_WORD);
+					      max(BYTES_PER_WORD, __alignof__(unsigned long long)));
  	return (unsigned long long *) (objp + cachep->buffer_size -
  				       sizeof(unsigned long long));
  }
@@ -2178,7 +2179,8 @@ kmem_cache_create (const char *name, siz
  	 * above the next power of two: caches with object sizes just above a
  	 * power of two have a significant amount of internal fragmentation.
  	 */
-	if (size < 4096 || fls(size - 1) == fls(size-1 + 3 * BYTES_PER_WORD))
+	if (size < 4096 || fls(size - 1) == fls(size-1 + 2 * sizeof(unsigned long long) +
+						max(BYTES_PER_WORD, __alignof__(unsigned long long))))
  		flags |= SLAB_RED_ZONE | SLAB_STORE_USER;
  	if (!(flags & SLAB_DESTROY_BY_RCU))
  		flags |= SLAB_POISON;
@@ -2197,9 +2199,9 @@ kmem_cache_create (const char *name, siz
  	 * unaligned accesses for some archs when redzoning is used, and makes
  	 * sure any on-slab bufctl's are also correctly aligned.
  	 */
-	if (size & (BYTES_PER_WORD - 1)) {
-		size += (BYTES_PER_WORD - 1);
-		size &= ~(BYTES_PER_WORD - 1);
+	if (size & RED_ZONE_ALIGN_MASK) {
+		size += RED_ZONE_ALIGN_MASK;
+		size &= ~RED_ZONE_ALIGN_MASK;
  	}

  	/* calculate the final buffer alignment: */
@@ -2261,9 +2263,14 @@ kmem_cache_create (const char *name, siz
  	}
  	if (flags & SLAB_STORE_USER) {
  		/* user store requires one word storage behind the end of
-		 * the real object.
+		 * the real object. But if the second red zone must be
+		 * aligned 'better' than that, allow for it.
  		 */
-		size += BYTES_PER_WORD;
+		if (flags & SLAB_RED_ZONE
+		    && BYTES_PER_WORD < __alignof__(unsigned long long))
+			size += __alignof__(unsigned long long);
+		else
+			size += BYTES_PER_WORD;
  	}
  #if FORCED_DEBUG && defined(CONFIG_DEBUG_PAGEALLOC)
  	if (size >= malloc_sizes[INDEX_L3 + 1].cs_size

---

Let me know if you would like an un-mangled copy of the patch as an 
attachement.

Regards
 	Mark Fortescue.

On Tue, 3 Jul 2007, David Woodhouse wrote:

> On Tue, 2007-07-03 at 23:47 +0100, Mark Fortescue wrote:
>> Hi David,
>>
>> I will try out your patch shortly.
>
> Thanks.
>
>> I may be wrong about the size calculations but if you take a look at lines
>> 2174 to 2188 and 2207 to 2203, reading the comments suggest to me that
>> these need to be changed to match the changes to the RedZone words.
>> Failing to change these means that 32bit aligned access of the 64bit
>> RedZone words is still posible and this will kill sun4c.
>
> Why do we need more than the existing:
>
> 	if (flags & SLAB_RED_ZONE || flags & SLAB_STORE_USER)
> 		ralign = __alignof__(unsigned long long);
>
>> For the 64bit RedZone word to be 64bit aligned (required by sun4c), the
>> User word must be 64bit aligned. I don't see where in your patch, this is
>> enforced.
>
> Where __alignof__(long long) > BYTES_PER_WORD my patch should lead to
> this layout (32-bit words):
>
>    [ redzone1 bits 63-32 ]
>    [ redzone1 bits 31-0  ]
>    [    ... object ...   ]
>    [    ... object ...   ]
>    [ redzone2 bits 63-32 ]
>    [ redzone2 bits 31-0  ]
>    [        unused       ]
>    [      user word      ]
>
> The user word is a 32-bit value; there's no requirement for _it_ to be
> aligned.
>
> Hm, actually I think my patch may be incomplete -- I need to adjust the
> size of the actual object too. This patch should be better...
>
> diff --git a/mm/slab.c b/mm/slab.c
> index a9c4472..8081c07 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -547,7 +547,7 @@ static unsigned long long *dbg_redzone2(struct kmem_cache *cachep, void *objp)
> 	if (cachep->flags & SLAB_STORE_USER)
> 		return (unsigned long long *)(objp + cachep->buffer_size -
> 					      sizeof(unsigned long long) -
> -					      BYTES_PER_WORD);
> +					      max(BYTES_PER_WORD, __alignof__(unsigned long long)));
> 	return (unsigned long long *) (objp + cachep->buffer_size -
> 				       sizeof(unsigned long long));
> }
> @@ -2223,8 +2223,11 @@ kmem_cache_create (const char *name, size_t size, size_t align,
> 	 * overridden by architecture or caller mandated alignment if either
> 	 * is greater than BYTES_PER_WORD.
> 	 */
> -	if (flags & SLAB_RED_ZONE || flags & SLAB_STORE_USER)
> +	if (flags & SLAB_RED_ZONE || flags & SLAB_STORE_USER) {
> 		ralign = __alignof__(unsigned long long);
> +		size += (__alignof__(unsigned long long) - 1);
> +		size &= ~(__alignof__(unsigned long long) - 1);
> +	}
>
> 	/* 2) arch mandated alignment */
> 	if (ralign < ARCH_SLAB_MINALIGN) {
> @@ -2261,9 +2264,14 @@ kmem_cache_create (const char *name, size_t size, size_t align,
> 	}
> 	if (flags & SLAB_STORE_USER) {
> 		/* user store requires one word storage behind the end of
> -		 * the real object.
> +		 * the real object. But if the second red zone must be
> +		 * aligned 'better' than that, allow for it.
> 		 */
> -		size += BYTES_PER_WORD;
> +		if (flags & SLAB_RED_ZONE
> +		    && BYTES_PER_WORD < __alignof__(unsigned long long))
> +			size += __alignof__(unsigned long long);
> +		else
> +			size += BYTES_PER_WORD;
> 	}
> #if FORCED_DEBUG && defined(CONFIG_DEBUG_PAGEALLOC)
> 	if (size >= malloc_sizes[INDEX_L3 + 1].cs_size
>
>
> -- 
> dwmw2
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
