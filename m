Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C69D56B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 14:16:24 -0500 (EST)
Received: by padfb1 with SMTP id fb1so29764289pad.8
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 11:16:24 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f8si7291413pas.21.2015.02.23.11.16.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 11:16:23 -0800 (PST)
Date: Mon, 23 Feb 2015 11:16:21 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: incorporate zero pages into transparent huge
 pages
Message-Id: <20150223111621.bc73004f51af2ca8e2847944@linux-foundation.org>
In-Reply-To: <54E5296C.5040806@redhat.com>
References: <1423688635-4306-1-git-send-email-ebru.akagunduz@gmail.com>
	<20150218153119.0bcd0bf8b4e7d30d99f00a3b@linux-foundation.org>
	<54E5296C.5040806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, aarcange@redhat.com, keithr@alum.mit.edu, dvyukov@google.com

On Wed, 18 Feb 2015 19:08:12 -0500 Rik van Riel <riel@redhat.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> On 02/18/2015 06:31 PM, Andrew Morton wrote:
> > On Wed, 11 Feb 2015 23:03:55 +0200 Ebru Akagunduz
> > <ebru.akagunduz@gmail.com> wrote:
> > 
> >> This patch improves THP collapse rates, by allowing zero pages.
> >> 
> >> Currently THP can collapse 4kB pages into a THP when there are up
> >> to khugepaged_max_ptes_none pte_none ptes in a 2MB range.  This
> >> patch counts pte none and mapped zero pages with the same
> >> variable.
> > 
> > So if I'm understanding this correctly, with the default value of 
> > khugepaged_max_ptes_none (HPAGE_PMD_NR-1), if an application
> > creates a 2MB area which contains 511 mappings of the zero page and
> > one real page, the kernel will proceed to turn that area into a
> > real, physical huge page.  So it consumes 2MB of memory which would
> > not have previously been allocated?
> 
> This is equivalent to an application doing a write fault
> to a 2MB area that was previously untouched, going into
> do_huge_pmd_anonymous_page() and receiving a 2MB page.
> 
> > If so, this might be rather undesirable behaviour in some
> > situations (and ditto the current behaviour for pte_none ptes)?
> > 
> > This can be tuned by adjusting khugepaged_max_ptes_none,
> 
> The example of directly going into do_huge_pmd_anonymous_page()
> is not influenced by the tunable.
> 
> It may indeed be undesirable in some situations, but I am
> not sure how to detect those...

Here's a live one: https://bugzilla.kernel.org/show_bug.cgi?id=93111

Application does MADV_DONTNEED to free up a load of memory and then
khugepaged comes along and pages that memory back in again.  It seems a
bit silly to do this after userspace has deliberately discarded those
pages!

Presumably MADV_NOHUGEPAGE can be used to prevent this, but it's a bit
of a hand-grenade.  I guess the MADV_DONTNEED manpage should be updated
to explain all this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
