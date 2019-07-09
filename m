Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17BA8C606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 05:59:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE8C22166E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 05:59:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE8C22166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D3008E003F; Tue,  9 Jul 2019 01:59:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 083A38E0032; Tue,  9 Jul 2019 01:59:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDC8E8E003F; Tue,  9 Jul 2019 01:59:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7D498E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 01:59:55 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id w27so756183lfk.22
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 22:59:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=8H9DxfUP055AjEkmlAvjXMvI3VeCVnuumQ1UZuDs62Q=;
        b=aOZ/LMBjOGU2YnD9UvUaYqDeo7WuTPq4fWFmH1dmyJe4EE3jqyK7B+wOVx9dkyB8qw
         tDgVYDr0oXskryiCsiKWuPKWgwCxRqmROg90brFvkQD+OVoESabDTE2Qh7ovwZurIEpT
         S/2MaYSqElW9Stc4r79DnQznijHlxnJsIgSyduXEo9D/7k4Ny4a7UIZPqFmLduDwj5Zi
         J0ZLTqJjs1nW7IbKhTcSKg9seJ0gYID/nb227jh2rhT+Xmqxrj5o6mYi5gD52nyYEl7u
         O028OMtwkCkGUXYLLti04U11m+wgi3g8KmPZqtJUsM8isd8Z3Hb08Ip8riJ60O3ZmZt0
         fbvw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU83yTTSnru0GpyKm9IPhv4bYC7ZTp5xwXiRHiTwpWiV4NK6v3u
	PzYXfkPdKabih+nXBM4E32L3sD7jySZJ2JNId1dN+vvPaQufnAw7TSz+1Y+hHWRYdStR2FWTwU2
	3CEBBiqvM7avn4fhu+d0ag8N/DT7J9P+UH2CXZeX4JN46iQf1WAsz2BLnpD+jPEc=
X-Received: by 2002:a19:4349:: with SMTP id m9mr10476067lfj.64.1562651995106;
        Mon, 08 Jul 2019 22:59:55 -0700 (PDT)
X-Received: by 2002:a19:4349:: with SMTP id m9mr10476042lfj.64.1562651994353;
        Mon, 08 Jul 2019 22:59:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562651994; cv=none;
        d=google.com; s=arc-20160816;
        b=BWwgwS9+9PjH6r+U0iUjGsQLrNYCU9FO9L3laqZeSKHVY9AxxjwWsuGeTWaRW20al1
         QNzLg8Wg0FnOX4YfV/L5WQlsH2F0D8XsjRbtI5zlK5w1YEisr5X7twWV4m4yIJLVFR0K
         T9mDnG1GSgm5bI3+pGNsyMvAs3UbjCZQd3Hh5RJgeRWvRj20EYya89ykdTlbiUrfADSR
         ikpDDrl+blQrP4At7qzpgMggei+SsqvZTUFfMqgx8Yvl3GuAjStZNxPmhoY6yEPyd3eq
         og4oVgF5vQ0faBm9X2+Oz1PAzuayqXypi2I8M1emoeUXGCgdAXPh+qnwFfBfVcSGkOm8
         w5ZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=8H9DxfUP055AjEkmlAvjXMvI3VeCVnuumQ1UZuDs62Q=;
        b=GMQUYaTzyKmoYO+BphAd61kdFVEeE3w27s4wKAcvU0fNxggyAufV8UPKC4kMS/GvgC
         2c7tbgTcnut7gV0VJdCOeOYmmkxtdMscDZYFPvp3Udd6gqhg0uequIXnNhqOCxE6DjLJ
         nFOmeJQpQBSGeVPCJJnoI+lSx1oAvtkiC3+oapo/2+kPKVOkOjLy3V1aO/4GMs51JitX
         F5VwnfaICaZpvoiFqHl+5tWIsOOhPZgVWvZBgxlUnp2NC97KlNSPHRgYJtekBcD1G4J1
         nk+HGHrE0JSCOFf0WcHV/G4sT6Oc6hlUkkEO6zRXWRubfeleQ3tEUjnJx/WnaA9b66yc
         ElIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z19sor10167962ljj.47.2019.07.08.22.59.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 22:59:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqzKL887cT/bh4p0A5cne2WzyPyCoDGHmgwY4o+MX+s9ZkgCmZ3VV5ott+JGpAo4pHvsp3LZuyf6VcE0SI3VnDo=
X-Received: by 2002:a2e:9d18:: with SMTP id t24mr13065996lji.2.1562651993947;
 Mon, 08 Jul 2019 22:59:53 -0700 (PDT)
MIME-Version: 1.0
References: <20190514235111.2817276-1-guro@fb.com> <20190514235111.2817276-2-guro@fb.com>
In-Reply-To: <20190514235111.2817276-2-guro@fb.com>
From: Minchan Kim <minchan@kernel.org>
Date: Tue, 9 Jul 2019 14:59:42 +0900
Message-ID: <CAEwNFnALK=aAnyBypHbvw4khRwbOeMN=5gtgLWY+3F3HEpb2Ng@mail.gmail.com>
Subject: Re: [PATCH RESEND] mm: show number of vmalloc pages in /proc/meminfo
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kernel-team@fb.com, 
	Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Roman,


On Wed, May 15, 2019 at 8:51 AM Roman Gushchin <guro@fb.com> wrote:
>
> Vmalloc() is getting more and more used these days (kernel stacks,
> bpf and percpu allocator are new top users), and the total %
> of memory consumed by vmalloc() can be pretty significant
> and changes dynamically.
>
> /proc/meminfo is the best place to display this information:
> its top goal is to show top consumers of the memory.
>
> Since the VmallocUsed field in /proc/meminfo is not in use
> for quite a long time (it has been defined to 0 by the
> commit a5ad88ce8c7f ("mm: get rid of 'vmalloc_info' from
> /proc/meminfo")), let's reuse it for showing the actual
> physical memory consumption of vmalloc().
>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Minchan Kim <minchan@kernel.org>

How it's going on?
Android needs this patch since it has gathered vmalloc pages from
/proc/vmallocinfo. It's too slow.

