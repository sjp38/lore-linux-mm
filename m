Date: Sun, 17 Sep 2006 13:36:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <20060917060358.ac16babf.pj@sgi.com>
Message-ID: <Pine.LNX.4.63.0609171329540.25459@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060915004402.88d462ff.pj@sgi.com>
 <20060915010622.0e3539d2.akpm@osdl.org> <Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
 <Pine.LNX.4.63.0609161734220.16748@chino.corp.google.com>
 <20060917041707.28171868.pj@sgi.com> <Pine.LNX.4.64.0609170540020.14516@schroedinger.engr.sgi.com>
 <20060917060358.ac16babf.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Sun, 17 Sep 2006, Paul Jackson wrote:

> You're two steps ahead of me.  Yes, it's zone_to_nid() in the
> current tree.
> 
> So ... any idea why your patch made only 0.000042%
> difference in the cost per call of __cpuset_zone_allowed()?
> 
> That is bizarrely close to zero.
> 

The reason why is because I'm an idiot.  I, too, was looking at an old 
tree where z->zone_pgdat->node_id still existed in __cpuset_zone_allowed.  
I changed it, and another reference in cpuset_zonelist_valid_mems_allowed 
to z->node.

		unpatched	patched
	real	5m23.057s	5m9.831s
	user	9m13.395s	9m14.855s
	sys	1m15.417s	0m55.007s

Unpatched:
	10599 __cpuset_zone_allowed                     50.4714
	 3521 mwait_idle                                45.1410
	 1149 clear_page                                20.1579
	   24 clear_page_end                             3.4286
	  215 find_get_page                              3.0282
	  110 pfn_to_page                                2.3913
	  130 __down_read_trylock                        1.9697
	   86 page_remove_rmap                           1.9545
	  150 find_vma                                   1.7241
	   46 __strnlen_user                             1.1795
	   32 nr_free_pages                              1.1034
	   55 page_to_pfn                                1.0784
	   22 page_add_file_rmap                         1.0000
	  829 get_page_from_freelist                     0.8904

So __cpuset_zone_allowed is 10599/50.4714 = 210.000118879.

Patched:
	5822 __cpuset_zone_allowed			29.1100
	1680 mwait_idle					21.5385
	1046 clear_page					18.3509
	 215 find_get_page				 3.0282
	  15 clear_page_end				 2.1429
	  86 page_remove_rmap				 1.9545
	  81 pfn_to_page				 1.7609
	 116 __down_read_trylock			 1.7576
	 132 find_vma					 1.5172
	  20 fput					 1.1765
	  43 __strnlen_user				 1.1026
	  53 page_to_pfn				 1.0392
	  22 page_add_file_rmap				 1.0000
	 804 get_page_from_freelist			 0.8636

So __cpuset_zone_allowed is 5822/29.1100 = 200.000000000 which is 4.8% 
faster.

Note: both versions also include my numa=fake fixes that are not yet in 
mm (which are necessary for me to even boot my machine with numa=fake=64).

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
