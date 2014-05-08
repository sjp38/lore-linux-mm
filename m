Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 661F56B00A5
	for <linux-mm@kvack.org>; Wed,  7 May 2014 20:13:33 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id i17so2067901qcy.39
        for <linux-mm@kvack.org>; Wed, 07 May 2014 17:13:33 -0700 (PDT)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id d93si3826421qgf.149.2014.05.07.17.13.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 17:13:32 -0700 (PDT)
Received: by mail-qg0-f50.google.com with SMTP id z60so1982734qgd.9
        for <linux-mm@kvack.org>; Wed, 07 May 2014 17:13:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140506130655.GE19914@cmpxchg.org>
References: <1399328011-15317-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20140506130655.GE19914@cmpxchg.org>
Date: Wed, 7 May 2014 17:13:32 -0700
Message-ID: <CANN689GqmdRpOOHV7uYCLgu+xKcYQ5_ESw7+-djNpVGo=D-+WQ@mail.gmail.com>
Subject: Re: [PATCH] mm, thp: close race between mremap() and split_huge_page()
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, stable@vger.kernel.org

My bad for introducing the bug, and thanks Kirill for fixing it.

Acked-by: Michel Lespinasse <walken@google.com>

On Tue, May 6, 2014 at 6:06 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Tue, May 06, 2014 at 01:13:31AM +0300, Kirill A. Shutemov wrote:
>> But on move_vma() destination VMA can be merged into adjacent one and as
>> result shifted left in interval tree. Fortunately, we can detect the
>> situation and prevent race with rmap walk by moving page table entries
>> under rmap lock. See commit 38a76013ad80.

Yup, forgot to take care of the THP case there...

> Fixes: 108d6642ad81 ("mm anon rmap: remove anon_vma_moveto_tail")

I think 108d6642ad81 on its own was OK (as it always took the locks);
but the attempt to not take them in the common case in 38a76013ad80 is
where I forgot to consider the THP case.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
