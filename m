Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E343C6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 05:43:47 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u138so11358801wmu.2
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 02:43:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n2sor4580352edd.3.2017.09.26.02.43.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Sep 2017 02:43:46 -0700 (PDT)
Date: Tue, 26 Sep 2017 12:43:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2] mm: Account pud page tables
Message-ID: <20170926094344.t4cws4v4vrie5de5@node.shutemov.name>
References: <20170925073913.22628-1-kirill.shutemov@linux.intel.com>
 <20170925115430.zccesf75c4ysaznb@dhcp22.suse.cz>
 <20170925130715.kebf5e3xjctpcalp@node.shutemov.name>
 <20170925135305.ydeeyapav2s36ifj@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925135305.ydeeyapav2s36ifj@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Mon, Sep 25, 2017 at 03:53:05PM +0200, Michal Hocko wrote:
> On Mon 25-09-17 16:07:15, Kirill A. Shutemov wrote:
> > On Mon, Sep 25, 2017 at 01:54:30PM +0200, Michal Hocko wrote:
> > > On Mon 25-09-17 10:39:13, Kirill A. Shutemov wrote:
> > > > On machine with 5-level paging support a process can allocate
> > > > significant amount of memory and stay unnoticed by oom-killer and
> > > > memory cgroup. The trick is to allocate a lot of PUD page tables.
> > > > We don't account PUD page tables, only PMD and PTE.
> > > > 
> > > > We already addressed the same issue for PMD page tables, see
> > > > dc6c9a35b66b ("mm: account pmd page tables to the process").
> > > > Introduction 5-level paging bring the same issue for PUD page tables.
> > > > 
> > > > The patch expands accounting to PUD level.
> > > 
> > > OK, we definitely need this or something like that but I really do not
> > > like how much code we actually need for each pte level for accounting.
> > > Do we really need to distinguish each level? Do we have any arch that
> > > would use a different number of pages to back pte/pmd/pud?
> > 
> > Looks like we actually do. At least on mips. See PMD_ORDER/PUD_ORDER.
> 
> Hmm, but then oom_badness does consider them a single page which is
> wrong. I haven't checked other users. Anyway even if we've had different
> sizes why cannot we deal with this in callers. They know which level of
> page table they allocate/free, no?

So do you want to see single counter for all page table levels?
Do we have anybody who relies on VmPTE/VmPMD now?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
