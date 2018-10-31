Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 849466B000A
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 17:21:29 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id n9-v6so14701582pfg.12
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 14:21:29 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id m3-v6si27622972pgr.32.2018.10.31.14.21.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 14:21:28 -0700 (PDT)
Subject: Re: [kvm PATCH v5 2/4] kvm: x86: Dynamically allocate guest_fpu
References: <20181031132634.50440-1-marcorr@google.com>
 <20181031132634.50440-3-marcorr@google.com>
 <cf476e07-e2fc-45c9-7259-3952a5cbb30e@intel.com>
 <CAA03e5HmMq-+9WsJ+Kd05ary85A7HJ5HJbNMUzc87QCRxamJGg@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <4094fe59-a161-99f0-e3cd-7ac14eb9f5a4@intel.com>
Date: Wed, 31 Oct 2018 14:21:27 -0700
MIME-Version: 1.0
In-Reply-To: <CAA03e5HmMq-+9WsJ+Kd05ary85A7HJ5HJbNMUzc87QCRxamJGg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>
Cc: kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, Wanpeng Li <kernellwp@gmail.com>

On 10/31/18 2:13 PM, Marc Orr wrote:
> KVM explicitly cast guest_fpu.state as a fxregs_state in a few
> places (e.g., the ioctls). Yet, I see a code path in 
> fpu__init_system_xstate_size_legacy() that sets
> fpu_kernel_xstate_size to sizeof(struct fregs_state). Will this cause
> problems? You mentioned that the fpu's state field is expected to
> range from ~500 bytes to ~3k, which implies that it should never get
> set to sizeof(struct fregs_state). But I want to confirm.

It can get set to sizeof(struct fregs_state) for systems where XSAVE is
not in use.  I was neglecting to mention those when I said the "~500
byte" number.

My point was that it can vary wildly and that any static allocation
scheme will waste lots of memory when we have small hardware-supported
buffers.
