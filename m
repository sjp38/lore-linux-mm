Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 1C7476B00FA
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 09:46:25 -0400 (EDT)
Date: Fri, 5 Apr 2013 13:46:23 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCHv2, RFC 20/30] ramfs: enable transparent huge page cache
In-Reply-To: <20130405083112.GD32126@blaptop>
Message-ID: <0000013dda72b161-378f03f8-2ed6-4a03-81e5-104df52a67f1-000000@email.amazonses.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-21-git-send-email-kirill.shutemov@linux.intel.com> <20130402162813.0B4CBE0085@blue.fi.intel.com> <alpine.LNX.2.00.1304021422460.19363@eggly.anvils>
 <20130403011104.GF16026@blaptop> <515E737D.8030204@gmail.com> <20130405080106.GB32126@blaptop> <515e89d2.e725320a.3a74.7fe7SMTPIN_ADDED_BROKEN@mx.google.com> <20130405083112.GD32126@blaptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Ying Han <yinghan@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 5 Apr 2013, Minchan Kim wrote:

> > >> How about add a knob?
> > >
> > >Maybe, volunteering?
> >
> > Hi Minchan,
> >
> > I can be the volunteer, what I care is if add a knob make sense?
>
> Frankly sepaking, I'd like to avoid new knob but there might be
> some workloads suffered from mlocked page migration so we coudn't
> dismiss it. In such case, introducing the knob would be a solution
> with default enabling. If we don't have any report for a long time,
> we can remove the knob someday, IMHO.

No Knob please. A new implementation for page pinning that avoids the
mlock crap.

1. It should be available for device drivers to pin their memory (they are
now elevating the ref counter which means page migration will have to see
if it can account for all references before giving up and it does that
quite frequently). So there needs to be an in kernel API, a syscall API as
well as a command line one. Preferably as similar as possible.

2. A sane API for marking pages as mlocked. Maybe part of MMAP? I hate the
command line tools and the APIs for doing that right now.

3. The reservation scheme for mlock via ulimit is broken. We have per
process constraints only it seems. If you start enough processes you can
still make the kernel go OOM.

4. mlock semantics are prescribed by posix which states that the page
stays in memory. I think we should stay with that narrow definition for
mlock.

5. Pinning could also mean that page faults on the page are to be avoided.
COW could occur on fork and page table entries could be instantated at
mmap/fork time. Pinning could mean that minor/major faults will not occur
on a page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
