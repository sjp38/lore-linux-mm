Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0AC6B000D
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 13:09:29 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id k25-v6so16995757pff.15
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 10:09:29 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id u131-v6si8960195pgc.465.2018.11.01.10.09.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 10:09:27 -0700 (PDT)
Subject: Re: [kvm PATCH v6 2/2] kvm: x86: Dynamically allocate guest_fpu
References: <20181031234928.144206-1-marcorr@google.com>
 <20181031234928.144206-3-marcorr@google.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <86c27c0c-1326-c757-9b43-251f2290182b@intel.com>
Date: Thu, 1 Nov 2018 10:09:26 -0700
MIME-Version: 1.0
In-Reply-To: <20181031234928.144206-3-marcorr@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>, kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, kernellwp@gmail.com

On 10/31/18 4:49 PM, Marc Orr wrote:
> +	if (!boot_cpu_has(X86_FEATURE_FPU) || !boot_cpu_has(X86_FEATURE_FXSR)) {
> +		printk(KERN_ERR "kvm: inadequate fpu\n");
> +		r = -EOPNOTSUPP;
> +		goto out;
> +	}

It would be nice to have a comment about _why_ this is inadequate.

>  	r = -ENOMEM;
> +	x86_fpu_cache = kmem_cache_create_usercopy(
> +				"x86_fpu",

For now, this should probably be kvm_x86_fpu since it's not used as a
generic x86 thing, yet.

Also, why is this a "usercopy"?  "fpu_kernel_xstate_size" includes (or
will soon include) supervisor state which can never be copied to
userspace.  If this structure is going out to userspace, that tells me
we might instead want fpu_user_xstate_size, *or* we want the
non-usercopy variant.
