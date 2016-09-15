Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1C9086B0269
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 09:43:34 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id wk8so88438704pab.3
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 06:43:34 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id l62si4882964pfl.260.2016.09.15.06.43.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 06:43:33 -0700 (PDT)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id E14D72053A
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 13:43:31 +0000 (UTC)
Received: from mail-yb0-f169.google.com (mail-yb0-f169.google.com [209.85.213.169])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D951020525
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 13:43:29 +0000 (UTC)
Received: by mail-yb0-f169.google.com with SMTP id u125so33258583ybg.3
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 06:43:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1473883618-14998-2-git-send-email-arbab@linux.vnet.ibm.com>
References: <1473883618-14998-1-git-send-email-arbab@linux.vnet.ibm.com> <1473883618-14998-2-git-send-email-arbab@linux.vnet.ibm.com>
From: Rob Herring <robh+dt@kernel.org>
Date: Thu, 15 Sep 2016 08:43:08 -0500
Message-ID: <CAL_JsqK5ngY-eJggPSo5AGcv4CC2b8Y1X_aYzr06_Zf6Kv-u=w@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] drivers/of: recognize status property of dt memory nodes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Frank Rowand <frowand.list@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Sep 14, 2016 at 3:06 PM, Reza Arbab <arbab@linux.vnet.ibm.com> wrote:
> Respect the standard dt "status" property when scanning memory nodes in
> early_init_dt_scan_memory(), so that if the property is present and not
> "okay", no memory will be added.
>
> The use case at hand is accelerator or device memory, which may be
> unusable until post-boot initialization of the memory link. Such a node
> can be described in the dt as any other, given its status is "disabled".
> Per the device tree specification,
>
> "disabled"
>         Indicates that the device is not presently operational, but it
>         might become operational in the future (for example, something
>         is not plugged in, or switched off).
>
> Once such memory is made operational, it can then be hotplugged.
>
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---
>  drivers/of/fdt.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> index 085c638..fc19590 100644
> --- a/drivers/of/fdt.c
> +++ b/drivers/of/fdt.c
> @@ -1022,8 +1022,10 @@ int __init early_init_dt_scan_memory(unsigned long node, const char *uname,
>                                      int depth, void *data)
>  {
>         const char *type = of_get_flat_dt_prop(node, "device_type", NULL);
> +       const char *status;
>         const __be32 *reg, *endp;
>         int l;
> +       bool add_memory;
>
>         /* We are scanning "memory" nodes only */
>         if (type == NULL) {
> @@ -1044,6 +1046,9 @@ int __init early_init_dt_scan_memory(unsigned long node, const char *uname,
>
>         endp = reg + (l / sizeof(__be32));
>
> +       status = of_get_flat_dt_prop(node, "status", NULL);
> +       add_memory = !status || !strcmp(status, "okay");

Move this into it's own function to mirror the unflattened version
(of_device_is_available). Also, make sure the logic is the same. IIRC,
"ok" is also allowed.

> +
>         pr_debug("memory scan node %s, reg size %d,\n", uname, l);
>
>         while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
> @@ -1057,6 +1062,9 @@ int __init early_init_dt_scan_memory(unsigned long node, const char *uname,
>                 pr_debug(" - %llx ,  %llx\n", (unsigned long long)base,
>                     (unsigned long long)size);
>
> +               if (!add_memory)
> +                       continue;

There's no point in checking this in the loop. status applies to the
whole node. Just return up above.

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
