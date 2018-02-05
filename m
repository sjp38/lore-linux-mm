Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77B826B0007
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 10:05:47 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id v31so19843497otb.1
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 07:05:47 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i81si892714oia.242.2018.02.05.07.05.46
        for <linux-mm@kvack.org>;
        Mon, 05 Feb 2018 07:05:46 -0800 (PST)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v2] mm: hwpoison: disable memory error handling on 1GB hugepage
References: <20180130013919.GA19959@hori1.linux.bs1.fc.nec.co.jp>
	<1517284444-18149-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Mon, 05 Feb 2018 15:05:43 +0000
In-Reply-To: <1517284444-18149-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	(Naoya Horiguchi's message of "Tue, 30 Jan 2018 12:54:04 +0900")
Message-ID: <87inbbjx2w.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> Recently the following BUG was reported:
>
>     Injecting memory failure for pfn 0x3c0000 at process virtual address 0x7fe300000000
>     Memory failure: 0x3c0000: recovery action for huge page: Recovered
>     BUG: unable to handle kernel paging request at ffff8dfcc0003000
>     IP: gup_pgd_range+0x1f0/0xc20
>     PGD 17ae72067 P4D 17ae72067 PUD 0
>     Oops: 0000 [#1] SMP PTI
>     ...
>     CPU: 3 PID: 5467 Comm: hugetlb_1gb Not tainted 4.15.0-rc8-mm1-abc+ #3
>     Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-1.fc25 04/01/2014
>
> You can easily reproduce this by calling madvise(MADV_HWPOISON) twice on
> a 1GB hugepage. This happens because get_user_pages_fast() is not aware
> of a migration entry on pud that was created in the 1st madvise() event.

Maybe I'm doing something wrong but I wasn't able to reproduce the issue
using the test at the end. I get -

    $ sudo ./hugepage

    Poisoning page...once
    [  121.295771] Injecting memory failure for pfn 0x8300000 at process virtual address 0x400000000000
    [  121.386450] Memory failure: 0x8300000: recovery action for huge page: Recovered

    Poisoning page...once again
    madvise: Bad address

What am I missing?


--------- >8 ---------
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

int main(int argc, char *argv[])
{
	int flags = MAP_HUGETLB | MAP_ANONYMOUS | MAP_PRIVATE;
	int prot = PROT_READ | PROT_WRITE;
	size_t hugepage_sz;
	void *hugepage;
	int ret;

	hugepage_sz = 1024 * 1024 * 1024; /* 1GB */
	hugepage = mmap(NULL, hugepage_sz, prot, flags, -1, 0);
	if (hugepage == MAP_FAILED) {
		perror("mmap");
		return 1;
	}

	memset(hugepage, 'b', hugepage_sz);
	getchar();

	printf("Poisoning page...once\n");
	ret = madvise(hugepage, hugepage_sz, MADV_HWPOISON);
	if (ret) {
		perror("madvise");
		return 1;
	}
	getchar();

	printf("Poisoning page...once again\n");
	ret = madvise(hugepage, hugepage_sz, MADV_HWPOISON);
	if (ret) {
		perror("madvise");
		return 1;
	}
	getchar();

	memset(hugepage, 'c', hugepage_sz);
	ret = munmap(hugepage, hugepage_sz);
	if (ret) {
		perror("munmap");
		return 1;
	}
	
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
