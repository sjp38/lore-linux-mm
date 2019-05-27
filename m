Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48E3CC07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 12:44:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CEA42075E
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 12:44:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CEA42075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 961A26B027F; Mon, 27 May 2019 08:44:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 911B36B0280; Mon, 27 May 2019 08:44:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 801D76B0281; Mon, 27 May 2019 08:44:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 320316B027F
	for <linux-mm@kvack.org>; Mon, 27 May 2019 08:44:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r5so27834063edd.21
        for <linux-mm@kvack.org>; Mon, 27 May 2019 05:44:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=86mikesk5y0hLJuq7PF255VU6jtdry0Ee9rsgjOZ6sc=;
        b=IuM7ZUgfY8KYcVMi7LjdNu07aUG2VJUUesPAwUwfzJOIOrks01c4Htv4C6NQLF8yn5
         aHmIjaMugyQ7bkWisYcEr05st2vLnatbP0j2vmpH0fwAVNwQ/2Ll1YahRKDN0j7PZ0Rm
         3e5r6yhe9TjklBIdrlqD5Y9Y9G+GyHy0VscXRGq7L7arFSerwL3xXiRk8NRW2f0VRJrA
         QfEARGbWBG6gzpAGDljwNBlh6UPPdUk8/CPJS3yGvM9tShySfkJQj4ORqxBzlJbq03sV
         6pcaTYupc1mOYeUmj5UBnUFKzskYqOA7ChsIOVZlXmM54f+WfrZFPwH0k5uwlEw125QN
         Zgkw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXlWszc3y3okN+8x7bP1ElL+VBtkLPWo2YicuYiLLWnNaEiWfld
	y0tlttCNRIXlgLIk3DdMyxftxlTHSmkvdtNZKcuGbvZ7uR4SLTCfhrxD1OoTztRQ95Op9yiyYVD
	/Y9ubEADvuWYMpeClw78huB3tOPtlxJcPq+VmjCpAJNRInmM3dj7f7DgqUT/VFf4=
X-Received: by 2002:a17:906:1d16:: with SMTP id n22mr94231580ejh.237.1558961054749;
        Mon, 27 May 2019 05:44:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2ifznDzjk5soCk4ZEaFHHVq3OcRP/q1v3YIwui/tolfIrSn2xn5r49sB5Xuf7IcbsRqF4
X-Received: by 2002:a17:906:1d16:: with SMTP id n22mr94231512ejh.237.1558961053868;
        Mon, 27 May 2019 05:44:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558961053; cv=none;
        d=google.com; s=arc-20160816;
        b=duaHFrBGHpF5NFhMknIPQZixA9018YqeR7n6D5E8GUadv5SVerFq+ayjtaCGeFdBun
         rPMeVcCp5F/d5aDjkYMTeypNnWSRIOwWLk3vRJ6RpnoVdRn4sxtQ0kvwmzrtPdE+RXks
         GrZAxC9hTmrU1ulj6dYBM9rkl6KpLSQy+s65WZhl9AkOti3GDgrfeAKlYEvRuEWmtUAk
         bh9g7DEaGxVw12KsSfhNq8xkpYK48mVu5nMY9s7npL6N2P01fJkze2n/qCXC+fZHspwx
         CpTdRhYI1MyXTrVjpNpbJmm42C6w0qXcBpyiX5/g7lQBLJkg3y6pUlNYcxRG1QmEDL4R
         CAtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=86mikesk5y0hLJuq7PF255VU6jtdry0Ee9rsgjOZ6sc=;
        b=TNZLhFCe0oi9MJ52oQZGz8SA5j+HWGuqM93YfYhr6KXL/dUmqFsdPy/OGwFKBPhlyB
         msCyRN5C0h0TvPM9KCo5VhbjdrkDNdBwgq7W6TRTAr14HGYHLqML3PanWyCexOlARc/z
         MmLczAMxfrKAGExG2ZF/1s9CMkAOlHTjKJwWhy3ULbKdCL03fT1I59toMNU2iGTrZmdw
         ur8wwWhefK02SL0rsLnk3B2h1G4GGKwIo01+XY75YhOlgmsD12tf2tjX+eX0WtSMvur9
         tdJ6Zdopew+/e9xtsHJ/7DfGBhqq9iG1RlSHLXTMW1Z8sz0ftD3BrTbh2WTeCod+7EH6
         qwrg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f49si2961332eda.354.2019.05.27.05.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 05:44:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 21369ADE3;
	Mon, 27 May 2019 12:44:13 +0000 (UTC)
Date: Mon, 27 May 2019 14:44:11 +0200
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
Message-ID: <20190527124411.GC1658@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-8-minchan@kernel.org>
 <20190520092801.GA6836@dhcp22.suse.cz>
 <20190521025533.GH10039@google.com>
 <20190521062628.GE32329@dhcp22.suse.cz>
 <20190527075811.GC6879@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527075811.GC6879@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 27-05-19 16:58:11, Minchan Kim wrote:
> On Tue, May 21, 2019 at 08:26:28AM +0200, Michal Hocko wrote:
> > On Tue 21-05-19 11:55:33, Minchan Kim wrote:
> > > On Mon, May 20, 2019 at 11:28:01AM +0200, Michal Hocko wrote:
> > > > [cc linux-api]
> > > > 
> > > > On Mon 20-05-19 12:52:54, Minchan Kim wrote:
> > > > > System could have much faster swap device like zRAM. In that case, swapping
> > > > > is extremely cheaper than file-IO on the low-end storage.
> > > > > In this configuration, userspace could handle different strategy for each
> > > > > kinds of vma. IOW, they want to reclaim anonymous pages by MADV_COLD
> > > > > while it keeps file-backed pages in inactive LRU by MADV_COOL because
> > > > > file IO is more expensive in this case so want to keep them in memory
> > > > > until memory pressure happens.
> > > > > 
> > > > > To support such strategy easier, this patch introduces
> > > > > MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER options in madvise(2) like
> > > > > that /proc/<pid>/clear_refs already has supported same filters.
> > > > > They are filters could be Ored with other existing hints using top two bits
> > > > > of (int behavior).
> > > > 
> > > > madvise operates on top of ranges and it is quite trivial to do the
> > > > filtering from the userspace so why do we need any additional filtering?
> > > > 
> > > > > Once either of them is set, the hint could affect only the interested vma
> > > > > either anonymous or file-backed.
> > > > > 
> > > > > With that, user could call a process_madvise syscall simply with a entire
> > > > > range(0x0 - 0xFFFFFFFFFFFFFFFF) but either of MADV_ANONYMOUS_FILTER and
> > > > > MADV_FILE_FILTER so there is no need to call the syscall range by range.
> > > > 
> > > > OK, so here is the reason you want that. The immediate question is why
> > > > cannot the monitor do the filtering from the userspace. Slightly more
> > > > work, all right, but less of an API to expose and that itself is a
> > > > strong argument against.
> > > 
> > > What I should do if we don't have such filter option is to enumerate all of
> > > vma via /proc/<pid>/maps and then parse every ranges and inode from string,
> > > which would be painful for 2000+ vmas.
> > 
> > Painful is not an argument to add a new user API. If the existing API
> > suits the purpose then it should be used. If it is not usable, we can
> > think of a different way.
> 
> I measured 1568 vma parsing overhead of /proc/<pid>/maps in ARM64 modern
> mobile CPU. It takes 60ms and 185ms on big cores depending on cpu governor.
> It's never trivial.

This is not the only option. Have you tried to simply use
/proc/<pid>/map_files interface? This will provide you with all the file
backed mappings.
-- 
Michal Hocko
SUSE Labs

