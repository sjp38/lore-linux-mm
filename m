Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE3536B0006
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 10:11:08 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id n5-v6so12378094plp.16
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 07:11:08 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id p67-v6si29950174pfp.68.2018.10.31.07.11.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 07:11:07 -0700 (PDT)
Subject: Re: [kvm PATCH v5 2/4] kvm: x86: Dynamically allocate guest_fpu
References: <20181031132634.50440-1-marcorr@google.com>
 <20181031132634.50440-3-marcorr@google.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <cf476e07-e2fc-45c9-7259-3952a5cbb30e@intel.com>
Date: Wed, 31 Oct 2018 07:11:05 -0700
MIME-Version: 1.0
In-Reply-To: <20181031132634.50440-3-marcorr@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>, kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, kernellwp@gmail.com

On 10/31/18 6:26 AM, Marc Orr wrote:
>  	r = -ENOMEM;
> +	x86_fpu_cache = kmem_cache_create_usercopy(
> +				"x86_fpu",
> +				sizeof(struct fpu),
> +				__alignof__(struct fpu),
> +				SLAB_ACCOUNT,
> +				offsetof(struct fpu, state),
> +				sizeof_field(struct fpu, state),
> +				NULL);

We should basically never be using sizeof(struct fpu), anywhere.  As you
saw, it's about a page in size, but the actual hardware FPU structure
can be as small as ~500 bytes or as big as ~3k.  Doing it this way is a
pretty unnecessary waste of memory because sizeof(struct fpu) is sized
for the worst-case (largest) possible XSAVE buffer that we support on
*any* CPU.  It will also get way worse if anyone ever throws a bunch
more state into the XSAVE area and we need to make it way bigger.

If you want a kmem cache for this, I'd suggest creating a cache which is
the size of the host XSAVE buffer.  That can be found in a variable
called 'fpu_kernel_xstate_size'.  I'm assuming here that the guest FPU
is going to support a strict subset of host kernel XSAVE states.

The other alternative is to calculate the actual size of the XSAVE
buffer that the guest needs.  You can do that from the values that KVM
sets to limit guest XCR0 values (the name of the control field is
escaping me at the moment).
