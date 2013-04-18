Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 106D46B00D0
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 20:27:26 -0400 (EDT)
Received: by mail-ye0-f174.google.com with SMTP id l2so359870yen.33
        for <linux-mm@kvack.org>; Wed, 17 Apr 2013 17:27:26 -0700 (PDT)
Message-ID: <516F3DE8.1040909@gmail.com>
Date: Thu, 18 Apr 2013 08:27:20 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch 0/2] mm: Add parameters to make kernel behavior at
 memory error on dirty cache selectable
References: <51662D5B.3050001@hitachi.com> <1365664306-rvrpdnsl-mutt-n-horiguchi@ah.jp.nec.com> <516E4BDC.9080903@gmail.com> <1366210525-yv9sg53o-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1366210525-yv9sg53o-mutt-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mitsuhiro Tanino <mitsuhiro.tanino.gm@hitachi.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Hi Naoya,
On 04/17/2013 10:55 PM, Naoya Horiguchi wrote:
> On Wed, Apr 17, 2013 at 03:14:36PM +0800, Simon Jeons wrote:
>> Hi Naoya,
>> On 04/11/2013 03:11 PM, Naoya Horiguchi wrote:
>>> Hi Tanino-san,
>>>
>>> On Thu, Apr 11, 2013 at 12:26:19PM +0900, Mitsuhiro Tanino wrote:
>>> ...
>>>> Solution
>>>> ---------
>>>> The patch proposes a new sysctl interface, vm.memory_failure_dirty_panic,
>>>> in order to prevent data corruption comes from data lost problem.
>>>> Also this patch displays information of affected file such as device name,
>>>> inode number, file offset and file type if the file is mapped on a memory
>>>> and the page is dirty cache.
>>>>
>>>> When SRAO machine check occurs on a dirty page cache, corresponding
>>>> data cannot be recovered any more. Therefore, the patch proposes a kernel
>>>> option to keep a system running or force system panic in order
>>>> to avoid further trouble such as data corruption problem of application.
>>>>
>>>> System administrator can select an error action using this option
>>>> according to characteristics of target system.
>>> Can we do this in userspace?
>>> mcelog can trigger scripts when a MCE which matches the user-configurable
>>> conditions happens, so I think that we can trigger a kernel panic by
>>> chekcing kernel messages from the triggered script.
>>> For that purpose, I recently fixed the dirty/clean messaging in commit
>>> ff604cf6d4 "mm: hwpoison: fix action_result() to print out dirty/clean".
>> In your commit ff604cf6d4, you mentioned that "because when we check
>> PageDirty in action_result() it was cleared after page isolation even if
>> it's dirty before error handling." Could you point out where page
>> isolation and clear PageDirty? I don't think is isolate_lru_pages.
> Here is the result of ftracing of memory_failure().
> cancel_dirty_page() is called inside me_pagecache_dirty(), that's it.

Cool! What's the option you used in this ftrace.

>
>        mceinj.sh-7662  [000] 154195.857024: funcgraph_entry:                   |            memory_failure() {
>        mceinj.sh-7662  [000] 154195.857024: funcgraph_entry:        0.283 us   |              PageHuge();
>        mceinj.sh-7662  [000] 154195.857025: funcgraph_entry:        0.321 us   |              _cond_resched();
>        mceinj.sh-7662  [000] 154195.857025: funcgraph_entry:        0.348 us   |              hwpoison_filter();
>        mceinj.sh-7662  [000] 154195.857026: funcgraph_entry:        0.323 us   |              PageHuge();
>        mceinj.sh-7662  [000] 154195.857027: funcgraph_entry:        0.264 us   |              PageHuge();
>        mceinj.sh-7662  [000] 154195.857027: funcgraph_entry:                   |              kmem_cache_alloc_trace() {
>        mceinj.sh-7662  [000] 154195.857028: funcgraph_entry:        0.254 us   |                _cond_resched();
>        mceinj.sh-7662  [000] 154195.857028: funcgraph_exit:         0.905 us   |              }
>        mceinj.sh-7662  [000] 154195.857029: funcgraph_entry:        0.308 us   |              _read_lock();
>        mceinj.sh-7662  [000] 154195.857029: funcgraph_entry:        0.326 us   |              _spin_lock();
>        mceinj.sh-7662  [000] 154195.857057: funcgraph_entry:                   |              kfree() {
>        mceinj.sh-7662  [000] 154195.857057: funcgraph_entry:        0.252 us   |                __phys_addr();
>        mceinj.sh-7662  [000] 154195.857058: funcgraph_exit:         1.000 us   |              }
>        mceinj.sh-7662  [000] 154195.857058: funcgraph_entry:                   |              try_to_unmap() {
>        mceinj.sh-7662  [000] 154195.857058: funcgraph_entry:                   |                try_to_unmap_file() {
>        mceinj.sh-7662  [000] 154195.857059: funcgraph_entry:        0.430 us   |                  _spin_lock();
>        mceinj.sh-7662  [000] 154195.857060: funcgraph_entry:        0.719 us   |                  vma_prio_tree_next();
>        mceinj.sh-7662  [000] 154195.857061: funcgraph_entry:                   |                  try_to_unmap_one() {
>        mceinj.sh-7662  [000] 154195.857061: funcgraph_entry:                   |                    page_check_address() {
>        mceinj.sh-7662  [000] 154195.857061: funcgraph_entry:        0.256 us   |                      PageHuge();
>        mceinj.sh-7662  [000] 154195.857062: funcgraph_entry:        0.419 us   |                      _spin_lock();
>        mceinj.sh-7662  [000] 154195.857063: funcgraph_exit:         1.812 us   |                    }
>        mceinj.sh-7662  [000] 154195.857063: funcgraph_entry:                   |                    flush_tlb_page() {
>        mceinj.sh-7662  [000] 154195.857064: funcgraph_entry:                   |                      native_flush_tlb_others() {
>        mceinj.sh-7662  [000] 154195.857064: funcgraph_entry:        0.286 us   |                        is_uv_system();
>        mceinj.sh-7662  [000] 154195.857065: funcgraph_entry:                   |                        flush_tlb_others_ipi() {
>        mceinj.sh-7662  [000] 154195.857065: funcgraph_entry:        0.336 us   |                          _spin_lock();
>        mceinj.sh-7662  [000] 154195.857066: funcgraph_entry:                   |                          physflat_send_IPI_mask() {
>        mceinj.sh-7662  [000] 154195.857066: funcgraph_entry:        0.405 us   |                            default_send_IPI_mask_sequence_phys();
>        mceinj.sh-7662  [000] 154195.857067: funcgraph_exit:         1.032 us   |                          }
>        mceinj.sh-7662  [000] 154195.857068: funcgraph_exit:         3.704 us   |                        }
>        mceinj.sh-7662  [000] 154195.857069: funcgraph_exit:         5.000 us   |                      }
>        mceinj.sh-7662  [000] 154195.857069: funcgraph_exit:         6.060 us   |                    }
>        mceinj.sh-7662  [000] 154195.857070: funcgraph_entry:                   |                    set_page_dirty() {
>        mceinj.sh-7662  [000] 154195.857070: funcgraph_entry:                   |                      __set_page_dirty_buffers() {
>        mceinj.sh-7662  [000] 154195.857070: funcgraph_entry:        0.278 us   |                        _spin_lock();
>        mceinj.sh-7662  [000] 154195.857071: funcgraph_exit:         0.972 us   |                      }
>        mceinj.sh-7662  [000] 154195.857071: funcgraph_exit:         1.636 us   |                    }
>        mceinj.sh-7662  [000] 154195.857072: funcgraph_entry:        0.269 us   |                    native_set_pte_at();
>        mceinj.sh-7662  [000] 154195.857072: funcgraph_entry:                   |                    page_remove_rmap() {
>        mceinj.sh-7662  [000] 154195.857073: funcgraph_entry:        0.281 us   |                      PageHuge();
>        mceinj.sh-7662  [000] 154195.857073: funcgraph_entry:                   |                      __dec_zone_page_state() {
>        mceinj.sh-7662  [000] 154195.857073: funcgraph_entry:        0.330 us   |                        __dec_zone_state();
>        mceinj.sh-7662  [000] 154195.857074: funcgraph_exit:         0.991 us   |                      }
>        mceinj.sh-7662  [000] 154195.857074: funcgraph_entry:                   |                      mem_cgroup_update_file_mapped() {
>        mceinj.sh-7662  [000] 154195.857075: funcgraph_entry:        0.278 us   |                        lookup_page_cgroup();
>        mceinj.sh-7662  [000] 154195.857076: funcgraph_exit:         1.112 us   |                      }
>        mceinj.sh-7662  [000] 154195.857076: funcgraph_exit:         3.668 us   |                    }
>        mceinj.sh-7662  [000] 154195.857076: funcgraph_entry:        0.309 us   |                    put_page();
>        mceinj.sh-7662  [000] 154195.857077: funcgraph_exit:       + 16.206 us  |                  }
>        mceinj.sh-7662  [000] 154195.857077: funcgraph_exit:       + 18.641 us  |                }
>        mceinj.sh-7662  [000] 154195.857077: funcgraph_exit:       + 19.336 us  |              }
>        mceinj.sh-7662  [000] 154195.857078: funcgraph_entry:                   |              me_pagecache_dirty() {
>        mceinj.sh-7662  [000] 154195.857079: funcgraph_entry:                   |                me_pagecache_clean() {
>        mceinj.sh-7662  [000] 154195.857079: funcgraph_entry:                   |                  delete_from_lru_cache() {
>        mceinj.sh-7662  [000] 154195.857080: funcgraph_entry:                   |                    isolate_lru_page() {
>        mceinj.sh-7662  [000] 154195.857080: funcgraph_entry:        0.424 us   |                      _spin_lock_irq();
>        mceinj.sh-7662  [000] 154195.857081: funcgraph_entry:                   |                      mem_cgroup_lru_del_list() {
>        mceinj.sh-7662  [000] 154195.857081: funcgraph_entry:        0.278 us   |                        lookup_page_cgroup();
>        mceinj.sh-7662  [000] 154195.857082: funcgraph_exit:         1.097 us   |                      }
>        mceinj.sh-7662  [000] 154195.857082: funcgraph_entry:        0.381 us   |                      __mod_zone_page_state();
>        mceinj.sh-7662  [000] 154195.857083: funcgraph_exit:         3.660 us   |                    }
>        mceinj.sh-7662  [000] 154195.857084: funcgraph_entry:        0.384 us   |                    put_page();
>        mceinj.sh-7662  [000] 154195.857084: funcgraph_exit:         5.176 us   |                  }
>        mceinj.sh-7662  [000] 154195.857085: funcgraph_entry:                   |                  generic_error_remove_page() {
>        mceinj.sh-7662  [000] 154195.857086: funcgraph_entry:                   |                    truncate_inode_page() {
>        mceinj.sh-7662  [000] 154195.857086: funcgraph_entry:                   |                      do_invalidatepage() {
>        mceinj.sh-7662  [000] 154195.857087: funcgraph_entry:                   |                        ext4_da_invalidatepage() {
>        mceinj.sh-7662  [000] 154195.857087: funcgraph_entry:                   |                          ext4_invalidatepage() {
>        mceinj.sh-7662  [000] 154195.857088: funcgraph_entry:                   |                            jbd2_journal_invalidatepage() {
>        mceinj.sh-7662  [000] 154195.857088: funcgraph_entry:        0.281 us   |                              _cond_resched();
>        mceinj.sh-7662  [000] 154195.857088: funcgraph_entry:                   |                              unlock_buffer() {
>        mceinj.sh-7662  [000] 154195.857089: funcgraph_entry:                   |                                wake_up_bit() {
>        mceinj.sh-7662  [000] 154195.857089: funcgraph_entry:                   |                                  bit_waitqueue() {
>        mceinj.sh-7662  [000] 154195.857089: funcgraph_entry:        0.308 us   |                                    __phys_addr();
>        mceinj.sh-7662  [000] 154195.857090: funcgraph_exit:         1.005 us   |                                  }
>        mceinj.sh-7662  [000] 154195.857091: funcgraph_entry:        0.409 us   |                                  __wake_up_bit();
>        mceinj.sh-7662  [000] 154195.857091: funcgraph_exit:         2.495 us   |                                }
>        mceinj.sh-7662  [000] 154195.857092: funcgraph_exit:         3.240 us   |                              }
>        mceinj.sh-7662  [000] 154195.857092: funcgraph_entry:                   |                              try_to_free_buffers() {
>        mceinj.sh-7662  [000] 154195.857093: funcgraph_entry:        0.377 us   |                                _spin_lock();
>        mceinj.sh-7662  [000] 154195.857093: funcgraph_entry:                   |                                drop_buffers() {
>        mceinj.sh-7662  [000] 154195.857094: funcgraph_entry:        0.427 us   |                                  put_page();
>        mceinj.sh-7662  [000] 154195.857095: funcgraph_exit:         1.378 us   |                                }
>        mceinj.sh-7662  [000] 154195.857095: funcgraph_entry:                   |                                cancel_dirty_page() {
>        mceinj.sh-7662  [000] 154195.857096: funcgraph_entry:                   |                                  dec_zone_page_state() {
>        mceinj.sh-7662  [000] 154195.857096: funcgraph_entry:                   |                                    __dec_zone_page_state() {
>        mceinj.sh-7662  [000] 154195.857097: funcgraph_entry:        0.408 us   |                                      __dec_zone_state();
>        mceinj.sh-7662  [000] 154195.857097: funcgraph_exit:         1.198 us   |                                    }
>        mceinj.sh-7662  [000] 154195.857098: funcgraph_exit:         1.987 us   |                                  }
>        mceinj.sh-7662  [000] 154195.857099: funcgraph_exit:         3.303 us   |                                }
>        mceinj.sh-7662  [000] 154195.857099: funcgraph_entry:                   |                                free_buffer_head() {
>        mceinj.sh-7662  [000] 154195.857099: funcgraph_entry:        0.579 us   |                                  kmem_cache_free();
>        mceinj.sh-7662  [000] 154195.857100: funcgraph_entry:        0.406 us   |                                  recalc_bh_state();
>        mceinj.sh-7662  [000] 154195.857101: funcgraph_exit:         2.269 us   |                                }
>        mceinj.sh-7662  [000] 154195.857102: funcgraph_exit:         9.451 us   |                              }
>        mceinj.sh-7662  [000] 154195.857102: funcgraph_exit:       + 14.532 us  |                            }
>        mceinj.sh-7662  [000] 154195.857102: funcgraph_exit:       + 15.321 us  |                          }
>        mceinj.sh-7662  [000] 154195.857103: funcgraph_exit:       + 16.285 us  |                        }
>        mceinj.sh-7662  [000] 154195.857103: funcgraph_exit:       + 17.133 us  |                      }
>        mceinj.sh-7662  [000] 154195.857104: funcgraph_entry:        0.439 us   |                      cancel_dirty_page();
>        mceinj.sh-7662  [000] 154195.857105: funcgraph_entry:                   |                      remove_from_page_cache() {
>        mceinj.sh-7662  [000] 154195.857105: funcgraph_entry:        0.408 us   |                        _spin_lock_irq();
>        mceinj.sh-7662  [000] 154195.857106: funcgraph_entry:                   |                        __remove_from_page_cache() {
>        mceinj.sh-7662  [000] 154195.857107: funcgraph_entry:                   |                          __dec_zone_page_state() {
>        mceinj.sh-7662  [000] 154195.857107: funcgraph_entry:        0.457 us   |                            __dec_zone_state();
>        mceinj.sh-7662  [000] 154195.857108: funcgraph_exit:         1.224 us   |                          }
>        mceinj.sh-7662  [000] 154195.857109: funcgraph_exit:         2.757 us   |                        }
>        mceinj.sh-7662  [000] 154195.857109: funcgraph_entry:                   |                        mem_cgroup_uncharge_cache_page() {
>        mceinj.sh-7662  [000] 154195.857109: funcgraph_entry:                   |                          __mem_cgroup_uncharge_common() {
>        mceinj.sh-7662  [000] 154195.857110: funcgraph_entry:        0.421 us   |                            lookup_page_cgroup();
>        mceinj.sh-7662  [000] 154195.857111: funcgraph_entry:        0.383 us   |                            bit_spin_lock();
>        mceinj.sh-7662  [000] 154195.857112: funcgraph_exit:         2.119 us   |                          }
>        mceinj.sh-7662  [000] 154195.857112: funcgraph_exit:         2.920 us   |                        }
>        mceinj.sh-7662  [000] 154195.857112: funcgraph_exit:         7.783 us   |                      }
>        mceinj.sh-7662  [000] 154195.857113: funcgraph_entry:        0.393 us   |                      put_page();
>        mceinj.sh-7662  [000] 154195.857113: funcgraph_exit:       + 27.960 us  |                    }
>        mceinj.sh-7662  [000] 154195.857114: funcgraph_exit:       + 29.017 us  |                  }
>        mceinj.sh-7662  [000] 154195.857114: funcgraph_exit:       + 35.595 us  |                }
>        mceinj.sh-7662  [000] 154195.857115: funcgraph_exit:       + 36.476 us  |              }
>        mceinj.sh-7662  [000] 154195.857115: funcgraph_entry:                   |              action_result() {
>        mceinj.sh-7662  [000] 154195.857116: funcgraph_entry:                   |                vprintk() {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
