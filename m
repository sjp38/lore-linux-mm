Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75ED76B026B
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 17:30:16 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f22-v6so12682670pgv.21
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 14:30:16 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b40-v6si15543883pla.285.2018.10.31.14.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 14:30:15 -0700 (PDT)
Subject: Re: [kvm PATCH v5 2/4] kvm: x86: Dynamically allocate guest_fpu
References: <20181031132634.50440-1-marcorr@google.com>
 <20181031132634.50440-3-marcorr@google.com>
 <cf476e07-e2fc-45c9-7259-3952a5cbb30e@intel.com>
 <CAA03e5HmMq-+9WsJ+Kd05ary85A7HJ5HJbNMUzc87QCRxamJGg@mail.gmail.com>
 <4094fe59-a161-99f0-e3cd-7ac14eb9f5a4@intel.com>
 <CAA03e5F7LsYcrr6fgHWdwQ=hyYm2Su7Lqke7==Un7tSp57JtSA@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <07251c42-e9d9-6428-60cd-6ecbaf78c3a5@intel.com>
Date: Wed, 31 Oct 2018 14:30:14 -0700
MIME-Version: 1.0
In-Reply-To: <CAA03e5F7LsYcrr6fgHWdwQ=hyYm2Su7Lqke7==Un7tSp57JtSA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>
Cc: kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, Wanpeng Li <kernellwp@gmail.com>

On 10/31/18 2:24 PM, Marc Orr wrote:
>> It can get set to sizeof(struct fregs_state) for systems where XSAVE is
>> not in use.  I was neglecting to mention those when I said the "~500
>> byte" number.
>>
>> My point was that it can vary wildly and that any static allocation
>> scheme will waste lots of memory when we have small hardware-supported
>> buffers.
> 
> Got it. Then I think we need to set the size for the kmem cache to
> max(fpu_kernel_xstate_size, sizeof(fxregs_state)), unless I'm missing
> something. I'll send out a version of the patch that does this in a
> bit. Thanks!

Despite its name, fpu_kernel_xstate_size *should* always be the "size of
the hardware buffer we need to back 'struct fpu'".  That's true for all
of the various formats we support: XSAVE, fxregs, swregs, etc...

fpu__init_system_xstate_size_legacy() does that when XSAVE itself is not
in play.
