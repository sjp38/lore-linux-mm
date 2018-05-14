Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A6E1B6B0007
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:19:36 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q185-v6so15500491qke.7
        for <linux-mm@kvack.org>; Mon, 14 May 2018 08:19:36 -0700 (PDT)
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id y9-v6si691010qtk.215.2018.05.14.08.19.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 May 2018 08:19:35 -0700 (PDT)
Date: Mon, 14 May 2018 15:19:34 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC] mm, THP: Map read-only text segments using large THP
 pages
In-Reply-To: <5BB682E1-DD52-4AA9-83E9-DEF091E0C709@oracle.com>
Message-ID: <010001635f3c42d3-ed92871f-4fba-47dc-9750-69a40dd07ab6-000000@email.amazonses.com>
References: <5BB682E1-DD52-4AA9-83E9-DEF091E0C709@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 14 May 2018, William Kucharski wrote:

> The idea is that the kernel will attempt to allocate and map the range using a
> PMD sized THP page upon first fault; if the allocation is successful the page
> will be populated (at present using a call to kernel_read()) and the page will
> be mapped at the PMD level. If memory allocation fails, the page fault routines
> will drop through to the conventional PAGESIZE-oriented routines for mapping
> the faulting page.

Cool. This could be controlled by the faultaround logic right? If we get
fault_around_bytes up to huge page size then it is reasonable to use a
huge page direcly.

fault_around_bytes can be set via sysfs so there is a natural way to
control this feature there I think.


> Since this approach will map a PMD size block of the memory map at a time, we
> should see a slight uptick in time spent in disk I/O but a substantial drop in
> page faults as well as a reduction in iTLB misses as address ranges will be
> mapped with the larger page. Analysis of a test program that consists of a very
> large text area (483,138,032 bytes in size) that thrashes D$ and I$ shows this
> does occur and there is a slight reduction in program execution time.

I think we would also want such a feature for regular writable pages as
soon as possible.
