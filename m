Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDD49C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 06:44:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CD062082F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 06:44:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CD062082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06A146B0007; Fri, 29 Mar 2019 02:44:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01A0B6B0008; Fri, 29 Mar 2019 02:44:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E730E6B000C; Fri, 29 Mar 2019 02:44:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C80B36B0007
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 02:44:34 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id f15so1296817qtk.16
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 23:44:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YeKfytpVUKrW06meeKx45xTvZV6q8OtEiMhLZH7cr7c=;
        b=EzWcFeXdinzhJ3xbVkIPJHv7C5rI0cTubgL0sULIzEDK5aYbVrBAcHQwKQPPakzEii
         I80yjrO48an3en+4LBa+3cwNTjnvtUzgYM6CBHrQeNr4bkWXRyk+6kSMfRd8E0dg10o0
         PAnHFVvPY29+BsijLldRAAZcjvbra6tzUBPZEZhEFZjUMqXICZDs89Ck1h2tr3QyXQE0
         QDeyPKpL7fa2g/OP2z406pt9qSqiKKwE/pr6GKhdU1M4+2PhjBETEUdQU09L+3TNCYQq
         4y2f3cCLvD39AqRHQttjGKV4ciZ7JLmunvHWe+QO1Rhm7yOGWifSptxmE5AP2S4kEF12
         XGdQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXr5fmOk03yb78g7WbCVFVGUZnLXAgY0FqedULwpgKoQNIvQ8jx
	gqE+IdfZ+tH1BhaMUug0Muchz3AgFWoAR9lv8kGJ9oX6BurdxNT5VxKdie7apgbwe1HVD7fSZSy
	KoXFJKmOVpdSltiXZ4JEluYy0ZuP5EDOYNLE3PpFBqyo9Gynn9lXsCb6RSzO1CtFcXA==
X-Received: by 2002:a05:620a:15b5:: with SMTP id f21mr37971636qkk.89.1553841874587;
        Thu, 28 Mar 2019 23:44:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0MNvDu5f8EphAOEJsnwNLnfVrAeBDfZEIcs1Mo7OO8r+ZLMciu1EWg1eGF+1jDzOI8OVz
X-Received: by 2002:a05:620a:15b5:: with SMTP id f21mr37971619qkk.89.1553841873949;
        Thu, 28 Mar 2019 23:44:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553841873; cv=none;
        d=google.com; s=arc-20160816;
        b=qo7mrEGk7KT142ijSB1DNpWB4GzEWbkMls2aH+2urpvqzRG/5uRKMKZLYJEjubwQaR
         7B5oW2h6rrB6Obt7LjdU9N24UlbB7tj35Q07Ppys3kKF5s/FzUMEZV0x+s0PZm7cpQ0D
         wMveJGV4Hy2QlLFtvsnx4Yd7kJxXJ9sfsLfuR39VERtq2hEAJJm3bGH0Ao8gdv41OfKN
         h1kUcs46aiKm+oGxmH77WAyd/5ADvB/Vj138w32J8MpwbNCXXaInK/5VjEehc4zzgZVS
         5bDonNq+T8cvrjnemI50RJFSHKtIy9GkynpfTwUZHGp63tYGlLqp3PTwpCvzP9jZ+C98
         9r+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YeKfytpVUKrW06meeKx45xTvZV6q8OtEiMhLZH7cr7c=;
        b=oLr49lA8cfYDzvbMEGBckKrWPWWrbvgqLrC2mchaovhWhxu6c+cNiWhj6OzMMxe+dB
         Dqoc3ALkO24pyhEIrv7HzL/EG1VV428WwA8NBAwpjT2xELg15Goskkd+pOLmzx2p1Ko6
         lfg2+RwP8ORZDHgjLAq+FuDmFUN9ksGQGleBsmgRr+twaYP4a2iPK7weOcFV/q8fCe4u
         TtFHPRh861UUJ+EYv6MNw9Bpe4Yg+TPcm6joxWadH/hOcD55bOLXsxwanuUHVtbN1tlV
         ZDZKrDNzCQwkG136dVLKtCdZwWtEJhg2BcCVlxx4njmD3SVjxL6kiTvp/JvfVsHRWCX6
         7nnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r29si657573qkm.32.2019.03.28.23.44.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 23:44:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DB1F3307D848;
	Fri, 29 Mar 2019 06:44:32 +0000 (UTC)
Received: from localhost (ovpn-12-24.pek2.redhat.com [10.72.12.24])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 060131001E8F;
	Fri, 29 Mar 2019 06:44:31 +0000 (UTC)
Date: Fri, 29 Mar 2019 14:44:29 +0800
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com,
	rppt@linux.ibm.com, osalvador@suse.de, willy@infradead.org,
	william.kucharski@oracle.com
Subject: Re: [PATCH v2 0/4] Clean up comments and codes in
 sparse_add_one_section()
Message-ID: <20190329064429.GB7627@MiWiFi-R3L-srv>
References: <20190326090227.3059-1-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326090227.3059-1-bhe@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Fri, 29 Mar 2019 06:44:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Talked to Michal, the local code refactorying may impact those big
feature or improvement patchset, e.g patch 2/4 and patch 3/4 will
conflict with Dan's patchset:
[PATCH v5 00/10] mm: Sub-section memory hotplug support

So I would like to discard them and only repost patch 1/4 and 4/4 after
addressing reviewers' concern. Sorry for the noise.

On 03/26/19 at 05:02pm, Baoquan He wrote:
> This is v2 post. V1 is here:
> http://lkml.kernel.org/r/20190320073540.12866-1-bhe@redhat.com
> 
> This patchset includes 4 patches. The first three patches are around
> sparse_add_one_section(). The last one is a simple clean up patch when
> review codes in hotplug path, carry it in this patchset.
> 
> Baoquan He (4):
>   mm/sparse: Clean up the obsolete code comment
>   mm/sparse: Optimize sparse_add_one_section()
>   mm/sparse: Rename function related to section memmap allocation/free
>   drivers/base/memory.c: Rename the misleading parameter
> 
>  drivers/base/memory.c |  6 ++---
>  mm/sparse.c           | 58 ++++++++++++++++++++++---------------------
>  2 files changed, 33 insertions(+), 31 deletions(-)
> 
> -- 
> 2.17.2
> 

