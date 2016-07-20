Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A44726B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 16:59:02 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p64so122731464pfb.0
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 13:59:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y67si5266056pfy.250.2016.07.20.13.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 13:59:01 -0700 (PDT)
Date: Wed, 20 Jul 2016 13:59:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 04/17] arm: get rid of superfluous __GFP_REPEAT
Message-Id: <20160720135900.6735fc0db41807c2edf88594@linux-foundation.org>
In-Reply-To: <20160601162424.GD19428@n2100.arm.linux.org.uk>
References: <1464599699-30131-1-git-send-email-mhocko@kernel.org>
	<1464599699-30131-5-git-send-email-mhocko@kernel.org>
	<20160601162424.GD19428@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org

On Wed, 1 Jun 2016 17:24:24 +0100 Russell King - ARM Linux <linux@armlinux.org.uk> wrote:

> On Mon, May 30, 2016 at 11:14:46AM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > __GFP_REPEAT has a rather weak semantic but since it has been introduced
> > around 2.6.12 it has been ignored for low order allocations.
> > 
> > PGALLOC_GFP uses __GFP_REPEAT but none of the allocation which uses
> > this flag is for more than order-2. This means that this flag has never
> > been actually useful here because it has always been used only for
> > PAGE_ALLOC_COSTLY requests.
> 
> I hear what you say, but...
> 
> commit 8c65da6dc89ccb605d73773b1dd617e72982d971
> Author: Russell King <rmk+kernel@arm.linux.org.uk>
> Date:   Sat Nov 30 12:52:31 2013 +0000
> 
>     ARM: pgd allocation: retry on failure
> 
>     Make pgd allocation retry on failure; we really need this to succeed
>     otherwise fork() can trigger OOMs.
> 
>     Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> 
> and that's the change which introduced this, and it did solve a problem
> for me.  So I'm not happy to give an ack for this change unless someone
> can tell me why adding __GFP_REPEAT back then had a beneficial effect.
> Maybe there was some other bug in the MM layer in 2013 which this change
> happened to solve?

I suspect that some other change has made arm's use of __GFP_REPEAT
unnecessary, because __GFP_REPEAT is now a no-op for order-0,1,2,3
allocations and none of the arm callsites which I can see are using
order-4 or higher.

So I think we should go ahead with this change.  If that causes some
problem then we'll need to dig in and figure out why the impossible
just happened, OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
