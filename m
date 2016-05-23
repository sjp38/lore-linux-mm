Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55C266B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 17:49:49 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 77so384036235pfz.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 14:49:49 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id nw12si13084632pab.179.2016.05.23.14.49.48
        for <linux-mm@kvack.org>;
        Mon, 23 May 2016 14:49:48 -0700 (PDT)
Date: Tue, 24 May 2016 00:49:42 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 3/3] mm, thp: make swapin readahead under down_read of
 mmap_sem
Message-ID: <20160523214942.GA79646@black.fi.intel.com>
References: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
 <1464023651-19420-4-git-send-email-ebru.akagunduz@gmail.com>
 <20160523184246.GE32715@dhcp22.suse.cz>
 <1464029349.16365.58.camel@redhat.com>
 <20160523190154.GA79357@black.fi.intel.com>
 <1464031607.16365.60.camel@redhat.com>
 <20160523200244.GA4289@node.shutemov.name>
 <1464034383.16365.70.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1464034383.16365.70.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, hughd@google.com, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, boaz@plexistor.com

On Mon, May 23, 2016 at 04:13:03PM -0400, Rik van Riel wrote:
> On Mon, 2016-05-23 at 23:02 +0300, Kirill A. Shutemov wrote:
> > On Mon, May 23, 2016 at 03:26:47PM -0400, Rik van Riel wrote:
> > > 
> > > On Mon, 2016-05-23 at 22:01 +0300, Kirill A. Shutemov wrote:
> > > > 
> > > > On Mon, May 23, 2016 at 02:49:09PM -0400, Rik van Riel wrote:
> > > > > 
> > > > > 
> > > > > On Mon, 2016-05-23 at 20:42 +0200, Michal Hocko wrote:
> > > > > > 
> > > > > > 
> > > > > > On Mon 23-05-16 20:14:11, Ebru Akagunduz wrote:
> > > > > > > 
> > > > > > > 
> > > > > > > 
> > > > > > > Currently khugepaged makes swapin readahead under
> > > > > > > down_write. This patch supplies to make swapin
> > > > > > > readahead under down_read instead of down_write.
> > > > > > You are still keeping down_write. Can we do without it
> > > > > > altogether?
> > > > > > Blocking mmap_sem of a remote proces for write is certainly
> > > > > > not
> > > > > > nice.
> > > > > Maybe Andrea can explain why khugepaged requires
> > > > > a down_write of mmap_sem?
> > > > > 
> > > > > If it were possible to have just down_read that
> > > > > would make the code a lot simpler.
> > > > You need a down_write() to retract page table. We need to make
> > > > sure
> > > > that
> > > > nobody sees the page table before we can replace it with huge
> > > > pmd.
> > > Good point.
> > > 
> > > I guess the alternative is to have the page_table_lock
> > > taken by a helper function (everywhere) that can return
> > > failure if the page table was changed while the caller
> > > was waiting for the lock.
> > Not page table was changed, but pmd is now pointing to something
> > else.
> > Basically, we would need to nest all pte-ptl's within pmd_lock().
> > That's not good for scalability.
> 
> I can see a few alternatives here:
> 
> 1) huge pmd collapsing takes both the pmd lock and the pte lock,
>    preventing pte updates from happening simultaneously

That's what we do now and that's not enough.

We would need to serialize against pmd_lock() during normal page-fault
path (and other pte manipulation), which we don't do now if pmd points to
page table.

That's huge hit on scalability.

> 
> 2) code that (re-)acquires the pte lock can read a sequence number
>    at the pmd level, check that it did not change after the
>    pte lock has been acquired, and abort if it has - I believe most
>    of the code that re-acquires the pte lock already knows how to
>    abort if somebody else touched the pte while it was looking
>    elsewhere

So, every pmd_lock() (and other means we take the lock) should bump the
sequence number and we need to be able to read stable result  outside
pmd_lock(), meaning it should be atomic_t or something similar.

Not exactly free.

And I'm not convinced the hassle worth the gain.

> That way the (uncommon) thp collapse code should still exclude
> pte level operations, at the cost of potentially teaching a few
> more pte level operations to abort (chances are most already do,
> considering a race with other pte-level manipulations requires that).

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
