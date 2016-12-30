Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CAA836B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 05:52:06 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id iq1so36853156wjb.1
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 02:52:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dk11si61797244wjd.116.2016.12.30.02.52.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Dec 2016 02:52:05 -0800 (PST)
Date: Fri, 30 Dec 2016 11:52:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Drop "PFNs busy" printk in an expected path.
Message-ID: <20161230105200.GE13301@dhcp22.suse.cz>
References: <20161229023131.506-1-eric@anholt.net>
 <20161229091256.GF29208@dhcp22.suse.cz>
 <87wpeitzld.fsf@eliezer.anholt.net>
 <xa1td1ga74v7.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <xa1td1ga74v7.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Eric Anholt <eric@anholt.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-stable <stable@vger.kernel.org>, "Robin H. Johnson" <robbat2@orbis-terrarum.net>, Vlastimil Babka <vbabka@suse.cz>, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu 29-12-16 23:22:20, Michal Nazarewicz wrote:
> On Thu, Dec 29 2016, Eric Anholt wrote:
> > Michal Hocko <mhocko@kernel.org> writes:
> >
> >> This has been already brought up
> >> http://lkml.kernel.org/r/20161130092239.GD18437@dhcp22.suse.cz and there
> >> was a proposed patch for that which ratelimited the output
> >> http://lkml.kernel.org/r/20161130132848.GG18432@dhcp22.suse.cz resp.
> >> http://lkml.kernel.org/r/robbat2-20161130T195244-998539995Z@orbis-terrarum.net
> >>
> >> then the email thread just died out because the issue turned out to be a
> >> configuration issue. Michal indicated that the message might be useful
> >> so dropping it completely seems like a bad idea. I do agree that
> >> something has to be done about that though. Can we reconsider the
> >> ratelimit thing?
> >
> > I agree that the rate of the message has gone up during 4.9 -- it used
> > to be a few per second.
> 
> Sounds like a regression which should be fixed.
> 
> This is why I dona??t think removing the message is a good idea.  If you
> suddenly see a lot of those messages, something changed for the worse.
> If you remove this message, you will never know.

I agree, that removing the message completely is not going to help to
find out regressions. Swamping logs with zillions of messages is,
however, not acceptable. It just causes even more problems. See the
previous report.

> > However, if this is an expected path during normal operation,
> 
> This depends on your definition of a??expecteda?? and a??normala??.
> 
> In general, I would argue that the fact those ever happen is a bug
> somewhere in the kernel a?? if memory is allocated as movable, it should
> be movable damn it!

Yes, it should be movable but there is no guarantee it is movable
immediately. Those pages might be pinned for some time. This is
unavoidable AFAICS.

So while this might be a regression which should be investigated there
should be another fix to prevent from swamping the logs as well.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
