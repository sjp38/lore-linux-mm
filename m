Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8F74E2803B4
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 13:13:05 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id y7so675470oia.15
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 10:13:05 -0700 (PDT)
Received: from mail-io0-x229.google.com (mail-io0-x229.google.com. [2607:f8b0:4001:c06::229])
        by mx.google.com with ESMTPS id v128si1645446oib.40.2017.08.23.10.13.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 10:13:04 -0700 (PDT)
Received: by mail-io0-x229.google.com with SMTP id o196so2731327ioe.0
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 10:13:04 -0700 (PDT)
Date: Wed, 23 Aug 2017 11:13:02 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [kernel-hardening] [PATCH v5 04/10] arm64: Add __flush_tlb_one()
Message-ID: <20170823171302.ubnv7qyrexhhpbs7@smitten>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-5-tycho@docker.com>
 <20170812112603.GB16374@remoulade>
 <20170814163536.6njceqc3dip5lrlu@smitten>
 <20170814165047.GB23428@leverpostej>
 <20170823165842.k5lbxom45avvd7g2@smitten>
 <20170823170443.GD12567@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170823170443.GD12567@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>

On Wed, Aug 23, 2017 at 06:04:43PM +0100, Mark Rutland wrote:
> On Wed, Aug 23, 2017 at 10:58:42AM -0600, Tycho Andersen wrote:
> > Hi Mark,
> > 
> > On Mon, Aug 14, 2017 at 05:50:47PM +0100, Mark Rutland wrote:
> > > That said, is there any reason not to use flush_tlb_kernel_range()
> > > directly?
> > 
> > So it turns out that there is a difference between __flush_tlb_one() and
> > flush_tlb_kernel_range() on x86: flush_tlb_kernel_range() flushes all the TLBs
> > via on_each_cpu(), where as __flush_tlb_one() only flushes the local TLB (which
> > I think is enough here).
> 
> That sounds suspicious; I don't think that __flush_tlb_one() is
> sufficient.
> 
> If you only do local TLB maintenance, then the page is left accessible
> to other CPUs via the (stale) kernel mappings. i.e. the page isn't
> exclusively mapped by userspace.

I thought so too, so I tried to test it with something like the patch
below. But it correctly failed for me when using __flush_tlb_one(). I
suppose I'm doing something wrong in the test, but I'm not sure what.

Tycho
