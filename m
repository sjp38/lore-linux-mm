Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E4DC16B0263
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:47:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y134so47188481pfg.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:47:53 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id dz9si4719317pab.5.2016.07.13.08.47.53
        for <linux-mm@kvack.org>;
        Wed, 13 Jul 2016 08:47:53 -0700 (PDT)
Subject: Re: [PATCH 2/4] x86, pagetable: ignore A/D bits in pte/pmd/pud_none()
References: <20160708001909.FB2443E2@viggo.jf.intel.com>
 <20160708001912.5216F89C@viggo.jf.intel.com>
 <20160713152145.GC20693@dhcp22.suse.cz>
From: Dave Hansen <dave@sr71.net>
Message-ID: <578662A7.3040409@sr71.net>
Date: Wed, 13 Jul 2016 08:47:51 -0700
MIME-Version: 1.0
In-Reply-To: <20160713152145.GC20693@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, dave.hansen@intel.com, dave.hansen@linux.intel.com

On 07/13/2016 08:21 AM, Michal Hocko wrote:
>> > This adds a tiny amount of overhead to all pte_none() checks.
>> > I doubt we'll be able to measure it anywhere.
> It would be better to introduce the overhead only for the affected
> cpu models but I guess this is also acceptable. Would it be too
> complicated to use alternatives for that?

The patch as it stands ends up doing a one-instruction change in
pte_none().  It goes from

    64c8:       48 85 ff                test   %rdi,%rdi

to

    64a8:       48 f7 c7 9f ff ff ff    test   $0xffffffffffffff9f,%rdi

So it essentially eats 4 bytes of icache more than it did before.  But,
it's the same number of instructions, and I can't imagine that the CPU
will have any more trouble with a test against an immediate than a test
against 0.

We could theoretically do alternatives for this, but we would at *best*
end up with 4 bytes of noops.  So, unless the processor likes decoding 4
noops better than 4 bytes of immediate as part of an instruction, we'll
not win anything.  *Plus* the ugliness of the assembly that we'll need
to have the compiler guarantee that the PTE ends up in %rdi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
