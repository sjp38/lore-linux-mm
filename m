Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B81A1C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 18:25:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B388206B7
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 18:25:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B388206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C90468E002B; Wed, 20 Feb 2019 13:25:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3EA48E0002; Wed, 20 Feb 2019 13:25:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B557D8E002B; Wed, 20 Feb 2019 13:25:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71ABB8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 13:25:36 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id b10so7784484pla.14
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 10:25:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uzK8XFXGL8nsdrxMRuHj40KvZQc9OlKuRRfDqrJUDio=;
        b=U0enhgy7qDXe9lqNBwn8lAXldciMxJ0c8QyEMO7YvTHAXt8Q6NfkPrUQMtsgjTS1dU
         dvZ/B/3JLp3OFSlPclEKoanj/PmtxjA1iZd6gOYN0CNUOcqLJIC1i92bXopLS/G5QVok
         +kuDy/Lbs825OsOh+zjSTF8aZohyMQAsho2IJC02FKoDjz0rKrza4z6O+SHDuNkupr/V
         kiejcoL//tN9qe4R/I45MGSwHlX5KiyvVfNk7NA7RsJTnyzOaGy4ZfkDmNn0gu27M+ln
         rwACOFzVE6HNn1WrQdqg/lsSuyh8DoMZ/kicZtJeq0jkH7SyD0UbPlrPJa/MFj8ewf0e
         lRRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubzm8qc6QRygjfkF9pDNeArDvxpkIlRR49jWcjgmQDcJTniK6Iq
	H2V9GESkbdoIzz8K625afpIp84i9jjgFKDUQoe35XdQul7J/cVlPtjFulvQrUvUspoUmt4z0wZq
	j6L4iD8ujbTr2jtctKvRkEePRcVc5pNceb19UOzw/nzQSPSe0CJOyVxMFUAuAovi5FQ==
X-Received: by 2002:a62:168e:: with SMTP id 136mr36339954pfw.116.1550687136046;
        Wed, 20 Feb 2019 10:25:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY6KwfEuVt9S1TU/LlLM07rMydjqUvc0btSHSXSNG5+WuI0bVi46u/gxiE3q+XoWncJPf6g
X-Received: by 2002:a62:168e:: with SMTP id 136mr36339895pfw.116.1550687135027;
        Wed, 20 Feb 2019 10:25:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550687135; cv=none;
        d=google.com; s=arc-20160816;
        b=oeMqVVA3X2p+iXkynk7sMt4B9VQAHIVdesqxgs0cfgSbrx+H1ak42k8KxG25uq21SR
         XbNb0/uO33C2vaHghnxGK8hwAN5N3A9KlVAIGc4wIQwOTbZteVU/G2KPSXbCCrGZMcYb
         +dJUD9aNSotM9ALvwF/HTKLQ3M/5H+mgLM/EYjDZvmvSEJvYo3ibEMDu43xFKuqlLcwZ
         mDlXf/f0I2aB+2COnW1m+t/Unbgy3sGnlOgExyalaPXszkpmUMKoDwxyC3rLaHsMp3nX
         6MizPXu+TtTaGYKoQ1Xh4l6uEIRt29BG0b9BVqCxZmawYQ6vjGnMkYD3c3EBCeoI6GnD
         spwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uzK8XFXGL8nsdrxMRuHj40KvZQc9OlKuRRfDqrJUDio=;
        b=KxvhVzg8SczsnCsTz7xuXoPRl8YgXSldAKLntPg3gDBWj9u9NYqSlWVIkmaFOdoQOf
         oijeKb/Il4uJe7vj/S3gkMZZqazDHceaV69bdTd3yYy5RAQ4oF08HlLH4S4zM6JFs7PP
         xYH+KeRVNQUC7z8DJxUz5lra4M4jS3DOXRM595VcU20LlLkmVpw5Rj3DzvmlL3LkKfP2
         Alf2jL/9FyAUZd/celCXTzmgGSh4On/mOaoM0qqJlUwYh8Ay9RPHNGDSlw2T84Y5ASZf
         hYzN22N/egz01JdNURknLDykpd4jkYccFmBZxsCQ72ZhaD3gh9vTxjS+v84OhvMrD7uh
         k0Ag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 1si17422325pln.122.2019.02.20.10.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 10:25:35 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Feb 2019 10:25:34 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,392,1544515200"; 
   d="scan'208";a="119478926"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga008.jf.intel.com with ESMTP; 20 Feb 2019 10:25:33 -0800
Date: Wed, 20 Feb 2019 11:25:27 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org,
	linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv6 00/10] Heterogenous memory node attributes
Message-ID: <20190220182527.GD4451@localhost.localdomain>
References: <20190214171017.9362-1-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214171017.9362-1-keith.busch@intel.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 10:10:07AM -0700, Keith Busch wrote:
> Platforms may provide multiple types of cpu attached system memory. The
> memory ranges for each type may have different characteristics that
> applications may wish to know about when considering what node they want
> their memory allocated from. 
> 
> It had previously been difficult to describe these setups as memory
> rangers were generally lumped into the NUMA node of the CPUs. New
> platform attributes have been created and in use today that describe
> the more complex memory hierarchies that can be created.
> 
> This series' objective is to provide the attributes from such systems
> that are useful for applications to know about, and readily usable with
> existing tools and libraries. Those applications may query performance
> attributes relative to a particular CPU they're running on in order to
> make more informed choices for where they want to allocate hot and cold
> data. This works with mbind() or the numactl library.

Hi all,

So this seems very calm at this point. Unless there are any late concerns
or suggestions, could we open consideration for queueing in a staging
tree for a future merge window?

Thanks,
Keith

 
> Keith Busch (10):
>   acpi: Create subtable parsing infrastructure
>   acpi: Add HMAT to generic parsing tables
>   acpi/hmat: Parse and report heterogeneous memory
>   node: Link memory nodes to their compute nodes
>   node: Add heterogenous memory access attributes
>   node: Add memory-side caching attributes
>   acpi/hmat: Register processor domain to its memory
>   acpi/hmat: Register performance attributes
>   acpi/hmat: Register memory side cache attributes
>   doc/mm: New documentation for memory performance
> 
>  Documentation/ABI/stable/sysfs-devices-node   |  89 +++-
>  Documentation/admin-guide/mm/numaperf.rst     | 164 +++++++
>  arch/arm64/kernel/acpi_numa.c                 |   2 +-
>  arch/arm64/kernel/smp.c                       |   4 +-
>  arch/ia64/kernel/acpi.c                       |  12 +-
>  arch/x86/kernel/acpi/boot.c                   |  36 +-
>  drivers/acpi/Kconfig                          |   1 +
>  drivers/acpi/Makefile                         |   1 +
>  drivers/acpi/hmat/Kconfig                     |   9 +
>  drivers/acpi/hmat/Makefile                    |   1 +
>  drivers/acpi/hmat/hmat.c                      | 677 ++++++++++++++++++++++++++
>  drivers/acpi/numa.c                           |  16 +-
>  drivers/acpi/scan.c                           |   4 +-
>  drivers/acpi/tables.c                         |  76 ++-
>  drivers/base/Kconfig                          |   8 +
>  drivers/base/node.c                           | 351 ++++++++++++-
>  drivers/irqchip/irq-gic-v2m.c                 |   2 +-
>  drivers/irqchip/irq-gic-v3-its-pci-msi.c      |   2 +-
>  drivers/irqchip/irq-gic-v3-its-platform-msi.c |   2 +-
>  drivers/irqchip/irq-gic-v3-its.c              |   6 +-
>  drivers/irqchip/irq-gic-v3.c                  |  10 +-
>  drivers/irqchip/irq-gic.c                     |   4 +-
>  drivers/mailbox/pcc.c                         |   2 +-
>  include/linux/acpi.h                          |   6 +-
>  include/linux/node.h                          |  60 ++-
>  25 files changed, 1480 insertions(+), 65 deletions(-)
>  create mode 100644 Documentation/admin-guide/mm/numaperf.rst
>  create mode 100644 drivers/acpi/hmat/Kconfig
>  create mode 100644 drivers/acpi/hmat/Makefile
>  create mode 100644 drivers/acpi/hmat/hmat.c

