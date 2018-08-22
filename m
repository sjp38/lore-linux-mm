Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 36A2E6B2661
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 17:11:00 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id bh1-v6so1447483plb.15
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 14:11:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6-v6sor710262pgj.274.2018.08.22.14.10.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 14:10:58 -0700 (PDT)
Date: Thu, 23 Aug 2018 00:10:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v8 PATCH 3/5] mm: mmap: zap pages with read mmap_sem in
 munmap
Message-ID: <20180822211053.qg3dlzf6pok2x4yk@kshutemo-mobl1>
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
 <1534358990-85530-4-git-send-email-yang.shi@linux.alibaba.com>
 <e691d054-f807-80ad-9934-a1917d8e2e77@suse.cz>
 <3c62f605-2244-6a05-2dc4-34a3f1c56300@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3c62f605-2244-6a05-2dc4-34a3f1c56300@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, Dave Hansen <dave.hansen@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 22, 2018 at 01:45:44PM -0700, Yang Shi wrote:
> 
> 
> On 8/22/18 4:19 AM, Vlastimil Babka wrote:
> > On 08/15/2018 08:49 PM, Yang Shi wrote:
> > > +	downgrade_write(&mm->mmap_sem);
> > > +
> > > +	/* Zap mappings with read mmap_sem */
> > > +	unmap_region(mm, start_vma, prev, start, end);
> > > +
> > > +	arch_unmap(mm, start_vma, start, end);
> > Hmm, did you check that all architectures' arch_unmap() is safe with
> > read mmap_sem instead of write mmap_sem? E.g. x86 does
> > mpx_notify_unmap() there where I would be far from sure at first glance...
> 
> Yes, I'm also not quite sure if it is 100% safe or not. I was trying to move
> this before downgrade_write, however, I'm not sure if it is ok or not too,
> so I keep the calling sequence.
> 
> For architectures, just x86 and ppc really do something. PPC just uses it
> for vdso unmap which should just happen during process exit, so it sounds
> safe.
> 
> For x86, mpx_notify_unmap() looks finally zap the VM_MPX vmas in bound table
> range with zap_page_range() and doesn't update vm flags, so it sounds ok to
> me since vmas have been detached, nobody can find those vmas. But, I'm not
> familiar with the details of mpx, maybe Kirill could help to confirm this?

I don't see anything obviously dependent on down_write() in
mpx_notify_unmap(), but Dave should know better.

-- 
 Kirill A. Shutemov
