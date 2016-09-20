Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id C9FDF6B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 09:55:43 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id c79so20166973ybf.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 06:55:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l23si12686680ywc.131.2016.09.20.06.55.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 06:55:43 -0700 (PDT)
Date: Tue, 20 Sep 2016 15:55:39 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [xiaolong.ye@intel.com: [mm]  0331ab667f: kernel BUG at
 mm/mmap.c:327!]
Message-ID: <20160920135539.GK4716@redhat.com>
References: <20160920134638.GJ4716@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160920134638.GJ4716@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org

On Tue, Sep 20, 2016 at 03:46:38PM +0200, Andrea Arcangeli wrote:
>  
> -	vma_rb_erase(vma, &mm->mm_rb);
> +	if (has_prev)
> +		vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
> +	else
> +		vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
>  	next = vma->vm_next;
>  	if (has_prev)

Once this is confirmed as false positive, the above can get a noop
cleanup before merging or I can do a more proper submit with this bit
cleaned up:

diff --git a/mm/mmap.c b/mm/mmap.c
index c682dee..0c5f6f7 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -627,10 +627,7 @@ static __always_inline void __vma_unlink_common(struct mm_struct *mm,
 {
 	struct vm_area_struct *next;
 
-	if (has_prev)
-		vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
-	else
-		vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
+	vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
 	next = vma->vm_next;
 	if (has_prev)
 		prev->vm_next = next;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
