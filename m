Date: Tue, 19 Sep 2006 12:17:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <Pine.LNX.4.64.0609162134540.13809@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.63.0609191212390.7746@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060916044847.99802d21.pj@sgi.com>
 <20060916083825.ba88eee8.akpm@osdl.org> <20060916145117.9b44786d.pj@sgi.com>
 <20060916161031.4b7c2470.akpm@osdl.org> <Pine.LNX.4.64.0609162134540.13809@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Sat, 16 Sep 2006, Christoph Lameter wrote:

> One would not construct a memory container from 50 zones but build a 
> single zone as a memory container of that size.
> 

Now I used numa=fake=64 for 64 nodes of 48M each and created a 2G cpuset 
(43 nodes) and attached 'usemem -m 1500 -s 100000000 &' for 1.5G of 
anonymous memory.  Then I timed and profiled the kernel build in the 
remaining 1G on my 3G box (21 nodes).  This was the old case.

I made a modification in my own tree that allowed numa=fake=N to break the 
memory into N nodes that are not powers of 2 (by writing a new hash 
function for pfn_to_nid).  I booted with numa=fake=3 which gives me one 
node of 2G and another of 1G.  I then placed each in their own cpusets and 
repeated the experiment.

		64 nodes		3 nodes
	real	5m19.722s		5m2.171s
	user	9m11.790s		9m15.999s
	sys	1m9.164s		0m31.030s

64 nodes:
	3786 mwait_idle				48.5385
	8590 __cpuset_zone_allowed		40.9048
	 978 clear_page				17.1579
	  22 clear_page_end			 3.1429
	 202 find_get_page			 2.8451
	 115 pfn_to_page			 2.5000
	 355 zone_watermark_ok			 2.2756
	 131 __down_read_trylock		 1.9848
	  86 page_remove_rmap			 1.9545
	 146 find_vma				 1.6782
	...
	1129 get_page_from_freelist		 1.2127

3 nodes:
	3940 mwait_idle				50.5128
	1114 clear_page				19.5439
	  19 clear_page_end			 2.7143
	 184 find_get_page			 2.5915
	  98 page_remove_rmap			 2.2273
	 122 __down_read_trylock		 1.8485
	 140 find_vma				 1.6092
	  67 pfn_to_page			 1.4565
	  47 __strnlen_user			 1.2051
	  24 page_add_file_rmap			 1.0909
	...
	 457 get_page_from_freelist		 0.4909
	  33 lru_cache_add_active		 0.4853
	...
	  90 __cpuset_zone_allowed		 0.4286

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
