Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E84616B0007
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 00:17:47 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id v15-v6so10264190ply.20
        for <linux-mm@kvack.org>; Sun, 12 Aug 2018 21:17:47 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id a20-v6si16978850pgi.184.2018.08.12.21.17.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Aug 2018 21:17:46 -0700 (PDT)
Date: Mon, 13 Aug 2018 12:17:33 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] mm: migration: fix migration of huge PMD shared pages
Message-ID: <201808131256.7IR4O74v%fengguang.wu@intel.com>
References: <20180813034108.27269-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="EeQfGwPcQSOJBaQU"
Content-Disposition: inline
In-Reply-To: <20180813034108.27269-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Mike,

I love your patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.18 next-20180810]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Mike-Kravetz/mm-migration-fix-migration-of-huge-PMD-shared-pages/20180813-114549
config: i386-tinyconfig (attached as .config)
compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   mm/rmap.c: In function 'try_to_unmap_one':
>> mm/rmap.c:1425:7: error: implicit declaration of function 'huge_pmd_unshare'; did you mean 'do_huge_pmd_wp_page'? [-Werror=implicit-function-declaration]
          huge_pmd_unshare(mm, &address, pvmw.pte)) {
          ^~~~~~~~~~~~~~~~
          do_huge_pmd_wp_page
   cc1: some warnings being treated as errors

vim +1425 mm/rmap.c

  1382	
  1383			/*
  1384			 * If the page is mlock()d, we cannot swap it out.
  1385			 * If it's recently referenced (perhaps page_referenced
  1386			 * skipped over this mm) then we should reactivate it.
  1387			 */
  1388			if (!(flags & TTU_IGNORE_MLOCK)) {
  1389				if (vma->vm_flags & VM_LOCKED) {
  1390					/* PTE-mapped THP are never mlocked */
  1391					if (!PageTransCompound(page)) {
  1392						/*
  1393						 * Holding pte lock, we do *not* need
  1394						 * mmap_sem here
  1395						 */
  1396						mlock_vma_page(page);
  1397					}
  1398					ret = false;
  1399					page_vma_mapped_walk_done(&pvmw);
  1400					break;
  1401				}
  1402				if (flags & TTU_MUNLOCK)
  1403					continue;
  1404			}
  1405	
  1406			/* Unexpected PMD-mapped THP? */
  1407			VM_BUG_ON_PAGE(!pvmw.pte, page);
  1408	
  1409			subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
  1410			address = pvmw.address;
  1411	
  1412			/*
  1413			 * PMDs for hugetlbfs pages could be shared.  In this case,
  1414			 * pages with shared PMDs will have a mapcount of 1 no matter
  1415			 * how many times it is actually mapped.  Map counting for
  1416			 * PMD sharing is mostly done via the reference count on the
  1417			 * PMD page itself.  If the page we are trying to unmap is a
  1418			 * hugetlbfs page, attempt to 'unshare' at the PMD level.
  1419			 * huge_pmd_unshare takes care of clearing the PUD and
  1420			 * reference counting on the PMD page which effectively unmaps
  1421			 * the page.  Take care of flushing cache and TLB for page in
  1422			 * this specific mapping here.
  1423			 */
  1424			if (PageHuge(page) &&
> 1425			    huge_pmd_unshare(mm, &address, pvmw.pte)) {
  1426				unsigned long end_add = address + vma_mmu_pagesize(vma);
  1427	
  1428				flush_cache_range(vma, address, end_add);
  1429				flush_tlb_range(vma, address, end_add);
  1430				mmu_notifier_invalidate_range(mm, address, end_add);
  1431				continue;
  1432			}
  1433	
  1434			if (IS_ENABLED(CONFIG_MIGRATION) &&
  1435			    (flags & TTU_MIGRATION) &&
  1436			    is_zone_device_page(page)) {
  1437				swp_entry_t entry;
  1438				pte_t swp_pte;
  1439	
  1440				pteval = ptep_get_and_clear(mm, pvmw.address, pvmw.pte);
  1441	
  1442				/*
  1443				 * Store the pfn of the page in a special migration
  1444				 * pte. do_swap_page() will wait until the migration
  1445				 * pte is removed and then restart fault handling.
  1446				 */
  1447				entry = make_migration_entry(page, 0);
  1448				swp_pte = swp_entry_to_pte(entry);
  1449				if (pte_soft_dirty(pteval))
  1450					swp_pte = pte_swp_mksoft_dirty(swp_pte);
  1451				set_pte_at(mm, pvmw.address, pvmw.pte, swp_pte);
  1452				/*
  1453				 * No need to invalidate here it will synchronize on
  1454				 * against the special swap migration pte.
  1455				 */
  1456				goto discard;
  1457			}
  1458	
  1459			if (!(flags & TTU_IGNORE_ACCESS)) {
  1460				if (ptep_clear_flush_young_notify(vma, address,
  1461							pvmw.pte)) {
  1462					ret = false;
  1463					page_vma_mapped_walk_done(&pvmw);
  1464					break;
  1465				}
  1466			}
  1467	
  1468			/* Nuke the page table entry. */
  1469			flush_cache_page(vma, address, pte_pfn(*pvmw.pte));
  1470			if (should_defer_flush(mm, flags)) {
  1471				/*
  1472				 * We clear the PTE but do not flush so potentially
  1473				 * a remote CPU could still be writing to the page.
  1474				 * If the entry was previously clean then the
  1475				 * architecture must guarantee that a clear->dirty
  1476				 * transition on a cached TLB entry is written through
  1477				 * and traps if the PTE is unmapped.
  1478				 */
  1479				pteval = ptep_get_and_clear(mm, address, pvmw.pte);
  1480	
  1481				set_tlb_ubc_flush_pending(mm, pte_dirty(pteval));
  1482			} else {
  1483				pteval = ptep_clear_flush(vma, address, pvmw.pte);
  1484			}
  1485	
  1486			/* Move the dirty bit to the page. Now the pte is gone. */
  1487			if (pte_dirty(pteval))
  1488				set_page_dirty(page);
  1489	
  1490			/* Update high watermark before we lower rss */
  1491			update_hiwater_rss(mm);
  1492	
  1493			if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
  1494				pteval = swp_entry_to_pte(make_hwpoison_entry(subpage));
  1495				if (PageHuge(page)) {
  1496					int nr = 1 << compound_order(page);
  1497					hugetlb_count_sub(nr, mm);
  1498					set_huge_swap_pte_at(mm, address,
  1499							     pvmw.pte, pteval,
  1500							     vma_mmu_pagesize(vma));
  1501				} else {
  1502					dec_mm_counter(mm, mm_counter(page));
  1503					set_pte_at(mm, address, pvmw.pte, pteval);
  1504				}
  1505	
  1506			} else if (pte_unused(pteval) && !userfaultfd_armed(vma)) {
  1507				/*
  1508				 * The guest indicated that the page content is of no
  1509				 * interest anymore. Simply discard the pte, vmscan
  1510				 * will take care of the rest.
  1511				 * A future reference will then fault in a new zero
  1512				 * page. When userfaultfd is active, we must not drop
  1513				 * this page though, as its main user (postcopy
  1514				 * migration) will not expect userfaults on already
  1515				 * copied pages.
  1516				 */
  1517				dec_mm_counter(mm, mm_counter(page));
  1518				/* We have to invalidate as we cleared the pte */
  1519				mmu_notifier_invalidate_range(mm, address,
  1520							      address + PAGE_SIZE);
  1521			} else if (IS_ENABLED(CONFIG_MIGRATION) &&
  1522					(flags & (TTU_MIGRATION|TTU_SPLIT_FREEZE))) {
  1523				swp_entry_t entry;
  1524				pte_t swp_pte;
  1525	
  1526				if (arch_unmap_one(mm, vma, address, pteval) < 0) {
  1527					set_pte_at(mm, address, pvmw.pte, pteval);
  1528					ret = false;
  1529					page_vma_mapped_walk_done(&pvmw);
  1530					break;
  1531				}
  1532	
  1533				/*
  1534				 * Store the pfn of the page in a special migration
  1535				 * pte. do_swap_page() will wait until the migration
  1536				 * pte is removed and then restart fault handling.
  1537				 */
  1538				entry = make_migration_entry(subpage,
  1539						pte_write(pteval));
  1540				swp_pte = swp_entry_to_pte(entry);
  1541				if (pte_soft_dirty(pteval))
  1542					swp_pte = pte_swp_mksoft_dirty(swp_pte);
  1543				set_pte_at(mm, address, pvmw.pte, swp_pte);
  1544				/*
  1545				 * No need to invalidate here it will synchronize on
  1546				 * against the special swap migration pte.
  1547				 */
  1548			} else if (PageAnon(page)) {
  1549				swp_entry_t entry = { .val = page_private(subpage) };
  1550				pte_t swp_pte;
  1551				/*
  1552				 * Store the swap location in the pte.
  1553				 * See handle_pte_fault() ...
  1554				 */
  1555				if (unlikely(PageSwapBacked(page) != PageSwapCache(page))) {
  1556					WARN_ON_ONCE(1);
  1557					ret = false;
  1558					/* We have to invalidate as we cleared the pte */
  1559					mmu_notifier_invalidate_range(mm, address,
  1560								address + PAGE_SIZE);
  1561					page_vma_mapped_walk_done(&pvmw);
  1562					break;
  1563				}
  1564	
  1565				/* MADV_FREE page check */
  1566				if (!PageSwapBacked(page)) {
  1567					if (!PageDirty(page)) {
  1568						/* Invalidate as we cleared the pte */
  1569						mmu_notifier_invalidate_range(mm,
  1570							address, address + PAGE_SIZE);
  1571						dec_mm_counter(mm, MM_ANONPAGES);
  1572						goto discard;
  1573					}
  1574	
  1575					/*
  1576					 * If the page was redirtied, it cannot be
  1577					 * discarded. Remap the page to page table.
  1578					 */
  1579					set_pte_at(mm, address, pvmw.pte, pteval);
  1580					SetPageSwapBacked(page);
  1581					ret = false;
  1582					page_vma_mapped_walk_done(&pvmw);
  1583					break;
  1584				}
  1585	
  1586				if (swap_duplicate(entry) < 0) {
  1587					set_pte_at(mm, address, pvmw.pte, pteval);
  1588					ret = false;
  1589					page_vma_mapped_walk_done(&pvmw);
  1590					break;
  1591				}
  1592				if (arch_unmap_one(mm, vma, address, pteval) < 0) {
  1593					set_pte_at(mm, address, pvmw.pte, pteval);
  1594					ret = false;
  1595					page_vma_mapped_walk_done(&pvmw);
  1596					break;
  1597				}
  1598				if (list_empty(&mm->mmlist)) {
  1599					spin_lock(&mmlist_lock);
  1600					if (list_empty(&mm->mmlist))
  1601						list_add(&mm->mmlist, &init_mm.mmlist);
  1602					spin_unlock(&mmlist_lock);
  1603				}
  1604				dec_mm_counter(mm, MM_ANONPAGES);
  1605				inc_mm_counter(mm, MM_SWAPENTS);
  1606				swp_pte = swp_entry_to_pte(entry);
  1607				if (pte_soft_dirty(pteval))
  1608					swp_pte = pte_swp_mksoft_dirty(swp_pte);
  1609				set_pte_at(mm, address, pvmw.pte, swp_pte);
  1610				/* Invalidate as we cleared the pte */
  1611				mmu_notifier_invalidate_range(mm, address,
  1612							      address + PAGE_SIZE);
  1613			} else {
  1614				/*
  1615				 * We should not need to notify here as we reach this
  1616				 * case only from freeze_page() itself only call from
  1617				 * split_huge_page_to_list() so everything below must
  1618				 * be true:
  1619				 *   - page is not anonymous
  1620				 *   - page is locked
  1621				 *
  1622				 * So as it is a locked file back page thus it can not
  1623				 * be remove from the page cache and replace by a new
  1624				 * page before mmu_notifier_invalidate_range_end so no
  1625				 * concurrent thread might update its page table to
  1626				 * point at new page while a device still is using this
  1627				 * page.
  1628				 *
  1629				 * See Documentation/vm/mmu_notifier.rst
  1630				 */
  1631				dec_mm_counter(mm, mm_counter_file(page));
  1632			}
  1633	discard:
  1634			/*
  1635			 * No need to call mmu_notifier_invalidate_range() it has be
  1636			 * done above for all cases requiring it to happen under page
  1637			 * table lock before mmu_notifier_invalidate_range_end()
  1638			 *
  1639			 * See Documentation/vm/mmu_notifier.rst
  1640			 */
  1641			page_remove_rmap(subpage, PageHuge(page));
  1642			put_page(page);
  1643		}
  1644	
  1645		mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
  1646	
  1647		return ret;
  1648	}
  1649	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--EeQfGwPcQSOJBaQU
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--EeQfGwPcQSOJBaQU--
