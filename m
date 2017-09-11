Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 729306B02FC
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 19:36:55 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id r141so14531181qke.7
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 16:36:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 18si10593204qkd.291.2017.09.11.16.36.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Sep 2017 16:36:54 -0700 (PDT)
Date: Mon, 11 Sep 2017 19:36:49 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Message-ID: <20170911233649.GA4892@redhat.com>
References: <20170718153816.GA3135@redhat.com>
 <b6f9d812-a1f5-d647-0a6a-39a08023c3b4@huawei.com>
 <20170719022537.GA6911@redhat.com>
 <f571a0a5-69ff-10b7-d612-353e53ba16fd@huawei.com>
 <20170720150305.GA2767@redhat.com>
 <ab3e67d5-5ed5-816f-6f8e-3228866be1fe@huawei.com>
 <20170721014106.GB25991@redhat.com>
 <CAPcyv4jJraGPW214xJ+wU3G=88UUP45YiA6hV5_NvNZSNB4qGA@mail.gmail.com>
 <20170905193644.GD19397@redhat.com>
 <CAA_GA1ckfyokvqy3aKi-NoSXxSzwiVsrykC6xNxpa3WUz0bqNQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAA_GA1ckfyokvqy3aKi-NoSXxSzwiVsrykC6xNxpa3WUz0bqNQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Bob Liu <liubo95@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Sep 10, 2017 at 07:22:58AM +0800, Bob Liu wrote:
> On Wed, Sep 6, 2017 at 3:36 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> > On Thu, Jul 20, 2017 at 08:48:20PM -0700, Dan Williams wrote:
> >> On Thu, Jul 20, 2017 at 6:41 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> >> > On Fri, Jul 21, 2017 at 09:15:29AM +0800, Bob Liu wrote:
> >> >> On 2017/7/20 23:03, Jerome Glisse wrote:
> >> >> > On Wed, Jul 19, 2017 at 05:09:04PM +0800, Bob Liu wrote:
> >> >> >> On 2017/7/19 10:25, Jerome Glisse wrote:
> >> >> >>> On Wed, Jul 19, 2017 at 09:46:10AM +0800, Bob Liu wrote:
> >> >> >>>> On 2017/7/18 23:38, Jerome Glisse wrote:
> >> >> >>>>> On Tue, Jul 18, 2017 at 11:26:51AM +0800, Bob Liu wrote:
> >> >> >>>>>> On 2017/7/14 5:15, Jerome Glisse wrote:
> >
> > [...]
> >
> >> >> > Second device driver are not integrated that closely within mm and the
> >> >> > scheduler kernel code to allow to efficiently plug in device access
> >> >> > notification to page (ie to update struct page so that numa worker
> >> >> > thread can migrate memory base on accurate informations).
> >> >> >
> >> >> > Third it can be hard to decide who win between CPU and device access
> >> >> > when it comes to updating thing like last CPU id.
> >> >> >
> >> >> > Fourth there is no such thing like device id ie equivalent of CPU id.
> >> >> > If we were to add something the CPU id field in flags of struct page
> >> >> > would not be big enough so this can have repercusion on struct page
> >> >> > size. This is not an easy sell.
> >> >> >
> >> >> > They are other issues i can't think of right now. I think for now it
> >> >>
> >> >> My opinion is most of the issues are the same no matter use CDM or HMM-CDM.
> >> >> I just care about a more complete solution no matter CDM,HMM-CDM or other ways.
> >> >> HMM or HMM-CDM depends on device driver, but haven't see a public/full driver to
> >> >> demonstrate the whole solution works fine.
> >> >
> >> > I am working with NVidia close source driver team to make sure that it works
> >> > well for them. I am also working on nouveau open source driver for same NVidia
> >> > hardware thought it will be of less use as what is missing there is a solid
> >> > open source userspace to leverage this. Nonetheless open source driver are in
> >> > the work.
> >>
> >> Can you point to the nouveau patches? I still find these HMM patches
> >> un-reviewable without an upstream consumer.
> >
> > So i pushed a branch with WIP for nouveau to use HMM:
> >
> > https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-nouveau
> >
> 
> Nice to see that.
> Btw, do you have any plan for a CDM-HMM driver? CPU can write to
> Device memory directly without extra copy.

Yes nouveau CDM support on PPC (which is the only CDM platform commercialy
available today) is on the TODO list. Note that the driver changes for CDM
are minimal (probably less than 100 lines of code). From the driver point
of view this is memory and it doesn't matter if it is CDM or not.

The real burden is on the application developpers who need to update their
code to leverage this.


Also as a data point you want to avoid CPU access to CDM device memory as
much as possible. The overhead for single cache line access are high (this
is PCIE or derivative protocol and it is a packet protocol).

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
