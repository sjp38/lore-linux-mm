Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5948F2803AA
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 12:58:45 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 4so653641oie.8
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 09:58:45 -0700 (PDT)
Received: from mail-io0-x235.google.com (mail-io0-x235.google.com. [2607:f8b0:4001:c06::235])
        by mx.google.com with ESMTPS id j128si1639065oif.349.2017.08.23.09.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 09:58:44 -0700 (PDT)
Received: by mail-io0-x235.google.com with SMTP id p141so2466879iop.3
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 09:58:44 -0700 (PDT)
Date: Wed, 23 Aug 2017 10:58:42 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [kernel-hardening] [PATCH v5 04/10] arm64: Add __flush_tlb_one()
Message-ID: <20170823165842.k5lbxom45avvd7g2@smitten>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-5-tycho@docker.com>
 <20170812112603.GB16374@remoulade>
 <20170814163536.6njceqc3dip5lrlu@smitten>
 <20170814165047.GB23428@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170814165047.GB23428@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>

Hi Mark,

On Mon, Aug 14, 2017 at 05:50:47PM +0100, Mark Rutland wrote:
> That said, is there any reason not to use flush_tlb_kernel_range()
> directly?

So it turns out that there is a difference between __flush_tlb_one() and
flush_tlb_kernel_range() on x86: flush_tlb_kernel_range() flushes all the TLBs
via on_each_cpu(), where as __flush_tlb_one() only flushes the local TLB (which
I think is enough here).

As you might expect, this is quite a performance hit (at least under kvm), I
ran a little kernbench:

# __flush_tlb_one
Wed Aug 23 15:47:33 UTC 2017
4.13.0-rc5+
Average Half load -j 2 Run (std deviation):
Elapsed Time 50.3233 (1.82716)
User Time 87.1233 (1.26871)
System Time 15.36 (0.500899)
Percent CPU 203.667 (4.04145)
Context Switches 7350.33 (1339.65)
Sleeps 16008.3 (980.362)

Average Optimal load -j 4 Run (std deviation):
Elapsed Time 27.4267 (0.215019)
User Time 88.6983 (1.91501)
System Time 13.1933 (2.39488)
Percent CPU 286.333 (90.6083)
Context Switches 11393 (4509.14)
Sleeps 15764.7 (698.048)

# flush_tlb_kernel_range()
Wed Aug 23 16:00:03 UTC 2017
4.13.0-rc5+
Average Half load -j 2 Run (std deviation):
Elapsed Time 86.57 (1.06099)
User Time 103.25 (1.85475)
System Time 75.4433 (0.415852)
Percent CPU 205.667 (3.21455)
Context Switches 9363.33 (1361.57)
Sleeps 14703.3 (1439.12)

Average Optimal load -j 4 Run (std deviation):
Elapsed Time 51.27 (0.615873)
User Time 110.328 (7.93884)
System Time 74.06 (1.55788)
Percent CPU 288 (90.2197)
Context Switches 16557.5 (7930.01)
Sleeps 14774.7 (921.746)

So, I think we need to keep something like __flush_tlb_one around.
I'll call it flush_one_local_tlb() for now, and will cc x86@ on the
next version to see if they have any insight.

Cheers,

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
