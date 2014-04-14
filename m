Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 888EA6B00D8
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 06:37:52 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ld10so8074013pab.12
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 03:37:50 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id hu10si650489pbc.358.2014.04.14.03.37.50
        for <linux-mm@kvack.org>;
        Mon, 14 Apr 2014 03:37:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <534B46FE.1070704@cn.fujitsu.com>
References: <534B46FE.1070704@cn.fujitsu.com>
Subject: RE: ask for your help about a patch (commit: 9845cbb)
Content-Transfer-Encoding: 7bit
Message-Id: <20140414103747.70943E0098@blue.fi.intel.com>
Date: Mon, 14 Apr 2014 13:37:47 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "gux.fnst" <gux.fnst@cn.fujitsu.com>
Cc: kirill.shutemov@linux.intel.com, linux-mm@kvack.org

gux.fnst wrote:
> Hi Kirill,

Hi Xing,

Please always CC to mailing list for upstream-related questions.
I've added linux-mm@ to CC.

> 
> Currently I'm doing some kernel test work, including that reproducing
> some existing kernel bugs. Here I may need your some help.
> 
> On 2014-02-25, you committed a patch (commit: 9845cbb) about thp.
> 
> mm, thp: fix infinite loop on memcg OOM
> ---------------------------------------------------------------------------------------------------------------------------
> Masayoshi Mizuma reported a bug with the hang of an application under 
> the memcg limit.
> It happens on write-protection fault to huge zero page.
> 
> If we successfully allocate a huge page to replace zero page but hit the 
> memcg limit we
> need to split the zero page with split_huge_page_pmd() and fallback to 
> small pages.
> 
> The other part of the problem is that VM_FAULT_OOM has special meaning in
> do_huge_pmd_wp_page() context. __handle_mm_fault() expects the page to 
> be split if
> it sees VM_FAULT_OOM and it will will retry page fault handling. This 
> causes an infinite loop
> if the page was not split.
> 
> do_huge_pmd_wp_zero_page_fallback() can return VM_FAULT_OOM if it failed 
> to allocate
> one small page, so fallback to small pages will not help.
> 
> The solution for this part is to replace VM_FAULT_OOM with 
> VM_FAULT_FALLBACK is
> fallback required.
> ---------------------------------------------------------------------------------------------------------------------------
> 
> It is a little difficult to reproduce this problem fixed by this patch 
> for me. Could you give me some
> hint about how to do this - a??allocate a huge page to replace zero page 
> but hit the memcg limit"?

I used this script:

#!/bin/sh -efu

set -efux

mount -t cgroup none /sys/fs/cgroup
mkdir /sys/fs/cgroup/test
echo "10M" > /sys/fs/cgroup/test/memory.limit_in_bytes
echo "10M" > /sys/fs/cgroup/test/memory.memsw.limit_in_bytes

echo $$ > /sys/fs/cgroup/test/tasks
/host/home/kas/var/mmaptest_zero
echo ok

Where /host/home/kas/var/mmaptest_zero is:

#include <assert.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/mman.h>

#define MB (1024 * 1024)
#define SIZE (256 * MB)

int main(int argc, char **argv)
{
	int i;
	char *p;

	posix_memalign((void **)&p, 2 * MB, SIZE);
	printf("p: %p\n", p);
	fork();
	for (i = 0; i < SIZE; i += 4096)
		assert(p[i] == 0);

	for (i = 0; i < SIZE; i += 4096)
		p[i] = 1;

	pause();
	return 0;
}

Without the patch it hangs, but should trigger OOM.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
