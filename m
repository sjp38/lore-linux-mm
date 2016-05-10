Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 275D46B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 09:34:08 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id e126so24573642vkb.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 06:34:08 -0700 (PDT)
Received: from mail-qg0-x241.google.com (mail-qg0-x241.google.com. [2607:f8b0:400d:c04::241])
        by mx.google.com with ESMTPS id l65si1431053qgd.61.2016.05.10.06.34.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 06:34:07 -0700 (PDT)
Received: by mail-qg0-x241.google.com with SMTP id e35so752189qge.1
        for <linux-mm@kvack.org>; Tue, 10 May 2016 06:34:07 -0700 (PDT)
Date: Tue, 10 May 2016 15:34:01 +0200
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [Question] Missing data after DMA read transfer - mm issue with
 transparent huge page?
Message-ID: <20160510133401.GB18820@gmail.com>
References: <15edf085-c21b-aa1c-9f1f-057d17b8a1a3@morey-chaisemartin.com>
 <alpine.LSU.2.11.1605022020560.5004@eggly.anvils>
 <20160503101153.GA7241@gmail.com>
 <07619be9-e812-5459-26dd-ceb8c6490520@morey-chaisemartin.com>
 <20160510100104.GA18820@gmail.com>
 <80f878a0-f71b-2969-f2eb-05f4509ff58a@morey-chaisemartin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <80f878a0-f71b-2969-f2eb-05f4509ff58a@morey-chaisemartin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Morey Chaisemartin <devel@morey-chaisemartin.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alex Williamson <alex.williamson@redhat.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 10, 2016 at 01:15:02PM +0200, Nicolas Morey Chaisemartin wrote:
> Le 05/10/2016 a 12:01 PM, Jerome Glisse a ecrit :
> > On Tue, May 10, 2016 at 09:04:36AM +0200, Nicolas Morey Chaisemartin wrote:
> >> Le 05/03/2016 a 12:11 PM, Jerome Glisse a ecrit :
> >>> On Mon, May 02, 2016 at 09:04:02PM -0700, Hugh Dickins wrote:
> >>>> On Fri, 29 Apr 2016, Nicolas Morey Chaisemartin wrote:

[...]

> >> Hi,
> >>
> >> I backported the patch to 3.10 (had to copy paste pmd_protnone defitinition from 4.5) and it's working !
> >> I'll open a ticket in Redhat tracker to try and get this fixed in RHEL7.
> >>
> >> I have a dumb question though: how can we end up in numa/misplaced memory code on a single socket system?
> >>
> > This patch is not a fix, do you see bug message in kernel log ? Because if
> > you do that it means we have a bigger issue.
> I don't see any on my 3.10. I have DMA_API_DEBUG enabled but I don't think it has an impact.

My patch can't be backported to 3.10 as is, you most likely need to replace
pmd_protnone() by pmd_numa()

> > You did not answer one of my previous question, do you set get_user_pages
> > with write = 1 as a paremeter ?
> For the read from the device, yes:
>         down_read(&current->mm->mmap_sem);
>         res = get_user_pages(
>                 current,
>                 current->mm,
>                 (unsigned long) iov->host_addr,
>                 page_count,
>                 (write_mode == 0) ? 1 : 0,      /* write */
>                 0,      /* force */
>                 &trans->pages[sg_o],
>                 NULL);
>         up_read(&current->mm->mmap_sem);

As i don't have context to infer how write_mode is set above, do you mind
retesting your driver and always asking for write no matter what ?

> > Also it would be a lot easier if you were testing with lastest 4.6 or 4.5
> > not RHEL kernel as they are far appart and what might looks like same issue
> > on both might be totaly different bugs.
> Is a RPM from elrepo ok?
> http://elrepo.org/linux/kernel/el7/SRPMS/

Yes should be ok for testing.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
