Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 719A66B025E
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 20:01:01 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id x3so92142949pfb.1
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 17:01:01 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id vz3si10141012pab.93.2016.03.25.17.01.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Mar 2016 17:01:00 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id u190so92370527pfb.3
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 17:01:00 -0700 (PDT)
Date: Fri, 25 Mar 2016 17:00:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCHv4 00/25] THP-enabled tmpfs/shmem
In-Reply-To: <20160325150417.GA1851@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1603251635490.1115@eggly.anvils>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com> <alpine.LSU.2.11.1603231305560.4946@eggly.anvils> <20160324091727.GA26796@node.shutemov.name> <alpine.LSU.2.11.1603241153120.1593@eggly.anvils>
 <20160325150417.GA1851@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri, 25 Mar 2016, Kirill A. Shutemov wrote:
> On Thu, Mar 24, 2016 at 12:08:55PM -0700, Hugh Dickins wrote:
> > On Thu, 24 Mar 2016, Kirill A. Shutemov wrote:
> > > On Wed, Mar 23, 2016 at 01:09:05PM -0700, Hugh Dickins wrote:
> > > > The small files thing formed my first impression.  My second
> > > > impression was similar, when I tried mmap(NULL, size_of_RAM,
> > > > PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_SHARED, -1, 0) and
> > > > cycled around the arena touching all the pages (which of
> > > > course has to push a little into swap): that soon OOMed.
> > > > 
> > > > But there I think you probably just have some minor bug to be fixed:
> > > > I spent a little while trying to debug it, but then decided I'd
> > > > better get back to writing to you.  I didn't really understand what
> > > > I was seeing, but when I hacked some stats into shrink_page_list(),
> > > > converting !is_page_cache_freeable(page) to page_cache_references(page)
> > > > to return the difference instead of the bool, a large proportion of
> > > > huge tmpfs pages seemed to have count 1 too high to be freeable at
> > > > that point (and one huge tmpfs page had a count of 3477).
> > > 
> > > I'll reply to your other points later, but first I wanted to address this
> > > obvious bug.
> > 
> > Thanks.  That works better, but is not yet right: memory isn't freed
> > as it should be, so when I exit then try to run a second time, the
> > mmap() just gets ENOMEM (with /proc/sys/vm/overcommit_memory 0):
> > MemFree is low.  No rush to fix, I've other stuff to do.
> > 
> > I don't get as far as that on the laptop, since the first run is OOM
> > killed while swapping; but I can't vouch for the OOM-kill-correctness
> > of the base tree I'm using, and this laptop has a history of OOMing
> > rather too easily if all's not right.
> 
> Hm. I don't see the issue.
> 
> I tried to reproduce it in my VM with following script:
> 
> #!/bin/sh -efu
> 
> swapon -a
> 
> ram="$(grep MemTotal /proc/meminfo | sed 's,[^0-9\]\+,,; s, kB,k,')"
> 
> usemem -w -f /dev/zero "$ram"
> 
> swapoff -a
> swapon -a
> 
> usemem -w -f /dev/zero "$ram"
> 
> cat /proc/meminfo
> grep thp /proc/vmstat
> 
> -----
> 
> usemem is a tool from this archive:
> 
> http://www.spinics.net/lists/linux-mm/attachments/gtarazbJaHPaAT.gtar
> 
> It works fine even if would double size of mapping.
> 
> Do you have a reproducer?

Yes, my reproducer is simpler (just cycling twice around the arena,
touching each page in order); and I too did not see it running your
script using usemem above.  It looks as if that invocation isn't doing
enough work with swap: if I add a "-r 2" to those usemem lines, then
I get "usemem: mmap failed: Cannot allocate memory" on the second.

I also added a "sleep 2" before the second call to usemem: I'm not sure
of the current state of vmstat, but historically it's slow to gather
back from each cpu to global, and I think it used to leave some cpu
counts stranded indefinitely once upon a time.  In my own testing,
I have a /proc/sys/vm/stat_refresh to touch before checking meminfo
or vmstat - and I think the vm_enough_memory() check in mmap() may
need that same care, since it refers to NR_FREE_PAGES etc.

8GB is my ramsize, if that matters.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
