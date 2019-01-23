Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A08498E0001
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 04:30:06 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id 39so703844edq.13
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 01:30:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q3-v6si8945557ejm.182.2019.01.23.01.30.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 01:30:04 -0800 (PST)
Date: Wed, 23 Jan 2019 10:30:02 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: BUG() due to "mm: put_and_wait_on_page_locked() while page is
 migrated"
Message-ID: <20190123093002.GP4087@dhcp22.suse.cz>
References: <f87ecfb2-64d3-23d4-54d7-a8ac37733206@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f87ecfb2-64d3-23d4-54d7-a8ac37733206@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: hughd@google.com, Andrea Arcangeli <aarcange@redhat.com>, torvalds@linux-foundation.org, vbabka@suse.cz, akpm@linux-foundation.org, Linux-MM <linux-mm@kvack.org>

On Tue 22-01-19 23:29:04, Qian Cai wrote:
> Running LTP migrate_pages03 [1] a few times triggering BUG() below on an arm64
> ThunderX2 server. Reverted the commit 9a1ea439b16b9 ("mm:
> put_and_wait_on_page_locked() while page is migrated") allows it to run
> continuously.
> 
> put_and_wait_on_page_locked
>   wait_on_page_bit_common
>     put_page
>       put_page_testzero
>         VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
> 
> [1]
> https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/migrate_pages/migrate_pages03.c
> 
> [ 1304.643587] page:ffff7fe0226ff000 count:2 mapcount:0 mapping:ffff8095c3406d58 index:0x7
> [ 1304.652082] xfs_address_space_operations [xfs]
[...]
> [ 1304.682652] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)

This looks like a page reference countimbalance to me. The page seemed
to be freed at the the migration code (wait_on_page_bit_common) called
put_page and immediatelly got reused for xfs allocation and that is why
we see its ref count==2. But I fail to see how that is possible as
__migration_entry_wait already does get_page_unless_zero so the
imbalance must have been preexisting.
-- 
Michal Hocko
SUSE Labs
