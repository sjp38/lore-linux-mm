Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 254C86B0031
	for <linux-mm@kvack.org>; Sat, 14 Dec 2013 06:08:49 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id o15so247018qap.10
        for <linux-mm@kvack.org>; Sat, 14 Dec 2013 03:08:48 -0800 (PST)
Received: from mail-qa0-x231.google.com (mail-qa0-x231.google.com [2607:f8b0:400d:c00::231])
        by mx.google.com with ESMTPS id v3si5437093qat.149.2013.12.14.03.08.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 14 Dec 2013 03:08:48 -0800 (PST)
Received: by mail-qa0-f49.google.com with SMTP id ii20so244551qab.8
        for <linux-mm@kvack.org>; Sat, 14 Dec 2013 03:08:47 -0800 (PST)
Date: Sat, 14 Dec 2013 06:08:44 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 08/23] mm/memblock: Add memblock memory allocation apis
Message-ID: <20131214110844.GB17954@htj.dyndns.org>
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
 <1386625856-12942-9-git-send-email-santosh.shilimkar@ti.com>
 <20131213213735.GM27070@htj.dyndns.org>
 <52ABABDA.4020808@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52ABABDA.4020808@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Grygorii Strashko <grygorii.strashko@ti.com>

Hello, Santosh.

On Fri, Dec 13, 2013 at 07:52:42PM -0500, Santosh Shilimkar wrote:
> >> +static void * __init memblock_virt_alloc_internal(
> >> +				phys_addr_t size, phys_addr_t align,
> >> +				phys_addr_t min_addr, phys_addr_t max_addr,
> >> +				int nid)
> >> +{
> >> +	phys_addr_t alloc;
> >> +	void *ptr;
> >> +
> >> +	if (nid == MAX_NUMNODES)
> >> +		pr_warn("%s: usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE\n",
> >> +			__func__);
> > 
> > Why not use WARN_ONCE()?  Also, shouldn't nid be set to NUMA_NO_NODE
> > here?
> > 
> You want all the users using MAX_NUMNODES to know about it so that
> the wrong usage can be fixed. WARN_ONCE will hide that.

Well, it doesn't really help anyone to be printing multiple messages
without any info on who was the caller and if this thing is gonna be
in mainline triggering of the warning should be rare anyway.  It's
more of a tool to gather one-off cases in the wild.  WARN_ONCE()
usually is the better choice as otherwise the warnings can swamp the
machine and console output in certain cases.

> > ...
> >> +	if (nid != NUMA_NO_NODE) {
> > 
> > Otherwise, the above test is broken.
> > 
> So the idea was just to warn the users and allow them to fix
> the code. Well we are just allowing the existing users of using
> either MAX_NUMNODES or NUMA_NO_NODE continue to work. Thats what
> we discussed, right ?

Huh?  Yeah, sure.  You're testing @nid against MAX_NUMNODES at the
beginning of the function.  If it's MAX_NUMNODES, you print a warning
but nothing else, so the if() conditional above, which should succeed,
would fail.  Am I missing sth here?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
