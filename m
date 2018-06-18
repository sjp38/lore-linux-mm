Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62D796B0003
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 09:33:16 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t5-v6so5184595pgt.18
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 06:33:16 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q10-v6si11980959pgf.547.2018.06.18.06.33.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 06:33:15 -0700 (PDT)
Date: Mon, 18 Jun 2018 16:33:12 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 15/17] x86/mm: Implement sync_direct_mapping()
Message-ID: <20180618133312.kb6j25jvf6dr7dvh@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-16-kirill.shutemov@linux.intel.com>
 <41c9db7f-2277-4403-5556-df56b686d5c8@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41c9db7f-2277-4403-5556-df56b686d5c8@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 13, 2018 at 06:41:21PM +0000, Dave Hansen wrote:
> On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> >  arch/x86/include/asm/mktme.h |   6 +
> >  arch/x86/mm/init_64.c        |   6 +
> >  arch/x86/mm/mktme.c          | 444 +++++++++++++++++++++++++++++++++++
> >  3 files changed, 456 insertions(+)
> 
> Can we not do any better than 400 lines of new open-coded pagetable
> hacking?

It's not pretty, but I don't see much options.

I first tried to modify routines that initialize/modify/remove parts of
direct mapping to keep all per-KeyID direct mappings in sync from start.
But it didn't really fly. We need to initialize direct mapping very early
when we don't have a way to allocated page in a usual way. We have very
limited pool of pre-allocated pages to allocate page tables from and it's
not able to satisfy demand for multiple direct mappings.

So I had to go with syncing it later on. When we have working page
allocator.

Regarding open-codeness, we need to walk two subtrees in lock steps.
I don't see how get mm/pagewalk.c to work in such use case. (And I don't
really like callback-based pagewalker.)

-- 
 Kirill A. Shutemov
