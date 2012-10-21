Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 0E2C76B0062
	for <linux-mm@kvack.org>; Sat, 20 Oct 2012 22:39:35 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so2869217ied.14
        for <linux-mm@kvack.org>; Sat, 20 Oct 2012 19:39:34 -0700 (PDT)
Message-ID: <50836060.4050408@gmail.com>
Date: Sun, 21 Oct 2012 10:39:28 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: question on NUMA page migration
References: <5081777A.8050104@redhat.com>
In-Reply-To: <5081777A.8050104@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>

On 10/19/2012 11:53 PM, Rik van Riel wrote:
> Hi Andrea, Peter,
>
> I have a question on page refcounting in your NUMA
> page migration code.
>
> In Peter's case, I wonder why you introduce a new
> MIGRATE_FAULT migration mode. If the normal page
> migration / compaction logic can do without taking
> an extra reference count, why does your code need it?

Hi Rik van Riel,

This is which part of codes? Why I can't find MIGRATE_FAULT in latest 
v3.7-rc2?

Regards,
Chen

>
> In Andrea's case, we have a comment suggesting an
> extra refcount is needed, immediately followed by
> a put_page:
>
>         /*
>          * Pin the head subpage at least until the first
>          * __isolate_lru_page succeeds (__isolate_lru_page pins it
>          * again when it succeeds). If we unpin before
>          * __isolate_lru_page successd, the page could be freed and
>          * reallocated out from under us. Thus our previous checks on
>          * the page, and the split_huge_page, would be worthless.
>          *
>          * We really only need to do this if "ret > 0" but it doesn't
>          * hurt to do it unconditionally as nobody can reference
>          * "page" anymore after this and so we can avoid an "if (ret >
>          * 0)" branch here.
>          */
>         put_page(page);
>
> This also confuses me.
>
> If we do not need the extra refcount (and I do not
> understand why NUMA migrate-on-fault needs one more
> refcount than normal page migration), we can get
> rid of the MIGRATE_FAULT mode.
>
> If we do need the extra refcount, why is normal
> page migration safe? :)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
