Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC3C6B0266
	for <linux-mm@kvack.org>; Wed, 23 May 2018 13:30:26 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r9-v6so6849139pgp.12
        for <linux-mm@kvack.org>; Wed, 23 May 2018 10:30:26 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id q8-v6si15285215pgp.533.2018.05.23.10.30.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 10:30:24 -0700 (PDT)
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
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
 <20180522175114.GA1237@bombadil.infradead.org>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <5e20be19-28ba-189a-6935-698a012a6665@linux.intel.com>
Date: Wed, 23 May 2018 10:30:23 -0700
MIME-Version: 1.0
In-Reply-To: <20180522175114.GA1237@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christopher Lameter <cl@linux.com>, Boaz Harrosh <boazh@netapp.com>, Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On 05/22/2018 10:51 AM, Matthew Wilcox wrote:
> But CR3 is a per-CPU register.  So it'd be *possible* to allocate one
> PGD per CPU (per process).  Have them be identical in all but one of
> the PUD entries.  Then you've reserved 1/512 of your address space for
> per-CPU pages.
> 
> Complicated, ugly, memory-consuming.  But possible.

Yep, and you'd probably want a cache of them so you don't end up having
to go rewrite half of the PGD every time you context-switch.  But, on
the plus side, the logic would be pretty similar if not identical to the
way that we manage PCIDs.  If your mm was recently active on the CPU,
you can use a PGD that's already been constructed.  If not, you're stuck
making a new one.

Andy L. was alto talking about using this kind of mechanism to simplify
the entry code.  Instead of needing per-cpu areas where we index by the
CPU number, or by using %GS, we could have per-cpu data or code that has
a fixed virtual address.

It'd be a fun project, but it might not ever pan out.
