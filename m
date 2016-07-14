Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 755BD6B0260
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 02:13:59 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so49090608wme.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 23:13:59 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id n125si31823567wme.125.2016.07.13.23.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 23:13:58 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id f126so54261598wma.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 23:13:58 -0700 (PDT)
Date: Thu, 14 Jul 2016 08:13:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] x86, pagetable: ignore A/D bits in pte/pmd/pud_none()
Message-ID: <20160714061355.GA24790@dhcp22.suse.cz>
References: <20160708001909.FB2443E2@viggo.jf.intel.com>
 <20160708001912.5216F89C@viggo.jf.intel.com>
 <20160713152145.GC20693@dhcp22.suse.cz>
 <578662A7.3040409@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <578662A7.3040409@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, dave.hansen@intel.com, dave.hansen@linux.intel.com

On Wed 13-07-16 08:47:51, Dave Hansen wrote:
> On 07/13/2016 08:21 AM, Michal Hocko wrote:
> >> > This adds a tiny amount of overhead to all pte_none() checks.
> >> > I doubt we'll be able to measure it anywhere.
> > It would be better to introduce the overhead only for the affected
> > cpu models but I guess this is also acceptable. Would it be too
> > complicated to use alternatives for that?
> 
> The patch as it stands ends up doing a one-instruction change in
> pte_none().  It goes from
> 
>     64c8:       48 85 ff                test   %rdi,%rdi
> 
> to
> 
>     64a8:       48 f7 c7 9f ff ff ff    test   $0xffffffffffffff9f,%rdi
> 
> So it essentially eats 4 bytes of icache more than it did before.  But,
> it's the same number of instructions, and I can't imagine that the CPU
> will have any more trouble with a test against an immediate than a test
> against 0.

I see. Thanks for the clarification.

> We could theoretically do alternatives for this, but we would at *best*
> end up with 4 bytes of noops.  So, unless the processor likes decoding 4
> noops better than 4 bytes of immediate as part of an instruction, we'll
> not win anything.  *Plus* the ugliness of the assembly that we'll need
> to have the compiler guarantee that the PTE ends up in %rdi.

Agreed!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
