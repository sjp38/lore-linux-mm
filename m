Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B5E4C04E84
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:53:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 128E820657
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:53:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 128E820657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8207A6B0007; Thu, 16 May 2019 09:53:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F6706B0008; Thu, 16 May 2019 09:53:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BF4D6B000A; Thu, 16 May 2019 09:53:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1DE106B0007
	for <linux-mm@kvack.org>; Thu, 16 May 2019 09:53:08 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b22so5564921edw.0
        for <linux-mm@kvack.org>; Thu, 16 May 2019 06:53:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=snYW1g8gu8OplU4wIoMhWxb6FV3JCp+3b3cHwZuPClc=;
        b=QGrIO5VYZZ/r/bqSRxiRxa0Of+4C8/adkihei/+fkGgG5McTcgVLwXbwvOPj1GHvxw
         O6NWRMAXTNKxYtBpG/15jDlCUeVNJeRpuPDUb0Aestj2DAcnWOyMscLIpIZC4dQ3Rm7Z
         tT1CXta+E08VXZPhT+sjL6I1FDLhjTxDghWe1gpSBCHQBjUnPIJdh5+qQHl3KFNwH/fa
         JkNRnp1ETdk/nCy8oJJWy7VHqYCISYwnVr7u32vVgxbUOCSVXnkDBuQPUAnVVm6Gm2PV
         A3dvrz3aPjzucaI9izozNWN+USNt38vFyj8XJvtgYQPoPUzzKBVi1GsI+aYNXx42Eu5o
         OYXw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUxmptNJLWuT8KsRNjOzcMtxGofJmTTYKobjdey8aRDsz5in8XM
	+M4pwjMlk4BZlultJ2byjakxBbOJm9BxdKZvJvfKCuG2YAOkFMd7uw6px+LPEVrw6IIx2CfAbOo
	Ulg+Pw5MjIfb+aiWQGYq6Z4gp8S2SZVNDSxUj+1odambM2bZssfZB/Vu8Ctx9L4s=
X-Received: by 2002:aa7:d04e:: with SMTP id n14mr21166213edo.205.1558014787714;
        Thu, 16 May 2019 06:53:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKLZPbNsXWMaIscXqBuyJRoNdow9v3DUwfFdlqE4ZGu0oR2oMt21Y8grT0w11Y6gJTj87u
X-Received: by 2002:aa7:d04e:: with SMTP id n14mr21166150edo.205.1558014787050;
        Thu, 16 May 2019 06:53:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558014787; cv=none;
        d=google.com; s=arc-20160816;
        b=So+1B97iLROkQD6NOSSYv4EyDIeW1kfP6dn6usss1od4RK1b2VdN0hmNKW4txzhenc
         HVJdGClLrIjQYkvadxee2jxw2Xz09+C5AVliSDb74FtlD610Su8SJzRIpTt/4y4y+To2
         GqaO8KLTGyuy8uhiA2zDp0yK69cyOHEoKSJOjW0FfHQ7zLgE0BdZSvDSXxYjllAJsGvE
         9HfZGmx7URGnrTOsuAyf8P33YsPrgo+bgZqGhes15uRr7MrWEghwz9HFNFgfGJVh5NCj
         O0lWj/rKgLRBI1UqNNmrvxyA/V7lVFYKjq7KgLnCg7h3XHtnHTXJILIOtcSoLe5mcULT
         02Jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=snYW1g8gu8OplU4wIoMhWxb6FV3JCp+3b3cHwZuPClc=;
        b=gpcmy2RvFI0MmnoGXFzpo+wkRCzTkDtr4BwnHGutqyxFo5B+ZfqJ59LKEQZnQJmulf
         qeD8E1U7JQtJPSVFYmrWo8HVSOuh8IQlArbvO9kFNIB8OlxwAMjoaBXJ5NnVAMaggozg
         Bl1XTylDP+5FRhvknwZd/XMpEYks8yKL+IkyewvlxGNspqKePy9J8Tz54RVZNQu5y0pi
         Ce7QmQgvJ9+HvzK1Q//L//Gt3XUBrncSD7tGRYPRYGyBCmBA0W0RlzUiRCPB2ub70h2s
         c986zQHEQjqA6a7+HovvBFzYTYwT1hgovLcFbm96DoimlU8vrHSDGIE5pr0T/UOSa3/w
         DxLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i21si274038edg.233.2019.05.16.06.53.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 06:53:07 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 06CCAAED7;
	Thu, 16 May 2019 13:53:05 +0000 (UTC)
Date: Thu, 16 May 2019 15:52:59 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com,
	keith.busch@intel.com, kirill.shutemov@linux.intel.com,
	pasha.tatashin@oracle.com, alexander.h.duyck@linux.intel.com,
	ira.weiny@intel.com, andreyknvl@google.com, arunks@codeaurora.org,
	vbabka@suse.cz, cl@linux.com, riel@surriel.com,
	keescook@chromium.org, hannes@cmpxchg.org, npiggin@gmail.com,
	mathieu.desnoyers@efficios.com, shakeelb@google.com, guro@fb.com,
	aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
	mgorman@techsingularity.net, daniel.m.jordan@oracle.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: Re: [PATCH RFC 0/5] mm: process_vm_mmap() -- syscall for duplication
 a process mapping
Message-ID: <20190516135259.GU16651@dhcp22.suse.cz>
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
 <20190516133034.GT16651@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190516133034.GT16651@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 16-05-19 15:30:34, Michal Hocko wrote:
> [You are defining a new user visible API, please always add linux-api
>  mailing list - now done]
> 
> On Wed 15-05-19 18:11:15, Kirill Tkhai wrote:
[...]
> > The proposed syscall aims to introduce an interface, which
> > supplements currently existing process_vm_writev() and
> > process_vm_readv(), and allows to solve the problem with
> > anonymous memory transfer. The above example may be rewritten as:
> > 
> > 	void *buf;
> > 
> > 	buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
> > 		   MAP_PRIVATE|MAP_ANONYMOUS, ...);
> > 	recv(sock, buf, n * PAGE_SIZE, 0);
> > 
> > 	/* Sign of @pid is direction: "from @pid task to current" or vice versa. */
> > 	process_vm_mmap(-pid, buf, n * PAGE_SIZE, remote_addr, PVMMAP_FIXED);
> > 	munmap(buf, n * PAGE_SIZE);

AFAIU this means that you actually want to do an mmap of an anonymous
memory with a COW semantic to the remote process right? How does the
remote process find out where and what has been mmaped? What if the
range collides? This sounds quite scary to me TBH. Why cannot you simply
use shared memory for that?
-- 
Michal Hocko
SUSE Labs

