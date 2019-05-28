Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FB1DC04E84
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:12:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB19220989
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:12:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BAMyLVSt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB19220989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DF176B026E; Tue, 28 May 2019 07:12:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78F5B6B026F; Tue, 28 May 2019 07:12:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 658146B0273; Tue, 28 May 2019 07:12:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD3E6B026E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 07:12:17 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a5so7299924pla.3
        for <linux-mm@kvack.org>; Tue, 28 May 2019 04:12:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=yjDDJ/2zUpUMynGNYx1IGW1H0lSoDeccz7vZj839ckk=;
        b=EqPZnz3bUke18/fU0Fws2yGErnz6pznYcv2vVAsxEfFQqDLMbhwHHZcx7B5ds1pYnO
         dtjSKbOdnJqRRoqIw3FQ5EHGfxyZ6CbnmsgfkAWIJpBr7uJ42FsLozBMUFISwamSC+09
         /KHs6rmt+VRk2+wv83yXyuIr5YmDryE9ZqGrp8CXoVLQWxYd14K+/lR1vhGoMxjOhoJv
         RUgJUduNP4VXLOk/U8+QFBZ4Qv8Pr6ogUaR94jDuQddOhRh3sQXDCy5vdDkV3Uqw6Tv/
         +80INWdmkddzOr1Vs5Qzm783cxVxPx9bJi6nDTo/DLsaMaay4QIb6cUP/HpXHCrcdckz
         TYtw==
X-Gm-Message-State: APjAAAV9a/bSQqPe7/iENhzg5dtmcKi6NeE15O369u2e8A+3ry5Kn5wQ
	fzAXbsUvBURqlZldjzvdu0NsHNX93ykCQB/TuXeS27KJ0mJ0N9epOzdXV1iYCY5ibRnIdlRKb8V
	yJZufRch9kGJSRYfzKY+y9Uy2FE0HH80tZTjQym5OU3vecB1RIVbxpCtfKft2vD4=
X-Received: by 2002:a63:560d:: with SMTP id k13mr131016285pgb.124.1559041936782;
        Tue, 28 May 2019 04:12:16 -0700 (PDT)
X-Received: by 2002:a63:560d:: with SMTP id k13mr131016178pgb.124.1559041935871;
        Tue, 28 May 2019 04:12:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559041935; cv=none;
        d=google.com; s=arc-20160816;
        b=AmT0jPmUcPHa1Yj33NVQa9/zVPITh4N8yvQlXi+wvpH3K521T4/E0mShjk6We9i/oS
         h7EyJKbvMyMi55qgsevU2d95eN1MmsUf/2ZBN2tsjvkna/gggDi+bjjtDd2Iuec+UL7U
         i0AtSSRgkGwcJz5m0APCQUHDJDu19Pnuyioa4g2TseC35LE3PYnTa79NDDBTwuBkdGgn
         sWk3vxRAzibmyCkV8R7uAB8DEryZ+FbCE8F5TcQ6rksqVZhsgxPHQRtUJ9JZd3Ck3OSf
         cuwPhPjswzf/QQgQMHDMRm3+6xcqQQjMhM9cwfz8i3TE16QfQ2h45V8RBEwpBMqsuJiR
         mgZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=yjDDJ/2zUpUMynGNYx1IGW1H0lSoDeccz7vZj839ckk=;
        b=pc8TLqXLDAgzjMzYpCEbKJx3wU2QFE7/t8sW3EYmniMoU5yYMxL4FvGzzCaNmmwmWs
         F4mNXj5J2VrOCdtugVW/1cA8MO9HQeyrQmLzICiVZAAKf6yxer//ed/h9coHC5wXH7yG
         ES7FJPyUuKT++//9D7Aitnmo4fV3YumgT4VAAouQ4+6/WU5ciHs1bXZBpd/DHS9ecTEJ
         S1ReHsHICyv1w82p7j6gmC1vj7LnF8BQakHNNUuRqo0K5QxJntnXthJqrqp6hy1ZslOn
         DmaU5WuxORnQYVJCMabfZS1BZKAe5pdkb9AS2N6oLBkOeE1TniS1AsHyWo8DxbW5Rm8L
         LNYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BAMyLVSt;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w25sor14033693pfg.23.2019.05.28.04.12.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 04:12:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BAMyLVSt;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yjDDJ/2zUpUMynGNYx1IGW1H0lSoDeccz7vZj839ckk=;
        b=BAMyLVStI/JfGQ5nZP1Aq6dmfML42NpXtmeu9rpv5EXDkgpwcdBMCj5BoUHY9SnjOr
         yXxPTGVcm1Hx0gzDRbOROR6xHoNkDjn+8YH4KGdIS5yqGcjJ8cvw63QBO+FYInAAUo4o
         0KURztiHWmmscsTig7NfQWSmzr3GNbCUKlczYANC0/1T5VGmOQ8Qg4G7aSkj3aFyLYsQ
         zZpqol/Gx09xwV9+VHJCNn0Sz6/inKLr1Szw9JTeIx3fNDBJbilrdXcSAmKL/pXV54WA
         RgyON09Us9klUuI1rvB0RNRW2Y1gYFDUh3tFWPkmUrUKehaLpn3Z2tI4BxK1tpq2Owne
         yOeQ==
X-Google-Smtp-Source: APXvYqxNxlP/WY14NSuqDMVHVvQZEWNgz/oPlh3HFqtK2YOKKCKnz4314RbUCguqjl5JrhkAUkvk6g==
X-Received: by 2002:a05:6a00:43:: with SMTP id i3mr64202949pfk.113.1559041935394;
        Tue, 28 May 2019 04:12:15 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id f16sm6699086pja.18.2019.05.28.04.12.11
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 28 May 2019 04:12:14 -0700 (PDT)
Date: Tue, 28 May 2019 20:12:08 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
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
Message-ID: <20190528111208.GA30365@google.com>
References: <20190527075811.GC6879@google.com>
 <20190527124411.GC1658@dhcp22.suse.cz>
 <20190528032632.GF6879@google.com>
 <20190528062947.GL1658@dhcp22.suse.cz>
 <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com>
 <20190528090821.GU1658@dhcp22.suse.cz>
 <20190528103256.GA9199@google.com>
 <20190528104117.GW1658@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528104117.GW1658@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 12:41:17PM +0200, Michal Hocko wrote:
> On Tue 28-05-19 19:32:56, Minchan Kim wrote:
> > On Tue, May 28, 2019 at 11:08:21AM +0200, Michal Hocko wrote:
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
> > With current usecase, it's per-process API with distinguishable anon/file
> > but thought it could be easily extended later for each address range
> > operation as userspace getting smarter with more information.
> 
> Never design user API based on a single usecase, please. The "easily
> extended" part is by far not clear to me TBH. As I've already mentioned
> several times, the synchronization model has to be thought through
> carefuly before a remote process address range operation can be
> implemented.

I agree with you that we shouldn't design API on single usecase but what
you are concerning is actually not our usecase because we are resilient
with the race since MADV_COLD|PAGEOUT is not destruptive.
Actually, many hints are already racy in that the upcoming pattern would
be different with the behavior you thought at the moment.

If you are still concerning of address range synchronization, how about
moving such hints to per-process level like prctl?
Does it make sense to you?

