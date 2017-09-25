Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD816B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 09:53:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 188so16340462pgb.3
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 06:53:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w2si4148628pgb.564.2017.09.25.06.53.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Sep 2017 06:53:09 -0700 (PDT)
Date: Mon, 25 Sep 2017 15:53:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv2] mm: Account pud page tables
Message-ID: <20170925135305.ydeeyapav2s36ifj@dhcp22.suse.cz>
References: <20170925073913.22628-1-kirill.shutemov@linux.intel.com>
 <20170925115430.zccesf75c4ysaznb@dhcp22.suse.cz>
 <20170925130715.kebf5e3xjctpcalp@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925130715.kebf5e3xjctpcalp@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Mon 25-09-17 16:07:15, Kirill A. Shutemov wrote:
> On Mon, Sep 25, 2017 at 01:54:30PM +0200, Michal Hocko wrote:
> > On Mon 25-09-17 10:39:13, Kirill A. Shutemov wrote:
> > > On machine with 5-level paging support a process can allocate
> > > significant amount of memory and stay unnoticed by oom-killer and
> > > memory cgroup. The trick is to allocate a lot of PUD page tables.
> > > We don't account PUD page tables, only PMD and PTE.
> > > 
> > > We already addressed the same issue for PMD page tables, see
> > > dc6c9a35b66b ("mm: account pmd page tables to the process").
> > > Introduction 5-level paging bring the same issue for PUD page tables.
> > > 
> > > The patch expands accounting to PUD level.
> > 
> > OK, we definitely need this or something like that but I really do not
> > like how much code we actually need for each pte level for accounting.
> > Do we really need to distinguish each level? Do we have any arch that
> > would use a different number of pages to back pte/pmd/pud?
> 
> Looks like we actually do. At least on mips. See PMD_ORDER/PUD_ORDER.

Hmm, but then oom_badness does consider them a single page which is
wrong. I haven't checked other users. Anyway even if we've had different
sizes why cannot we deal with this in callers. They know which level of
page table they allocate/free, no?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
