Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B189C6B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 07:13:11 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 31so7993170wrr.2
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 04:13:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d12sor2137598edo.0.2018.04.10.04.13.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 04:13:10 -0700 (PDT)
Date: Tue, 10 Apr 2018 14:12:22 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH -mm] mm, pagemap: Fix swap offset value for PMD migration
 entry
Message-ID: <20180410111222.akgtbqsmrpmm2clt@node.shutemov.name>
References: <20180408033737.10897-1-ying.huang@intel.com>
 <20180409174753.4b959a5b3ff732b8f96f5a14@linux-foundation.org>
 <87in8znaj4.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87in8znaj4.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrei Vagin <avagin@openvz.org>, Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, Daniel Colascione <dancol@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Tue, Apr 10, 2018 at 08:57:19AM +0800, Huang, Ying wrote:
> >> the swap offset reported doesn't
> >> reflect this.  And in the loop to report information of each sub-page,
> >> the swap offset isn't increased accordingly as that for PFN.
> >> 
> >> BTW: migration swap entries have PFN information, do we need to
> >> restrict whether to show them?
> >
> > For what reason?  Address obfuscation?
> 
> This is an existing feature for PFN report of /proc/<pid>/pagemap,
> reason is in following commit log.  I am wondering whether that is
> necessary for migration swap entries too.
> 
> ab676b7d6fbf4b294bf198fb27ade5b0e865c7ce
> Author:     Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> AuthorDate: Mon Mar 9 23:11:12 2015 +0200
> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Tue Mar 17 09:31:30 2015 -0700
> 
> pagemap: do not leak physical addresses to non-privileged userspace
> 
> As pointed by recent post[1] on exploiting DRAM physical imperfection,
> /proc/PID/pagemap exposes sensitive information which can be used to do
> attacks.
> 
> This disallows anybody without CAP_SYS_ADMIN to read the pagemap.
> 
> [1] http://googleprojectzero.blogspot.com/2015/03/exploiting-dram-rowhammer-bug-to-gain.html
> 
> [ Eventually we might want to do anything more finegrained, but for now
>   this is the simple model.   - Linus ]

Note that there's follow up to the commit: 

1c90308e7a77 ("pagemap: hide physical addresses from non-privileged users")

It introduces pm->show_pfn and it should be applied to swap entries too.

-- 
 Kirill A. Shutemov
