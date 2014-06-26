Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 98C406B00A1
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 15:56:59 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id y20so3502883ier.40
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 12:56:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id v8si13001112icx.92.2014.06.26.12.56.58
        for <linux-mm@kvack.org>;
        Thu, 26 Jun 2014 12:56:58 -0700 (PDT)
Date: Thu, 26 Jun 2014 12:56:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hwpoison: Fix race with changing page during offlining
Message-Id: <20140626125657.f1830a0b399cbe5a97071206@linux-foundation.org>
In-Reply-To: <20140626195036.GA5311@nhori.redhat.com>
References: <1403806972-14267-1-git-send-email-andi@firstfloor.org>
	<20140626195036.GA5311@nhori.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, tony.luck@intel.com, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, dave.hansen@linux.intel.com, Chen Yucong <slaoub@gmail.com>

On Thu, 26 Jun 2014 15:50:36 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> > index 90002ea..e277726a 100644
> > --- a/mm/memory-failure.c
> > +++ b/mm/memory-failure.c
> > @@ -1143,6 +1143,22 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
> >  	lock_page(hpage);
> >  
> >  	/*
> > +	 * The page could have turned into a non LRU page or
> > +	 * changed compound pages during the locking.
> > +	 * If this happens just bail out.
> > +	 */
> > +	if (compound_head(p) != hpage) {
> > +		action_result(pfn, "different compound page after locking", IGNORED);
> > +		res = -EBUSY;
> > +		goto out;
> > +	}
> 
> This is a useful check.
> 
> > +	if (!PageLRU(hpage)) {
> > +		action_result(pfn, "non LRU after locking", IGNORED);
> > +		res = -EBUSY;
> > +		goto out;
> > +	}
> 
> I think this makes sense in v3.14, but maybe redundant if the patch "hwpoison:
> fix the handling path of the victimized page frame that belong to non-LRU"
> from Chen Yucong is merged into mainline (now it's in linux-mmotm).

Andi, can you please check that and test?  If the patch is good I'll
bump it into 3.16 with an enhanced changelog..


From: Chen Yucong <slaoub@gmail.com>
Subject: hwpoison: fix the handling path of the victimized page frame that belong to non-LRU

Until now, the kernel has the same policy to handle victimized page frames
that belong to kernel-space(reserved/slab-subsystem) or non-LRU(unknown
page state).  In other word, the result of handling either of these
victimized page frames is (IGNORED | FAILED), and the return value of
memory_failure() is -EBUSY.

This patch is to avoid that memory_failure() returns very soon due to the
"true" value of (!PageLRU(p)), and it also ensures that action_result()
can report more precise information("reserved kernel", "kernel slab", and
"unknown page state") instead of "non LRU", especially for memory errors
which are detected by memory-scrubbing.

Signed-off-by: Chen Yucong <slaoub@gmail.com>
Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memory-failure.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff -puN mm/memory-failure.c~hwpoison-fix-the-handling-path-of-the-victimized-page-frame-that-belong-to-non-lur mm/memory-failure.c
--- a/mm/memory-failure.c~hwpoison-fix-the-handling-path-of-the-victimized-page-frame-that-belong-to-non-lur
+++ a/mm/memory-failure.c
@@ -895,7 +895,7 @@ static int hwpoison_user_mappings(struct
 	struct page *hpage = *hpagep;
 	struct page *ppage;
 
-	if (PageReserved(p) || PageSlab(p))
+	if (PageReserved(p) || PageSlab(p) || !PageLRU(p))
 		return SWAP_SUCCESS;
 
 	/*
@@ -1159,9 +1159,6 @@ int memory_failure(unsigned long pfn, in
 					action_result(pfn, "free buddy, 2nd try", DELAYED);
 				return 0;
 			}
-			action_result(pfn, "non LRU", IGNORED);
-			put_page(p);
-			return -EBUSY;
 		}
 	}
 
@@ -1194,6 +1191,9 @@ int memory_failure(unsigned long pfn, in
 		return 0;
 	}
 
+	if (!PageHuge(p) && !PageTransTail(p) && !PageLRU(p))
+		goto identify_page_state;
+
 	/*
 	 * For error on the tail page, we should set PG_hwpoison
 	 * on the head page to show that the hugepage is hwpoisoned
@@ -1243,6 +1243,7 @@ int memory_failure(unsigned long pfn, in
 		goto out;
 	}
 
+identify_page_state:
 	res = -EBUSY;
 	/*
 	 * The first check uses the current page flags which may not have any
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
