Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 578856B00B8
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 01:43:36 -0500 (EST)
Received: by mail-yk0-f174.google.com with SMTP id 20so4765036yks.5
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 22:43:36 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id u64si3068546yhe.64.2014.02.20.22.43.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Feb 2014 22:43:35 -0800 (PST)
Message-ID: <5306F588.10309@oracle.com>
Date: Fri, 21 Feb 2014 01:43:20 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/11] pagewalk: update page table walker core
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1392068676-30627-2-git-send-email-n-horiguchi@ah.jp.nec.com> <5306942C.2070902@gmail.com> <5306c629.012ce50a.6c48.ffff9844SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <5306c629.012ce50a.6c48.ffff9844SMTPIN_ADDED_BROKEN@mx.google.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mpm@selenic.com, cpw@sgi.com, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, xemul@parallels.com, riel@redhat.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

On 02/20/2014 10:20 PM, Naoya Horiguchi wrote:
> Hi Sasha,
> 
> On Thu, Feb 20, 2014 at 06:47:56PM -0500, Sasha Levin wrote:
>> Hi Naoya,
>>
>> This patch seems to trigger a NULL ptr deref here. I didn't have a change to look into it yet
>> but here's the spew:
> 
> Thanks for reporting.
> I'm not sure what caused this bug from the kernel message. But in my guessing,
> it seems that the NULL pointer is deep inside lockdep routine __lock_acquire(),
> so if we find out which pointer was NULL, it might be useful to bisect which
> the proble is (page table walker or lockdep, or both.)

This actually points to walk_pte_range() trying to lock a NULL spinlock. It happens when we call
pte_offset_map_lock() and get a NULL ptl out of pte_lockptr().

> BTW, just from curiousity, in my build environment many of kernel functions
> are inlined, so should not be shown in kernel message. But in your report
> we can see the symbols like walk_pte_range() and __lock_acquire() which never
> appear in my kernel. How did you do it? I turned off CONFIG_OPTIMIZE_INLINING,
> but didn't make it.

I'm really not sure. I've got a bunch of debug options enabled and it just seems to do the trick.

Try CONFIG_READABLE_ASM maybe?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
