Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 20A19831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 09:20:12 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id j27so11729096wre.3
        for <linux-mm@kvack.org>; Mon, 22 May 2017 06:20:12 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 199si19998992wms.154.2017.05.22.06.20.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 06:20:10 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id d127so33197605wmf.1
        for <linux-mm@kvack.org>; Mon, 22 May 2017 06:20:10 -0700 (PDT)
Date: Mon, 22 May 2017 16:12:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/mm: pgds getting out of sync after memory hot remove
Message-ID: <20170522131215.wrnklp4dtemntixz@node.shutemov.name>
References: <1495216887-3175-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1495216887-3175-1-git-send-email-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>

On Fri, May 19, 2017 at 02:01:26PM -0400, Jerome Glisse wrote:
> After memory hot remove it seems we do not synchronize pgds for kernel
> virtual memory range (on vmemmap_free()). This seems bogus to me as it
> means we are left with stall entry for process with mm != mm_init
> 
> Yet i am puzzle by the fact that i am only now hitting this issue. It
> never was an issue with 4.12 or before ie HMM never triggered following
> BUG_ON inside sync_global_pgds():
> 
> if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))
>    BUG_ON(p4d_page_vaddr(*p4d) != p4d_page_vaddr(*p4d_ref));
> 
> 
> It seems that Kirill 5 level page table changes play a role in this
> behavior change. I could not bisect because HMM is painfull to rebase
> for each bisection step so that is just my best guess.
> 
> 
> Am i missing something here ? Am i wrong in assuming that should sync
> pgd on vmemmap_free() ? If so anyone have a good guess on why i am now
> seeing the above BUG_ON ?

What would we gain by syncing pgd on free? Stale pgds are fine as long as
they are not referenced (use-after-free case). Syncing is addtional work.

See af2cf278ef4f ("x86/mm/hotplug: Don't remove PGD entries in remove_pagetable()")
and 5372e155a28f ("x86/mm: Drop unused argument 'removed' from sync_global_pgds()").

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
