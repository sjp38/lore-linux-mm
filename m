Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 306EAC32750
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 15:07:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D976820665
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 15:07:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="mUXTUC7C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D976820665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 612E06B000D; Mon, 12 Aug 2019 11:07:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C3656B000E; Mon, 12 Aug 2019 11:07:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B1D86B0010; Mon, 12 Aug 2019 11:07:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0183.hostedemail.com [216.40.44.183])
	by kanga.kvack.org (Postfix) with ESMTP id 251726B000D
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 11:07:31 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C0F54180AD7C1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:07:30 +0000 (UTC)
X-FDA: 75814104660.30.voice00_417e8da9cf65d
X-HE-Tag: voice00_417e8da9cf65d
X-Filterd-Recvd-Size: 9859
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:07:29 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id b13so49832364pfo.1
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 08:07:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=FfJCpjysQVbS87yDleV9efBJ62H70bVd8lRpyhmGjiA=;
        b=mUXTUC7CkMBCbbdOgWd22eOoshLbMwoFMoQp4tY2RQgykV8jAxvOkDHlG90thkP0F2
         Lh63qquLYhRU43BqWJtg/mZWx0933vd1hoWixjmZyv2RbLGrHQEVr8QnOKuVcgstRLl4
         pDP3R2EByEFiYfXTDQbBG4sgYerLUH7/EGHZmqzhi7ifawDhF6MugPaY4v3BAV8v6mLy
         q9EY11iwePPr9MJFAOcEaxFqa7ZHV0oTl0wezEUIm2mYoGkFyY5uwAKHO8vOWACR3bFT
         FDbDRUay8rQkx/TrMOUuFwLrxIRD3bU+qVN+BmxcFqIdvXDNCPI1Dz2NoLfStDc+ULVA
         FzXA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=FfJCpjysQVbS87yDleV9efBJ62H70bVd8lRpyhmGjiA=;
        b=dASkXApA55EPiWkMFr1avEZujmLfBbaC6QeFd0aXKgvQOTK5RgKiVVnZcN0guLQTjH
         AWR7WSjmErig+bcnxE67v6uu9Wd59Ek9p0I/vj0DAaQT44eZfBNyKu/jg3uXo1IPfNcW
         X+eOvUVg855NjQ2O7yoyQUke315uIp6Mi9uukS25zEpTpDaIDKc8gIKbaaxsYOVqE7uB
         aPEmxX80Stz3fcV6IhTV/fwEZUrrl9dXNZRS+W2bKCRC+nLqOZjmPco0tPRb/WHDxMHG
         Jg1s8RHRI4rCGahH3xU1POQ3upi4Rnl9/uMWnYx5V6C/Ktb5tZnmlywXydnRHiJWphIj
         Qj9g==
X-Gm-Message-State: APjAAAWHTnJ9Id7vfLgn5AhKKeXhw3iLd2TtM8Fr6txSnT/46L5e84WX
	OhWSOORABtE/OJwQAE9h9OadgiMH88Y=
X-Google-Smtp-Source: APXvYqyFnO5i7orfiNCFIgJ8d4gkhfqZkqY3IMYxdxP0CAlBa1w7YwP0CoonnHUoO6Y/TBeiqGg9EA==
X-Received: by 2002:a63:c64b:: with SMTP id x11mr30441310pgg.319.1565622448538;
        Mon, 12 Aug 2019 08:07:28 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::5810])
        by smtp.gmail.com with ESMTPSA id e6sm6079914pfl.37.2019.08.12.08.07.27
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 12 Aug 2019 08:07:27 -0700 (PDT)
Date: Mon, 12 Aug 2019 11:07:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC PATCH] mm: drop mark_page_access from the unmap path
Message-ID: <20190812150725.GA3684@cmpxchg.org>
References: <20190730121110.GA184615@google.com>
 <20190730123237.GR9330@dhcp22.suse.cz>
 <20190730123935.GB184615@google.com>
 <20190730125751.GS9330@dhcp22.suse.cz>
 <20190731054447.GB155569@google.com>
 <20190731072101.GX9330@dhcp22.suse.cz>
 <20190806105509.GA94582@google.com>
 <20190809124305.GQ18351@dhcp22.suse.cz>
 <20190809183424.GA22347@cmpxchg.org>
 <20190812080947.GA5117@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812080947.GA5117@dhcp22.suse.cz>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 10:09:47AM +0200, Michal Hocko wrote:
> On Fri 09-08-19 14:34:24, Johannes Weiner wrote:
> > On Fri, Aug 09, 2019 at 02:43:24PM +0200, Michal Hocko wrote:
> > > On Tue 06-08-19 19:55:09, Minchan Kim wrote:
> > > > On Wed, Jul 31, 2019 at 09:21:01AM +0200, Michal Hocko wrote:
> > > > > On Wed 31-07-19 14:44:47, Minchan Kim wrote:
> > > [...]
> > > > > > As Nick mentioned in the description, without mark_page_accessed in
> > > > > > zapping part, repeated mmap + touch + munmap never acticated the page
> > > > > > while several read(2) calls easily promote it.
> > > > > 
> > > > > And is this really a problem? If we refault the same page then the
> > > > > refaults detection should catch it no? In other words is the above still
> > > > > a problem these days?
> > > > 
> > > > I admit we have been not fair for them because read(2) syscall pages are
> > > > easily promoted regardless of zap timing unlike mmap-based pages.
> > > > 
> > > > However, if we remove the mark_page_accessed in the zap_pte_range, it
> > > > would make them more unfair in that read(2)-accessed pages are easily
> > > > promoted while mmap-based page should go through refault to be promoted.
> > > 
> > > I have really hard time to follow why an unmap special handling is
> > > making the overall state more reasonable.
> > > 
> > > Anyway, let me throw the patch for further discussion. Nick, Mel,
> > > Johannes what do you think?
> > > 
> > > From 3821c2e66347a2141358cabdc6224d9990276fec Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.com>
> > > Date: Fri, 9 Aug 2019 14:29:59 +0200
> > > Subject: [PATCH] mm: drop mark_page_access from the unmap path
> > > 
> > > Minchan has noticed that mark_page_access can take quite some time
> > > during unmap:
> > > : I had a time to benchmark it via adding some trace_printk hooks between
> > > : pte_offset_map_lock and pte_unmap_unlock in zap_pte_range. The testing
> > > : device is 2018 premium mobile device.
> > > :
> > > : I can get 2ms delay rather easily to release 2M(ie, 512 pages) when the
> > > : task runs on little core even though it doesn't have any IPI and LRU
> > > : lock contention. It's already too heavy.
> > > :
> > > : If I remove activate_page, 35-40% overhead of zap_pte_range is gone
> > > : so most of overhead(about 0.7ms) comes from activate_page via
> > > : mark_page_accessed. Thus, if there are LRU contention, that 0.7ms could
> > > : accumulate up to several ms.
> > > 
> > > bf3f3bc5e734 ("mm: don't mark_page_accessed in fault path") has replaced
> > > SetPageReferenced by mark_page_accessed arguing that the former is not
> > > sufficient when mark_page_accessed is removed from the fault path
> > > because it doesn't promote page to the active list. It is true that a
> > > page that is mapped by a single process might not get promoted even when
> > > referenced if the reclaim checks it after the unmap but does that matter
> > > that much? Can we cosider the page hot if there are no other
> > > users? Moreover we do have workingset detection in place since then and
> > > so a next refault would activate the page if it was really hot one.
> > 
> > I do think the pages can be very hot. Think of short-lived executables
> > and their libraries. Like shell commands. When they run a few times or
> > periodically, they should be promoted to the active list and not have
> > to compete with streaming IO on the inactive list - the PG_referenced
> > doesn't really help them there, see page_check_references().
> 
> Yeah, I am aware of that. We do rely on more processes to map the page
> which I've tried to explain in the changelog.
> 
> Btw. can we promote PageReferenced pages with zero mapcount? I am
> throwing that more as an idea because I haven't really thought that
> through yet.

That flag implements a second-chance policy, see this commit:

commit 645747462435d84c6c6a64269ed49cc3015f753d
Author: Johannes Weiner <hannes@cmpxchg.org>
Date:   Fri Mar 5 13:42:22 2010 -0800

    vmscan: detect mapped file pages used only once

We had an application that would checksum large files using mmapped IO
to avoid double buffering. The VM used to activate mapped cache
directly, and it trashed the actual workingset.

In response I added support for use-once mapped pages using this flag.
SetPageReferenced signals the VM that we're not sure about the page
yet and give it another round trip on the LRU.

If you activate on this flag, it would restore the initial problem of
use-once pages trashing the workingset.

> > Maybe the refaults will be fine - but latency expectations around
> > mapped page cache certainly are a lot higher than unmapped cache.
> >
> > So I'm a bit reluctant about this patch. If Minchan can be happy with
> > the lock batching, I'd prefer that.
> 
> Yes, it seems that the regular lock drop&relock helps in Minchan's case
> but this is a kind of change that might have other subtle side effects.
> E.g. will-it-scale has noticed a regression [1], likely because the
> critical section is shorter and the overal throughput of the operation
> decreases. Now, the w-i-s is an artificial benchmark so I wouldn't lose
> much sleep over it normally but we have already seen real regressions
> when the locking pattern has changed in the past so I would by a bit
> cautious.

I'm much more concerned about fundamentally changing the aging policy
of mapped page cache then about the lock breaking scheme. With locking
we worry about CPU effects; with aging we worry about additional IO.

> As I've said, this RFC is mostly to open a discussion. I would really
> like to weigh the overhead of mark_page_accessed and potential scenario
> when refaults would be visible in practice. I can imagine that a short
> lived statically linked applications have higher chance of being the
> only user unlike libraries which are often being mapped via several
> ptes. But the main problem to evaluate this is that there are many other
> external factors to trigger the worst case.

We can discuss the pros and cons, but ultimately we simply need to
test it against real workloads to see if changing the promotion rules
regresses the amount of paging we do in practice.

