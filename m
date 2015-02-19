Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 13CBA6B00C4
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 19:26:50 -0500 (EST)
Received: by mail-qg0-f43.google.com with SMTP id i50so3950802qgf.2
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 16:26:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b89si18966173qgf.111.2015.02.18.16.26.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Feb 2015 16:26:49 -0800 (PST)
Message-ID: <54E5296C.5040806@redhat.com>
Date: Wed, 18 Feb 2015 19:08:12 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: incorporate zero pages into transparent huge pages
References: <1423688635-4306-1-git-send-email-ebru.akagunduz@gmail.com> <20150218153119.0bcd0bf8b4e7d30d99f00a3b@linux-foundation.org>
In-Reply-To: <20150218153119.0bcd0bf8b4e7d30d99f00a3b@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, aarcange@redhat.com

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 02/18/2015 06:31 PM, Andrew Morton wrote:
> On Wed, 11 Feb 2015 23:03:55 +0200 Ebru Akagunduz
> <ebru.akagunduz@gmail.com> wrote:
> 
>> This patch improves THP collapse rates, by allowing zero pages.
>> 
>> Currently THP can collapse 4kB pages into a THP when there are up
>> to khugepaged_max_ptes_none pte_none ptes in a 2MB range.  This
>> patch counts pte none and mapped zero pages with the same
>> variable.
> 
> So if I'm understanding this correctly, with the default value of 
> khugepaged_max_ptes_none (HPAGE_PMD_NR-1), if an application
> creates a 2MB area which contains 511 mappings of the zero page and
> one real page, the kernel will proceed to turn that area into a
> real, physical huge page.  So it consumes 2MB of memory which would
> not have previously been allocated?

This is equivalent to an application doing a write fault
to a 2MB area that was previously untouched, going into
do_huge_pmd_anonymous_page() and receiving a 2MB page.

> If so, this might be rather undesirable behaviour in some
> situations (and ditto the current behaviour for pte_none ptes)?
> 
> This can be tuned by adjusting khugepaged_max_ptes_none,

The example of directly going into do_huge_pmd_anonymous_page()
is not influenced by the tunable.

It may indeed be undesirable in some situations, but I am
not sure how to detect those...

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJU5SlsAAoJEM553pKExN6D8DYH/0TQPr38R3lYqxTllOVPIUus
+UrgXveOeoMiMbN3e5r9tIJkw+2yUJFZ8hkYx+aFsTD5zNz7xwf9Qz8IdJpcZ3sc
PkvOnnZNk/ZzixWrBhWFPsKRN2pi5wXMpfNM2jTs9W4EeyfkV3RYbGxZy/OO1LB5
CwDzteCTb81y1FYxC4vNxLnML417ZjIMq7ICdj6lKW2KC5+TdCIPTOrKCy+2fWBo
4qhqho4RFKHLCxpnryUMzZDXca4vmcgGWwUm5xLF6SnJWWFEiPBLixJiRV3xe0iw
rbuGhcIXo/q16oO4QOIl+hSVJr8vE+Y8xRbIJFmWXCmuQHQpg5ZspVZ+9Z/3UaI=
=Qf1D
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
