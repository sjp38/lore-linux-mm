Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B11DE6B0093
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 17:11:15 -0500 (EST)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id oAHMBB66012725
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 14:11:11 -0800
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by hpaq5.eem.corp.google.com with ESMTP id oAHMAnIA026416
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 14:11:10 -0800
Received: by qwf7 with SMTP id 7so28329qwf.34
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 14:11:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1290007734.2109.941.camel@laptop>
References: <1289996638-21439-1-git-send-email-walken@google.com>
	<1289996638-21439-4-git-send-email-walken@google.com>
	<20101117125756.GA5576@amd>
	<1290007734.2109.941.camel@laptop>
Date: Wed, 17 Nov 2010 14:05:30 -0800
Message-ID: <AANLkTim4tO_aKzXLXJm-N-iEQ9rNSa0=HGJVDAz33kY6@mail.gmail.com>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering writeback
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 7:28 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Wed, 2010-11-17 at 23:57 +1100, Nick Piggin wrote:
>> On Wed, Nov 17, 2010 at 04:23:58AM -0800, Michel Lespinasse wrote:
>> > When faulting in pages for mlock(), we want to break COW for anonymous
>> > or file pages within VM_WRITABLE, non-VM_SHARED vmas. However, there is
>> > no need to write-fault into VM_SHARED vmas since shared file pages can
>> > be mlocked first and dirtied later, when/if they actually get written to.
>> > Skipping the write fault is desirable, as we don't want to unnecessarily
>> > cause these pages to be dirtied and queued for writeback.
>>
>> It's not just to break COW, but to do block allocation and such
>> (filesystem's page_mkwrite op). That needs to at least be explained
>> in the changelog.
>
> Agreed, the 0/3 description actually does mention this.
>
>> Filesystem doesn't have a good way to fully pin required things
>> according to mlock, but page_mkwrite provides some reasonable things
>> (like block allocation / reservation).
>
> Right, but marking all pages dirty isn't really sane. I can imagine
> making the reservation but not marking things dirty solution, although
> it might be lots harder to implement, esp since some filesystems don't
> actually have a page_mkwrite() implementation.

Really, my understanding is that not pre-allocating filesystem blocks
is just fine. This is, after all, what happens with ext3 and it's
never been reported as a bug (that I know of).

If filesystem people's feedback is that they really want mlock() to
continue pre-allocating blocks, maybe we can just do it using
fallocate() rather than page_mkwrite() callbacks ?

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
