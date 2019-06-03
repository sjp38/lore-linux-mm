Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC48BC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:27:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87274208CB
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:27:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="PQ5b4O2X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87274208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E8186B026D; Mon,  3 Jun 2019 13:27:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 198E96B026E; Mon,  3 Jun 2019 13:27:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0877C6B0271; Mon,  3 Jun 2019 13:27:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5FEB6B026D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:27:23 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id u1so8624974pgh.3
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:27:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=giaaUlfYCB4p9IcMpuBt2FywCr2iJGrguh6BYXiq67g=;
        b=kE6ydkbRSDCoazsvHsvJS/EBGboeSd/B91hfFwL/uGyvzzLWk/yY+FjFwHhBc1NZNW
         xJYtXsaJ9fiHS9RN8cq6mO8AuzFO9xDRtEA31yd72ChLqngbeqDPazA/m9Om3CkYBcWQ
         ioL3labbybcgGLhuDBwgN20mlNqnFPyonL27W5flWMpaRyq88cou+bxGdBPxH/A3WWnQ
         0haaS0+irGfu+Vt7Ftqw9x06reHc3YzaN/48jlHFoLH5yn1PVDC88/2XKcVINqKUfj0V
         MhnTLuiPaJRT73+WPItZtFrn88iswiXOSDn4RfgJcbIQnKx1PQBij4KGXvNnPf0xLL7l
         7VTA==
X-Gm-Message-State: APjAAAVOzPtHa2D41vbn87IiX/el52CTCLINm7w+Uyt4iG7iKO0FAAZP
	Xh6siyjVsZKUOTiLALSecksTWBA2KJdYbH+QhC21W+UDB1TcNCQuGssmzGNsww8MucN408C+0WE
	Ym4mzR2/HSBSTbRMQhmOfeNMcGB5tpowcRABbnIFUIJDMYdCk+65kxq1XNuEYSOpNpQ==
X-Received: by 2002:a63:5d54:: with SMTP id o20mr28485556pgm.97.1559582843376;
        Mon, 03 Jun 2019 10:27:23 -0700 (PDT)
X-Received: by 2002:a63:5d54:: with SMTP id o20mr28485470pgm.97.1559582842497;
        Mon, 03 Jun 2019 10:27:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559582842; cv=none;
        d=google.com; s=arc-20160816;
        b=cHs9JPq/1F8qK5qBtwAVDhmAuQhAnMsQbwGqpE7hFiHObIhivBYkNGM/ys0m0KA73z
         2YvoAS2u+muW88N1X1KIp0v/BP1s0XHV56Szlv8eYyDAntpRYWm2adGN1rTLI4oru1L4
         RaHQf53xHlc5ZfeOSUDCRPybmmkMBiEu4hGYNpW7NDQURWhdPbnzZn9w3N41f75Bz2x3
         Gdk7M7gd+l600zKM+ZGSxtTJwc8itiHPXRYHTkLv3lR5Msk/4XstaP/qfjFFU5XbUSDF
         6Bc4vg1BnV4Gb1h87EebrpD/8SRrV06PJ5HLnl5FUaHvKFlqymUPRBmOs617A1/YwnnD
         GmoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=giaaUlfYCB4p9IcMpuBt2FywCr2iJGrguh6BYXiq67g=;
        b=YxQ8T89SSStSncBF3SHzVjYkWGClCMDdeZw59jhou/vj6vb1XuCMrNbgnUJekninBd
         rFYnsxiZQbsS/SHk1CX7kJiKBaM/0mkKDtOokvIbDkVZuznP3LDiujF46KC1VS5UgGQz
         ZxTD1y4xHkVmZJzYRIJ+U+uLkcHxj57QXEE7I6LnKc+BN1MkCemPoJu0mg5iVHPVOuxd
         rEb/AgeqxKoHVILslWsWm05uLCq2W2g8eYWV1zG/A/uQjpXghmLIY4mzPMuQdu/JWvxJ
         AoWPi6d9vMild5LfwgSvWRoEXSTsbvoqEt0tpbbNmfbwSvhJ0RxsALpyze1ZLCBUNB+F
         w1Bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=PQ5b4O2X;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t10sor8305264pjv.1.2019.06.03.10.27.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 10:27:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=PQ5b4O2X;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=giaaUlfYCB4p9IcMpuBt2FywCr2iJGrguh6BYXiq67g=;
        b=PQ5b4O2XlL6OPmwtnnq6KaLa51qn9sjNwVfi0PlxHiJGJ+i7VnVu+20+W1qNQomvSl
         O3Bv5aHsJ+ipuVoMtxh+kzpSWlW4Fk3QMjP1zhFNcetUhou0CknU1EGHuroPrIz5z14C
         qXzhT/f5tH7ZDs5fLUiEx4n4L8NnZWU7fN3LdyUmT8Mxq9mRnmUApBPrT2zWXQJ0feWI
         4w3/MUVcT9pZIZJFcwZJF1GD0/TY6J7eT+huIUuMCYafpele/5qrcMQKXrkYlANL17q9
         CUPSL9cFDkj7VHokflPz+CnEZ0hF9rhqwkjU7vUo1G4IBQ9beS8fsUpGZc8+5T2/sgSJ
         Qd7g==
X-Google-Smtp-Source: APXvYqzgq4qEKaWZh0wCQxHsqzHbOHu4nbzb40a+iOcqwVisgDkpzRyOJZZvootYCQo7snWqgQqhRA==
X-Received: by 2002:a17:90a:8a10:: with SMTP id w16mr31345882pjn.133.1559582839582;
        Mon, 03 Jun 2019 10:27:19 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:9fa4])
        by smtp.gmail.com with ESMTPSA id s1sm12158354pgp.94.2019.06.03.10.27.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 10:27:18 -0700 (PDT)
Date: Mon, 3 Jun 2019 13:27:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 1/6] mm: introduce MADV_COLD
Message-ID: <20190603172717.GA30363@cmpxchg.org>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-2-minchan@kernel.org>
 <20190531084752.GI6896@dhcp22.suse.cz>
 <20190531133904.GC195463@google.com>
 <20190531140332.GT6896@dhcp22.suse.cz>
 <20190531143407.GB216592@google.com>
 <20190603071607.GB4531@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190603071607.GB4531@dhcp22.suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 09:16:07AM +0200, Michal Hocko wrote:
> On Fri 31-05-19 23:34:07, Minchan Kim wrote:
> > On Fri, May 31, 2019 at 04:03:32PM +0200, Michal Hocko wrote:
> > > On Fri 31-05-19 22:39:04, Minchan Kim wrote:
> > > > On Fri, May 31, 2019 at 10:47:52AM +0200, Michal Hocko wrote:
> > > > > On Fri 31-05-19 15:43:08, Minchan Kim wrote:
> > > > > > When a process expects no accesses to a certain memory range, it could
> > > > > > give a hint to kernel that the pages can be reclaimed when memory pressure
> > > > > > happens but data should be preserved for future use.  This could reduce
> > > > > > workingset eviction so it ends up increasing performance.
> > > > > > 
> > > > > > This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> > > > > > MADV_COLD can be used by a process to mark a memory range as not expected
> > > > > > to be used in the near future. The hint can help kernel in deciding which
> > > > > > pages to evict early during memory pressure.
> > > > > > 
> > > > > > Internally, it works via deactivating pages from active list to inactive's
> > > > > > head if the page is private because inactive list could be full of
> > > > > > used-once pages which are first candidate for the reclaiming and that's a
> > > > > > reason why MADV_FREE move pages to head of inactive LRU list. Therefore,
> > > > > > if the memory pressure happens, they will be reclaimed earlier than other
> > > > > > active pages unless there is no access until the time.
> > > > > 
> > > > > [I am intentionally not looking at the implementation because below
> > > > > points should be clear from the changelog - sorry about nagging ;)]
> > > > > 
> > > > > What kind of pages can be deactivated? Anonymous/File backed.
> > > > > Private/shared? If shared, are there any restrictions?
> > > > 
> > > > Both file and private pages could be deactived from each active LRU
> > > > to each inactive LRU if the page has one map_count. In other words,
> > > > 
> > > >     if (page_mapcount(page) <= 1)
> > > >         deactivate_page(page);
> > > 
> > > Why do we restrict to pages that are single mapped?
> > 
> > Because page table in one of process shared the page would have access bit
> > so finally we couldn't reclaim the page. The more process it is shared,
> > the more fail to reclaim.
> 
> So what? In other words why should it be restricted solely based on the
> map count. I can see a reason to restrict based on the access
> permissions because we do not want to simplify all sorts of side channel
> attacks but memory reclaim is capable of reclaiming shared pages and so
> far I haven't heard any sound argument why madvise should skip those.
> Again if there are any reasons, then document them in the changelog.

I think it makes sense. It could be explained, but it also follows
established madvise semantics, and I'm not sure it's necessarily
Minchan's job to re-iterate those.

Sharing isn't exactly transparent to userspace. The kernel does COW,
ksm etc. When you madvise, you can really only speak for your own
reference to that memory - "*I* am not using this."

This is in line with other madvise calls: MADV_DONTNEED clears the
local page table entries and drops the corresponding references, so
shared pages won't get freed. MADV_FREE clears the pte dirty bit and
also has explicit mapcount checks before clearing PG_dirty, so again
shared pages don't get freed.

