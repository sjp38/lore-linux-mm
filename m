Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A971C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 22:20:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20268206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 22:20:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20268206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6996C8E0003; Wed, 31 Jul 2019 18:20:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64A248E0001; Wed, 31 Jul 2019 18:20:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5392F8E0003; Wed, 31 Jul 2019 18:20:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1DAEF8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 18:20:24 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h27so44145508pfq.17
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 15:20:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=M50of4IbCpESvALNxtuKZjwVjl8N+p2Dijpq5DqtyNo=;
        b=ccfMa6RJqtFjhbf8+XZ508p5IXC7L3oAcagiBlHWJUN0uBikFR5HAzis06D8N+yaCd
         sRqj6RZInrFkDW7qlBINDvb87hmw3hqXxIp7WoDufnDqwp401pgMXDjP92RaYmrDwSQU
         0TcxLIpJMsPaLXyzVaGAFdTqbbcUV34j2CyoGz37UuoZra+k7qBHCpPSWWutAslVKcn7
         +TcxJ7xefwWtxwUzi2zP6INaVyf+dPmCkPlFUw4GVgSSaAFC6PU3Z1nXVLKOPk2LlyS6
         ZJ/Q5Zz2uMHp/K9YHohKzSRUjEX90kIKBkIfcYIPjBvlgWuHKrsu8prcFkFevyKjH4ZQ
         qG0w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWCYjfv545PrGoRcYzhRib4h06fpEmxx6RuszaLJiDdN+sdiQYF
	pmbRSzmFbW1RuWytyKYug9gcX5HaItqUzJiKd83OTGu9tx82TgZZszgSFZVH60EIltGVW1wA4Fr
	4DBImK8UhH3LHbkJ7YdQbDZ4zSFvltTRH6C5edsnHWe9Y+UPg5pMYH0BwnNoH+cs=
X-Received: by 2002:a17:90a:c588:: with SMTP id l8mr5062526pjt.16.1564611623554;
        Wed, 31 Jul 2019 15:20:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTwcyZHXJUwbXtqEvDQkkiDJphGzkqX12kDJmqFf/kDrQgQRRMdHFoJwtcoFzVcOQW/qyB
X-Received: by 2002:a17:90a:c588:: with SMTP id l8mr5062460pjt.16.1564611622406;
        Wed, 31 Jul 2019 15:20:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564611622; cv=none;
        d=google.com; s=arc-20160816;
        b=fUD2fWUcqLSTLpGRjO/zrAlvsMb32h1gdI5eLxNJH+8riNd5DIp2O+KwrTNHXXVvHg
         bllx7JGhW9PQNKfxWAja8g0rwTVscvBeUujIZ2Vwf4foxpNZ5+PsyaD2LtTkQ/p12AQz
         JZ6s6PZ2O06I725eRaC182s1q8Zv9qHh3NREmxWGtDBIPfmCHaQSyIcBbr3MQ/urP5Ys
         BptxsFMOHRLUYPVQ3lz9B9KmBbK8TrRIqpT/+ixRS1VOMC34onjFKYVG97eO4msrozX+
         sPY8+f36KmFSo7s9s2UMa9VhximEhYfo331cZxVU9XZoJAp/UIaQFRqe3vexyBs0LUoV
         VBtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=M50of4IbCpESvALNxtuKZjwVjl8N+p2Dijpq5DqtyNo=;
        b=hjGAwx7LQq/aku4j73G9uBBXbVYxcC0HIvQNJSJtN4lxiA3POn3fF6yOFhltnFOAMc
         JoGcXO5BmZ8UHTgH8KuqDzPq1Q+ZjU7pA6kY1CV7e0/T4/NUJy2MI59LhM8yfRXC/2z5
         /YHpa9b+b++Y/4Rqjy8n0vJkXBerLOY8tQZM1t2FcUaxDZA5SRvzkMfvZiMsSbcH4q9L
         7iC7lG3iLLSooWqwbMxAqN7abdWatPKaDZJ/m/HgAP2l2hJQTvld9zt1ZKdcgvq1N+xA
         jyxIjh/b8wYIPJvU56F0A3rrH3z9u3ejvG4wgQdOuR44IOLddabIpWL6EXAq5QE4EE6M
         BJLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id d9si35038964pgv.577.2019.07.31.15.20.21
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 15:20:22 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id BE57336111A;
	Thu,  1 Aug 2019 08:20:18 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hswwB-00027e-CG; Thu, 01 Aug 2019 08:19:11 +1000
Date: Thu, 1 Aug 2019 08:19:11 +1000
From: Dave Chinner <david@fromorbit.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: William Kucharski <william.kucharski@oracle.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Song Liu <songliubraving@fb.com>,
	Bob Kasten <robert.a.kasten@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Chad Mynhier <chad.mynhier@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: Re: [PATCH v3 0/2] mm,thp: Add filemap_huge_fault() for THP
Message-ID: <20190731221911.GA7689@dread.disaster.area>
References: <20190731082513.16957-1-william.kucharski@oracle.com>
 <20190731102053.GZ7689@dread.disaster.area>
 <20190731113221.GE4700@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731113221.GE4700@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=7-415B0cAAAA:8 a=1UT5xkaULuNUDC-A2zkA:9 a=0OXPVnBbH5FFKjg_:21
	a=0NBTTMARi36R3mQB:21 a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 04:32:21AM -0700, Matthew Wilcox wrote:
> On Wed, Jul 31, 2019 at 08:20:53PM +1000, Dave Chinner wrote:
> > On Wed, Jul 31, 2019 at 02:25:11AM -0600, William Kucharski wrote:
> > > This set of patches is the first step towards a mechanism for automatically
> > > mapping read-only text areas of appropriate size and alignment to THPs
> > > whenever possible.
> > > 
> > > For now, the central routine, filemap_huge_fault(), amd various support
> > > routines are only included if the experimental kernel configuration option
> > > 
> > > 	RO_EXEC_FILEMAP_HUGE_FAULT_THP
> > > 
> > > is enabled.
> > > 
> > > This is because filemap_huge_fault() is dependent upon the
> > > address_space_operations vector readpage() pointing to a routine that will
> > > read and fill an entire large page at a time without poulluting the page
> > > cache with PAGESIZE entries
> > 
> > How is the readpage code supposed to stuff a THP page into a bio?
> > 
> > i.e. Do bio's support huge pages, and if not, what is needed to
> > stuff a huge page in a bio chain?
> 
> I believe that the current BIO code (after Ming Lei's multipage patches
> from late last year / earlier this year) is capable of handling a
> PMD-sized page.
> 
> > Once you can answer that question, you should be able to easily
> > convert the iomap_readpage/iomap_readpage_actor code to support THP
> > pages without having to care about much else as iomap_readpage()
> > is already coded in a way that will iterate IO over the entire THP
> > for you....
> 
> Christoph drafted a patch which illustrates the changes needed to the
> iomap code.  The biggest problem is:
> 
> struct iomap_page {
>         atomic_t                read_count;
>         atomic_t                write_count;
>         DECLARE_BITMAP(uptodate, PAGE_SIZE / 512);
> };
> 
> All of a sudden that needs to go from a single unsigned long bitmap (or
> two on 64kB page size machines) to 512 bytes on x86 and even larger on,
> eg, POWER.

The struct iomap_page is dynamically allocated, so the bitmap itself
can be sized appropriate to the size of the page the structure is
being allocated for. The current code is simple because we have a
bound PAGE_SIZE so the structure size is always small.

Making it dynamically sized would also reduce the size of the bitmap
because it only needs to track filesystem blocks, not sectors. The
fact it is hard coded means it has to support the worst case of
tracking uptodata state for 512 byte block sizes, hence the "128
bits on 64k pages" static size.

i.e. huge pages on a 4k block size filesystem only requires 512
*bits* for a 2MB page, not 512 * 8 bits.  And when I get back to the
64k block size on 4k page size support for XFS+iomap, that will go
down even further. i.e. the huge page will only have to track 32
filesystem blocks, not 512, and we're back to fitting in the
existing static iomap_page....

So, yeah, I think the struct iomap_page needs to be dynamically
sized to support 2MB (or larger) pages effectively.

/me wonders what is necessary for page invalidation to work
correctly for these huge pages. e.g. someone does a direct IO
write to a range within a cached read only huge page....

Which reminds me, I bet there are assumptions in some of the iomap
code (or surrounding filesystem code) that assume if filesystem
block size = PAGE_SIZE there will be no iomap_page attached to the
page. And that if there is a iomap_page attached, then the block
size is < PAGE_SIZE. And do't make assumptions about block size
being <= PAGE_SIZE, as I have a patchset to support block size >
PAGE_SIZE for the iomap and XFS code which I'll be getting back to
Real Soon.

> It's egregious because no sane filesystem is going to fragment a PMD
> sized page into that number of discontiguous blocks,

It's not whether a sane filesytem will do that, the reality is that
it can happen and so it needs to work. Anyone using 512 byte block
size filesysetms and expecting PMD sized pages to be *efficient* has
rocks in their head. We just need to make it work.

> so we never need
> to allocate the 520 byte data structure this suddenly becomes.  It'd be
> nice to have a more efficient data structure (maybe that tracks uptodate
> by extent instead of by individual sector?)

Extents can still get fragmented, and we have to support the worst
case fragmentation that can occur. Which is single filesystem
blocks. And that fragmentation can change during the life of the
page (punch out blocks, allocate different ones, COW, etc) so we
have to allocate the worst case up front even if we rarely (if
ever!) need it.

> But I don't understand the
> iomap layer at all, and I never understood buggerheads, so I don't have
> a useful contribution here.

iomap is a whole lot easier - the only thing we need to track at the
"page cache" level is which parts of the page contain valid data and
that's what the struct iomap_page is for when more than one bit of
uptodate information needs to be stored. the iomap infrastructure
does everything else through the filesystem and so only requires the
caching layer to track the valid data ranges in each page...

IOWs, all we need to worry about for PMD faults in iomap is getting
the page sizes right, iterating IO ranges to fill/write back full
PMD pages and tracking uptodate state in the page on a filesystem
block granularity. Everything else should just work....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

