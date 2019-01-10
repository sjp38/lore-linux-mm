Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C79D4C43387
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 15:36:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82DBA214C6
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 15:36:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82DBA214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 336198E0002; Thu, 10 Jan 2019 10:36:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BF478E0001; Thu, 10 Jan 2019 10:36:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B06C8E0002; Thu, 10 Jan 2019 10:36:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id E29798E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 10:36:13 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id s140so5325856oih.4
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 07:36:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=UiU+kA6pOL4I/NJ8tGII0wrxzss2hVQQaB07bU+wRUs=;
        b=UmawEUQFd9aSYpLPHUcgFegNcAjo0VmKyQx5lleNbih6zWiL2ZSPlkFCWE5gD1HRrd
         vF+C/utgHoTP6L0t3YhIGP+qEyazRT0mYodMNEQQrzxNFuaClxHD7w5vrL+MnMllcxcd
         3BIpMqk1ZvLwytYT7puo8BTykK0/kcfWYUYt5iUK0luHUlppFfYauP41pjV1wl53JJ8r
         KUECbs0uAV4891ZQZt945XgCOSrqq+ylJy40F5c1goiCI6WX01lwpxCbQuvS6xPl/Zzo
         iMLy7ASXnpxToiJ308qluajrsvdOCwTiedlzvtGpSeb5k7FlqSrVfvhcxyQ3DriHZGE0
         Acqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukemhNGyuwLi454HkbrtWcAKGKOGZKHATOUeYWXaFxp65iqn58rj
	jzt9Yhjm1PbNi2nABwQJV8R/KJE6cVZhwd2CTHmsRFqixo/Xn+nmSZn0QStvEv8DgeHldrQH4KX
	Nf5gPqQ+Ynb2d2BSzN+i8j7W2bMHUA/OULV1jrIrGdrtU654WahY40fK5RJgD6RM32lOFlz8MNf
	pgiGElkvHIZKKKXloghxTz01GDAo8ziGOfd2750I6RSRcK6b21A1R9aWb7e5UGM42kYDEubpYfO
	S6pmNyLx3z3bnwWkjnIcq2a0jVJ0qp2AqnDgur0lCgZUw9/MlInBuqhFJbsrdchdtUP+GiFxmXE
	cMB7mZo+7ttnmBFWba8yT3IF9xAc6vehYy8pbwPWrhqn5jgGqAnN6qlcCV8CMpbYLJz6yAbKRg=
	=
X-Received: by 2002:a05:6808:282:: with SMTP id z2mr7158414oic.128.1547134573454;
        Thu, 10 Jan 2019 07:36:13 -0800 (PST)
X-Received: by 2002:a05:6808:282:: with SMTP id z2mr7158386oic.128.1547134572826;
        Thu, 10 Jan 2019 07:36:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547134572; cv=none;
        d=google.com; s=arc-20160816;
        b=V4gI+wjjQ9yck0PdDXzXANfr4Gvzbs29bnRdZ32/YoNg4yQsojWtyEXHI+fkM6z7Zo
         ZLdffH73qecf5H4KFraxS4viW97paArjbqeuKe7vdASLH1F62ficVx4qV6cDGbJKjP72
         m9AU8/op6GQxP6PJ9WE3WLCQqrHiIUWlmrwzGHivYH4yKf4VdKAxvehig0KRrgV9qmau
         6Me6w90b6E8tsRcALimF5F08qPOiCGEbMKyYt1H02WC4eFwvvOWiZDdrBqw2RUrjl3Zw
         C7O+B5c9FfG8kMT+exy2pjctpsZvLiyDJMT2T/t9GIID5MpKiVAE+4cRpgop9wPwvxxn
         UsSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=UiU+kA6pOL4I/NJ8tGII0wrxzss2hVQQaB07bU+wRUs=;
        b=g6CGoj6F+GkGKIXelFzec1SxSIwFpNa76PhG9psIGS8Qc0UtBBDuNnXC7oKQpFn1sZ
         pQFLOMpf2ZvLr4NHib+uehkknjYTLWepJnz4nRvL2Xz+N/0Zvsl4z//iMPSxpxHpL2oU
         gmRJb8ZDqTb3zGgc+1gwCNUGMtKBAAKbwGYe2eO8KrTXh5oSABMQd9TgAxhGyPydLWeP
         3WAdlzM9L75W+5aqQncUcZy7bQnLJXFq/YjqG/Opi2ltRpZyTrwU55WCEUVjguduH2pk
         vb6RIt8EPNBd1OaiUsgFWwkG5KyvXFiXE39UoOfx6Opvgbri69o7fe6y3FPzSwsUjJJA
         xhvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n66sor29182165oig.110.2019.01.10.07.36.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 07:36:12 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN66yvy4aWxFnPpM3qIPLZztg5sJXcCuuPHEy4wLOCflX88+A8EMxVn/8pB4NPvGmkXodmS3t+NShQxSG2ysr5Y=
X-Received: by 2002:aca:368a:: with SMTP id d132mr7178539oia.193.1547134572310;
 Thu, 10 Jan 2019 07:36:12 -0800 (PST)
MIME-Version: 1.0
References: <20190109174341.19818-1-keith.busch@intel.com> <20190109174341.19818-3-keith.busch@intel.com>
In-Reply-To: <20190109174341.19818-3-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 10 Jan 2019 16:36:01 +0100
Message-ID:
 <CAJZ5v0j40_+-Jjbu4miBKUt8Gnw817G_r1rgCxWHoa9oH-a-Tg@mail.gmail.com>
Subject: Re: [PATCHv3 02/13] acpi: Add HMAT to generic parsing tables
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
Message-ID: <20190110153601.3xP8EcQ1rkHfLa4LnfWAh2S4RK0lXA9NrCP719YpccE@z>

On Wed, Jan 9, 2019 at 6:47 PM Keith Busch <keith.busch@intel.com> wrote:
>
> The Heterogeneous Memory Attribute Table (HMAT) header has different
> field lengths than the existing parsing uses. Add the HMAT type to the
> parsing rules so it may be generically parsed.
>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Keith Busch <keith.busch@intel.com>

Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

> ---
>  drivers/acpi/tables.c | 9 +++++++++
>  include/linux/acpi.h  | 1 +
>  2 files changed, 10 insertions(+)
>
> diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
> index 967e1168becf..d9911cd55edc 100644
> --- a/drivers/acpi/tables.c
> +++ b/drivers/acpi/tables.c
> @@ -51,6 +51,7 @@ static int acpi_apic_instance __initdata;
>
>  enum acpi_subtable_type {
>         ACPI_SUBTABLE_COMMON,
> +       ACPI_SUBTABLE_HMAT,
>  };
>
>  struct acpi_subtable_entry {
> @@ -232,6 +233,8 @@ acpi_get_entry_type(struct acpi_subtable_entry *entry)
>         switch (entry->type) {
>         case ACPI_SUBTABLE_COMMON:
>                 return entry->hdr->common.type;
> +       case ACPI_SUBTABLE_HMAT:
> +               return entry->hdr->hmat.type;
>         }
>         return 0;
>  }
> @@ -242,6 +245,8 @@ acpi_get_entry_length(struct acpi_subtable_entry *entry)
>         switch (entry->type) {
>         case ACPI_SUBTABLE_COMMON:
>                 return entry->hdr->common.length;
> +       case ACPI_SUBTABLE_HMAT:
> +               return entry->hdr->hmat.length;
>         }
>         return 0;
>  }
> @@ -252,6 +257,8 @@ acpi_get_subtable_header_length(struct acpi_subtable_entry *entry)
>         switch (entry->type) {
>         case ACPI_SUBTABLE_COMMON:
>                 return sizeof(entry->hdr->common);
> +       case ACPI_SUBTABLE_HMAT:
> +               return sizeof(entry->hdr->hmat);
>         }
>         return 0;
>  }
> @@ -259,6 +266,8 @@ acpi_get_subtable_header_length(struct acpi_subtable_entry *entry)
>  static enum acpi_subtable_type __init
>  acpi_get_subtable_type(char *id)
>  {
> +       if (strncmp(id, ACPI_SIG_HMAT, 4) == 0)
> +               return ACPI_SUBTABLE_HMAT;
>         return ACPI_SUBTABLE_COMMON;
>  }
>
> diff --git a/include/linux/acpi.h b/include/linux/acpi.h
> index 7c3c4ebaded6..53f93dff171c 100644
> --- a/include/linux/acpi.h
> +++ b/include/linux/acpi.h
> @@ -143,6 +143,7 @@ enum acpi_address_range_id {
>  /* Table Handlers */
>  union acpi_subtable_headers {
>         struct acpi_subtable_header common;
> +       struct acpi_hmat_structure hmat;
>  };
>
>  typedef int (*acpi_tbl_table_handler)(struct acpi_table_header *table);
> --
> 2.14.4
>

