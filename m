Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 803DCC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:32:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FD9B216B7
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:32:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FD9B216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D15B26B0003; Tue, 21 May 2019 07:32:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9E896B0005; Tue, 21 May 2019 07:32:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B186C6B0006; Tue, 21 May 2019 07:32:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD156B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 07:32:57 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h12so30148936edl.23
        for <linux-mm@kvack.org>; Tue, 21 May 2019 04:32:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0BaKrML7wLTt3gqVBh2CSd4ARfigKXI9vIEfmDiOzXE=;
        b=NHTr5hKPeL8CG9Ls6fUQjzgRgmdyCodeZwq/jyiMYa0/zqGme42IH6/O2+2enwuy/l
         JNZi1jFcqtsO0slEy2R4SfLjadJ+WeNcTf007HG/awp4iO5ZXzciYupw+rdWR0Jcjn5E
         p57ZCIB5G/YntDJ3thcXB45k4XZjN4U41RhgTSyGs99dfga4MrFP4EzKu2mZpAR1dbvM
         C6HHMiTz4RbSbb//QxdTcgL0rFxaSGlhpMohRnyN89usPkWfaEc0AoL8dGerGSWrXne0
         EjvFW2vsPK7Y49xrTtuAVoA630NUhvNn3BCg9PzSJNuush4oPwcnzeBpWLFbWNJmMUp4
         vpJg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVGm5RyqgGe5n7YtZJHGLYU7pFz3QrFTkWW8+sIC3MgaqRPjCqX
	IcCowupjM46Mdd4sqzHTPGuITbgaXN9ES+i8fYdXHBCvq7N8KkLGDxjlA+SEAGryo0MECioOWcM
	wM0d/G4QuzzO/dQBSEijocxT0HE0vFIL7sgBvx05u9K20h7sPZCC09KPlZV+GqGI=
X-Received: by 2002:a17:906:d053:: with SMTP id bo19mr38800053ejb.86.1558438376933;
        Tue, 21 May 2019 04:32:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjYEkwfwnbWsDz7unmjvhY9oqeH1wNXCe/AtsKD0vtx5MS2AGSi6GiGTzgOX5pNccpQjxI
X-Received: by 2002:a17:906:d053:: with SMTP id bo19mr38799992ejb.86.1558438376193;
        Tue, 21 May 2019 04:32:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558438376; cv=none;
        d=google.com; s=arc-20160816;
        b=zB459KxomhtqqNk083QrIJccwnogvfIpEEyTTKmj/2QVx7r3H5LzJRqMUZNit+e+NU
         cAimeVlo3VkW0UtcAHS8xIa2dLKGq6ifbA+K07TlNDOcPQuxb5yVIAwjIvh4qK5E77iR
         XRyBh5q39K6VzocHm1S7LFiMe89M0vbQwg2VNNHIbXM6JVe43kQWnehLfFbKOL7hj4Ov
         XaM1jMgpBQa4N/sUb41o1oPAQPjvxIrDmXZa/aF0zOoEOnCY5Z2v3xxHz838gbOXi7XB
         6x7tO//jTovlQh0mXAxuD1ZbeCpKWEcu32SHCWhP+nt1u07IYteZVHUIGz6tHESpu35z
         kNbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0BaKrML7wLTt3gqVBh2CSd4ARfigKXI9vIEfmDiOzXE=;
        b=bW1WdKhbfdAiRozuWN8HKT28Kw5eKQXicQP19R/jn+/m2tvZGLldTpTh0M8BGrtM4z
         JOAhKdGVMh3aFQPicIAyGFQUtI382GFeEhZx6unPvPqvVygnL5XkiaEecOlm+sXURaYV
         XPiAJictRig32AyL53fXyG0eWRtg0YcW9+wIjGBmAxnoc7IEpnxwUzwWbb4d8KlEMR2/
         Fp6n+dQ9tTJ0SnxZGBIpIRDIWx+T1aBEiXpqPKnQlIAboaMIPcd4GXoOOh9BpNpiDCcB
         vsu9JdhX7OVGLgbhcxJ8nv16c7WWhTe2aZIGlG8sBB89k3vsLdam4t2+LY6Pifwz2MW6
         J6qA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z36si8139091edb.45.2019.05.21.04.32.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 04:32:56 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 512A5AE14;
	Tue, 21 May 2019 11:32:55 +0000 (UTC)
Date: Tue, 21 May 2019 13:32:54 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Oleksandr Natalenko <oleksandr@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 4/7] mm: factor out madvise's core functionality
Message-ID: <20190521113254.GU32329@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-5-minchan@kernel.org>
 <20190520142633.x5d27gk454qruc4o@butterfly.localdomain>
 <20190521012649.GE10039@google.com>
 <20190521063628.x2npirvs75jxjilx@butterfly.localdomain>
 <20190521065000.GH32329@dhcp22.suse.cz>
 <20190521070638.yhn3w4lpohwcqbl3@butterfly.localdomain>
 <20190521105256.GF219653@google.com>
 <20190521110030.GR32329@dhcp22.suse.cz>
 <20190521112423.GH219653@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521112423.GH219653@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 21-05-19 20:24:23, Minchan Kim wrote:
> On Tue, May 21, 2019 at 01:00:30PM +0200, Michal Hocko wrote:
> > On Tue 21-05-19 19:52:56, Minchan Kim wrote:
> > > On Tue, May 21, 2019 at 09:06:38AM +0200, Oleksandr Natalenko wrote:
> > > > Hi.
> > > > 
> > > > On Tue, May 21, 2019 at 08:50:00AM +0200, Michal Hocko wrote:
> > > > > On Tue 21-05-19 08:36:28, Oleksandr Natalenko wrote:
> > > > > [...]
> > > > > > Regarding restricting the hints, I'm definitely interested in having
> > > > > > remote MADV_MERGEABLE/MADV_UNMERGEABLE. But, OTOH, doing it via remote
> > > > > > madvise() introduces another issue with traversing remote VMAs reliably.
> > > > > > IIUC, one can do this via userspace by parsing [s]maps file only, which
> > > > > > is not very consistent, and once some range is parsed, and then it is
> > > > > > immediately gone, a wrong hint will be sent.
> > > > > > 
> > > > > > Isn't this a problem we should worry about?
> > > > > 
> > > > > See http://lkml.kernel.org/r/20190520091829.GY6836@dhcp22.suse.cz
> > > > 
> > > > Oh, thanks for the pointer.
> > > > 
> > > > Indeed, for my specific task with remote KSM I'd go with map_files
> > > > instead. This doesn't solve the task completely in case of traversal
> > > > through all the VMAs in one pass, but makes it easier comparing to a
> > > > remote syscall.
> > > 
> > > I'm wondering how map_files can solve your concern exactly if you have
> > > a concern about the race of vma unmap/remap even there are anonymous
> > > vma which map_files doesn't support.
> > 
> > See http://lkml.kernel.org/r/20190521105503.GQ32329@dhcp22.suse.cz
> 
> Question is how it works for anonymous vma which don't have backing
> file.

We would have to export map_files like interface for anonymous vmas
and have a way to invalidate on the VMA removal (reference counting or
something similar), no question this will be some additional work to do.
-- 
Michal Hocko
SUSE Labs

