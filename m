Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id DAA20683
	for <linux-mm@kvack.org>; Fri, 20 Dec 2002 03:11:14 -0800 (PST)
Message-ID: <3E02FACD.5B300794@digeo.com>
Date: Fri, 20 Dec 2002 03:11:09 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: shared pagetable benchmarking
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Did a bit of timing and profiling.  It's a uniprocessor
kernel, 7G, PAE.

The workload is application and removal of ~80 patches using
my patch scripts.  Tons and tons of forks from bash.

2.5 ends up being 13% slower than 2.4, after disabling highpte
to make it fair.  3%-odd of this is HZ=1000.  So say 10%.

Pagetable sharing actually slowed this test down by several
percent overall.  Which is unfortunate, because the main
thing which Linus likes about shared pagetables is that it
"speeds up forks".

Is there anything we can do to fix all of this up a bit?



2.4.21-pre2:

c0106d60 system_call                                  10   0.1786
c012ca00 __free_pages_ok                              10   0.0124
c0114c38 mm_init                                      13   0.0396
c0124a84 find_vma                                     13   0.1548
c01283ac generic_file_write                           13   0.0073
c012cd24 rmqueue                                      14   0.0201
c0122570 __free_pte                                   16   0.1667
c0123df0 handle_mm_fault                              16   0.0625
c0123aac do_anonymous_page                            25   0.0801
c0126c3c file_read_actor                              33   0.1684
c0123be4 do_no_page                                   37   0.0706
c01226d0 copy_page_range                              47   0.0810
c0112878 do_page_fault                                49   0.0352
c01225e8 clear_page_tables                            70   0.3017
c0122914 zap_page_range                               72   0.1118
c01234b0 do_wp_page                                  275   0.3736
00000000 total                                      1062   0.0008
created /tmp/prof.time
akpm-prof pushpatch 99  11.83s user 10.56s system 99% cpu 22.439 total

c01283ac generic_file_write                            9   0.0050
c012d8b4 free_page_and_swap_cache                      9   0.1500
c012625c __find_get_page                              10   0.2083
c0118cdc exit_notify                                  11   0.0174
c012ca00 __free_pages_ok                              11   0.0137
c013c030 link_path_walk                               16   0.0077
c012cd24 rmqueue                                      18   0.0259
c0123aac do_anonymous_page                            20   0.0641
c0126c3c file_read_actor                              25   0.1276
c01226d0 copy_page_range                              27   0.0466
c0123be4 do_no_page                                   29   0.0553
c01225e8 clear_page_tables                            32   0.1379
c01052b0 poll_idle                                    33   0.8250
c0122914 zap_page_range                               42   0.0652
c0112878 do_page_fault                                50   0.0359
c01234b0 do_wp_page                                  161   0.2188
00000000 total                                       791   0.0006
created /tmp/prof.time
akpm-prof poppatch 99  8.60s user 7.57s system 97% cpu 16.530 total



2.5.52-mm3:

c012b998 free_hot_cold_page                           94   0.4896
c0117348 do_schedule                                 103   0.1717
c012ba7c buffered_rmqueue                            110   0.5729
c01c1b4c strnlen_user                                116   1.3810
c012e36c kmem_cache_alloc                            120   1.8750
c0134454 find_vma                                    133   1.5114
c010a558 system_call                                 134   3.0455
c01504ac d_lookup                                    143   0.6164
c0148af4 link_path_walk                              153   0.0915
c0116b88 kmap_atomic_to_page                         175   1.9886
c0133060 handle_mm_fault                             195   0.6414
c01c1d48 __copy_from_user                            212   1.8929
c011598c pte_alloc_one                               213   1.6641
c0132c74 do_anonymous_page                           260   0.6311
c011cab0 do_softirq                                  300   1.7045
c01c1ce0 __copy_to_user                              369   3.5481
c0132e10 do_no_page                                  529   0.8936
c013c9e4 pte_unshare                                 572   0.5789
c0116b04 kmap_atomic                                 585   5.2232
c0131b44 zap_pte_range                               585   1.4199
c0115bc0 do_page_fault                               600   0.4808
c0136428 page_add_rmap                               766   2.1517
c0131890 clear_page_tables                           860   2.6220
c013658c page_remove_rmap                            928   1.9333
c013250c do_wp_page                                 2594   3.3601
00000000 total                                     15261   0.0097
created /tmp/prof.time
akpm-prof pushpatch 99  12.36s user 14.61s system 97% cpu 27.768 total


c0117348 do_schedule                                  77   0.1283
c010a558 system_call                                  85   1.9318
c0134454 find_vma                                     90   1.0227
c01504ac d_lookup                                    106   0.4569
c0116b88 kmap_atomic_to_page                         107   1.2159
c0133060 handle_mm_fault                             113   0.3717
c011598c pte_alloc_one                               135   1.0547
c0148af4 link_path_walk                              135   0.0807
c01c1d48 __copy_from_user                            162   1.4464
c0132c74 do_anonymous_page                           218   0.5291
c01c1ce0 __copy_to_user                              297   2.8558
c011cab0 do_softirq                                  319   1.8125
c0132e10 do_no_page                                  325   0.5490
c0131b44 zap_pte_range                               362   0.8786
c013c9e4 pte_unshare                                 375   0.3796
c0116b04 kmap_atomic                                 384   3.4286
c0115bc0 do_page_fault                               447   0.3582
c0136428 page_add_rmap                               505   1.4185
c0131890 clear_page_tables                           563   1.7165
c013658c page_remove_rmap                            585   1.2188
c013250c do_wp_page                                 1559   2.0194
00000000 total                                     10586   0.0067
created /tmp/prof.time
akpm-prof poppatch 99  9.00s user 10.31s system 96% cpu 19.926 total

OK, remove shpte:
=================

c0134344 find_vma                                    110   1.2500
c01c07fc strnlen_user                                112   1.3333
c0118c94 copy_process                                113   0.0456
c012b77c buffered_rmqueue                            120   0.6250
c014f0a0 __d_lookup                                  133   0.6520
c010a558 system_call                                 145   3.2955
c01474e0 link_path_walk                              162   0.0769
c0116b28 kmap_atomic_to_page                         165   1.8750
c0132f00 handle_mm_fault                             166   0.5461
c012e02c kmem_cache_alloc                            185   2.8906
c012e0d8 kmem_cache_free                             188   2.9375
c0115a0c pgd_alloc                                   193   0.9650
c01c09f8 __copy_from_user                            196   1.7500
c011598c pte_alloc_one                               216   1.6875
c0132b24 do_anonymous_page                           249   0.6163
c011c880 do_softirq                                  293   1.6648
c01c0990 __copy_to_user                              418   4.0192
c0132cb8 do_no_page                                  446   0.7637
c01317b4 copy_page_range                             496   0.7425
c0116aa4 kmap_atomic                                 591   5.2768
c0115b60 do_page_fault                               594   0.4760
c0131a50 zap_pte_range                               609   1.2378
c0136314 page_add_rmap                               632   1.7556
c01314f0 clear_page_tables                           688   2.2051
c013647c page_remove_rmap                            817   1.7021
c01323d4 do_wp_page                                 2600   3.4759
00000000 total                                     14713   0.0094
created /tmp/prof.time
akpm-prof pushpatch 99  12.29s user 14.40s system 99% cpu 26.913 total

c014f0a0 __d_lookup                                   91   0.4461
c010a558 system_call                                  93   2.1136
c0132f00 handle_mm_fault                             111   0.3651
c012e02c kmem_cache_alloc                            113   1.7656
c01474e0 link_path_walk                              118   0.0560
c011598c pte_alloc_one                               129   1.0078
c0116b28 kmap_atomic_to_page                         129   1.4659
c012e0d8 kmem_cache_free                             140   2.1875
c01c09f8 __copy_from_user                            160   1.4286
c0115a0c pgd_alloc                                   170   0.8500
c0132b24 do_anonymous_page                           184   0.4554
c011c880 do_softirq                                  297   1.6875
c01317b4 copy_page_range                             309   0.4626
c01c0990 __copy_to_user                              318   3.0577
c0132cb8 do_no_page                                  335   0.5736
c0131a50 zap_pte_range                               364   0.7398
c01314f0 clear_page_tables                           393   1.2596
c0115b60 do_page_fault                               441   0.3534
c0136314 page_add_rmap                               441   1.2250
c0116aa4 kmap_atomic                                 448   4.0000
c013647c page_remove_rmap                            550   1.1458
c01323d4 do_wp_page                                 1593   2.1297
00000000 total                                     10335   0.0066
created /tmp/prof.time
akpm-prof poppatch 99  9.07s user 10.03s system 99% cpu 19.290 total

Also remove highpte
===================

c01c037c strnlen_user                                108   1.2857
c010a558 system_call                                 111   2.5227
c012b79c buffered_rmqueue                            113   0.5885
c0134144 find_vma                                    117   1.3295
c01171e4 do_schedule                                 118   0.1954
c0132d20 handle_mm_fault                             132   0.4583
c014ebf0 __d_lookup                                  142   0.6961
c0131010 page_address                                147   1.0500
c0116ae4 kmap_atomic                                 163   1.4554
c0147030 link_path_walk                              186   0.0882
c01c0578 __copy_from_user                            203   1.8125
c011597c pte_alloc_one                               224   1.5556
c0115a0c pgd_alloc                                   231   1.1550
c0132990 do_anonymous_page                           260   0.7065
c011c8d0 do_softirq                                  283   1.6080
c01c0510 __copy_to_user                              380   3.6538
c0132b00 do_no_page                                  401   0.7371
c01316fc copy_page_range                             451   0.7723
c0131944 zap_pte_range                               588   1.1575
c013602c page_add_rmap                               601   2.5042
c0115b60 do_page_fault                               607   0.4716
c0131440 clear_page_tables                           637   2.1233
c013611c page_remove_rmap                            657   2.0030
c01322b4 do_wp_page                                 2530   3.6988
00000000 total                                     13554   0.0087
created /tmp/prof.time
akpm-prof pushpatch 99  11.97s user 13.36s system 99% cpu 25.541 total

c0132d20 handle_mm_fault                             100   0.3472
c0147030 link_path_walk                              106   0.0503
c0116ae4 kmap_atomic                                 109   0.9732
c0115a0c pgd_alloc                                   140   0.7000
c011597c pte_alloc_one                               151   1.0486
c01c0578 __copy_from_user                            162   1.4464
c0132990 do_anonymous_page                           204   0.5543
c011c8d0 do_softirq                                  305   1.7330
c01c0510 __copy_to_user                              308   2.9615
c0132b00 do_no_page                                  310   0.5699
c01316fc copy_page_range                             314   0.5377
c013602c page_add_rmap                               361   1.5042
c0131944 zap_pte_range                               379   0.7461
c0115b60 do_page_fault                               409   0.3178
c013611c page_remove_rmap                            430   1.3110
c0131440 clear_page_tables                           443   1.4767
c01322b4 do_wp_page                                 1662   2.4298
00000000 total                                      9706   0.0062
created /tmp/prof.time
akpm-prof poppatch 99  8.86s user 9.33s system 98% cpu 18.433 total
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
