Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FC35C46470
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 08:49:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C9DF20B7C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 08:49:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GUdtm2Y/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C9DF20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D30A16B0272; Tue, 28 May 2019 04:49:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D03E16B0273; Tue, 28 May 2019 04:49:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1A9F6B0275; Tue, 28 May 2019 04:49:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8DAFC6B0272
	for <linux-mm@kvack.org>; Tue, 28 May 2019 04:49:35 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id j26so11459237pgj.6
        for <linux-mm@kvack.org>; Tue, 28 May 2019 01:49:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=yyUeiuvEAPZA604X3Qsle66wGTeITptdd2/mkPm2vyI=;
        b=cNiaCTKng8Vo130KBYfwCtkPAdunD9tLNnTzfyAoTN73XCs2KuYSZtqQxN9RjK8ZVn
         vKygIUtVjdJl0HuekCCODRQ/6k+m/v5nPdCY3zoAxme9Fpu56LD3fjqcxWx7ieqQrca3
         soZezrqyMLrHjWiR4p63t7uyKPqMnHOsrksZFtQvn+Ja13pYCiANywsqlqiYtVC9MJT4
         /vERZ3cY68ODaQJQmp2vXrWVZ5Ns4MALIHJvUZ5uUgHOwD+V0vToUNGOFp2moj0+lFXb
         sQYuTPHurQTJakMcs6rAwMnDLOnqInT7yYFZHfMxpLe78p99oTCoaKsL2KYfxaB76wba
         7PJw==
X-Gm-Message-State: APjAAAVS8V/vYCZt4+u5SDmJcsf1iKXQNyVxCDv4Q4I+DGVLsHEuEANd
	2Pk4ukRR2oKxDtvz4iNVUMI1WwBC4dgr4t2Lht86oLOekW79w5H7ps2aadPRJGJdSNNj05NkDQ8
	fTEedQ9/Dw1d7AKq3iY3XTlRDdDkBAFyNxFcu7QcDgC/IuROgi9GP+/o5eDHtWUY=
X-Received: by 2002:a17:902:42a5:: with SMTP id h34mr110029468pld.178.1559033375138;
        Tue, 28 May 2019 01:49:35 -0700 (PDT)
X-Received: by 2002:a17:902:42a5:: with SMTP id h34mr110029407pld.178.1559033374563;
        Tue, 28 May 2019 01:49:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559033374; cv=none;
        d=google.com; s=arc-20160816;
        b=hoPlO2kHlt0S93ME+yHzjN5rE1pUoL4OFV49uPQzC+dnfX+1K1YIscGBWzY8DgzSgE
         uhm1xk9JcsJG6rtNOlXO+0POHRUKgLx/enTcbLrovLGeQAVgBb8BcVH47KVOYjOlhlMu
         Mp9VTD0qx8uDu3gVM+cYT86cipmaSlDzBvmowQ+O5DpJX12hXxpxdP/Xj5JZn2fiaz4E
         tvyrmdWXrf2T9O90z25V1hEQh4wWkuDzQSKqwXle7JoBkp+1gLEmWoY9aWHHUHdcd822
         y0vxxvQBKCaT8FXUDSh6zN6ruY/FszGPGbVTvNZF+6n3PuAiSHiKmkyYMAsnN2LTi7SV
         VO0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=yyUeiuvEAPZA604X3Qsle66wGTeITptdd2/mkPm2vyI=;
        b=IBkx6gWU72pm6tSwDIwlwBKB8OoS+DwmS2qQOF8VCxvoX2OZoiPd0UAsS2CMvEPSXe
         dyYaGBAEwbXy07GG3IXpNODDV4An7/85NpZJhfr7/5A5tNrni/rPkMeXi7KODXIM2m7U
         UzxejhP19ZEhbotC5iMfYXGxS3XavylLhAuUrUucXAor+jCI4gn3pmR8t6VGnoVkdeoD
         KM4WIolB7PgXCvjtXHQs+YwCEJPvuck8Wna+dR2zLo9DGME9XAN2Hb18fEGM49DygkL4
         mlkHSnv6zZ/4dydyBxy9I0aqO0aPvGBuKpbwZmYeXODIR9IIHs+0+gA7gpJexbVIRfiW
         uoyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="GUdtm2Y/";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y16sor16064786pfl.18.2019.05.28.01.49.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 01:49:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="GUdtm2Y/";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yyUeiuvEAPZA604X3Qsle66wGTeITptdd2/mkPm2vyI=;
        b=GUdtm2Y/xH530GIsF7hKD2bjE7d4L/YyedgUu6O7oznl9DqX84dH45WsG3vgu2VtMx
         4esY7XbmjbBgpNICqEtwGvORDOMOdigx6H6ThgY07VYfInU+DPQ+lx06LqXlKAI960cq
         LBVfzXpwEGX7+S5jPsc5h5emULZqdWjrECLRaTbhGaZsBkDU9ExuwWE5VO04YIqZXERo
         0recf4DhGEakwNR0o8N9+YSS9djGhhhmSUYV7hCm14r4yEI/gAvn0+q6YIzBefHgVbE5
         7UoC2lhWEPJ0ZG1KSZUv1tTaT4tJ6WC5p5Lnmt3MAlJ/7Uk28QlzIn5ICuyg/n7FJUQv
         OhGQ==
X-Google-Smtp-Source: APXvYqwv1WO8a7zoeMcXFsjLWQD88vtfSjCyEPG8TUZxQ0ivtD/z60/XLaCem2Q1YjKoTUHOIfErLg==
X-Received: by 2002:a62:4dc5:: with SMTP id a188mr90994883pfb.8.1559033374062;
        Tue, 28 May 2019 01:49:34 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id d19sm1694790pjs.22.2019.05.28.01.49.29
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 28 May 2019 01:49:32 -0700 (PDT)
Date: Tue, 28 May 2019 17:49:27 +0900
From: Minchan Kim <minchan@kernel.org>
To: Daniel Colascione <dancol@google.com>
Cc: Michal Hocko <mhocko@kernel.org>,
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
Message-ID: <20190528084927.GB159710@google.com>
References: <20190520035254.57579-8-minchan@kernel.org>
 <20190520092801.GA6836@dhcp22.suse.cz>
 <20190521025533.GH10039@google.com>
 <20190521062628.GE32329@dhcp22.suse.cz>
 <20190527075811.GC6879@google.com>
 <20190527124411.GC1658@dhcp22.suse.cz>
 <20190528032632.GF6879@google.com>
 <20190528062947.GL1658@dhcp22.suse.cz>
 <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > if we went with the per vma fd approach then you would get this
> > > feature automatically because map_files would refer to file backed
> > > mappings while map_anon could refer only to anonymous mappings.
> >
> > The reason to add such filter option is to avoid the parsing overhead
> > so map_anon wouldn't be helpful.
> 
> Without chiming on whether the filter option is a good idea, I'd like
> to suggest that providing an efficient binary interfaces for pulling
> memory map information out of processes.  Some single-system-call
> method for retrieving a binary snapshot of a process's address space
> complete with attributes (selectable, like statx?) for each VMA would
> reduce complexity and increase performance in a variety of areas,
> e.g., Android memory map debugging commands.

I agree it's the best we can get *generally*.
Michal, any opinion?

