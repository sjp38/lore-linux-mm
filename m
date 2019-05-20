Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 786A9C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 16:46:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CF8B214DA
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 16:46:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="UsDmFQ7y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CF8B214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B57276B0006; Mon, 20 May 2019 12:46:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B08256B0008; Mon, 20 May 2019 12:46:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F6BB6B000A; Mon, 20 May 2019 12:46:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4A66B0006
	for <linux-mm@kvack.org>; Mon, 20 May 2019 12:46:12 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 123so10084140pgh.17
        for <linux-mm@kvack.org>; Mon, 20 May 2019 09:46:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=AhvyYHsik8s1aZ1UVXcXGfBu8d3R9Dfu1UdhHMa3ucQ=;
        b=Jz4DZ5Q+54ZxNP37T6RxXO6I5xQjz+C0ukL1Sd1QINhm+8YgV5vF+OaQkg0IYroeaF
         gT9mBcHSK1cUlE1lan89k75iDZPXAe+7d1Ce/Mu7nqapSwnyZS2b8tghp140dYpOtzdZ
         CEzFT813Sn0MEIErDYnViedqmZRiNWNNvOWUyEmUMKxXEngSIHqjEpwng3P+aTPc/qsm
         Wou3TcR/X5tS7asD1eZuLz5xQPdtymRIlS7R+rDNEsC1uAr5S4z4P7wcldhtetJuzkcW
         Pp4eefw4uJzjO13fq1FuBrCPMDXm97eNfuP7ho/H79tlEsYafadUkmILBR3vkMvscpDo
         w9eg==
X-Gm-Message-State: APjAAAX+0LmX2NmC3zP1n+JaIU5Ft7SsexUruOhYc7439BuS8q0gufzU
	KU2sj82exlLac3Y+zSnYPo59/Tl6mOltgDmiDGRjSzdm22XxBd3nDxQpCgD5B3s8sSrVDMTygEG
	jypvANbY3Bcm5lNBGA5bhrgvPF47dR+2t6yUQRln9Z04MqM0ddIZPDj3DvqxQZPaQlQ==
X-Received: by 2002:a17:902:848c:: with SMTP id c12mr27594365plo.17.1558370772003;
        Mon, 20 May 2019 09:46:12 -0700 (PDT)
X-Received: by 2002:a17:902:848c:: with SMTP id c12mr27594305plo.17.1558370771020;
        Mon, 20 May 2019 09:46:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558370771; cv=none;
        d=google.com; s=arc-20160816;
        b=e6YLKXZbGyNM6RzqQibgyWIvZC/bjl1V4elmRTbZKJCe6FC/JXbTQZrsQVHL5HMORC
         c5Kbb5s0tctdtmcucX9OABu2A7TUV13Q/qAehh+X/UmRyWow4T3lUQO3uM/TbcDhe/ow
         dzv79d88QNQ72/CPGZK5UDs9UPPdZjqB8/b6UNAPvTJAfxxUcmQmG8LVZzOEupiJ3+ik
         MUYVGv1MY1eU51a9YEcFUtR1TlG2p8OuFT/qFfnIvMCa9DgVPj6/SITrXomqJBNjOoFE
         x8+xPkRBOF28wDAs3uPnUnZvl/1yFLnt9xKYF4WGaD2XpQe08Fs/JjNG+k78Xo2Ei0A+
         668w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=AhvyYHsik8s1aZ1UVXcXGfBu8d3R9Dfu1UdhHMa3ucQ=;
        b=Fq98KoXDyfmoojgUhBiz5wsvh8lLyF7IyccvOJ+o3wxiYMNWbG1pyf3Nj9ctrBsnae
         Yj5LH9bMMorSJOV0FG3GSLgcfshvJWMGyNr89MzAZmMcONfFTkP5HMWs5C5Ymj0GFpy3
         zB4mBFqeatIqf3DzC9oBkp+OkZK40CKuGTq1AzN+5+7l1U+oAjott9zw2+TcpEqoD1RA
         1f7KGL5sdsJg5BypmsJHWD9PQhkfyWIbbSirY5vSp8wF3imkV/notM5r87BjTdAWuNl3
         1UaQszwX/o4x1ThymTHqtlBL29+QqPm+WbLNTDfv9cUbuwamfshCKCd+vkAAq44yRtYR
         kffg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=UsDmFQ7y;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h1sor18065211pgc.77.2019.05.20.09.46.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 09:46:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=UsDmFQ7y;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=AhvyYHsik8s1aZ1UVXcXGfBu8d3R9Dfu1UdhHMa3ucQ=;
        b=UsDmFQ7yRbOepyPR7AjsW03NVtO+g8LFYwT6yxz7nEb0fYQOAlBdknmQRffXAKJDn+
         qV0ymJDcpra7H0FQSx0LU3Oa5wQEQ13MOb15Uo06QKp1xgsj59VeiUeVv31nzJt6QHcy
         VctpAADvyCkdJG6b767kqERvNpCn2FFbJfIDtNbGvfm6CcdbUj+p8s10vaRAgUdNlcJ2
         EKC7JALHTUVt8/gOfKpLrmr+kn0XS1uI5z94u40MOK/cb3vHvpjS6MtPWkD96noFPlR9
         6uRMThqfDY/3g9WBdejaM87bPQdgmSG66QVHIUiV1dj/HUV+mlXXWXMe/whZAxWbmsJb
         +otQ==
X-Google-Smtp-Source: APXvYqxlq0UlxgIX7doeBMTtmPdq658NEoNcyut9RersVG40Z/X4qMzdBoFTKWS1679tGeWZaJICIA==
X-Received: by 2002:a65:638a:: with SMTP id h10mr7938216pgv.64.1558370767966;
        Mon, 20 May 2019 09:46:07 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::3:df5f])
        by smtp.gmail.com with ESMTPSA id u20sm21814466pfm.145.2019.05.20.09.46.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 May 2019 09:46:06 -0700 (PDT)
Date: Mon, 20 May 2019 12:46:05 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>, Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190520164605.GA11665@cmpxchg.org>
References: <20190520035254.57579-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190520035254.57579-1-minchan@kernel.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
> - Approach
> 
> The approach we chose was to use a new interface to allow userspace to
> proactively reclaim entire processes by leveraging platform information.
> This allowed us to bypass the inaccuracy of the kernel’s LRUs for pages
> that are known to be cold from userspace and to avoid races with lmkd
> by reclaiming apps as soon as they entered the cached state. Additionally,
> it could provide many chances for platform to use much information to
> optimize memory efficiency.
> 
> IMHO we should spell it out that this patchset complements MADV_WONTNEED
> and MADV_FREE by adding non-destructive ways to gain some free memory
> space. MADV_COLD is similar to MADV_WONTNEED in a way that it hints the
> kernel that memory region is not currently needed and should be reclaimed
> immediately; MADV_COOL is similar to MADV_FREE in a way that it hints the
> kernel that memory region is not currently needed and should be reclaimed
> when memory pressure rises.

I agree with this approach and the semantics. But these names are very
vague and extremely easy to confuse since they're so similar.

MADV_COLD could be a good name, but for deactivating pages, not
reclaiming them - marking memory "cold" on the LRU for later reclaim.

For the immediate reclaim one, I think there is a better option too:
In virtual memory speak, putting a page into secondary storage (or
ensuring it's already there), and then freeing its in-memory copy, is
called "paging out". And that's what this flag is supposed to do. So
how about MADV_PAGEOUT?

With that, we'd have:

MADV_FREE: Mark data invalid, free memory when needed
MADV_DONTNEED: Mark data invalid, free memory immediately

MADV_COLD: Data is not used for a while, free memory when needed
MADV_PAGEOUT: Data is not used for a while, free memory immediately

What do you think?

