Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id D7BEC6B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 16:03:01 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id w15-v6so9226110ybm.15
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 13:03:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b198-v6sor928030ywa.470.2018.10.01.13.03.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Oct 2018 13:03:00 -0700 (PDT)
Received: from mail-yw1-f54.google.com (mail-yw1-f54.google.com. [209.85.161.54])
        by smtp.gmail.com with ESMTPSA id e82-v6sm11868053ywa.60.2018.10.01.13.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 13:02:57 -0700 (PDT)
Received: by mail-yw1-f54.google.com with SMTP id m127-v6so2446777ywb.0
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 13:02:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181001185616.11427.35521.stgit@ltcalpine2-lp9.aus.stglabs.ibm.com>
References: <20181001185616.11427.35521.stgit@ltcalpine2-lp9.aus.stglabs.ibm.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 1 Oct 2018 13:02:56 -0700
Message-ID: <CAGXu5jL2xgiXZ_9bdY9fWJB7dKvzKO7L9Xb83M0mmmhQrZSZcQ@mail.gmail.com>
Subject: Re: [PATCH] migration/mm: Add WARN_ON to try_offline_node
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Bringmann <mwb@linux.vnet.ibm.com>
Cc: PowerPC <linuxppc-dev@lists.ozlabs.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michael Ellerman <mpe@ellerman.id.au>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Nicholas Piggin <npiggin@gmail.com>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Russell Currey <ruscur@russell.cc>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Christophe Leroy <christophe.leroy@c-s.fr>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Mathieu Malaterre <malat@debian.org>, Juliet Kim <minkim@us.ibm.com>, Tyrel Datwyler <tyreld@linux.vnet.ibm.com>, Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

On Mon, Oct 1, 2018 at 11:56 AM, Michael Bringmann
<mwb@linux.vnet.ibm.com> wrote:
> In some LPAR migration scenarios, device-tree modifications are
> made to the affinity of the memory in the system.  For instance,
> it may occur that memory is installed to nodes 0,3 on a source
> system, and to nodes 0,2 on a target system.  Node 2 may not
> have been initialized/allocated on the target system.
>
> After migration, if a RTAS PRRN memory remove is made to a
> memory block that was in node 3 on the source system, then
> try_offline_node tries to remove it from node 2 on the target.
> The NODE_DATA(2) block would not be initialized on the target,
> and there is no validation check in the current code to prevent
> the use of a NULL pointer.  Call traces such as the following
> may be observed:
>
> A similar problem of moving memory to an unitialized node has
> also been observed on systems where multiple PRRN events occur
> prior to a complete update of the device-tree.
>
> pseries-hotplug-mem: Attempting to update LMB, drc index 80000002
> Offlined Pages 4096
> ...
> Oops: Kernel access of bad area, sig: 11 [#1]
> ...
> Workqueue: pseries hotplug workque pseries_hp_work_fn
> ...
> NIP [c0000000002bc088] try_offline_node+0x48/0x1e0
> LR [c0000000002e0b84] remove_memory+0xb4/0xf0
> Call Trace:
> [c0000002bbee7a30] [c0000002bbee7a70] 0xc0000002bbee7a70 (unreliable)
> [c0000002bbee7a70] [c0000000002e0b84] remove_memory+0xb4/0xf0
> [c0000002bbee7ab0] [c000000000097784] dlpar_remove_lmb+0xb4/0x160
> [c0000002bbee7af0] [c000000000097f38] dlpar_memory+0x328/0xcb0
> [c0000002bbee7ba0] [c0000000000906d0] handle_dlpar_errorlog+0xc0/0x130
> [c0000002bbee7c10] [c0000000000907d4] pseries_hp_work_fn+0x94/0xa0
> [c0000002bbee7c40] [c0000000000e1cd0] process_one_work+0x1a0/0x4e0
> [c0000002bbee7cd0] [c0000000000e21b0] worker_thread+0x1a0/0x610
> [c0000002bbee7d80] [c0000000000ea458] kthread+0x128/0x150
> [c0000002bbee7e30] [c00000000000982c] ret_from_kernel_thread+0x5c/0xb0
>
> This patch adds a check for an incorrectly initialized to the
> beginning of try_offline_node, and exits the routine.
>
> Another patch is being developed for powerpc to track the
> node Id to which an LMB belongs, so that we can remove the
> LMB from there instead of the nid as currently interpreted
> from the device tree.
>
> Signed-off-by: Michael Bringmann <mwb@linux.vnet.ibm.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  mm/memory_hotplug.c |   10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
>
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 38d94b7..e48a4d0 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1831,10 +1831,16 @@ static int check_and_unmap_cpu_on_node(pg_data_t *pgdat)
>  void try_offline_node(int nid)
>  {
>         pg_data_t *pgdat = NODE_DATA(nid);
> -       unsigned long start_pfn = pgdat->node_start_pfn;
> -       unsigned long end_pfn = start_pfn + pgdat->node_spanned_pages;
> +       unsigned long start_pfn;
> +       unsigned long end_pfn;
>         unsigned long pfn;
>
> +       if (WARN_ON(pgdat == NULL))
> +               return;
> +
> +       start_pfn = pgdat->node_start_pfn;
> +       end_pfn = start_pfn + pgdat->node_spanned_pages;
> +
>         for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
>                 unsigned long section_nr = pfn_to_section_nr(pfn);
>
>



-- 
Kees Cook
Pixel Security
