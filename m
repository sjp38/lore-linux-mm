Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94219C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 07:48:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53A562146F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 07:48:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53A562146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3BEF6B0008; Tue,  2 Jul 2019 03:48:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EED158E0003; Tue,  2 Jul 2019 03:48:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB4558E0002; Tue,  2 Jul 2019 03:48:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 887356B0008
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 03:48:23 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so18881098ede.23
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 00:48:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=s1JiDXz8o1SY8FFKorg3C3csWHGOy+fLRlQoZ5UZcgk=;
        b=sF3gmd0WM5d2VEjqZcHknHl8HtVn+GMHAngYXCrDMB42Es6jeUB9BS4CQLE2Gmi/9I
         Pel1jmpIPkjY6Q48HkOPczqiC5zS+2ZFNNQwAKWd8HWHYU/UolQAndz3IwjCBge0tt19
         l2tjIB1pu6HCGM4/EpmBuVvq732Vb3sa5/zD+J/LZMIkHh+wIg8Gd6nsk4m1y5xHOfYV
         kSghGuC7Yyv9/H93dz858F3r+7NN4jvDTElvJfpa0c/0BoLybFYN4vSFuF/vxj79rdyV
         b10hUcUTgGcfAZ56GrHpsdALHpS1650f1vWQKj9Zuqj0zlf5ywiekUGf9PulKgfUwBaU
         Ievg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVlrQyM4A1Vo+axUiZ23+YiS9/V1NtFW15sszqGxujdwFwnzxAh
	vlIGQmx3miW4v1+9LsZbT16Qe9o7OGAIWKqTZoeN1jnIkib6u33oGoNBOxGyi3cbylvJTQqSarW
	5HbfzFfIfieDzfVQiSgbE7eSDGxamwMzj8pr9MTDApUYeXQRll9I2TVFOH9B0e4X7ag==
X-Received: by 2002:a50:b178:: with SMTP id l53mr5316349edd.244.1562053703127;
        Tue, 02 Jul 2019 00:48:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9CFdoJTDaVCQwhOwZRnbmqJYUAZ0wAEjnpsYDiNUUQ2UH6d5pRdjM+6BygwgVoYB5oWbn
X-Received: by 2002:a50:b178:: with SMTP id l53mr5316297edd.244.1562053702336;
        Tue, 02 Jul 2019 00:48:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562053702; cv=none;
        d=google.com; s=arc-20160816;
        b=DLKFhDkDWUfzGyXCilTFe4Pf8gNCFqwaVWQGZkPODn7jtd0QitEEyF4QYEdUDBxKlm
         WwwB6axxBqAMGLhl8XLQZssKDHs+0KTBMaaIxzNuJD8Akdnk/aLhRqoM1l/ntjnbF7fj
         sSG5Wr7EZiVC3QaIoP+cX3KYFtttxbuuMMSdppzyPQC6WAezFDPzZcGI7x27njEbhGdc
         KhgPj5a2qSbO6/LawX2HQlW3NL+EzVtOu7pr6ZPqVBluKSWtznjpFvti2fK3oj2x3jDs
         rab/QxxKMKQrKBmIGkRamSFSOPd8lsbaIX+g0WL1zSS2uXMlP2qKlaI51YDPHisRdlkt
         Cd5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=s1JiDXz8o1SY8FFKorg3C3csWHGOy+fLRlQoZ5UZcgk=;
        b=GnKl9hCQwqfWXfNVSWWpRP88HIvLq70A5hRkHFbAHrgPwT81NvyxJnSjQgz1c8xfYZ
         3IyDHCIcDF2P14mtp8prAQBrYo+jZQrzrremEcbj8ZeFWRSRnCKhj633ksZwpJ/G4UZ6
         0Za5EuCy/5tcXD/hhMvc/SVMGlFXyuFRsDWitQa4Esuaw27OdiLcMW6VDMHBOibdeAAu
         Zg7CoMNcq1dAA7L6K4x7M6nNinVeGMqvCD+ZUYn6dl/r04mLmT5+33NlTx+uWrQs6XOz
         lfWPlM6eCmvAMEvGLLp1mdf47NfSDfhGCG8YfkqXYlbICuf8Y3XagsiVzaFw5ZpukAXu
         KspA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g15si8581588ejh.113.2019.07.02.00.48.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 00:48:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 63296AFFB;
	Tue,  2 Jul 2019 07:48:21 +0000 (UTC)
Date: Tue, 2 Jul 2019 09:48:18 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Rashmica Gupta <rashmica.g@gmail.com>
Cc: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org,
	mhocko@suse.com, dan.j.williams@intel.com,
	pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
Message-ID: <20190702074806.GA26836@linux>
References: <20190625075227.15193-1-osalvador@suse.de>
 <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
 <20190626080249.GA30863@linux>
 <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
 <20190626081516.GC30863@linux>
 <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
 <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 02, 2019 at 04:42:34PM +1000, Rashmica Gupta wrote:
> Hi David,
> 
> Sorry for the late reply.
> 
> On Wed, 2019-06-26 at 10:28 +0200, David Hildenbrand wrote:
> > On 26.06.19 10:15, Oscar Salvador wrote:
> > > On Wed, Jun 26, 2019 at 10:11:06AM +0200, David Hildenbrand wrote:
> > > > Back then, I already mentioned that we might have some users that
> > > > remove_memory() they never added in a granularity it wasn't
> > > > added. My
> > > > concerns back then were never fully sorted out.
> > > > 
> > > > arch/powerpc/platforms/powernv/memtrace.c
> > > > 
> > > > - Will remove memory in memory block size chunks it never added
> > > > - What if that memory resides on a DIMM added via
> > > > MHP_MEMMAP_DEVICE?
> > > > 
> > > > Will it at least bail out? Or simply break?
> > > > 
> > > > IOW: I am not yet 100% convinced that MHP_MEMMAP_DEVICE is save
> > > > to be
> > > > introduced.
> > > 
> > > Uhm, I will take a closer look and see if I can clear your
> > > concerns.
> > > TBH, I did not try to use arch/powerpc/platforms/powernv/memtrace.c
> > > yet.
> > > 
> > > I will get back to you once I tried it out.
> > > 
> > 
> > BTW, I consider the code in arch/powerpc/platforms/powernv/memtrace.c
> > very ugly and dangerous.
> 
> Yes it would be nice to clean this up.
> 
> > We should never allow to manually
> > offline/online pages / hack into memory block states.
> > 
> > What I would want to see here is rather:
> > 
> > 1. User space offlines the blocks to be used
> > 2. memtrace installs a hotplug notifier and hinders the blocks it
> > wants
> > to use from getting onlined.
> > 3. memory is not added/removed/onlined/offlined in memtrace code.
> >
> 
> I remember looking into doing it a similar way. I can't recall the
> details but my issue was probably 'how does userspace indicate to
> the kernel that this memory being offlined should be removed'?
> 
> I don't know the mm code nor how the notifiers work very well so I
> can't quite see how the above would work. I'm assuming memtrace would
> register a hotplug notifier and when memory is offlined from userspace,
> the callback func in memtrace would be called if the priority was high
> enough? But how do we know that the memory being offlined is intended
> for usto touch? Is there a way to offline memory from userspace not
> using sysfs or have I missed something in the sysfs interface?
> 
> On a second read, perhaps you are assuming that memtrace is used after
> adding new memory at runtime? If so, that is not the case. If not, then
> would you be able to clarify what I'm not seeing?

Hi Rashmica,

let us go the easy way here.
Could you please explain:

1) How memtrace works
2) Why it was designed, what is the goal of the interface?
3) When it is supposed to be used?

I have seen a couple of reports in the past from people running memtrace
and failing to do so sometimes, and back then I could not grasp why people
was using it, or under which circumstances was nice to have.
So it would be nice to have a detailed explanation from the person who wrote
it.

Thanks

-- 
Oscar Salvador
SUSE L3

