Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id A044B8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 05:28:32 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id y85so2029665wmc.7
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 02:28:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y140sor8172346wmd.12.2018.12.21.02.28.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 02:28:31 -0800 (PST)
Subject: Re: [kvm PATCH v7 2/2] kvm: x86: Dynamically allocate guest_fpu
References: <20181106222009.90833-1-marcorr@google.com>
 <20181106222009.90833-3-marcorr@google.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <fe4cff79-f24e-4eb0-a28c-ca770e3186df@redhat.com>
Date: Fri, 21 Dec 2018 11:28:29 +0100
MIME-Version: 1.0
In-Reply-To: <20181106222009.90833-3-marcorr@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>, kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, kernellwp@gmail.com
Cc: Dave Hansen <dave.hansen@intel.com>

On 06/11/18 23:20, Marc Orr wrote:
> +	x86_fpu_cache = kmem_cache_create_usercopy(
> +				"x86_fpu",
> +				fpu_kernel_xstate_size,

This unfortunately is wrong because there are other members in struct
fpu before the fpregs_state union.  It's enough to run a guest and then
rmmod kvm to see slub errors which are actually caused by memory
corruption.

The right way to size it is shown in fpu__init_task_struct_size but for
now I'll revert it to sizeof(struct fpu).  I have plans to move
fsave/fxsave/xsave directly in KVM, without using the kernel FPU
helpers, and actually this guest_fpu thing will come in handy for that.
:)  Once it's done, the size of the object in the cache will be
something like kvm_xstate_size.

Paolo


> +				__alignof__(struct fpu),
> +				SLAB_ACCOUNT,
> +				offsetof(struct fpu, state),
> +				fpu_kernel_xstate_size,
> +				NULL);
