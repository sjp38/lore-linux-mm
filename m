Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id ABA506B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 14:29:12 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id i12so233891540ywa.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 11:29:12 -0700 (PDT)
Received: from mail-vk0-x235.google.com (mail-vk0-x235.google.com. [2607:f8b0:400c:c05::235])
        by mx.google.com with ESMTPS id 88si1239758ual.63.2016.07.11.11.29.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 11:29:11 -0700 (PDT)
Received: by mail-vk0-x235.google.com with SMTP id f7so135557519vkb.3
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 11:29:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160711182654.GA19160@redhat.com>
References: <20160629105736.15017-1-dsafonov@virtuozzo.com>
 <20160629105736.15017-4-dsafonov@virtuozzo.com> <CALCETrW+xWp-xVDjOyPkB5P3-zAubt4U65R4tVNsY34+406tTg@mail.gmail.com>
 <b451bdf2-3ce9-dc86-6f9c-fe3bd665d1d8@virtuozzo.com> <CALCETrUEP-q-Be1i=L7hxX-nf4OpBv7edq2Mg0gi5TRX73FTsA@mail.gmail.com>
 <20160711182654.GA19160@redhat.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 11 Jul 2016 11:28:51 -0700
Message-ID: <CALCETrVaO_E923KY2bKGfG1tH75JBtEns4nKc+GWsYAx9NT0hQ@mail.gmail.com>
Subject: Re: [PATCHv2 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, xemul@virtuozzo.com, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>

On Mon, Jul 11, 2016 at 11:26 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> On 07/10, Andy Lutomirski wrote:
>>
>> On Thu, Jul 7, 2016 at 4:11 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>> > On 07/06/2016 05:30 PM, Andy Lutomirski wrote:
>> >>
>> >> On Wed, Jun 29, 2016 at 3:57 AM, Dmitry Safonov <dsafonov@virtuozzo.com>
>> >> wrote:
>> >>>
>> >>> Add API to change vdso blob type with arch_prctl.
>> >>> As this is usefull only by needs of CRIU, expose
>> >>> this interface under CONFIG_CHECKPOINT_RESTORE.
>> >>
>> >>
>> >>> +#ifdef CONFIG_CHECKPOINT_RESTORE
>> >>> +       case ARCH_MAP_VDSO_X32:
>> >>> +               return do_map_vdso(VDSO_X32, addr, false);
>> >>> +       case ARCH_MAP_VDSO_32:
>> >>> +               return do_map_vdso(VDSO_32, addr, false);
>> >>> +       case ARCH_MAP_VDSO_64:
>> >>> +               return do_map_vdso(VDSO_64, addr, false);
>> >>> +#endif
>> >>> +
>> >>
>> >>
>> >> This will have an odd side effect: if the old mapping is still around,
>> >> its .fault will start behaving erratically.
>
> Yes but I am not sure I fully understand your concerns, so let me ask...
>
> Do we really care? I mean, the kernel can't crash or something like this,
> just the old vdso mapping can faultin the "wrong" page from the new
> vdso_image, right?

That makes me nervous.  IMO a mapping should have well-defined
semantics.  If nothing else, could be really messy if the list of
pages were wrong.

My real concern is DoS: I doubt that __install_special_mapping gets
all the accounting right.

>
> The user of prctl(ARCH_MAP_VDSO) should understand what it does and unmap
> the old vdso anyway.
>
>> >> I wonder if we can either
>> >> reliably zap the old vma (or check that it's not there any more)
>> >> before mapping a new one
>
> However, I think this is right anyway, please see below...
>
>> >> or whether we can associate the vdso image
>> >> with the vma (possibly by having a separate vm_special_mapping for
>> >> each vdso_image.
>
> Yes, I too thought it would be nice to do this, regardless.
>
> But as you said we probably want to limit the numbet of special mappings
> an application can create:
>
>> >> I'm also a bit concerned that __install_special_mapping might not get
>> >> all the cgroup and rlimit stuff right.  If we ensure that any old
>> >> mappings are gone, then the damage is bounded, but otherwise someone
>> >> might call this in a loop and fill their address space with arbitrary
>> >> numbers of special mappings.
>
> I think you are right, we should not allow user-space to abuse the special
> mappings. Even if iiuc in this case only RLIMIT_AS does matter...
>
>> Oleg, want to sanity-check us?  Do you believe that if .mremap ensures
>> that only entire vma can be remapped
>
> Yes I think this makes sense. And damn we should kill arch_remap() ;)
>
>> and .close ensures that only the
>> whole vma can be unmapped,
>
> How? It can't return the error.
>
> And do_munmap() doesn't necessarily call ->close(),
>
>> Or will we have issues with
>> mprotect?
>
> Yes, __split_vma() doesn't call ->close() too. ->open() can't help...
>
> So it seems that we should do this by hand somehow. But in fact, what
> I actually think right now is that I am totally confused and got lost ;)

I'm starting to wonder if we should finally suck it up and give
special mappings a non-NULL vm_file so we can track them properly.
Oleg, weren't you thinking of doing that for some other reason?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
