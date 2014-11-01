Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9836B012E
	for <linux-mm@kvack.org>; Sat,  1 Nov 2014 15:21:18 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so9751262pab.38
        for <linux-mm@kvack.org>; Sat, 01 Nov 2014 12:21:18 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id wn5si11896217pbc.94.2014.11.01.12.21.16
        for <linux-mm@kvack.org>;
        Sat, 01 Nov 2014 12:21:16 -0700 (PDT)
Date: Sat, 01 Nov 2014 15:21:12 -0400 (EDT)
Message-Id: <20141101.152112.741323581543029110.davem@davemloft.net>
Subject: Re: [PATCH V4 1/2] mm: Update generic gup implementation to handle
 hugepage directory
From: David Miller <davem@davemloft.net>
In-Reply-To: <1414570785-18966-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1414570785-18966-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aneesh.kumar@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, steve.capper@linaro.org, aarcange@redhat.com, benh@kernel.crashing.org, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Wed, 29 Oct 2014 13:49:44 +0530

> Update generic gup implementation with powerpc specific details.
> On powerpc at pmd level we can have hugepte, normal pmd pointer
> or a pointer to the hugepage directory.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
> Changes from V3:
> * Drop arm and arm64 changes
> * Add hugepte assumption to the function 

Wait, what are you doing here?

You can't assume that a pmd is something you can just go:

	__pte(pmd_val(x))

with.  Not at all.

You have to use the correct pmd_*() accessors at all times on
this object.

Platforms can encode PMDs however they like.  In fact, on sparc64,
we used to have 32-bit PMDs with a special encoding for huge
PMDs that looked nothing at all like a 64-bit PTE.

Please code this in a portable manner to support the powerpc
facilities, don't add assumptions that are not necessarily
universally true.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
