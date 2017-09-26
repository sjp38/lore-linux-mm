Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1DD6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 12:16:45 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q77so15451115qke.4
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 09:16:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u46si150856qtj.50.2017.09.26.09.16.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 09:16:43 -0700 (PDT)
Date: Tue, 26 Sep 2017 09:16:36 -0700
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Message-ID: <20170926161635.GA3216@redhat.com>
References: <20170719022537.GA6911@redhat.com>
 <f571a0a5-69ff-10b7-d612-353e53ba16fd@huawei.com>
 <20170720150305.GA2767@redhat.com>
 <ab3e67d5-5ed5-816f-6f8e-3228866be1fe@huawei.com>
 <20170721014106.GB25991@redhat.com>
 <CAPcyv4jJraGPW214xJ+wU3G=88UUP45YiA6hV5_NvNZSNB4qGA@mail.gmail.com>
 <20170905193644.GD19397@redhat.com>
 <CAA_GA1ckfyokvqy3aKi-NoSXxSzwiVsrykC6xNxpa3WUz0bqNQ@mail.gmail.com>
 <20170911233649.GA4892@redhat.com>
 <CAA_GA1ff4mGKfxxRpjYCRjXOvbUuksM0K2gmH1VrhL4qtGWFbw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAA_GA1ff4mGKfxxRpjYCRjXOvbUuksM0K2gmH1VrhL4qtGWFbw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Bob Liu <liubo95@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Sep 26, 2017 at 05:56:26PM +0800, Bob Liu wrote:
> On Tue, Sep 12, 2017 at 7:36 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> > On Sun, Sep 10, 2017 at 07:22:58AM +0800, Bob Liu wrote:
> >> On Wed, Sep 6, 2017 at 3:36 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> >> > On Thu, Jul 20, 2017 at 08:48:20PM -0700, Dan Williams wrote:
> >> >> On Thu, Jul 20, 2017 at 6:41 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> >> >> > On Fri, Jul 21, 2017 at 09:15:29AM +0800, Bob Liu wrote:
> >> >> >> On 2017/7/20 23:03, Jerome Glisse wrote:
> >> >> >> > On Wed, Jul 19, 2017 at 05:09:04PM +0800, Bob Liu wrote:
> >> >> >> >> On 2017/7/19 10:25, Jerome Glisse wrote:
> >> >> >> >>> On Wed, Jul 19, 2017 at 09:46:10AM +0800, Bob Liu wrote:
> >> >> >> >>>> On 2017/7/18 23:38, Jerome Glisse wrote:
> >> >> >> >>>>> On Tue, Jul 18, 2017 at 11:26:51AM +0800, Bob Liu wrote:
> >> >> >> >>>>>> On 2017/7/14 5:15, Jerome Glisse wrote:
> >> >
> >> > [...]
> >> >
> >> >> >> > Second device driver are not integrated that closely within mm and the
> >> >> >> > scheduler kernel code to allow to efficiently plug in device access
> >> >> >> > notification to page (ie to update struct page so that numa worker
> >> >> >> > thread can migrate memory base on accurate informations).
> >> >> >> >
> >> >> >> > Third it can be hard to decide who win between CPU and device access
> >> >> >> > when it comes to updating thing like last CPU id.
> >> >> >> >
> >> >> >> > Fourth there is no such thing like device id ie equivalent of CPU id.
> >> >> >> > If we were to add something the CPU id field in flags of struct page
> >> >> >> > would not be big enough so this can have repercusion on struct page
> >> >> >> > size. This is not an easy sell.
> >> >> >> >
> >> >> >> > They are other issues i can't think of right now. I think for now it
> >> >> >>
> >> >> >> My opinion is most of the issues are the same no matter use CDM or HMM-CDM.
> >> >> >> I just care about a more complete solution no matter CDM,HMM-CDM or other ways.
> >> >> >> HMM or HMM-CDM depends on device driver, but haven't see a public/full driver to
> >> >> >> demonstrate the whole solution works fine.
> >> >> >
> >> >> > I am working with NVidia close source driver team to make sure that it works
> >> >> > well for them. I am also working on nouveau open source driver for same NVidia
> >> >> > hardware thought it will be of less use as what is missing there is a solid
> >> >> > open source userspace to leverage this. Nonetheless open source driver are in
> >> >> > the work.
> >> >>
> >> >> Can you point to the nouveau patches? I still find these HMM patches
> >> >> un-reviewable without an upstream consumer.
> >> >
> >> > So i pushed a branch with WIP for nouveau to use HMM:
> >> >
> >> > https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-nouveau
> >> >
> >>
> >> Nice to see that.
> >> Btw, do you have any plan for a CDM-HMM driver? CPU can write to
> >> Device memory directly without extra copy.
> >
> > Yes nouveau CDM support on PPC (which is the only CDM platform commercialy
> > available today) is on the TODO list. Note that the driver changes for CDM
> > are minimal (probably less than 100 lines of code). From the driver point
> > of view this is memory and it doesn't matter if it is CDM or not.
> >
> 
> It seems have to migrate/copy memory between system-memory and
> device-memory even in HMM-CDM solution.
> Because device-memory is not added into buddy system, the page fault
> for normal malloc() always allocate memory from system-memory!!
> If the device then access the same virtual address, the data is copied
> to device-memory.
> 
> Correct me if I misunderstand something.
> @Balbir, how do you plan to make zero-copy work if using HMM-CDM?

Device can access system memory so copy to device is _not_ mandatory. Copying
data to device is for performance only ie the device driver take hint from
userspace and monitor device activity to decide which memory should be migrated
to device memory to maximize performance.

Moreover in some previous version of the HMM patchset we had an helper that
allowed to directly allocate device memory on device page fault. I intend to
post this helper again. With that helper you can have zero copy when device
is the first to access the memory.

Plan is to get what we have today work properly with the open source driver
and make it perform well. Once we get some experience with real workload we
might look into allowing CPU page fault to be directed to device memory but
at this time i don't think we need this.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
