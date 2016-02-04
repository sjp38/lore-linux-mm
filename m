Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 19A9844044D
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 09:27:40 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id r129so214344724wmr.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 06:27:40 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id 134si20640998wmr.40.2016.02.04.06.27.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 06:27:39 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id g62so688009wme.2
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 06:27:38 -0800 (PST)
Date: Thu, 4 Feb 2016 16:27:36 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4/4] thp: rewrite freeze_page()/unfreeze_page() with
 generic rmap walkers
Message-ID: <20160204142736.GB20399@node.shutemov.name>
References: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1454512459-94334-5-git-send-email-kirill.shutemov@linux.intel.com>
 <56B21FC9.9040009@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <56B21FC9.9040009@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 03, 2016 at 07:42:01AM -0800, Dave Hansen wrote:
> On 02/03/2016 07:14 AM, Kirill A. Shutemov wrote:
> > But the new variant is somewhat slower. Current helpers iterates over
> > VMAs the compound page is mapped to, and then over ptes within this VMA.
> > New helpers iterates over small page, then over VMA the small page
> > mapped to, and only then find relevant pte.
> 
> The code simplification here is really attractive.  Can you quantify
> what the slowdown is?  Is it noticeable, or would it be in the noise
> during all the other stuff that happens under memory pressure?

I don't know how to quantify it within whole memory pressure picture.
There're just too many variables to get some sense from split_huge_page()
contribution.

I've tried to measure split_huge_page() performance itself.

Testcase:

	#define _GNU_SOURCE
	#include <stdio.h>
	#include <stdlib.h>
	#include <unistd.h>
	#include <sys/mman.h>

	#define MB (1024UL * 1024)
	#define SIZE (4 * 1024 * 2 * MB)
	#define BASE ((void *)0x400000000000)

	#define FORKS 0

	int main()
	{
		char *p;
		unsigned long i;

		p = mmap(BASE, SIZE, PROT_READ | PROT_WRITE,
				MAP_FIXED | MAP_PRIVATE | MAP_ANONYMOUS | MAP_POPULATE,
				-1, 0);
		if (p == MAP_FAILED)
			perror("mmap"), exit(1);

		for (i = 0; i < SIZE; i += 2 * MB) {
			munmap(p + i, 4096);
		}

		for (i = 0; i < FORKS; i++) {
			if (!fork())
				pause();
		}

		system("grep thp /proc/vmstat");
		system("time /bin/echo 3 > /proc/sys/vm/drop_caches");
		system("grep thp /proc/vmstat");
		return 0;
	}

Basically, we allocate 4k THP, make them partially unmapped, optionally
fork() the process multiple times and then trigger shrinker, measuring how
long would it take.

Optional fork() will make THP shared, meaning we need to freeze/unfreeze
ptes in multiple VMAs.

Numbers doesn't look pretty:

		FORKS == 0		FORKS == 100
Baseline:	1.93s +- 0.017s		32.08s +- 0.246s
Patched:	5.636s +- 0.021s		405.943s +- 6.126s
Slowdown:	2.92x			12.65x

With FORKS == 100, it looks especially bad. But having that many mapping
of the page is uncommon.

Any comments?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
