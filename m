Date: Fri, 15 Sep 2006 16:03:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <20060915010622.0e3539d2.akpm@osdl.org>
Message-ID: <Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060915004402.88d462ff.pj@sgi.com>
 <20060915010622.0e3539d2.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Paul Jackson <pj@sgi.com>, clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 15 Sep 2006, Andrew Morton wrote:

> Yes.  Speeding up get_page_from_freelist() is less than totally trivial. 
> I've been putting off thinking about it until we're pretty sure that there
> aren't any other showstoppers.
> 
> I'm (very) impressed at how well the infrastructre which you and Christoph
> have put together has held up under this.
> 

I used numa=fake=64 for 64 nodes of 48M each (with my numa=fake fix).  I 
created a 2G cpuset with 43 nodes (43*48M = ~2G) and attached 'usemem -m 
1500 -s 10000000 &' to it for 1.5G of anonymous memory.  I then used 
readprofile to time and profile a kernel build of 2.6.18-rc5 with x86_64 
defconfig in the remaining 21 nodes.

Kernel build within the 2G container:
	real	5m23.057s
	user	9m13.395s
	sys	1m15.417s

Unrestricted kernel build (no NUMA emulation or usemem):
	real	5m3.213s
	user	9m19.483s
	sys	0m32.014s	<-- over twice faster

In 2G container:
	10599 __cpuset_zone_allowed			50.4714
	 3521 mwait_idle				45.1410
	 1149 clear_page				20.1579
	   24 clear_page_end				 3.4286
	  215 find_get_page				 3.0282
	  110 pfn_to_page				 2.3913
	  130 __down_read_trylock			 1.9697
	   86 page_remove_rmap				 1.9545
	  150 find_vma					 1.7241
	   46 __strnlen_user				 1.1795
	   32 nr_free_pages				 1.1034
	   55 page_to_pfn				 1.0784
	   22 page_add_file_rmap			 1.0000
	  829 get_page_from_freelist			 0.8904
	 1548 do_page_fault				 0.8586
	   17 file_ra_state_init			 0.8500
	   63 _atomic_dec_and_lock			 0.7500
	   85 ia32_sysenter_target			 0.7083
	   47 cond_resched				 0.6912
	  198 copy_user_generic				 0.6644

Unrestricted:
	 3719 mwait_idle				47.6795
	 1083 clear_page				19.0000
	   20 clear_page_end				 2.8571
	  175 find_get_page				 2.4648
	   77 page_remove_rmap				 1.7500
	  114 __down_read_trylock			 1.7273
	   77 pfn_to_page				 1.6739
	  144 find_vma					 1.6552
	   60 __strnlen_user				 1.5385
	   71 page_to_pfn				 1.3922
	   24 page_add_file_rmap			 1.0909
	   17 fput					 1.0000
	   80 _atomic_dec_and_lock			 0.9524
	    4 up_write					 0.8000
	 1439 do_page_fault				 0.7981
	   13 compat_sys_open				 0.7647
	  227 copy_user_generic				 0.7617
	   89 ia32_sysenter_target			 0.7417
	   21 memcmp					 0.6562
	   13 file_ra_state_init			 0.6500
	...
	  389 get_page_from_freelist			 0.4178

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
