Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7EAF56B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 02:13:43 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id h15so7276698igd.5
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 23:13:43 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0047.hostedemail.com. [216.40.44.47])
        by mx.google.com with ESMTP id wl19si41655574icb.28.2014.07.02.23.13.41
        for <linux-mm@kvack.org>;
        Wed, 02 Jul 2014 23:13:42 -0700 (PDT)
Message-ID: <1404368018.14741.31.camel@joe-AO725>
Subject: Re: [mmotm:master 298/396] kernel/kexec.c:2181: undefined reference
 to `crypto_alloc_shash'
From: Joe Perches <joe@perches.com>
Date: Wed, 02 Jul 2014 23:13:38 -0700
In-Reply-To: <53b4f07a.xCByfd0BkPuAXJCu%fengguang.wu@intel.com>
References: <53b4f07a.xCByfd0BkPuAXJCu%fengguang.wu@intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Thu, 2014-07-03 at 13:56 +0800, kbuild test robot wrote:
> Hi Joe,

Hi Fengguang.

> It's probably a bug fix that unveils the link errors.

I don't understand how the typedef removal matters here.
Is this some sort of bisect false positive?

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   82b56f797fa200a5e9feac3a93cb6496909b9670
> commit: f192fb3c695b607044d4476c822783a8ae10ce75 [298/396] sysctl-remove-now-unused-typedef-ctl_table-fix
> config: make ARCH=arm prima2_defconfig
> 
> All error/warnings:
> 
>    kernel/built-in.o: In function `kexec_calculate_store_digests':
> >> kernel/kexec.c:2181: undefined reference to `crypto_alloc_shash'
> >> kernel/kexec.c:2223: undefined reference to `crypto_shash_update'
> >> kernel/kexec.c:2238: undefined reference to `crypto_shash_update'
> >> kernel/kexec.c:2253: undefined reference to `crypto_shash_final'
> 
> vim +2181 kernel/kexec.c
> 
> 025d7537 Vivek Goyal 2014-07-02  2175  	struct kexec_sha_region *sha_regions;
> 025d7537 Vivek Goyal 2014-07-02  2176  	struct purgatory_info *pi = &image->purgatory_info;
> 025d7537 Vivek Goyal 2014-07-02  2177  
> 025d7537 Vivek Goyal 2014-07-02  2178  	zero_buf = __va(page_to_pfn(ZERO_PAGE(0)) << PAGE_SHIFT);
> 025d7537 Vivek Goyal 2014-07-02  2179  	zero_buf_sz = PAGE_SIZE;
> 025d7537 Vivek Goyal 2014-07-02  2180  
> 025d7537 Vivek Goyal 2014-07-02 @2181  	tfm = crypto_alloc_shash("sha256", 0, 0);
> 025d7537 Vivek Goyal 2014-07-02  2182  	if (IS_ERR(tfm)) {
> 025d7537 Vivek Goyal 2014-07-02  2183  		ret = PTR_ERR(tfm);
> 025d7537 Vivek Goyal 2014-07-02  2184  		goto out;
> 025d7537 Vivek Goyal 2014-07-02  2185  	}
> 025d7537 Vivek Goyal 2014-07-02  2186  
> 025d7537 Vivek Goyal 2014-07-02  2187  	desc_size = crypto_shash_descsize(tfm) + sizeof(*desc);
> 025d7537 Vivek Goyal 2014-07-02  2188  	desc = kzalloc(desc_size, GFP_KERNEL);
> 025d7537 Vivek Goyal 2014-07-02  2189  	if (!desc) {
> 025d7537 Vivek Goyal 2014-07-02  2190  		ret = -ENOMEM;
> 025d7537 Vivek Goyal 2014-07-02  2191  		goto out_free_tfm;
> 025d7537 Vivek Goyal 2014-07-02  2192  	}
> 025d7537 Vivek Goyal 2014-07-02  2193  
> 025d7537 Vivek Goyal 2014-07-02  2194  	sha_region_sz = KEXEC_SEGMENT_MAX * sizeof(struct kexec_sha_region);
> 025d7537 Vivek Goyal 2014-07-02  2195  	sha_regions = vzalloc(sha_region_sz);
> 025d7537 Vivek Goyal 2014-07-02  2196  	if (!sha_regions)
> 025d7537 Vivek Goyal 2014-07-02  2197  		goto out_free_desc;
> 025d7537 Vivek Goyal 2014-07-02  2198  
> 025d7537 Vivek Goyal 2014-07-02  2199  	desc->tfm   = tfm;
> 025d7537 Vivek Goyal 2014-07-02  2200  	desc->flags = 0;
> 025d7537 Vivek Goyal 2014-07-02  2201  
> 025d7537 Vivek Goyal 2014-07-02  2202  	ret = crypto_shash_init(desc);
> 025d7537 Vivek Goyal 2014-07-02  2203  	if (ret < 0)
> 025d7537 Vivek Goyal 2014-07-02  2204  		goto out_free_sha_regions;
> 025d7537 Vivek Goyal 2014-07-02  2205  
> 025d7537 Vivek Goyal 2014-07-02  2206  	digest = kzalloc(SHA256_DIGEST_SIZE, GFP_KERNEL);
> 025d7537 Vivek Goyal 2014-07-02  2207  	if (!digest) {
> 025d7537 Vivek Goyal 2014-07-02  2208  		ret = -ENOMEM;
> 025d7537 Vivek Goyal 2014-07-02  2209  		goto out_free_sha_regions;
> 025d7537 Vivek Goyal 2014-07-02  2210  	}
> 025d7537 Vivek Goyal 2014-07-02  2211  
> 025d7537 Vivek Goyal 2014-07-02  2212  	for (j = i = 0; i < image->nr_segments; i++) {
> 025d7537 Vivek Goyal 2014-07-02  2213  		struct kexec_segment *ksegment;
> 025d7537 Vivek Goyal 2014-07-02  2214  
> 025d7537 Vivek Goyal 2014-07-02  2215  		ksegment = &image->segment[i];
> 025d7537 Vivek Goyal 2014-07-02  2216  		/*
> 025d7537 Vivek Goyal 2014-07-02  2217  		 * Skip purgatory as it will be modified once we put digest
> 025d7537 Vivek Goyal 2014-07-02  2218  		 * info in purgatory.
> 025d7537 Vivek Goyal 2014-07-02  2219  		 */
> 025d7537 Vivek Goyal 2014-07-02  2220  		if (ksegment->kbuf == pi->purgatory_buf)
> 025d7537 Vivek Goyal 2014-07-02  2221  			continue;
> 025d7537 Vivek Goyal 2014-07-02  2222  
> 025d7537 Vivek Goyal 2014-07-02 @2223  		ret = crypto_shash_update(desc, ksegment->kbuf,
> 025d7537 Vivek Goyal 2014-07-02  2224  					  ksegment->bufsz);
> 025d7537 Vivek Goyal 2014-07-02  2225  		if (ret)
> 025d7537 Vivek Goyal 2014-07-02  2226  			break;
> 025d7537 Vivek Goyal 2014-07-02  2227  
> 025d7537 Vivek Goyal 2014-07-02  2228  		/*
> 025d7537 Vivek Goyal 2014-07-02  2229  		 * Assume rest of the buffer is filled with zero and
> 025d7537 Vivek Goyal 2014-07-02  2230  		 * update digest accordingly.
> 025d7537 Vivek Goyal 2014-07-02  2231  		 */
> 025d7537 Vivek Goyal 2014-07-02  2232  		nullsz = ksegment->memsz - ksegment->bufsz;
> 025d7537 Vivek Goyal 2014-07-02  2233  		while (nullsz) {
> 025d7537 Vivek Goyal 2014-07-02  2234  			unsigned long bytes = nullsz;
> 025d7537 Vivek Goyal 2014-07-02  2235  
> 025d7537 Vivek Goyal 2014-07-02  2236  			if (bytes > zero_buf_sz)
> 025d7537 Vivek Goyal 2014-07-02  2237  				bytes = zero_buf_sz;
> 025d7537 Vivek Goyal 2014-07-02 @2238  			ret = crypto_shash_update(desc, zero_buf, bytes);
> 025d7537 Vivek Goyal 2014-07-02  2239  			if (ret)
> 025d7537 Vivek Goyal 2014-07-02  2240  				break;
> 025d7537 Vivek Goyal 2014-07-02  2241  			nullsz -= bytes;
> 025d7537 Vivek Goyal 2014-07-02  2242  		}
> 025d7537 Vivek Goyal 2014-07-02  2243  
> 025d7537 Vivek Goyal 2014-07-02  2244  		if (ret)
> 025d7537 Vivek Goyal 2014-07-02  2245  			break;
> 025d7537 Vivek Goyal 2014-07-02  2246  
> 025d7537 Vivek Goyal 2014-07-02  2247  		sha_regions[j].start = ksegment->mem;
> 025d7537 Vivek Goyal 2014-07-02  2248  		sha_regions[j].len = ksegment->memsz;
> 025d7537 Vivek Goyal 2014-07-02  2249  		j++;
> 025d7537 Vivek Goyal 2014-07-02  2250  	}
> 025d7537 Vivek Goyal 2014-07-02  2251  
> 025d7537 Vivek Goyal 2014-07-02  2252  	if (!ret) {
> 025d7537 Vivek Goyal 2014-07-02 @2253  		ret = crypto_shash_final(desc, digest);
> 025d7537 Vivek Goyal 2014-07-02  2254  		if (ret)
> 025d7537 Vivek Goyal 2014-07-02  2255  			goto out_free_digest;
> 025d7537 Vivek Goyal 2014-07-02  2256  		ret = kexec_purgatory_get_set_symbol(image, "sha_regions",
> 
> :::::: The code at line 2181 was first introduced by commit
> :::::: 025d75374c9c08274f60da5802381a8ef7490388 kexec: load and relocate purgatory at kernel load time
> 
> :::::: TO: Vivek Goyal <vgoyal@redhat.com>
> :::::: CC: Johannes Weiner <hannes@cmpxchg.org>
> 
> ---
> 0-DAY kernel build testing backend              Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
