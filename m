Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6C41A6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 10:33:26 -0400 (EDT)
Received: by yhid80 with SMTP id d80so12565664yhi.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 07:33:26 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id m46si376560yhb.99.2015.06.16.07.33.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Jun 2015 07:33:25 -0700 (PDT)
Message-ID: <5580326D.30006@citrix.com>
Date: Tue, 16 Jun 2015 15:27:57 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/12] x86/virt/guest/xen: Remove use of pgd_list from
 the Xen guest code
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
 <1434188955-31397-8-git-send-email-mingo@kernel.org>
 <1434359109.13744.14.camel@hellion.org.uk> <557EA944.9020504@citrix.com>
 <20150615203532.GC13273@gmail.com> <55802F94.90306@citrix.com>
 <5580307F.8050007@oracle.com>
In-Reply-To: <5580307F.8050007@oracle.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>, Ingo Molnar <mingo@kernel.org>
Cc: Ian Campbell <ijc@hellion.org.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys
 Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter
 Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter
 Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

On 16/06/15 15:19, Boris Ostrovsky wrote:
> On 06/16/2015 10:15 AM, David Vrabel wrote:
>> On 15/06/15 21:35, Ingo Molnar wrote:
>>> * David Vrabel <david.vrabel@citrix.com> wrote:
>>>
>>>> On 15/06/15 10:05, Ian Campbell wrote:
>>>>> On Sat, 2015-06-13 at 11:49 +0200, Ingo Molnar wrote:
>>>>>> xen_mm_pin_all()/unpin_all() are used to implement full guest
>>>>>> instance
>>>>>> suspend/restore. It's a stop-all method that needs to iterate
>>>>>> through all
>>>>>> allocated pgds in the system to fix them up for Xen's use.
>>>>>>
>>>>>> This code uses pgd_list, probably because it was an easy interface.
>>>>>>
>>>>>> But we want to remove the pgd_list, so convert the code over to
>>>>>> walk all
>>>>>> tasks in the system. This is an equivalent method.
>>>> It is not equivalent because pgd_alloc() now populates entries in
>>>> pgds that are
>>>> not visible to xen_mm_pin_all() (note how the original code adds the
>>>> pgd to the
>>>> pgd_list in pgd_ctor() before calling pgd_prepopulate_pmd()).  These
>>>> newly
>>>> allocated page tables won't be correctly converted on suspend/resume
>>>> and the new
>>>> process will die after resume.
>>> So how should the Xen logic be fixed for the new scheme? I can't say
>>> I can see
>>> through the paravirt complexity here.
>> Actually, since we freeze_processes() before trying to pin page tables,
>> I think it should be ok as-is.
>>
>> I'll put the patch through some tests.
> 
> Actually, I just ran this through a couple of boot/suspend/resume tests
> and didn't see any issues (with the one fix I mentioned to Ingo
> earlier). On unstable Xen only.

In which case this can have a:

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

Thanks.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
