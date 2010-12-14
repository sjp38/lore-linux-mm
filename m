Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CFA2B6B008A
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 19:51:51 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id oBE0pn39008541
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 16:51:49 -0800
Received: from iwn42 (iwn42.prod.google.com [10.241.68.106])
	by wpaz5.hot.corp.google.com with ESMTP id oBE0pPwi013631
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 16:51:48 -0800
Received: by iwn42 with SMTP id 42so94411iwn.10
        for <linux-mm@kvack.org>; Mon, 13 Dec 2010 16:51:46 -0800 (PST)
Date: Mon, 13 Dec 2010 16:51:40 -0800
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH 1/6] mlock: only hold mmap_sem in shared mode when
 faulting in pages
Message-ID: <20101214005140.GA29904@google.com>
References: <1291335412-16231-1-git-send-email-walken@google.com>
 <1291335412-16231-2-git-send-email-walken@google.com>
 <20101208152740.ac449c3d.akpm@linux-foundation.org>
 <AANLkTikYZi0=c+yM1p8H18u+9WVbsQXjAinUWyNt7x+t@mail.gmail.com>
 <AANLkTinY0pcTcd+OxPLyvsJgHgh=cTaB1-8VbEA2tstb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinY0pcTcd+OxPLyvsJgHgh=cTaB1-8VbEA2tstb@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 9, 2010 at 10:11 PM, Linus Torvalds <torvalds@linux-foundation.org> wrote:
> On Wednesday, December 8, 2010, Michel Lespinasse <walken@google.com> wrote:
>>
>> Yes, patch 1/6 changes the long hold time to be in read mode instead
>> of write mode, which is only a band-aid. But, this prepares for patch
>> 5/6, which releases mmap_sem whenever there is contention on it or
>> when blocking on disk reads.
>
> I have to say that I'm not a huge fan of that horribly kludgy
> contention check case.
>
> The "move page-in to read-locked sequence" and the changes to
> get_user_pages look fine, but the contention thing is just disgusting.
> I'd really like to see some other approach if at all possible.

Andrew, should I amend my patches to remove the rwsem_is_contended() code ?
This would involve:
- remove rwsem-implement-rwsem_is_contended.patch and
  x86-rwsem-more-precise-rwsem_is_contended-implementation.patch
- in mlock-do-not-hold-mmap_sem-for-extended-periods-of-time.patch,
  drop the one hunk making use of rwsem_is_contended (rest of the patch
  would still work without it)
- optionally, follow up patch to limit batch size to a constant
  in do_mlock_pages():

diff --git a/mm/mlock.c b/mm/mlock.c
index 569ae6a..a505a7e 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -457,15 +457,23 @@ static int do_mlock_pages(unsigned long start, size_t len)
 			continue;
 		if (nstart < vma->vm_start)
 			nstart = vma->vm_start;
+		/*
+		 * Constrain batch size to limit mmap_sem hold time.
+		 */
+		if (nend > nstart + 1024 * PAGE_SIZE)
+			nend = nstart + 1024 * PAGE_SIZE;
 		/*
 		 * Now fault in a range of pages. __mlock_vma_pages_range()
 		 * double checks the vma flags, so that it won't mlock pages
 		 * if the vma was already munlocked.
 		 */
 		ret = __mlock_vma_pages_range(vma, nstart, nend, &locked);
 		if (ret < 0) {
 			ret = __mlock_posix_error_return(ret);
 			break;
+		} else if (locked) {
+			locked = 0;
+			up_read(&mm->mmap_sem);
 		}
 		nend = nstart + ret * PAGE_SIZE;
 		ret = 0;


I don't really prefer using a constant, but I'm not sure how else to make
Linus happy :)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
