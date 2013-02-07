Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id A58E66B0005
	for <linux-mm@kvack.org>; Thu,  7 Feb 2013 16:35:21 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id j34so1185879qco.9
        for <linux-mm@kvack.org>; Thu, 07 Feb 2013 13:35:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130206171047.d27b5772.akpm@linux-foundation.org>
References: <1359591980-29542-1-git-send-email-walken@google.com>
	<1359591980-29542-2-git-send-email-walken@google.com>
	<5112F7AF.6010307@oracle.com>
	<20130206171047.d27b5772.akpm@linux-foundation.org>
Date: Thu, 7 Feb 2013 13:35:20 -0800
Message-ID: <CANN689FV+0Z_TuqWKdsmUHk7HMFDuk31uQO=eH79+249nfOQrQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: use long type for page counts in mm_populate()
 and get_user_pages()
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 6, 2013 at 5:10 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 06 Feb 2013 19:39:11 -0500
> Sasha Levin <sasha.levin@oracle.com> wrote:
>
>> We're now hitting the VM_BUG_ON() which was added in the last hunk of the
>> patch:
>
> hm, why was that added.
>
> Michel, I seem to have confused myself over this series.  I saw a
> report this morning which led me to drop
> mm-accelerate-munlock-treatment-of-thp-pages.patch but now I can't find
> that report and I'm wondering if I should have dropped
> mm-accelerate-mm_populate-treatment-of-thp-pages.patch instead.
>
> Given that and Sasha's new report I think I'll drop
>
> mm-use-long-type-for-page-counts-in-mm_populate-and-get_user_pages.patch
> mm-use-long-type-for-page-counts-in-mm_populate-and-get_user_pages-fix.patch
> mm-use-long-type-for-page-counts-in-mm_populate-and-get_user_pages-fix-fix.patch
> mm-accelerate-mm_populate-treatment-of-thp-pages.patch
> mm-accelerate-munlock-treatment-of-thp-pages.patch
>
> and let's start again?

All right. My bad, there were issues in the patch series. I think
there were two:

- The VM_BUG_ON(!reg) in "mm: use long type for page counts in
mm_populate() and get_user_pages()". The intention there was to test
for what happened in the original overflow case, which is that gup
would return 0 as the passed nr_pages argument (when passed as an int)
would be <= 0. As it turns out, this didn't account for the other case
where gup returns 0, which is when the first page is file-backed, not
found in page cache, and the mmap_sem gets dropped due to a non-NULL
"nonblocking" argument (as is the case with mm_populate())

- The issue in munlock, where the page mask wasn't correctly computed
due to an off by 1 issue.

I agree a clean resend seems the most appropriate course of action at
this point. Sorry for the trouble :/

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
