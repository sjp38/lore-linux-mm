Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFB258E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 11:29:31 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id s71so16353734pfi.22
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 08:29:31 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-eopbgr760089.outbound.protection.outlook.com. [40.107.76.89])
        by mx.google.com with ESMTPS id a8si631152pgw.380.2019.01.14.08.29.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Jan 2019 08:29:30 -0800 (PST)
From: "Harrosh, Boaz" <Boaz.Harrosh@netapp.com>
Subject: Re: [RFC PATCH] mm: align anon mmap for THP
Date: Mon, 14 Jan 2019 16:29:29 +0000
Message-ID: 
 <MWHPR06MB2896ACD09C21B2939959C8A8EE800@MWHPR06MB2896.namprd06.prod.outlook.com>
References: <20190111201003.19755-1-mike.kravetz@oracle.com>
 <20190111215506.jmp2s5end2vlzhvb@black.fi.intel.com>
 <ebd57b51-117b-4a3d-21d9-fc0287f437d6@oracle.com>,<20190114135001.w2wpql53zitellus@kshutemo-mobl1>
In-Reply-To: <20190114135001.w2wpql53zitellus@kshutemo-mobl1>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Toshi Kani <toshi.kani@hpe.com>, Andrew Morton <akpm@linux-foundation.org>

 Kirill A. Shutemov <kirill@shutemov.name> wrote:
> On Fri, Jan 11, 2019 at 03:28:37PM -0800, Mike Kravetz wrote:
>> Ok, I just wanted to ask the question.  I've seen application code doing
>> the 'mmap sufficiently large area' then unmap to get desired alignment
>> trick.  Was wondering if there was something we could do to help.
>
> Application may want to get aligned allocation for different reasons.
> It should be okay for userspace to ask for size + (alignment - PAGE_SIZE)
> and then round up the address to get the alignment. We basically do the
> same on kernel side.
>

This is what we do and will need to keep doing for old Kernels.
But it is a pity that those holes can not be reused for small maps, and mos=
t important
that we cannot have "mapping holes" around the mapping that catch memory
overruns

> For THP, I believe, kernel already does The Right Thing=99 for most users=
.
> User still may want to get speific range as THP (to avoid false sharing o=
r
> something).

I'm an OK Kernel programmer.  But I was not able to create a HugePage mappi=
ng
against /dev/shm/ in a reliable way. I think it only worked on Fedora 28/29
but not on any other distro/version. (MMAP_HUGE)

We run with our own compiled Kernel on various distros, THP is configured
in but mmap against /dev/shm/ never gives me Huge pages. Does it only
work with unanimous mmap ? (I think it is mount dependent which is not
in the application control)

Just a rant. One day I will figure this out. Meanwhile I do this ugly
user mode aligns the pointers, and try to sleep at night ...

> But still I believe userspace has all required tools to get it
> right.
>

I still wish that if I ask for an mmap size aligned on 2M that I would auto=
matically
get a 2M pointer. I don't see how the system can benefit from having both e=
nds
of the VMA cross Huge page boundary.

> --
> Kirill A. Shutemov

Thanks
Boaz
