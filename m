Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BB7656B006A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 18:44:34 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o95MiPW6030179
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 15:44:32 -0700
Received: from iwn4 (iwn4.prod.google.com [10.241.68.68])
	by hpaq1.eem.corp.google.com with ESMTP id o95MgQ8g021299
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 15:44:23 -0700
Received: by iwn4 with SMTP id 4so13919096iwn.10
        for <linux-mm@kvack.org>; Tue, 05 Oct 2010 15:44:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4CAB628D.3030205@redhat.com>
References: <1286265215-9025-1-git-send-email-walken@google.com>
	<1286265215-9025-3-git-send-email-walken@google.com>
	<4CAB628D.3030205@redhat.com>
Date: Tue, 5 Oct 2010 15:44:22 -0700
Message-ID: <AANLkTimdACZ9Xm01DM2+E64+T5XfLffrkFBhf7CJ286p@mail.gmail.com>
Subject: Re: [PATCH 2/3] Retry page fault when blocking on disk transfer.
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 5, 2010 at 10:38 AM, Rik van Riel <riel@redhat.com> wrote:
> On 10/05/2010 03:53 AM, Michel Lespinasse wrote:
>>
>> This change reduces mmap_sem hold times that are caused by waiting for
>> disk transfers when accessing file mapped VMAs. It introduces the
>> VM_FAULT_ALLOW_RETRY flag, which indicates that the call site wants
>> mmap_sem to be released if blocking on a pending disk transfer.
>> In that case, filemap_fault() returns the VM_FAULT_RETRY status bit
>> and do_page_fault() will then re-acquire mmap_sem and retry the page
>> fault.
>> It is expected that the retry will hit the same page which will now be
>> cached, and thus it will complete with a low mmap_sem hold time.
>>
>> Signed-off-by: Michel Lespinasse<walken@google.com>
>
> Acked-by: Rik van Riel <riel@redhat.com>
>
> Looks like it should be relatively easy to do something
> similar in do_swap_page also.

Good idea. We don't make use of swap too much, which is probably why
we didn't have that in our kernel, but it seems like a good idea just
for uniformity. I'll add this in a follow-on patch.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
