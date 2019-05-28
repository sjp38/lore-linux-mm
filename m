Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A86AC072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:49:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF60220717
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:49:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF60220717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 442C16B026E; Tue, 28 May 2019 07:49:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F11D6B026F; Tue, 28 May 2019 07:49:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2928A6B0272; Tue, 28 May 2019 07:49:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA8236B026E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 07:49:26 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x16so32718995edm.16
        for <linux-mm@kvack.org>; Tue, 28 May 2019 04:49:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=atXQTwSrHhre7m/LtGLjM/skWxOmJ9716T3FRxL2EjA=;
        b=EVDv9T9XufJvJhUVqUqUsC/kPOYFEjwZ4MdZYFIpjtLxiLji0q/lRNSp5RtMPjWv5r
         neWIEi5PgNOBkhlKzGkS4tYRyUYZdte1jCbS+7kVwH0mGG0H6XVY4AUqZfo/QpsrRGQ+
         GYWrk7MK1rPOEJGw1nIGSXrMEXnuZkyfoop7wrzr3dOJ+Hp9mnmWDNmnVH6ZUYMCzD7M
         fUAltdjoEi1MYZrwm3mSH64may08NrrbMJdxZVKrdXct3zWBk8jmME8mNgzMpbWKDzXi
         IE2YM/p1Qz2j3OZif2cvJc2GpMznMIGCWqKvzAraYkKtD1VIv0djXmUZSciOy5r5nsgk
         b8CA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWExOeflDN1DQvg0iaw4cv1MoWBydIQ2iZwpqUrlJnGwD8Tc45F
	I/Bg5sxQEi7E+PNYown35CtJgkcadhedeqET4//GQuCG5/tNvyTDDdTc1GdVgxyTezB5yvMbdxJ
	fHR/TV954hMfuLOJcmimiZnBCwuR/ZzVtuhqGXpIEZxr1l0zakyGsUOzY8uPibok=
X-Received: by 2002:a50:89e3:: with SMTP id h32mr67769220edh.51.1559044166372;
        Tue, 28 May 2019 04:49:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/WOZKtyxcpiOll3BBPyIAyyLjuBK065oOSgZvqtAbCtSHTTR68EYoxnkc+Kfs+vU2SGh3
X-Received: by 2002:a50:89e3:: with SMTP id h32mr67769154edh.51.1559044165464;
        Tue, 28 May 2019 04:49:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559044165; cv=none;
        d=google.com; s=arc-20160816;
        b=cXNd86K+CUcOTmEeQO8hdlq2MsVpJGPXYcrVxyiUBYhrnm3gxj1343y5jxR2SThZ0Z
         cHKUcqiqzvWmZU3oSiI6jzvPpnJZlSF5Jq9DtadeAO3HzyLQ23Ysnf2SftcJQQOrmM7o
         QDFZdNSSTTUZrGmqGZFGZsVI/+Mgf6m0PEZoFCZWOXmoG5koSaXFaOnLICJORNc+gjqe
         i3ncYwQtxc7ysbYWVDqZ76CS5/EpDhpw4siLFfhcnZ68U+OE3azkTEGg40sjhpuaAM33
         DUuUd9C5hvz9JEHrO/AfwvfSKmgvY8akVZJqljaR2QtatYTBxvPYDfElSXF9QisPAyxJ
         uVDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=atXQTwSrHhre7m/LtGLjM/skWxOmJ9716T3FRxL2EjA=;
        b=MXYx5SsXQgfbOQIRsrnTVkKffgbEQrxpbp+/U/95gxjod/R95p4zLaUgYBZYVbq0pX
         xGbbRisSNIapyc5+4ZRZ/+Pok2jJMib/GUm7BNFT+caQlRXAyfSe1W5GEYVJ+yVZECjQ
         YaD0AKIjKMpllQsEkYCRsgFdDetRpB11RR40vrX2bpZNO0bonvp+Zl/wplikvwIvx93B
         kLCLe85qeZOUPvjZlUaXkxiDuC53+67vZBdGAHa3OOZsNAA62t8OL+Xa3rQiweH16aHr
         iQ+feEuRhPH1xeawdMqz5RMvSi7Z27r2FcJmIG1e2rzOjXrfH+YByqVhQmFSgwidGvv6
         1FTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x26si1247900edm.106.2019.05.28.04.49.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 04:49:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9723CAEF9;
	Tue, 28 May 2019 11:49:24 +0000 (UTC)
Date: Tue, 28 May 2019 13:49:23 +0200
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
Message-ID: <20190528114923.GZ1658@dhcp22.suse.cz>
References: <20190527124411.GC1658@dhcp22.suse.cz>
 <20190528032632.GF6879@google.com>
 <20190528062947.GL1658@dhcp22.suse.cz>
 <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com>
 <20190528090821.GU1658@dhcp22.suse.cz>
 <CAKOZueux3T4_dMOUK6R=ZHhCFaSSstOCPh_KSwSMCW_yp=jdSg@mail.gmail.com>
 <20190528103312.GV1658@dhcp22.suse.cz>
 <CAKOZueuRAtps+YZ1g2SOevBrDwE6tWsTuONJu1NLgvW7cpA-ug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZueuRAtps+YZ1g2SOevBrDwE6tWsTuONJu1NLgvW7cpA-ug@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 04:21:44, Daniel Colascione wrote:
> On Tue, May 28, 2019 at 3:33 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 28-05-19 02:39:03, Daniel Colascione wrote:
> > > On Tue, May 28, 2019 at 2:08 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> > > > > On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > > > > > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > > > > if we went with the per vma fd approach then you would get this
> > > > > > > > feature automatically because map_files would refer to file backed
> > > > > > > > mappings while map_anon could refer only to anonymous mappings.
> > > > > > >
> > > > > > > The reason to add such filter option is to avoid the parsing overhead
> > > > > > > so map_anon wouldn't be helpful.
> > > > > >
> > > > > > Without chiming on whether the filter option is a good idea, I'd like
> > > > > > to suggest that providing an efficient binary interfaces for pulling
> > > > > > memory map information out of processes.  Some single-system-call
> > > > > > method for retrieving a binary snapshot of a process's address space
> > > > > > complete with attributes (selectable, like statx?) for each VMA would
> > > > > > reduce complexity and increase performance in a variety of areas,
> > > > > > e.g., Android memory map debugging commands.
> > > > >
> > > > > I agree it's the best we can get *generally*.
> > > > > Michal, any opinion?
> > > >
> > > > I am not really sure this is directly related. I think the primary
> > > > question that we have to sort out first is whether we want to have
> > > > the remote madvise call process or vma fd based. This is an important
> > > > distinction wrt. usability. I have only seen pid vs. pidfd discussions
> > > > so far unfortunately.
> > >
> > > I don't think the vma fd approach is viable. We have some processes
> > > with a *lot* of VMAs --- system_server had 4204 when I checked just
> > > now (and that's typical) --- and an FD operation per VMA would be
> > > excessive.
> >
> > What do you mean by excessive here? Do you expect the process to have
> > them open all at once?
> 
> Minchan's already done timing. More broadly, in an era with various
> speculative execution mitigations, making a system call is pretty
> expensive.

This is a completely separate discussion. This could be argued about
many other syscalls. Let's make the semantic correct first before we
even start thinking about mutliplexing. It is easier to multiplex on an
existing and sane interface.

Btw. Minchan concluded that multiplexing is not really all that
important based on his numbers http://lkml.kernel.org/r/20190527074940.GB6879@google.com

[...]

> > Is this really too much different from /proc/<pid>/map_files?
> 
> It's very different. See below.
> 
> > > > An interface to query address range information is a separate but
> > > > although a related topic. We have /proc/<pid>/[s]maps for that right
> > > > now and I understand it is not a general win for all usecases because
> > > > it tends to be slow for some. I can see how /proc/<pid>/map_anons could
> > > > provide per vma information in a binary form via a fd based interface.
> > > > But I would rather not conflate those two discussions much - well except
> > > > if it could give one of the approaches more justification but let's
> > > > focus on the madvise part first.
> > >
> > > I don't think it's a good idea to focus on one feature in a
> > > multi-feature change when the interactions between features can be
> > > very important for overall design of the multi-feature system and the
> > > design of each feature.
> > >
> > > Here's my thinking on the high-level design:
> > >
> > > I'm imagining an address-range system that would work like this: we'd
> > > create some kind of process_vm_getinfo(2) system call [1] that would
> > > accept a statx-like attribute map and a pid/fd parameter as input and
> > > return, on output, two things: 1) an array [2] of VMA descriptors
> > > containing the requested information, and 2) a VMA configuration
> > > sequence number. We'd then have process_madvise() and other
> > > cross-process VM interfaces accept both address ranges and this
> > > sequence number; they'd succeed only if the VMA configuration sequence
> > > number is still current, i.e., the target process hasn't changed its
> > > VMA configuration (implicitly or explicitly) since the call to
> > > process_vm_getinfo().
> >
> > The sequence number is essentially a cookie that is transparent to the
> > userspace right? If yes, how does it differ from a fd (returned from
> > /proc/<pid>/map_{anons,files}/range) which is a cookie itself and it can
> 
> If you want to operate on N VMAs simultaneously under an FD-per-VMA
> model, you'd need to have those N FDs all open at the same time *and*
> add some kind of system call that accepted those N FDs and an
> operation to perform. The sequence number I'm proposing also applies
> to the whole address space, not just one VMA. Even if you did have
> these N FDs open all at once and supplied them all to some batch
> operation, you couldn't guarantee via the FD mechanism that some *new*
> VMA didn't appear in the address range you want to manipulate. A
> global sequence number would catch this case. I still think supplying
> a list of address ranges (like we already do for scatter-gather IO) is
> less error-prone, less resource-intensive, more consistent with
> existing practice, and equally flexible, especially if we start
> supporting destructive cross-process memory operations, which may be
> useful for things like checkpointing and optimizing process startup.

I have a strong feeling you are over optimizing here. We are talking
about a pro-active memory management and so far I haven't heard any
usecase where all this would happen in the fast path. There are
essentially two usecases I have heard so far. Age/Reclaim the whole
process (with anon/fs preferency) and do the same on a particular
and well specified range (e.g. a garbage collector or an inactive large
image in browsert etc...). The former doesn't really care about parallel
address range manipulations because it can tolerate them. The later is a
completely different story.

Are there any others where saving few ms matter so much?

> Besides: process_vm_readv and process_vm_writev already work on
> address ranges. Why should other cross-process memory APIs use a very
> different model for naming memory regions?

I would consider those APIs not a great example. They are racy on
more levels (pid reuse and address space modification), and require a
non-trivial synchronization. Do you want something similar for madvise
on a non-cooperating remote application?
 
> > be used to revalidate when the operation is requested and fail if
> > something has changed. Moreover we already do have a fd based madvise
> > syscall so there shouldn't be really a large need to add a new set of
> > syscalls.
> 
> We have various system calls that provide hints for open files, but
> the memory operations are distinct. Modeling anonymous memory as a
> kind of file-backed memory for purposes of VMA manipulation would also
> be a departure from existing practice. Can you help me understand why
> you seem to favor the FD-per-VMA approach so heavily? I don't see any
> arguments *for* an FD-per-VMA model for remove memory manipulation and
> I see a lot of arguments against it. Is there some compelling
> advantage I'm missing?

First and foremost it provides an easy cookie to the userspace to
guarantee time-to-check-time-to-use consistency. It also naturally
extend an existing fadvise interface that achieves madvise semantic on
files. I am not really pushing hard for this particular API but I really
do care about a programming model that would be sane. If we have a
different means to achieve the same then all fine by me but so far I
haven't heard any sound arguments to invent something completely new
when we have established APIs to use. Exporting anonymous mappings via
proc the same way we do for file mappings doesn't seem to be stepping
outside of the current practice way too much.

All I am trying to say here is that process_madvise(fd, start, len) is
inherently racy API and we should focus on discussing whether this is a
sane model. And I think it would be much better to discuss that under
the respective patch which introduces that API rather than here.
-- 
Michal Hocko
SUSE Labs

