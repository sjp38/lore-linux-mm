Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id C3FE06B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 14:00:32 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id 20so26438396wmh.1
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 11:00:32 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id v80si12041321wmv.40.2016.03.28.11.00.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 11:00:31 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id 20so6082818wmh.3
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 11:00:31 -0700 (PDT)
Date: Mon, 28 Mar 2016 21:00:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 00/25] THP-enabled tmpfs/shmem
Message-ID: <20160328180029.GB25200@node.shutemov.name>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1603231305560.4946@eggly.anvils>
 <20160324091727.GA26796@node.shutemov.name>
 <alpine.LSU.2.11.1603241153120.1593@eggly.anvils>
 <20160325150417.GA1851@node.shutemov.name>
 <alpine.LSU.2.11.1603251635490.1115@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1603251635490.1115@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri, Mar 25, 2016 at 05:00:50PM -0700, Hugh Dickins wrote:
> On Fri, 25 Mar 2016, Kirill A. Shutemov wrote:
> > On Thu, Mar 24, 2016 at 12:08:55PM -0700, Hugh Dickins wrote:
> > > On Thu, 24 Mar 2016, Kirill A. Shutemov wrote:
> > > > On Wed, Mar 23, 2016 at 01:09:05PM -0700, Hugh Dickins wrote:
> > > > > The small files thing formed my first impression.  My second
> > > > > impression was similar, when I tried mmap(NULL, size_of_RAM,
> > > > > PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_SHARED, -1, 0) and
> > > > > cycled around the arena touching all the pages (which of
> > > > > course has to push a little into swap): that soon OOMed.
> > > > > 
> > > > > But there I think you probably just have some minor bug to be fixed:
> > > > > I spent a little while trying to debug it, but then decided I'd
> > > > > better get back to writing to you.  I didn't really understand what
> > > > > I was seeing, but when I hacked some stats into shrink_page_list(),
> > > > > converting !is_page_cache_freeable(page) to page_cache_references(page)
> > > > > to return the difference instead of the bool, a large proportion of
> > > > > huge tmpfs pages seemed to have count 1 too high to be freeable at
> > > > > that point (and one huge tmpfs page had a count of 3477).
> > > > 
> > > > I'll reply to your other points later, but first I wanted to address this
> > > > obvious bug.
> > > 
> > > Thanks.  That works better, but is not yet right: memory isn't freed
> > > as it should be, so when I exit then try to run a second time, the
> > > mmap() just gets ENOMEM (with /proc/sys/vm/overcommit_memory 0):
> > > MemFree is low.  No rush to fix, I've other stuff to do.
> > > 
> > > I don't get as far as that on the laptop, since the first run is OOM
> > > killed while swapping; but I can't vouch for the OOM-kill-correctness
> > > of the base tree I'm using, and this laptop has a history of OOMing
> > > rather too easily if all's not right.
> > 
> > Hm. I don't see the issue.
> > 
> > I tried to reproduce it in my VM with following script:
> > 
> > #!/bin/sh -efu
> > 
> > swapon -a
> > 
> > ram="$(grep MemTotal /proc/meminfo | sed 's,[^0-9\]\+,,; s, kB,k,')"
> > 
> > usemem -w -f /dev/zero "$ram"
> > 
> > swapoff -a
> > swapon -a
> > 
> > usemem -w -f /dev/zero "$ram"
> > 
> > cat /proc/meminfo
> > grep thp /proc/vmstat
> > 
> > -----
> > 
> > usemem is a tool from this archive:
> > 
> > http://www.spinics.net/lists/linux-mm/attachments/gtarazbJaHPaAT.gtar
> > 
> > It works fine even if would double size of mapping.
> > 
> > Do you have a reproducer?
> 
> Yes, my reproducer is simpler (just cycling twice around the arena,
> touching each page in order); and I too did not see it running your
> script using usemem above.  It looks as if that invocation isn't doing
> enough work with swap: if I add a "-r 2" to those usemem lines, then
> I get "usemem: mmap failed: Cannot allocate memory" on the second.
> 
> I also added a "sleep 2" before the second call to usemem: I'm not sure
> of the current state of vmstat, but historically it's slow to gather
> back from each cpu to global, and I think it used to leave some cpu
> counts stranded indefinitely once upon a time.  In my own testing,
> I have a /proc/sys/vm/stat_refresh to touch before checking meminfo
> or vmstat - and I think the vm_enough_memory() check in mmap() may
> need that same care, since it refers to NR_FREE_PAGES etc.
> 
> 8GB is my ramsize, if that matters.

I think I found it. I have refcounting screwed up in faultaround.

This should fix the problem:

diff --git a/mm/filemap.c b/mm/filemap.c
index 94c097ec08e7..1325bb4568d1 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2292,19 +2292,18 @@ repeat:
 		if (fe->pte)
 			fe->pte += iter.index - last_pgoff;
 		last_pgoff = iter.index;
-		alloc_set_pte(fe, NULL, page);
+		if (alloc_set_pte(fe, NULL, page))
+			goto unlock;
 		unlock_page(page);
-		/* Huge page is mapped? No need to proceed. */
-		if (pmd_trans_huge(*fe->pmd))
-			break;
-		/* Failed to setup page table? */
-		VM_BUG_ON(!fe->pte);
 		goto next;
 unlock:
 		unlock_page(page);
 skip:
 		page_cache_release(page);
 next:
+		/* Huge page is mapped? No need to proceed. */
+		if (pmd_trans_huge(*fe->pmd))
+			break;
 		if (iter.index == end_pgoff)
 			break;
 	}
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
