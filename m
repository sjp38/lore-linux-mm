Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6C93F6B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 18:25:26 -0400 (EDT)
Received: by qgbb65 with SMTP id b65so70034925qgb.2
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 15:25:26 -0700 (PDT)
Received: from mail-qk0-x234.google.com (mail-qk0-x234.google.com. [2607:f8b0:400d:c09::234])
        by mx.google.com with ESMTPS id r64si15621147qki.12.2015.10.22.15.25.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 15:25:25 -0700 (PDT)
Received: by qkcy65 with SMTP id y65so60538311qkc.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 15:25:25 -0700 (PDT)
Date: Thu, 22 Oct 2015 18:25:16 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 15/25] x86, pkeys: check VMAs and PTEs for protection keys
Message-ID: <20151022222515.GA3511@gmail.com>
References: <20150928191817.035A64E2@viggo.jf.intel.com>
 <20150928191823.CAE64CF3@viggo.jf.intel.com>
 <20151022205746.GA3045@gmail.com>
 <562953BC.9070003@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <562953BC.9070003@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

On Thu, Oct 22, 2015 at 02:23:08PM -0700, Dave Hansen wrote:
> On 10/22/2015 01:57 PM, Jerome Glisse wrote:
> > I have not read all the patches, but here i assume that for GUP you do
> > not first call arch_vma_access_permitted(). So issue i see is that GUP
> > for a process might happen inside another process and that process might
> > have different pkru protection keys, effectively randomly allowing or
> > forbidding a device driver to perform a GUP from say some workqueue that
> > just happen to be schedule against a different processor/thread than the
> > one against which it is doing the GUP for.
> 
> There are some places where there is no real context from which we can
> determine access rights.  ptrace is a good example.  We don't enforce
> PKEYs when walking _another_ process's page tables.
> 
> Can you give an example of where a process might be doing a gup and it
> is completely separate from the CPU context that it's being executed under?

In drivers/iommu/amd_iommu_v2.c thought this is on AMD platform. I also
believe that in infiniband one can have GUP call from workqueue that can
run at any time. In GPU driver we also use GUP thought at this point we
do not allow another process from accessing a buffer that is populated
by GUP from another process.

I am also here mainly talking about what future GPU will do where you will
have the CPU service page fault from GPU inside a workqueue that can run
at any point in time.

> 
> > Second and more fundamental thing i have issue with is that this whole
> > pkru keys are centric to CPU POV ie this is a CPU feature. So i do not
> > believe that device driver should be forbidden to do GUP base on pkru
> > keys.
> 
> I don't think of it as something necessarily central to the CPU, but
> something central to things that walk page tables.  We mark page tables
> with PKEYs and things that walk them will have certain rights.

My point is that we are seing devices that want to walk the page table and
they do it from a work queue inside the kernel which can run against another
process than the one they are doing the walk from.

I am sure there is already upstream device driver that does so, i have not
check all of them to confirm thought.


> > Tying this to the pkru reg value of whatever processor happens to be
> > running some device driver kernel function that try to do a GUP seems
> > broken to me.
> 
> That's one way to look at it.  Another way is that PKRU is specifying
> some real _intent_ about whether we want access to be allowed to some
> memory.

I think i misexpress myself here, yes PKRU is about specifying intent but
specifying it for CPU thread not for device thread. GPU for instance have
threads that run on behalf of a given process and i would rather see some
kind of coherent way to specify that for each devices like you allow it
to specify it on per CPU thread basis.


> > So as first i would just allow GUP to always work and then come up with
> > syscall to allow to set pkey on device file. This obviously is a lot more
> > work as you need to go over all device driver using GUP.
> 
> I wouldn't be opposed to adding some context to the thread (like
> pagefault_disable()) that indicates whether we should enforce protection
> keys.  If we are in some asynchronous context, disassociated from the
> running CPU's protection keys, we could set a flag.

I was simply thinking of having a global set of pkeys against the process
mm struct which would be the default global setting for all device GUP
access. This global set could be override by userspace on a per device
basis allowing some device to have more access than others.


> I'd really appreciate if you could point to some concrete examples here
> which could actually cause a problem, like workqueues doing gups.

Well i could grep for all current user of GUP, but i can tell you that this
is gonna be the model for GPU thread ie a kernel workqueue gonna handle
page fault on behalf of GPU and will perform equivalent of GUP. Also apply
for infiniband ODP thing which is upstream.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
