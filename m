Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B29FC6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 05:56:28 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r74so11389719wme.5
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 02:56:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g71sor1680439lfh.91.2017.09.26.02.56.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Sep 2017 02:56:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170911233649.GA4892@redhat.com>
References: <20170718153816.GA3135@redhat.com> <b6f9d812-a1f5-d647-0a6a-39a08023c3b4@huawei.com>
 <20170719022537.GA6911@redhat.com> <f571a0a5-69ff-10b7-d612-353e53ba16fd@huawei.com>
 <20170720150305.GA2767@redhat.com> <ab3e67d5-5ed5-816f-6f8e-3228866be1fe@huawei.com>
 <20170721014106.GB25991@redhat.com> <CAPcyv4jJraGPW214xJ+wU3G=88UUP45YiA6hV5_NvNZSNB4qGA@mail.gmail.com>
 <20170905193644.GD19397@redhat.com> <CAA_GA1ckfyokvqy3aKi-NoSXxSzwiVsrykC6xNxpa3WUz0bqNQ@mail.gmail.com>
 <20170911233649.GA4892@redhat.com>
From: Bob Liu <lliubbo@gmail.com>
Date: Tue, 26 Sep 2017 17:56:26 +0800
Message-ID: <CAA_GA1ff4mGKfxxRpjYCRjXOvbUuksM0K2gmH1VrhL4qtGWFbw@mail.gmail.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Bob Liu <liubo95@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Sep 12, 2017 at 7:36 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Sun, Sep 10, 2017 at 07:22:58AM +0800, Bob Liu wrote:
>> On Wed, Sep 6, 2017 at 3:36 AM, Jerome Glisse <jglisse@redhat.com> wrote=
:
>> > On Thu, Jul 20, 2017 at 08:48:20PM -0700, Dan Williams wrote:
>> >> On Thu, Jul 20, 2017 at 6:41 PM, Jerome Glisse <jglisse@redhat.com> w=
rote:
>> >> > On Fri, Jul 21, 2017 at 09:15:29AM +0800, Bob Liu wrote:
>> >> >> On 2017/7/20 23:03, Jerome Glisse wrote:
>> >> >> > On Wed, Jul 19, 2017 at 05:09:04PM +0800, Bob Liu wrote:
>> >> >> >> On 2017/7/19 10:25, Jerome Glisse wrote:
>> >> >> >>> On Wed, Jul 19, 2017 at 09:46:10AM +0800, Bob Liu wrote:
>> >> >> >>>> On 2017/7/18 23:38, Jerome Glisse wrote:
>> >> >> >>>>> On Tue, Jul 18, 2017 at 11:26:51AM +0800, Bob Liu wrote:
>> >> >> >>>>>> On 2017/7/14 5:15, J=C3=A9r=C3=B4me Glisse wrote:
>> >
>> > [...]
>> >
>> >> >> > Second device driver are not integrated that closely within mm a=
nd the
>> >> >> > scheduler kernel code to allow to efficiently plug in device acc=
ess
>> >> >> > notification to page (ie to update struct page so that numa work=
er
>> >> >> > thread can migrate memory base on accurate informations).
>> >> >> >
>> >> >> > Third it can be hard to decide who win between CPU and device ac=
cess
>> >> >> > when it comes to updating thing like last CPU id.
>> >> >> >
>> >> >> > Fourth there is no such thing like device id ie equivalent of CP=
U id.
>> >> >> > If we were to add something the CPU id field in flags of struct =
page
>> >> >> > would not be big enough so this can have repercusion on struct p=
age
>> >> >> > size. This is not an easy sell.
>> >> >> >
>> >> >> > They are other issues i can't think of right now. I think for no=
w it
>> >> >>
>> >> >> My opinion is most of the issues are the same no matter use CDM or=
 HMM-CDM.
>> >> >> I just care about a more complete solution no matter CDM,HMM-CDM o=
r other ways.
>> >> >> HMM or HMM-CDM depends on device driver, but haven't see a public/=
full driver to
>> >> >> demonstrate the whole solution works fine.
>> >> >
>> >> > I am working with NVidia close source driver team to make sure that=
 it works
>> >> > well for them. I am also working on nouveau open source driver for =
same NVidia
>> >> > hardware thought it will be of less use as what is missing there is=
 a solid
>> >> > open source userspace to leverage this. Nonetheless open source dri=
ver are in
>> >> > the work.
>> >>
>> >> Can you point to the nouveau patches? I still find these HMM patches
>> >> un-reviewable without an upstream consumer.
>> >
>> > So i pushed a branch with WIP for nouveau to use HMM:
>> >
>> > https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-nouveau
>> >
>>
>> Nice to see that.
>> Btw, do you have any plan for a CDM-HMM driver? CPU can write to
>> Device memory directly without extra copy.
>
> Yes nouveau CDM support on PPC (which is the only CDM platform commercial=
y
> available today) is on the TODO list. Note that the driver changes for CD=
M
> are minimal (probably less than 100 lines of code). From the driver point
> of view this is memory and it doesn't matter if it is CDM or not.
>

It seems have to migrate/copy memory between system-memory and
device-memory even in HMM-CDM solution.
Because device-memory is not added into buddy system, the page fault
for normal malloc() always allocate memory from system-memory!!
If the device then access the same virtual address, the data is copied
to device-memory.

Correct me if I misunderstand something.
@Balbir, how do you plan to make zero-copy work if using HMM-CDM?

--
Thanks,
Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
