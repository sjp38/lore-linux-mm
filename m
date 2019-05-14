Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DB36C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 06:30:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0BD5208C3
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 06:30:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0BD5208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61DD66B0003; Tue, 14 May 2019 02:30:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A74E6B0005; Tue, 14 May 2019 02:30:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46F9F6B0007; Tue, 14 May 2019 02:30:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 24EDE6B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 02:30:48 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v6so15000074qkh.6
        for <linux-mm@kvack.org>; Mon, 13 May 2019 23:30:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mgFD/HBmqD9tbHso2Ft8IrmU0HCter766u/5lDK5MD4=;
        b=aosUlHZ/mzNGgokH12qmaDMdXWT3hLgRop0eDn2VxE5Qo06uU3oMeYlmyFr0Ce3621
         THA2/nf3/IGS3UrHSYk5CHh5V57NuhDTzHLuETtcmZZ9GW7UENaGCIkbgdQqJWin8ki+
         9YN0+8o6YoyW5Gr2BdG265BrLUGAeEq8GqsWbNvmBgBEXYQpC/UsvnRo5ejy1q1YbGXy
         WRZK9zZUEO+XlMbr8M7Yaqjy5MhIINcYSzaa90gs68N/ZTZjHaJWm4yYOGiAjGA9a1xX
         Q+V0MhBUze6l7RNvtSCSmHSszSPVW9KdRQaBEonT2FjLh34fEEm4FxRwg8cL7f4OS0xU
         oLJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWADNPnWKUV8b+eW9wPsUMlb4KhWlfbeMyXC6NU9VKUTICO9rAM
	HxcEaX/RuyrZy/MYHOF6270ngd5vvQXvZf1DozB8CpIk47AVzzlRxTiIVcmozJ9NJ4QfjNd2QwJ
	+5JsUE4PiZzdMHPXxcnoMEm52ARJ9FF6CFzrVAGbBzeBbEa5Wq+dbVIt/70ubEKiIvQ==
X-Received: by 2002:a05:620a:1206:: with SMTP id u6mr4482299qkj.88.1557815447860;
        Mon, 13 May 2019 23:30:47 -0700 (PDT)
X-Received: by 2002:a05:620a:1206:: with SMTP id u6mr4482253qkj.88.1557815447160;
        Mon, 13 May 2019 23:30:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557815447; cv=none;
        d=google.com; s=arc-20160816;
        b=tLzsZNkzHgqIajuIR0hdFfcLfOuTigr4yxDNm7Zbz1az/IA8aa7eeiEXQIOyAfibEl
         i9LueQiIAXXwHhUvHxTjVGdnY/Bvpf8eGt4zkZl63GpJ7GvVBXJBZ5PVBEpWdQIHMpMT
         TNdsEg9PzFgQHInT/kKHNXldmum4Uo3Boh/PZWSW2xJ5LoIY0wFDGhHaJE6XKuzRfhJ7
         TZ80DZ3k28sfkvTEJ8N/bg4EbmDqCRoDB2KtW17tDYXgLm92RFj60UHPVCiXeqBhsrEK
         LpaINltr62IuTk3XR2ATqwiTq1tOSTE29O4DiT4rybVURk4wDlNQm2gl8mf4tEikereU
         Vwtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mgFD/HBmqD9tbHso2Ft8IrmU0HCter766u/5lDK5MD4=;
        b=oTIed935A0Ug4CKyPc1PqYzFNK6bg7SSbk4DZPXqvzHUmd499PM+imNmPTfs5zr6BR
         aYXYVFpwmh6eEF8EGPeGe6uM2eDKdeEzqPajsBtT1jYz7WE5PVsXARb+QKZZmrKYcvRD
         cVXhjHaDOIZ7SxOlqq30QV++SYaPGyFUr5tegCg3eqlQUqqgUCqfKRq2pDuOfGMyLRmM
         OS2N3m4uA61H+vUng5dxYqITEO3SpBWr/QNzmR3MrcdmTnRzLCVVf0KmdFKLYEmRw9lT
         vBMMWyGWfDD5+slEYfgydOpPLnpBVOW/QDsUr3CUL7P3fSPwhxzkKW9GNCuVwaMc52KD
         1QIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s48sor4219347qth.58.2019.05.13.23.30.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 May 2019 23:30:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwaf5mn0VEeYyYPcp4R3rX8b8NxqPdRtJziHb0+qXlt8ZvgtZIe0QaDDnNFxHyEY0wLoSEhbg==
X-Received: by 2002:ac8:8ad:: with SMTP id v42mr27107649qth.337.1557815446620;
        Mon, 13 May 2019 23:30:46 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id a51sm6532064qta.85.2019.05.13.23.30.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 May 2019 23:30:45 -0700 (PDT)
Date: Tue, 14 May 2019 08:30:43 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>, linux-mm@kvack.org
Subject: Re: [PATCH RFC 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190514063043.ojhsb6d3ohxx4wur@butterfly.localdomain>
References: <20190510072125.18059-1-oleksandr@redhat.com>
 <36a71f93-5a32-b154-b01d-2a420bca2679@virtuozzo.com>
 <20190513113314.lddxv4kv5ajjldae@butterfly.localdomain>
 <a3870e32-3a27-e6df-fcb2-79080cdd167a@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a3870e32-3a27-e6df-fcb2-79080cdd167a@virtuozzo.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

On Mon, May 13, 2019 at 03:37:56PM +0300, Kirill Tkhai wrote:
> > Yes, I get your point. But the intention is to avoid another hacky trick
> > (LD_PRELOAD), thus *something* should *preferably* be done on the
> > kernel level instead.
> 
> I don't think so. Does userspace hack introduce some overhead? It does not
> look so. Why should we think about mergeable VMAs in page fault handler?!
> This is the last thing we want to think in page fault handler.
> 
> Also, there is difficult synchronization in page fault handlers, and it's
> easy to make a mistake. So, there is a mistake in [3/4], and you call
> ksm_enter() with mmap_sem read locked, while normal way is to call it
> with write lock (see madvise_need_mmap_write()).
> 
> So, let's don't touch this path. Small optimization for unlikely case will
> introduce problems in optimization for likely case in the future.

Yup, you're right, I've missed the fact that write lock is needed there.
Re-vamping locking there is not my intention, so lets find another
solution.

> > Also, just for the sake of another piece of stats here:
> > 
> > $ echo "$(cat /sys/kernel/mm/ksm/pages_sharing) * 4 / 1024" | bc
> > 526
> 
> This all requires attentive analysis. The number looks pretty big for me.
> What are the pages you get merged there? This may be just zero pages,
> you have identical.
> 
> E.g., your browser want to work fast. It introduces smart schemes,
> and preallocates many pages in background (mmap + write 1 byte to a page),
> so in further it save some time (no page fault + alloc), when page is
> really needed. But your change merges these pages and kills this
> optimization. Sounds not good, does this?
> 
> I think, we should not think we know and predict better than application
> writers, what they want from kernel. Let's people decide themselves
> in dependence of their workload. The only exception is some buggy
> or old applications, which impossible to change, so force madvise
> workaround may help. But only in case there are really such applications...
> 
> I'd researched what pages you have duplicated in these 526 MB. Maybe
> you find, no action is required or a report to userspace application
> to use madvise is needed.

OK, I agree, this is a good argument to move decision to userspace.

> > 2) what kinds of opt-out we should maintain? Like, what if force_madvise
> > is called, but the task doesn't want some VMAs to be merged? This will
> > required new flag anyway, it seems. And should there be another
> > write-only file to unmerge everything forcibly for specific task?
> 
> For example,
> 
> Merge:
> #echo $task > /sys/kernel/mm/ksm/force_madvise

Immediate question: what should be actually done on this? I see 2
options:

1) mark all VMAs as mergeable + set some flag for mmap() to mark all
further allocations as mergeable as well;
2) just mark all the VMAs as mergeable; userspace can call this
periodically to mark new VMAs.

My prediction is that 2) is less destructive, and the decision is
preserved predominantly to userspace, thus it would be a desired option.

> Unmerge:
> #echo -$task > /sys/kernel/mm/ksm/force_madvise

Okay.

> In case of task don't want to merge some VMA, we just should skip it at all.

This way we lose some flexibility, IMO, but I get you point.

Thanks.

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

