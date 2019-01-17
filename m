Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CF9BC43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 12:11:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32DA720855
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 12:11:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32DA720855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B36228E0004; Thu, 17 Jan 2019 07:11:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE5DB8E0002; Thu, 17 Jan 2019 07:11:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FC068E0004; Thu, 17 Jan 2019 07:11:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF318E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 07:11:16 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id b27so4826760otk.6
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 04:11:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=AxIgu+ssdyh4k+fK0G2jre2kzjLfEgitJPwARRAUwho=;
        b=QKZQChpJXPJsWbTu3ShVJEo5Il7yGuZmy2h7PmalddjkHA/nOV79RtzWrbp5YBBFwa
         O1w0l7pkCflZT+WqLDaAX1NiWWa1XjJw7lvsFgczr145h+hPJRBuxokDLMsslrJhbFXS
         I76lZr+f/pHo7R7gZnNIlKZQDNZA3xHCufEn+NPgM0aKz1qtkReuSUtbiZHXJ770CX9r
         +MMUH/NEUCpzxiWJL0IrDQLPcX6shEgX7J2X+dYOV68RJuDsnGt1BZtcgY6TcYcL6d6b
         4d2nf6BopaXJSGj4fdsayqu41bUNPGKeQzDBZYDZUZHqs2UK8RR/Kii1nEP4KW1cdLlO
         mDPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukeym8Yo6FFAWk/ZcA9v8rBAMiBJae2OyHaNq5j5rF/FN7CvensP
	XMjgb1NVgdoXoCfmbBgEYDE0DbzRqEkMC6Q8p1cI8vzkPOeNL9ezFOOOk+h2tJWtGiwSgUJtec/
	WoG41pHUBWmevcUmNUvUomJ2Hz1OpeQjOSDeRnpuM0CL3H0+1vd8OIMIir6efecVzgZu7bdAZoV
	TI/ohtVaVT7s8YlXbmtEd47Dy0ygg5HpMnYo/XtWx3PJNAlxYg6EYf4l5BKVJFZ/SRp+E/BVkKh
	ijj6aHtvwNSKIrehtsvNBqABFCeq/du9YOZSMLzu6OItlm9jD9bZzF4SA5rvGZ2o3vHBv3rwRnJ
	Sy7XVU3PWiiT/hrvwsvZVn27PSxUAlv84BIA5mMEmD/5vt+RxM3xqRoZoYvv5lnMFKfg/skCJA=
	=
X-Received: by 2002:aca:6c8b:: with SMTP id h133mr7690460oic.33.1547727076120;
        Thu, 17 Jan 2019 04:11:16 -0800 (PST)
X-Received: by 2002:aca:6c8b:: with SMTP id h133mr7690416oic.33.1547727074934;
        Thu, 17 Jan 2019 04:11:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547727074; cv=none;
        d=google.com; s=arc-20160816;
        b=fuT8q6GJcEGNS1zBwrpNVcf17hMHpg0SacxFCKj2X5Xio6JxEvd6vXSw7pSJ3AAb4W
         iLyMI79UD8z2MkUKUQEe0SACZGUlyE7gDWvwGSK62IyPboAkKpkr8tQpi6Ng1cpc45gy
         ne04N1rk4FE37LqLLFijWZ1U2hBBcMYxdmnlJ7f/Ir3qf2xAyqlNFuUioQDdHlKgldg8
         PNI2ks+Ese/gRuBqSEVqtTk4lmNvywz0YY1rz/IAp/wPrh1r3ie7yiheEbwnZ/xN52xe
         y9mXgdiJxokuT/p26SHJwYeCnHtqCj3dqhjq0zLHBmKZBjt4q6PeKNwTRFmaN7qDxbgu
         5qEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=AxIgu+ssdyh4k+fK0G2jre2kzjLfEgitJPwARRAUwho=;
        b=E2LMlxgNOTQH/0WKXp8iO1vHW3cUSN2KPuUQ/hZRYhsX7tulKlghM8VG/OHsuBJ3Z1
         mYsYe4kWqK2FDfBspDQBhUdVzqryWUTrBigtHmVE/Qa5AKyFjSZgI4fkuN1msLkqeRRT
         zTxwifb7qR1K+4Fu+qQj7on6f8JFlc1zU9p6unq//HXFsnK/mTFE6jFrIPGFWFZwblWL
         zCrWjGDRStyoYyzNQNbsvNWXBoMh0QI7OkSllMQTGUdeCQVfuC5NYPrITyrTgfrIWCxn
         pWdusmTJhS7fR94Jn7eOtQfIThGCS/MHKqjWi1W+HFe8X2ckodUgGOudBaU1AH3UdgRs
         sMHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z89sor654156otb.62.2019.01.17.04.11.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 04:11:14 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN42LWfRv9IR+uyfT8y7WNn0BxMdPheEVAtGpE0LNzCZmCMDXGt44ZumSNsxxPhHTkpfbSqWnTmE4rC2gLfD6HI=
X-Received: by 2002:a9d:5f06:: with SMTP id f6mr8865291oti.258.1547727074395;
 Thu, 17 Jan 2019 04:11:14 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-7-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-7-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 17 Jan 2019 13:11:02 +0100
Message-ID:
 <CAJZ5v0jg24sNVQiA1AvVwP-uCCq1Uo9rxkAERyb_zDL_W8AATA@mail.gmail.com>
Subject: Re: [PATCHv4 06/13] acpi/hmat: Register processor domain to its memory
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117121102.h6UKXW0juNJ_uXjJ1zrHW2FHheX0OiNZcqvj-2jtja0@z>

    On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
>
> If the HMAT Subsystem Address Range provides a valid processor proximity
> domain for a memory domain, or a processor domain with the highest
> performing access exists, register the memory target with that initiator
> so this relationship will be visible under the node's sysfs directory.
>
> Since HMAT requires valid address ranges have an equivalent SRAT entry,
> verify each memory target satisfies this requirement.

What exactly will happen after this patch?

There will be some new directories under
/sys/devices/system/node/nodeX/ if all goes well.  Anything else?

> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/acpi/hmat/hmat.c | 143 ++++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 136 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> index 833a783868d5..efb33c74d1a3 100644
> --- a/drivers/acpi/hmat/hmat.c
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -17,6 +17,43 @@
>  #include <linux/slab.h>
>  #include <linux/sysfs.h>
>
> +static LIST_HEAD(targets);
> +

A kerneldoc documenting the struct type here, please.

> +struct memory_target {
> +       struct list_head node;
> +       unsigned int memory_pxm;
> +       unsigned long p_nodes[BITS_TO_LONGS(MAX_NUMNODES)];
> +};
> +
> +static __init struct memory_target *find_mem_target(unsigned int m)

Why don't you call the arg mem_pxm like below?

> +{
> +       struct memory_target *t;
> +
> +       list_for_each_entry(t, &targets, node)
> +               if (t->memory_pxm == m)
> +                       return t;
> +       return NULL;
> +}
> +
> +static __init void alloc_memory_target(unsigned int mem_pxm)
> +{
> +       struct memory_target *t;
> +
> +       if (pxm_to_node(mem_pxm) == NUMA_NO_NODE)
> +               return;
> +
> +       t = find_mem_target(mem_pxm);
> +       if (t)
> +               return;
> +
> +       t = kzalloc(sizeof(*t), GFP_KERNEL);
> +       if (!t)
> +               return;
> +
> +       t->memory_pxm = mem_pxm;
> +       list_add_tail(&t->node, &targets);
> +}
> +
>  static __init const char *hmat_data_type(u8 type)
>  {
>         switch (type) {
> @@ -53,11 +90,30 @@ static __init const char *hmat_data_type_suffix(u8 type)
>         };
>  }
>
> +static __init void hmat_update_access(u8 type, u32 value, u32 *best)

I guess that you pass a pointer to avoid unnecessary updates, right?

But that causes you to dereference that pointer quite often.  It might
be better to pass the current value of 'best' and return an updated
one (which may be the same as the passed one, of course).

> +{
> +       switch (type) {
> +       case ACPI_HMAT_ACCESS_LATENCY:
> +       case ACPI_HMAT_READ_LATENCY:
> +       case ACPI_HMAT_WRITE_LATENCY:
> +               if (!*best || *best > value)
> +                       *best = value;
> +               break;
> +       case ACPI_HMAT_ACCESS_BANDWIDTH:
> +       case ACPI_HMAT_READ_BANDWIDTH:
> +       case ACPI_HMAT_WRITE_BANDWIDTH:
> +               if (!*best || *best < value)
> +                       *best = value;
> +               break;
> +       }
> +}
> +
>  static __init int hmat_parse_locality(union acpi_subtable_headers *header,
>                                       const unsigned long end)
>  {
> +       struct memory_target *t;

I would call this variable mem_target.  't' is too easy to overlook
IMO.  [Same below]

>         struct acpi_hmat_locality *loc = (void *)header;
> -       unsigned int init, targ, total_size, ipds, tpds;
> +       unsigned int init, targ, pass, p_node, total_size, ipds, tpds;
>         u32 *inits, *targs, value;
>         u16 *entries;
>         u8 type;
> @@ -87,12 +143,28 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
>         targs = &inits[ipds];
>         entries = (u16 *)(&targs[tpds]);
>         for (targ = 0; targ < tpds; targ++) {
> -               for (init = 0; init < ipds; init++) {
> -                       value = entries[init * tpds + targ];
> -                       value = (value * loc->entry_base_unit) / 10;
> -                       pr_info("  Initiator-Target[%d-%d]:%d%s\n",
> -                               inits[init], targs[targ], value,
> -                               hmat_data_type_suffix(type));
> +               u32 best = 0;
> +
> +               t = find_mem_target(targs[targ]);
> +               for (pass = 0; pass < 2; pass++) {
> +                       for (init = 0; init < ipds; init++) {
> +                               value = entries[init * tpds + targ];
> +                               value = (value * loc->entry_base_unit) / 10;
> +
> +                               if (!pass) {
> +                                       hmat_update_access(type, value, &best);
> +                                       pr_info("  Initiator-Target[%d-%d]:%d%s\n",
> +                                               inits[init], targs[targ], value,
> +                                               hmat_data_type_suffix(type));
> +                                       continue;
> +                               }
> +
> +                               if (!t)
> +                                       continue;
> +                               p_node = pxm_to_node(inits[init]);
> +                               if (p_node != NUMA_NO_NODE && value == best)
> +                                       set_bit(p_node, t->p_nodes);
> +                       }
>                 }
>         }
>         return 0;
> @@ -122,6 +194,7 @@ static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
>                                            const unsigned long end)
>  {
>         struct acpi_hmat_address_range *spa = (void *)header;
> +       struct memory_target *t = NULL;
>
>         if (spa->header.length != sizeof(*spa)) {
>                 pr_err("HMAT: Unexpected address range header length: %d\n",
> @@ -131,6 +204,23 @@ static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
>         pr_info("HMAT: Memory (%#llx length %#llx) Flags:%04x Processor Domain:%d Memory Domain:%d\n",
>                 spa->physical_address_base, spa->physical_address_length,
>                 spa->flags, spa->processor_PD, spa->memory_PD);
> +
> +       if (spa->flags & ACPI_HMAT_MEMORY_PD_VALID) {
> +               t = find_mem_target(spa->memory_PD);
> +               if (!t) {
> +                       pr_warn("HMAT: Memory Domain missing from SRAT\n");

Again, I'm wondering about the log level here.  I "warning" really adequate?

> +                       return -EINVAL;
> +               }
> +       }
> +       if (t && spa->flags & ACPI_HMAT_PROCESSOR_PD_VALID) {
> +               int p_node = pxm_to_node(spa->processor_PD);
> +
> +               if (p_node == NUMA_NO_NODE) {
> +                       pr_warn("HMAT: Invalid Processor Domain\n");

Same here.

> +                       return -EINVAL;
> +               }
> +               set_bit(p_node, t->p_nodes);
> +       }
>         return 0;
>  }
>
> @@ -154,6 +244,33 @@ static int __init hmat_parse_subtable(union acpi_subtable_headers *header,
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
> +static __init void hmat_register_targets(void)
> +{
> +       struct memory_target *t, *next;
> +       unsigned m, p;
> +
> +       list_for_each_entry_safe(t, next, &targets, node) {
> +               list_del(&t->node);
> +               m = pxm_to_node(t->memory_pxm);
> +               for_each_set_bit(p, t->p_nodes, MAX_NUMNODES)
> +                       register_memory_node_under_compute_node(m, p, 0);
> +               kfree(t);
> +       }
> +}
> +
>  static __init int hmat_init(void)
>  {
>         struct acpi_table_header *tbl;
> @@ -163,6 +280,17 @@ static __init int hmat_init(void)
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

Can you do

ret = acpi_table_parse_entries(ACPI_SIG_SRAT, sizeof(struct acpi_table_srat),
                               ACPI_SRAT_TYPE_MEMORY_AFFINITY,
srat_parse_mem_affinity, 0);
if (ret < 0)
        goto out_put;

here instead?  The current one is barely readable.

Also please add a comment to explain what it means if this returns an error.

> +               goto out_put;
> +       acpi_put_table(tbl);
> +
>         status = acpi_get_table(ACPI_SIG_HMAT, 0, &tbl);
>         if (ACPI_FAILURE(status))
>                 return 0;
> @@ -173,6 +301,7 @@ static __init int hmat_init(void)
>                                              hmat_parse_subtable, 0) < 0)
>                         goto out_put;
>         }
> +       hmat_register_targets();
>  out_put:
>         acpi_put_table(tbl);
>         return 0;
> --

