Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCBB3C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:06:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A290E2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:06:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A290E2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46FC88E0038; Wed, 20 Feb 2019 17:06:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41EA88E0002; Wed, 20 Feb 2019 17:06:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 334B98E0038; Wed, 20 Feb 2019 17:06:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 09D7A8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:06:03 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id 42so12721145otv.5
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:06:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=80wq8RIr4brdNYYPZ3tyyCou77N/Hx2TQOUNzTc41no=;
        b=fAcSkoDJXAXDYnreTDzoE5k80B1dZKVEn2fN4LeWRCWLC/OfykCzYlbhnfMZFEpl9t
         fsyrKHM7UCLA3d3PrKI3ScgXERFPv7mTTeTSc5ASTURguiOlA27S5+eULbxnAIMeY1z7
         S4sHMkV2QlHvQl/awztSHMGrWAYBzKGmlcKaiA+G7Cq2gk+XSp5R/zt6h0b9EjlysX8d
         2fN7eT1KgsAdmvz7xxkeEj+3IigdNEiUGKHfzwSDxF6iimf+7s4EtS3Of19bChGQCA1k
         77lSTA+DVS1AfTR8feZHO+uPGj7auQW+Sk+rYIrmn5Ba/8jPxf4U/j11Ll4cgsPP/HwN
         WvAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubW3BNKCz7PJg2ju86rkDUJUgE8grG/vLHj+roYdvQXbCknXRui
	usfXWJeF9DYGkNL2cgaenRu1F3U345NVJWdrEwkJMrL2GS99mngRwCttgkWdJpAMwMUKql9etB8
	riaQBgJFq5ss9uYCETcTN2si5kqmjEgZRsVUXyaoB69JutzCAXP91NmTO0BnTRE2vHPoQcqF/bF
	WqP/Isc9yyc8P1lvB7Pt3xFn1dbx/HXvc0zc3JSo8/mQr32E8GABUcyCOaipIwy/3cFvLV+M79d
	2iBdQh9iIVANg64U0PNCcRhhnPGTsGhWKNTmhr5sWopdn7Z2G5jzF8trlgTN9knECtZzTptyDB2
	oYCACfJTg7kz9Io0EMPWKOfSu3F4CJ2oX3CV41lBbqI6ugTOVhRmED4Oey71PuBrgaLfLFb8lQ=
	=
X-Received: by 2002:a9d:798c:: with SMTP id h12mr14114186otm.86.1550700362799;
        Wed, 20 Feb 2019 14:06:02 -0800 (PST)
X-Received: by 2002:a9d:798c:: with SMTP id h12mr14114156otm.86.1550700362209;
        Wed, 20 Feb 2019 14:06:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550700362; cv=none;
        d=google.com; s=arc-20160816;
        b=tA8qyJoLXxEF6o6J1g3k16avtKJ+r+on6jcAsPE3na1TYWlzgabI1ZVyoAioNjmaQt
         NT5G15WFAch+EXbOFfXFz0bpfetqNQAAgOlL3AbmNr/rYYfNqpOkfPOJhAA/l/Bzzs2i
         ZorZlMbDKldk5eEQGwJhSS/dZHInO90wbIjLD2kYqfdmdD4WIw8h4qW3eWJ0WqyGUv8k
         fmaPCLPmAIYNhawebj0lhGFV0fswCnZz4Wij3ufKu0gnKXwTtSiszPchcPDLSIO0JVp5
         RPFN/0eMs7+C8r+Hvo/FaCxi1GWFyXZyFKlB6edaBLiIBsPVC7ewyo7dO/rMmq+mR5RR
         RJNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=80wq8RIr4brdNYYPZ3tyyCou77N/Hx2TQOUNzTc41no=;
        b=Hx92MxAGnJ9k9K5vjlKueSLjOsVeAAjsbzxTQhPHP+I1Zafhj/vqlGEEv4cnEq/m68
         Zp6+4R/nCa9JH01/ICZebZubuYnm+pHTBnVoFT7dlekIVWJW2ut+MbwofRG/n9gXgKfN
         DGZiuFX7lvD6Dg6MKpKk24hUEbBi01VaSUZO3JoeoOTde704jbN3hT+xYnnCV/Abx82r
         Tb9y7ZpdNVhOncmjUyk6+wZicUlVIxWjCgeRugE9ek9ECuh0tsuEV8zdSMFSjUDv+Ywz
         y6qu6nhm1gObozZ6LEj4WViYaV85K2QJeu6be3yMuezYPvNS55bhjpPV/rAgNvFb8I2S
         8/gw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m2sor12168546otl.152.2019.02.20.14.06.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 14:06:02 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IZgSJLWQHESjaz/a33C8nm9iD+15dSEraM1gzX9abpO+ZxRAQ3C6pYxcVetewbDWe7dMB4V9WFZdYSa6ZcLK1Y=
X-Received: by 2002:a9d:5a0b:: with SMTP id v11mr21134786oth.124.1550700361880;
 Wed, 20 Feb 2019 14:06:01 -0800 (PST)
MIME-Version: 1.0
References: <20190214171017.9362-1-keith.busch@intel.com> <20190214171017.9362-10-keith.busch@intel.com>
In-Reply-To: <20190214171017.9362-10-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Wed, 20 Feb 2019 23:05:51 +0100
Message-ID: <CAJZ5v0i6ZD0azWmLWkuzt4Sms+L8+wvKYao8-JCJp0zOgjdx5A@mail.gmail.com>
Subject: Re: [PATCHv6 09/10] acpi/hmat: Register memory side cache attributes
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, 
	Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 6:10 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Register memory side cache attributes with the memory's node if HMAT
> provides the side cache iniformation table.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

> ---
>  drivers/acpi/hmat/hmat.c | 32 ++++++++++++++++++++++++++++++++
>  1 file changed, 32 insertions(+)
>
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> index 6833c4897ff4..e2a15f53fe45 100644
> --- a/drivers/acpi/hmat/hmat.c
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -314,6 +314,7 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
>                                    const unsigned long end)
>  {
>         struct acpi_hmat_cache *cache = (void *)header;
> +       struct node_cache_attrs cache_attrs;
>         u32 attrs;
>
>         if (cache->header.length < sizeof(*cache)) {
> @@ -327,6 +328,37 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
>                 cache->memory_PD, cache->cache_size, attrs,
>                 cache->number_of_SMBIOShandles);
>
> +       cache_attrs.size = cache->cache_size;
> +       cache_attrs.level = (attrs & ACPI_HMAT_CACHE_LEVEL) >> 4;
> +       cache_attrs.line_size = (attrs & ACPI_HMAT_CACHE_LINE_SIZE) >> 16;
> +
> +       switch ((attrs & ACPI_HMAT_CACHE_ASSOCIATIVITY) >> 8) {
> +       case ACPI_HMAT_CA_DIRECT_MAPPED:
> +               cache_attrs.associativity = NODE_CACHE_DIRECT_MAP;
> +               break;
> +       case ACPI_HMAT_CA_COMPLEX_CACHE_INDEXING:
> +               cache_attrs.associativity = NODE_CACHE_INDEXED;
> +               break;
> +       case ACPI_HMAT_CA_NONE:
> +       default:
> +               cache_attrs.associativity = NODE_CACHE_OTHER;
> +               break;
> +       }
> +
> +       switch ((attrs & ACPI_HMAT_WRITE_POLICY) >> 12) {
> +       case ACPI_HMAT_CP_WB:
> +               cache_attrs.write_policy = NODE_CACHE_WRITE_BACK;
> +               break;
> +       case ACPI_HMAT_CP_WT:
> +               cache_attrs.write_policy = NODE_CACHE_WRITE_THROUGH;
> +               break;
> +       case ACPI_HMAT_CP_NONE:
> +       default:
> +               cache_attrs.write_policy = NODE_CACHE_WRITE_OTHER;
> +               break;
> +       }
> +
> +       node_add_cache(pxm_to_node(cache->memory_PD), &cache_attrs);
>         return 0;
>  }
>
> --
> 2.14.4
>

