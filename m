Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id A40A76B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 18:53:56 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so834113pde.36
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 15:53:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id yb4si14520161pab.349.2014.04.29.15.53.55
        for <linux-mm@kvack.org>;
        Tue, 29 Apr 2014 15:53:55 -0700 (PDT)
Date: Tue, 29 Apr 2014 15:53:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,writeback: fix divide by zero in pos_ratio_polynom
Message-Id: <20140429155353.8fe070101d3b4faa0c825d99@linux-foundation.org>
In-Reply-To: <53602C2B.50604@redhat.com>
References: <20140429151910.53f740ef@annuminas.surriel.com>
	<20140429153936.49a2710c0c2bba4d233032f2@linux-foundation.org>
	<53602C2B.50604@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, mhocko@suse.cz, fengguang.wu@intel.com, mpatlasov@parallels.com

On Tue, 29 Apr 2014 18:48:11 -0400 Rik van Riel <riel@redhat.com> wrote:

> On 04/29/2014 06:39 PM, Andrew Morton wrote:
> > On Tue, 29 Apr 2014 15:19:10 -0400 Rik van Riel <riel@redhat.com> wrote:
> > 
> >> It is possible for "limit - setpoint + 1" to equal zero, leading to a
> >> divide by zero error. Blindly adding 1 to "limit - setpoint" is not
> >> working, so we need to actually test the divisor before calling div64.
> >>
> >> ...
> >>
> >> --- a/mm/page-writeback.c
> >> +++ b/mm/page-writeback.c
> >> @@ -597,11 +597,16 @@ static inline long long pos_ratio_polynom(unsigned long setpoint,
> >>  					  unsigned long dirty,
> >>  					  unsigned long limit)
> >>  {
> >> +	unsigned int divisor;
> > 
> > I'm thinking this would be better as a ulong so I don't have to worry
> > my pretty head over truncation things?
> 
> I looked at div_*64, and the second argument is a 32 bit
> variable. I guess a long would be ok, since if we are
> dividing by more than 4 billion we don't really care :)
> 
> static inline s64 div_s64(s64 dividend, s32 divisor)

ah, good point.  Switching to ulong is perhaps a bit misleading then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
