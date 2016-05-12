Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6446882963
	for <linux-mm@kvack.org>; Thu, 12 May 2016 11:57:41 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id e126so163488340vkb.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 08:57:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t4si8959377qkc.66.2016.05.12.08.57.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 08:57:40 -0700 (PDT)
Date: Thu, 12 May 2016 17:57:37 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Question] Missing data after DMA read transfer - mm issue with
 transparent huge page?
Message-ID: <20160512155737.GG19275@redhat.com>
References: <20160503101153.GA7241@gmail.com>
 <07619be9-e812-5459-26dd-ceb8c6490520@morey-chaisemartin.com>
 <20160510100104.GA18820@gmail.com>
 <60fc4f9f-fc8e-84a4-da84-a3c823b9b5bb@morey-chaisemartin.com>
 <20160511145141.GA5288@gmail.com>
 <432180fd-2faf-af37-7d99-4e24ab263d50@morey-chaisemartin.com>
 <20160512093632.GA15092@gmail.com>
 <e009b1e5-2fb2-0cc6-b065-932d7fa1c658@morey-chaisemartin.com>
 <20160512135253.GA17039@gmail.com>
 <db706ffa-2b61-de50-0118-9b0b6834ef68@morey-chaisemartin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <db706ffa-2b61-de50-0118-9b0b6834ef68@morey-chaisemartin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Morey-Chaisemartin <devel@morey-chaisemartin.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alex Williamson <alex.williamson@redhat.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello Nicolas,

On Thu, May 12, 2016 at 05:31:52PM +0200, Nicolas Morey-Chaisemartin wrote:
> 
> 
> Le 05/12/2016 a 03:52 PM, Jerome Glisse a ecrit :
> > On Thu, May 12, 2016 at 03:30:24PM +0200, Nicolas Morey-Chaisemartin wrote:
> >> Le 05/12/2016 a 11:36 AM, Jerome Glisse a ecrit :
> >>> On Thu, May 12, 2016 at 08:07:59AM +0200, Nicolas Morey-Chaisemartin wrote:
> [...]
> >>>> With transparent_hugepage=never I can't see the bug anymore.
> >>>>
> >>> Can you test https://patchwork.kernel.org/patch/9061351/ with 4.5
> >>> (does not apply to 3.10) and without transparent_hugepage=never
> >>>
> >>> Jerome
> >> Fails with 4.5 + this patch and with 4.5 + this patch + yours
> >>
> > There must be some bug in your code, we have upstream user that works
> > fine with the above combination (see drivers/vfio/vfio_iommu_type1.c)
> > i suspect you might be releasing the page pin too early (put_page()).
> In my previous tests, I checked the page before calling put_page and it has already changed.
> And I also checked that there is not multiple transfers in a single page at once.
> So I doubt it's that.
> >
> > If you really believe it is bug upstream we would need a dumb kernel
> > module that does gup like you do and that shows the issue. Right now
> > looking at code (assuming above patches applied) i can't see anything
> > that can go wrong with THP.
> 
> The issue is that I doubt I'll be able to do that. We have had code running in production for at least a year without the issue showing up and now a single test shows this.
> And some tweak to the test (meaning memory footprint in the user space) can make the problem disappear.
> 
> Is there a way to track what is happening to the THP? From the looks of it, the refcount are changed behind my back? Would kgdb with watch point work on this?
> Is there a less painful way?

Do you use fork()?

If you have threads and your DMA I/O granularity is smaller than
PAGE_SIZE, and a thread of the application in parent or child is
writing to another part of the page, the I/O can get lost (worse, it
doesn't get really lost but it goes to the child by mistake, instead
of sticking to the "mm" where you executed get_user_pages). This is
practically a bug in fork() but it's known. It can affect any app that
uses get_user_pages/O_DIRECT, fork() and uses thread and the I/O
granularity is smaller than PAGE_SIZE.

The same bug cannot happen with KSM or other things that can wrprotect
a page out of app control, because all things out of app control
checks there are no page pins before wrprotecting the page. So it's up
to the app to control "fork()".

To fix it, you should do one of: 1) use MADV_DONTFORK on the pinned
region, 2) prevent fork to run while you've pins taken with
get_user_pages or anyway while get_user_pages may be running
concurrently, 3) use a PAGE_SIZE I/O granularity and/or prevent the
threads to write to the other part of the page while DMA is running.

I'm not aware of other issues that could screw with page pins with THP
on kernels <=4.4, if there were, everything should fall apart
including O_DIRECT and qemu cache=none. The only issue I'm aware of
that can cause DMA to get lost with page pins is the aforementioned
one.

To debug it further, I would suggest to start by searching for "fork"
calls, and adding MADV_DONTFORK to the pinned region if there's any
fork() in your testcase.

Without being allowed to see the source there's not much else we can
do considering there's no sign of unknown bugs in this area in kernels
<=4.4.

All there is, is the known bug above, but apps that could be affected
by it, actively avoid it by using MADV_DONTFORK like with qemu
cache=none.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
