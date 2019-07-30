Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71BF7C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:48:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35114206B8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:48:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35114206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF83D8E0003; Tue, 30 Jul 2019 11:48:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA9138E0001; Tue, 30 Jul 2019 11:48:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A71198E0003; Tue, 30 Jul 2019 11:48:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5BA7E8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 11:48:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id a5so40597005edx.12
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:48:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6w+3KE675kCWzjT8oHgKhFVrXzFlaZnT0bqlvIZwwTU=;
        b=HR+4BN5xfXVxK5qfX5I3+uo8r1xjPcJYBejMxPv4d0dh/l9RnYaHqNKRp5xsVZKbLO
         xKAE9HYWt+g0mAQd2dLnhSlL0bCjoJmCT2X3vV1OvLlBJRX71HCrDH7ddvfDTIxobErN
         e2PkLWjZBbwPTsfhh2vp5vnvZGHtCF0J+1LsImthFBnWSlv/FbReTaoALRaishdcLF8d
         xlnpDxrMRmQ6Xbe78drqUYvpK172GcP34vDWJvjkoB9drjxwbuy5WS11W5TiwY+pnwjU
         ofa1ohntzD4U/VCGobAz10mb2gTf0JN8TOZT7mPkQfs4gG8Go32YN8iSgMaP93esA94z
         Mv3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAUCcQXb2dHlgbscE5Ld32chYMGQlQjmKqPBQOM1QzH/m8Ne56Jt
	6rkB7S9vbEEjJTSzCAheYhK4hs7KYH/8qfs8DiXh+cN5I9cSCzRUG8r1TtQ+CRoQvP9pSiQQWYv
	NdVeuwTv/awRWZXL7OL7f5B8xeKya3AKsh1ZlANiXph31LTvE6L4KnyvAKD/QLvYpZA==
X-Received: by 2002:a50:9947:: with SMTP id l7mr103468311edb.305.1564501736935;
        Tue, 30 Jul 2019 08:48:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWzskNzSajasdLAa4xGiI05vmVQlIUKdbVWPCdgy5F9kepcEOEU1Ce3R1r1TUutLt+VL32
X-Received: by 2002:a50:9947:: with SMTP id l7mr103468254edb.305.1564501736181;
        Tue, 30 Jul 2019 08:48:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564501736; cv=none;
        d=google.com; s=arc-20160816;
        b=G3PMwyOuuyPFSdpvrITDUKEWTp/lg0QaERdcLcsoQ5k/I39of2QWwGNs4szslzQllR
         clMHGaZfssUSk2YOlGajiJKnu741pzPp6c7atxJ5N2514JypkwKlCaZTIDMSa+p3T8kY
         nFSIVT0vQmuwYC8z9+L7DwIdQwML+5X6Y7l2637/F2fJnkKhRhBYaqBrjm/5n/2CqiV4
         cyrPlRd8EA3yvtkoP3dGkpHLBx3BQWcDkXoP9zYo2mMx5epmNRNzzk2Ih+MFuGphqIab
         ONRf9sWwG7vU7Fzn3spq+hEnAmuv9jjQk8lAS8VHLu+1eDaNFc/j5gjB3fU5MazkQz/w
         6PRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6w+3KE675kCWzjT8oHgKhFVrXzFlaZnT0bqlvIZwwTU=;
        b=DWx6MUpqYwENnLTtMJ3Yh16cb6FP11FSuMAL1SjZ35Ki1AJd73rHDDpWdc8revBXb0
         MU0LNghkQxAIuj3IRi9UiXFg40Uc5btiREWMumH/lCcN+TZUN/DFu5S88o94Dax2T942
         w8XNa7w5m5UO68zesCrYkSZAM+03e89mbZgno01lX0XKcsnQXcKHe0BVhYFNNE+7LRYh
         8hfV2rM9lDvG3lmCl5Y9h6A4LRiPc6RXYzMxptb7robRFAsLdgdufZOHaN6b0TP/OAge
         z97gkV0D7khTc+QGD8lCHgYk92T7G4ovOwRvi8/yWJ4AKuyqzBm8u1FPwCsQ8mNobWMv
         0jUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b43si18807367edd.433.2019.07.30.08.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 08:48:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7F5EEB024;
	Tue, 30 Jul 2019 15:48:55 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 039991E435C; Tue, 30 Jul 2019 17:48:55 +0200 (CEST)
Date: Tue, 30 Jul 2019 17:48:54 +0200
From: Jan Kara <jack@suse.cz>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@kernel.dk>,
	Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 1/2] mm/filemap: don't initiate writeback if mapping has
 no dirty pages
Message-ID: <20190730154854.GG28829@quack2.suse.cz>
References: <156378816804.1087.8607636317907921438.stgit@buzz>
 <20190722175230.d357d52c3e86dc87efbd4243@linux-foundation.org>
 <bdc6c53d-a7bb-dcc4-20ba-6c7fa5c57dbd@yandex-team.ru>
 <20190730141457.GE28829@quack2.suse.cz>
 <51ba7304-06bd-a50d-cb14-6dc41b92fab5@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51ba7304-06bd-a50d-cb14-6dc41b92fab5@yandex-team.ru>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 30-07-19 17:57:18, Konstantin Khlebnikov wrote:
> On 30.07.2019 17:14, Jan Kara wrote:
> > On Tue 23-07-19 11:16:51, Konstantin Khlebnikov wrote:
> > > On 23.07.2019 3:52, Andrew Morton wrote:
> > > > 
> > > > (cc linux-fsdevel and Jan)
> > 
> > Thanks for CC Andrew.
> > 
> > > > On Mon, 22 Jul 2019 12:36:08 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:
> > > > 
> > > > > Functions like filemap_write_and_wait_range() should do nothing if inode
> > > > > has no dirty pages or pages currently under writeback. But they anyway
> > > > > construct struct writeback_control and this does some atomic operations
> > > > > if CONFIG_CGROUP_WRITEBACK=y - on fast path it locks inode->i_lock and
> > > > > updates state of writeback ownership, on slow path might be more work.
> > > > > Current this path is safely avoided only when inode mapping has no pages.
> > > > > 
> > > > > For example generic_file_read_iter() calls filemap_write_and_wait_range()
> > > > > at each O_DIRECT read - pretty hot path.
> > 
> > Yes, but in common case mapping_needs_writeback() is false for files you do
> > direct IO to (exactly the case with no pages in the mapping). So you
> > shouldn't see the overhead at all. So which case you really care about?
> > 
> > > > > This patch skips starting new writeback if mapping has no dirty tags set.
> > > > > If writeback is already in progress filemap_write_and_wait_range() will
> > > > > wait for it.
> > > > > 
> > > > > ...
> > > > > 
> > > > > --- a/mm/filemap.c
> > > > > +++ b/mm/filemap.c
> > > > > @@ -408,7 +408,8 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
> > > > >    		.range_end = end,
> > > > >    	};
> > > > > -	if (!mapping_cap_writeback_dirty(mapping))
> > > > > +	if (!mapping_cap_writeback_dirty(mapping) ||
> > > > > +	    !mapping_tagged(mapping, PAGECACHE_TAG_DIRTY))
> > > > >    		return 0;
> > > > >    	wbc_attach_fdatawrite_inode(&wbc, mapping->host);
> > > > 
> > > > How does this play with tagged_writepages?  We assume that no tagging
> > > > has been performed by any __filemap_fdatawrite_range() caller?
> > > > 
> > > 
> > > Checking also PAGECACHE_TAG_TOWRITE is cheap but seems redundant.
> > > 
> > > To-write tags are supposed to be a subset of dirty tags:
> > > to-write is set only when dirty is set and cleared after starting writeback.
> > > 
> > > Special case set_page_writeback_keepwrite() which does not clear to-write
> > > should be for dirty page thus dirty tag is not going to be cleared either.
> > > Ext4 calls it after redirty_page_for_writepage()
> > > XFS even without clear_page_dirty_for_io()
> > > 
> > > Anyway to-write tag without dirty tag or at clear page is confusing.
> > 
> > Yeah, TOWRITE tag is intended to be internal to writepages logic so your
> > patch is fine in that regard. Overall the patch looks good to me so I'm
> > just wondering a bit about the motivation...
> 
> In our case file mixes cached pages and O_DIRECT read. Kind of database
> were index header is memory mapped while the rest data read via O_DIRECT.
> I suppose for sharing index between multiple instances.

OK, that has always been a bit problematic but you're not the first one to
have such design ;). So feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

to your patch.

> On this path we also hit this bug:
> https://lore.kernel.org/lkml/156355839560.2063.5265687291430814589.stgit@buzz/
> so that's why I've started looking into this code.

I see. OK.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

