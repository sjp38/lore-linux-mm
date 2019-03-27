Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0287C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:33:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA2212146F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:33:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA2212146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40F746B0005; Wed, 27 Mar 2019 13:33:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3980F6B0006; Wed, 27 Mar 2019 13:33:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 286C96B0007; Wed, 27 Mar 2019 13:33:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C5F526B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:33:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i59so6982500edi.15
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 10:33:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=m0U/aFSe6pHtZN7odX1vSQ62dNMvXPz1h5RkwfV3haA=;
        b=KDOaWn24J5aayZVPDrYLDGsixyciOws8+EHP6UXvLY9lS1LtvSbS0mNA04o+D48GUP
         zgzfi/WhFS/Igb4b38BOeWzijCmx6ZPWv5qr7oq9DTkJ822tZn+0athKbg/DLFPpogk9
         MjonSZLBCXoY7pq/2p5bGuvQC9YYXw+cJt1USIjkJzQ9MvUTqA/k7kCUGlSETZyS1chW
         9QeLqVjSEOuCR1weKVB6LHh3U4P5+YhQGVdk0mQnBb/O3dCACj+8oIoGt5Ro7bjxbw6c
         7aSrIIISulEcpfj5/qULWRiqY2Z3gfsVnfrf05uDQQMa9yGgVZ3LwyQAshFJX+PS4WVJ
         5/ng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAWk7mMiNzTCTI6d/f+mB06/BZYJLlVxuTgSbcG8V6VeqKfjCVmp
	ei6bOhJeyzTdmRV92SHYzj6zfYgGWl193ALqqU0QggfBzmshOVtoTT8FJjg9oyqBvevmRY5SH+t
	4U4+bahAtPjA1f/aMGmaR7xUmzLgvvwQ2LIgBbUSzbAC6hUKKca9QecDVkZsoWw/Bjw==
X-Received: by 2002:a50:b493:: with SMTP id w19mr26068758edd.11.1553708015364;
        Wed, 27 Mar 2019 10:33:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyR6Qc/A+6sZNsjwUUOPo0UQNEgg/pNI76219rs7oTe6dUKr3BPtqrjBDvaDW2ZMq1SA1Ib
X-Received: by 2002:a50:b493:: with SMTP id w19mr26068694edd.11.1553708014244;
        Wed, 27 Mar 2019 10:33:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553708014; cv=none;
        d=google.com; s=arc-20160816;
        b=Hlv12EMKzszsP6MDX6JtqWKrp1WoSt4JMLQXApdFOtp+W9xfCc0or1UircwhMKnMjT
         /sUY8nTaR8LARCIwNAmrbCreiYrvqQZ6D7khOJoC8LpkZFVLFjZUNbuPYHgzgqnrWtqc
         mdPfCpNl6e+d9F2gEh/Rp4SzklvOCyaneF0XpLtTVHThxMOagIFo0NnWACmBvHZIqLQx
         haUqWiw2snZweMTZkecclF/SI1VTlz/DD0wn7SQTbQSTRB57yjrEkZYHdIYJu7uj+N+T
         g+JUUQu6KGKC3lW7eOEK2cjEimuU2FYiPPCmT7jPFUktybps0OUR4hkiNFtPya3IpGs3
         E56Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=m0U/aFSe6pHtZN7odX1vSQ62dNMvXPz1h5RkwfV3haA=;
        b=Uqe5XICs5nU21Ny12IVyMWCmPkpAtWmvulU2d4szL9OWyMQ7d6/3146qVobydbD3go
         4Iqo/K5C1phVG+F00d7nYv1tneVS4QgD6WTrkiwcbFtXO/58sZCyxdrL9YKwcsvxyrap
         RveV7vjFdWyTWv1A39WcdFYDzEdJCPWC5OrLh0HtlOAvsw0SXGr3YAdNBC1h2scludKc
         OAMncVMf+wlegJS9s0mwfMZrUUK+9iL3dU5gZaTJ2SLbXFKTG4B5MLaLVVeommVB/Jht
         LoKE/3u61e6YdSbgqbDAlqFsAl7+tMCCVSjMVYtcwoGEsV1I7OO80YckqmNrK2hNFwTY
         55zg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l37si2592248edc.451.2019.03.27.10.33.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 10:33:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 86E5EAFF2;
	Wed, 27 Mar 2019 17:33:33 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id C64591E1589; Wed, 27 Mar 2019 18:33:32 +0100 (CET)
Date: Wed, 27 Mar 2019 18:33:32 +0100
From: Jan Kara <jack@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Chandan Rajendra <chandan@linux.ibm.com>,
	stable <stable@vger.kernel.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH] mm: Fix modifying of page protection by insert_pfn()
Message-ID: <20190327173332.GA15475@quack2.suse.cz>
References: <20190311084537.16029-1-jack@suse.cz>
 <CAPcyv4gBhTXs3Lf1ESgtaT4JUV8xiwNnM_OQU3-0ENB0hpAPng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gBhTXs3Lf1ESgtaT4JUV8xiwNnM_OQU3-0ENB0hpAPng@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 11-03-19 10:22:44, Dan Williams wrote:
> On Mon, Mar 11, 2019 at 1:45 AM Jan Kara <jack@suse.cz> wrote:
> >
> > Aneesh has reported that PPC triggers the following warning when
> > excercising DAX code:
> >
> > [c00000000007610c] set_pte_at+0x3c/0x190
> > LR [c000000000378628] insert_pfn+0x208/0x280
> > Call Trace:
> > [c0000002125df980] [8000000000000104] 0x8000000000000104 (unreliable)
> > [c0000002125df9c0] [c000000000378488] insert_pfn+0x68/0x280
> > [c0000002125dfa30] [c0000000004a5494] dax_iomap_pte_fault.isra.7+0x734/0xa40
> > [c0000002125dfb50] [c000000000627250] __xfs_filemap_fault+0x280/0x2d0
> > [c0000002125dfbb0] [c000000000373abc] do_wp_page+0x48c/0xa40
> > [c0000002125dfc00] [c000000000379170] __handle_mm_fault+0x8d0/0x1fd0
> > [c0000002125dfd00] [c00000000037a9b0] handle_mm_fault+0x140/0x250
> > [c0000002125dfd40] [c000000000074bb0] __do_page_fault+0x300/0xd60
> > [c0000002125dfe20] [c00000000000acf4] handle_page_fault+0x18
> >
> > Now that is WARN_ON in set_pte_at which is
> >
> >         VM_WARN_ON(pte_hw_valid(*ptep) && !pte_protnone(*ptep));
> >
> > The problem is that on some architectures set_pte_at() cannot cope with
> > a situation where there is already some (different) valid entry present.
> >
> > Use ptep_set_access_flags() instead to modify the pfn which is built to
> > deal with modifying existing PTE.
> >
> > CC: stable@vger.kernel.org
> > Fixes: b2770da64254 "mm: add vm_insert_mixed_mkwrite()"
> > Reported-by: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> > Signed-off-by: Jan Kara <jack@suse.cz>
> 
> Acked-by: Dan Williams <dan.j.williams@intel.com>
> 
> Andrew, can you pick this up?

Andrew, ping?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

