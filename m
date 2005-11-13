Date: Sat, 12 Nov 2005 23:47:10 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH]: Cleanup of __alloc_pages
Message-Id: <20051112234710.3d567e21.pj@sgi.com>
In-Reply-To: <20051112231211.372be3a9.akpm@osdl.org>
References: <20051107174349.A8018@unix-os.sc.intel.com>
	<20051107175358.62c484a3.akpm@osdl.org>
	<1131416195.20471.31.camel@akash.sc.intel.com>
	<43701FC6.5050104@yahoo.com.au>
	<20051107214420.6d0f6ec4.pj@sgi.com>
	<43703EFB.1010103@yahoo.com.au>
	<1131473876.2400.9.camel@akash.sc.intel.com>
	<43716476.1030306@yahoo.com.au>
	<20051112210913.0b365815.pj@sgi.com>
	<20051112211429.294b3783.pj@sgi.com>
	<20051112231211.372be3a9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: nickpiggin@yahoo.com.au, rohit.seth@intel.com, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Yes, the fact that GFP_ATOMIC also implies "use the emergency pool" is
> unfortunate, and perhaps the two should always have been separated out, at
> least to make the programmer think about whether the code really needs
> access to the emergency pools.   Usually it does.

Ah - now it makes more sense.

The key invisible fact in the gfp.h line:

  #define GFP_ATOMIC      (__GFP_VALID | __GFP_HIGH)

is that __GFP_WAIT is *not* set (making it mean don't sleep).
All the other commonly used GFP_* flags do have __GFP_WAIT.

I have no issue with ATOMIC also meaning "use emergency pool".
That's an appropriate simplication, that fits the usage well.

I just had a mental block on the invisible unset __GFP_WAIT bit.

Would you look kindly on a patch that did:


--- 2.6.14-mm2.orig/include/linux/gfp.h	2005-11-12 23:36:57.258103418 -0800
+++ 2.6.14-mm2/include/linux/gfp.h	2005-11-12 23:42:35.287219455 -0800
@@ -58,6 +58,7 @@ struct vm_area_struct;
 			__GFP_NOFAIL|__GFP_NORETRY|__GFP_NO_GROW|__GFP_COMP| \
 			__GFP_NOMEMALLOC|__GFP_HARDWALL)
 
+/* GFP_ATOMIC means both !wait (__GFP_WAIT not set) and use emergency pool */
 #define GFP_ATOMIC	(__GFP_VALID | __GFP_HIGH)
 #define GFP_NOIO	(__GFP_VALID | __GFP_WAIT)
 #define GFP_NOFS	(__GFP_VALID | __GFP_WAIT | __GFP_IO)


-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
