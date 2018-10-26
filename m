Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC70C6B031C
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 10:49:11 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g63-v6so940716pfc.9
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 07:49:11 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id w17-v6si7420685pgg.489.2018.10.26.07.49.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 07:49:10 -0700 (PDT)
Subject: Re: [kvm PATCH v4 0/2] use vmalloc to allocate vmx vcpus
References: <20181026075900.111462-1-marcorr@google.com>
 <20181026122948.GQ25444@bombadil.infradead.org>
 <20181026144528.GS25444@bombadil.infradead.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <cd9934d3-2699-d705-9e66-88485fc74ead@intel.com>
Date: Fri, 26 Oct 2018 07:49:09 -0700
MIME-Version: 1.0
In-Reply-To: <20181026144528.GS25444@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Marc Orr <marcorr@google.com>
Cc: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, sean.j.christopherson@intel.com, Dave Hansen <dave.hansen@linux.intel.com>

On 10/26/18 7:45 AM, Matthew Wilcox wrote:
>         struct fpu                 user_fpu;             /*  2176  4160 */
>         struct fpu                 guest_fpu;            /*  6336  4160 */

Those are *not* supposed to be embedded in any other structures.  My bad
for not documenting this better.

It also seems really goofy that we need an xsave buffer in the
task_struct for user fpu state, then another in the vcpu.  Isn't one for
user state enough?

In any case, I'd suggest getting rid of 'user_fpu', then either moving
'guest_fpu' to the bottom of the structure, or just make it a 'struct
fpu *' and dynamically allocating it separately.

To do this, I'd take fpu__init_task_struct_size(), and break it apart a
bit to tell you the size of the 'struct fpu' separately from the size of
the 'task struct'.
