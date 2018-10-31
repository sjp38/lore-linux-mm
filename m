Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDF86B0005
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 10:19:21 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v10-v6so11056031wrw.12
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 07:19:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v3-v6sor18163075wrw.43.2018.10.31.07.19.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 07:19:20 -0700 (PDT)
MIME-Version: 1.0
References: <20181031132634.50440-1-marcorr@google.com> <20181031132634.50440-4-marcorr@google.com>
 <ea8abaf5-8c8b-1484-c6d7-e5d110e45f48@intel.com> <20181031141547.GA13907@linux.intel.com>
In-Reply-To: <20181031141547.GA13907@linux.intel.com>
From: Marc Orr <marcorr@google.com>
Date: Wed, 31 Oct 2018 14:19:08 +0000
Message-ID: <CAA03e5GzBSg_ZkfX0DGd4a1tPAoP_71Q-L3px62htB0-vzqhAQ@mail.gmail.com>
Subject: Re: [kvm PATCH v5 3/4] kvm: vmx: refactor vmx_msrs struct for vmalloc
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sean.j.christopherson@intel.com
Cc: dave.hansen@intel.com, kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, dave.hansen@linux.intel.com, Wanpeng Li <kernellwp@gmail.com>

On Wed, Oct 31, 2018 at 7:15 AM Sean Christopherson
<sean.j.christopherson@intel.com> wrote:
>
> On Wed, Oct 31, 2018 at 07:12:16AM -0700, Dave Hansen wrote:
> > On 10/31/18 6:26 AM, Marc Orr wrote:
> > > +/*
> > > + * To prevent vmx_msr_entry array from crossing a page boundary, require:
> > > + * sizeof(*vmx_msrs.vmx_msr_entry.val) to be a power of two. This is guaranteed
> > > + * through compile-time asserts that:
> > > + *   - NR_AUTOLOAD_MSRS * sizeof(struct vmx_msr_entry) is a power of two
> > > + *   - NR_AUTOLOAD_MSRS * sizeof(struct vmx_msr_entry) <= PAGE_SIZE
> > > + *   - The allocation of vmx_msrs.vmx_msr_entry.val is aligned to its size.
> > > + */
> >
> > Why do we need to prevent them from crossing a page boundary?
>
> The VMCS takes the physical address of the load/store lists.  I
> requested that this information be added to the changelog.  Marc
> deferred addressing my comments since there's a decent chance
> patches 3/4 and 4/4 will be dropped in the end.

Exactly. And the code (in these patches) to map these virtual address
to physical addresses operates at page granularity, and will break for
memory that spans a single page.
