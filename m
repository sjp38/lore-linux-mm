Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 113A06B007E
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 11:04:21 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id l68so28371241wml.0
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 08:04:21 -0700 (PDT)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id vu8si14792272wjc.28.2016.03.25.08.04.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Mar 2016 08:04:19 -0700 (PDT)
Received: by mail-wm0-x233.google.com with SMTP id l68so21358386wml.0
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 08:04:19 -0700 (PDT)
Date: Fri, 25 Mar 2016 18:04:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 00/25] THP-enabled tmpfs/shmem
Message-ID: <20160325150417.GA1851@node.shutemov.name>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1603231305560.4946@eggly.anvils>
 <20160324091727.GA26796@node.shutemov.name>
 <alpine.LSU.2.11.1603241153120.1593@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1603241153120.1593@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, Mar 24, 2016 at 12:08:55PM -0700, Hugh Dickins wrote:
> On Thu, 24 Mar 2016, Kirill A. Shutemov wrote:
> > On Wed, Mar 23, 2016 at 01:09:05PM -0700, Hugh Dickins wrote:
> > > The small files thing formed my first impression.  My second
> > > impression was similar, when I tried mmap(NULL, size_of_RAM,
> > > PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_SHARED, -1, 0) and
> > > cycled around the arena touching all the pages (which of
> > > course has to push a little into swap): that soon OOMed.
> > > 
> > > But there I think you probably just have some minor bug to be fixed:
> > > I spent a little while trying to debug it, but then decided I'd
> > > better get back to writing to you.  I didn't really understand what
> > > I was seeing, but when I hacked some stats into shrink_page_list(),
> > > converting !is_page_cache_freeable(page) to page_cache_references(page)
> > > to return the difference instead of the bool, a large proportion of
> > > huge tmpfs pages seemed to have count 1 too high to be freeable at
> > > that point (and one huge tmpfs page had a count of 3477).
> > 
> > I'll reply to your other points later, but first I wanted to address this
> > obvious bug.
> 
> Thanks.  That works better, but is not yet right: memory isn't freed
> as it should be, so when I exit then try to run a second time, the
> mmap() just gets ENOMEM (with /proc/sys/vm/overcommit_memory 0):
> MemFree is low.  No rush to fix, I've other stuff to do.
> 
> I don't get as far as that on the laptop, since the first run is OOM
> killed while swapping; but I can't vouch for the OOM-kill-correctness
> of the base tree I'm using, and this laptop has a history of OOMing
> rather too easily if all's not right.

Hm. I don't see the issue.

I tried to reproduce it in my VM with following script:

#!/bin/sh -efu

swapon -a

ram="$(grep MemTotal /proc/meminfo | sed 's,[^0-9\]\+,,; s, kB,k,')"

usemem -w -f /dev/zero "$ram"

swapoff -a
swapon -a

usemem -w -f /dev/zero "$ram"

cat /proc/meminfo
grep thp /proc/vmstat

-----

usemem is a tool from this archive:

http://www.spinics.net/lists/linux-mm/attachments/gtarazbJaHPaAT.gtar

It works fine even if would double size of mapping.

Do you have a reproducer?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
