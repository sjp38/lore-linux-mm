Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A34B36B0003
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 05:09:01 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 98so20008303qkp.22
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 02:09:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m2si3874794qtd.356.2018.11.05.02.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 02:09:00 -0800 (PST)
Subject: Re: [kvm PATCH v6 2/2] kvm: x86: Dynamically allocate guest_fpu
References: <20181031234928.144206-1-marcorr@google.com>
 <20181031234928.144206-3-marcorr@google.com>
 <86c27c0c-1326-c757-9b43-251f2290182b@intel.com>
 <CAA03e5EU9j3tCLH=ZU8T4vz_N=D+2os_s8VcAYjC-o9cu-TJ0g@mail.gmail.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <9c64321a-0050-c03e-b164-ab5782b70058@redhat.com>
Date: Mon, 5 Nov 2018 11:08:53 +0100
MIME-Version: 1.0
In-Reply-To: <CAA03e5EU9j3tCLH=ZU8T4vz_N=D+2os_s8VcAYjC-o9cu-TJ0g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>, dave.hansen@intel.com
Cc: kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, Wanpeng Li <kernellwp@gmail.com>

On 01/11/2018 18:35, Marc Orr wrote:
> Good question. Configuring the usercopy kmem cache to restrict access
> beyond fpu_user_xstate_size bytes (rather than fpu_kernel_xstate_size
> bytes) from the beginning of the state field seems intuitive to me,
> but I'm honestly not familiar with what user space expects KVM to
> return through the ioctls. Can someone familiar with this suggest what
> to do? Otherwise, I can update the patch to use the non-usercopy
> variant.

Similar to signal context, KVM always converts to non-compacted format
when copying out to userspace.  KVM also needs to transmit supervisor
states, but that is done through KVM_GET/SET_MSRS rather than
KVM_GET/SET_XSAVE.

In addition, the userspace areas that are pointed to by the argument of
KVM_GET/SET_XSAVE and KVM_GET/SET_FPU are always accessed via
copy_to_user and memdup_user, in order to avoid possible TOCTTOU races.
 Therefore, guest_fpu should not be usercopy at all.

Paolo
