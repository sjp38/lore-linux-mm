Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC6C48E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 11:40:09 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e29so49475ede.19
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 08:40:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m23si688567eda.188.2019.01.14.08.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 08:40:08 -0800 (PST)
Date: Mon, 14 Jan 2019 17:40:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: align anon mmap for THP
Message-ID: <20190114164004.GL21345@dhcp22.suse.cz>
References: <20190111201003.19755-1-mike.kravetz@oracle.com>
 <20190111215506.jmp2s5end2vlzhvb@black.fi.intel.com>
 <ebd57b51-117b-4a3d-21d9-fc0287f437d6@oracle.com>
 <20190114135001.w2wpql53zitellus@kshutemo-mobl1>
 <MWHPR06MB2896ACD09C21B2939959C8A8EE800@MWHPR06MB2896.namprd06.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <MWHPR06MB2896ACD09C21B2939959C8A8EE800@MWHPR06MB2896.namprd06.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Harrosh, Boaz" <Boaz.Harrosh@netapp.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Toshi Kani <toshi.kani@hpe.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon 14-01-19 16:29:29, Harrosh, Boaz wrote:
>  Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > On Fri, Jan 11, 2019 at 03:28:37PM -0800, Mike Kravetz wrote:
> >> Ok, I just wanted to ask the question.  I've seen application code doing
> >> the 'mmap sufficiently large area' then unmap to get desired alignment
> >> trick.  Was wondering if there was something we could do to help.
> >
> > Application may want to get aligned allocation for different reasons.
> > It should be okay for userspace to ask for size + (alignment - PAGE_SIZE)
> > and then round up the address to get the alignment. We basically do the
> > same on kernel side.
> >
> 
> This is what we do and will need to keep doing for old Kernels.
> But it is a pity that those holes can not be reused for small maps, and most important
> that we cannot have "mapping holes" around the mapping that catch memory
> overruns

What does prevent you from mapping a larger area and MAP_FIXED,
PROT_NONE over it to get the protection?
 
> > For THP, I believe, kernel already does The Right Thing™ for most users.
> > User still may want to get speific range as THP (to avoid false sharing or
> > something).
> 
> I'm an OK Kernel programmer.  But I was not able to create a HugePage mapping
> against /dev/shm/ in a reliable way. I think it only worked on Fedora 28/29
> but not on any other distro/version. (MMAP_HUGE)

Are you mixing hugetlb rather than THP?

> We run with our own compiled Kernel on various distros, THP is configured
> in but mmap against /dev/shm/ never gives me Huge pages. Does it only
> work with unanimous mmap ? (I think it is mount dependent which is not
> in the application control)

If you are talking about THP then you have to enable huge pages for the
mapping AFAIR.
-- 
Michal Hocko
SUSE Labs
