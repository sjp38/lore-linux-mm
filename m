Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7289BC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 10:51:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D58B208C2
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 10:51:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D58B208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7BC86B027B; Mon, 13 May 2019 06:51:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A05986B027C; Mon, 13 May 2019 06:51:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CDA06B027D; Mon, 13 May 2019 06:51:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E39B6B027B
	for <linux-mm@kvack.org>; Mon, 13 May 2019 06:51:41 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b22so17438059edw.0
        for <linux-mm@kvack.org>; Mon, 13 May 2019 03:51:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+wMaRL4eLZVI0n0o4gccwjBilI3epL5izt/bEQ9K9ZU=;
        b=Ljh389mZ3B5vJRsvuMEYn47jq6izzrWCK/vrY69l93lLFS8SqLfCaXtnvF3K21OjOZ
         1RjAC1fo0k4wkBt6DuGkXJ7Oo2BJluNcPHKosy26srqUHrgFAJSG1bSaX0NBY/xOzGFW
         O7FOftp6uabWV1CwFhJLuFfSK/pmyTYWNN7gOFLnwODz1gr3Ixo4QceIujOKJsfb5T4J
         i3kldMtqEeYQ16L2JrUB1hYSNZtbiTJI56ErO3RwnSAdUP/fMtaOcXC3uZsNRyb/d9Rs
         AgesI7kBQSBzcbkfedNU9fM5AOTKJN92DX3Z9xtk3rqZJUnWybnmEPazB5so8geIN/C2
         NLVA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVl0adM2oXDyvgfS2y4D2hzSNjD5OOsiKXJkPrIqBdfoCzlZPD+
	niLgiVBCXHzxr7IXllDLZhNQabQTJdkRIO8fIxkQUiN6SYnqOwrGVrZFez5OcBvsupzK6d3zsc3
	c3aoqyobDz6GeqWBPXF8X8v4xv6KAQTCofucffQD8M2KSQo+A2v5pLNZ5xljboiw=
X-Received: by 2002:a50:d2d4:: with SMTP id q20mr28894099edg.120.1557744700824;
        Mon, 13 May 2019 03:51:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/MvqV8qknr1YFEe/wyzVI05iCh2qIFvsOE+HtG+2fMYgS7n5Ov9MOR9zX2A4GA4VZnNCq
X-Received: by 2002:a50:d2d4:: with SMTP id q20mr28893984edg.120.1557744699405;
        Mon, 13 May 2019 03:51:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557744699; cv=none;
        d=google.com; s=arc-20160816;
        b=zgUfb8db6CzjGgDDycF9e8vBC2AqESYoF0zWHQ6FU82stJa68+tzCQwo43gz4HNDGw
         TYJeTjRVFcribgYDpImEE0mmlbwP7h47gGv0Zmj9x45k6z83G/pJPLvgcKJr5pyUgVaN
         yJjUswbfOP/Ld8SV30OykSmpve8SEue/+dB6xPBSFpYT5HMOScz4ED6+CsFg0lIN+57+
         dq5X6cnJzUu1p5G69p8Ro29HmpvC4d9AchAzHteeKnG1mfG9D3hwbBXtzHPX+MdqN18q
         SmWoIZDVcu2DXlhx+1VVnCkJTQLkudkEmgXqvkLyxxtlewi4t8TxZg8c2S1MQLwtgfmx
         ZX0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+wMaRL4eLZVI0n0o4gccwjBilI3epL5izt/bEQ9K9ZU=;
        b=U6wlCaAm+pJ1wsrPfb7N7JS0Fr6gYlFyvMGQvDjJtO7vb8klux512H3vi0w+uxPM1U
         X99r/V3s9gIHWuofOlkyTuTMNi+Zk4oWjVAoBmrRDGZt2Uu6Bg5i5f9UkgLjwfM4/VDy
         jTz4FwET25dSFYn44BrcO3VFhFaNIyQq0s0rUdzhyuXXOmme6+3Pz1O9Ud9+rNA1mjbZ
         AEgEp7dNho3ikkEba4/vqXiN/m3AtUqUmWhQ3YZzvyMDzRrOvOtsTMwuMBNbwWTX5/D3
         v6BCJSwwI39WnaIy+9vBlmwGpCBe8tW2SOpMJOQ0/ustJ51rr1fPHQbUg0I2SKU1RNjZ
         eC0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w11si2710552edb.418.2019.05.13.03.51.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 03:51:39 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 076D8AED5;
	Mon, 13 May 2019 10:51:39 +0000 (UTC)
Date: Mon, 13 May 2019 12:51:38 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH v2 00/15] Remove 'order' argument from many mm functions
Message-ID: <20190513105138.GF24036@dhcp22.suse.cz>
References: <20190510135038.17129-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190510135038.17129-1-willy@infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 10-05-19 06:50:23, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> This is a little more serious attempt than v1, since nobody seems opposed
> to the concept of using GFP flags to pass the order around.  I've split
> it up a bit better, and I've reversed the arguments of __alloc_pages_node
> to match the order of the arguments to other functions in the same family.
> alloc_pages_node() needs the same treatment, but there's about 70 callers,
> so I'm going to skip it for now.
> 
> This is against current -mm.  I'm seeing a text saving of 482 bytes from
> a tinyconfig vmlinux (1003785 reduced to 1003303).  There are more
> savings to be had by combining together order and the gfp flags, for
> example in the scan_control data structure.

So what is the primary objective here? Reduce the code size? Reduce the
registers pressure? Please tell us more why changing the core allocator
API and make it more subtle is worth it.

> I think there are also cognitive savings to be had from eliminating
> some of the function variants which exist solely to take an 'order'.
> 
> Matthew Wilcox (Oracle) (15):
>   mm: Remove gfp_flags argument from rmqueue_pcplist
>   mm: Pass order to __alloc_pages_nodemask in GFP flags
>   mm: Pass order to __alloc_pages in GFP flags
>   mm: Pass order to alloc_page_interleave in GFP flags
>   mm: Pass order to alloc_pages_current in GFP flags
>   mm: Pass order to alloc_pages_vma in GFP flags
>   mm: Pass order to __alloc_pages_node in GFP flags
>   mm: Pass order to __get_free_page in GFP flags
>   mm: Pass order to prep_new_page in GFP flags
>   mm: Pass order to rmqueue in GFP flags
>   mm: Pass order to get_page_from_freelist in GFP flags
>   mm: Pass order to __alloc_pages_cpuset_fallback in GFP flags
>   mm: Pass order to prepare_alloc_pages in GFP flags
>   mm: Pass order to try_to_free_pages in GFP flags
>   mm: Pass order to node_reclaim() in GFP flags
> 
>  arch/ia64/kernel/uncached.c       |  6 +-
>  arch/ia64/sn/pci/pci_dma.c        |  4 +-
>  arch/powerpc/platforms/cell/ras.c |  5 +-
>  arch/x86/events/intel/ds.c        |  4 +-
>  arch/x86/kvm/vmx/vmx.c            |  4 +-
>  drivers/misc/sgi-xp/xpc_uv.c      |  5 +-
>  include/linux/gfp.h               | 59 +++++++++++--------
>  include/linux/migrate.h           |  2 +-
>  include/linux/swap.h              |  2 +-
>  include/trace/events/vmscan.h     | 28 ++++-----
>  kernel/profile.c                  |  2 +-
>  mm/filemap.c                      |  2 +-
>  mm/gup.c                          |  4 +-
>  mm/hugetlb.c                      |  5 +-
>  mm/internal.h                     |  5 +-
>  mm/khugepaged.c                   |  2 +-
>  mm/mempolicy.c                    | 34 +++++------
>  mm/migrate.c                      |  9 ++-
>  mm/page_alloc.c                   | 98 +++++++++++++++----------------
>  mm/shmem.c                        |  5 +-
>  mm/slab.c                         |  3 +-
>  mm/slob.c                         |  2 +-
>  mm/slub.c                         |  2 +-
>  mm/vmscan.c                       | 26 ++++----
>  24 files changed, 157 insertions(+), 161 deletions(-)
> 
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs

