Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14A49C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 12:21:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D637A2184E
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 12:21:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D637A2184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 658406B0005; Fri, 19 Jul 2019 08:21:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 609466B0006; Fri, 19 Jul 2019 08:21:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51F3F8E0001; Fri, 19 Jul 2019 08:21:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 06A406B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 08:21:16 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f3so21907498edx.10
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 05:21:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GZF2YlTNDMl3EzgT+5+nFWtjjhGE3TXjtZfLHS4nK74=;
        b=X2Q8+b7h5B3SoJknjfssxFskhoKK2QAKUGE3A/10hWbgMZKF6H9BQaP1Fmef0feRDs
         jsv15FpCU301BDGaqQ7Yjp1GRrsGwwZBWMUGO6xEsh0ynA77e0itJhwCFsstnKWuLIFu
         2T4mLOGlFb4CUOLwaqzovGG6hnUcC1+HluyNhzestCudxKYLgezAAo9DyVs9yfX0p1qG
         jh1LJDvJ3R9zopgEdzb5FQssbE0QRWZt3MwX+yLhDuEkGLTPOfazZdcZ051CzJI66f5a
         sMKIg7nWASJwIOszoUM5HCoOV1IU0HRpAyIlQJ9UMOjetITg0tAPdJqjNJG6BuGfCBnq
         KqIw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Gm-Message-State: APjAAAUdMRdwf8bnJhHizpewc5x8HR8OrQAu0uQDj9JLbXK1ZJAsYuu1
	3GrgU4ZkZHl2DEumec98rf5h7yX/T57lzcc6Y/OQyYzUj3tcvhZgObh7gVFQ4bQbG2mNjwzdapE
	3JaAmVyLPmvi2N83VCrKsmpG7p72M95mO5KW635R9hkRSdQ01ObEwQwmC8UBB6Zg/QQ==
X-Received: by 2002:a50:9ec3:: with SMTP id a61mr45391191edf.184.1563538875584;
        Fri, 19 Jul 2019 05:21:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycSxYJ0GRz0xUKiKMQdF7pLVZjsZbx2YtIMpbLoi6iPOP2MoGeU/0d4iXrK7gtTUOn0nIc
X-Received: by 2002:a50:9ec3:: with SMTP id a61mr45391090edf.184.1563538874494;
        Fri, 19 Jul 2019 05:21:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563538874; cv=none;
        d=google.com; s=arc-20160816;
        b=MsESiMLMKnJAQVUYku9zF54ZxUbWsMS4DdDlx5GbFc+7cECHdHuCN9u3Mc6D0qH//o
         jV+ZvfQ12wwEGLv9UeZcqHB0VJqKJkEjuCHifU2Jt9fJZaJ9u//8O+viaEMeZjBjx4Kd
         Gzvwbkp9lY4O4Jy3zsm/X/W0VERXvw7NudYnRJdz2U/32T71SIpQeZNOEmZOhUIXUZVB
         8o/DS9+nb71f+6wjzzYikDWxOoJg2CYQSk4Id5HTxrepQnhRTlke/4XTggES+e0I6L4h
         c1wy8JzV74T93eQzbLtuQC5nmjEfI3kOAtiy3leuZ5uIumeZabvPIaw0EDEw/Mky+HFp
         fQyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GZF2YlTNDMl3EzgT+5+nFWtjjhGE3TXjtZfLHS4nK74=;
        b=xx2SKlgkv+KHMivsXbSspPDXcmseA8yYXEeSHCNJvcjn6oUzztxNlY4tZJHt9+/Esx
         3aWdmEhrqWxZTPgwFhvJsDq4vAU7X6LvhSv9nsVuk7afM0Osk2csU5rCRmlVRqtrhD8K
         VJZnv8gpxxcfY3piSJD2z6Nk7WUaGi24zIxby6XjEFteYioDEAT+KThB8i30elOQuOzq
         8ZB1xiTOjVt3iOmAqe+JHU95R1eRStfo6ykejfxSAvOc6Vk6Z0f8Lle3ea017Qjq38jB
         uXoh8W8kRzAmlPr+XxfnPhRtVAJcTOuArJt4n0cQ/o+s6+54X+d3QqcdQn+HM+oAIcXs
         LI8g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 38si196844edq.398.2019.07.19.05.21.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 05:21:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EAEF8AF37;
	Fri, 19 Jul 2019 12:21:13 +0000 (UTC)
Date: Fri, 19 Jul 2019 14:21:11 +0200
From: Joerg Roedel <jroedel@suse.de>
To: Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Subject: Re: [PATCH 3/3] mm/vmalloc: Sync unmappings in vunmap_page_range()
Message-ID: <20190719122111.GD19068@suse.de>
References: <20190717071439.14261-1-joro@8bytes.org>
 <20190717071439.14261-4-joro@8bytes.org>
 <CALCETrXfCbajLhUixKNaMfFw91gzoQzt__faYLwyBqA3eAbQVA@mail.gmail.com>
 <20190718091745.GG13091@suse.de>
 <CALCETrXJYuHN872F74kVTuw4dYOc5saKqoUFbgJ5X0EuGEhXcA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXJYuHN872F74kVTuw4dYOc5saKqoUFbgJ5X0EuGEhXcA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 12:04:49PM -0700, Andy Lutomirski wrote:
> I find it problematic that there is no meaningful documentation as to
> what vmalloc_sync_all() is supposed to do.

Yeah, I found that too, there is no real design around
vmalloc_sync_all(). It looks like it was just added to fit the purpose
on x86-32. That also makes it hard to find all necessary call-sites.

> Which is obviously entirely inapplicable.  If I'm understanding
> correctly, the underlying issue here is that the vmalloc fault
> mechanism can propagate PGD entry *addition*, but nothing (not even
> flush_tlb_kernel_range()) propagates PGD entry *removal*.

Close, the underlying issue is not about PGD, but PMD entry
addition/removal on x86-32 pae systems.

> I find it suspicious that only x86 has this.  How do other
> architectures handle this?

The problem on x86-PAE arises from the !SHARED_KERNEL_PMD case, which was
introduced by the  Xen-PV patches and then re-used for the PTI-x32
enablement to be able to map the LDT into user-space at a fixed address.

Other architectures probably don't have the !SHARED_KERNEL_PMD case (or
do unsharing of kernel page-tables on any level where a huge-page could
be mapped).

> At the very least, I think this series needs a comment in
> vmalloc_sync_all() explaining exactly what the function promises to
> do.

Okay, as it stands, it promises to sync mappings for the vmalloc area
between all PGDs in the system. I will add that as a comment.

> But maybe a better fix is to add code to flush_tlb_kernel_range()
> to sync the vmalloc area if the flushed range overlaps the vmalloc
> area.

That would also cause needless overhead on x86-64 because the vmalloc
area doesn't need syncing there. I can make it x86-32 only, but that is
not a clean solution imo.

> Or, even better, improve x86_32 the way we did x86_64: adjust
> the memory mapping code such that top-level paging entries are never
> deleted in the first place.

There is not enough address space on x86-32 to partition it like on
x86-64. In the default PAE configuration there are _four_ PGD entries,
usually one for the kernel, and then 512 PMD entries. Partitioning
happens on the PMD level, for example there is one entry (2MB of address
space) reserved for the user-space LDT mapping.

Regards,

	Joerg

