Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 96FB46B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 17:23:13 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so101344926pac.3
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 14:23:13 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id yp1si23872831pbc.152.2015.10.22.14.23.10
        for <linux-mm@kvack.org>;
        Thu, 22 Oct 2015 14:23:10 -0700 (PDT)
Subject: Re: [PATCH 15/25] x86, pkeys: check VMAs and PTEs for protection keys
References: <20150928191817.035A64E2@viggo.jf.intel.com>
 <20150928191823.CAE64CF3@viggo.jf.intel.com>
 <20151022205746.GA3045@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <562953BC.9070003@sr71.net>
Date: Thu, 22 Oct 2015 14:23:08 -0700
MIME-Version: 1.0
In-Reply-To: <20151022205746.GA3045@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

On 10/22/2015 01:57 PM, Jerome Glisse wrote:
> I have not read all the patches, but here i assume that for GUP you do
> not first call arch_vma_access_permitted(). So issue i see is that GUP
> for a process might happen inside another process and that process might
> have different pkru protection keys, effectively randomly allowing or
> forbidding a device driver to perform a GUP from say some workqueue that
> just happen to be schedule against a different processor/thread than the
> one against which it is doing the GUP for.

There are some places where there is no real context from which we can
determine access rights.  ptrace is a good example.  We don't enforce
PKEYs when walking _another_ process's page tables.

Can you give an example of where a process might be doing a gup and it
is completely separate from the CPU context that it's being executed under?

> Second and more fundamental thing i have issue with is that this whole
> pkru keys are centric to CPU POV ie this is a CPU feature. So i do not
> believe that device driver should be forbidden to do GUP base on pkru
> keys.

I don't think of it as something necessarily central to the CPU, but
something central to things that walk page tables.  We mark page tables
with PKEYs and things that walk them will have certain rights.

> Tying this to the pkru reg value of whatever processor happens to be
> running some device driver kernel function that try to do a GUP seems
> broken to me.

That's one way to look at it.  Another way is that PKRU is specifying
some real _intent_ about whether we want access to be allowed to some
memory.

> So as first i would just allow GUP to always work and then come up with
> syscall to allow to set pkey on device file. This obviously is a lot more
> work as you need to go over all device driver using GUP.

I wouldn't be opposed to adding some context to the thread (like
pagefault_disable()) that indicates whether we should enforce protection
keys.  If we are in some asynchronous context, disassociated from the
running CPU's protection keys, we could set a flag.

I'd really appreciate if you could point to some concrete examples here
which could actually cause a problem, like workqueues doing gups.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
