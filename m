Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3235A6B0271
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 17:44:13 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d8-v6so12724731pgq.3
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 14:44:13 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id t25-v6si23129998pfj.53.2018.10.31.14.44.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 14:44:12 -0700 (PDT)
Subject: Re: [kvm PATCH v5 2/4] kvm: x86: Dynamically allocate guest_fpu
References: <20181031132634.50440-1-marcorr@google.com>
 <20181031132634.50440-3-marcorr@google.com>
 <cf476e07-e2fc-45c9-7259-3952a5cbb30e@intel.com>
 <CAA03e5HmMq-+9WsJ+Kd05ary85A7HJ5HJbNMUzc87QCRxamJGg@mail.gmail.com>
 <4094fe59-a161-99f0-e3cd-7ac14eb9f5a4@intel.com>
 <CAA03e5F7LsYcrr6fgHWdwQ=hyYm2Su7Lqke7==Un7tSp57JtSA@mail.gmail.com>
 <07251c42-e9d9-6428-60cd-6ecbaf78c3a5@intel.com>
 <CAA03e5FBri+LSZoGKJpJJruSEoNZ39DTbJMRhJbatgQAs6BiaA@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <6ebffd2a-a387-ed71-1514-6dff42a35bec@intel.com>
Date: Wed, 31 Oct 2018 14:44:11 -0700
MIME-Version: 1.0
In-Reply-To: <CAA03e5FBri+LSZoGKJpJJruSEoNZ39DTbJMRhJbatgQAs6BiaA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>
Cc: kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, Wanpeng Li <kernellwp@gmail.com>

On 10/31/18 2:39 PM, Marc Orr wrote:
> That makes sense. But my specific concern is the code I've copied
> below, from arch/x86/kvm/x86.c. Notice on a system where
> guest_fpu.state is a fregs_state, this code would generate garbage for
> some fields. With the new code we're talking about, it will cause
> memory corruption. But maybe it's not possible to run this code on a
> system with an fregs_state, because such systems would predate VMX?

Ahh, got it.

So, you *can* clear X86_FEATURE_* bits from the kernel command-line, so
it's theoretically possible to have a system that supports VMX, but
doesn't support a modern MMU.  It's obviously not well tested. :)

The KVM code you pasted, to be "correct" should probably be checking
X86_FEATURE_FXSR and X86_FEATURE_FPU *somewhere*.
