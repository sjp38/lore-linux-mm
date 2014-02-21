Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 06BC06B00C4
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 11:36:16 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id t10so1737415eei.40
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 08:36:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a41si17330645eef.71.2014.02.21.08.36.10
        for <linux-mm@kvack.org>;
        Fri, 21 Feb 2014 08:36:13 -0800 (PST)
Date: Fri, 21 Feb 2014 11:35:53 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <5307807d.c1580e0a.3078.ffff8622SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <5306F588.10309@oracle.com>
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1392068676-30627-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5306942C.2070902@gmail.com>
 <5306c629.012ce50a.6c48.ffff9844SMTPIN_ADDED_BROKEN@mx.google.com>
 <5306F588.10309@oracle.com>
Subject: Re: [PATCH 01/11] pagewalk: update page table walker core
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sasha.levin@oracle.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mpm@selenic.com, cpw@sgi.com, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, xemul@parallels.com, riel@redhat.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

On Fri, Feb 21, 2014 at 01:43:20AM -0500, Sasha Levin wrote:
> On 02/20/2014 10:20 PM, Naoya Horiguchi wrote:
> > Hi Sasha,
> > 
> > On Thu, Feb 20, 2014 at 06:47:56PM -0500, Sasha Levin wrote:
> >> Hi Naoya,
> >>
> >> This patch seems to trigger a NULL ptr deref here. I didn't have a change to look into it yet
> >> but here's the spew:
> > 
> > Thanks for reporting.
> > I'm not sure what caused this bug from the kernel message. But in my guessing,
> > it seems that the NULL pointer is deep inside lockdep routine __lock_acquire(),
> > so if we find out which pointer was NULL, it might be useful to bisect which
> > the proble is (page table walker or lockdep, or both.)
> 
> This actually points to walk_pte_range() trying to lock a NULL spinlock. It happens when we call
> pte_offset_map_lock() and get a NULL ptl out of pte_lockptr().

I don't think page->ptl was NULL, because if so we hit NULL pointer dereference
outside __lock_acquire() (it's derefered in __raw_spin_lock()).
Maybe page->ptl->lock_dep was NULL. I'll digging it more to find out how we failed
to set this lock_dep thing.

> > BTW, just from curiousity, in my build environment many of kernel functions
> > are inlined, so should not be shown in kernel message. But in your report
> > we can see the symbols like walk_pte_range() and __lock_acquire() which never
> > appear in my kernel. How did you do it? I turned off CONFIG_OPTIMIZE_INLINING,
> > but didn't make it.
> 
> I'm really not sure. I've got a bunch of debug options enabled and it just seems to do the trick.
> 
> Try CONFIG_READABLE_ASM maybe?

Hmm, it makes no change, can I have your config?

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
