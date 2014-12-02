Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9A56E6B0069
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 02:27:21 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so12791208pab.6
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 23:27:21 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id uq12si32377591pab.95.2014.12.01.23.27.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Dec 2014 23:27:20 -0800 (PST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 2 Dec 2014 12:57:12 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 917B21258054
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 12:57:26 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sB27RjRZ2556176
	for <linux-mm@kvack.org>; Tue, 2 Dec 2014 12:57:46 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sB27R870029494
	for <linux-mm@kvack.org>; Tue, 2 Dec 2014 12:57:08 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 03/10] mm: Convert p[te|md]_numa users to p[te|md]_protnone_numa
In-Reply-To: <1417473762.7182.8.camel@kernel.crashing.org>
References: <1416578268-19597-1-git-send-email-mgorman@suse.de> <1416578268-19597-4-git-send-email-mgorman@suse.de> <1417473762.7182.8.camel@kernel.crashing.org>
Date: Tue, 02 Dec 2014 12:57:00 +0530
Message-ID: <87k32ah5q3.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>

Benjamin Herrenschmidt <benh@kernel.crashing.org> writes:

> On Fri, 2014-11-21 at 13:57 +0000, Mel Gorman wrote:
>> Convert existing users of pte_numa and friends to the new helper. Note
>> that the kernel is broken after this patch is applied until the other
>> page table modifiers are also altered. This patch layout is to make
>> review easier.
>
> Aneesh, the removal of the DSISR_PROTFAULT checks, I wonder if we might
> break something here ... (I know, I asked for them to be removed :-)
>

That is the reason I converted that to a WARN_ON in later patch. 

> IE, we basically bounce all protection checks to the "normal" VMA
> protection checking, so far so good...
>
> But what about the subpage protection stuff ? Will that still work ?
>

I did look at that before. So if we had subpage access limitted, when we
take a fault for that subpage, we bail out early in hash_page_mm. (with
rc = 2). low_hash_fault handle that case directly. We will not end up
calling do_page_fault.

Now, hash_preload can possibly insert an hpte in hash page table even if
the access is not allowed by the pte permissions. But i guess even that
is ok. because we will fault again, end-up calling hash_page_mm where we
handle that part correctly.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
