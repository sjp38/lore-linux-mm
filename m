Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4EF6B0005
	for <linux-mm@kvack.org>; Thu, 24 Mar 2016 15:09:05 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id fe3so29381841pab.1
        for <linux-mm@kvack.org>; Thu, 24 Mar 2016 12:09:05 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id 76si14019872pfb.3.2016.03.24.12.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Mar 2016 12:09:04 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id 4so65270815pfd.0
        for <linux-mm@kvack.org>; Thu, 24 Mar 2016 12:09:04 -0700 (PDT)
Date: Thu, 24 Mar 2016 12:08:55 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCHv4 00/25] THP-enabled tmpfs/shmem
In-Reply-To: <20160324091727.GA26796@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1603241153120.1593@eggly.anvils>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com> <alpine.LSU.2.11.1603231305560.4946@eggly.anvils> <20160324091727.GA26796@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, 24 Mar 2016, Kirill A. Shutemov wrote:
> On Wed, Mar 23, 2016 at 01:09:05PM -0700, Hugh Dickins wrote:
> > The small files thing formed my first impression.  My second
> > impression was similar, when I tried mmap(NULL, size_of_RAM,
> > PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_SHARED, -1, 0) and
> > cycled around the arena touching all the pages (which of
> > course has to push a little into swap): that soon OOMed.
> > 
> > But there I think you probably just have some minor bug to be fixed:
> > I spent a little while trying to debug it, but then decided I'd
> > better get back to writing to you.  I didn't really understand what
> > I was seeing, but when I hacked some stats into shrink_page_list(),
> > converting !is_page_cache_freeable(page) to page_cache_references(page)
> > to return the difference instead of the bool, a large proportion of
> > huge tmpfs pages seemed to have count 1 too high to be freeable at
> > that point (and one huge tmpfs page had a count of 3477).
> 
> I'll reply to your other points later, but first I wanted to address this
> obvious bug.

Thanks.  That works better, but is not yet right: memory isn't freed
as it should be, so when I exit then try to run a second time, the
mmap() just gets ENOMEM (with /proc/sys/vm/overcommit_memory 0):
MemFree is low.  No rush to fix, I've other stuff to do.

I don't get as far as that on the laptop, since the first run is OOM
killed while swapping; but I can't vouch for the OOM-kill-correctness
of the base tree I'm using, and this laptop has a history of OOMing
rather too easily if all's not right.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
