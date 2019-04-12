Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63E81C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 06:53:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27D0C20651
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 06:53:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27D0C20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAA0D6B000C; Fri, 12 Apr 2019 02:53:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B30AC6B0010; Fri, 12 Apr 2019 02:53:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D1396B0266; Fri, 12 Apr 2019 02:53:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4724E6B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 02:53:17 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d2so4263545edo.23
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 23:53:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rqBneHYFb+qAUTDXhL+JxRJizleIs9AJtZzRqAzZrjU=;
        b=CArkXaryxR+DdKVPgSVIGj84XY5wsbJLMDfQa3jps4bzjrzAVynzPC1q8mA0z/f3HI
         VPNizNQk7nNNFTWpk2Pfe/A+ju4SbYKpLiwdQvhoGMpTk4ytGOwwEqzIla1LNMS/WayO
         VM6CGKYXMC0f1FfCvbI2ThlSC5rpeLUq6HHTv64F0Ilq3y2W/Ea8f9EvBGL7WD+oTngx
         YSEsQhDEbKeS3bREXFrDQ8OToykLJWknBZ8pVykS/dRY4Xm8CcbE6YVmrCQFO+YbAxAD
         ji17bE5p9XxSBnCHKLpf7zZiFXZLi5VLEISOrYt32pOAt3JJBZuIjawoJcrJxT2zsqxQ
         BFtg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXQRxNjs2S9RKHohoEn28QlL8M6doirvHqGvZVtHbI0CC8VCXbc
	QSYkdXcfrueBLlthNdv8YcmY69bR2s79o+9ShipOgcpd3SH21sTZEZBS78GVsAwkCa3i7KIEYfq
	55R+BZMFagMXEn6zmxBe3ZV+mmZbL9LUPdlt+BNv+0xzElUqX8vfyQOedk7hDa5I=
X-Received: by 2002:a17:906:b34c:: with SMTP id cd12mr25736360ejb.106.1555051996833;
        Thu, 11 Apr 2019 23:53:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3yU9fQtky6yiBYJhj1ZoWdzzznV7hocN0faIS/J5UXPZwGtOVaXkXo+TF762Nr+y0Tsu4
X-Received: by 2002:a17:906:b34c:: with SMTP id cd12mr25736325ejb.106.1555051995964;
        Thu, 11 Apr 2019 23:53:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555051995; cv=none;
        d=google.com; s=arc-20160816;
        b=Z6hkV51TdEEN8BKviKzCz2ao2YjEYZpTu5/501fsPnls43xVP/MbALB55IZ+GaqPse
         /GnhdPcuvf+52Khe+km6obCO2IGecUz4o/f7ATnTfOcvqxzrQTxsiRP76Wx+Z8zPdaou
         hVBbLkpVl5gdD4Dc7a1U+SLr+0k3qZiNG1ZRvXSyhOxeNEa6QJZIMCBSXPuMdb5zvCoB
         UzXBvK7MfEtiqxDzIRxQCvdDg67n6wN9yMUe5S+BFhdnBzBfstMWqGJfy0wt3X2CLG2J
         16+CBS1Cac+z0wBCbPKmDIwJzoy8MgXFZJAWMbjBwRWriRFYI0X+JZZFpPtDwEESHt6S
         hOoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rqBneHYFb+qAUTDXhL+JxRJizleIs9AJtZzRqAzZrjU=;
        b=NQMY1Uc3CIAwilqTi9MZHCoplvDq31G0g2j2ehJE2R28vov3oxX01B0Q3J+wcnyJ/9
         Y6GFWg4Wl8xL9JrcR8XzNHMj63ex5OVYtm+/uArLz5WOwWg6p29Lw1hhHRc5S2IiqBuv
         v0X+QHI2FSg1HbGQBfNYWa32tN9k4p700We7FPlt5MB4UVt4gmNTctO+6GjWCe80ReO/
         fXCeTTxzeAWWQSS+5ekixR9DjooJVxsC7H7U9qKbhpWD9EAb+1ZCsVk8/RZTqRuSUxC/
         Txh95h2J5dYJc05nGHrtS/8gcrYmevDD6wa+yJRA5d4RfUrulFhHLi7QB47wfjWA+YtY
         19Ag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h44si2930653ede.156.2019.04.11.23.53.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 23:53:15 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 786A0ADDB;
	Fri, 12 Apr 2019 06:53:15 +0000 (UTC)
Date: Fri, 12 Apr 2019 08:53:14 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Suren Baghdasaryan <surenb@google.com>, akpm@linux-foundation.org,
	rientjes@google.com, yuzhoujian@didichuxing.com,
	jrdr.linux@gmail.com, guro@fb.com, hannes@cmpxchg.org,
	penguin-kernel@I-love.SAKURA.ne.jp, ebiederm@xmission.com,
	shakeelb@google.com, christian@brauner.io, minchan@kernel.org,
	timmurray@google.com, dancol@google.com, joel@joelfernandes.org,
	jannh@google.com, linux-mm@kvack.org,
	lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
Message-ID: <20190412065314.GC13373@dhcp22.suse.cz>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411153313.GE22763@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 08:33:13, Matthew Wilcox wrote:
> On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > victim process. The usage of this flag is currently limited to SIGKILL
> > signal and only to privileged users.
> 
> What is the downside of doing expedited memory reclaim?  ie why not do it
> every time a process is going to die?
 
Well, you are tearing down an address space which might be still in use
because the task not fully dead yeat. So there are two downsides AFAICS.
Core dumping which will not see the reaped memory so the resulting
coredump might be incomplete. And unexpected #PF/gup on the reaped
memory will result in SIGBUS. These are things that we have closed our
eyes in the oom context because they likely do not matter. If we want to
use the same technique for other usecases then we have to think how much
that matter again.

-- 
Michal Hocko
SUSE Labs

