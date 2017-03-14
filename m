Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 21F5F6B038A
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 09:22:26 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n11so19027420wma.5
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 06:22:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p51si5089980wrb.250.2017.03.14.06.22.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Mar 2017 06:22:24 -0700 (PDT)
Date: Tue, 14 Mar 2017 14:20:23 +0100
From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: [LTP] Is MADV_HWPOISON supposed to work only on faulted-in pages?
Message-ID: <20170314132023.GA8206@rei.lan>
References: <6a445beb-119c-9a9a-0277-07866afe4924@redhat.com>
 <20170220050016.GA15533@hori1.linux.bs1.fc.nec.co.jp>
 <20170223032342.GA18740@hori1.linux.bs1.fc.nec.co.jp>
 <1ba376aa-5e7c-915f-35d1-2d4eef0cad88@huawei.com>
 <20170227012029.GA28934@hori1.linux.bs1.fc.nec.co.jp>
 <22763879-C335-41E6-8102-2022EED75DAE@cs.rutgers.edu>
 <20170227063308.GA14387@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170227063308.GA14387@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Yisheng Xie <xieyisheng1@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ltp@lists.linux.it" <ltp@lists.linux.it>, linux-man@vger.kernel.org, mtk.manpages@gmail.com

Hi!
> > >>>>> code below (and LTP madvise07 [1]) doesn't produce SIGBUS,
> > >>>>> unless I touch/prefault page before call to madvise().
> > >>>>>
> > >>>>> Is this expected behavior?
> > >>>>
> > >>>> Thank you for reporting.
> > >>>>
> > >>>> madvise(MADV_HWPOISON) triggers page fault when called on the address
> > >>>> over which no page is faulted-in, so I think that SIGBUS should be
> > >>>> called in such case.
> > >>>>
> > >>>> But it seems that memory error handler considers such a page as "reserved
> > >>>> kernel page" and recovery action fails (see below.)
> > >>>>
> > >>>>   [  383.371372] Injecting memory failure for page 0x1f10 at 0x7efcdc569000
> > >>>>   [  383.375678] Memory failure: 0x1f10: reserved kernel page still referenced by 1 users
> > >>>>   [  383.377570] Memory failure: 0x1f10: recovery action for reserved kernel page: Failed
> > >>>>
> > >>>> I'm not sure how/when this behavior was introduced, so I try to understand.
> > >>>
> > >>> I found that this is a zero page, which is not recoverable for memory
> > >>> error now.
> > >>>
> > >>>> IMO, the test code below looks valid to me, so no need to change.
> > >>>
> > >>> I think that what the testcase effectively does is to test whether memory
> > >>> handling on zero pages works or not.
> > >>> And the testcase's failure seems acceptable, because it's simply not-implemented yet.
> > >>> Maybe recovering from error on zero page is possible (because there's no data
> > >>> loss for memory error,) but I'm not sure that code might be simple enough and/or
> > >>> it's worth doing ...
> > >> I question about it,  if a memory error happened on zero page, it will
> > >> cause all of data read from zero page is error, I mean no-zero, right?
> > >
> > > Hi Yisheng,
> > >
> > > Yes, the impact is serious (could affect many processes,) but it's possibility
> > > is very low because there's only one page in a system that is used for zero page.
> > > There are many other pages which are not recoverable for memory error like
> > > slab pages, so I'm not sure how I prioritize it (maybe it's not a
> > > top-priority thing, nor low-hanging fruit.)
> > >
> > >> And can we just use re-initial it with zero data maybe by memset ?
> > >
> > > Maybe it's not enoguh. Under a real hwpoison, we should isolate the error
> > > page to prevent the access on the broken data.
> > > But zero page is statically defined as an array of global variable, so
> > > it's not trival to replace it with a new zero page at runtime.
> > >
> > > Anyway, it's in my todo list, so hopefully revisited in the future.
> > >
> > 
> > Hi Naoya,
> > 
> > The test case tries to HWPOISON a range of virtual addresses that do not
> > map to any physical pages.
> > 
> 
> Hi Yan,
> 
> > I expected either madvise should fail because HWPOISON does not work on
> > non-existing physical pages or madvise_hwpoison() should populate
> > some physical pages for that virtual address range and poison them.
> 
> The latter is the current behavior. It just comes from get_user_pages_fast()
> which not only finds the page and takes refcount, but also touch the page.
> 
> madvise(MADV_HWPOISON) is a test feature, and calling it for address backed
> by no page doesn't simulate anything real. IOW, the behavior is undefined.
> So I don't have a strong opinion about how it should behave.
> 
> > 
> > As I tested it on kernel v4.10, the test application exited at
> > madvise, because madvise returns -1 and error message is
> > "Device or resource busy". I think this is a proper behavior.
> 
> yes, maybe we see the same thing, you can see in dmesg "recovery action
> for reserved kernel page: Failed" message.
> 
> > 
> > There might be some confusion in madvise's man page on MADV_HWPOISON.
> > If you add some text saying madvise fails if any page is not mapped in
> > the given address range, that can eliminate the confusion*
> 
> Writing it down to man page makes readers think this behavior is a part of
> specification, that might not be good now because the failure in error
> handling of zero page is not the eventually fixed behavior.
> I mean that if zero page handles hwpoison properly in the future, madvise
> will succeed without any confusion.
> So I feel that we don't have to update man page for this issue.

I still think that this is a worth of documenting in the manual page,
since the call failed silently before 4.10 right? I guess that we may as
well add a BUGS section and document at least that.

-- 
Cyril Hrubis
chrubis@suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
