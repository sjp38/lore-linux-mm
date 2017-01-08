Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A01BE6B0069
	for <linux-mm@kvack.org>; Sun,  8 Jan 2017 15:21:26 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id b22so608455813pfd.0
        for <linux-mm@kvack.org>; Sun, 08 Jan 2017 12:21:26 -0800 (PST)
Received: from mail-pg0-x232.google.com (mail-pg0-x232.google.com. [2607:f8b0:400e:c05::232])
        by mx.google.com with ESMTPS id r2si54990199pli.327.2017.01.08.12.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Jan 2017 12:21:25 -0800 (PST)
Received: by mail-pg0-x232.google.com with SMTP id f188so268265348pgc.3
        for <linux-mm@kvack.org>; Sun, 08 Jan 2017 12:21:25 -0800 (PST)
Date: Sun, 8 Jan 2017 12:21:16 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: stop leaking PageTables
In-Reply-To: <87mvf2kpfa.fsf@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.11.1701081209550.3615@eggly.anvils>
References: <alpine.LSU.2.11.1701071526090.1130@eggly.anvils> <87mvf2kpfa.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Sun, 8 Jan 2017, Aneesh Kumar K.V wrote:
> Hugh Dickins <hughd@google.com> writes:
> 
> > And fix a separate pagetable leak, or crash, introduced by the same
> > change, that could only show up on some ppc64: why does do_set_pmd()'s
> > failure case attempt to withdraw a pagetable when it never deposited
> > one, at the same time overwriting (so leaking) the vmf->prealloc_pte?
> > Residue of an earlier implementation, perhaps?  Delete it.
> 
> That change is part of -mm tree.
> 
> https://lkml.kernel.org/r/20161212163428.6780-1-aneesh.kumar@linux.vnet.ibm.com

Ah, so it is, I hadn't looked there.  That's reassuring,
I'm glad to know you reached the same conclusion on that piece of code.

It still worried me that the fix is languishing in mmotm, but it looks
not lost: akpm would have sent it in a couple of days anyway, and only
affected ppc64 (like the related khugepaged patch you have queued there).

> 
> >
> > Fixes: 953c66c2b22a ("mm: THP page cache support for ppc64")
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> 
> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Thanks, and to Linus, who already has this in for -rc3: so akpm can drop
mm-thp-pagecache-only-withdraw-page-table-after-a-successful-deposit.patch
and then later send in your
mm-thp-pagecache-collapse-free-the-pte-page-table-on-collapse-for-thp-page-cache.patch

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
