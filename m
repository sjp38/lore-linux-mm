Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED396B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 04:12:20 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id u65so4840139wrc.6
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 01:12:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m139si1734770wma.32.2017.02.08.01.12.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 01:12:19 -0800 (PST)
Subject: Re: [PATCH] mm, slab: rename kmalloc-node cache to kmalloc-<size>
References: <20170203181008.24898-1-vbabka@suse.cz>
 <201702080139.e2GzXRQt%fengguang.wu@intel.com>
 <20170207133839.f6b1f1befe4468770991f5e0@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d3a1f708-efdd-98c3-9c26-dab600501679@suse.cz>
Date: Wed, 8 Feb 2017 10:12:13 +0100
MIME-Version: 1.0
In-Reply-To: <20170207133839.f6b1f1befe4468770991f5e0@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>

On 02/07/2017 10:38 PM, Andrew Morton wrote:
> On Wed, 8 Feb 2017 01:15:17 +0800 kbuild test robot <lkp@intel.com> wrote:
> 
>> Hi Vlastimil,
>> 
>> [auto build test WARNING on mmotm/master]
>> [also build test WARNING on v4.10-rc7 next-20170207]
>> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>> 
>> url:    https://github.com/0day-ci/linux/commits/Vlastimil-Babka/mm-slab-rename-kmalloc-node-cache-to-kmalloc-size/20170204-021843
>> base:   git://git.cmpxchg.org/linux-mmotm.git master
>> config: arm-allyesconfig (attached as .config)
>> compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
>> reproduce:
>>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>>         chmod +x ~/bin/make.cross
>>         # save the attached .config to linux build tree
>>         make.cross ARCH=arm 
>> 
>> All warnings (new ones prefixed by >>):
>> 
>> >> WARNING: mm/built-in.o(.text+0x3b49c): Section mismatch in reference from the function get_kmalloc_cache_name() to the (unknown reference) .init.rodata:(unknown)
>>    The function get_kmalloc_cache_name() references
>>    the (unknown reference) __initconst (unknown).
>>    This is often because get_kmalloc_cache_name lacks a __initconst
>>    annotation or the annotation of (unknown) is wrong.
> 
> yup, thanks.

Thanks for the fix.

I was going to implement Christoph's suggestion and export the whole structure
in mm/slab.h, but gcc was complaining that I'm redefining it, until I created a
typedef first. Is it worth the trouble? Below is how it would look like.

Vlastimil

----8<----
diff --git a/mm/slab.c b/mm/slab.c
index ede31b59bb9f..9d66b3d6791e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1294,7 +1294,7 @@ void __init kmem_cache_init(void)
 	 * structures first.  Without this, further allocations will bug.
 	 */
 	kmalloc_caches[INDEX_NODE] = create_kmalloc_cache(
-				get_kmalloc_cache_name(INDEX_NODE),
+				kmalloc_info[INDEX_NODE].name,
 				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS);
 	slab_state = PARTIAL_NODE;
 	setup_kmalloc_cache_index_table();
diff --git a/mm/slab.h b/mm/slab.h
index 5708c548c6f7..e6b4cf74be86 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -71,6 +71,13 @@ extern struct list_head slab_caches;
 /* The slab cache that manages slab cache information */
 extern struct kmem_cache *kmem_cache;
 
+/* A table of kmalloc cache names and sizes */
+typedef struct {
+	const char *name;
+	unsigned long size;
+} kmalloc_info_t;
+extern const kmalloc_info_t kmalloc_info[];
+
 unsigned long calculate_alignment(unsigned long flags,
 		unsigned long align, unsigned long size);
 
@@ -78,7 +85,6 @@ unsigned long calculate_alignment(unsigned long flags,
 /* Kmalloc array related functions */
 void setup_kmalloc_cache_index_table(void);
 void create_kmalloc_caches(unsigned long);
-const char *get_kmalloc_cache_name(int index);
 
 /* Find the kmalloc slab corresponding for a certain size */
 struct kmem_cache *kmalloc_slab(size_t, gfp_t);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 36a8547de699..ab3872ed623e 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -917,10 +917,7 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
  * kmalloc_index() supports up to 2^26=64MB, so the final entry of the table is
  * kmalloc-67108864.
  */
-static struct {
-	const char *name;
-	unsigned long size;
-} const kmalloc_info[] __initconst = {
+const kmalloc_info_t kmalloc_info[] __initconst = {
 	{NULL,                      0},		{"kmalloc-96",             96},
 	{"kmalloc-192",           192},		{"kmalloc-8",               8},
 	{"kmalloc-16",             16},		{"kmalloc-32",             32},
@@ -937,11 +934,6 @@ static struct {
 	{"kmalloc-67108864", 67108864}
 };
 
-const char *get_kmalloc_cache_name(int index)
-{
-	return kmalloc_info[index].name;
-}
-
 /*
  * Patch up the size_index table if we have strange large alignment
  * requirements for the kmalloc array. This is only the case for

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
