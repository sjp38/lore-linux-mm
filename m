Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5120BC46470
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 09:39:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3946208CB
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 09:39:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Lsbugko9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3946208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31C756B0270; Tue, 28 May 2019 05:39:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A5B46B0272; Tue, 28 May 2019 05:39:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16C7E6B0273; Tue, 28 May 2019 05:39:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id E4FA06B0270
	for <linux-mm@kvack.org>; Tue, 28 May 2019 05:39:17 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id v20so1471446uao.2
        for <linux-mm@kvack.org>; Tue, 28 May 2019 02:39:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CJjr4QcKIDXguG3swKrHpGv8Kgka4wgBSkcZKXispCo=;
        b=Qm0xIUwCAyhTMNzOR7ppB0CKxUbPtJAxZLU2trt6l16xhxoeUjCvcf795cp43gTx7T
         SeVK+UxNiT2NZdigDW3g8SV8HAtGO1Msi3n8NZquJOVN2CGcNr9uojBrog/zeFrT7s01
         Y6u3Lr7q1dH7BHVrka+TCRnYgs2ZqYLRxaXPln/OXttAzUIMJMJeQDkfe77vG5xYzvk/
         7m5BPBPJNC44SGWcVJI/RCx6yTNgsk3UlWECCH4mduKdUE7YTiV2cqCB8i5az1lN7MhQ
         Ky2FCeciEjMXK6o2c49vyJvLxZTa6MTJEjALrZtF9MP3yq3G4hHa9TgLVXoZ5MQIJAYb
         XpVQ==
X-Gm-Message-State: APjAAAWQuJXGuoWvb+L0gTC4/dBQcbXYlJ/gdsJ2O54J4DCheyE8pULa
	RPJYHG19cArXBGPCTzovWwq/xrt4wbLaxZsnZy0X5V6BR5dkVzX3l1A848ncVvNsiCmGlbGnhs+
	tm17GFWHS8G7YLz9vnJehP4Lr5gBiJ5rW6BweEdA8dms7Jqq/mBXa64Z8gtzt9OOncA==
X-Received: by 2002:a67:f4cc:: with SMTP id s12mr22293264vsn.37.1559036357553;
        Tue, 28 May 2019 02:39:17 -0700 (PDT)
X-Received: by 2002:a67:f4cc:: with SMTP id s12mr22293227vsn.37.1559036356613;
        Tue, 28 May 2019 02:39:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559036356; cv=none;
        d=google.com; s=arc-20160816;
        b=wobo2FPwfG7wxaeaH+VbJEV11A7XoSn0FMG1z5txUqy7IQEIzOlt91cgur3MR/3qE9
         EA2NSxouUExdUR2GMcsYVafWDZ0AWDeLlOGZXXHlbi72UPWvTOORhbUQV+uxFU44QIpO
         smwG8p4nvQUBn/0kUhPXDs9SIIeaHKnetJZmaePYR0oCZ0uwxe8ekKuqZP7BPmvrXqNU
         gmz7PJyxOwe+Uwjrt6eCUdPr/c6cdjVeaMWdnoGIME3prZFO8zhUnwE46Y6sPa6u1Wc7
         47oKgcKWrezaWbXTy4iHEjkIVBmWaernRDGXWVmwcQMjd+tDWFhXZfN63Ce29DAx57sZ
         guZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CJjr4QcKIDXguG3swKrHpGv8Kgka4wgBSkcZKXispCo=;
        b=Is0N7ihF7KG5QtazXID72bpz/mknjcyscFqM7zrwP8L1N6VIwvkjWzlHI4EpX5imBx
         0p5LQH44730BApKGFrT7a3uB727rtuYyvkB3BW4d5kamO74vobV/EN8+yqGegPinU1GX
         5c0Mri/dBYKW506k8Qx0oNjF0oUUOpKc63hgm2FjZtsxdkBqhQuJX8RZmy9skxYwPA+i
         GYNa7GG9YJSwS09F20otmmr/poibbBuoPi0fYHqQyo1TMdyrLMQcMRt//qZh+ExbK3gK
         djjXjSSQzLaoYjP+IRDAMxMwl6mbRrcW1LXC249PH7odKGrW98D4k+twjIlQuURFRHDs
         LIwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Lsbugko9;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w12sor5446118vsl.101.2019.05.28.02.39.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 02:39:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Lsbugko9;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CJjr4QcKIDXguG3swKrHpGv8Kgka4wgBSkcZKXispCo=;
        b=Lsbugko9hzn5ewzyguy2BAClCZdJLimpQyRyG90whoByeaMaAbQ46O6FU6dSmcxqWr
         hKs67qWNIX/MEZ5z1nJ8+Ksn1CId0jT+DXvO7chx1Nh55zzdl+PLuy9zmM1VR8j+zfEc
         EuB/yLzbKUMNh/Zu2IbNK8g1b2vnDKp5UKzPBJFKtX2O8dWK8ZwEL2iFae9VXiFD4hvo
         Pa2M85EaQxc1ekoh2VG937kS9xAK34c5VnQQcpcQaPLlS7HM64Ht8zTlLckMfI/PqOoO
         239V28lfxy+EYvBP8PL0Ujdo+8pF0hZTKy/1TneaWQhdDJfqiNbI3TlDhBxEfZcp1l4U
         XJRQ==
X-Google-Smtp-Source: APXvYqyqaJpaQdz3kCZpqJPsONJNFevTsyHRx+oOKLYFF/6kJUKPg1PIxH+kmMy07GB5Iy+eTCVum2mQUtp7oaf3fw0=
X-Received: by 2002:a67:dd8e:: with SMTP id i14mr30137012vsk.149.1559036355824;
 Tue, 28 May 2019 02:39:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190520092801.GA6836@dhcp22.suse.cz> <20190521025533.GH10039@google.com>
 <20190521062628.GE32329@dhcp22.suse.cz> <20190527075811.GC6879@google.com>
 <20190527124411.GC1658@dhcp22.suse.cz> <20190528032632.GF6879@google.com>
 <20190528062947.GL1658@dhcp22.suse.cz> <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com> <20190528090821.GU1658@dhcp22.suse.cz>
In-Reply-To: <20190528090821.GU1658@dhcp22.suse.cz>
From: Daniel Colascione <dancol@google.com>
Date: Tue, 28 May 2019 02:39:03 -0700
Message-ID: <CAKOZueux3T4_dMOUK6R=ZHhCFaSSstOCPh_KSwSMCW_yp=jdSg@mail.gmail.com>
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

On Tue, May 28, 2019 at 2:08 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> > On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > if we went with the per vma fd approach then you would get this
> > > > > feature automatically because map_files would refer to file backed
> > > > > mappings while map_anon could refer only to anonymous mappings.
> > > >
> > > > The reason to add such filter option is to avoid the parsing overhead
> > > > so map_anon wouldn't be helpful.
> > >
> > > Without chiming on whether the filter option is a good idea, I'd like
> > > to suggest that providing an efficient binary interfaces for pulling
> > > memory map information out of processes.  Some single-system-call
> > > method for retrieving a binary snapshot of a process's address space
> > > complete with attributes (selectable, like statx?) for each VMA would
> > > reduce complexity and increase performance in a variety of areas,
> > > e.g., Android memory map debugging commands.
> >
> > I agree it's the best we can get *generally*.
> > Michal, any opinion?
>
> I am not really sure this is directly related. I think the primary
> question that we have to sort out first is whether we want to have
> the remote madvise call process or vma fd based. This is an important
> distinction wrt. usability. I have only seen pid vs. pidfd discussions
> so far unfortunately.

I don't think the vma fd approach is viable. We have some processes
with a *lot* of VMAs --- system_server had 4204 when I checked just
now (and that's typical) --- and an FD operation per VMA would be
excessive. VMAs also come and go pretty easily depending on changes in
protections and various faults. It's also not entirely clear what the
semantics of vma FDs should be over address space mutations, while the
semantics of address ranges are well-understood. I would much prefer
an interface operating on address ranges to one operating on VMA FDs,
both for efficiency and for consistency with other memory management
APIs.

> An interface to query address range information is a separate but
> although a related topic. We have /proc/<pid>/[s]maps for that right
> now and I understand it is not a general win for all usecases because
> it tends to be slow for some. I can see how /proc/<pid>/map_anons could
> provide per vma information in a binary form via a fd based interface.
> But I would rather not conflate those two discussions much - well except
> if it could give one of the approaches more justification but let's
> focus on the madvise part first.

I don't think it's a good idea to focus on one feature in a
multi-feature change when the interactions between features can be
very important for overall design of the multi-feature system and the
design of each feature.

Here's my thinking on the high-level design:

I'm imagining an address-range system that would work like this: we'd
create some kind of process_vm_getinfo(2) system call [1] that would
accept a statx-like attribute map and a pid/fd parameter as input and
return, on output, two things: 1) an array [2] of VMA descriptors
containing the requested information, and 2) a VMA configuration
sequence number. We'd then have process_madvise() and other
cross-process VM interfaces accept both address ranges and this
sequence number; they'd succeed only if the VMA configuration sequence
number is still current, i.e., the target process hasn't changed its
VMA configuration (implicitly or explicitly) since the call to
process_vm_getinfo().

This way, a process A that wants to perform some VM operation on
process B can slurp B's VMA configuration using process_vm_getinfo(),
figure out what it wants to do, and attempt to do it. If B modifies
its memory map in the meantime, If A finds that its local knowledge of
B's memory map has become invalid between the process_vm_getinfo() and
A taking some action based on the result, A can retry [3]. While A
could instead ptrace or otherwise suspend B, *then* read B's memory
map (knowing B is quiescent), *then* operate on B, the optimistic
approach I'm describing would be much lighter-weight in the typical
case. It's also pretty simple, IMHO. If the "operate on B" step is
some kind of vectorized operation over multiple address ranges, this
approach also gets us all-or-nothing semantics.

Or maybe the whole sequence number thing is overkill and we don't need
atomicity? But if there's a concern  that A shouldn't operate on B's
memory without knowing what it's operating on, then the scheme I've
proposed above solves this knowledge problem in a pretty lightweight
way.

[1] or some other interface
[2] or something more complicated if we want the descriptors to
contain variable-length elements, e.g., strings
[3] or override the sequence number check if it's feeling bold?

