Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 300D9C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 08:31:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFFD1214D8
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 08:31:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oZXsDC13"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFFD1214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 377766B0272; Tue, 28 May 2019 04:31:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34E186B0273; Tue, 28 May 2019 04:31:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 264166B0275; Tue, 28 May 2019 04:31:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0336D6B0272
	for <linux-mm@kvack.org>; Tue, 28 May 2019 04:31:26 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id z6so8081753vkd.12
        for <linux-mm@kvack.org>; Tue, 28 May 2019 01:31:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=nDpCbodGGyTl/G0ilhTF0HY0iZvF6dtHic3QCj90ipM=;
        b=U5/q2v+r5mEnogk8Tf+X9TcTT0WdMAtAJbis9VPzAXCr36K25QAjmnCRaGaj9h1MBZ
         Jv+vCBzRsykvUNGSaREdC+9bpeb4U+yQaN42CUjkS01sl3H9ArcLTj60rxlyKHAooFAq
         gVIAVIXnHnhdIhjHpvY0W0HqdXxabVUSGwNxNbp0y4VRkmVaSbQfRg/5PeTZQMNpyPBX
         iV9CQURIy9Ou220mLJFITt0lLDrS4bcATXGQ46S4lHP5Sqp9aQKyxkg544u06OwdUoRN
         yuD009sXHCAkOq2Y+kJJG1gpjWpZClqvLvommQZAj5MNfTS5RfFLoBDyVIt8i5Qsie1U
         3wSA==
X-Gm-Message-State: APjAAAX9d6hRi9klFzPa4su6G25RcZbkl3ZCyv3tYkbW+ul0oWEVmisa
	sHsySzgMXLQsMe3oR+jyyMSVEPNOvauLENT2WoNLBUzq/F2Fcfkd6IkeEBlvh5MUcEnSqkQdHlD
	bMQZKuW/4eeslOEMg0Toomdv2Tgs1dTihmvIR498/eifXp5Y1OS/VE+5YuZ+NoYijJw==
X-Received: by 2002:a1f:a945:: with SMTP id s66mr24245774vke.15.1559032285652;
        Tue, 28 May 2019 01:31:25 -0700 (PDT)
X-Received: by 2002:a1f:a945:: with SMTP id s66mr24245763vke.15.1559032285020;
        Tue, 28 May 2019 01:31:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559032285; cv=none;
        d=google.com; s=arc-20160816;
        b=XSfhJVvBULt2kaYPa7ZPsRzzB4+PPhD1axDbdiWF0mojQngYqrSdwXbaMs4Uj1B1FR
         n5LQUXCjdaAZUXTRS6EF2/0TESzU1EoAjInPR7VPslYKU3ZpYoZBlZLOblIyCaKPH2h8
         u9/DS523hWG/kb/QfEJxEIAMGvk28c+50OQsE9D/71vjj5RxxEAXU0R6q0gkUYpf8erJ
         yDH/heOQy+9NkMNEyuEo29G7gIpIyck4+TvGMPdxe/cS0LhPRTGAksJmTFSMUX4FuUbJ
         DUUX94w66KUs0DuS/KXdlpWVnsk26s9OULEIYCXUsmWbYyuXefe/+Kb/q2p0wzLAivhb
         WDCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=nDpCbodGGyTl/G0ilhTF0HY0iZvF6dtHic3QCj90ipM=;
        b=GdpACbTK8TpXu0f5KFKgmSsplQMy+5To6/jyYs0Y4vclEqtoqS17K/0R4dqU7Jwx7V
         0bXS4WcMIsDwequABVb4VfihR3wtDSrd+4oapQ2x6qmmB4QQ5UAfw31Lpv5Qk0elA+8M
         f5378QsGGk9Q30eLgI16ubWTdw0FbLuZKhWd0EQAtM/LAG1IxEyihNbgtBAtVACw64hK
         FusTWzgBbKZ/wXN8jNNZQZaf9nA8DBxml3Qwu8V/hNjI2gMlyVKm4AXPJYlDA7VXzHHB
         N+Jl16eSk8HHcYL2Jkv8McJ+WecfXHFo1nxuxxTLiF0H/fs2bQMyy2wJvn2x+RfnGHXV
         trDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oZXsDC13;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l1sor5171733vsn.11.2019.05.28.01.31.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 01:31:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oZXsDC13;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nDpCbodGGyTl/G0ilhTF0HY0iZvF6dtHic3QCj90ipM=;
        b=oZXsDC139BFCteWhHBnBHACBOyQMeYRAOrZf/VJ9wS/tQrz+S5esMvP0w8pm449GB0
         cmPfZW9ULRdT8n87/iMLMqbXXoNT2419ayfmemKqxIJh/KqXliDTTIoDy/JJkTCzYryx
         iIlEjh1oNEoJ4CStLL3ikYedgGLSj31O/YU1e5WlFayKAu5dl4Cfe9sAOMTSo6ok56dv
         SscPem+FZ6pZKojuqiPTl9gCzY8bvmH3jPqX75TAYNEMn8ednqktRfMImHunEbKtoRUv
         Lf1i1JxgNOSbcFvnNzWMo0/z3X2u7Op2IXl1Rdo2AYwyzRhLvuUtMZjXo6ABqCq7Hxjt
         u1EA==
X-Google-Smtp-Source: APXvYqzE8QewMLUeXU4DZglD7H5qffJkLV6mdCsxLIk1a1dGSRHlmjrRoO/5otC9dc45/lQq+x8myk+C/2zbJELkiOo=
X-Received: by 2002:a67:e1d3:: with SMTP id p19mr60303726vsl.183.1559032284339;
 Tue, 28 May 2019 01:31:24 -0700 (PDT)
MIME-Version: 1.0
References: <20190520035254.57579-1-minchan@kernel.org> <20190520035254.57579-8-minchan@kernel.org>
 <20190520092801.GA6836@dhcp22.suse.cz> <20190521025533.GH10039@google.com>
 <20190521062628.GE32329@dhcp22.suse.cz> <20190527075811.GC6879@google.com>
 <20190527124411.GC1658@dhcp22.suse.cz> <20190528032632.GF6879@google.com>
 <20190528062947.GL1658@dhcp22.suse.cz> <20190528081351.GA159710@google.com>
In-Reply-To: <20190528081351.GA159710@google.com>
From: Daniel Colascione <dancol@google.com>
Date: Tue, 28 May 2019 01:31:13 -0700
Message-ID: <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
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

On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> if we went with the per vma fd approach then you would get this
> > feature automatically because map_files would refer to file backed
> > mappings while map_anon could refer only to anonymous mappings.
>
> The reason to add such filter option is to avoid the parsing overhead
> so map_anon wouldn't be helpful.

Without chiming on whether the filter option is a good idea, I'd like
to suggest that providing an efficient binary interfaces for pulling
memory map information out of processes.  Some single-system-call
method for retrieving a binary snapshot of a process's address space
complete with attributes (selectable, like statx?) for each VMA would
reduce complexity and increase performance in a variety of areas,
e.g., Android memory map debugging commands.

