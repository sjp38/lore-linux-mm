Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id A58676B0005
	for <linux-mm@kvack.org>; Sun, 10 Jul 2016 08:44:48 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id f7so169435412vkb.3
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 05:44:48 -0700 (PDT)
Received: from mail-vk0-x22b.google.com (mail-vk0-x22b.google.com. [2607:f8b0:400c:c05::22b])
        by mx.google.com with ESMTPS id o12si795869uao.147.2016.07.10.05.44.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jul 2016 05:44:47 -0700 (PDT)
Received: by mail-vk0-x22b.google.com with SMTP id v6so107703342vkb.2
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 05:44:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b451bdf2-3ce9-dc86-6f9c-fe3bd665d1d8@virtuozzo.com>
References: <20160629105736.15017-1-dsafonov@virtuozzo.com>
 <20160629105736.15017-4-dsafonov@virtuozzo.com> <CALCETrW+xWp-xVDjOyPkB5P3-zAubt4U65R4tVNsY34+406tTg@mail.gmail.com>
 <b451bdf2-3ce9-dc86-6f9c-fe3bd665d1d8@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sun, 10 Jul 2016 05:44:28 -0700
Message-ID: <CALCETrUEP-q-Be1i=L7hxX-nf4OpBv7edq2Mg0gi5TRX73FTsA@mail.gmail.com>
Subject: Re: [PATCHv2 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>, Oleg Nesterov <oleg@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, xemul@virtuozzo.com, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>

On Thu, Jul 7, 2016 at 4:11 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> On 07/06/2016 05:30 PM, Andy Lutomirski wrote:
>>
>> On Wed, Jun 29, 2016 at 3:57 AM, Dmitry Safonov <dsafonov@virtuozzo.com>
>> wrote:
>>>
>>> Add API to change vdso blob type with arch_prctl.
>>> As this is usefull only by needs of CRIU, expose
>>> this interface under CONFIG_CHECKPOINT_RESTORE.
>>
>>
>>> +#ifdef CONFIG_CHECKPOINT_RESTORE
>>> +       case ARCH_MAP_VDSO_X32:
>>> +               return do_map_vdso(VDSO_X32, addr, false);
>>> +       case ARCH_MAP_VDSO_32:
>>> +               return do_map_vdso(VDSO_32, addr, false);
>>> +       case ARCH_MAP_VDSO_64:
>>> +               return do_map_vdso(VDSO_64, addr, false);
>>> +#endif
>>> +
>>
>>
>> This will have an odd side effect: if the old mapping is still around,
>> its .fault will start behaving erratically.  I wonder if we can either
>> reliably zap the old vma (or check that it's not there any more)
>> before mapping a new one or whether we can associate the vdso image
>> with the vma (possibly by having a separate vm_special_mapping for
>> each vdso_image.  The latter is quite easy: change vdso_image to embed
>> vm_special_mapping and use container_of in vdso_fault to fish the
>> vdso_image back out.  But we'd have to embed another
>> vm_special_mapping for the vvar mapping as well for the same reason.
>>
>> I'm also a bit concerned that __install_special_mapping might not get
>> all the cgroup and rlimit stuff right.  If we ensure that any old
>> mappings are gone, then the damage is bounded, but otherwise someone
>> might call this in a loop and fill their address space with arbitrary
>> numbers of special mappings.
>
>
> Well, I have deleted code that unmaps old vdso because I didn't saw
> a reason why it's bad and wanted to reduce code. But well, now I do see
> reasons, thanks.
>
> Hmm, what do you think if I do it a little different way then embedding
> vm_special_mapping: just that old hack with vma_ops. If I add a close()
> hook there and make there context.vdso = NULL pointer, then I can test
> it on remap. This can also have nice feature as restricting partial
> munmap of vdso blob. Is this sounds sane?

I think so, as long as you do something to make sure that vvar gets
unmapped as well.

Oleg, want to sanity-check us?  Do you believe that if .mremap ensures
that only entire vma can be remapped and .close ensures that only the
whole vma can be unmapped, are we okay?  Or will we have issues with
mprotect?


-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
