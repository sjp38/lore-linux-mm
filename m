Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE92BC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:21:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57F98208C3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:21:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="VLoUpTyN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57F98208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8FD76B026C; Tue, 28 May 2019 07:21:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E664E6B026E; Tue, 28 May 2019 07:21:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D564E6B026F; Tue, 28 May 2019 07:21:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id B3C176B026C
	for <linux-mm@kvack.org>; Tue, 28 May 2019 07:21:57 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id q191so8310291vkh.5
        for <linux-mm@kvack.org>; Tue, 28 May 2019 04:21:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=PDuFfWfADQYlVhXy+17dLFypWmYPH1IcELfasjjhB/Q=;
        b=O6PJJdkESFy1te01/bBJTevdBI9Vkm1K2AvbxSnxx37mJ++0X5+U75TUZeCq7kOa0j
         +db3uFobuvIX5S3YldCh0Y5zUOXNayMLVrtredl7/cHA4mOM+PMoI2SN/738pRYG/+8T
         V9MyvyhQyBeXmy4i9pHSbs+s/bIcsiny9lDWcLZhEwfoJAWJ0nV8amW1JJQ0mNWOueUV
         t+OoBBgIEmeJv9oEMjU/u8KnGx5MYdQ9/QJb0r4tA4Vi1bLhTGjRZk+4F/y7pq8OS64t
         DGu/KaRgz8T02kZ5JdAKSVBRKMOyujSHvJ72N8bWgDbUhru0AmM4LlYvgClRYcc3FGQF
         2TGw==
X-Gm-Message-State: APjAAAUVLl1E1PqoxwXcMbvJzz8ImjWIP8Q4GgZIYS3WJWfbMdX/ggim
	/Mn3zQX2mbiFKHMEbETaeGwLyOLNDJy7Z3ue5ENJeTn7PzJHdIm1909ENVwYzY/uvlrQB7QxKLh
	xh2J1VQoNMqq4007IMpWl5Tb8bXNpZsfKKoo8G5fy2vnnyV6nQyffN1bDMOhYlBTcQA==
X-Received: by 2002:a67:1783:: with SMTP id 125mr52832389vsx.54.1559042517287;
        Tue, 28 May 2019 04:21:57 -0700 (PDT)
X-Received: by 2002:a67:1783:: with SMTP id 125mr52832345vsx.54.1559042516347;
        Tue, 28 May 2019 04:21:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559042516; cv=none;
        d=google.com; s=arc-20160816;
        b=nMZilNm165JQamy2SpKGMfpnR+HhY7Ho0jzNGqeQ7+7oY4gWcGKBCJow0PpXt+tiCb
         fXU0ltJ0p61txocZvRC3Y4vVQSATzQNWzM7IfFjVqAn0SszOukVyKHWhzHbwyqux/uJ5
         qEBiYrg2daP+vESCgPK3HabtXl0MUo37zrATZRLW4vaFRGZGdaGtSfVl2+9aw03aCGp9
         E1A6Z3sEvdiXdBkSjJx0Mbl8opXlJPFcoBOGV+wfPr3bZFsmeXQH7/dv5finppfCtJZG
         ESHkh+2npI+p/PLjx0aOdo2dqd+H+yD0MYhfH8eEvhSMtTubOsZBuAxadTCdRC6EZup+
         riyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=PDuFfWfADQYlVhXy+17dLFypWmYPH1IcELfasjjhB/Q=;
        b=dBqQn/PGOArIo8SS2IfDvOjDO9wou4Udm+COrVBT1OsXhNY4rsBv7eKn4MxGVWjXX+
         0b5CmYNLnU/jAi3Q0wZtOjpVZec4ryqmu20SgLrjT+LcVJUegQrXG4jZ0sJt2Ys4KuX9
         ZLk6TZSd7AaaWvV8rLFQ6f/TsL7E4bMpW6uzxs7K7xcaxXdNYEXkWeMHG4WM/voG9SIJ
         gGF9yJEPonWkGv5bHmElbbeyk5SWw7BfVqFAtRC1GZqWrbMsWwthbrnDivDOKYmgo0bu
         7onkPo6HA5oP78+zRErrWFFL23Du9xZ2NT/UksH1iYdH3GH1W9kNNNynT8BL0rZM5+w9
         +bIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VLoUpTyN;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w205sor5290399vsw.47.2019.05.28.04.21.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 04:21:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VLoUpTyN;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PDuFfWfADQYlVhXy+17dLFypWmYPH1IcELfasjjhB/Q=;
        b=VLoUpTyNlV3VW+ZBKjhY4F2iodWLKJkOJWCcnc1iQ3S6WqX2wNz+wYGdlBAly2YEJf
         uwwLyvZqMg/jMKAB/tZPQ+2ICrRKbnVTNJGETNRLZynk2zIaOTfaj6IYsHDG7sHXEAfi
         tf1lTm9Esb49Q5xEnb/dkGnz8h1X3NMxdt78DC7CR2HhkStWlDts8NuCGFygXnmv115s
         1lI+m9MnaSbZGLyglKlPWyaQXYqrNsj78LAV6rWH3ZAsxyADaY5fvGCYOsgiKEqtbkS1
         npJ+IvL+NybFjMFW6KyJ/WEeI/+43OlTrvJYhB4hS0bN9U9HZTO31mqcjksbO57yPbPS
         lRAg==
X-Google-Smtp-Source: APXvYqweDq6pHRU4KDEZMJzO0GXUt0BWVFUr4wVrB+W7bnd4u/MvUMdhC5GOTz54S4XddsCNZCC189kI32ioA3U9q/0=
X-Received: by 2002:a67:dd8e:: with SMTP id i14mr30354365vsk.149.1559042515604;
 Tue, 28 May 2019 04:21:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190521062628.GE32329@dhcp22.suse.cz> <20190527075811.GC6879@google.com>
 <20190527124411.GC1658@dhcp22.suse.cz> <20190528032632.GF6879@google.com>
 <20190528062947.GL1658@dhcp22.suse.cz> <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com> <20190528090821.GU1658@dhcp22.suse.cz>
 <CAKOZueux3T4_dMOUK6R=ZHhCFaSSstOCPh_KSwSMCW_yp=jdSg@mail.gmail.com> <20190528103312.GV1658@dhcp22.suse.cz>
In-Reply-To: <20190528103312.GV1658@dhcp22.suse.cz>
From: Daniel Colascione <dancol@google.com>
Date: Tue, 28 May 2019 04:21:44 -0700
Message-ID: <CAKOZueuRAtps+YZ1g2SOevBrDwE6tWsTuONJu1NLgvW7cpA-ug@mail.gmail.com>
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 3:33 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 28-05-19 02:39:03, Daniel Colascione wrote:
> > On Tue, May 28, 2019 at 2:08 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> > > > On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > > > > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > > > if we went with the per vma fd approach then you would get this
> > > > > > > feature automatically because map_files would refer to file backed
> > > > > > > mappings while map_anon could refer only to anonymous mappings.
> > > > > >
> > > > > > The reason to add such filter option is to avoid the parsing overhead
> > > > > > so map_anon wouldn't be helpful.
> > > > >
> > > > > Without chiming on whether the filter option is a good idea, I'd like
> > > > > to suggest that providing an efficient binary interfaces for pulling
> > > > > memory map information out of processes.  Some single-system-call
> > > > > method for retrieving a binary snapshot of a process's address space
> > > > > complete with attributes (selectable, like statx?) for each VMA would
> > > > > reduce complexity and increase performance in a variety of areas,
> > > > > e.g., Android memory map debugging commands.
> > > >
> > > > I agree it's the best we can get *generally*.
> > > > Michal, any opinion?
> > >
> > > I am not really sure this is directly related. I think the primary
> > > question that we have to sort out first is whether we want to have
> > > the remote madvise call process or vma fd based. This is an important
> > > distinction wrt. usability. I have only seen pid vs. pidfd discussions
> > > so far unfortunately.
> >
> > I don't think the vma fd approach is viable. We have some processes
> > with a *lot* of VMAs --- system_server had 4204 when I checked just
> > now (and that's typical) --- and an FD operation per VMA would be
> > excessive.
>
> What do you mean by excessive here? Do you expect the process to have
> them open all at once?

Minchan's already done timing. More broadly, in an era with various
speculative execution mitigations, making a system call is pretty
expensive. If we have two options for remote VMA manipulation, one
that requires thousands of system calls (with the count proportional
to the address space size of the process) and one that requires only a
few system calls no matter how large the target process is, the latter
ought to start off with more points than the former under any kind of
design scoring.

> > VMAs also come and go pretty easily depending on changes in
> > protections and various faults.
>
> Is this really too much different from /proc/<pid>/map_files?

It's very different. See below.

> > > An interface to query address range information is a separate but
> > > although a related topic. We have /proc/<pid>/[s]maps for that right
> > > now and I understand it is not a general win for all usecases because
> > > it tends to be slow for some. I can see how /proc/<pid>/map_anons could
> > > provide per vma information in a binary form via a fd based interface.
> > > But I would rather not conflate those two discussions much - well except
> > > if it could give one of the approaches more justification but let's
> > > focus on the madvise part first.
> >
> > I don't think it's a good idea to focus on one feature in a
> > multi-feature change when the interactions between features can be
> > very important for overall design of the multi-feature system and the
> > design of each feature.
> >
> > Here's my thinking on the high-level design:
> >
> > I'm imagining an address-range system that would work like this: we'd
> > create some kind of process_vm_getinfo(2) system call [1] that would
> > accept a statx-like attribute map and a pid/fd parameter as input and
> > return, on output, two things: 1) an array [2] of VMA descriptors
> > containing the requested information, and 2) a VMA configuration
> > sequence number. We'd then have process_madvise() and other
> > cross-process VM interfaces accept both address ranges and this
> > sequence number; they'd succeed only if the VMA configuration sequence
> > number is still current, i.e., the target process hasn't changed its
> > VMA configuration (implicitly or explicitly) since the call to
> > process_vm_getinfo().
>
> The sequence number is essentially a cookie that is transparent to the
> userspace right? If yes, how does it differ from a fd (returned from
> /proc/<pid>/map_{anons,files}/range) which is a cookie itself and it can

If you want to operate on N VMAs simultaneously under an FD-per-VMA
model, you'd need to have those N FDs all open at the same time *and*
add some kind of system call that accepted those N FDs and an
operation to perform. The sequence number I'm proposing also applies
to the whole address space, not just one VMA. Even if you did have
these N FDs open all at once and supplied them all to some batch
operation, you couldn't guarantee via the FD mechanism that some *new*
VMA didn't appear in the address range you want to manipulate. A
global sequence number would catch this case. I still think supplying
a list of address ranges (like we already do for scatter-gather IO) is
less error-prone, less resource-intensive, more consistent with
existing practice, and equally flexible, especially if we start
supporting destructive cross-process memory operations, which may be
useful for things like checkpointing and optimizing process startup.

Besides: process_vm_readv and process_vm_writev already work on
address ranges. Why should other cross-process memory APIs use a very
different model for naming memory regions?

> be used to revalidate when the operation is requested and fail if
> something has changed. Moreover we already do have a fd based madvise
> syscall so there shouldn't be really a large need to add a new set of
> syscalls.

We have various system calls that provide hints for open files, but
the memory operations are distinct. Modeling anonymous memory as a
kind of file-backed memory for purposes of VMA manipulation would also
be a departure from existing practice. Can you help me understand why
you seem to favor the FD-per-VMA approach so heavily? I don't see any
arguments *for* an FD-per-VMA model for remove memory manipulation and
I see a lot of arguments against it. Is there some compelling
advantage I'm missing?

> > Or maybe the whole sequence number thing is overkill and we don't need
> > atomicity? But if there's a concern  that A shouldn't operate on B's
> > memory without knowing what it's operating on, then the scheme I've
> > proposed above solves this knowledge problem in a pretty lightweight
> > way.
>
> This is the main question here. Do we really want to enforce an external
> synchronization between the two processes to make sure that they are
> both operating on the same range - aka protect from the range going away
> and being reused for a different purpose. Right now it wouldn't be fatal
> because both operations are non destructive but I can imagine that there
> will be more madvise operations to follow (including those that are
> destructive) because people will simply find usecases for that. This
> should be reflected in the proposed API.

A sequence number gives us this synchronization at very low cost and
adds safety. It's also a general-purpose mechanism that would
safeguard *any* cross-process VM operation, not just the VM operations
we're discussing right now.

