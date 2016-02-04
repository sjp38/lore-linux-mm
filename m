Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id D7F144403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 18:59:02 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id g62so5304106wme.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 15:59:02 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id c133si10470294wmf.44.2016.02.04.15.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 15:59:01 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id g62so27249137wme.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 15:59:01 -0800 (PST)
Date: Fri, 5 Feb 2016 01:58:58 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4/4] thp: rewrite freeze_page()/unfreeze_page() with
 generic rmap walkers
Message-ID: <20160204235858.GA24336@node.shutemov.name>
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
To: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
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

Okay, here's more realistic scenario: migration 8GiB worth of THP.

Testcase:
	#define _GNU_SOURCE
	#include <stdio.h>
	#include <stdlib.h>
	#include <unistd.h>
	#include <sys/mman.h>
	#include <linux/mempolicy.h>
	#include <numaif.h>

	#define MB (1024UL * 1024)
	#define SIZE (4 * 1024 * 2 * MB)
	#define BASE ((void *)0x400000000000)

	#include <time.h>

	void timespec_diff(struct timespec *start, struct timespec *stop,
			struct timespec *result)
	{
		if ((stop->tv_nsec - start->tv_nsec) < 0) {
			result->tv_sec = stop->tv_sec - start->tv_sec - 1;
			result->tv_nsec = stop->tv_nsec - start->tv_nsec + 1000000000;
		} else {
			result->tv_sec = stop->tv_sec - start->tv_sec;
			result->tv_nsec = stop->tv_nsec - start->tv_nsec;
		}
	}

	int main()
	{
		char *p;
		unsigned long ret, node_mask;
		struct timespec start, stop, result;

		node_mask = 0b01;
		ret = set_mempolicy(MPOL_BIND, &node_mask, 64);
		if (ret == -1)
			perror("set_mempolicy"), exit(1);
		p = mmap(BASE, SIZE, PROT_READ | PROT_WRITE,
				MAP_FIXED | MAP_PRIVATE | MAP_ANONYMOUS | MAP_POPULATE,
				-1, 0);
		if (p == MAP_FAILED)
			perror("mmap"), exit(1);

		system("grep thp /proc/vmstat");
		clock_gettime(CLOCK_MONOTONIC, &start);
		node_mask = 0b10;
		ret = mbind(p, SIZE, MPOL_BIND, &node_mask, 64, MPOL_MF_MOVE);
		if (ret == -1)
			perror("mbind"), exit(1);
		clock_gettime(CLOCK_MONOTONIC, &stop);
		system("grep thp /proc/vmstat");

		timespec_diff(&start, &stop, &result);
		printf("--------------------------\n");
		printf("%ld.%09lds\n", result.tv_sec, result.tv_nsec);

		return 0;
	}

Baseline: 25.146 +- 0.141
Patched:  28.684 +- 0.298
Slowdown: 1.14x

Can we tolerate this?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
