Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E7C4C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:29:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E97D208C3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:29:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E97D208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A13F56B0276; Tue, 28 May 2019 02:29:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EAB16B0278; Tue, 28 May 2019 02:29:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B2E86B027A; Tue, 28 May 2019 02:29:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3D06A6B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:29:50 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f41so31525607ede.1
        for <linux-mm@kvack.org>; Mon, 27 May 2019 23:29:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Yqr6t8w6ANxnLvbD9qo2aZfKmt5mddRVVcwXU3Mvtjg=;
        b=Ze4xc3bAl5v//0FtcWkrlH94eYBHS/SxX7qfpagrv92qxYzayY0qWBsWZsxnkW5D7c
         40mYe+KR2zCySjCZq1Q8USUOdBGJkw8CY0M3NVdgx2rMLlelgup3bEuxyAtLS6AjN7BR
         e0fAZZgFR0gVW+O5xQlrw6fvDFG6aF8w9TqHH30vbqq+ct/XddHaK8TUlnOfQUHDRYeB
         C2SYnuTVmNYe2x90z7FqQcKb6a8C1vxac+OG0boFXJLr4gHQMyNyZUrQbMHAphO2Wll/
         SruqKBcBdDRSb5pTBxonkGKZoykMqevRPYFfSNGl0GWjmTWYNRjJRyv89MFlaSlHIgKe
         55HQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXMJOpsxWdvzyWJxU+ydkzwjLelZI3hp/fUdBn/MhUW5XR+wDpF
	3s7wyirXVWn0Fv28sMVulT6YpHzsv0BwooWKZjOzwUshsbfMp7cFUy5IyNAN5vUMqZbs+5QmAyp
	s88sZ1ID2ofkJWlF7GmAIpErIpFHOjEJqsTOEsgse7M3o9rF5GGTvXub1N1DffKQ=
X-Received: by 2002:aa7:cdc1:: with SMTP id h1mr625790edw.102.1559024989825;
        Mon, 27 May 2019 23:29:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuzkTF7LsodOawkfU/ilVaWyftojZY6Yle6M1exswpqFhEzwkEL05QTW7luh/09G8V3HyD
X-Received: by 2002:aa7:cdc1:: with SMTP id h1mr625728edw.102.1559024988992;
        Mon, 27 May 2019 23:29:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559024988; cv=none;
        d=google.com; s=arc-20160816;
        b=DH9Y72qTPfAgbXbcVkAkV3/oxe0NS6Qjf0unBPGaUbOP3UBQGMdIxGFyrKngJoFvWr
         UMDWKL9jvkg3iD16tsxNvXmfbNoKmBTPC4IEMw6thyYwfAEJkI+U56Ma2Z668DHcM9ky
         yRt94oNQit1vEx7g2h2ZILYr0rsGegCn+0t9oQ+lFxLyxMH9dDEXoPNKQdActwzpBtgu
         NdPoCcIlN/4BOLRVPvd8pZ33E4EZiNdH/HbtdIwf/U3CUS7WO1Pq2UAa9WAF/uVPF9pD
         VhqDXfGPgXyC+4mSvPUZRG7vFxaMpBGx57X696Tr/HhqXX3ipo4IEwNoZmBaQ2cRY7d+
         jsmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Yqr6t8w6ANxnLvbD9qo2aZfKmt5mddRVVcwXU3Mvtjg=;
        b=Tl+O/asr4ayGR12O+RzU6TrRydIfdvaUPUChGUMFE+VFuEPMjthi9RL7/AV4hBHr60
         k3ygcQNIxf9b04W92LdZya/GDfCP3HduDVXBxnzdxrc4HWSuIIX4NppqWffDl+GptQuo
         ig8eV+jXACcqk+V3wpIoRntGoY2x0gv/+UibthHszvdx9PA0jPpkHgp5WKQ5ByXtjNbJ
         ShGE5rrJtOwURDkUMO3QEeg0kkPznN6ToUN3cbjnbbVijKVIb6DokXZcR83Q/cuzWy5c
         YGa+TLQB6o6d/Sis0BFTNX4jL2w1wC+yR6xvc3C9pXgOkshyGv67H2RYi18ShG9184QC
         uW/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t55si11124721edd.123.2019.05.27.23.29.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 23:29:48 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2B3F8AFE2;
	Tue, 28 May 2019 06:29:48 +0000 (UTC)
Date: Tue, 28 May 2019 08:29:47 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190528062947.GL1658@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-8-minchan@kernel.org>
 <20190520092801.GA6836@dhcp22.suse.cz>
 <20190521025533.GH10039@google.com>
 <20190521062628.GE32329@dhcp22.suse.cz>
 <20190527075811.GC6879@google.com>
 <20190527124411.GC1658@dhcp22.suse.cz>
 <20190528032632.GF6879@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528032632.GF6879@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 12:26:32, Minchan Kim wrote:
> On Mon, May 27, 2019 at 02:44:11PM +0200, Michal Hocko wrote:
> > On Mon 27-05-19 16:58:11, Minchan Kim wrote:
> > > On Tue, May 21, 2019 at 08:26:28AM +0200, Michal Hocko wrote:
> > > > On Tue 21-05-19 11:55:33, Minchan Kim wrote:
> > > > > On Mon, May 20, 2019 at 11:28:01AM +0200, Michal Hocko wrote:
> > > > > > [cc linux-api]
> > > > > > 
> > > > > > On Mon 20-05-19 12:52:54, Minchan Kim wrote:
> > > > > > > System could have much faster swap device like zRAM. In that case, swapping
> > > > > > > is extremely cheaper than file-IO on the low-end storage.
> > > > > > > In this configuration, userspace could handle different strategy for each
> > > > > > > kinds of vma. IOW, they want to reclaim anonymous pages by MADV_COLD
> > > > > > > while it keeps file-backed pages in inactive LRU by MADV_COOL because
> > > > > > > file IO is more expensive in this case so want to keep them in memory
> > > > > > > until memory pressure happens.
> > > > > > > 
> > > > > > > To support such strategy easier, this patch introduces
> > > > > > > MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER options in madvise(2) like
> > > > > > > that /proc/<pid>/clear_refs already has supported same filters.
> > > > > > > They are filters could be Ored with other existing hints using top two bits
> > > > > > > of (int behavior).
> > > > > > 
> > > > > > madvise operates on top of ranges and it is quite trivial to do the
> > > > > > filtering from the userspace so why do we need any additional filtering?
> > > > > > 
> > > > > > > Once either of them is set, the hint could affect only the interested vma
> > > > > > > either anonymous or file-backed.
> > > > > > > 
> > > > > > > With that, user could call a process_madvise syscall simply with a entire
> > > > > > > range(0x0 - 0xFFFFFFFFFFFFFFFF) but either of MADV_ANONYMOUS_FILTER and
> > > > > > > MADV_FILE_FILTER so there is no need to call the syscall range by range.
> > > > > > 
> > > > > > OK, so here is the reason you want that. The immediate question is why
> > > > > > cannot the monitor do the filtering from the userspace. Slightly more
> > > > > > work, all right, but less of an API to expose and that itself is a
> > > > > > strong argument against.
> > > > > 
> > > > > What I should do if we don't have such filter option is to enumerate all of
> > > > > vma via /proc/<pid>/maps and then parse every ranges and inode from string,
> > > > > which would be painful for 2000+ vmas.
> > > > 
> > > > Painful is not an argument to add a new user API. If the existing API
> > > > suits the purpose then it should be used. If it is not usable, we can
> > > > think of a different way.
> > > 
> > > I measured 1568 vma parsing overhead of /proc/<pid>/maps in ARM64 modern
> > > mobile CPU. It takes 60ms and 185ms on big cores depending on cpu governor.
> > > It's never trivial.
> > 
> > This is not the only option. Have you tried to simply use
> > /proc/<pid>/map_files interface? This will provide you with all the file
> > backed mappings.
> 
> I compared maps vs. map_files with 3036 file-backed vma.
> Test scenario is to dump all of vmas of the process and parse address
> ranges.
> For map_files, it's easy to parse each address range because directory name
> itself is range. However, in case of maps, I need to parse each range
> line by line so need to scan all of lines.
> 
> (maps cover additional non-file-backed vmas so nr_vma is a little bigger)
> 
> performance mode:
> map_files: nr_vma 3036 usec 13387
> maps     : nr_vma 3078 usec 12923
> 
> powersave mode:
> 
> map_files: nr_vma 3036 usec 52614
> maps     : nr_vma 3078 usec 41089
> 
> map_files is slower than maps if we dump all of vmas. I guess directory
> operation needs much more jobs(e.g., dentry lookup, instantiation)
> compared to maps.

OK, that is somehow surprising. I am still not convinced the filter is a
good idea though. The primary reason is that it encourages using madvise
on a wide range without having a clue what the range contains. E.g. the
full address range and rely the right thing will happen. Do we really
want madvise to operate in that mode?

Btw. if we went with the per vma fd approach then you would get this
feature automatically because map_files would refer to file backed
mappings while map_anon could refer only to anonymous mappings.

-- 
Michal Hocko
SUSE Labs

