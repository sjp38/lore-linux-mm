Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id B1FFA6B0038
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 18:16:13 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so7929466pab.32
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 15:16:13 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id i7si16680186pat.139.2014.10.07.15.16.11
        for <linux-mm@kvack.org>;
        Tue, 07 Oct 2014 15:16:12 -0700 (PDT)
Message-ID: <54346623.6000309@intel.com>
Date: Tue, 07 Oct 2014 15:16:03 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] mm: poison critical mm/ structs
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com> <20141001140725.fd7f1d0cf933fbc2aa9fc1b1@linux-foundation.org> <542C749B.1040103@oracle.com> <alpine.LSU.2.11.1410020154500.6444@eggly.anvils> <542D680E.8010909@oracle.com>
In-Reply-To: <542D680E.8010909@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de

On 10/02/2014 07:58 AM, Sasha Levin wrote:
>> > What does this add on top of slab poisoning?  Some checks in some
>> > mm places while the object is active, I guess: why not base those
>> > on slab poisoning?  And add them in as appropriate to the problem
>> > at hand, when a problem is seen.
> The extra you're getting is detecting corruption that happened
> inside the object rather than around it.

Isn't this more akin to redzoning that poisoning?

I'm not sure I follow the logic here.  The poison is inside the object,
but it's now at the edges.  With slub at least, you get a redzone right
after the object(s):

	{ OBJ } | REDZONE | { OBJ } | REDZONE | ...

With this patch, you'd get something along these lines:

	{ POISON | OBJ | POISON } { POISON | OBJ | POISON }  ...

So if somebody overflows OBJ, they'll hit the redzone/poison in either
case.  If they're randomly scribbling on memory, their likelihood of
hitting the redzone/poison is proportional to the size of the
redzone/poison.

The only place this really helps is if someone overflows from a
non-redzoned page or structure in to the beginning of a slub redzoned
one.  The fact that the redzone is at the end means we'll miss it.

But, all that means is that we should probably add redzones to the
beginning of slub objects, not just the end.  That doesn't help us with
'struct page' of course, but it does for the mm_struct and vma.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
