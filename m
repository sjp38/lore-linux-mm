Date: Wed, 10 Jul 2002 15:43:20 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <91460000.1026341000@flay>
In-Reply-To: <3D2BC6DB.B60E010D@zip.com.au>
References: <3D2A55D0.35C5F523@zip.com.au> <1214790647.1026163711@[10.10.2.3]> <3D2A7466.AD867DA7@zip.com.au> <20020709173246.GG8878@dualathlon.random> <3D2BC6DB.B60E010D@zip.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Here's the diff.  The kmap() and kmap_atomic() rate is way down
> now.  Still no benefit from it all through.  Martin.  Help.

Hmmm ... well I have some preliminary results on the 16-way NUMA
for kernel compile, and it doesn't make things faster - if anything there's
a barely perceptible slowdown (may just be statistical error). 

On the other hand, Hanna just did some dbench measurements on an
8-way SMP, and got about 15% improvement out of it (she mailed the
results to lkml just now). 

The profile comparison between 2.4 and 2.5 is interesting. Unless I've
screwed something up in the profiling, seems like we're spending a lot
of time in do_page_fault (with or without your patch). It's *so* different,
that I'm inclined to suspect my profiling .... (profile=2).

2.5:

 46361 total                                      0.3985
 36500 default_idle                             570.3125
  5556 do_page_fault                              4.5653
  1087 do_softirq                                 5.2260
   673 pte_alloc_one                              3.8239
   529 schedule                                   0.5700
   304 exit_notify                                0.3800
   192 __wake_up                                  1.7143
   188 do_fork                                    0.0904
   180 system_call                                4.0909
   174 pgd_alloc                                  2.7188
   109 timer_bh                                   0.1548

2.4 + patches

 22256 total                                      0.0237
 13510 default_idle                             259.8077
  2042 _text_lock_swap                           37.8148
   585 lru_cache_add                              6.3587
   551 do_anonymous_page                          1.6596
   488 do_generic_file_read                       0.4388
   401 lru_cache_del                             18.2273
   385 _text_lock_namei                           0.3688
   363 __free_pages_ok                            0.6927
   267 __generic_copy_from_user                   2.5673
   222 __d_lookup                                 0.8672
   211 zap_page_range                             0.2409
   188 _text_lock_dec_and_lock                    7.8333
   179 rmqueue                                    0.4144
   178 __find_get_page                            2.7812
   161 _text_lock_read_write                      1.3644
   157 file_read_actor                            0.6886
   151 nr_free_pages                              2.9038
   123 link_path_walk                             0.0478
   118 set_page_dirty                             1.2292
   101 fput                                       0.4353

Interestingly, kmap doesn't show up in the virgin 2.5 profile at all,
but it does in the 2.4 profile ... 

   7 flush_all_zero_pkmaps                      0.0700
109 kmap_high                                  0.3028



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
