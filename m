Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 450F2C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 10:33:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 056982075C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 10:33:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 056982075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE3106B0274; Tue, 28 May 2019 06:33:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A93D66B0275; Tue, 28 May 2019 06:33:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95CD76B0276; Tue, 28 May 2019 06:33:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 45F5A6B0274
	for <linux-mm@kvack.org>; Tue, 28 May 2019 06:33:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g36so32437220edg.8
        for <linux-mm@kvack.org>; Tue, 28 May 2019 03:33:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GFm2KVjWN8Ii8lgnLv3wgkCb+64jV4Ob3uLihwbel/8=;
        b=VlCMhJQHP2au9TBm+mOFgnNi1TMk50dLSoavX+mPi+PhH+MJJPdxhTOSDE/NEpwKm9
         5eqeUK72NdirjIp0DlLStAVaqQ4POsbh+aco3Gsg0wEF1G+3ANg8GU9kr88v+1P44ts2
         WFu6r5iLc1LjOKsyA9Swk6iuuiCla8D+e7vbFVlYAgjmzgPSlCCRGlS9/PXrxQmEXO68
         b8VTWrLhM7RQuG1Xk4vkdErdIOcfi4k4cylUoGbFcE0ai3tobrjtJYPuyGXLR51UOeui
         DhqDv4aTYCU/AuBGMiV9rQ2x/TGjT1AQQNd37e37azRORGGIjEhaPK0g/VozjSquLrTB
         mSLA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWlJxx8+GtLxF3IWVJNR1G3NNGMQCn7QeGTkMtlAf5BhOcAXeZQ
	TMY9aiOUVlfvYOYaaluZlRwzGGgb8lS4CRqwzS3cFIr4e91Vxcgu57hgdeWgabrWQ5lLr9RN1/2
	np6NRnzlQICPG1IE6CHMrqnNBVhdohnW2umPtXEk4XAkoDqQxC4fOtL+sugZ5a0M=
X-Received: by 2002:a17:906:4995:: with SMTP id p21mr22054775eju.140.1559039594790;
        Tue, 28 May 2019 03:33:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhCehUJuoRyDBoxXDnJgpojg8vROIgQ4WktNz4+lU3XGyv0feE0jdwUg3pxjvK5Iq1K1R8
X-Received: by 2002:a17:906:4995:: with SMTP id p21mr22054702eju.140.1559039593868;
        Tue, 28 May 2019 03:33:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559039593; cv=none;
        d=google.com; s=arc-20160816;
        b=t+CvjUPuF9Ug7EIS1A0D2X6KDQbAbOB8208chCDSyTlidbdQH3ryo7k4v0VHSa6T1T
         ocykE3FBwisYW8ZFrC/K93MEA2jmD6yBlbIPHuQR9DKpm4nOslq++dIQ3xYFRU3wcFVe
         TmiN4HpK96J6OfEW1VrwwkXsGXxsTWaetDmKRJDqDbz9WY1ISxooxBDQeyAxzAUSaE1e
         5/NGr7UGrYQxrWDS8Z8IHPMSiwgRTXsNEwahTq0HBV8dJZkgsxSGXgjxJSPJD8COZyPz
         g/13bYztcfEyafQSOXB7bdlnMOmV8UxqXrWd7OneOk6sM50PZnhdmC/xRWuGhCBCK5Mm
         JeKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GFm2KVjWN8Ii8lgnLv3wgkCb+64jV4Ob3uLihwbel/8=;
        b=J09m/S28WikVw5WFcA956TUY34oh4hXv3Dn6/GU2/G0kTMITase0dOHLL9djzDFjZ3
         hlYc3vP8IIoCp0xtOGDpoOmBSX8LHK3C6vQ01XRU3JLG7Swi50hhOP5M/eG6T0iR5193
         Y2z2m5qKszO4idZ0uQSKT1/12oAubGdXo5ecRFpc7uFsQE/CHrBh1Q8ZkcyMGN7EIP7N
         Rvu+fjdbCIE9owPkgmWQSpFoLjnj5f5s0luM/Uy9++Jc+VNsm0Vv/iXOEMKDJukJn2UT
         OW48mCA0nEMud/JBhuG8bAB0nxK1j0BvM+foWWAO0GthZbj+38PgB04tAzxHdgwZfMOd
         pUdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a20si11922937edd.180.2019.05.28.03.33.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 03:33:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 364C1AC66;
	Tue, 28 May 2019 10:33:13 +0000 (UTC)
Date: Tue, 28 May 2019 12:33:12 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Daniel Colascione <dancol@google.com>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190528103312.GV1658@dhcp22.suse.cz>
References: <20190521062628.GE32329@dhcp22.suse.cz>
 <20190527075811.GC6879@google.com>
 <20190527124411.GC1658@dhcp22.suse.cz>
 <20190528032632.GF6879@google.com>
 <20190528062947.GL1658@dhcp22.suse.cz>
 <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com>
 <20190528090821.GU1658@dhcp22.suse.cz>
 <CAKOZueux3T4_dMOUK6R=ZHhCFaSSstOCPh_KSwSMCW_yp=jdSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZueux3T4_dMOUK6R=ZHhCFaSSstOCPh_KSwSMCW_yp=jdSg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 02:39:03, Daniel Colascione wrote:
> On Tue, May 28, 2019 at 2:08 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> > > On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > > > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > > if we went with the per vma fd approach then you would get this
> > > > > > feature automatically because map_files would refer to file backed
> > > > > > mappings while map_anon could refer only to anonymous mappings.
> > > > >
> > > > > The reason to add such filter option is to avoid the parsing overhead
> > > > > so map_anon wouldn't be helpful.
> > > >
> > > > Without chiming on whether the filter option is a good idea, I'd like
> > > > to suggest that providing an efficient binary interfaces for pulling
> > > > memory map information out of processes.  Some single-system-call
> > > > method for retrieving a binary snapshot of a process's address space
> > > > complete with attributes (selectable, like statx?) for each VMA would
> > > > reduce complexity and increase performance in a variety of areas,
> > > > e.g., Android memory map debugging commands.
> > >
> > > I agree it's the best we can get *generally*.
> > > Michal, any opinion?
> >
> > I am not really sure this is directly related. I think the primary
> > question that we have to sort out first is whether we want to have
> > the remote madvise call process or vma fd based. This is an important
> > distinction wrt. usability. I have only seen pid vs. pidfd discussions
> > so far unfortunately.
> 
> I don't think the vma fd approach is viable. We have some processes
> with a *lot* of VMAs --- system_server had 4204 when I checked just
> now (and that's typical) --- and an FD operation per VMA would be
> excessive.

What do you mean by excessive here? Do you expect the process to have
them open all at once?

> VMAs also come and go pretty easily depending on changes in
> protections and various faults.

Is this really too much different from /proc/<pid>/map_files?

[...]

> > An interface to query address range information is a separate but
> > although a related topic. We have /proc/<pid>/[s]maps for that right
> > now and I understand it is not a general win for all usecases because
> > it tends to be slow for some. I can see how /proc/<pid>/map_anons could
> > provide per vma information in a binary form via a fd based interface.
> > But I would rather not conflate those two discussions much - well except
> > if it could give one of the approaches more justification but let's
> > focus on the madvise part first.
> 
> I don't think it's a good idea to focus on one feature in a
> multi-feature change when the interactions between features can be
> very important for overall design of the multi-feature system and the
> design of each feature.
> 
> Here's my thinking on the high-level design:
> 
> I'm imagining an address-range system that would work like this: we'd
> create some kind of process_vm_getinfo(2) system call [1] that would
> accept a statx-like attribute map and a pid/fd parameter as input and
> return, on output, two things: 1) an array [2] of VMA descriptors
> containing the requested information, and 2) a VMA configuration
> sequence number. We'd then have process_madvise() and other
> cross-process VM interfaces accept both address ranges and this
> sequence number; they'd succeed only if the VMA configuration sequence
> number is still current, i.e., the target process hasn't changed its
> VMA configuration (implicitly or explicitly) since the call to
> process_vm_getinfo().

The sequence number is essentially a cookie that is transparent to the
userspace right? If yes, how does it differ from a fd (returned from
/proc/<pid>/map_{anons,files}/range) which is a cookie itself and it can
be used to revalidate when the operation is requested and fail if
something has changed. Moreover we already do have a fd based madvise
syscall so there shouldn't be really a large need to add a new set of
syscalls.

[...]

> Or maybe the whole sequence number thing is overkill and we don't need
> atomicity? But if there's a concern  that A shouldn't operate on B's
> memory without knowing what it's operating on, then the scheme I've
> proposed above solves this knowledge problem in a pretty lightweight
> way.

This is the main question here. Do we really want to enforce an external
synchronization between the two processes to make sure that they are
both operating on the same range - aka protect from the range going away
and being reused for a different purpose. Right now it wouldn't be fatal
because both operations are non destructive but I can imagine that there
will be more madvise operations to follow (including those that are
destructive) because people will simply find usecases for that. This
should be reflected in the proposed API.
-- 
Michal Hocko
SUSE Labs

