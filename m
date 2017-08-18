Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1012F6B025F
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 09:57:41 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y129so173497821pgy.1
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 06:57:41 -0700 (PDT)
Received: from mail-pg0-f44.google.com (mail-pg0-f44.google.com. [74.125.83.44])
        by mx.google.com with ESMTPS id v22si3690595pfl.72.2017.08.18.06.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 06:57:39 -0700 (PDT)
Received: by mail-pg0-f44.google.com with SMTP id y129so64985848pgy.4
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 06:57:39 -0700 (PDT)
Subject: Re: [kernel-hardening] [RFC] memory allocations in genalloc
References: <299c22f9-2e34-36dc-a6da-22eadbc0a59d@huawei.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <bea38f28-b311-dd54-9323-f90e2b157e35@redhat.com>
Date: Fri, 18 Aug 2017 06:57:37 -0700
MIME-Version: 1.0
In-Reply-To: <299c22f9-2e34-36dc-a6da-22eadbc0a59d@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, Jes Sorensen <jes@trained-monkey.org>
Cc: Michal Hocko <mhocko@kernel.org>, James Morris <james.l.morris@oracle.com>, Jerome Glisse <jglisse@redhat.com>, Paul Moore <paul@paul-moore.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, linux-security-module@vger.kernel.org

On 08/17/2017 09:26 AM, Igor Stoppa wrote:
> Foreword:
> If I should direct this message to someone else, please let me know.
> I couldn't get a clear idea, by looking at both MAINTAINERS and git blame.
> 
> ****
> 
> Hi,
> 
> I'm currently trying to convert the SE Linux policy db into using a
> protectable memory allocator (pmalloc) that I have developed.
> 
> Such allocator is based on genalloc: I had come up with an
> implementation that was pretty similar to what genalloc already does, so
> it was pointed out to me that I could have a look at it.
> 
> And, indeed, it seemed a perfect choice.
> 
> But ... when freeing memory, genalloc wants that the caller also states
> how large each specific memory allocation is.
> 
> This, per se, is not an issue, although genalloc doesn't seen to check
> if the memory being freed is really matching a previous allocation request.
> 
> However, this design doesn't sit well with the use case I have in mind.
> 
> In particular, when the SE Linux policy db is populated, the creation of
> one or more specific entry of the db might fail.
> In this case, the memory previously allocated for said entry, is
> released with kfree, which doesn't need to know the size of the chunk
> being freed.
> 
> I would like to add similar capability to genalloc.
> 
> genalloc already uses bitmaps, to track what words are allocated (1) and
> which are free (0)
> 
> What I would like to do is to add another bitmap, which would track the
> beginning of each individual allocation (1 on the first allocation unit
> of each allocation, 0 otherwise).
> 
> Such enhancement would enable also the detection of calls to free with
> incorrect / misaligned addresses - right now it is possible to
> successfully free a memory area that overlaps the interface of two
> adjacent allocations, without fully covering either of them.
> 
> Would this change be acceptable?
> Is there any better way to achieve what I want?
> 

In general, I don't see anything wrong with wanting to let gen_pool_free
not take a size. It's hard to say anything more without a patch to review.
My biggest concern would be keeping existing behavior and managing two
bitmaps locklessly.


> 
> ---
> 
> I have also a question wrt the use of spinlocks in genalloc.
> Why a spinlock?
> 
> Freeing a chunk of memory previously allocated with vmalloc requires
> invoking vfree_atomic, instead of vfree, because the list of chunks is
> walked with the spinlock held, and vfree can sleep.
> 
> Why not using a mutex?
> 

>From the git history, gen_pool used to use a reader/writer lock and
was switched to be lockless so it could be used in NMI contexts
7f184275aa30 ("lib, Make gen_pool memory allocator lockless").
This looks to be an intentional choice, presumably so regions can be
added in atomic contexts. Again, if you have a specific patch or
proposal this would be easier to review.

Thanks,
Laura


> 
> --
> TIA, igor
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
