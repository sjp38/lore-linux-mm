Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 2B8906B0069
	for <linux-mm@kvack.org>; Thu, 30 Aug 2012 18:33:53 -0400 (EDT)
Received: by iagk10 with SMTP id k10so5042846iag.14
        for <linux-mm@kvack.org>; Thu, 30 Aug 2012 15:33:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120830143401.be06d61b.akpm@linux-foundation.org>
References: <1344324343-3817-1-git-send-email-walken@google.com>
	<20120830143401.be06d61b.akpm@linux-foundation.org>
Date: Thu, 30 Aug 2012 15:33:52 -0700
Message-ID: <CANN689G7q=FLLx+ZPg1r-Vu4m7rYrQNhpTkqevrqhPcmZhSObA@mail.gmail.com>
Subject: Re: [PATCH 0/5] rbtree based interval tree as a prio_tree replacement
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: riel@redhat.com, peterz@infradead.org, vrajesh@umich.edu, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Thu, Aug 30, 2012 at 2:34 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue,  7 Aug 2012 00:25:38 -0700
> Michel Lespinasse <walken@google.com> wrote:
>
>> This patchset goes over the rbtree changes that have been already integrated
>> into Andrew's -mm tree, as well as the augmented rbtree proposal which is
>> currently pending.
>
> hm.  Well I grabbed these for a bit of testing.
>
> It's a large change in MM and it depends on code which hasn't yet been
> merged in mainline.  It's probably prudent to do all this in two steps
> - we'll see.

Makes sense to me. If we want to split the series as they get sent
upstream, I would suggest sending all the rbtree and augmented rbtree
infrastructure first, and then the rbtree usages (prio tree
replacement, anon rmap interval tree which I'm going to send next, and
rik's augmented rbtree based vma gap finder) in the next kernel.

> The templates-with-CPP thing is not terribly appealing.  It's not
> obvious that it really needed to be done this way - we've avoided it in
> plenty of other places.  It would be nice to see that alternatives have
> been thoroughly explored, and why they were rejected.

I am actually wondering if the interval_tree_tmpl.h include file
shouldn't be done as one large preprocessor #define instead. The
ITSTRUCT, ITRB, etc... definitions would then become arguments to that
large definition. It would also be possible to break up that #define
into smaller ones - most likely, one for insertion, one for removal,
and one for the subtree_search / iter_first / iter_next functions. Do
you think this might help ?

I don't really see other workable alternatives that don't involve code
replication.

> The code uses the lame-and-useless "inline" absolutely all over the
> place.  I do think that for new code it would be better to get down and
> actually make proper engineering decisions about which functions should
> be inlined and mark them __always_inline.

You mentionned this before, but I'm not convinced that __always_inline
would be better. The kernel is full of 2-line functions that we really
want inlined, and I don't see what the value would be in converting
these all to __always_inline. I am tempted to stick with the current
usage, which I understand as being:

- use inline when the programmer believes a function should be inlined
(this includes the static inline functions in header files - if the
programmer didn't believe this should be inlined, he wouldn't put the
function in a header file)

- use __always_inline if the function absolutely needs to be inlined
for correct operation (I believe scheduler has some of these, which
need to be included in the parent in order to end up in the correct
section), OR in rare cases if the compiler is known to generate bad
code with a mere inline and the programmer wants to force the issue.

I would also note that replacing inline with __always_inline is not a
no-op change, even when the compiler was already inlining the original
(marked inline) function. Sometimes the generated code ends up being
different with __always_inline and I would rather not apply these
changes blindly.

> Hillf has made a review suggestion which AFAICT remains unresponded to.

To be honest, I wasn't quite sure what he was suggesting ?

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
