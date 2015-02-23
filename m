Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id F31056B006E
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 15:24:33 -0500 (EST)
Received: by qcvp6 with SMTP id p6so13106596qcv.12
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 12:24:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f1si37127616qaa.43.2015.02.23.12.24.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 12:24:33 -0800 (PST)
Message-ID: <54EB82D0.9080606@redhat.com>
Date: Mon, 23 Feb 2015 14:43:12 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: incorporate zero pages into transparent huge pages
References: <1423688635-4306-1-git-send-email-ebru.akagunduz@gmail.com>	<20150218153119.0bcd0bf8b4e7d30d99f00a3b@linux-foundation.org>	<54E5296C.5040806@redhat.com> <20150223111621.bc73004f51af2ca8e2847944@linux-foundation.org>
In-Reply-To: <20150223111621.bc73004f51af2ca8e2847944@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, aarcange@redhat.com, keithr@alum.mit.edu, dvyukov@google.com

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 02/23/2015 02:16 PM, Andrew Morton wrote:
> On Wed, 18 Feb 2015 19:08:12 -0500 Rik van Riel <riel@redhat.com>
> wrote:

>>> If so, this might be rather undesirable behaviour in some 
>>> situations (and ditto the current behaviour for pte_none
>>> ptes)?
>>> 
>>> This can be tuned by adjusting khugepaged_max_ptes_none,

> Here's a live one:
> https://bugzilla.kernel.org/show_bug.cgi?id=93111
> 
> Application does MADV_DONTNEED to free up a load of memory and
> then khugepaged comes along and pages that memory back in again.
> It seems a bit silly to do this after userspace has deliberately
> discarded those pages!
> 
> Presumably MADV_NOHUGEPAGE can be used to prevent this, but it's a
> bit of a hand-grenade.  I guess the MADV_DONTNEED manpage should be
> updated to explain all this?

That makes me wonder what a good value for khugepaged_max_ptes_none
would be.

Doubling the amount of memory a program uses seems quite unreasonable.

Increasing the amount of memory a program uses by 512x seems totally
unreasonable.

Increasing the amount of memory a program uses by 20% might be
reasonable, if that much memory is available, since that seems to
be about how much performance improvement we have ever seen from
THP.

Andrew, Andrea, do you have any ideas on this?

Is this something to just set, or should we ask Ebru to run
a few different tests with this?

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJU64LQAAoJEM553pKExN6DbjAH/31KsggMczFT5Z6KQ68dnMnc
nlYAHmiC8nBzguhj5fUtm94jWBK1IPg9cUkRt1tKDJXkVGk91it0MdO1QhuSL91b
xNghqc1d8/P/dmuguNH6C7BUlf52iFFyaCrnip+sO1rxIEUYkFwHxpwC5vSlLrrl
bENlILFuY5kmF2xd6kIfvhOr7TzkbCS92Da3la0sCIT4tjlXPKJ6fuTo9aK8LOqr
kKi6gmmyH+gDhi2EAJk3D1cZT8RqrynsbirEEcWq+ORNUScmSqNlQqGOLw/nJeSp
Nkw7rReeMz5PHVxnsNQE4kxQ4zIJ0auZsZ9cC4Gw3ZpQKdiLBiAK+lJECgQsqPk=
=pDxP
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
