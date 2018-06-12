Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 45D106B026B
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 00:05:08 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id n21-v6so17462911iob.19
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 21:05:08 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x124-v6si139362ite.101.2018.06.11.21.05.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 21:05:06 -0700 (PDT)
Subject: Re: [PATCH v2 00/11] mm: Teach memory_failure() about ZONE_DEVICE
 pages
References: <20180605141104.GF19202@dhcp22.suse.cz>
 <CAPcyv4iGd56kc2NG5GDYMqW740RNr7NZr9DRft==fPxPyieq7Q@mail.gmail.com>
 <20180606073910.GB32433@dhcp22.suse.cz>
 <CAPcyv4hA2Na7wyuyLZSWG5s_4+pEv6aMApk23d2iO1vhFx92XQ@mail.gmail.com>
 <20180607143724.GS32433@dhcp22.suse.cz>
 <CAPcyv4jnyuC-yjuSgu4qKtzB0h9yYMZDsg5Rqqa=HTCY9KM_gw@mail.gmail.com>
 <20180611075004.GH13364@dhcp22.suse.cz>
 <CAPcyv4gSTMEi5XdzLQZqxMMKCcwF=me02wCiRtAAXSiy2CPGJA@mail.gmail.com>
 <20180611145636.GP13364@dhcp22.suse.cz>
 <CAPcyv4hnPRk0hTGctHB4tBnyL_27x3DwPUVwhZ+L7c-=1Xdf6Q@mail.gmail.com>
 <20180612015025.GA25302@hori1.linux.bs1.fc.nec.co.jp>
From: Jane Chu <jane.chu@oracle.com>
Message-ID: <829374f0-80a8-bccc-7db5-17596947d458@oracle.com>
Date: Mon, 11 Jun 2018 21:04:39 -0700
MIME-Version: 1.0
In-Reply-To: <20180612015025.GA25302@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Dan Williams <dan.j.williams@intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Souptick Joarder <jrdr.linux@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Hellwig <hch@lst.de>, "linux-edac@vger.kernel.org" <linux-edac@vger.kernel.org>

On 6/11/2018 6:50 PM, Naoya Horiguchi wrote:

> On Mon, Jun 11, 2018 at 08:19:54AM -0700, Dan Williams wrote:
>> On Mon, Jun 11, 2018 at 7:56 AM, Michal Hocko <mhocko@kernel.org> wrote:
>>> On Mon 11-06-18 07:44:39, Dan Williams wrote:
>>> [...]
>>>> I'm still trying to understand the next level of detail on where you
>>>> think the design should go next? Is it just the HWPoison page flag?
>>>> Are you concerned about supporting greater than PAGE_SIZE poison?
>>> I simply do not want to check for HWPoison at zillion of places and have
>>> each type of page to have some special handling which can get wrong very
>>> easily. I am not clear on details here, this is something for users of
>>> hwpoison to define what is the reasonable scenarios when the feature is
>>> useful and turn that into a feature list that can be actually turned
>>> into a design document. See the different from let's put some more on
>>> top approach...
>>>
>> So you want me to pay the toll of writing a design document justifying
>> all the existing use cases of HWPoison before we fix the DAX bugs, and
>> the design document may or may not result in any substantive change to
>> these patches?
>>
>> Naoya or Andi, can you chime in here?
> memory_failure() does 3 things:
>
>   - unmapping the error page from processes using it,
>   - isolating the error page with PageHWPoison,
>   - logging/reporting.
>
> The unmapping part and the isolating part are quite page type dependent,
> so this seems to me hard to do them in generic manner (so supporting new
> page type always needs case specific new code.)
> But I agree that we can improve code and document to help developers add
> support for new page type.
>
> About documenting, the content of Documentation/vm/hwpoison.rst is not
> updated since 2009, so some update with design thing might be required.
> My current thought about update items are like this:
>
>    - detailing general workflow,
>    - adding some about soft offline,
>    - guideline for developers to support new type of memory,
>    (- and anything helpful/requested.)
>
> Making code more readable/self-descriptive is helpful, though I'm
> not clear now about how.
>
> Anyway I'll find time to work on this, while now I'm testing the dax
> support patches and fixing a bug I found recently.

Thank you. Maybe it's already on your mind, but just in case. When you update the
document, would you add the characteristics of pmem error handling in that
   . UE/poison can be repaired until the wear and tear reaches a max level
   . many user applications mmap the entire capacity, leaving no spare pages
     for swapping (unlike the volatile memory UE handling)
   . the what-you-see-is-what-you-get nature
?
Regarding HWPOISON redesign, a nagging thought is that a memory UE typically indicts
a very small blast radius, less than 4KB.  But it seems that the larger the page size,
the greater the 'penalty' in terms of how much memory would end up being offlined.
If there a way to be frugal?

Thanks!
-jane

>
> Thanks,
> Naoya Horiguchi
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm
