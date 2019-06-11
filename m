Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B03EC43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 09:38:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF633212F5
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 09:38:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF633212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 711766B0007; Tue, 11 Jun 2019 05:38:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C2866B0008; Tue, 11 Jun 2019 05:38:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D6D06B000A; Tue, 11 Jun 2019 05:38:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB8A6B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:38:34 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c1so19819910edi.20
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 02:38:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6q1R6VkX/s6POxfFRQ2SqAnw9oY8FrCxPQ2D4yeGm1s=;
        b=uaJM71nfRcPyG9Tfvxiw2sJfu3OIe0XPnPc7bpbe4tTg22cP0VE+zwtl34v6r8JzLX
         4f2mO44paXn3MPslAjiIy78r1BHFTSCWEMnxEvxw1y7dbl6IR4L/MCNDkPrak+aihaF9
         dyfXwo3d1JVOWdwh2VXk/qJy8eszneOLg1rG35xT1gTrxpWm8QRftllE712aBMZveJ0f
         JWa1xP6D/upHcWcdb3kCl++ZJR0RqPAuZCh+T3LOanhp+GtPBacTct+pR9QWrSNtvDzU
         WMbpl1Z5a44kJG30ZxqgZN/CBe3LkXYsVnxjBg0Ty5S+/+6uZ6JIhCYO597WP7+x+W+J
         5xTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAWAYYG4xlkwjna9d62bFEY+SkmyiFAMdNitnTd2khy3LYz3Y9Sx
	qQQ0MFLUjyIlL+CQy5nj9LX6aIcbaiF7a4wyPDAssFtSYEN2aKnKi2IAAmTGrkRONSgPKLQDKAS
	KcJ4DzGkRAGJ+8ia8Ah7I6BHaLvwpygWOYERpdLMZSS8MRbrgMYYtFfdcybM+1E67qQ==
X-Received: by 2002:a50:b062:: with SMTP id i89mr79580630edd.85.1560245913619;
        Tue, 11 Jun 2019 02:38:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrayCdc4lk/vSM/gwF+B5KkQzeiZhqQrI1Nk3XjEp8L8EicbegO8nA2QpmHHWL+sJlQnV8
X-Received: by 2002:a50:b062:: with SMTP id i89mr79580568edd.85.1560245912821;
        Tue, 11 Jun 2019 02:38:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560245912; cv=none;
        d=google.com; s=arc-20160816;
        b=eFiwrrBdoM4nSZMIuvUhW/zLx3sYaEORr/JYa9orZnkbjpwDA7S+RuvkPUKN3e1P7q
         MCWmCQ6sEeFITJcRSp/5x/0Vs8/AHY4CUmL4oX+M8yrOlMwSR8l/Ks8O/F136Vkkg5F5
         16b/rFUVoSZxgR4RpAuBSmGCYyjTkplDRGyLePNm3kr19yrIaQ0hRPU9nlt8/pU5gNkB
         zhUtBwzqHpiDNh4uP4BK1n5gXaYUB7KZrrSBDfuN8/j4TOeswoJNufklRGUlKWxFbou+
         +HLPo+dlSQbcO6sKHnKpz88UGLDwTAu+ia3sjvpyQ6RqbEQFxrSCPNpPu2FFXZ185q7P
         zfmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6q1R6VkX/s6POxfFRQ2SqAnw9oY8FrCxPQ2D4yeGm1s=;
        b=FaOMyzMgkicllrYC/sNdhDtko2EqsUZ6xfZDlYO3gNmPW2VigYXF4fZlBTco5Jpfe5
         eu9UowgkRR/4yMYFb4v9F6bF7RkGWT3qdhjoCo5TWaLgtopbhQPGji36e1HUw2IejZuv
         ByP47hA084tcBjgHoKWzVH4sw2UPPkogkxfx+d3sHueGkijXuBLOs/0XXASoTL+0wnJ1
         4N5cQnaD37VbjSXkGbKaafTuLn8lBXwcLQAfULBqjFSMdod7Wv7fcPINU9uJGefW+nE/
         5/FcTJmARfT3w2sYbKyWi6dNCEggreh7CxhVcYCAnRkwMQqBOxEUVkq7NMjoJutDoWTv
         ck/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l1si7315537ejn.215.2019.06.11.02.38.31
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 02:38:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CD815EBD;
	Tue, 11 Jun 2019 02:38:30 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AF8543F77D;
	Tue, 11 Jun 2019 02:38:29 -0700 (PDT)
Date: Tue, 11 Jun 2019 10:38:23 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>, Yu Zhao <yuzhao@google.com>,
	linux-mm@kvack.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH] mm: treewide: Clarify pgtable_page_{ctor,dtor}() naming
Message-ID: <20190611093822.GA26409@lakrids.cambridge.arm.com>
References: <20190610163354.24835-1-mark.rutland@arm.com>
 <20190610130511.310e8d2cc8d6b02b2c3e238d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190610130511.310e8d2cc8d6b02b2c3e238d@linux-foundation.org>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 01:05:11PM -0700, Andrew Morton wrote:
> On Mon, 10 Jun 2019 17:33:54 +0100 Mark Rutland <mark.rutland@arm.com> wrote:
> 
> > The naming of pgtable_page_{ctor,dtor}() seems to have confused a few
> > people, and until recently arm64 used these erroneously/pointlessly for
> > other levels of pagetable.
> > 
> > To make it incredibly clear that these only apply to the PTE level, and
> > to align with the naming of pgtable_pmd_page_{ctor,dtor}(), let's rename
> > them to pgtable_pte_page_{ctor,dtor}().
> > 
> > The bulk of this conversion was performed by the below Coccinelle
> > semantic patch, with manual whitespace fixups applied within macros, and
> > Documentation updated by hand.
> 
> eep.  I get a spectacular number of rejects thanks to Mike's series
> 
> asm-generic-x86-introduce-generic-pte_allocfree_one.patch
> alpha-switch-to-generic-version-of-pte-allocation.patch
> arm-switch-to-generic-version-of-pte-allocation.patch
> arm64-switch-to-generic-version-of-pte-allocation.patch
> csky-switch-to-generic-version-of-pte-allocation.patch
> m68k-sun3-switch-to-generic-version-of-pte-allocation.patch
> mips-switch-to-generic-version-of-pte-allocation.patch
> nds32-switch-to-generic-version-of-pte-allocation.patch
> nios2-switch-to-generic-version-of-pte-allocation.patch
> parisc-switch-to-generic-version-of-pte-allocation.patch
> riscv-switch-to-generic-version-of-pte-allocation.patch
> um-switch-to-generic-version-of-pte-allocation.patch
> unicore32-switch-to-generic-version-of-pte-allocation.patch
> 
> But at least they will make your patch smaller!

Aha; thanks for the heads-up!

Given this cleanup isn't urgent, I'll sit on it until the above has
settled.

Mark.

