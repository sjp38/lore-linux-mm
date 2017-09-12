Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4809C6B0300
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 21:09:53 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k101so8822332iod.1
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 18:09:53 -0700 (PDT)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id h74si6463064ioi.210.2017.09.11.18.09.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Sep 2017 18:09:51 -0700 (PDT)
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
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
 <20170911233649.GA4892@redhat.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <905f3242-e17b-a4c1-dd03-36f64161fa02@huawei.com>
Date: Tue, 12 Sep 2017 09:02:19 +0800
MIME-Version: 1.0
In-Reply-To: <20170911233649.GA4892@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Bob Liu <lliubbo@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 2017/9/12 7:36, Jerome Glisse wrote:
> On Sun, Sep 10, 2017 at 07:22:58AM +0800, Bob Liu wrote:
>> On Wed, Sep 6, 2017 at 3:36 AM, Jerome Glisse <jglisse@redhat.com> wrote:
>>> On Thu, Jul 20, 2017 at 08:48:20PM -0700, Dan Williams wrote:
>>>> On Thu, Jul 20, 2017 at 6:41 PM, Jerome Glisse <jglisse@redhat.com> wrote:
>>>>> On Fri, Jul 21, 2017 at 09:15:29AM +0800, Bob Liu wrote:
>>>>>> On 2017/7/20 23:03, Jerome Glisse wrote:
>>>>>>> On Wed, Jul 19, 2017 at 05:09:04PM +0800, Bob Liu wrote:
>>>>>>>> On 2017/7/19 10:25, Jerome Glisse wrote:
>>>>>>>>> On Wed, Jul 19, 2017 at 09:46:10AM +0800, Bob Liu wrote:
>>>>>>>>>> On 2017/7/18 23:38, Jerome Glisse wrote:
>>>>>>>>>>> On Tue, Jul 18, 2017 at 11:26:51AM +0800, Bob Liu wrote:
>>>>>>>>>>>> On 2017/7/14 5:15, Jerome Glisse wrote:
>>>
>>> [...]
>>>
>>>>>>> Second device driver are not integrated that closely within mm and the
>>>>>>> scheduler kernel code to allow to efficiently plug in device access
>>>>>>> notification to page (ie to update struct page so that numa worker
>>>>>>> thread can migrate memory base on accurate informations).
>>>>>>>
>>>>>>> Third it can be hard to decide who win between CPU and device access
>>>>>>> when it comes to updating thing like last CPU id.
>>>>>>>
>>>>>>> Fourth there is no such thing like device id ie equivalent of CPU id.
>>>>>>> If we were to add something the CPU id field in flags of struct page
>>>>>>> would not be big enough so this can have repercusion on struct page
>>>>>>> size. This is not an easy sell.
>>>>>>>
>>>>>>> They are other issues i can't think of right now. I think for now it
>>>>>>
>>>>>> My opinion is most of the issues are the same no matter use CDM or HMM-CDM.
>>>>>> I just care about a more complete solution no matter CDM,HMM-CDM or other ways.
>>>>>> HMM or HMM-CDM depends on device driver, but haven't see a public/full driver to
>>>>>> demonstrate the whole solution works fine.
>>>>>
>>>>> I am working with NVidia close source driver team to make sure that it works
>>>>> well for them. I am also working on nouveau open source driver for same NVidia
>>>>> hardware thought it will be of less use as what is missing there is a solid
>>>>> open source userspace to leverage this. Nonetheless open source driver are in
>>>>> the work.
>>>>
>>>> Can you point to the nouveau patches? I still find these HMM patches
>>>> un-reviewable without an upstream consumer.
>>>
>>> So i pushed a branch with WIP for nouveau to use HMM:
>>>
>>> https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-nouveau
>>>
>>
>> Nice to see that.
>> Btw, do you have any plan for a CDM-HMM driver? CPU can write to
>> Device memory directly without extra copy.
> 
> Yes nouveau CDM support on PPC (which is the only CDM platform commercialy
> available today) is on the TODO list. Note that the driver changes for CDM
> are minimal (probably less than 100 lines of code). From the driver point
> of view this is memory and it doesn't matter if it is CDM or not.
> 
> The real burden is on the application developpers who need to update their
> code to leverage this.
> 

Why it's not transparent to application?
Application just use system malloc() and don't care whether the data is copied or not.

> 
> Also as a data point you want to avoid CPU access to CDM device memory as
> much as possible. The overhead for single cache line access are high (this
> is PCIE or derivative protocol and it is a packet protocol).
> 

Thank you for the hint, we are going to follow cdm-hmm since HMM already merged into upstream.

--
Thanks,
Bob



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
