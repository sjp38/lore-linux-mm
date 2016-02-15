Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id B8BAB6B0009
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 00:02:27 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id l127so147006095iof.3
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 21:02:27 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id b42si40369785ioj.123.2016.02.14.21.02.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Feb 2016 21:02:26 -0800 (PST)
Date: Mon, 15 Feb 2016 15:11:53 +1100
From: Paul Mackerras <paulus@ozlabs.org>
Subject: Re: [PATCH V2 08/29] mm: Some arch may want to use HPAGE_PMD related
 values as variables
Message-ID: <20160215041153.GC3797@oak.ozlabs.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1454923241-6681-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454923241-6681-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, Feb 08, 2016 at 02:50:20PM +0530, Aneesh Kumar K.V wrote:
> With next generation power processor, we are having a new mmu model
> [1] that require us to maintain a different linux page table format.
> 
> Inorder to support both current and future ppc64 systems with a single
> kernel we need to make sure kernel can select between different page
> table format at runtime. With the new MMU (radix MMU) added, we will
> have two different pmd hugepage size 16MB for hash model and 2MB for
> Radix model. Hence make HPAGE_PMD related values as a variable.

But this patch doesn't actually turn any constant into a variable, as
far as I can see...

Most of what this patch does is to move two tests around:

* The #if HPAGE_PMD_ORDER >= MAX_ORDER test get moved from a generic
header into all archs except powerpc, and for powerpc it gets turned
into BUILD_BUG_ON.  However, BUILD_BUG_ON only works on things that
are known at compile time, last time I looked.  Doesn't it need to be
a BUG_ON to prepare for HPAGE_PMD_ORDER being a variable that isn't
known at compile time?

* The existing BUILD_BUG_ON(HPAGE_PMD_ORDER < 2) gets turned into #if
for all archs except powerpc, and for powerpc it stays as a
BUILD_BUG_ON but gets moved to arch code.  That doesn't really seem to
accomplish anything.  Once again, doesn't it need to become a BUG_ON?
If so, could we just make it BUG_ON in the generic code where the
BUILD_BUG_ON currently is?

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
