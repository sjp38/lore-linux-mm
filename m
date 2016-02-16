Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 93CBA6B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 03:12:57 -0500 (EST)
Received: by mail-qk0-f176.google.com with SMTP id x1so63602197qkc.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 00:12:57 -0800 (PST)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id q205si39253123qhq.67.2016.02.16.00.12.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 00:12:56 -0800 (PST)
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 16 Feb 2016 01:12:55 -0700
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id E4F9A3E40030
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 01:12:52 -0700 (MST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1G8Cqx520906226
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 08:12:52 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1G8CqAI021179
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 03:12:52 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 08/29] mm: Some arch may want to use HPAGE_PMD related values as variables
In-Reply-To: <20160215041153.GC3797@oak.ozlabs.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1454923241-6681-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20160215041153.GC3797@oak.ozlabs.ibm.com>
Date: Tue, 16 Feb 2016 13:42:42 +0530
Message-ID: <874md9f4zp.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@ozlabs.org> writes:

> On Mon, Feb 08, 2016 at 02:50:20PM +0530, Aneesh Kumar K.V wrote:
>> With next generation power processor, we are having a new mmu model
>> [1] that require us to maintain a different linux page table format.
>> 
>> Inorder to support both current and future ppc64 systems with a single
>> kernel we need to make sure kernel can select between different page
>> table format at runtime. With the new MMU (radix MMU) added, we will
>> have two different pmd hugepage size 16MB for hash model and 2MB for
>> Radix model. Hence make HPAGE_PMD related values as a variable.
>
> But this patch doesn't actually turn any constant into a variable, as
> far as I can see...

This get done in a later patch where we rename PMD_SHIFT to H_PMD_SHIFT.
[PATCH V2 15/29] powerpc/mm: Rename hash specific page table bits (_PAGE* -> H_PAGE*)

>
> Most of what this patch does is to move two tests around:
>
> * The #if HPAGE_PMD_ORDER >= MAX_ORDER test get moved from a generic
> header into all archs except powerpc, and for powerpc it gets turned
> into BUILD_BUG_ON.  However, BUILD_BUG_ON only works on things that
> are known at compile time, last time I looked.  Doesn't it need to be
> a BUG_ON to prepare for HPAGE_PMD_ORDER being a variable that isn't
> known at compile time?
>
> * The existing BUILD_BUG_ON(HPAGE_PMD_ORDER < 2) gets turned into #if
> for all archs except powerpc, and for powerpc it stays as a
> BUILD_BUG_ON but gets moved to arch code.  That doesn't really seem to
> accomplish anything.  Once again, doesn't it need to become a BUG_ON?
> If so, could we just make it BUG_ON in the generic code where the
> BUILD_BUG_ON currently is?

The patch actually got updated after feedback from Kirill
Updated patch here. We still want to fail during build for ppc64. So
there is a BUILD_BUG_ON also added

http://article.gmane.org/gmane.linux.kernel/2148538

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
