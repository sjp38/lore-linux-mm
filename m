Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EF89C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:17:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58B422086C
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:17:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58B422086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0209D8E003B; Wed, 20 Feb 2019 17:17:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F11958E0002; Wed, 20 Feb 2019 17:17:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E28018E003B; Wed, 20 Feb 2019 17:17:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id B5AEF8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:17:10 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id m52so22313283otc.13
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:17:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=aZiSJ5zHvIOHDPPsq+gJj9k0t/TVuDTgJuAZIqMAxis=;
        b=PHTCVQkG5bOLgRS8G68//NY8+yD1SjdeUAk+btNhYsXz6GwbouZSoX50QeGkvOpP7m
         Ti2YrkyrfJJSlyNpRnUL4zqLhM+kBEcL9UPIYyeaLfCv+yjFELURP/dLkFjvMRba686m
         WbZiU02t/Pfnjf3JuHyKiN8ETm1m3luLGo+DMpzd6XDo7+X6fqfQPZKAcdArX33zwO1c
         OqjuJ1R89YJqGL8XxK63K2+zZFiNSY/lxzPgjsJropSwYT5TMdAGJfn8pirfvbTaWjA5
         4nxTkEHY4iMvh/NuXcxc8aAsmxzhCr+QVadLDmFojzBK3ue/63xiIDRjO5M1SNvIkAQY
         +vmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAube0sA8H8S8tLWABiYVtwqZyVDmHREwhJ3s/NyxbUMopgMPLI+y
	ybcHfMJ6lX5oH+RhVsLaHcGJZpxIKCXWCwmaqk+nBAd9uz8bhiRx6L+yGpG3W9gewjdInXFAnai
	6L6m2WOfJ7r/E9Fhgt+zh9I1X+TrkDTe6fR1NMDf6McR0JHYnTDOxfcaRfB9Aph+CYrgA08ag+w
	otcZpIF4NVHm0wGPOt5Bp6+TBeB4A3mMSM1z0FeGCT6bkAJs5rvJTmVxS6nXlTdwDza+jjIannA
	0XV7oXnuVOi0wvmSRj4C5tIet5uNFn30vmiiqX8lfZHEt2Cz/5J8so4mKxVrtNoLiOdA82Edx5E
	Ju5ItNj2VJNEfzZ3JenIbuS9KLqnvDMAAML6JBYxPsAP8uGM7MsM/s4e+5xSnq6F3ZNJUbRbKg=
	=
X-Received: by 2002:a05:6830:20da:: with SMTP id z26mr18589517otq.204.1550701030529;
        Wed, 20 Feb 2019 14:17:10 -0800 (PST)
X-Received: by 2002:a05:6830:20da:: with SMTP id z26mr18589495otq.204.1550701029969;
        Wed, 20 Feb 2019 14:17:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550701029; cv=none;
        d=google.com; s=arc-20160816;
        b=LR7RkFblHpNtl3xwYfM3D9+ALnhJi38xoGuPV+kZzBo7/rIdzwR9CfXhgEwtIW5Xx1
         i1WhNt45pNK+9qATce5aIxh2qvzFRRUs7wufYffKwkazmogctDdP/7RRLz5s3PF/1SG+
         TWxPvtwsKe4yZdo4qNyUu/xlyu7xC13mACZrM7cBGVoyunK7yylg1aSkUUbBEZTwA8iI
         16Rd48gvhEhuVn+pOSsUhkM4ydQNn/25RNKwiOZD1Gp84hn7QM3BpkFYrSAtBHK+5w1q
         jcJDZ33SyoJ9K0DK5f7+Ab5j70jklZBSPCZ/bzhiJ7Dq9LjnXOwMGhrkSOdjZG+bH7YT
         gyyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=aZiSJ5zHvIOHDPPsq+gJj9k0t/TVuDTgJuAZIqMAxis=;
        b=IkpJ3cHfhHJz9loFi4egt6uYrfO8fz2oaNghN1zfk35EE9EKhrmyFyg+iRauJzfHmJ
         mjjc/kLePIe8u30iRpEpaZBBBizPEErJSX0uDPQuPXGJVeIXOAU2aHyegzMv8OaPaFYu
         MJawn66A94wEK7Mwu/ludMiKfD/eaWcBjT0J+wHkaD5hX+H2AE+0/7WLeR22jEGVE2UZ
         oQ70kz1/kav5NvCI8HNOa8VxkbxPE/TfXCZ4mQLo5TYHJXt86KqM1tv0GsKqrnjgF3fA
         8iRBT+fp/g9IkRRWXsY1XYtj8dNxzcQ+nwxGptADvMmFqCzwab4S9bnR0cQ9dvW1mTfg
         5LLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m13sor9723417oih.111.2019.02.20.14.17.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 14:17:09 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IYdg4Ic4DZNMP9CEt1r6Bd1F1fVzuO3jiNBVrgeqfuxI5QgCkmTc5WdvQJDoNqBgGSLF4P7w/0AjFyNExUXr5Y=
X-Received: by 2002:aca:c141:: with SMTP id r62mr7065095oif.160.1550701029508;
 Wed, 20 Feb 2019 14:17:09 -0800 (PST)
MIME-Version: 1.0
References: <20190214171017.9362-1-keith.busch@intel.com> <20190214171017.9362-8-keith.busch@intel.com>
 <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com>
 <9ab5d6ba-4cb6-a6f1-894d-d79b77c8bc21@intel.com> <CAPcyv4iP032bqAgCZ8czRXkJ_gXz0H1EVC+ypf6NhKQ65aKczg@mail.gmail.com>
In-Reply-To: <CAPcyv4iP032bqAgCZ8czRXkJ_gXz0H1EVC+ypf6NhKQ65aKczg@mail.gmail.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Wed, 20 Feb 2019 23:16:58 +0100
Message-ID: <CAJZ5v0hwyXnsLmCKNJvzOvcG-HD1UmuWNGFvoB02=2Ks1hE0bA@mail.gmail.com>
Subject: Re: [PATCHv6 07/10] acpi/hmat: Register processor domain to its memory
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "Rafael J. Wysocki" <rafael@kernel.org>, 
	Keith Busch <keith.busch@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 11:14 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Wed, Feb 20, 2019 at 2:11 PM Dave Hansen <dave.hansen@intel.com> wrote:
> >
> > On 2/20/19 2:02 PM, Rafael J. Wysocki wrote:
> > >> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> > >> index c9637e2e7514..08e972ead159 100644
> > >> --- a/drivers/acpi/hmat/Kconfig
> > >> +++ b/drivers/acpi/hmat/Kconfig
> > >> @@ -2,6 +2,7 @@
> > >>  config ACPI_HMAT
> > >>         bool "ACPI Heterogeneous Memory Attribute Table Support"
> > >>         depends on ACPI_NUMA
> > >> +       select HMEM_REPORTING
> > > If you want to do this here, I'm not sure that defining HMEM_REPORTING
> > > as a user-selectable option is a good idea.  In particular, I don't
> > > really think that setting ACPI_HMAT without it makes a lot of sense.
> > > Apart from this, the patch looks reasonable to me.
> >
> > I guess the question is whether we would want to allow folks to consume
> > the HMAT inside the kernel while not reporting it out via
> > HMEM_REPORTING.  We have some in-kernel users of the HMAT lined up like
> > mitigations for memory-side caches.
> >
> > It's certainly possible that folks would want to consume those
> > mitigations without anything in sysfs.  They might not even want or need
> > NUMA support itself, for instance.
> >
> > So, what should we do?
> >
> > config HMEM_REPORTING
> >         bool # no user-visible prompt
> >         default y if ACPI_HMAT
> >
> > So folks can override in their .config, but they don't see a prompt?
>
> I would add an "&& ACPI_NUMA" to that default as well.

But ACPI_HMAT depends on ACPI_NUMA already, or am I missing anything?

