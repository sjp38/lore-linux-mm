Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31A47C41517
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:31:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0288D21901
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:31:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0288D21901
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84EB06B0003; Fri, 26 Jul 2019 04:31:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FE436B0005; Fri, 26 Jul 2019 04:31:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C74D8E0003; Fri, 26 Jul 2019 04:31:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1FE266B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 04:31:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o13so33674803edt.4
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 01:31:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=E6eX+/MFlTWP2vujAMSh7Gen9lqS+XtDiA6QU6x+rkI=;
        b=EOZmQrScH3kY1o6ptAnlMmiBsR7qsNqQGvmaRahBIGEsoCgl0gsXpkgKCwGbhN8fUa
         XV3oTU7WZ4kuGoQVmu1FjbM4UNKZGjRgEYzhXtMTL9SI/BrGzFuZdfE66orvmlwTpcKO
         JfLqO7WA+/6+zq/EXl7o0PqICX0QTUuLnfykcF3jZvziNrG8oI4/9ka44uWgC0qXdHZB
         HFR7/bB1K1+6SE1PWOv7e2m6Fc2Jqj387Kbe/xRrzanxHpILF3eHTM/pLf/vyuGRJSKy
         uABRVlmAUSclqvgai75ZjLlwdiUrT9WOwrLDLaZxOmEeAJje7DJ/drx9vs5wRZlGFCpC
         xgBw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWCkAwHL3aK534Gmmhl1TW0xAnAqG6qAU7C3wThIP8t+JZiNCyF
	O9wwXXGEGXH1eZu8XDjr6gqhb9ywBXOO9gMRQGHRtkPwrNwXSv+53v6nEnldERVPf6GX+pp0EAG
	We+NUsb+LGNnMl/xO+s9GIUyd/jlmkJL1uwyRlr29FY9XleCDMbJTTCPv0H9PiPI=
X-Received: by 2002:a05:6402:1707:: with SMTP id y7mr79756092edu.223.1564129878690;
        Fri, 26 Jul 2019 01:31:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSUC2HB9OwFyTBhsOQnaW+L1+JQgje8t2b82dRpYcslJMOsNaskiZDl0fJRjwVtsjr2pPn
X-Received: by 2002:a05:6402:1707:: with SMTP id y7mr79756052edu.223.1564129878095;
        Fri, 26 Jul 2019 01:31:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564129878; cv=none;
        d=google.com; s=arc-20160816;
        b=p//rlu4z3AuLozZENIV0CsMXKb8FvWYz4JlIzOH08a/85Sg2AC75lRw5KLjAhIdEI0
         1GJ+LelewZVT4BJ7YcbEJEtrg2BTo3q2kIyknmK0L7wi+hoWVTtcZjgnC9lmsoS7387e
         FTWRpPAwRxKJaUAaK4o6xSMk1nVXxWqhRb70eDV2WtKEFpFpTT92cRReml6GLgnLxH5h
         xml6Du690l8sq8YOrbisqtJBsH+JqK1mGViZy9pgDp6tm2AbzBaS4e6hmjpMNwWJ9c9C
         MCHgHrSZWBZBO4ageAclbwlHDnhyXAoZxL5l1pSy/UoBv5MCcqqfpTKv+a67aFZBKNqo
         ZYeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=E6eX+/MFlTWP2vujAMSh7Gen9lqS+XtDiA6QU6x+rkI=;
        b=yldIGvLexmAqttxZ+f8jUzZUB3dlGezryg0/HbkhC5+KkLafN5Ia4uR/I5cNTscgVF
         OO2RWE7e/RkCBuswuKTmom3PX54evjS66fxosnnrQ+Xn1H5AZ6I46dGdFWwOWMiY3MZl
         N0b4SqbqQlnK4oJiq7ld3XWCrEpZ/lqDt/Bu3VljOVPKeOlepUO5dUkV1Dp4xeY0K960
         CqpbLpUx6Pevul50sEBCkh0um9bduf39++Kdy3UrUUx5kOzFUuQM4+E7NZdUrFOEuRBa
         DSDj7wXUhT7fjn2IS7K8WIL3WR3M0JWKtvIyfjzbVt6lzxVm9sPD53ldAe314U3cWYW/
         RxUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w8si11722460edb.380.2019.07.26.01.31.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 01:31:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AB72DB606;
	Fri, 26 Jul 2019 08:31:17 +0000 (UTC)
Date: Fri, 26 Jul 2019 10:31:17 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in
 acpi_scan_init()
Message-ID: <20190726083117.GJ6142@dhcp22.suse.cz>
References: <20190724143017.12841-1-david@redhat.com>
 <20190725125636.GA3582@dhcp22.suse.cz>
 <6dc566c2-faf6-565d-4ef1-2ac3a366bc76@redhat.com>
 <20190725135747.GB3582@dhcp22.suse.cz>
 <447b74ca-f7c7-0835-fd50-a9f7191fe47c@redhat.com>
 <20190725191943.GA6142@dhcp22.suse.cz>
 <e31882cf-3290-ea36-77d6-637eaf66fe77@redhat.com>
 <20190726075729.GG6142@dhcp22.suse.cz>
 <fd9e8495-1a93-ac47-442f-081d392ed09b@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fd9e8495-1a93-ac47-442f-081d392ed09b@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 26-07-19 10:05:58, David Hildenbrand wrote:
> On 26.07.19 09:57, Michal Hocko wrote:
> > On Thu 25-07-19 22:49:36, David Hildenbrand wrote:
> >> On 25.07.19 21:19, Michal Hocko wrote:
> > [...]
> >>> We need to rationalize the locking here, not to add more hacks.
> >>
> >> No, sorry. The real hack is calling a function that is *documented* to
> >> be called under lock without it. That is an optimization for a special
> >> case. That is the black magic in the code.
> > 
> > OK, let me ask differently. What does the device_hotplug_lock actually
> > protects from in the add_memory path? (Which data structures)
> > 
> > This function is meant to be used when struct pages and node/zone data
> > structures should be updated. Why should we even care about some device
> > concept here? This should all be handled a layer up. Not all memory will
> > have user space API to control online/offline state.
> 
> Via add_memory()/__add_memory() we create memory block devices for all
> memory. So all memory we create via this function (IOW, hotplug) will
> have user space APIs.

Ups, I have mixed add_memory with add_pages which I've had in mind while
writing that. Sorry about the confusion.

Anyway, my dislike of the device_hotplug_lock persists. I would really
love to see it go rather than grow even more to the hotplug code. We
should be really striving for mem hotplug internal and ideally range
defined locking longterm.

-- 
Michal Hocko
SUSE Labs

