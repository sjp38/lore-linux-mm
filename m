Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 322AE828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 10:30:39 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id f89so533010010qtd.1
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 07:30:39 -0700 (PDT)
Received: from mail-vk0-x230.google.com (mail-vk0-x230.google.com. [2607:f8b0:400c:c05::230])
        by mx.google.com with ESMTPS id 105si1063948uas.235.2016.07.06.07.30.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 07:30:38 -0700 (PDT)
Received: by mail-vk0-x230.google.com with SMTP id v6so36320016vkb.2
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 07:30:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160629105736.15017-4-dsafonov@virtuozzo.com>
References: <20160629105736.15017-1-dsafonov@virtuozzo.com> <20160629105736.15017-4-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 6 Jul 2016 07:30:18 -0700
Message-ID: <CALCETrW+xWp-xVDjOyPkB5P3-zAubt4U65R4tVNsY34+406tTg@mail.gmail.com>
Subject: Re: [PATCHv2 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, xemul@virtuozzo.com, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>

On Wed, Jun 29, 2016 at 3:57 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> Add API to change vdso blob type with arch_prctl.
> As this is usefull only by needs of CRIU, expose
> this interface under CONFIG_CHECKPOINT_RESTORE.

> +#ifdef CONFIG_CHECKPOINT_RESTORE
> +       case ARCH_MAP_VDSO_X32:
> +               return do_map_vdso(VDSO_X32, addr, false);
> +       case ARCH_MAP_VDSO_32:
> +               return do_map_vdso(VDSO_32, addr, false);
> +       case ARCH_MAP_VDSO_64:
> +               return do_map_vdso(VDSO_64, addr, false);
> +#endif
> +

This will have an odd side effect: if the old mapping is still around,
its .fault will start behaving erratically.  I wonder if we can either
reliably zap the old vma (or check that it's not there any more)
before mapping a new one or whether we can associate the vdso image
with the vma (possibly by having a separate vm_special_mapping for
each vdso_image.  The latter is quite easy: change vdso_image to embed
vm_special_mapping and use container_of in vdso_fault to fish the
vdso_image back out.  But we'd have to embed another
vm_special_mapping for the vvar mapping as well for the same reason.

I'm also a bit concerned that __install_special_mapping might not get
all the cgroup and rlimit stuff right.  If we ensure that any old
mappings are gone, then the damage is bounded, but otherwise someone
might call this in a loop and fill their address space with arbitrary
numbers of special mappings.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
