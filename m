Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id CE5CD6B0036
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 17:05:49 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id el20so1178589lab.5
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 14:05:48 -0700 (PDT)
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
        by mx.google.com with ESMTPS id xs1si9533647lbb.39.2014.06.25.14.05.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 14:05:47 -0700 (PDT)
Received: by mail-la0-f51.google.com with SMTP id mc6so1185500lab.38
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 14:05:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrWmmVC2qQtL0Js_Y7LvSPdTh5Hpk6c5ZG3Rt8uTJBWoHQ@mail.gmail.com>
References: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com>
 <1403084656-27284-3-git-send-email-qiaowei.ren@intel.com> <53A884B2.5070702@mit.edu>
 <53A88806.1060908@intel.com> <CALCETrXYZZiZsDiUvvZd0636+qHP9a0sHTN6wt_ZKjvLaeeBzw@mail.gmail.com>
 <53A88DE4.8050107@intel.com> <CALCETrWBbkFzQR3tz1TphqxiGYycvzrFrKc=ghzMynbem=d7rg@mail.gmail.com>
 <9E0BE1322F2F2246BD820DA9FC397ADE016AF41C@shsmsx102.ccr.corp.intel.com>
 <CALCETrX+iS5N8bCUm_O-1E4GPu4oG-SuFJoJjx_+S054K9-6pw@mail.gmail.com>
 <9E0BE1322F2F2246BD820DA9FC397ADE016B26AB@shsmsx102.ccr.corp.intel.com> <CALCETrWmmVC2qQtL0Js_Y7LvSPdTh5Hpk6c5ZG3Rt8uTJBWoHQ@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 25 Jun 2014 14:05:27 -0700
Message-ID: <CALCETrUD3L5Ta_v+NqgUrTk7Ok3zE=CRg0rqeKthOj2OORCLKQ@mail.gmail.com>
Subject: Re: [PATCH v6 02/10] x86, mpx: add MPX specific mmap interface
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Wed, Jun 25, 2014 at 2:04 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Tue, Jun 24, 2014 at 6:40 PM, Ren, Qiaowei <qiaowei.ren@intel.com> wrote:
>> On 2014-06-25, Andy Lutomirski wrote:
>>> On Mon, Jun 23, 2014 at 10:53 PM, Ren, Qiaowei <qiaowei.ren@intel.com>
>>> wrote:
>>>> On 2014-06-24, Andy Lutomirski wrote:
>>>>>> On 06/23/2014 01:06 PM, Andy Lutomirski wrote:
>>>>>>> Can the new vm_operation "name" be use for this?  The magic
>>>>>>> "always written to core dumps" feature might need to be reconsidered.
>>>>>>
>>>>>> One thing I'd like to avoid is an MPX vma getting merged with a
>>>>>> non-MPX vma.  I don't see any code to prevent two VMAs with
>>>>>> different vm_ops->names from getting merged.  That seems like a
>>>>>> bit of a design oversight for ->name.  Right?
>>>>>
>>>>> AFAIK there are no ->name users that don't also set ->close, for
>>>>> exactly that reason.  I'd be okay with adding a check for ->name, too.
>>>>>
>>>>> Hmm.  If MPX vmas had a real struct file attached, this would all
>>>>> come for free. Maybe vmas with non-default vm_ops and file != NULL
>>>>> should never be mergeable?
>>>>>
>>>>>>
>>>>>> Thinking out loud a bit... There are also some more complicated
>>>>>> but more performant cleanup mechanisms that I'd like to go after in the future.
>>>>>> Given a page, we might want to figure out if it is an MPX page or not.
>>>>>> I wonder if we'll ever collide with some other user of vm_ops->name.
>>>>>> It looks fairly narrowly used at the moment, but would this keep
>>>>>> us from putting these pages on, say, a tmpfs mount?  Doesn't look
>>>>>> that way at the moment.
>>>>>
>>>>> You could always check the vm_ops pointer to see if it's MPX.
>>>>>
>>>>> One feature I've wanted: a way to have special per-process vmas that
>>>>> can be easily found.  For example, I want to be able to efficiently
>>>>> find out where the vdso and vvar vmas are.  I don't think this is
>>>>> currently supported.
>>>>>
>>>> Andy, if you add a check for ->name to avoid the MPX vmas merged
>>>> with
>>> non-MPX vmas, I guess the work flow should be as follow (use
>>> _install_special_mapping to get a new vma):
>>>>
>>>> unsigned long mpx_mmap(unsigned long len) {
>>>>     ......
>>>>     static struct vm_special_mapping mpx_mapping = {
>>>>         .name = "[mpx]",
>>>>         .pages = no_pages,
>>>>     };
>>>>
>>>>     ....... vma = _install_special_mapping(mm, addr, len, vm_flags,
>>>>     &mpx_mapping); ......
>>>> }
>>>>
>>>> Then, we could check the ->name to see if the VMA is MPX specific. Right?
>>>
>>> Does this actually create a vma backed with real memory?  Doesn't this
>>> need to go through anon_vma or something?  _install_special_mapping
>>> completely prevents merging.
>>>
>> Hmm, _install_special_mapping should completely prevent merging, even among MPX vmas.
>>
>> So, could you tell me how to set MPX specific ->name to the vma when it is created? Seems like that I could not find such interface.
>
> You may need to add one.
>
> I'd suggest posting a new thread to linux-mm describing what you need
> and asking how to do it.

Hmm.  the memfd_create thing may be able to do this for you.  If you
created a per-mm memfd and mapped it, it all just might work.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
