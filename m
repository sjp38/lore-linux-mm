Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85D4E6B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 13:32:39 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id l8so3984807wmg.7
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 10:32:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x33si712474edm.58.2017.11.06.10.32.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 10:32:38 -0800 (PST)
Date: Mon, 6 Nov 2017 19:32:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Guaranteed allocation of huge pages (1G) using movablecore=N
 doesn't seem to work at all
Message-ID: <20171106183237.64b3hj25hbfw7v4l@dhcp22.suse.cz>
References: <CACAwPwZqFRyFJhb7pyyrufah+1TfCDuzQMo3qwJuMKkp6aYd_Q@mail.gmail.com>
 <CACAwPwbA0NpTC9bfV7ySHkxPrbZJVvjH=Be5_c25Q3S8qNay+w@mail.gmail.com>
 <CACAwPwamD4RL9O8wujK_jCKGu=x0dBBmH9O-9078cUEEk4WsMA@mail.gmail.com>
 <CACAwPwYKjK5RT-ChQqqUnD7PrtpXg1WhTHGK3q60i6StvDMDRg@mail.gmail.com>
 <CACAwPwav-eY4_nt=Z7TQB8WMFg+1X5WY2Gkgxph74X7=Ovfvrw@mail.gmail.com>
 <CACAwPwaP05FgxTp=kavwgFZF+LEGO-OSspJ4jH+Y=_uRxiVZaA@mail.gmail.com>
 <CACAwPwY5ss_D9kj7XoLVVkQ9=KXDFCnyDzdoxkGxhJZBNFre3w@mail.gmail.com>
 <CACAwPwYp4TysdH_1w1F9L7BpwFAGR8dNg04F6QASyQeYYNErkg@mail.gmail.com>
 <20171106180406.diowlwanvucnwkbp@dhcp22.suse.cz>
 <CACAwPwaTejMB8yOrkOxpDj297B=Y6bTvw2nAyHsiJKC+aB=a2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACAwPwaTejMB8yOrkOxpDj297B=Y6bTvw2nAyHsiJKC+aB=a2w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Cc: linux-mm@kvack.org

On Mon 06-11-17 20:13:36, Maxim Levitsky wrote:
> Yes, I tested git head from mainline and few kernels from ubuntu repos
> since I was lazy to compile them too.

OK, so this hasn't worked realiably as I've suspected.

> Do you have an idea what can I do about this issue? Do you think its
> feasable to fix this?

Well, I think that giga pages need quite some love to be usable
reliably. The current implementation is more towards "make it work if
there is enough unused memory".

> And if not using moveable zone, how would it even be possible to have
> guaranreed allocation of 1g pages

Having a guaranteed giga pages is something the kernel is not yet ready
to offer.  Abusing zone movable might look like the right direction
but that is not really the case until we make sure those pages are
migratable.

There has been a simple patch which makes PUD (1GB) pages migrateable
http://lkml.kernel.org/r/20170913101047.GA13026@gmail.com but I've had
concerns that it really didn't consider the migration path much
http://lkml.kernel.org/r/20171003073301.hydw7jf2wztsx2om%40dhcp22.suse.cz
I still believe the patch is not complete but maybe it is not that far
away from being so. E.g. the said pfn_range_valid_gigantic can be
enhanced to make the migration much more reliable or get rid of it
altogether because the pfn based allocator already knows how to do
migration and other stuff.

I can help some with that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
