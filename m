Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE2A9C04E84
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 09:08:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A291F208CB
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 09:08:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A291F208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 222316B0275; Tue, 28 May 2019 05:08:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D1776B0276; Tue, 28 May 2019 05:08:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C3376B0278; Tue, 28 May 2019 05:08:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B50A96B0275
	for <linux-mm@kvack.org>; Tue, 28 May 2019 05:08:25 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x16so32106456edm.16
        for <linux-mm@kvack.org>; Tue, 28 May 2019 02:08:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZwcWr9VWmfqG3HHy672VEg4BSNiSaWATEy9aAwdElOM=;
        b=jBRLm3TiU+j5x8n0r0WkPJW2d8xrRof5MSyjU9ug9+YUHRfUVUwm2LJRIzsP0yXZAy
         pUPBNCRa1C8AhS+HRafwt/Bg4Euchf6y1rDaV46a1x3fcaOaP6QCbgxdhrz9z7LC6fg9
         HapZx0V9hLf2beBiwNVe5pxDVW4LTt+e+aSdHlI/VaLOJcwooW6t9SUFE1eXJUMsdjYg
         f6a87zFseHZP717sSeu3nlEczQVdcyKs/1qlcGin6PXXOTIWtmFfnSVVMLu43LXtirTy
         jk5cGMCMvxjT+VBC0igBnvAvyovQBRKJlPIYncArfgt/5gwYQOIWyM+o2VS5hfjovzb2
         wAFA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXZQu3lrDBo6twodjwIRU93ooG8evvrfABP7pqxvIzVJOH3+N8C
	yaPIsOfajquk9Vs+Vld+x2TnFvvv9KVxPisG/VsXuEdT0QoV0FOTIgkhwE3Ni2MK4ymUZGZcrYo
	vSQPBv8ZgDjvmwWdm2dXsS91pctEz7gDnXZeruxPR3NcOa/ClhwXdE681ieVmtgc=
X-Received: by 2002:a50:991d:: with SMTP id k29mr126632963edb.29.1559034505323;
        Tue, 28 May 2019 02:08:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlcQLV4daaAzq6jxmErEHhO22CINRJgG+IMBdtBjgxN638/UQVtAiIOE9WEeFS2m2DYzpf
X-Received: by 2002:a50:991d:: with SMTP id k29mr126632880edb.29.1559034504383;
        Tue, 28 May 2019 02:08:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559034504; cv=none;
        d=google.com; s=arc-20160816;
        b=eSnEXHXBxmgzjIiba9HD+m0LFflGmB8I0cIxkbuZ1odroVqOWttczQTupvcbEBANxO
         q0NFhAGbzBKwHZOnJ8N8EbxuLcwHGe7uS0KaJyS31WAqb2ZNGxuixYaitmvmmNAjRkG2
         rheAQzmTMaRli64tw3nR7ROEvql22cjjiU/bfki/k+Hu9Y1seUwJFMbH8cbP/QJcxObn
         3Z9/RfVOO80kBdAt05lguDokuWTEEI/dmpiVL2zESODdJg8GRuRUKnCGA5ajOyJ7BURf
         Pmm3W6QjNPeO4G6mY1WOeSvK6HQufHQvLTv4L2a97eXpm9t3YeJWkBaBhpkKbVnjjLm3
         nquw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZwcWr9VWmfqG3HHy672VEg4BSNiSaWATEy9aAwdElOM=;
        b=CtXDPxD+cWSrRDGpLaNSCSsEkmRk8EC1BzDZ+HbHSbTfudN2l/M27Vh0pSKqQ3z3IL
         HiM6yItb48q6ObvznFTETswgxOxfFmwLSRqi/eaGkvo8znty2EZgenAqONSu3ziLngdE
         cWGjDDruhAbFW6VOY7AQ4v+8c69mqfdRJb1/ImWPrYQZOK+z0Yz9gmay+JcDUcDOOszm
         hv980qKE58XZI0BS11psRIZ9R+xCd0CpTgi+VdNI5PW6Ibho6mfCZywEB6JaF8yDrNEz
         /ctUsECmfN00PIhCJPhW60Si15ZOc89bJI2WOwA/1PXP03JkqdPePSfamwPaO9tYUpRz
         hlKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h58si9192967eda.50.2019.05.28.02.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 02:08:24 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 784DAB010;
	Tue, 28 May 2019 09:08:23 +0000 (UTC)
Date: Tue, 28 May 2019 11:08:21 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Daniel Colascione <dancol@google.com>,
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
Message-ID: <20190528090821.GU1658@dhcp22.suse.cz>
References: <20190520092801.GA6836@dhcp22.suse.cz>
 <20190521025533.GH10039@google.com>
 <20190521062628.GE32329@dhcp22.suse.cz>
 <20190527075811.GC6879@google.com>
 <20190527124411.GC1658@dhcp22.suse.cz>
 <20190528032632.GF6879@google.com>
 <20190528062947.GL1658@dhcp22.suse.cz>
 <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528084927.GB159710@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > if we went with the per vma fd approach then you would get this
> > > > feature automatically because map_files would refer to file backed
> > > > mappings while map_anon could refer only to anonymous mappings.
> > >
> > > The reason to add such filter option is to avoid the parsing overhead
> > > so map_anon wouldn't be helpful.
> > 
> > Without chiming on whether the filter option is a good idea, I'd like
> > to suggest that providing an efficient binary interfaces for pulling
> > memory map information out of processes.  Some single-system-call
> > method for retrieving a binary snapshot of a process's address space
> > complete with attributes (selectable, like statx?) for each VMA would
> > reduce complexity and increase performance in a variety of areas,
> > e.g., Android memory map debugging commands.
> 
> I agree it's the best we can get *generally*.
> Michal, any opinion?

I am not really sure this is directly related. I think the primary
question that we have to sort out first is whether we want to have
the remote madvise call process or vma fd based. This is an important
distinction wrt. usability. I have only seen pid vs. pidfd discussions
so far unfortunately.

An interface to query address range information is a separate but
although a related topic. We have /proc/<pid>/[s]maps for that right
now and I understand it is not a general win for all usecases because
it tends to be slow for some. I can see how /proc/<pid>/map_anons could
provide per vma information in a binary form via a fd based interface.
But I would rather not conflate those two discussions much - well except
if it could give one of the approaches more justification but let's
focus on the madvise part first.
-- 
Michal Hocko
SUSE Labs

