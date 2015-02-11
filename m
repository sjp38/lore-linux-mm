Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3FBE76B006C
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 21:34:34 -0500 (EST)
Received: by mail-qg0-f54.google.com with SMTP id z60so639323qgd.13
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 18:34:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a6si20866306qcq.25.2015.02.10.18.34.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 18:34:33 -0800 (PST)
Message-ID: <54DABDDF.3030402@redhat.com>
Date: Tue, 10 Feb 2015 21:26:39 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: incorporate zero pages into transparent huge pages
References: <1423522057-5757-1-git-send-email-ebru.akagunduz@gmail.com> <20150210210657.GI11755@redhat.com>
In-Reply-To: <20150210210657.GI11755@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 02/10/2015 04:06 PM, Andrea Arcangeli wrote:
> On Tue, Feb 10, 2015 at 12:47:37AM +0200, Ebru Akagunduz wrote:
>> This patch improves THP collapse rates, by allowing zero pages.
>> 
>> Currently THP can collapse 4kB pages into a THP when there are up
>> to khugepaged_max_ptes_none pte_none ptes in a 2MB range.  This
>> patch counts pte none and mapped zero pages with the same
>> variable.
>> 
>> The patch was tested with a program that allocates 800MB of 
>> memory, and performs interleaved reads and writes, in a pattern 
>> that causes some 2MB areas to first see read accesses, resulting 
>> in the zero pfn being mapped there.
>> 
>> To simulate memory fragmentation at allocation time, I modified 
>> do_huge_pmd_anonymous_page to return VM_FAULT_FALLBACK for read 
>> faults.
>> 
>> Without the patch, only %50 of the program was collapsed into THP
>> and the percentage did not increase over time.
>> 
>> With this patch after 10 minutes of waiting khugepaged had 
>> collapsed %89 of the program's memory.
> 
> This is very good idea, associating it with the sysctl is sensible 
> here as collapsing zeropages would affect the memory footprint in
> the same way as none ptes.
> 
> __collapse_huge_page_copy however is likely screwing with the 
> refcounts of the zero page. Did you have DEBUG_VM=y enabled? If
> yes you should get one warning that the zeropage refcount
> underflowed that could confirm my concern:

In __collapse_huge_page_copy, the zero pte takes the same path
as pte_none, so I believe that part of the code is correct.

> So in short I think __collapse_huge_page_copy and
> release_pte_pages needs an additional case that complements the
> already existing special

You are right that release_pte_pages needs a special case too,
in order to skip refcounting on the zero page.

Ebru?

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJU2r3fAAoJEM553pKExN6DJPAH/1TT9uzS0/1wRcN7gn/UP0rb
TpkKzihDOeQgEPfGjd6wUgepU0iVhMX80qBCqk0wIAPgZLnt4IxSl24f09Sm38Cn
zAV0mLySmoaYNisf+qieZ/NF/PDiUOrxGzWJzvm7Ymqq8Mh94qdgpsLy2I+EQioT
RqwbYMMB2XvH3mWOzhQUfnyG5mJMmZtpVcrJ4MIVVq5a3x+Ry668ZT75oNegni5W
Hfax6/8jf4Bjpxc9I/9FvZXzZr9m9yVcGHoCckdGxlnsSSgd60B9b+EYy6AlJpqS
xYkGhKSL0iAAoXYkmrtFdLpdhU/eqhgLb0V2NxcimjrzNG/0LE8fGhb/0SmPXUU=
=085q
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
