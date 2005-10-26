Date: Tue, 25 Oct 2005 21:52:29 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bug 5493] New: mprotect usage causing slow system performance
 and freezing
Message-Id: <20051025215229.3e8e3f57.akpm@osdl.org>
In-Reply-To: <200510251108.j9PB8EZJ025221@fire-1.osdl.org>
References: <200510251108.j9PB8EZJ025221@fire-1.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@kernel-bugs.osdl.org>
List-ID: <linux-mm.kvack.org>

 http://bugzilla.kernel.org/show_bug.cgi?id=5493

This real-world application is failing due to the new rmap code.  There are
a large number of vmas and the linear searches in rmap.c are completely
killing us.

Profile:

c01608f0 __link_path_walk                              1   0.0003
c016ace8 __d_lookup                                    1   0.0036
c0191b70 gcc2_compiled.                                1   0.0071
c023a368 _raw_spin_unlock                              1   0.0078
c02fe410 ide_inb                                       1   0.0625
c0117580 write_profile                                 2   0.0377
c013da20 kmem_flagcheck                                2   0.0385
c013e4c8 kmem_cache_alloc                              2   0.0143
c01406d4 shrink_list                                   2   0.0020
c0143a10 zap_pte_range                                 2   0.0032
c014ba50 get_swap_page                                 2   0.0032
c0236634 radix_tree_preload                            2   0.0179
c02da3e0 generic_make_request                          2   0.0044
c02fe468 ide_outb                                      2   0.1250
c041f47c _write_unlock_irqrestore                      2   0.0833
c01395c0 __alloc_pages                                 3   0.0031
c0139ccc __mod_page_state                              3   0.1250
c013e150 cache_alloc_debugcheck_after                  3   0.0112
c0144910 do_wp_page                                    3   0.0037
c0149ec0 page_referenced                               3   0.0197
c014bcbc swap_info_get                                 3   0.0197
c015807c bio_alloc                                     3   0.0750
c041f494 _write_unlock_irq                             4   0.2000
c013cac4 check_poison_obj                              5   0.0137
c0142bd0 page_address                                  9   0.0625
c041f890 do_page_fault                                 9   0.0054
c0149bbc page_check_address                           11   0.0573
c041f40c _spin_unlock_irq                             18   0.9000
c0139380 buffered_rmqueue                             32   0.0748
c014a024 try_to_unmap_one                            782   1.7455
c014a400 try_to_unmap_anon                          1511  11.1103
c0149c7c page_referenced_one                        4169  17.0861
c0149d70 page_referenced_anon                       8498  62.4853
00000000 total                                     15109   0.0046

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
