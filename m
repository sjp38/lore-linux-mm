Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA2C08E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 09:04:01 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w142-v6so1504598qkw.8
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 06:04:01 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g24-v6si737899qvg.205.2018.09.12.06.04.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 06:04:00 -0700 (PDT)
Date: Wed, 12 Sep 2018 09:03:55 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v2] mm: mprotect: check page dirty when change ptes
Message-ID: <20180912130355.GA4009@redhat.com>
References: <20180912064921.31015-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180912064921.31015-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Khalid Aziz <khalid.aziz@oracle.com>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andi Kleen <ak@linux.intel.com>, Henry Willard <henry.willard@oracle.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-mm@kvack.org

On Wed, Sep 12, 2018 at 02:49:21PM +0800, Peter Xu wrote:
> Add an extra check on page dirty bit in change_pte_range() since there
> might be case where PTE dirty bit is unset but it's actually dirtied.
> One example is when a huge PMD is splitted after written: the dirty bit
> will be set on the compound page however we won't have the dirty bit set
> on each of the small page PTEs.
> 
> I noticed this when debugging with a customized kernel that implemented
> userfaultfd write-protect.  In that case, the dirty bit will be critical
> since that's required for userspace to handle the write protect page
> fault (otherwise it'll get a SIGBUS with a loop of page faults).
> However it should still be good even for upstream Linux to cover more
> scenarios where we shouldn't need to do extra page faults on the small
> pages if the previous huge page is already written, so the dirty bit
> optimization path underneath can cover more.
> 

So as said by Kirill NAK you are not looking at the right place for
your bug please first apply the below patch and read my analysis in
my last reply.

Below patch fix userfaultfd bug. I am not posting it as it is on a
branch and i am not sure when Andrea plan to post. Andrea feel free
to squash that fix.
