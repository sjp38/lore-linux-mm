Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 350D3C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:57:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB4BD2087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:57:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB4BD2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8318A8E0005; Tue, 30 Jul 2019 08:57:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E3058E0001; Tue, 30 Jul 2019 08:57:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D1998E0005; Tue, 30 Jul 2019 08:57:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB708E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:57:54 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w25so40255970edu.11
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 05:57:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LhPpTxq1W4lX/oUUkNGmNsFIixIpMH9fRPv9xB0PyE8=;
        b=HxXPTDQjGBkBa7fxdcHp0K11Nr12gV+wU+mr+E/CevhUfwy4cMhl+NhsyWoAaiAlHi
         IJXstuvg7DPqmg6ddRXBXmPnX18gvxy/spYIr7EwdZM4hDRnS8rs1c+yYTabw/F+PnA1
         09dnlw5tt2kCe38nsJwm9RMAoIbiNLVyvbtdfNp+fWi45yLBtfxm1wzYlPIM+Xop+vc1
         WdEguOeWLOpZ521b0hxejPz+pdqz6rCC08B1hT2nzVlxDUnkMYcUuQdSAHMqeyBy6WYI
         gW772w8XRtEwZBr47dkaH+WBj9qPTTQ1AzMorBCXdsAXO5ojU/RCesZ7nn30c0ferrsy
         IDsw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW2idjuJxcGUu2//uuVb3/zZwzmwqXc06zyebtYsFadmXO2120j
	0Lt+9kaC/umMwhOIsIMefP7UmewIbABXbfQEPcuv9dcyqiia0hmhNjmDGAhUD058iD5mpJGpKsY
	ZavAlhEzC9ewmkRdBJH0j1xrWJTRMIhYMDu/eLIskrXClSYfmED4Pw5LrQvGREso=
X-Received: by 2002:a17:906:3507:: with SMTP id r7mr56311198eja.45.1564491473668;
        Tue, 30 Jul 2019 05:57:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOF0lBbCPBrOOREpZAmDu77qf4070XQRygI1rlhTa6DS3X4g+yQsfT27lkcTLJBhKLi7nk
X-Received: by 2002:a17:906:3507:: with SMTP id r7mr56311151eja.45.1564491472739;
        Tue, 30 Jul 2019 05:57:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564491472; cv=none;
        d=google.com; s=arc-20160816;
        b=IWAG3UqsV9C5wm3jjCPnU+RklLq7lk0W1iGLLKZHFUikjFNgPGViyORhxzpZRd+6rc
         F2I0ow50wHgCbnFaQfBtIw7fFruyS5jUOHWe9BLLdXTTlQleNLXROW9VxxyyxK8Sfddl
         +L/UsbPI5XWhlHCjO/f9WQ67BwtDd4B7vqjWlLxEaLsyaeO0hSxzqV8+PXe0P/wC55Ee
         qlahvGdbqjm19/hKnp8gEvJoQpo6gagqN0FJUoYvLR+GbZF38Z+tq4MBeuQM7d8Ym7rI
         D+HE/emJ35SyFaf+a7AeHBqA3UaEpkd5DygISUc5//ucwwlHGiEX5sbVdKi8l2B9Fh2A
         Ey1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LhPpTxq1W4lX/oUUkNGmNsFIixIpMH9fRPv9xB0PyE8=;
        b=r3XRqU8X3N2TQwC9kdruBUpE4OcfDXC7DJdKne0V+jN1zxJTpeOIxY8OmR+1oxd5F8
         VyowG2Mrp5nk/DX+Golz+kqKC60nJj5mKlLJlJKxh2DfsJn0xI3bXa2JhPLPRA0F3DBw
         c6gE1EQ77pFpSbDKSlj4IyiKL0DR5q0DXFvwBpgA+XwKbUx9fRAL49AJepWxrJSg2Dz2
         9Capo14AHHwb/vq4MNrRvt4ukouotS6TdXQrC4iznSE9bCeIOcyDGnK1wL6KcRiS67ww
         bq8wZywyS14wmFqnVn6hp6fnmVEu4vCt7/uU1yc7cc3u2gl9RxC6fehewwxtx8RrVe0A
         PljQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g24si19702389edb.391.2019.07.30.05.57.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 05:57:52 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ECEAAAC20;
	Tue, 30 Jul 2019 12:57:51 +0000 (UTC)
Date: Tue, 30 Jul 2019 14:57:51 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH] mm: release the spinlock on zap_pte_range
Message-ID: <20190730125751.GS9330@dhcp22.suse.cz>
References: <20190729071037.241581-1-minchan@kernel.org>
 <20190729074523.GC9330@dhcp22.suse.cz>
 <20190729082052.GA258885@google.com>
 <20190729083515.GD9330@dhcp22.suse.cz>
 <20190730121110.GA184615@google.com>
 <20190730123237.GR9330@dhcp22.suse.cz>
 <20190730123935.GB184615@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730123935.GB184615@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc Nick - the email thread starts http://lkml.kernel.org/r/20190729071037.241581-1-minchan@kernel.org
 A very brief summary is that mark_page_accessed seems to be quite
 expensive and the question is whether we still need it and why
 SetPageReferenced cannot be used instead. More below.]

On Tue 30-07-19 21:39:35, Minchan Kim wrote:
> On Tue, Jul 30, 2019 at 02:32:37PM +0200, Michal Hocko wrote:
> > On Tue 30-07-19 21:11:10, Minchan Kim wrote:
> > > On Mon, Jul 29, 2019 at 10:35:15AM +0200, Michal Hocko wrote:
> > > > On Mon 29-07-19 17:20:52, Minchan Kim wrote:
> > > > > On Mon, Jul 29, 2019 at 09:45:23AM +0200, Michal Hocko wrote:
> > > > > > On Mon 29-07-19 16:10:37, Minchan Kim wrote:
> > > > > > > In our testing(carmera recording), Miguel and Wei found unmap_page_range
> > > > > > > takes above 6ms with preemption disabled easily. When I see that, the
> > > > > > > reason is it holds page table spinlock during entire 512 page operation
> > > > > > > in a PMD. 6.2ms is never trivial for user experince if RT task couldn't
> > > > > > > run in the time because it could make frame drop or glitch audio problem.
> > > > > > 
> > > > > > Where is the time spent during the tear down? 512 pages doesn't sound
> > > > > > like a lot to tear down. Is it the TLB flushing?
> > > > > 
> > > > > Miguel confirmed there is no such big latency without mark_page_accessed
> > > > > in zap_pte_range so I guess it's the contention of LRU lock as well as
> > > > > heavy activate_page overhead which is not trivial, either.
> > > > 
> > > > Please give us more details ideally with some numbers.
> > > 
> > > I had a time to benchmark it via adding some trace_printk hooks between
> > > pte_offset_map_lock and pte_unmap_unlock in zap_pte_range. The testing
> > > device is 2018 premium mobile device.
> > > 
> > > I can get 2ms delay rather easily to release 2M(ie, 512 pages) when the
> > > task runs on little core even though it doesn't have any IPI and LRU
> > > lock contention. It's already too heavy.
> > > 
> > > If I remove activate_page, 35-40% overhead of zap_pte_range is gone
> > > so most of overhead(about 0.7ms) comes from activate_page via
> > > mark_page_accessed. Thus, if there are LRU contention, that 0.7ms could
> > > accumulate up to several ms.
> > 
> > Thanks for this information. This is something that should be a part of
> > the changelog. I am sorry to still poke into this because I still do not
> 
> I will include it.
> 
> > have a full understanding of what is going on and while I do not object
> > to drop the spinlock I still suspect this is papering over a deeper
> > problem.
> 
> I couldn't come up with better solution. Feel free to suggest it.
> 
> > 
> > If mark_page_accessed is really expensive then why do we even bother to
> > do it in the tear down path in the first place? Why don't we simply set
> > a referenced bit on the page to reflect the young pte bit? I might be
> > missing something here of course.
> 
> commit bf3f3bc5e73
> Author: Nick Piggin <npiggin@suse.de>
> Date:   Tue Jan 6 14:38:55 2009 -0800
> 
>     mm: don't mark_page_accessed in fault path
> 
>     Doing a mark_page_accessed at fault-time, then doing SetPageReferenced at
>     unmap-time if the pte is young has a number of problems.
> 
>     mark_page_accessed is supposed to be roughly the equivalent of a young pte
>     for unmapped references. Unfortunately it doesn't come with any context:
>     after being called, reclaim doesn't know who or why the page was touched.
> 
>     So calling mark_page_accessed not only adds extra lru or PG_referenced
>     manipulations for pages that are already going to have pte_young ptes anyway,
>     but it also adds these references which are difficult to work with from the
>     context of vma specific references (eg. MADV_SEQUENTIAL pte_young may not
>     wish to contribute to the page being referenced).
> 
>     Then, simply doing SetPageReferenced when zapping a pte and finding it is
>     young, is not a really good solution either. SetPageReferenced does not
>     correctly promote the page to the active list for example. So after removing
>     mark_page_accessed from the fault path, several mmap()+touch+munmap() would
>     have a very different result from several read(2) calls for example, which
>     is not really desirable.

Well, I have to say that this is rather vague to me. Nick, could you be
more specific about which workloads do benefit from this change? Let's
say that the zapped pte is the only referenced one and then reclaim
finds the page on inactive list. We would go and reclaim it. But does
that matter so much? Hot pages would be referenced from multiple ptes
very likely, no?

That being said, cosindering that mark_page_accessed is not free, do we
have strong reasons to keep it?

Or do I miss something?

>     Signed-off-by: Nick Piggin <npiggin@suse.de>
>     Acked-by: Johannes Weiner <hannes@saeurebad.de>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

-- 
Michal Hocko
SUSE Labs

