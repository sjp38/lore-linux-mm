Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79F1DC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 00:51:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3CA121741
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 00:51:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3CA121741
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E45A6B0003; Tue,  9 Apr 2019 20:51:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5952E6B0005; Tue,  9 Apr 2019 20:51:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AC7E6B0006; Tue,  9 Apr 2019 20:51:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8D56B0003
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 20:51:53 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id v16so360897pfn.11
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 17:51:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :subject:message-id:user-agent;
        bh=K0E08On+QVraUsTVlKSHI5EPZumw+n6IZS97gN0ytKM=;
        b=csnWH1ErzlqI/PdjopvygIkEyEc9JrxUvylyidNa2E39mRMuniEbd6y5XRYeUbCv5r
         tNr9g7qz0HVfi2KvxAe7AgCDTImJgyF7DXZzJ+Zw4w5J17HM7tHfyTtavC2Ns2X/F0Ox
         uKfqDQyXECpGulWQNAzlOjbL/0si4xZyJ2M2NDRDrm/1pPV1lFl+hG4sVsaD3GGrYWtY
         qyqx2doFpqJOHC/EMAVjlz/uYYrRlc0Uym9LotuvLUb5OPBwvE+sPRVGYSakmKCeWObI
         O5eStIo++rasb/6rHIKaEqCGl1/SvVIModc8Xz5IkhwBrAUEC8VCZayXQk4GN/7UxT8O
         AXxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAX3wCoPlotH5lEsbrAGuZA8Wilq5zFczqGjtjwdLbulf54rJf0b
	uSENwrkCPGczWHXxMoPH2b02pSUXLKTtXKg+tjbMGCCPEZSXCd5B28hEXcszp4/08Anas37iqqO
	L1hZ+4JGUX4/AuYnfSF3d48JwzYWHt3su3b53HOyJje3IiwB8uAmIxJAK4HPMloNTxw==
X-Received: by 2002:a17:902:b60d:: with SMTP id b13mr41025671pls.100.1554857512588;
        Tue, 09 Apr 2019 17:51:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWhR9iSqBMbWIBhURxTPXObswrfK61FxGXbYC8bj2Kc/lrF2J9U7XU8IyPm9ESYUf5txyO
X-Received: by 2002:a17:902:b60d:: with SMTP id b13mr41025565pls.100.1554857510895;
        Tue, 09 Apr 2019 17:51:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554857510; cv=none;
        d=google.com; s=arc-20160816;
        b=WAmNahTvGvgMI/6P6d6X5fbHn7wDyJyEGMJaQSAdqL/BULt/VVK6p9wVE1i3NthEAS
         GyLjPdCmP7083KN7Rr/BFpGFcGov9/bpT5LjR0HYAGJaLbFnN0OuhUjOoOkLNM+EqTzE
         jxqLd4AlQfQ1drsthDdSwWHVkS3fK/naIm6F+qsFfb8t/Fu3Ji10NC5Y6gyUusX2oCqP
         mgyNvT5bEC4gg2m1xF0+lQmvuBrNWaTm6g8ohT361AGa66aYLemWPy6NlZMI7B1w6FlO
         6L61+j89KpBaElSWvqXjocftUs4fS4oAq3HnpQm0K9TY7+uDjzwRccw/O2es/VQF/UQ6
         u8vA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:subject:to:from:date;
        bh=K0E08On+QVraUsTVlKSHI5EPZumw+n6IZS97gN0ytKM=;
        b=d5giS9mgS3z7Q0ebYL+fmhC4Uopta1N5RJXvarU5FO2gx6INPssedslnFd7DOjwMsV
         68jl/3Gy8TnmZnCaVY//xANyXQCh52/Rxqz5itjDt6fplTP76D6xHrOVUEkxRLLP86eK
         054DoxecIC2ZEvWULw0DV7mCtqjT37eJN3greYysHh50PhgcwtI67WTNoLj9w0pwn7IH
         5DS7jjpD9t8rIhq7zxTXA7CkKkm0sy7mg6JHPO55QqhIcOKK4HyKdRkuM0Zb24TXHllV
         FVilv6amQQaDZs/1/7ceL0+b0uOzrdgETHSAVP1jPMC0LYP8y0t8Z+bm7YoNPG8V1P+A
         XxeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b68si13576375plb.351.2019.04.09.17.51.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 17:51:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id D9508106D;
	Wed, 10 Apr 2019 00:51:49 +0000 (UTC)
Date: Tue, 09 Apr 2019 17:51:48 -0700
From: akpm@linux-foundation.org
To: broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org,
 sfr@canb.auug.org.au
Subject:  mmotm 2019-04-09-17-51 uploaded
Message-ID: <20190410005148.JVyyoXimw%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The mm-of-the-moment snapshot 2019-04-09-17-51 has been uploaded to

   http://www.ozlabs.org/~akpm/mmotm/

mmotm-readme.txt says

README for mm-of-the-moment:

http://www.ozlabs.org/~akpm/mmotm/

This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
more than once a week.

You will need quilt to apply these patches to the latest Linus release (5.x
or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
http://ozlabs.org/~akpm/mmotm/series

The file broken-out.tar.gz contains two datestamp files: .DATE and
.DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
followed by the base kernel version against which this patch series is to
be applied.

This tree is partially included in linux-next.  To see which patches are
included in linux-next, consult the `series' file.  Only the patches
within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
linux-next.


A full copy of the full kernel tree with the linux-next and mmotm patches
already applied is available through git within an hour of the mmotm
release.  Individual mmotm releases are tagged.  The master branch always
points to the latest release, so it's constantly rebasing.

http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/



The directory http://www.ozlabs.org/~akpm/mmots/ (mm-of-the-second)
contains daily snapshots of the -mm tree.  It is updated more frequently
than mmotm, and is untested.

A git copy of this tree is available at

	http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/

and use of this tree is similar to
http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/, described above.


This mmotm tree contains the following patches against 5.1-rc4:
(patches marked "*" will be included in linux-next)

  origin.patch
* checkpatch-dont-interpret-stack-dumps-as-commit-ids.patch
* mm-add-sys-kernel-slab-cache-cache_dma32.patch
* coredump-fix-race-condition-between-mmget_not_zero-get_task_mm-and-core-dumping.patch
* userfaultfd-use-rcu-to-free-the-task-struct-when-fork-fails.patch
* slab-store-tagged-freelist-for-off-slab-slabmgmt.patch
* mm-swapoff-shmem_find_swap_entries-filter-out-other-types.patch
* mm-swapoff-remove-too-limiting-swap_unuse_max_tries.patch
* mm-swapoff-take-notice-of-completion-sooner.patch
* mm-swapoff-shmem_unuse-stop-eviction-without-igrab.patch
* mm-swapoff-shmem_unuse-stop-eviction-without-igrab-fix.patch
* mm-memory_hotplug-do-not-unlock-when-fails-to-take-the-device_hotplug_lock.patch
* mm-vmstat-fix-proc-vmstat-format-for-config_debug_tlbflush=y-config_smp=n.patch
* prctl-fix-false-positive-in-validate_prctl_map.patch
* scripts-spellingtxt-add-more-typos-to-spellingtxt-and-sort.patch
* arch-sh-boards-mach-dreamcast-irqc-remove-duplicate-header.patch
* debugobjects-move-printk-out-of-db-lock-critical-sections.patch
* ocfs2-use-common-file-type-conversion.patch
* ocfs2-fix-ocfs2-read-inode-data-panic-in-ocfs2_iget.patch
* ocfs2-clear-zero-in-unaligned-direct-io.patch
* ocfs2-clear-zero-in-unaligned-direct-io-checkpatch-fixes.patch
* ocfs2-wait-for-recovering-done-after-direct-unlock-request.patch
* ocfs2-checkpoint-appending-truncate-log-transaction-before-flushing.patch
* ramfs-support-o_tmpfile.patch
  mm.patch
* list-add-function-list_rotate_to_front.patch
* slob-respect-list_head-abstraction-layer.patch
* slob-use-slab_list-instead-of-lru.patch
* slub-add-comments-to-endif-pre-processor-macros.patch
* slub-use-slab_list-instead-of-lru.patch
* slab-use-slab_list-instead-of-lru.patch
* mm-remove-stale-comment-from-page-struct.patch
* slub-remove-useless-kmem_cache_debug-before-remove_full.patch
* mm-slab-remove-unneed-check-in-cpuup_canceled.patch
* slub-update-the-comment-about-slab-frozen.patch
* mm-vmscan-drop-zone-id-from-kswapd-tracepoints.patch
* mm-cma_debugc-fix-the-break-condition-in-cma_maxchunk_get.patch
* userfaultfd-sysctl-add-vmunprivileged_userfaultfd.patch
* userfaultfd-sysctl-add-vmunprivileged_userfaultfd-fix.patch
* page-cache-store-only-head-pages-in-i_pages.patch
* page-cache-store-only-head-pages-in-i_pages-fix.patch
* page-cache-store-only-head-pages-in-i_pages-fix-fix.patch
* mm-page_alloc-disallow-__gfp_comp-in-alloc_pages_exact.patch
* mm-move-recent_rotated-pages-calculation-to-shrink_inactive_list.patch
* mm-move-nr_deactivate-accounting-to-shrink_active_list.patch
* mm-move-nr_deactivate-accounting-to-shrink_active_list-fix.patch
* mm-remove-pages_to_free-argument-of-move_active_pages_to_lru.patch
* mm-generalize-putback-scan-functions.patch
* mm-gup-replace-get_user_pages_longterm-with-foll_longterm.patch
* mm-gup-replace-get_user_pages_longterm-with-foll_longterm-v3.patch
* mm-gup-change-write-parameter-to-flags-in-fast-walk.patch
* mm-gup-change-gup-fast-to-use-flags-rather-than-a-write-bool.patch
* mm-gup-add-foll_longterm-capability-to-gup-fast.patch
* mm-gup-add-foll_longterm-capability-to-gup-fast-v3.patch
* ib-hfi1-use-the-new-foll_longterm-flag-to-get_user_pages_fast.patch
* ib-hfi1-use-the-new-foll_longterm-flag-to-get_user_pages_fast-v3.patch
* ib-qib-use-the-new-foll_longterm-flag-to-get_user_pages_fast.patch
* ib-mthca-use-the-new-foll_longterm-flag-to-get_user_pages_fast.patch
* mmmemory_hotplug-unlock-1gb-hugetlb-on-x86_64.patch
* mmmemory_hotplug-drop-redundant-hugepage_migration_supported-check.patch
* mm-memory_hotplug-fix-the-wrong-usage-of-n_high_memory.patch
* mm-compaction-fix-an-undefined-behaviour.patch
* mm-compaction-fix-an-undefined-behaviour-fix.patch
* mm-cma-fix-the-bitmap-status-to-show-failed-allocation-reason.patch
* mm-compaction-show-gfp-flag-names-in-try_to_compact_pages-tracepoint.patch
* mm-compaction-some-tracepoints-should-be-defined-only-when-config_compaction-is-set.patch
* mm-change-mm_update_next_owner-to-update-mm-owner-with-write_once.patch
* mm-isolation-remove-redundant-pfn_valid_within-in-__first_valid_page.patch
* mm-vmscan-add-tracepoints-for-node-reclaim.patch
* mm-memcontrol-track-lru-counts-in-the-vmstats-array.patch
* mm-memcontrol-replace-zone-summing-with-lruvec_page_state.patch
* mm-memcontrol-replace-node-summing-with-memcg_page_state.patch
* mm-memcontrol-push-down-mem_cgroup_node_nr_lru_pages.patch
* mm-memcontrol-push-down-mem_cgroup_nr_lru_pages.patch
* mm-memcontrol-quarantine-the-mem_cgroup_nr_lru_pages-api.patch
* mm-cma-fix-crash-on-cma-allocation-if-bitmap-allocation-fails.patch
* initramfs-free-initrd-memory-if-opening-initrdimage-fails.patch
* initramfs-cleanup-initrd-freeing.patch
* initramfs-factor-out-a-helper-to-populate-the-initrd-image.patch
* initramfs-cleanup-populate_rootfs.patch
* initramfs-cleanup-populate_rootfs-fix.patch
* initramfs-move-the-legacy-keepinitrd-parameter-to-core-code.patch
* initramfs-proide-a-generic-free_initrd_mem-implementation.patch
* initramfs-poison-freed-initrd-memory.patch
* init-provide-a-generic-free_initmem-implementation.patch
* hexagon-switch-over-to-generic-free_initmem.patch
* init-free_initmem-poison-freed-init-memory.patch
* riscv-switch-over-to-generic-free_initmem.patch
* sh-advertise-gigantic-page-support.patch
* sparc-advertise-gigantic-page-support.patch
* mm-simplify-memory_isolation-compaction-cma-into-contig_alloc.patch
* hugetlb-allow-to-free-gigantic-pages-regardless-of-the-configuration.patch
* mm-introduce-put_user_page-placeholder-versions.patch
* mm-page_mkclean-vs-madv_dontneed-race.patch
* mm-vmscan-drop-may_writepage-and-classzone_idx-from-direct-reclaim-begin-template.patch
* mem-hotplug-fix-node-spanned-pages-when-we-have-a-node-with-only-zone_movable.patch
* hugetlbfs-fix-potential-over-underflow-setting-node-specific-nr_hugepages.patch
* mm-hugetlb-get-rid-of-nodemask_alloc.patch
* mm-__pagevec_lru_add_fn-typo-fix.patch
* mm-balloon-drop-unused-function-stubs.patch
* mm-sparse-clean-up-the-obsolete-code-comment.patch
* drivers-base-memoryc-clean-up-relicts-in-function-parameters.patch
* huegtlbfs-on-restore-reserve-error-path-retain-subpool-reservation.patch
* hugetlb-use-same-fault-hash-key-for-shared-and-private-mappings.patch
* mm-hmm-select-mmu-notifier-when-selecting-hmm-v2.patch
* mm-hmm-use-reference-counting-for-hmm-struct-v3.patch
* mm-hmm-do-not-erase-snapshot-when-a-range-is-invalidated.patch
* mm-hmm-improve-and-rename-hmm_vma_get_pfns-to-hmm_range_snapshot-v2.patch
* mm-hmm-improve-and-rename-hmm_vma_fault-to-hmm_range_fault-v3.patch
* mm-hmm-improve-driver-api-to-work-and-wait-over-a-range-v3.patch
* mm-hmm-add-default-fault-flags-to-avoid-the-need-to-pre-fill-pfns-arrays-v2.patch
* mm-hmm-mirror-hugetlbfs-snapshoting-faulting-and-dma-mapping-v3.patch
* mm-hmm-allow-to-mirror-vma-of-a-file-on-a-dax-backed-filesystem-v3.patch
* mm-hmm-add-helpers-to-test-if-mm-is-still-alive-or-not.patch
* mm-hmm-add-an-helper-function-that-fault-pages-and-map-them-to-a-device-v3.patch
* mm-hmm-add-an-helper-function-that-fault-pages-and-map-them-to-a-device-v3-fix.patch
* mm-hmm-convert-various-hmm_pfn_-to-device_entry-which-is-a-better-name.patch
* mm-mmu_notifier-helper-to-test-if-a-range-invalidation-is-blockable.patch
* mm-mmu_notifier-convert-user-range-blockable-to-helper-function.patch
* mm-mmu_notifier-convert-mmu_notifier_range-blockable-to-a-flags.patch
* mm-mmu_notifier-contextual-information-for-event-enums.patch
* mm-mmu_notifier-contextual-information-for-event-triggering-invalidation-v2.patch
* mm-mmu_notifier-use-correct-mmu_notifier-events-for-each-invalidation.patch
* mm-mmu_notifier-pass-down-vma-and-reasons-why-mmu-notifier-is-happening-v2.patch
* mm-mmu_notifier-mmu_notifier_range_update_to_read_only-helper.patch
* mm-enable-error-injection-at-add_to_page_cache.patch
* mm-enable-error-injection-at-add_to_page_cache-fix.patch
* mm-rmap-use-the-pramapcount-to-do-the-check.patch
* mm-use-mm_zero_struct_page-from-sparc-on-all-64b-architectures.patch
* mm-drop-meminit_pfn_in_nid-as-it-is-redundant.patch
* mm-implement-new-zone-specific-memblock-iterator.patch
* mm-initialize-max_order_nr_pages-at-a-time-instead-of-doing-larger-sections.patch
* mm-memory_hotplug-cleanup-memory-offline-path.patch
* mm-memory_hotplug-provide-a-more-generic-restrictions-for-memory-hotplug.patch
* mm-memory_hotplug-provide-a-more-generic-restrictions-for-memory-hotplug-fix.patch
* mm-filemap-fix-minor-typo.patch
* mm-memory_hotplug-release-memory-resource-after-arch_remove_memory.patch
* mm-memory_hotplug-make-unregister_memory_section-never-fail.patch
* mm-memory_hotplug-make-__remove_section-never-fail.patch
* mm-memory_hotplug-make-__remove_pages-and-arch_remove_memory-never-fail.patch
* memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work.patch
* memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
* psi-introduce-state_mask-to-represent-stalled-psi-states.patch
* psi-make-psi_enable-static.patch
* psi-rename-psi-fields-in-preparation-for-psi-trigger-addition.patch
* psi-rename-psi-fields-in-preparation-for-psi-trigger-addition-v6.patch
* psi-split-update_stats-into-parts.patch
* psi-track-changed-states.patch
* refactor-header-includes-to-allow-kthreadh-inclusion-in-psi_typesh.patch
* psi-introduce-psi-monitor.patch
* mm-add-priority-threshold-to-__purge_vmap_area_lazy.patch
* mm-vmap-keep-track-of-free-blocks-for-vmap-allocation.patch
* mm-vmap-keep-track-of-free-blocks-for-vmap-allocation-v3.patch
* mm-vmap-keep-track-of-free-blocks-for-vmap-allocation-v4.patch
* mm-vmap-add-debug_augment_propagate_check-macro.patch
* mm-vmap-add-debug_augment_propagate_check-macro-v4.patch
* mm-vmap-add-debug_augment_lowest_match_check-macro.patch
* mm-vmap-add-debug_augment_lowest_match_check-macro-v4.patch
* mm-proportional-memorylowmin-reclaim.patch
* mm-make-memoryemin-the-baseline-for-utilisation-determination.patch
* mm-make-memoryemin-the-baseline-for-utilisation-determination-fix.patch
* mm-add-probe_user_read.patch
* mm-add-probe_user_read-fix.patch
* powerpc-use-probe_user_read.patch
* mm-vmalloc-convert-vmap_lazy_nr-to-atomic_long_t.patch
* mm-shuffle-initial-free-memory-to-improve-memory-side-cache-utilization.patch
* mm-shuffle-initial-free-memory-to-improve-memory-side-cache-utilization-fix.patch
* mm-move-buddy-list-manipulations-into-helpers.patch
* mm-move-buddy-list-manipulations-into-helpers-fix.patch
* mm-move-buddy-list-manipulations-into-helpers-fix2.patch
* mm-maintain-randomization-of-page-free-lists.patch
* mm-maintain-randomization-of-page-free-lists-checkpatch-fixes.patch
* mm-vmscan-remove-unused-lru_pages-argument.patch
* mm-mincore-make-mincore-more-conservative.patch
* mm-mincore-make-mincore-more-conservative-v2.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* info-task-hung-in-generic_file_write_iter.patch
* info-task-hung-in-generic_file_write-fix.patch
* fs-select-avoid-clang-stack-usage-warning.patch
* kdb-get-rid-of-broken-attempt-to-print-ccversion-in-kdb-summary.patch
* remove-spdx-with-linux-syscall-note-from-kernel-space-headers.patch
* notifiers-double-register-detection.patch
* kernel-latencytopc-remove-unnecessary-checks-for-latencytop_enabled.patch
* kernel-latencytopc-rename-clear_all_latency_tracing-to-clear_tsk_latency_tracing.patch
* lib-bitmapc-remove-unused-export_symbols.patch
* lib-bitmapc-guard-exotic-bitmap-functions-by-config_numa.patch
* lib-genallocc-export-symbol-addr_in_gen_pool.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr-fix.patch
* lib-plist-rename-debug_pi_list-to-debug_plist.patch
* lib-sort-make-swap-functions-more-generic.patch
* lib-sort-use-more-efficient-bottom-up-heapsort-variant.patch
* lib-sort-avoid-indirect-calls-to-built-in-swap.patch
* lib-list_sort-simplify-and-remove-max_list_length_bits.patch
* lib-list_sort-optimize-number-of-calls-to-comparison-function.patch
* lib-move-mathematic-helpers-to-separate-folder.patch
* lib-math-move-int_pow-from-pwm_blc-for-wider-use.patch
* lib-make-bitmap_parselist_user-a-wrapper-on-bitmap_parselist.patch
* lib-rework-bitmap_parselist.patch
* lib-test_bitmap-switch-test_bitmap_parselist-to-ktime_get.patch
* lib-test_bitmap-add-testcases-for-bitmap_parselist.patch
* lib-test_bitmap-add-tests-for-bitmap_parselist_user.patch
* bitops-fix-ubsan-undefined-behavior-warning-for-rotation-right.patch
* lib-fix-possible-incorrect-result-from-rational-fractions-helper.patch
* checkpatch-fix-something.patch
* fs-binfmt_elfc-remove-unneeded-initialization-of-mm-start_stack.patch
* elf-make-scope-of-pos-variable-smaller.patch
* elf-free-pt_interp-filename-asap.patch
* elf-free-pt_interp-filename-asap-fix.patch
* elf-delete-trailing-return-in-functions-returning-void.patch
* autofs-fix-some-word-usage-odities-in-autofstxt.patch
* autofs-update-autofstxt-for-strictexpire-mount-option.patch
* autofs-update-autofs_exp_leaves-description.patch
* autofs-update-mount-control-expire-desription-with-autofs_exp_forced.patch
* autofs-add-description-of-ignore-pseudo-mount-option.patch
* fat-issue-flush-after-the-writeback-of-fat.patch
* signal-annotate-implicit-fall-through.patch
* cpumask-fix-double-string-traverse-in-cpumask_parse.patch
* cpumask-fix-double-string-traverse-in-cpumask_parse-fix.patch
* rapidio-fix-a-null-pointer-derefenrece-when-create_workqueue-fails.patch
* kernel-sysctlc-switch-to-bitmap_zalloc.patch
* sysctl-return-einval-if-val-violates-minmax.patch
* convert-struct-pid-count-to-refcount_t.patch
* convert-struct-pid-count-to-refcount_t-fix.patch
* eventfd-prepare-id-to-userspace-via-fdinfo.patch
* gcov-clang-move-common-gcc-code-into-gcc_basec.patch
* gcov-docs-add-a-note-on-gcc-vs-clang-differences.patch
* panic-avoid-the-extra-noise-dmesg.patch
* panic-reboot-allow-specifying-reboot_mode-for-panic-only.patch
* pps-descriptor-based-gpio.patch
* dt-bindings-pps-pps-gpio-pps-echo-implementation.patch
* pps-pps-gpio-pps-echo-implementation.patch
* scripts-gdb-find-vmlinux-where-it-was-before.patch
* scripts-gdb-add-kernel-config-dumping-command.patch
* scripts-gdb-add-kernel-config-dumping-command-v2.patch
* scripts-gdb-add-rb-tree-iterating-utilities.patch
* scripts-gdb-add-rb-tree-iterating-utilities-v2.patch
* scripts-gdb-add-a-timer-list-command.patch
* scripts-gdb-add-a-timer-list-command-v2.patch
* scripts-gdb-silence-pep8-checks.patch
* ipc-prevent-lockup-on-alloc_msg-and-free_msg.patch
* ipc-mqueue-remove-redundant-wq-task-assignment.patch
* ipc-mqueue-optimize-msg_get.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-16m.patch
* ipc-conserve-sequence-numbers-in-ipcmni_extend-mode.patch
* ipc-do-cyclic-id-allocation-for-the-ipc-object.patch
  linux-next.patch
  linux-next-rejects.patch
* pinctrl-fix-pxa2xxc-build-warnings.patch
* scripts-atomic-check-atomicssh-dont-assume-that-scripts-are-executable.patch
* fs-coda-psdevc-remove-duplicate-header.patch
* include-replace-tsk-to-task-in-linux-sched-signalh.patch
* fs-cachefiles-nameic-remove-duplicate-header.patch
* fs-block_devc-remove-duplicate-header.patch
* kernel-resource-use-resource_overlaps-to-simplify-region_intersects.patch
* treewide-replace-include-asm-sizesh-with-include-linux-sizesh.patch
* arch-remove-asm-sizesh-amd-asm-generic-sizesh.patch
* mm-rename-ambiguously-named-memorystat-counters-and-functions.patch
* mm-rename-ambiguously-named-memorystat-counters-and-functions-fix.patch
* mm-consider-subtrees-in-memoryevents.patch
* fsl_hypervisor-dereferencing-error-pointers-in-ioctl.patch
* fsl_hypervisor-prevent-integer-overflow-in-ioctl.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch

