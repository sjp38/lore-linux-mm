Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id D33136B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 07:13:12 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u81so25698950oia.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 04:13:12 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0106.outbound.protection.outlook.com. [104.47.2.106])
        by mx.google.com with ESMTPS id 66si1489934otm.249.2016.07.07.04.13.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 04:13:12 -0700 (PDT)
Subject: Re: [PATCHv2 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
References: <20160629105736.15017-1-dsafonov@virtuozzo.com>
 <20160629105736.15017-4-dsafonov@virtuozzo.com>
 <CALCETrW+xWp-xVDjOyPkB5P3-zAubt4U65R4tVNsY34+406tTg@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <b451bdf2-3ce9-dc86-6f9c-fe3bd665d1d8@virtuozzo.com>
Date: Thu, 7 Jul 2016 14:11:58 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrW+xWp-xVDjOyPkB5P3-zAubt4U65R4tVNsY34+406tTg@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, xemul@virtuozzo.com, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>

On 07/06/2016 05:30 PM, Andy Lutomirski wrote:
> On Wed, Jun 29, 2016 at 3:57 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>> Add API to change vdso blob type with arch_prctl.
>> As this is usefull only by needs of CRIU, expose
>> this interface under CONFIG_CHECKPOINT_RESTORE.
>
>> +#ifdef CONFIG_CHECKPOINT_RESTORE
>> +       case ARCH_MAP_VDSO_X32:
>> +               return do_map_vdso(VDSO_X32, addr, false);
>> +       case ARCH_MAP_VDSO_32:
>> +               return do_map_vdso(VDSO_32, addr, false);
>> +       case ARCH_MAP_VDSO_64:
>> +               return do_map_vdso(VDSO_64, addr, false);
>> +#endif
>> +
>
> This will have an odd side effect: if the old mapping is still around,
> its .fault will start behaving erratically.  I wonder if we can either
> reliably zap the old vma (or check that it's not there any more)
> before mapping a new one or whether we can associate the vdso image
> with the vma (possibly by having a separate vm_special_mapping for
> each vdso_image.  The latter is quite easy: change vdso_image to embed
> vm_special_mapping and use container_of in vdso_fault to fish the
> vdso_image back out.  But we'd have to embed another
> vm_special_mapping for the vvar mapping as well for the same reason.
>
> I'm also a bit concerned that __install_special_mapping might not get
> all the cgroup and rlimit stuff right.  If we ensure that any old
> mappings are gone, then the damage is bounded, but otherwise someone
> might call this in a loop and fill their address space with arbitrary
> numbers of special mappings.

Well, I have deleted code that unmaps old vdso because I didn't saw
a reason why it's bad and wanted to reduce code. But well, now I do see
reasons, thanks.

Hmm, what do you think if I do it a little different way then embedding
vm_special_mapping: just that old hack with vma_ops. If I add a close()
hook there and make there context.vdso = NULL pointer, then I can test
it on remap. This can also have nice feature as restricting partial
munmap of vdso blob. Is this sounds sane?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
