Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 38AB26B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 13:13:21 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id hr10so78526368pac.2
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 10:13:21 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id z66si604384pfk.207.2016.11.09.10.13.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 10:13:20 -0800 (PST)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id F293B203A1
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 18:13:18 +0000 (UTC)
Received: from mail-yw0-f178.google.com (mail-yw0-f178.google.com [209.85.161.178])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4D42D20386
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 18:13:16 +0000 (UTC)
Received: by mail-yw0-f178.google.com with SMTP id r204so215777720ywb.0
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 10:13:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1478562276-25539-5-git-send-email-arbab@linux.vnet.ibm.com>
References: <1478562276-25539-1-git-send-email-arbab@linux.vnet.ibm.com> <1478562276-25539-5-git-send-email-arbab@linux.vnet.ibm.com>
From: Rob Herring <robh+dt@kernel.org>
Date: Wed, 9 Nov 2016 12:12:55 -0600
Message-ID: <CAL_JsqLmAv4Pueq9XveeWMD3Jn_o6mGUcyztx8OajBGTrEd0aQ@mail.gmail.com>
Subject: Re: [PATCH v6 4/4] of/fdt: mark hotpluggable memory
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Frank Rowand <frowand.list@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Nov 7, 2016 at 5:44 PM, Reza Arbab <arbab@linux.vnet.ibm.com> wrote:
> When movable nodes are enabled, any node containing only hotpluggable
> memory is made movable at boot time.
>
> On x86, hotpluggable memory is discovered by parsing the ACPI SRAT,
> making corresponding calls to memblock_mark_hotplug().
>
> If we introduce a dt property to describe memory as hotpluggable,
> configs supporting early fdt may then also do this marking and use
> movable nodes.
>
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---
>  drivers/of/fdt.c | 6 ++++++
>  mm/Kconfig       | 2 +-
>  2 files changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> index c89d5d2..2cf1d66 100644
> --- a/drivers/of/fdt.c
> +++ b/drivers/of/fdt.c
> @@ -1015,6 +1015,7 @@ int __init early_init_dt_scan_memory(unsigned long node, const char *uname,
>         const char *type = of_get_flat_dt_prop(node, "device_type", NULL);
>         const __be32 *reg, *endp;
>         int l;
> +       bool hotpluggable;
>
>         /* We are scanning "memory" nodes only */
>         if (type == NULL) {
> @@ -1034,6 +1035,7 @@ int __init early_init_dt_scan_memory(unsigned long node, const char *uname,
>                 return 0;
>
>         endp = reg + (l / sizeof(__be32));
> +       hotpluggable = of_get_flat_dt_prop(node, "linux,hotpluggable", NULL);

Memory being hotpluggable doesn't seem like a linux property to me.
I'd drop the linux prefix. Also, this needs to be documented.

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
