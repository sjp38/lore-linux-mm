Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 362956B0292
	for <linux-mm@kvack.org>; Sat,  9 Sep 2017 19:23:02 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l196so3858651lfl.2
        for <linux-mm@kvack.org>; Sat, 09 Sep 2017 16:23:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h9sor860652ljb.32.2017.09.09.16.22.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Sep 2017 16:23:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170905193644.GD19397@redhat.com>
References: <20170713211532.970-1-jglisse@redhat.com> <2d534afc-28c5-4c81-c452-7e4c013ab4d0@huawei.com>
 <20170718153816.GA3135@redhat.com> <b6f9d812-a1f5-d647-0a6a-39a08023c3b4@huawei.com>
 <20170719022537.GA6911@redhat.com> <f571a0a5-69ff-10b7-d612-353e53ba16fd@huawei.com>
 <20170720150305.GA2767@redhat.com> <ab3e67d5-5ed5-816f-6f8e-3228866be1fe@huawei.com>
 <20170721014106.GB25991@redhat.com> <CAPcyv4jJraGPW214xJ+wU3G=88UUP45YiA6hV5_NvNZSNB4qGA@mail.gmail.com>
 <20170905193644.GD19397@redhat.com>
From: Bob Liu <lliubbo@gmail.com>
Date: Sun, 10 Sep 2017 07:22:58 +0800
Message-ID: <CAA_GA1ckfyokvqy3aKi-NoSXxSzwiVsrykC6xNxpa3WUz0bqNQ@mail.gmail.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Bob Liu <liubo95@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Sep 6, 2017 at 3:36 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Thu, Jul 20, 2017 at 08:48:20PM -0700, Dan Williams wrote:
>> On Thu, Jul 20, 2017 at 6:41 PM, Jerome Glisse <jglisse@redhat.com> wrot=
e:
>> > On Fri, Jul 21, 2017 at 09:15:29AM +0800, Bob Liu wrote:
>> >> On 2017/7/20 23:03, Jerome Glisse wrote:
>> >> > On Wed, Jul 19, 2017 at 05:09:04PM +0800, Bob Liu wrote:
>> >> >> On 2017/7/19 10:25, Jerome Glisse wrote:
>> >> >>> On Wed, Jul 19, 2017 at 09:46:10AM +0800, Bob Liu wrote:
>> >> >>>> On 2017/7/18 23:38, Jerome Glisse wrote:
>> >> >>>>> On Tue, Jul 18, 2017 at 11:26:51AM +0800, Bob Liu wrote:
>> >> >>>>>> On 2017/7/14 5:15, J=C3=A9r=C3=B4me Glisse wrote:
>
> [...]
>
>> >> > Second device driver are not integrated that closely within mm and =
the
>> >> > scheduler kernel code to allow to efficiently plug in device access
>> >> > notification to page (ie to update struct page so that numa worker
>> >> > thread can migrate memory base on accurate informations).
>> >> >
>> >> > Third it can be hard to decide who win between CPU and device acces=
s
>> >> > when it comes to updating thing like last CPU id.
>> >> >
>> >> > Fourth there is no such thing like device id ie equivalent of CPU i=
d.
>> >> > If we were to add something the CPU id field in flags of struct pag=
e
>> >> > would not be big enough so this can have repercusion on struct page
>> >> > size. This is not an easy sell.
>> >> >
>> >> > They are other issues i can't think of right now. I think for now i=
t
>> >>
>> >> My opinion is most of the issues are the same no matter use CDM or HM=
M-CDM.
>> >> I just care about a more complete solution no matter CDM,HMM-CDM or o=
ther ways.
>> >> HMM or HMM-CDM depends on device driver, but haven't see a public/ful=
l driver to
>> >> demonstrate the whole solution works fine.
>> >
>> > I am working with NVidia close source driver team to make sure that it=
 works
>> > well for them. I am also working on nouveau open source driver for sam=
e NVidia
>> > hardware thought it will be of less use as what is missing there is a =
solid
>> > open source userspace to leverage this. Nonetheless open source driver=
 are in
>> > the work.
>>
>> Can you point to the nouveau patches? I still find these HMM patches
>> un-reviewable without an upstream consumer.
>
> So i pushed a branch with WIP for nouveau to use HMM:
>
> https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-nouveau
>

Nice to see that.
Btw, do you have any plan for a CDM-HMM driver? CPU can write to
Device memory directly without extra copy.

--
Thanks,
Bob Liu

> Top 16 patches are HMM related (implementic logic inside the driver to us=
e
> HMM). The next 16 patches are hardware specific patches and some nouveau
> changes needed to allow page fault.
>
> It is enough to have simple malloc test case working:
>
> https://cgit.freedesktop.org/~glisse/compote
>
> There is 2 program here the old one is existing way you use GPU for compu=
te
> task while the new one is what HMM allow to achieve ie use malloc memory
> directly.
>
>
> I haven't added yet the device memory support it is in work and i will pu=
sh
> update to this branch and repo for that. Probably next week if no pressin=
g
> bug preempt my time.
>
>
> So there is a lot of ugliness in all this and i don't expect this to be w=
hat
> end up upstream. Right now there is a large rework of nouveau vm (virtual
> memory) code happening to rework completely how we do address space manag=
ement
> within nouveau. This work is prerequisite for a clean implementation for =
HMM
> inside nouveau (it will also lift the 40bits address space limitation tha=
t
> exist today inside nouveau driver). Once that work land i will work on cl=
ean
> upstreamable implementation for nouveau to use HMM as well as userspace t=
o
> leverage it (this is requirement for upstream GPU driver to have open sou=
rce
> userspace that make use of features). All this is a lot of work and there=
 is
> not many people working on this.
>
>
> They are other initiatives under way related to this that i can not talk =
about
> publicly but if they bare fruit they might help to speedup all this.
>
> J=C3=A9r=C3=B4me
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
