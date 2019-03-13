Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74F2BC10F03
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 23:23:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13B1921019
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 23:23:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13B1921019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB1958E000C; Wed, 13 Mar 2019 19:23:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B61388E0001; Wed, 13 Mar 2019 19:23:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4FA98E000C; Wed, 13 Mar 2019 19:23:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69EE08E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 19:23:11 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id t15so1555715otk.4
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 16:23:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=Q2yzGy8Up5RijkmMQQzeyBjDUfhrLxmOdP/p+EKf+TU=;
        b=TsTIDm8ffPBpeYtd74cYck2yn8WzUfLh6Ne+Yc56y27JcVTHL3aOI89nlxzmwA+6V8
         50GNJiFBa/yYg+sR8zscAk609N1U2YdLD8FpCJygvPtgsov5qxn4X1qD0nHw5YMiwY9w
         kyiMjh/2omwhFauHAgSDHf2e8RJ1JjicZFaRjOiiJuatfmFkLVDEamONR0ho/05G/a2W
         Q9vUJn/jfpse0bB8t0oC2SFwSCTbKcq3eJ0LXP5U4f8xhXqVdRwL78ssp6e19+MB1yTf
         4/J1tcWxPzoxDpCBZO/MWc5L+QNenIYcbvO98dRYTsx4eshzV7BVYRNuIseit6fi3JPa
         ZUsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU7diwexPB5iu81xjg/jQ3KBzgxevIHNcWdHutzYENLuvGvCleT
	qtDyAraKa0ZxKA21RSzXZiiyILfEfJyVVHMKv6bmkCfb6oAqx4hSpYkE5F+e5qUeacCk2cZOiAf
	5uVGW/IM7r9OpE/PuJTXkt1+iwa2SjNkm1EtbRBXhOpfq1mE2zaz84oPkJPyrwDmdGuHti3FVnN
	NiwtWSmZSg7TjTqRKbBuft8fhu7Vcm+CrnWG1srJYvqvTS+8oereVRn81BnWI0wRnfPnyFBMa1+
	o61Wn39dNA1Q+3/ODnEtqrQpK6TMzSUZRBf+72L0UTh1vIU6qsof6pyLzTHDFqLUxUVBOd+qdke
	pxJC1YdKoYK71SBB6dNF92+BD+/udxP4plUwRhbqkSI9veta1CIBfq2FZ+un3Jf5QWsJEe2Wpg=
	=
X-Received: by 2002:a05:6830:14c1:: with SMTP id t1mr30311838otq.48.1552519391124;
        Wed, 13 Mar 2019 16:23:11 -0700 (PDT)
X-Received: by 2002:a05:6830:14c1:: with SMTP id t1mr30311806otq.48.1552519389786;
        Wed, 13 Mar 2019 16:23:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552519389; cv=none;
        d=google.com; s=arc-20160816;
        b=u6x494oX0pztFuRxvfOrfY5oduMxXkzUrfPr7AGmmF9w9VvndNbv1gP59FIsu+R3P9
         tBE8vp1DOwX3xIhFZPhzZOwNLGJvNvNEXmknKEijy2iXlEmFpcYLqD2w9QiRABTcdB9R
         9xgRoim8xCfi/ofYkNBlGcWOb4H8CELeHtijKuPT7BtVwxQD5TuS8SswboKf45JLzKKX
         yBjalkJc9Q9llfSoUHaM48CxQ9Md4sHLcCfGpYwH0QUYz4P+XHBToNFYDPEQ4MQSOEK5
         WZNEHwxvIJV9la217o0xLCCgGuifvgf6DwDlug2N+vIv7CoJupWbmjgWd5oG1JnuwJZV
         KTVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=Q2yzGy8Up5RijkmMQQzeyBjDUfhrLxmOdP/p+EKf+TU=;
        b=VGX1boYj+E0D59pLfmxmf8ZetoVvMluQ+Ggm8gNhIDUiMvCDbb+wDP+8qzNsmtb9tJ
         d5WRMKh/PoO17w4d+4UwIphUfmd5QKJD+lOxziM9aye6cifVxbGQ2nBR+776HOaI7Pmn
         EdJ4gxxjrye2llrXwjWkasUb69WVtwzBXUO03WB5/kGd7XwLnXh854vgX5cW3ImK/dhX
         KtLgTop91cSk51f3EUJXon+1abT7HwBBsVeFRHCZPpzLuuUFxbQ9FWAeAgNIdKDnMhoU
         WxGFQOwcCJQE5pRK0ng/augB7LOvSDvr5uauo5H0NUKxDAGPVRsfIehYOJ8Eou7PpJyW
         gAiw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i1sor7749662otc.70.2019.03.13.16.23.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 16:23:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqwEhfD+Dpjy5A26uD7mkAe2L2+aMR7vn3Wpk0YBShuHd0QcjVWrL58j8VCwhyxJWavHJFuVWF1gJuGyny7N+5U=
X-Received: by 2002:a9d:6498:: with SMTP id g24mr30326216otl.343.1552519389344;
 Wed, 13 Mar 2019 16:23:09 -0700 (PDT)
MIME-Version: 1.0
References: <20190311205606.11228-1-keith.busch@intel.com> <20190311205606.11228-8-keith.busch@intel.com>
In-Reply-To: <20190311205606.11228-8-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 14 Mar 2019 00:22:58 +0100
Message-ID: <CAJZ5v0iO0ArbyXRZX5MKSf10SY+HRKkaRs7SUmo+KdA0ecOLHQ@mail.gmail.com>
Subject: Re: [PATCHv8 07/10] acpi/hmat: Register processor domain to its memory
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, 
	Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, 
	Jonathan Cameron <jonathan.cameron@huawei.com>, Brice Goglin <Brice.Goglin@inria.fr>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 9:55 PM Keith Busch <keith.busch@intel.com> wrote:
>
> If the HMAT Subsystem Address Range provides a valid processor proximity
> domain for a memory domain, or a processor domain matches the performance
> access of the valid processor proximity domain, register the memory
> target with that initiator so this relationship will be visible under
> the node's sysfs directory.
>
> Since HMAT requires valid address ranges have an equivalent SRAT entry,
> verify each memory target satisfies this requirement.
>
> Reviewed-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> Signed-off-by: Keith Busch <keith.busch@intel.com>

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

> ---
>  drivers/acpi/hmat/Kconfig |   3 +-
>  drivers/acpi/hmat/hmat.c  | 392 +++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 393 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> index 2f7111b7af62..13cddd612a52 100644
> --- a/drivers/acpi/hmat/Kconfig
> +++ b/drivers/acpi/hmat/Kconfig
> @@ -4,4 +4,5 @@ config ACPI_HMAT
>         depends on ACPI_NUMA
>         help
>          If set, this option has the kernel parse and report the
> -        platform's ACPI HMAT (Heterogeneous Memory Attributes Table).
> +        platform's ACPI HMAT (Heterogeneous Memory Attributes Table),
> +        and register memory initiators with their targets.
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> index 4758beb3b2c1..01a6eddac6f7 100644
> --- a/drivers/acpi/hmat/hmat.c
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -13,11 +13,105 @@
>  #include <linux/device.h>
>  #include <linux/init.h>
>  #include <linux/list.h>
> +#include <linux/list_sort.h>
>  #include <linux/node.h>
>  #include <linux/sysfs.h>
>
>  static __initdata u8 hmat_revision;
>
> +static __initdata LIST_HEAD(targets);
> +static __initdata LIST_HEAD(initiators);
> +static __initdata LIST_HEAD(localities);
> +
> +/*
> + * The defined enum order is used to prioritize attributes to break ties when
> + * selecting the best performing node.
> + */
> +enum locality_types {
> +       WRITE_LATENCY,
> +       READ_LATENCY,
> +       WRITE_BANDWIDTH,
> +       READ_BANDWIDTH,
> +};
> +
> +static struct memory_locality *localities_types[4];
> +
> +struct memory_target {
> +       struct list_head node;
> +       unsigned int memory_pxm;
> +       unsigned int processor_pxm;
> +       struct node_hmem_attrs hmem_attrs;
> +};
> +
> +struct memory_initiator {
> +       struct list_head node;
> +       unsigned int processor_pxm;
> +};
> +
> +struct memory_locality {
> +       struct list_head node;
> +       struct acpi_hmat_locality *hmat_loc;
> +};
> +
> +static __init struct memory_initiator *find_mem_initiator(unsigned int cpu_pxm)
> +{
> +       struct memory_initiator *initiator;
> +
> +       list_for_each_entry(initiator, &initiators, node)
> +               if (initiator->processor_pxm == cpu_pxm)
> +                       return initiator;
> +       return NULL;
> +}
> +
> +static __init struct memory_target *find_mem_target(unsigned int mem_pxm)
> +{
> +       struct memory_target *target;
> +
> +       list_for_each_entry(target, &targets, node)
> +               if (target->memory_pxm == mem_pxm)
> +                       return target;
> +       return NULL;
> +}
> +
> +static __init void alloc_memory_initiator(unsigned int cpu_pxm)
> +{
> +       struct memory_initiator *initiator;
> +
> +       if (pxm_to_node(cpu_pxm) == NUMA_NO_NODE)
> +               return;
> +
> +       initiator = find_mem_initiator(cpu_pxm);
> +       if (initiator)
> +               return;
> +
> +       initiator = kzalloc(sizeof(*initiator), GFP_KERNEL);
> +       if (!initiator)
> +               return;
> +
> +       initiator->processor_pxm = cpu_pxm;
> +       list_add_tail(&initiator->node, &initiators);
> +}
> +
> +static __init void alloc_memory_target(unsigned int mem_pxm)
> +{
> +       struct memory_target *target;
> +
> +       if (pxm_to_node(mem_pxm) == NUMA_NO_NODE)
> +               return;
> +
> +       target = find_mem_target(mem_pxm);
> +       if (target)
> +               return;
> +
> +       target = kzalloc(sizeof(*target), GFP_KERNEL);
> +       if (!target)
> +               return;
> +
> +       target->memory_pxm = mem_pxm;
> +       target->processor_pxm = PXM_INVAL;
> +       list_add_tail(&target->node, &targets);
> +}
> +
>  static __init const char *hmat_data_type(u8 type)
>  {
>         switch (type) {
> @@ -89,14 +183,83 @@ static __init u32 hmat_normalize(u16 entry, u64 base, u8 type)
>         return value;
>  }
>
> +static __init void hmat_update_target_access(struct memory_target *target,
> +                                            u8 type, u32 value)
> +{
> +       switch (type) {
> +       case ACPI_HMAT_ACCESS_LATENCY:
> +               target->hmem_attrs.read_latency = value;
> +               target->hmem_attrs.write_latency = value;
> +               break;
> +       case ACPI_HMAT_READ_LATENCY:
> +               target->hmem_attrs.read_latency = value;
> +               break;
> +       case ACPI_HMAT_WRITE_LATENCY:
> +               target->hmem_attrs.write_latency = value;
> +               break;
> +       case ACPI_HMAT_ACCESS_BANDWIDTH:
> +               target->hmem_attrs.read_bandwidth = value;
> +               target->hmem_attrs.write_bandwidth = value;
> +               break;
> +       case ACPI_HMAT_READ_BANDWIDTH:
> +               target->hmem_attrs.read_bandwidth = value;
> +               break;
> +       case ACPI_HMAT_WRITE_BANDWIDTH:
> +               target->hmem_attrs.write_bandwidth = value;
> +               break;
> +       default:
> +               break;
> +       }
> +}
> +
> +static __init void hmat_add_locality(struct acpi_hmat_locality *hmat_loc)
> +{
> +       struct memory_locality *loc;
> +
> +       loc = kzalloc(sizeof(*loc), GFP_KERNEL);
> +       if (!loc) {
> +               pr_notice_once("Failed to allocate HMAT locality\n");
> +               return;
> +       }
> +
> +       loc->hmat_loc = hmat_loc;
> +       list_add_tail(&loc->node, &localities);
> +
> +       switch (hmat_loc->data_type) {
> +       case ACPI_HMAT_ACCESS_LATENCY:
> +               localities_types[READ_LATENCY] = loc;
> +               localities_types[WRITE_LATENCY] = loc;
> +               break;
> +       case ACPI_HMAT_READ_LATENCY:
> +               localities_types[READ_LATENCY] = loc;
> +               break;
> +       case ACPI_HMAT_WRITE_LATENCY:
> +               localities_types[WRITE_LATENCY] = loc;
> +               break;
> +       case ACPI_HMAT_ACCESS_BANDWIDTH:
> +               localities_types[READ_BANDWIDTH] = loc;
> +               localities_types[WRITE_BANDWIDTH] = loc;
> +               break;
> +       case ACPI_HMAT_READ_BANDWIDTH:
> +               localities_types[READ_BANDWIDTH] = loc;
> +               break;
> +       case ACPI_HMAT_WRITE_BANDWIDTH:
> +               localities_types[WRITE_BANDWIDTH] = loc;
> +               break;
> +       default:
> +               break;
> +       }
> +}
> +
>  static __init int hmat_parse_locality(union acpi_subtable_headers *header,
>                                       const unsigned long end)
>  {
>         struct acpi_hmat_locality *hmat_loc = (void *)header;
> +       struct memory_target *target;
>         unsigned int init, targ, total_size, ipds, tpds;
>         u32 *inits, *targs, value;
>         u16 *entries;
> -       u8 type;
> +       u8 type, mem_hier;
>
>         if (hmat_loc->header.length < sizeof(*hmat_loc)) {
>                 pr_notice("HMAT: Unexpected locality header length: %d\n",
> @@ -105,6 +268,7 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
>         }
>
>         type = hmat_loc->data_type;
> +       mem_hier = hmat_loc->flags & ACPI_HMAT_MEMORY_HIERARCHY;
>         ipds = hmat_loc->number_of_initiator_Pds;
>         tpds = hmat_loc->number_of_target_Pds;
>         total_size = sizeof(*hmat_loc) + sizeof(*entries) * ipds * tpds +
> @@ -123,6 +287,7 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
>         targs = inits + ipds;
>         entries = (u16 *)(targs + tpds);
>         for (init = 0; init < ipds; init++) {
> +               alloc_memory_initiator(inits[init]);
>                 for (targ = 0; targ < tpds; targ++) {
>                         value = hmat_normalize(entries[init * tpds + targ],
>                                                hmat_loc->entry_base_unit,
> @@ -130,9 +295,18 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
>                         pr_info("  Initiator-Target[%d-%d]:%d%s\n",
>                                 inits[init], targs[targ], value,
>                                 hmat_data_type_suffix(type));
> +
> +                       if (mem_hier == ACPI_HMAT_MEMORY) {
> +                               target = find_mem_target(targs[targ]);
> +                               if (target && target->processor_pxm == inits[init])
> +                                       hmat_update_target_access(target, type, value);
> +                       }
>                 }
>         }
>
> +       if (mem_hier == ACPI_HMAT_MEMORY)
> +               hmat_add_locality(hmat_loc);
> +
>         return 0;
>  }
>
> @@ -160,6 +334,7 @@ static int __init hmat_parse_proximity_domain(union acpi_subtable_headers *heade
>                                               const unsigned long end)
>  {
>         struct acpi_hmat_proximity_domain *p = (void *)header;
> +       struct memory_target *target;
>
>         if (p->header.length != sizeof(*p)) {
>                 pr_notice("HMAT: Unexpected address range header length: %d\n",
> @@ -175,6 +350,23 @@ static int __init hmat_parse_proximity_domain(union acpi_subtable_headers *heade
>                 pr_info("HMAT: Memory Flags:%04x Processor Domain:%d Memory Domain:%d\n",
>                         p->flags, p->processor_PD, p->memory_PD);
>
> +       if (p->flags & ACPI_HMAT_MEMORY_PD_VALID) {
> +               target = find_mem_target(p->memory_PD);
> +               if (!target) {
> +                       pr_debug("HMAT: Memory Domain missing from SRAT\n");
> +                       return -EINVAL;
> +               }
> +       }
> +       if (target && p->flags & ACPI_HMAT_PROCESSOR_PD_VALID) {
> +               int p_node = pxm_to_node(p->processor_PD);
> +
> +               if (p_node == NUMA_NO_NODE) {
> +                       pr_debug("HMAT: Invalid Processor Domain\n");
> +                       return -EINVAL;
> +               }
> +               target->processor_pxm = p_node;
> +       }
> +
>         return 0;
>  }
>
> @@ -198,6 +390,191 @@ static int __init hmat_parse_subtable(union acpi_subtable_headers *header,
>         }
>  }
>
> +static __init int srat_parse_mem_affinity(union acpi_subtable_headers *header,
> +                                         const unsigned long end)
> +{
> +       struct acpi_srat_mem_affinity *ma = (void *)header;
> +
> +       if (!ma)
> +               return -EINVAL;
> +       if (!(ma->flags & ACPI_SRAT_MEM_ENABLED))
> +               return 0;
> +       alloc_memory_target(ma->proximity_domain);
> +       return 0;
> +}
> +
> +static __init u32 hmat_initiator_perf(struct memory_target *target,
> +                              struct memory_initiator *initiator,
> +                              struct acpi_hmat_locality *hmat_loc)
> +{
> +       unsigned int ipds, tpds, i, idx = 0, tdx = 0;
> +       u32 *inits, *targs;
> +       u16 *entries;
> +
> +       ipds = hmat_loc->number_of_initiator_Pds;
> +       tpds = hmat_loc->number_of_target_Pds;
> +       inits = (u32 *)(hmat_loc + 1);
> +       targs = inits + ipds;
> +       entries = (u16 *)(targs + tpds);
> +
> +       for (i = 0; i < ipds; i++) {
> +               if (inits[i] == initiator->processor_pxm) {
> +                       idx = i;
> +                       break;
> +               }
> +       }
> +
> +       if (i == ipds)
> +               return 0;
> +
> +       for (i = 0; i < tpds; i++) {
> +               if (targs[i] == target->memory_pxm) {
> +                       tdx = i;
> +                       break;
> +               }
> +       }
> +       if (i == tpds)
> +               return 0;
> +
> +       return hmat_normalize(entries[idx * tpds + tdx],
> +                             hmat_loc->entry_base_unit,
> +                             hmat_loc->data_type);
> +}
> +
> +static __init bool hmat_update_best(u8 type, u32 value, u32 *best)
> +{
> +       bool updated = false;
> +
> +       if (!value)
> +               return false;
> +
> +       switch (type) {
> +       case ACPI_HMAT_ACCESS_LATENCY:
> +       case ACPI_HMAT_READ_LATENCY:
> +       case ACPI_HMAT_WRITE_LATENCY:
> +               if (!*best || *best > value) {
> +                       *best = value;
> +                       updated = true;
> +               }
> +               break;
> +       case ACPI_HMAT_ACCESS_BANDWIDTH:
> +       case ACPI_HMAT_READ_BANDWIDTH:
> +       case ACPI_HMAT_WRITE_BANDWIDTH:
> +               if (!*best || *best < value) {
> +                       *best = value;
> +                       updated = true;
> +               }
> +               break;
> +       }
> +
> +       return updated;
> +}
> +
> +static int initiator_cmp(void *priv, struct list_head *a, struct list_head *b)
> +{
> +       struct memory_initiator *ia;
> +       struct memory_initiator *ib;
> +       unsigned long *p_nodes = priv;
> +
> +       ia = list_entry(a, struct memory_initiator, node);
> +       ib = list_entry(b, struct memory_initiator, node);
> +
> +       set_bit(ia->processor_pxm, p_nodes);
> +       set_bit(ib->processor_pxm, p_nodes);
> +
> +       return ia->processor_pxm - ib->processor_pxm;
> +}
> +
> +static __init void hmat_register_target_initiators(struct memory_target *target)
> +{
> +       static DECLARE_BITMAP(p_nodes, MAX_NUMNODES);
> +       struct memory_initiator *initiator;
> +       unsigned int mem_nid, cpu_nid;
> +       struct memory_locality *loc = NULL;
> +       u32 best = 0;
> +       int i;
> +
> +       mem_nid = pxm_to_node(target->memory_pxm);
> +       /*
> +        * If the Address Range Structure provides a local processor pxm, link
> +        * only that one. Otherwise, find the best performance attributes and
> +        * register all initiators that match.
> +        */
> +       if (target->processor_pxm != PXM_INVAL) {
> +               cpu_nid = pxm_to_node(target->processor_pxm);
> +               register_memory_node_under_compute_node(mem_nid, cpu_nid, 0);
> +               return;
> +       }
> +
> +       if (list_empty(&localities))
> +               return;
> +
> +       /*
> +        * We need the initiator list sorted so we can use bitmap_clear for
> +        * previously set initiators when we find a better memory accessor.
> +        * We'll also use the sorting to prime the candidate nodes with known
> +        * initiators.
> +        */
> +       bitmap_zero(p_nodes, MAX_NUMNODES);
> +       list_sort(p_nodes, &initiators, initiator_cmp);
> +       for (i = WRITE_LATENCY; i <= READ_BANDWIDTH; i++) {
> +               loc = localities_types[i];
> +               if (!loc)
> +                       continue;
> +
> +               best = 0;
> +               list_for_each_entry(initiator, &initiators, node) {
> +                       u32 value;
> +
> +                       if (!test_bit(initiator->processor_pxm, p_nodes))
> +                               continue;
> +
> +                       value = hmat_initiator_perf(target, initiator, loc->hmat_loc);
> +                       if (hmat_update_best(loc->hmat_loc->data_type, value, &best))
> +                               bitmap_clear(p_nodes, 0, initiator->processor_pxm);
> +                       if (value != best)
> +                               clear_bit(initiator->processor_pxm, p_nodes);
> +               }
> +               if (best)
> +                       hmat_update_target_access(target, loc->hmat_loc->data_type, best);
> +       }
> +
> +       for_each_set_bit(i, p_nodes, MAX_NUMNODES) {
> +               cpu_nid = pxm_to_node(i);
> +               register_memory_node_under_compute_node(mem_nid, cpu_nid, 0);
> +       }
> +}
> +
> +static __init void hmat_register_targets(void)
> +{
> +       struct memory_target *target;
> +
> +       list_for_each_entry(target, &targets, node)
> +               hmat_register_target_initiators(target);
> +}
> +
> +static __init void hmat_free_structures(void)
> +{
> +       struct memory_target *target, *tnext;
> +       struct memory_locality *loc, *lnext;
> +       struct memory_initiator *initiator, *inext;
> +
> +       list_for_each_entry_safe(target, tnext, &targets, node) {
> +               list_del(&target->node);
> +               kfree(target);
> +       }
> +
> +       list_for_each_entry_safe(initiator, inext, &initiators, node) {
> +               list_del(&initiator->node);
> +               kfree(initiator);
> +       }
> +
> +       list_for_each_entry_safe(loc, lnext, &localities, node) {
> +               list_del(&loc->node);
> +               kfree(loc);
> +       }
> +}
> +
>  static __init int hmat_init(void)
>  {
>         struct acpi_table_header *tbl;
> @@ -207,6 +584,17 @@ static __init int hmat_init(void)
>         if (srat_disabled())
>                 return 0;
>
> +       status = acpi_get_table(ACPI_SIG_SRAT, 0, &tbl);
> +       if (ACPI_FAILURE(status))
> +               return 0;
> +
> +       if (acpi_table_parse_entries(ACPI_SIG_SRAT,
> +                               sizeof(struct acpi_table_srat),
> +                               ACPI_SRAT_TYPE_MEMORY_AFFINITY,
> +                               srat_parse_mem_affinity, 0) < 0)
> +               goto out_put;
> +       acpi_put_table(tbl);
> +
>         status = acpi_get_table(ACPI_SIG_HMAT, 0, &tbl);
>         if (ACPI_FAILURE(status))
>                 return 0;
> @@ -229,7 +617,9 @@ static __init int hmat_init(void)
>                         goto out_put;
>                 }
>         }
> +       hmat_register_targets();
>  out_put:
> +       hmat_free_structures();
>         acpi_put_table(tbl);
>         return 0;
>  }
> --
> 2.14.4
>

