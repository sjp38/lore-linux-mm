Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id AFE956B0010
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 01:46:30 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id h8so2160276otb.4
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 22:46:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q62-v6si179065oia.15.2018.10.02.22.46.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 22:46:29 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w935hr6g014291
	for <linux-mm@kvack.org>; Wed, 3 Oct 2018 01:46:29 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mvqhngp67-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 Oct 2018 01:46:29 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <daniel@linux.ibm.com>;
	Tue, 2 Oct 2018 23:46:28 -0600
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 03 Oct 2018 15:47:35 +1000
From: Daniel Black <daniel@linux.ibm.com>
Subject: Re: [PATCH] mm: madvise(MADV_DODUMP) allow hugetlbfs pages
In-Reply-To: <ecbe3fad-4ab7-6549-bafb-5f24ccc36e74@oracle.com>
References: <20180930054629.29150-1-daniel@linux.ibm.com>
 <ecbe3fad-4ab7-6549-bafb-5f24ccc36e74@oracle.com>
Message-Id: <20181003074520.460bbf17@volution>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, khlebnikov@openvz.org

On Mon, 1 Oct 2018 15:11:32 -0700
Mike Kravetz <mike.kravetz@oracle.com> wrote:

> On 9/29/18 10:46 PM, Daniel Black wrote:
> <snip>
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 972a9eaa898b..71d21df2a3f3 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -96,7 +96,7 @@ static long madvise_behavior(struct
> > vm_area_struct *vma, new_flags |= VM_DONTDUMP;
> >  		break;
> >  	case MADV_DODUMP:
> > -		if (new_flags & VM_SPECIAL) {
> > +		if (!is_vm_hugetlb_page(vma) && new_flags &
> > VM_SPECIAL) {
> 
> Thanks Daniel,
> 
> This is certainly a regression.  My only question is whether this
> condition should be more specific and test the default hugetlb vma
> flags (VM_DONTEXPAND | VM_HUGETLB).

>  Or, whether simply checking
> VM_HUGETLB as you have done above is sufficient.

The is_vm_hugetlb_page() function seems widely used elsewhere for that
single purpose.

> Only reason for
> concern is that I am not 100% certain other VM_SPECIAL flags could
> not be set in VM_HUGETLB vma.

They might be, but being a VM_HUGETLB flag is the main criteria for
being able to madvise(DODUMP) on the memory. It highlight its user
memory for the user to do as they wish.

When 314e51b9851b was added, it seemed the direction was to kill of the
VM_RESERVED, now a few years later VM_SPECIAL seems to be replacing
this. I think it would be better to preserve the original goal and
keep flags having a single meaning.

The purpose in 0103bd16fb90 as I surmise it, is that VM_IO | VM_PFNMAP
| VM_MIXEDMAP are the true things that want to be prevented from having
madvise(DO_DUMP) on them, based on frequent use of DONT_DUMP with those
memory pages. Was VM_DONTEXPAND an intentional inclusion there it did it
just get included with VM_SPECIAL?

Either way, I've tried to keep to the principles of the
is_vm_hugetlb_page function being the authoritative source of a HUGETLB
page.

> Perhaps Konstantin has an opinion as he did a bunch of the vm_flag
> reorg.
> 

Thanks for the review.
