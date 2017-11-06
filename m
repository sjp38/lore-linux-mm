Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 939696B0260
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 13:04:17 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id s75so13458601pgs.12
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 10:04:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b5si11537820pgr.120.2017.11.06.10.04.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 10:04:16 -0800 (PST)
Date: Mon, 6 Nov 2017 19:04:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Guaranteed allocation of huge pages (1G) using movablecore=N
 doesn't seem to work at all
Message-ID: <20171106180406.diowlwanvucnwkbp@dhcp22.suse.cz>
References: <20171106171150.7a2lent6vdrewsk7@dhcp22.suse.cz>
 <CACAwPwZuiT9BfunVgy73KYjGfVopgcE0dknAxSLPNeJB8rkcMQ@mail.gmail.com>
 <CACAwPwZqFRyFJhb7pyyrufah+1TfCDuzQMo3qwJuMKkp6aYd_Q@mail.gmail.com>
 <CACAwPwbA0NpTC9bfV7ySHkxPrbZJVvjH=Be5_c25Q3S8qNay+w@mail.gmail.com>
 <CACAwPwamD4RL9O8wujK_jCKGu=x0dBBmH9O-9078cUEEk4WsMA@mail.gmail.com>
 <CACAwPwYKjK5RT-ChQqqUnD7PrtpXg1WhTHGK3q60i6StvDMDRg@mail.gmail.com>
 <CACAwPwav-eY4_nt=Z7TQB8WMFg+1X5WY2Gkgxph74X7=Ovfvrw@mail.gmail.com>
 <CACAwPwaP05FgxTp=kavwgFZF+LEGO-OSspJ4jH+Y=_uRxiVZaA@mail.gmail.com>
 <CACAwPwY5ss_D9kj7XoLVVkQ9=KXDFCnyDzdoxkGxhJZBNFre3w@mail.gmail.com>
 <CACAwPwYp4TysdH_1w1F9L7BpwFAGR8dNg04F6QASyQeYYNErkg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACAwPwYp4TysdH_1w1F9L7BpwFAGR8dNg04F6QASyQeYYNErkg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Cc: linux-mm@kvack.org

On Mon 06-11-17 19:36:38, Maxim Levitsky wrote:
> Isn't this a non backward compatible change? Why to remove an optional non
> default option for use cases like mine.

Well, strictly speaking it is. The reality is that with the current
implementation the option breaks the hotplug usecase. I can see your
argument about the opt in and we might need to hold on this patch for
merging uut it seems that http://lkml.kernel.org/r/20171003072619.8654-1-mhocko@kernel.org
is not the problem you are seeing.

> I won't argue with you on this, but my question was different, and was why
> the kernel can't move other pages from moveable zone in my case.

OK, I have re-read your original report where you say
: This was tested on 4.14.0-rc5 (my custom compiled) and on several
: older kernels (4.10,4.12,4.13) from ubuntu repositories.

Does that mean that this a new regression in 4.14-rc5 or you see the
problem in other kernels too?

If this a new rc5 thing then 79b63f12abcb ("mm, hugetlb: do not
allocate non-migrateable gigantic pages from movable zones") might be
related. Although it shouldn't if hugepages_treat_as_movable is enabled.

I wouldn't be all that surprised if this was an older issue, though. If
I look at pfn_range_valid_gigantic it seems that the page count check
makes it just too easy to fail even on migratable memory. To be honest
I consider the giga pages runtime support rather fragile and that is
why I wasn't very much afraid to remove hacks that allow breaking other
usecases.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
