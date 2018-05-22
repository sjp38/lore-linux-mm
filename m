Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4F8A6B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 13:51:20 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d9-v6so12608236plj.4
        for <linux-mm@kvack.org>; Tue, 22 May 2018 10:51:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f64-v6si17081131plf.496.2018.05.22.10.51.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 22 May 2018 10:51:19 -0700 (PDT)
Date: Tue, 22 May 2018 10:51:14 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
Message-ID: <20180522175114.GA1237@bombadil.infradead.org>
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514191551.GA27939@bombadil.infradead.org>
 <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
 <20180515004137.GA5168@bombadil.infradead.org>
 <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
 <010001637399f796-3ffe3ed2-2fb1-4d43-84f0-6a65b6320d66-000000@email.amazonses.com>
 <5aea6aa0-88cc-be7a-7012-7845499ced2c@netapp.com>
 <50cbc27f-0014-0185-048d-25640f744b5b@linux.intel.com>
 <0100016388be5738-df8f9d12-7011-4e4e-ba5b-33973e5da794-000000@email.amazonses.com>
 <c4bb7ea8-16d5-ca31-2a9b-db90841211ba@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c4bb7ea8-16d5-ca31-2a9b-db90841211ba@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Christopher Lameter <cl@linux.com>, Boaz Harrosh <boazh@netapp.com>, Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On Tue, May 22, 2018 at 10:03:54AM -0700, Dave Hansen wrote:
> On 05/22/2018 09:46 AM, Christopher Lameter wrote:
> > On Tue, 22 May 2018, Dave Hansen wrote:
> > 
> >> On 05/22/2018 09:05 AM, Boaz Harrosh wrote:
> >>> How can we implement "Private memory"?
> >> Per-cpu page tables would do it.
> > We already have that for percpu subsystem. See alloc_percpu()
> 
> I actually mean a set of page tables which is only ever installed on a
> single CPU.  The CPU is architecturally allowed to go load any PTE in
> the page tables into the TLB any time it feels like.  The only way to
> keep a PTE from getting into the TLB is not ensure that a CPU never has
> any access to it, and the only way to do that is to make sure that no
> set of page tables it ever loads into CR3 have that PTE.
> 
> As Peter said, it's possible, but not pretty.

But CR3 is a per-CPU register.  So it'd be *possible* to allocate one
PGD per CPU (per process).  Have them be identical in all but one of
the PUD entries.  Then you've reserved 1/512 of your address space for
per-CPU pages.

Complicated, ugly, memory-consuming.  But possible.
