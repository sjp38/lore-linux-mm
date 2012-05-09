Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 66AC96B0083
	for <linux-mm@kvack.org>; Wed,  9 May 2012 08:51:25 -0400 (EDT)
Message-ID: <4FAA67FF.6090808@cn.fujitsu.com>
Date: Wed, 09 May 2012 20:50:07 +0800
From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Reply-To: gaowanlong@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: mm: move_pages syscall can't return ENOENT when pages are not
 present
References: <50e8b720-2459-4cf4-bfbd-fcc4cd408249@zmail13.collab.prod.int.phx2.redhat.com> <85e08d38-234a-4bc6-8c4f-6c92b50dc9b1@zmail13.collab.prod.int.phx2.redhat.com> <CAJn8CcGGyPNOZH2g+2FaFCtg70P4QOVvzhWYDcGoJta3-ikr8Q@mail.gmail.com>
In-Reply-To: <CAJn8CcGGyPNOZH2g+2FaFCtg70P4QOVvzhWYDcGoJta3-ikr8Q@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiaotian Feng <xtfeng@gmail.com>
Cc: Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, LTP List <ltp-list@lists.sourceforge.net>

On 05/09/2012 05:28 PM, Xiaotian Feng wrote:

> On Wed, May 9, 2012 at 4:58 PM, Zhouping Liu <zliu@redhat.com> wrote:
>> hi, all
>>
>> Recently, I found an error in move_pages syscall:
>>
>> depending on move_pages(2), when page is not present,
>> it should fail with ENOENT, in fact, it's ok without
>> any errno.
>>
>> the following reproducer can easily reproduce
>> the issue, suggest you get more details by strace.
>> inside reproducer, I try to move a non-exist page from
>> node 1 to node 0.
>>
>> I have tested it on the latest kernel 3.4-rc5 with 2 and 4 numa nodes.
>> [zliu@ZhoupingLiu ~]$ gcc -o reproducer reproducer.c -lnuma
>> [zliu@ZhoupingLiu ~]$ ./reproducer
>> from_node is 1, to_node is 0
>> ERROR: move_pages expected FAIL.
>>
> 
> " If nodes is not NULL, move_pages returns the number of valid
> migration requests which could not currently be performed.  Otherwise
> it returns 0."


FYI, actually, 
commit e78bbfa8262424417a29349a8064a535053912b9
Author: Brice Goglin <Brice.Goglin@inria.fr>
Date:   Sat Oct 18 20:27:15 2008 -0700

    mm: stop returning -ENOENT from sys_move_pages() if nothing got migrated

this commit changed the behaviour.

And the LTP has fixed to be consistent with this,
https://github.com/linux-test-project/ltp/commit/338299da1ff27c7815183c1b07eb91e705f117ce


Thanks,
Wanlong Gao

> 
>> I'm not in mail list, please CC me.
>>
>> /*
>>  * Copyright (C) 2012  Red Hat, Inc.
>>  *
>>  * This work is licensed under the terms of the GNU GPL, version 2. See
>>  * the COPYING file in the top-level directory.
>>  *
>>  * Compiled: gcc -o reproducer reproducer.c -lnuma
>>  * Description:
>>  * it's designed to check move_pages syscall, when
>>  * page is not present, it should fail with ENOENT.
>>  */
>>
>> #include <sys/mman.h>
>> #include <sys/types.h>
>> #include <sys/wait.h>
>> #include <stdio.h>
>> #include <unistd.h>
>> #include <errno.h>
>> #include <numa.h>
>> #include <numaif.h>
>>
>> #define TEST_PAGES 4
>>
>> int main(int argc, char **argv)
>> {
>>        void *pages[TEST_PAGES];
>>        int onepage;
>>        int nodes[TEST_PAGES];
>>        int status, ret;
>>        int i, from_node = 1, to_node = 0;
>>
>>        onepage = getpagesize();
>>
>>        for (i = 0; i < TEST_PAGES - 1; i++) {
>>                pages[i] = numa_alloc_onnode(onepage, from_node);
>>                nodes[i] = to_node;
>>        }
>>
>>        nodes[TEST_PAGES - 1] = to_node;
>>
>>        /*
>>         * the follow page is not available, also not aligned,
>>         * depend on move_pages(2), it can't be moved, and should
>>         * return ENOENT errno.
>>         */
>>        pages[TEST_PAGES - 1] = pages[TEST_PAGES - 2] - onepage * 4 + 1;
>>
>>        printf("from_node is %u, to_node is %u\n", from_node, to_node);
>>        ret = move_pages(0, TEST_PAGES, pages, nodes, &status, MPOL_MF_MOVE);
>>        if (ret == -1) {
>>                if (errno != ENOENT)
>>                        perror("move_pages expected ENOENT errno, but it's");
>>                else
>>                        printf("Succeed\n");
>>        } else {
>>                printf("ERROR: move_pages expected FAIL.\n");
>>        }
>>
>>        for (i = 0; i < TEST_PAGES; i++)
>>                numa_free(pages[i], onepage);
>>
>>        return 0;
>> }
>>
>> --
>> Thanks,
>> Zhouping
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
