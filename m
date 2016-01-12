Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id EF692680F7F
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 19:03:45 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id vt7so13091599obb.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 16:03:45 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id h8si31454615oeq.23.2016.01.11.16.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 16:03:45 -0800 (PST)
Message-ID: <1452557022.23317.7.camel@ellerman.id.au>
Subject: Re: [PATCH V2] mm/powerpc: Fix _PAGE_PTE breaking swapoff
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Tue, 12 Jan 2016 11:03:42 +1100
In-Reply-To: <1452527374-4886-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: 
	<1452527374-4886-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, 2016-01-11 at 21:19 +0530, Aneesh Kumar K.V wrote:

> Core kernel expect swp_entry_t to be consisting of
> only swap type and swap offset. We should not leak pte bits to
> swp_entry_t. This breaks swapoff which use the swap type and offset
> to build a swp_entry_t and later compare that to the swp_entry_t
> obtained from linux page table pte. Leaking pte bits to swp_entry_t
> breaks that comparison and results in us looping in try_to_unuse.
> 
> The stack trace can be anywhere below try_to_unuse() in mm/swapfile.c,
> since swapoff is circling around and around that function, reading from
> each used swap block into a page, then trying to find where that page
> belongs, looking at every non-file pte of every mm that ever swapped.
> 
> Reported-by: Hugh Dickins <hughd@google.com>
> Suggested-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Thanks. I slightly edited the wording in the change log and added:

Fixes: 6a119eae942c ("powerpc/mm: Add a _PAGE_PTE bit")

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
