Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 763766B025E
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 23:08:10 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 16so74040224qtn.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 20:08:10 -0700 (PDT)
Received: from mail-yw0-f182.google.com (mail-yw0-f182.google.com. [209.85.161.182])
        by mx.google.com with ESMTPS id o9si12949653ybg.197.2016.09.20.20.08.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 20:08:09 -0700 (PDT)
Received: by mail-yw0-f182.google.com with SMTP id g192so32307837ywh.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 20:08:09 -0700 (PDT)
Subject: Re: [PATCH] mm: usercopy: Check for module addresses
References: <1474386996-16049-1-git-send-email-labbott@redhat.com>
 <CAGXu5jJBhNRF50q562THamJY-PKm9RpFW+id9GCaRzwezQ_xZA@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <c9060494-5b69-b346-b44d-249d62a3f662@redhat.com>
Date: Tue, 20 Sep 2016 20:08:06 -0700
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJBhNRF50q562THamJY-PKm9RpFW+id9GCaRzwezQ_xZA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 09/20/2016 04:01 PM, Kees Cook wrote:
> On Tue, Sep 20, 2016 at 8:56 AM, Laura Abbott <labbott@redhat.com> wrote:
>> While running a compile on arm64, I hit a memory exposure
>>
>> usercopy: kernel memory exposure attempt detected from fffffc0000f3b1a8 (buffer_head) (1 bytes)
>> ------------[ cut here ]------------
>> kernel BUG at mm/usercopy.c:75!
>> Internal error: Oops - BUG: 0 [#1] SMP
>> Modules linked in: ip6t_rpfilter ip6t_REJECT
>> nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_broute bridge stp
>> llc ebtable_nat ip6table_security ip6table_raw ip6table_nat
>> nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle
>> iptable_security iptable_raw iptable_nat nf_conntrack_ipv4
>> nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle
>> ebtable_filter ebtables ip6table_filter ip6_tables vfat fat xgene_edac
>> xgene_enet edac_core i2c_xgene_slimpro i2c_core at803x realtek xgene_dma
>> mdio_xgene gpio_dwapb gpio_xgene_sb xgene_rng mailbox_xgene_slimpro nfsd
>> auth_rpcgss nfs_acl lockd grace sunrpc xfs libcrc32c sdhci_of_arasan
>> sdhci_pltfm sdhci mmc_core xhci_plat_hcd gpio_keys
>> CPU: 0 PID: 19744 Comm: updatedb Tainted: G        W 4.8.0-rc3-threadinfo+ #1
>> Hardware name: AppliedMicro X-Gene Mustang Board/X-Gene Mustang Board, BIOS 3.06.12 Aug 12 2016
>> task: fffffe03df944c00 task.stack: fffffe00d128c000
>> PC is at __check_object_size+0x70/0x3f0
>> LR is at __check_object_size+0x70/0x3f0
>> ...
>> [<fffffc00082b4280>] __check_object_size+0x70/0x3f0
>> [<fffffc00082cdc30>] filldir64+0x158/0x1a0
>> [<fffffc0000f327e8>] __fat_readdir+0x4a0/0x558 [fat]
>> [<fffffc0000f328d4>] fat_readdir+0x34/0x40 [fat]
>> [<fffffc00082cd8f8>] iterate_dir+0x190/0x1e0
>> [<fffffc00082cde58>] SyS_getdents64+0x88/0x120
>> [<fffffc0008082c70>] el0_svc_naked+0x24/0x28
>>
>> fffffc0000f3b1a8 is a module address. Modules may have compiled in
>> strings which could get copied to userspace. In this instance, it
>> looks like "." which matches with a size of 1 byte. Extend the
>> is_vmalloc_addr check to be is_vmalloc_or_module_addr to cover
>> all possible cases.
>>
>> Signed-off-by: Laura Abbott <labbott@redhat.com>
>> ---
>> Longer term, it would be good to expand the check for to regions like
>> regular kernel memory.
>> ---
>>  mm/usercopy.c | 5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/usercopy.c b/mm/usercopy.c
>> index 8ebae91..d8b5bd3 100644
>> --- a/mm/usercopy.c
>> +++ b/mm/usercopy.c
>> @@ -145,8 +145,11 @@ static inline const char *check_heap_object(const void *ptr, unsigned long n,
>>          * Some architectures (arm64) return true for virt_addr_valid() on
>>          * vmalloced addresses. Work around this by checking for vmalloc
>>          * first.
>> +        *
>> +        * We also need to check for module addresses explicitly since we
>> +        * may copy static data from modules to userspace
>>          */
>> -       if (is_vmalloc_addr(ptr))
>> +       if (is_vmalloc_or_module_addr(ptr))
>>                 return NULL;
>
> I still don't understand why this happens on arm64 and not x86.
> (Really what I don't understand is what virt_addr_valid() is actually
> checking -- they seem to be checking very different things between x86
> and arm64.)

virt_addr_valid is supposed to return true if and only if virt_to_page
returns a valid pointer. arm64 is currently returning true in some
cases it shouldn't. I finally got to work on a patch to fix it up so
hopefully once that gets submitted we can drop these extra checks.

>
> Regardless, I'll get this pushed to Linus and try to make the -rc8 cut.
>
> Thanks!
>
> -Kees
>
>>
>>         if (!virt_addr_valid(ptr))
>> --
>> 2.7.4
>>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
