Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8AAB56B0078
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 17:47:45 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o8FLlfK8027202
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 14:47:41 -0700
Received: from vws9 (vws9.prod.google.com [10.241.21.137])
	by wpaz5.hot.corp.google.com with ESMTP id o8FLldt6006236
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 14:47:40 -0700
Received: by vws9 with SMTP id 9so441491vws.20
        for <linux-mm@kvack.org>; Wed, 15 Sep 2010 14:47:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1284579969.21906.451.camel@calx>
References: <20100915134724.C9EE.A69D9226@jp.fujitsu.com>
	<201009151034.22497.knikanth@suse.de>
	<20100915141710.C9F7.A69D9226@jp.fujitsu.com>
	<201009151201.11359.knikanth@suse.de>
	<20100915140911.GC4383@balbir.in.ibm.com>
	<alpine.LNX.2.00.1009151612450.28912@zhemvz.fhfr.qr>
	<1284561982.21906.280.camel@calx>
	<alpine.LNX.2.00.1009151648390.28912@zhemvz.fhfr.qr>
	<1284571473.21906.428.camel@calx>
	<AANLkTimYQgm6nKZ4TantPiL4kmUP9FtMQwzqeetVnGrr@mail.gmail.com>
	<1284579969.21906.451.camel@calx>
Date: Wed, 15 Sep 2010 14:47:39 -0700
Message-ID: <AANLkTini3k1hK-9RM6io0mOf4VoDzGpbUEpiv=WHfhEW@mail.gmail.com>
Subject: Re: [PATCH v2] After swapout/swapin private dirty mappings are
 reported clean in smaps
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Richard Guenther <rguenther@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, Nikanth Karthikesan <knikanth@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Matz <matz@novell.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 15, 2010 at 12:46 PM, Matt Mackall <mpm@selenic.com> wrote:
> On Wed, 2010-09-15 at 12:18 -0700, Hugh Dickins wrote:
>> The problem is that /proc/pid/smaps exports a simplified view of the
>> VM, and Richard and Nikanth were hoping that it gave them some info
>> which it has never pretended to give them,
>>
>> It happens to use a pte_dirty(ptent) test: you could argue that that
>> should be pte_dirty(ptent) || PageDirty(page) (which would then "fix
>> the issue" which Richard sees with swapoff/swapon),
>
> That might be interesting. Are there any other notable cases where
> pte_dirty() differs from PageDirty()?

I don't know about "other notable".  A page may very well be PageDirty
(e.g. modified by a write system call) without any of the ptes
pointing to it (if there even are any) marked as pte_dirty.  A page
may very well not be marked PageDirty yet, though one or more of the
ptes pointing to it have been marked pte_dirty when userspace made a
write access to the page via that pte.   Traditionally (when
/proc/pid/smaps was first reporting dirty versus clean ptes) the pte
dirtiness would later be found and propagated through to PageDirtiness
(clearing the pte dirtiness), which would later be cleaned when the
page was written out to backing store (file or swap).

PeterZ's writeback work in 2.6.19 (set_page_dirty_balance,
clear_page_dirty_for_io etc.) tightened up writeback from (most: tmpfs
is one exception) shared file mmaps, synchronizing the PageDirty more
carefully with the pte_dirty; and perhaps there is some inconsistency
there, that we never felt compelled to keep pte and Page so tightly in
synch in the anonymous/Swap case - it would have been unnecessary
overhead (though I repeatedly forget the essence of why not - file
syncing, and pdflush activity,  were relevant considerations; but I
cannot now put my finger on precisely why shared file writing needed
to be fixed, but anonymous dirtying could be left unchanged).

But even if you replace smaps's pte_dirty(ptent) tests by
pte_dirty(ptent) || PageDirty(page) tests, it wouldn't be doing what
Richard and Nikanth want - they want clean ptes of clean PageSwapCache
to be reported as dirty, despite being clean copies of backing store;
and I can understand your reluctance to go that far.  I think
reporting "Anon:" pages is more useful - in part because we have no
counts of Anon+Swap, yet that's the quantity which vm_enough_memory
may place a limit upon (but beware, it does of course get more
complicated: tmpfs files come out of that tally too, but would not
show up in this way).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
