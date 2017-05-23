Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 064696B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 05:27:40 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j22so50745639qtj.15
        for <linux-mm@kvack.org>; Tue, 23 May 2017 02:27:40 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id 125si20767795qkg.36.2017.05.23.02.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 02:27:39 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id u75so22117268qka.1
        for <linux-mm@kvack.org>; Tue, 23 May 2017 02:27:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170523040524.13717-1-oohall@gmail.com>
References: <20170523040524.13717-1-oohall@gmail.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 23 May 2017 19:27:38 +1000
Message-ID: <CAKTCnzmtfZ54hem8Yvc4HSnOYx+7BXrMOHdn1LdM+QtrbHJJiw@mail.gmail.com>
Subject: Re: [PATCH 1/6] powerpc/mm: Wire up hpte_removebolted for powernv
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>
Cc: "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, Anton Blanchard <anton@samba.org>

On Tue, May 23, 2017 at 2:05 PM, Oliver O'Halloran <oohall@gmail.com> wrote:
> From: Anton Blanchard <anton@samba.org>
>
> Adds support for removing bolted (i.e kernel linear mapping) mappings on
> powernv. This is needed to support memory hot unplug operations which
> are required for the teardown of DAX/PMEM devices.
>
> Reviewed-by: Rashmica Gupta <rashmica.g@gmail.com>
> Signed-off-by: Anton Blanchard <anton@samba.org>
> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
> ---
> v1 -> v2: Fixed the commit author
>           Added VM_WARN_ON() if we attempt to remove an unbolted hpte
> ---
>  arch/powerpc/mm/hash_native_64.c | 33 +++++++++++++++++++++++++++++++++
>  1 file changed, 33 insertions(+)
>
> diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_native_64.c
> index 65bb8f33b399..b534d041cfe8 100644
> --- a/arch/powerpc/mm/hash_native_64.c
> +++ b/arch/powerpc/mm/hash_native_64.c
> @@ -407,6 +407,38 @@ static void native_hpte_updateboltedpp(unsigned long newpp, unsigned long ea,
>         tlbie(vpn, psize, psize, ssize, 0);
>  }
>
> +/*
> + * Remove a bolted kernel entry. Memory hotplug uses this.
> + *
> + * No need to lock here because we should be the only user.
> + */
> +static int native_hpte_removebolted(unsigned long ea, int psize, int ssize)
> +{
> +       unsigned long vpn;
> +       unsigned long vsid;
> +       long slot;
> +       struct hash_pte *hptep;
> +
> +       vsid = get_kernel_vsid(ea, ssize);
> +       vpn = hpt_vpn(ea, vsid, ssize);
> +
> +       slot = native_hpte_find(vpn, psize, ssize);
> +       if (slot == -1)
> +               return -ENOENT;
> +
> +       hptep = htab_address + slot;
> +
> +       VM_WARN_ON(!(be64_to_cpu(hptep->v) & HPTE_V_BOLTED));
> +
> +       /* Invalidate the hpte */
> +       hptep->v = 0;
> +
> +       /* Invalidate the TLB */
> +       tlbie(vpn, psize, psize, ssize, 0);
> +       return 0;
> +}
> +

Reviewed-by: Balbir Singh <bsingharora@gmail.com>

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
