Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.6 required=3.0 tests=BIGNUM_EMAILS,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09B97C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:34:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9373C208C3
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:34:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="f7ygwcHE";
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="VlMFaJDp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9373C208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 104786B0007; Fri,  9 Aug 2019 08:34:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B5656B0008; Fri,  9 Aug 2019 08:34:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBE786B000A; Fri,  9 Aug 2019 08:34:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id C29336B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 08:34:52 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id b25so68334562otp.12
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 05:34:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:mime-version:content-disposition:user-agent;
        bh=7sFGm7DAfry07W9Y7NrH6PenBUDO/l2La6UByPoZdgQ=;
        b=EHWE1Bo3aGXw908hFS28r8zsMCz0sRQBIJry2ZxVt1NhP93E9oMAl7dmC7YOxXDOHg
         PEn1DQHe/8GP2FHgbsQteASHYaV+Um7ow2+kq4UNbBy+UcNIFevNPAdUdRVkN61B4ntX
         2xUT6nZ5ve8jgS2kOaaNDahdJvbgFGR/QZgGwixhi4cqgtWdHksjyJaMQsbGw6ZRsAH/
         zeZrNWvLa9zBI90dXDpRmo6HMoKAnKAHQVuuPs0nFSrN+J6cGwettDdIIZgqnBWLQMtj
         y6W4sYMGlfgAXFO1QA5G1BwAZf6JcryZXz9fJ+dDObnzpxRPldxZTFul8AWoofHwGZM8
         JVCw==
X-Gm-Message-State: APjAAAUa1w8d8VdrtG3hOFhDj4u1KHXEMASKqn2BGzxkdpwHmIwyvBVX
	sO2STCKFmdwPaEMW+WTkbFBOm5n2egQZCR2J0LHLesdHbfDZpVLm+4lBCLhxvrZ634f+8Kds5zY
	JteKymqDXc/TmgIuKuTiWC/22acrnNJkikDWX186FCkvsuqIPo/k7TMei7jdR1dhdAw==
X-Received: by 2002:a5d:80c3:: with SMTP id h3mr21647612ior.167.1565354092386;
        Fri, 09 Aug 2019 05:34:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwoQTB7usJ/r9pPwcLxXXDrwnmmeXfIvv0Xw0UQ8xDaGUs+Y9dPpNk9nmK1mtZSjNN5swI2
X-Received: by 2002:a5d:80c3:: with SMTP id h3mr21647555ior.167.1565354091552;
        Fri, 09 Aug 2019 05:34:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565354091; cv=none;
        d=google.com; s=arc-20160816;
        b=Gf8InFc7ViUaDpvUT7tcb7oZpCs5K4sx1s07bpvXrOtGKLEFJ97ohrv9F6w0OUFrD0
         Tj2RhJUur9RIkt9Sqj5/AIFgxtlR095kL+51ICit5lsPIf1CV+PslhWcB3KL4yZztdoi
         9/epA3ZjVbqFns17OhyXMTq7hAJjhJ1c0hlDBcHM4rSzPH/tInej4klyta8bglif0CVy
         30WVuLQ9QbNsXwCV2NXc0JNOtScae5V5oazmPhrd7mr9uWK9ZPU193lgdDLQ3TrOToQg
         nu5QKdIxLgMRQ3eSDkqa3G9DKiQKBq/z+rTSOK3Bn8sQJjn+7ZcU23Dyvc/Sqs+4qb0k
         kMsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature:dkim-signature;
        bh=7sFGm7DAfry07W9Y7NrH6PenBUDO/l2La6UByPoZdgQ=;
        b=yCC66yU1XVmImYeoWWk1Pcz44P7kouU6Ht211Z37LaQ5JfwNoPqB/xQj1R1h0iKMgB
         IILpf4XYgTNN2spoacnNYzizbYaGtPEzzQp00pIxqy5y/NPNhvJoqxZjI1G0LMCORtKd
         bxxfraNrmvHZ4PmA3Yzg5CcF6apgPC/rUenzWXu8xmxr4hr9iEt/oMgV8ZUeD1O/vtrE
         k9ogcIkvDc/28H/3A2/IHH6FVz8qpmQzjIBAXwneeJ7YLBcq47p3v5sPNdMPxYHqTalu
         bE3GxZ3d22CaQgX9k8s7otAyuxki0FCr8rXDx1ZhMVevKhvjJLvgA+aydtrLTHoVFF2G
         zPEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2019-08-05 header.b=f7ygwcHE;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=VlMFaJDp;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id q25si10092828iog.126.2019.08.09.05.34.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 05:34:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.carpenter@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2019-08-05 header.b=f7ygwcHE;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=VlMFaJDp;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x79CYRr5185992;
	Fri, 9 Aug 2019 12:34:49 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type; s=corp-2019-08-05;
 bh=7sFGm7DAfry07W9Y7NrH6PenBUDO/l2La6UByPoZdgQ=;
 b=f7ygwcHErht1sBU4N1nERK/ujArkAhxdpcvVTrDUzWjlBr2zEljPu/BJHywwUFkgKBIV
 9VH5kYbBV9ws0KK+FYNCj2ju9mQK7NyrTsg7MWpnTfJBc3agAAa7Lsn/0enLw+7Zxzj3
 DZb2qyIBf93tQmN7M040UpI5uRefdJ9hyyeV9CDHG25IAUuxWhTMLVxwLtuGFeX9fGsD
 DAkZTORJrfwT08qJ2g6LfjaDBtzlCtiQkldOLoDY1IYw6/OB7veUCBGKxd/9VhxakGIX
 /37Sca+oGHKnphgzyfBOvyDMEVckVgoFAihVj8iwp6IgHrXcIk4ZZoRc2lFdrDEy4MHo ug== 
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type; s=corp-2018-07-02;
 bh=7sFGm7DAfry07W9Y7NrH6PenBUDO/l2La6UByPoZdgQ=;
 b=VlMFaJDpQbek3sAEgwlmig5enhStZwyPMGg8RBGkE4z4b/wa/JtBRQIM3DNrjsAgbx//
 KirKe3MEjLjCGmgUJA2DKgEFO+mKaxuF66D2Ex8mHSHEnSA9ghltShzKLKO/cGXufwJ/
 Jl3Ouom+Aha89Bs5Z4Ddw6XV3KzbDKcLJ23MBA6ylObIf2sPmnmzF4Y0bIwxDPgWQtWa
 5BmMcUnsWPuGNw1JacdlFl1K1CyV7Hi5ZrhmE9mvs7uEEpvnek4s3eU0LJRyqvlH8nav
 qjE/F5B5O/hPzB0iONAuVuFvYKrrqxR4mWknZMmejsUtjDwc0it59hxsqi6szSLTREjB LA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2u8hasf7y0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 09 Aug 2019 12:34:49 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x79CXIqS139622;
	Fri, 9 Aug 2019 12:34:49 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2u8x1gqewn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 09 Aug 2019 12:34:49 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x79CYlM5012634;
	Fri, 9 Aug 2019 12:34:48 GMT
Received: from mwanda (/41.57.98.10)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 09 Aug 2019 05:34:47 -0700
Date: Fri, 9 Aug 2019 15:34:41 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: songliubraving@fb.com
Cc: linux-mm@kvack.org
Subject: [bug report] mm,thp: add read-only THP support for (non-shmem) FS
Message-ID: <20190809123441.GA9573@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9343 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908090130
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9343 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908090130
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Song Liu,

The patch 89e1c65c0db7: "mm,thp: add read-only THP support for
(non-shmem) FS" from Aug 7, 2019, leads to the following static
checker warning:

	mm/khugepaged.c:1532 collapse_file()
	error: double unlock 'irq:'

mm/khugepaged.c
  1398                          if (xa_is_value(page) || !PageUptodate(page)) {
  1399                                  xas_unlock_irq(&xas);
                                        ^^^^^^^^^^^^^^^^^^^^
We enable IRQs.

  1400                                  /* swap in or instantiate fallocated page */
  1401                                  if (shmem_getpage(mapping->host, index, &page,
  1402                                                    SGP_NOHUGE)) {
  1403                                          result = SCAN_FAIL;
  1404                                          goto xa_unlocked;
  1405                                  }
  1406                          } else if (trylock_page(page)) {
  1407                                  get_page(page);
  1408                                  xas_unlock_irq(&xas);
  1409                          } else {
  1410                                  result = SCAN_PAGE_LOCK;
  1411                                  goto xa_locked;
  1412                          }
  1413                  } else {        /* !is_shmem */
  1414                          if (!page || xa_is_value(page)) {
  1415                                  xas_unlock_irq(&xas);
  1416                                  page_cache_sync_readahead(mapping, &file->f_ra,
  1417                                                            file, index,
  1418                                                            PAGE_SIZE);
  1419                                  /* drain pagevecs to help isolate_lru_page() */
  1420                                  lru_add_drain();
  1421                                  page = find_lock_page(mapping, index);
  1422                                  if (unlikely(page == NULL)) {
  1423                                          result = SCAN_FAIL;
  1424                                          goto xa_unlocked;
  1425                                  }
  1426                          } else if (!PageUptodate(page)) {
  1427                                  xas_unlock_irq(&xas);
  1428                                  wait_on_page_locked(page);
  1429                                  if (!trylock_page(page)) {
  1430                                          result = SCAN_PAGE_LOCK;
  1431                                          goto xa_unlocked;
  1432                                  }
  1433                                  get_page(page);
  1434                          } else if (PageDirty(page)) {
  1435                                  result = SCAN_FAIL;
  1436                                  goto xa_locked;
  1437                          } else if (trylock_page(page)) {
  1438                                  get_page(page);
  1439                                  xas_unlock_irq(&xas);
  1440                          } else {
  1441                                  result = SCAN_PAGE_LOCK;
  1442                                  goto xa_locked;
  1443                          }
  1444                  }
  1445  
  1446                  /*
  1447                   * The page must be locked, so we can drop the i_pages lock
  1448                   * without racing with truncate.
  1449                   */
  1450                  VM_BUG_ON_PAGE(!PageLocked(page), page);
  1451                  VM_BUG_ON_PAGE(!PageUptodate(page), page);
  1452  
  1453                  /*
  1454                   * If file was truncated then extended, or hole-punched, before
  1455                   * we locked the first page, then a THP might be there already.
  1456                   */
  1457                  if (PageTransCompound(page)) {
  1458                          result = SCAN_PAGE_COMPOUND;
  1459                          goto out_unlock;
  1460                  }
  1461  
  1462                  if (page_mapping(page) != mapping) {
  1463                          result = SCAN_TRUNCATED;
  1464                          goto out_unlock;
  1465                  }
  1466  
  1467                  if (isolate_lru_page(page)) {
  1468                          result = SCAN_DEL_PAGE_LRU;
  1469                          goto out_unlock;
  1470                  }
  1471  
  1472                  if (page_has_private(page) &&
  1473                      !try_to_release_page(page, GFP_KERNEL)) {
  1474                          result = SCAN_PAGE_HAS_PRIVATE;
  1475                          break;

The patch adds this break statement but IRQs are enabled at this point.

  1476                  }
  1477  
  1478                  if (page_mapped(page))
  1479                          unmap_mapping_pages(mapping, index, 1, false);
  1480  
  1481                  xas_lock_irq(&xas);
  1482                  xas_set(&xas, index);
  1483  
  1484                  VM_BUG_ON_PAGE(page != xas_load(&xas), page);
  1485                  VM_BUG_ON_PAGE(page_mapped(page), page);
  1486  
  1487                  /*
  1488                   * The page is expected to have page_count() == 3:
  1489                   *  - we hold a pin on it;
  1490                   *  - one reference from page cache;
  1491                   *  - one from isolate_lru_page;
  1492                   */
  1493                  if (!page_ref_freeze(page, 3)) {
  1494                          result = SCAN_PAGE_COUNT;
  1495                          xas_unlock_irq(&xas);
  1496                          putback_lru_page(page);
  1497                          goto out_unlock;
  1498                  }
  1499  
  1500                  /*
  1501                   * Add the page to the list to be able to undo the collapse if
  1502                   * something go wrong.
  1503                   */
  1504                  list_add_tail(&page->lru, &pagelist);
  1505  
  1506                  /* Finally, replace with the new page. */
  1507                  xas_store(&xas, new_page);
  1508                  continue;
  1509  out_unlock:
  1510                  unlock_page(page);
  1511                  put_page(page);
  1512                  goto xa_unlocked;
  1513          }
  1514  
  1515          if (is_shmem)
  1516                  __inc_node_page_state(new_page, NR_SHMEM_THPS);
  1517          else {
  1518                  __inc_node_page_state(new_page, NR_FILE_THPS);
  1519                  filemap_nr_thps_inc(mapping);
  1520          }
  1521  
  1522          if (nr_none) {
  1523                  struct zone *zone = page_zone(new_page);
  1524  
  1525                  __mod_node_page_state(zone->zone_pgdat, NR_FILE_PAGES, nr_none);
  1526                  if (is_shmem)
  1527                          __mod_node_page_state(zone->zone_pgdat,
  1528                                                NR_SHMEM, nr_none);
  1529          }
  1530  
  1531  xa_locked:
  1532          xas_unlock_irq(&xas);
                ^^^^^^^^^^^^^^^^^^^^
Double unlock.

  1533  xa_unlocked:
  1534  
  1535          if (result == SCAN_SUCCEED) {

regards,
dan carpenter

