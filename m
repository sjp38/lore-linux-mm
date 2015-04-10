Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 85FB16B0038
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 16:39:01 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so32106295pac.1
        for <linux-mm@kvack.org>; Fri, 10 Apr 2015 13:39:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gu11si4448813pbd.78.2015.04.10.13.39.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Apr 2015 13:39:00 -0700 (PDT)
Date: Fri, 10 Apr 2015 13:38:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlb: use pmd_page() in follow_huge_pmd()
Message-Id: <20150410133859.fc79985a9514eb1e4d1dcde7@linux-foundation.org>
In-Reply-To: <20150410100849.56b9d677@thinkpad>
References: <1428595895-24140-1-git-send-email-gerald.schaefer@de.ibm.com>
	<alpine.DEB.2.10.1504091235500.11370@chino.kir.corp.google.com>
	<20150410100849.56b9d677@thinkpad>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Jiri Slaby <jslaby@suse.cz>

On Fri, 10 Apr 2015 10:08:49 +0200 Gerald Schaefer <gerald.schaefer@de.ibm.com> wrote:

> On Thu, 9 Apr 2015 12:41:47 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > On Thu, 9 Apr 2015, Gerald Schaefer wrote:
> > 
> > > commit 61f77eda "mm/hugetlb: reduce arch dependent code around
> > > follow_huge_*" broke follow_huge_pmd() on s390, where pmd and pte
> > > layout differ and using pte_page() on a huge pmd will return wrong
> > > results. Using pmd_page() instead fixes this.
> > > 
> > > All architectures that were touched by commit 61f77eda have
> > > pmd_page() defined, so this should not break anything on other
> > > architectures.
> > > 
> > > Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> > > Cc: stable@vger.kernel.org # v3.12
> > 
> > Acked-by: David Rientjes <rientjes@google.com>
> > 
> > I'm not sure where the stable cc came from, though: commit 61f77eda
> > makes s390 use a generic version of follow_huge_pmd() and that
> > generic version is buggy for s930 because of commit e66f17ff7177
> > ("mm/hugetlb: take page table lock in follow_huge_pmd()").  Both of
> > those are 4.0 material, though, so why is this needed for stable 3.12?
> 
> Both commits 61f77eda and e66f17ff already made it into the 3.12 stable
> tree, probably because of SLES 12 (actually that's how I noticed them).
> 
> But I guess I screwed up the stable CC, stable@vger.kernel.org.#.v3.12
> somehow doesn't look right, not sure if the CC in the patch header
> suffices. Looks like Jiri Slaby added the patches to 3.12, putting him
> on CC now.

hm.  I think I'll make it

Fixes: 61f77eda "mm/hugetlb: reduce arch dependent code around follow_huge_*"
...
Cc: <stable@vger.kernel.org>

There's enough info here for the various tree maintainers to work out
whether their kernel needs this fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
