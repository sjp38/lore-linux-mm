Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 805A36B005D
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 18:38:23 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1DNcKaW024560
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 14 Feb 2009 08:38:21 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AC9C12AEA81
	for <linux-mm@kvack.org>; Sat, 14 Feb 2009 08:38:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B8991EF083
	for <linux-mm@kvack.org>; Sat, 14 Feb 2009 08:38:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7492EE08004
	for <linux-mm@kvack.org>; Sat, 14 Feb 2009 08:38:17 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FC62E08002
	for <linux-mm@kvack.org>; Sat, 14 Feb 2009 08:38:17 +0900 (JST)
Message-ID: <2d734ee52c2801a284a4c8fa2d76dc49.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090213142032.09b4a4da.akpm@linux-foundation.org>
References: <20090212161920.deedea35.kamezawa.hiroyu@jp.fujitsu.com>
    <20090212162203.db3f07cb.kamezawa.hiroyu@jp.fujitsu.com>
    <20090213142032.09b4a4da.akpm@linux-foundation.org>
Date: Sat, 14 Feb 2009 08:38:16 +0900 (JST)
Subject: Re: [PATCH 1/2] clean up for early_pfn_to_nid
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, davem@davemlloft.net, heiko.carstens@de.ibm.com, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 12 Feb 2009 16:22:03 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> Declaration of early_pfn_to_nid() is scattered over per-arch include
>> files,
>> and it seems it's complicated to know when the declaration is used.
>> I think it makes fix-for-memmap-init not easy.
>>
>> This patch moves all declaration to include/linux/mm.h
>>
>> After this,
>>   if !CONFIG_NODES_POPULATES_NODE_MAP &&
>> !CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
>>      -> Use static definition in include/linux/mm.h
>>   else if !CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
>>      -> Use generic definition in mm/page_alloc.c
>>   else
>>      -> per-arch back end function will be called.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> ---
>>  arch/ia64/include/asm/mmzone.h   |    4 ----
>>  arch/ia64/mm/numa.c              |    2 +-
>>  arch/x86/include/asm/mmzone_32.h |    2 --
>>  arch/x86/include/asm/mmzone_64.h |    2 --
>>  arch/x86/mm/numa_64.c            |    2 +-
>>  include/linux/mm.h               |   19 ++++++++++++++++---
>>  mm/page_alloc.c                  |    8 +++++++-
>>  7 files changed, 25 insertions(+), 14 deletions(-)
>
> It's rather unfortunate that this bugfix includes a fair-sized cleanup
> patch, because we should backport it into 2.6.28.x.
>
> Oh well.
>
Sorry..but this part was too ugly to write a patch that convince me
this patch is correct. If I should rewrite, I'll do.

> I queued these as
>
> mm-clean-up-for-early_pfn_to_nid.patch
> mm-fix-memmap-init-for-handling-memory-hole.patch
>
> and tagged them as needed-in-2.6.28.x.  I don't recall whether they are
> needed in earlier -stable releases?
>
Maybe necessary for some machines, which may access memory holes.

> I don't have a record here of davem having tested these new patches, btw
> ;)
Sorry for bad CC.
This fix's logic itself is not different from original one.

-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
