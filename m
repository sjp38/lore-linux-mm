Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FD9C6B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:58:22 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u30so1989125wrc.9
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 23:58:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d202si472870wme.110.2017.06.21.23.58.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 23:58:20 -0700 (PDT)
Subject: Re: [PATCH] mm: Refactor conversion of pages to bytes macro
 definitions
References: <1497971668-30685-1-git-send-email-nborisov@suse.com>
 <20170622064454.GA14308@dhcp22.suse.cz>
From: Nikolay Borisov <nborisov@suse.com>
Message-ID: <5d46bcf4-1988-1abd-eec7-dc11c182810f@suse.com>
Date: Thu, 22 Jun 2017 09:58:17 +0300
MIME-Version: 1.0
In-Reply-To: <20170622064454.GA14308@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, mgorman@techsingularity.net, cmetcalf@mellanox.com, minchan@kernel.org, vbabka@suse.cz, kirill.shutemov@linux.intel.com, tj@kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org



On 22.06.2017 09:44, Michal Hocko wrote:
> On Tue 20-06-17 18:14:28, Nikolay Borisov wrote:
>> Currently there are a multiple files with the following code:
>>  #define K(x) ((x) << (PAGE_SHIFT - 10))
>>  ... some code..
>>  #undef K
>>
>> This is mainly used to print out some memory-related statistics, where X is
>> given in pages and the macro just converts it to kilobytes. In the future
>> there is going to be more macros since there are intention to introduce
>> byte-based memory counters [1]. This could lead to proliferation of
>> multiple duplicated definition of various macros used to convert a quantity
>> from one unit to another. Let's try and consolidate such definition in the
>> mm.h header since currently it's being included in all files which exhibit
>> this pattern. Also let's rename it to something a bit more verbose.
>>
>> This patch doesn't introduce any functional changes
>>
>> [1] https://patchwork.kernel.org/patch/9395205/
>>
>> Signed-off-by: Nikolay Borisov <nborisov@suse.com>
>> ---
>>  arch/tile/mm/pgtable.c      |  2 --
>>  drivers/base/node.c         | 66 ++++++++++++++++++-------------------
>>  include/linux/mm.h          |  2 ++
>>  kernel/debug/kdb/kdb_main.c |  3 +-
>>  mm/backing-dev.c            | 22 +++++--------
>>  mm/memcontrol.c             | 17 +++++-----
>>  mm/oom_kill.c               | 19 +++++------
>>  mm/page_alloc.c             | 80 ++++++++++++++++++++++-----------------------
>>  8 files changed, 100 insertions(+), 111 deletions(-)
> 
> Those macros are quite trivial and we do not really save much code while
> this touches a lot of code potentially causing some conflicts. So do we
> really need this? I am usually very keen on removing duplication but
> this doesn't seem to be worth all the troubles IMHO.
> 

There are 2 problems I see: 

1. K is in fact used for other macros than converting pages to kbytes. 
Simple grep before my patch is applied yields the following: 

arch/tile/mm/pgtable.c:#define K(x) ((x) << (PAGE_SHIFT-10))
arch/x86/crypto/serpent-sse2-i586-asm_32.S:#define K(x0, x1, x2, x3, x4, i) \
crypto/serpent_generic.c:#define K(x0, x1, x2, x3, i) ({                                \
drivers/base/node.c:#define K(x) ((x) << (PAGE_SHIFT - 10))
drivers/net/hamradio/scc.c:#define K(x) kiss->x
include/uapi/linux/keyboard.h:#define K(t,v)            (((t)<<8)|(v))
kernel/debug/kdb/kdb_main.c:#define K(x) ((x) << (PAGE_SHIFT - 10))
mm/backing-dev.c:#define K(x) ((x) << (PAGE_SHIFT - 10))
mm/backing-dev.c:#define K(pages) ((pages) << (PAGE_SHIFT - 10))
mm/memcontrol.c:#define K(x) ((x) << (PAGE_SHIFT-10))
mm/oom_kill.c:#define K(x) ((x) << (PAGE_SHIFT-10))
mm/page_alloc.c:#define K(x) ((x) << (PAGE_SHIFT-10))


Furthermore, I intend on sending another patchset which introduces 2 more macros:
drivers/base/node.c:#define BtoK(x) ((x) >> 10)
drivers/video/fbdev/intelfb/intelfb.h:#define BtoKB(x)          ((x) / 1024)
mm/backing-dev.c:#define BtoK(x) ((x) >> 10)
mm/page_alloc.c:#define BtoK(x) ((x) >> 10)

fs/fs-writeback.c:#define BtoP(x) ((x) >> PAGE_SHIFT)
include/trace/events/writeback.h:#define BtoP(x) ((x) >> PAGE_SHIFT)
mm/page_alloc.c:#define BtoP(x) ((x) >> PAGE_SHIFT)

As you can see this ends up in spreading those macros. Ideally 
they should be in a header which is shared among all affected 
files. This was inspired by the feedback that Tejun has given 
here: https://patchwork.kernel.org/patch/9395205/ and I believe
he is right. 





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
