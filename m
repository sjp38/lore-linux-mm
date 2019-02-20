Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12B40C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:02:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB9FB2086C
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:02:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB9FB2086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 696408E0035; Wed, 20 Feb 2019 17:02:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61C478E0002; Wed, 20 Feb 2019 17:02:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BE2E8E0035; Wed, 20 Feb 2019 17:02:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8DC8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:02:14 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id q26so8487049otf.19
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:02:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=vvbga5/rKMhGa+NSWBfXnVaRcn9H55kD51cNX0PyggM=;
        b=ba6Pz4ax3WS8fqmsvBQtPyUaq3Gs7epMoHdEyZxwjR+ljv5L0mmsQ4ZKWoftI/vv1p
         uPVk+RuAqjWDYhfNJzIqSW+N6BTnyKKiXXQ0bAbnaZQ3LBoJ/zL3CyGvg9gqTRAfgeF6
         Mzxln29denMCJ20hG2OLm8DUgcFu5AtqCvRECUz3TDnQG2J7GISG8uGFRmQj9C+qa5zw
         uiYJAPc4YrBCVcg9s2TYRq6HnW9aZZWWaQaC6lPlSFtQJhNFvYJMKtYe3GHb5ejqw71H
         tKrYJekIm59pQuVfanAYM5SmavyR0ecFvAyTGGB4uhvvzzcrLL1AZxugUkDNL2lgWlUp
         zxAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZs9evVMlElvu4j5mw7vkhWH1RQWQBjUEc/VKw44jPLcv+ygu28
	RKIZ97Z3dqiEHp++ul442+NufZxV+hcjljP2GmiTpwyGLKZ3ihXLSZ4AgfLGo1JEYrspVmst6Ct
	6CT9onKGNB4W8uQ0iMsxgoGsYlCIeu2APWNXzY3sTdUnyc8qGL26XJpr/lg9Ba0zbdtDB1CXX26
	44DLPT6S6m4YIMVULNFofHfMiIR4ZOFsosvfGYMA3T8Z9HhZUr0LdUbbiMm3fV03x2xPGox7GuM
	sogXJZ6xzSzSZllyjxwljoHMkJ4ttW2fkjB72L2Y8Wl5ShNocoVkGbO9jDsk7ei72zA4VRpUDcw
	OabUWzDKAb+kH+chXFKZZIm3YWAR7FmF8yt26t5qhV9jXHcE5m+maZu/xmYyjAEcL2z4ACtbKw=
	=
X-Received: by 2002:a9d:6c18:: with SMTP id f24mr22943338otq.2.1550700133802;
        Wed, 20 Feb 2019 14:02:13 -0800 (PST)
X-Received: by 2002:a9d:6c18:: with SMTP id f24mr22943302otq.2.1550700133096;
        Wed, 20 Feb 2019 14:02:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550700133; cv=none;
        d=google.com; s=arc-20160816;
        b=ewUO9DrXNRDJRW7J3KGqXjQyYgGTPo8Vv2DiwcZRKE3CuyAeHDosgy+flqXXlnMDlI
         8SWIyjd8afSrGYVWeo+OlLHsikjQERhD3qzeZ+iqbpaQN1AyePegmhFuBoBCX+ROXVFC
         YcUmD3QhL7I+J18GKDNd7DXOH1PaOr78owM/fM3xaYatbX4fdx4AdVsxg0FLr5fCWu8A
         qT5rjH16nF6Bh7bJtxycaW36Qvw94Rrbz2rsn+1jrWHGxPDa4hQw2Xt7m39Eal62g1Gw
         TLW6Zbzr8T08BxF+R87QzLwS+aEF5FFF90EC/PvQP57igGQ7J13Ft8L7yDBUzj1ybYaX
         1niQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=vvbga5/rKMhGa+NSWBfXnVaRcn9H55kD51cNX0PyggM=;
        b=iQRIqREinZ+QjO94raIWQeawn7mNVnWIEEnQJ2uW4Pbb4ppB3FRnW4rOL8CE+1wQyg
         cYcdit8jJXZl77jpBjhARpga2airrpVh8CE1dRI2wmSFm8hWqSD+gihIsM8j7Km3dBgF
         KvkFecdC7sr4pWkiC5bYdHNEBrwvGHSnkhS7QqsXWNgoYOJTw7anqU8TB6j06lUNp+QL
         yA57N0R9rMliS5v/RFL+7J5F2/hV0N6kNUt/n1dIM7pj0uFKSnz2orDSUNjpipcwarvJ
         WO5RfdZexg+lkT7/UPn97AyfUivsGC+9K/EZtebnzadn/LfauwOzNUiuGiT6ABQ52gMd
         uQbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p9sor11051157oig.65.2019.02.20.14.02.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 14:02:13 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IbAzu8gI/MWJeSOSNKf1hGrR2Pg+qTBx37R9oT5FXo9crNiJVD4x++lZ0b9JfEsAG8sY05Yvn9BSSCb8K1GtgE=
X-Received: by 2002:aca:6046:: with SMTP id u67mr2338709oib.84.1550700132699;
 Wed, 20 Feb 2019 14:02:12 -0800 (PST)
MIME-Version: 1.0
References: <20190214171017.9362-1-keith.busch@intel.com> <20190214171017.9362-8-keith.busch@intel.com>
In-Reply-To: <20190214171017.9362-8-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Wed, 20 Feb 2019 23:02:01 +0100
Message-ID: <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com>
Subject: Re: [PATCHv6 07/10] acpi/hmat: Register processor domain to its memory
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
> If the HMAT Subsystem Address Range provides a valid processor proximity
> domain for a memory domain, or a processor domain matches the performance
> access of the valid processor proximity domain, register the memory
> target with that initiator so this relationship will be visible under
> the node's sysfs directory.
>
> By registering only the best performing relationships, this provides the
> most useful information applications may want to know when considering
> which CPU they should run on for a given memory node, or which memory
> node they should allocate memory from for a given CPU.
>
> Since HMAT requires valid address ranges have an equivalent SRAT entry,
> verify each memory target satisfies this requirement.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/acpi/hmat/Kconfig |   1 +
>  drivers/acpi/hmat/hmat.c  | 396 +++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 396 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> index c9637e2e7514..08e972ead159 100644
> --- a/drivers/acpi/hmat/Kconfig
> +++ b/drivers/acpi/hmat/Kconfig
> @@ -2,6 +2,7 @@
>  config ACPI_HMAT
>         bool "ACPI Heterogeneous Memory Attribute Table Support"
>         depends on ACPI_NUMA
> +       select HMEM_REPORTING

If you want to do this here, I'm not sure that defining HMEM_REPORTING
as a user-selectable option is a good idea.  In particular, I don't
really think that setting ACPI_HMAT without it makes a lot of sense.
Apart from this, the patch looks reasonable to me.

