Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5DCAC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:21:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73F082086C
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:21:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73F082086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 240388E003F; Wed, 20 Feb 2019 17:21:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EF1F8E0002; Wed, 20 Feb 2019 17:21:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DE698E003F; Wed, 20 Feb 2019 17:21:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3C018E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:21:57 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id 31so4952076ota.8
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:21:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=PfRNwRVl7g3bqidrv95AzMgr3KnyTTsf1iUE/PpifHg=;
        b=Gcwy/txQv/jkv7GhRXMIaz4xyYtRTsG6RZdZS3I51f3CaHkwhCpJZTgSXwu5s6qVqY
         /p8oInbzCyv8kpr+5E1uWOm8XrOuYwgJaYD2mMaXGesJ6/7ZyiKot5jaJRe/QbPJDjKk
         SX9sxh9/fpyQiUx7Va1ButgdMXPuyy143BTxM0tr8bchm/M84n2gP/FLuYRl9LxZYNoa
         tKtwDGuu/YbCHOPG1Tv0jRl86RVEzuUjBfLw3rG55Rnz42ZVeHNRQoBEP5qd4nqXN/gS
         odLP8zJvijBD77gOx5mOYCWuifMq+hcxd4oJvjI0fyPW0l046pojkhA6mO+f8iy5EY8s
         QzYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAub2dHXQcoLtKoRmP9RkjaDCum0H0iAB9ERMcH0UDv0mi9PMb7hd
	ud7TCr6wlB7dFFKDCG6fzg57eaA+exR3sYns9013taJShTMJUdEHBuhYzj8yBRvMsrZ4zNlJjSN
	GBgZ8ZlBQ4e4ZiX+VRYL/eCc9oCvFrxegBSGMtMLS3vd/BCC6fnNUKNWD1cwSZpTUcGk7FscscU
	VnLm2vKcp5nx8xQx7p1+Shm+niSxgr/8a9bfpOq1/8UVNptbwCZGxN/uif0/C359bALwj+eK9To
	eesiv6kdGrYV1AZwMdir99FN6TzHbgC0/PUMINrTSeUZEQgGdgloyH1PRq7287ehd47Dfzde0VD
	dQKbKJVmNVaQ00ds9HqaEom9uZjCgmskBrbqglBaF61e/lVqgq/XG5HIGzug8pPQKsN9j0rAEg=
	=
X-Received: by 2002:aca:cd93:: with SMTP id d141mr7428277oig.163.1550701317651;
        Wed, 20 Feb 2019 14:21:57 -0800 (PST)
X-Received: by 2002:aca:cd93:: with SMTP id d141mr7428257oig.163.1550701317098;
        Wed, 20 Feb 2019 14:21:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550701317; cv=none;
        d=google.com; s=arc-20160816;
        b=YWjMWhnhOWfSqx+23kYUD4LpyEjLVhyPvM7Cs+1EO3STpNLJH2vzRfDuqkA4TTIytI
         h4R88DCOHyMPMFjP5HzMdg6IgudRX7WnxWyumrXNVdgFQ9av6VRRrwNkLC7VT0iMq3al
         fqzDYrrlfmVx+rkqOZrt82PGOjDlukRPeWdl5L9rObC+8Up+cREb0Y7pGzMtiFl1kqNG
         77N3B3feZobw0RRhIiKPqHTZptultU+x3uEFV5MpqHgcx0wX8l3Q0ct6FHJMtfdCq3CK
         TT2d6OwaW/onSN5NN8/LSikciII6LfOI+I7P2MrTTamblVU2xmLnowuRFF7G8phrlDFI
         yjOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=PfRNwRVl7g3bqidrv95AzMgr3KnyTTsf1iUE/PpifHg=;
        b=yssyZANnptyseut3HCBMySOABqyb1mNqvN8ijzQfptLn6HgRi7N5Oc7PBGv1SrJgBv
         ZoaC0zvpJe1eKgd28yaUpveQIJwCp+3Iwk9utVzbKX/cf7/F3d583eAXjM73q6cBK/mb
         KBRKwQUFplPJIqLjsg7/DrqEHXubvmoxdZjDfiV72m2ii1KZ7HtjX0SbwA7akLje8IjM
         VMb8ZYeozWg2Mrrdw2/ZYdoTLerindjuSqjeiomYqTLjhInYUS7Yynn4qIJiJjlsHTe5
         rJSzTN/l197Y4t5oyCHTGGznfIFhM2f2oh/BG84qefdvnmDV+gOQhSVdQGF8IWi8lG/z
         E6sA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9sor5922492oia.134.2019.02.20.14.21.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 14:21:57 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IbYnyhjUWec6h/ijCvT3Sat82fibfLBId5o8D/Dh7apFdbkV8p7Y0qk3V3QfIBdHfoKJTEwz5vR437BlQkx0LY=
X-Received: by 2002:aca:c141:: with SMTP id r62mr7076865oif.160.1550701316742;
 Wed, 20 Feb 2019 14:21:56 -0800 (PST)
MIME-Version: 1.0
References: <20190214171017.9362-1-keith.busch@intel.com> <20190214171017.9362-8-keith.busch@intel.com>
 <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com> <9ab5d6ba-4cb6-a6f1-894d-d79b77c8bc21@intel.com>
In-Reply-To: <9ab5d6ba-4cb6-a6f1-894d-d79b77c8bc21@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Wed, 20 Feb 2019 23:21:45 +0100
Message-ID: <CAJZ5v0izS-MBcC3ZsRKK59zWcJOMQ672sRuv_GCVrsYR36Wa8w@mail.gmail.com>
Subject: Re: [PATCHv6 07/10] acpi/hmat: Register processor domain to its memory
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Keith Busch <keith.busch@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 11:11 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 2/20/19 2:02 PM, Rafael J. Wysocki wrote:
> >> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> >> index c9637e2e7514..08e972ead159 100644
> >> --- a/drivers/acpi/hmat/Kconfig
> >> +++ b/drivers/acpi/hmat/Kconfig
> >> @@ -2,6 +2,7 @@
> >>  config ACPI_HMAT
> >>         bool "ACPI Heterogeneous Memory Attribute Table Support"
> >>         depends on ACPI_NUMA
> >> +       select HMEM_REPORTING
> > If you want to do this here, I'm not sure that defining HMEM_REPORTING
> > as a user-selectable option is a good idea.  In particular, I don't
> > really think that setting ACPI_HMAT without it makes a lot of sense.
> > Apart from this, the patch looks reasonable to me.
>
> I guess the question is whether we would want to allow folks to consume
> the HMAT inside the kernel while not reporting it out via
> HMEM_REPORTING.  We have some in-kernel users of the HMAT lined up like
> mitigations for memory-side caches.
>
> It's certainly possible that folks would want to consume those
> mitigations without anything in sysfs.  They might not even want or need
> NUMA support itself, for instance.
>
> So, what should we do?
>
> config HMEM_REPORTING
>         bool # no user-visible prompt
>         default y if ACPI_HMAT
>
> So folks can override in their .config, but they don't see a prompt?

Maybe it would be better to make HMEM_REPORTING do "select ACPI_HMAT if ACPI".

The mitigations could then do that too if they depend on HMAT and
ACPI_HMAT need not be user-visible at all.

