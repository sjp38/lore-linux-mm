Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5451EC46460
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:32:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1602A20B7C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:32:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1602A20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C5A06B027E; Tue, 28 May 2019 08:32:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 977DE6B027F; Tue, 28 May 2019 08:32:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88CC16B0281; Tue, 28 May 2019 08:32:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4436B027E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:32:11 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t58so32816497edb.22
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:32:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WavWU/ixMeExR2vQNvDxg1J6RoINAykgtfKZR5IugME=;
        b=LVwnoC861kEbL78HQYvwitK3xVpDIeDYnoN4yghJj7IDCAzA4zu+UvKC9ux+voA6Rd
         Twf8o8UnhHkLzr8nk/lpO26TLWcz8sEmEb46nJ7xIbenqT+0dVoq7VR3S+toO8OZrLIG
         rXXFMw4a6JIgc17vczydPcWJ0miMv1QnmXGpb8gr6VGjGQ6Pp/qLbIGyBOosM52aBUww
         3Nr6UY2erxeL1wfTGARpfKnl+Jb6tFTc3Z/9t2Ftx0+7Dlvx2U3wberVhP+Yagh3oMKP
         BXXfsfwBJ+78x4TmYg2gXXGJFQv2j+FOPUSVqtMyXpfDVdovR4wjKxNAg+EgisEgbF62
         S0AA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV8OWloYsXMWJLraSJ7/sx6Gfb+wK0iWD81ITrC08GnLFjAgdPE
	yH5joOJf+FCBzxSOav+A+th3SNqbBg/18tJkpwxy5MdNMwa+5IVgihNd/Y5kLq6p34dg88CuwAn
	wh9eZOuHObVtuKXGdfn2hyjKQHAcqL6Oh5wu5kbpSjwp0BZDX8PGtB95m2wN/rPQ=
X-Received: by 2002:a17:906:a28d:: with SMTP id i13mr102862890ejz.148.1559046730771;
        Tue, 28 May 2019 05:32:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwb27d1b/XWi27Tc+FXMn3C5jPuh+S0fijhI/3cQGaV5eCo41dikWAZXZhb0FLe59I6dYJ
X-Received: by 2002:a17:906:a28d:: with SMTP id i13mr102862805ejz.148.1559046729882;
        Tue, 28 May 2019 05:32:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559046729; cv=none;
        d=google.com; s=arc-20160816;
        b=quPxPf4xo+Y0nRdLuLSo6roCHYX8ueziPH8U6KUAb5l51uLYgVQz+1uRiFd1OV95q9
         szZKrLQXaajd+ZOqkhKDWf3ACzAWCSpdgeYv8msolx5IVESgy0m4gnn3UicqaHM2Pth/
         SLWMnNY0W9UvFVZFec+zJ1wGKnrYt0e57eHUOVerOEv1mtUbQRfPAMTDzOXk16+AT7qY
         KIJeupc0MuXlgsxr1ZtGOgfhJ7sVvzFIaBBUOQqzXjC39nu+H/hmVldUsu11dtbFjmel
         J06BC6z+TR6SXq5WpQhQVs7tHquykysSZSgf3HgD8eltLwDutR7yjLoE67FWnhKUMlvD
         xFtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WavWU/ixMeExR2vQNvDxg1J6RoINAykgtfKZR5IugME=;
        b=IPjbuq9u5IOL08Oou03fM0mC5GnzQc9yN9x8hL0+HjCD3hrMhW5H4zoj0J5n1PcDWu
         Op48AGXQJ4aw9Ip5lXgj128HIXsGJLjuXY0nkQdx24muZ9MUTOFOR/Z+BKtFwc30xAzp
         eImytwAI7lAegcImv7+mNwWi4nb/fiRZmw2S45opp20qDmnzkKxN5Tba7DG2thxmVTmp
         9QkhI6YfGbDc/2Ij3Iu1lCvUbENn07Ebs0aHzb6NIgnudp54YCWL9Qj9OwfdzZmSexAP
         /vSUurnWPJX8ffgrzcGKAc0rUaA168DJzCcFyiOBMVO21ikIOq6ZsPEgj/XOLs5nbuCu
         BTSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rn6si4350075ejb.369.2019.05.28.05.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 05:32:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 30483B016;
	Tue, 28 May 2019 12:32:09 +0000 (UTC)
Date: Tue, 28 May 2019 14:32:08 +0200
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
Message-ID: <20190528123208.GC1658@dhcp22.suse.cz>
References: <20190528062947.GL1658@dhcp22.suse.cz>
 <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com>
 <20190528090821.GU1658@dhcp22.suse.cz>
 <CAKOZueux3T4_dMOUK6R=ZHhCFaSSstOCPh_KSwSMCW_yp=jdSg@mail.gmail.com>
 <20190528103312.GV1658@dhcp22.suse.cz>
 <CAKOZueuRAtps+YZ1g2SOevBrDwE6tWsTuONJu1NLgvW7cpA-ug@mail.gmail.com>
 <20190528114923.GZ1658@dhcp22.suse.cz>
 <CAKOZueuerHTCPbQqowSxi-_sRsqxYQQqgyi1UOh7EkZcS3DCnA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZueuerHTCPbQqowSxi-_sRsqxYQQqgyi1UOh7EkZcS3DCnA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 05:11:16, Daniel Colascione wrote:
> On Tue, May 28, 2019 at 4:49 AM Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > > We have various system calls that provide hints for open files, but
> > > the memory operations are distinct. Modeling anonymous memory as a
> > > kind of file-backed memory for purposes of VMA manipulation would also
> > > be a departure from existing practice. Can you help me understand why
> > > you seem to favor the FD-per-VMA approach so heavily? I don't see any
> > > arguments *for* an FD-per-VMA model for remove memory manipulation and
> > > I see a lot of arguments against it. Is there some compelling
> > > advantage I'm missing?
> >
> > First and foremost it provides an easy cookie to the userspace to
> > guarantee time-to-check-time-to-use consistency.
> 
> But only for one VMA at a time.

Which is the unit we operate on, right?

> > It also naturally
> > extend an existing fadvise interface that achieves madvise semantic on
> > files.
> 
> There are lots of things that madvise can do that fadvise can't and
> that don't even really make sense for fadvise, e.g., MADV_FREE. It
> seems odd to me to duplicate much of the madvise interface into
> fadvise so that we can use file APIs to give madvise hints. It seems
> simpler to me to just provide a mechanism to put the madvise hints
> where they're needed.

I do not see why we would duplicate. I confess I haven't tried to
implement this so I might be overlooking something but it seems to me
that we could simply reuse the same functionality from both APIs.

> > I am not really pushing hard for this particular API but I really
> > do care about a programming model that would be sane.
> 
> You've used "sane" twice so far in this message. Can you specify more
> precisely what you mean by that word?

Well, I would consider a model which would prevent from unintended side
effects (e.g. working on a completely different object) without a tricky
synchronization sane.

> I agree that there needs to be
> some defense against TOCTOU races when doing remote memory management,
> but I don't think providing this robustness via a file descriptor is
> any more sane than alternative approaches. A file descriptor comes
> with a lot of other features --- e.g., SCM_RIGHTS, fstat, and a
> concept of owning a resource --- that aren't needed to achieve
> robustness.
> 
> Normally, a file descriptor refers to some resource that the kernel
> holds as long as the file descriptor (well, the open file description
> or struct file) lives -- things like graphics buffers, files, and
> sockets. If we're using an FD *just* as a cookie and not a resource,
> I'd rather just expose the cookie directly.

You are absolutely right. But doesn't that apply to any other
revalidation method that would be tracking VMA status as well. As I've
said I am not married to this approach as long as there are better
alternatives. So far we are in a discussion what should be the actual
semantic of the operation and how much do we want to tolerate races. And
it seems that we are diving into implementation details rather than
landing with a firm decision that the current proposed API is suitable
or not.

> > If we have a
> > different means to achieve the same then all fine by me but so far I
> > haven't heard any sound arguments to invent something completely new
> > when we have established APIs to use.
> 
> Doesn't the next sentence describe something profoundly new? :-)
> 
> > Exporting anonymous mappings via
> > proc the same way we do for file mappings doesn't seem to be stepping
> > outside of the current practice way too much.
> 
> It seems like a radical departure from existing practice to provide
> filesystem interfaces to anonymous memory regions, e.g., anon_vma.
> You've never been able to refer to those memory regions with file
> descriptors.
> 
> All I'm suggesting is that we take the existing madvise mechanism,
> make it work cross-process, and make it robust against TOCTOU
> problems, all one step at a time. Maybe my sense of API "size" is
> miscalibrated, but adding a new type of FD to refer to anonymous VMA
> regions feels like a bigger departure and so requires stronger
> justification, especially if the result of the FD approach is probably
> something less efficient than a cookie-based one.

Feel free to propose the way to achieve that in the respective email
thread.
 
> > and we should focus on discussing whether this is a
> > sane model. And I think it would be much better to discuss that under
> > the respective patch which introduces that API rather than here.
> 
> I think it's important to discuss what that API should look like. :-)

It will be fun to follow this discussion and make some sense of
different parallel threads.

-- 
Michal Hocko
SUSE Labs

