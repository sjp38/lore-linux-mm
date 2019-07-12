Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56038C742A5
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 08:04:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 272022084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 08:04:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 272022084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C5398E0126; Fri, 12 Jul 2019 04:04:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 975488E00DB; Fri, 12 Jul 2019 04:04:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 863E48E0126; Fri, 12 Jul 2019 04:04:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 39D1F8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 04:04:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i9so7088618edr.13
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 01:04:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cnV1CHg7fCn5AmilbSUrnET1tHffeaZG92AWXorIfXU=;
        b=GOamNqr/nuztexke+VUiV1uGQ6AFoscyxo3ITqpas7jM7hKxJpGsq9xcD9R5znBC4o
         pUClvoQoqb0Qa8ORz4WLkSmCYyhvsUPeQx/jYFd2Ptla9tpPxCxKExzCLiTODgI425W2
         pcuiY/QWbgfhj1TZeHIWkpLvXcIedHMubTYdO/xr7k147u2MHTd/YzdnRx4fc9YED1Cz
         l2nHQLnWJ0RE8iK9XDDHQrm7uq1NmQ6m9yQXk4xZxXxJyqfsBI5f0EW7GpcWlPHWLmCZ
         nRf++WFRZnPNHCKpaYMn1AogTopIitiBBGGFXb2hnsUkW05kd/2G4HDYPOB1X5GWFtTN
         /BhQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAUR0HYFDrYR0kNRljRuYydsME1gZ52A9FAjykc1KVT0qsnrgetA
	9U9NkIsHf00+vXA+viuIl9Kzzi3zxqHOkKN9MCtFUf9WTfxGklvPMEWqfqCiM7kml3jr4EP3CWL
	pxJEfsxGjOzy5NsjPEKg+E6mxCoTgH7BZOFs2hfOEpxnuemqUhMbW1fYonGDMlDuHWg==
X-Received: by 2002:aa7:cd17:: with SMTP id b23mr7937134edw.278.1562918692782;
        Fri, 12 Jul 2019 01:04:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMwnSli3QaUGBEy2lEtNf7jVeoznm6uPgQVpPiwnu9+IPtxB5I1r6E+URTQfhnC4FjZzZK
X-Received: by 2002:aa7:cd17:: with SMTP id b23mr7937088edw.278.1562918692072;
        Fri, 12 Jul 2019 01:04:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562918692; cv=none;
        d=google.com; s=arc-20160816;
        b=t5QxEtrpRX+lSYDNEjTSbpdnp26RaYGyGtFxdHTaZcNZAITQhNy2rrOJg+QQZUkRSH
         cRFMsuw7Z2ShxhIHdefMj8OEZHpFG5WeeqAy0tnzp3wnfdk3HSzYgGJoWWQh66KaAfWB
         9exDFbHs8X1s15jd36HYKmGkKuSG03Dzs0E0u9cv55QKYnxu941CVdSqAay+reSZowUp
         hRKlQtm6uSYVgXDUJK9B5ZlFJ2bvyTwsdL1kHd6k6jdR4YBB+Sij36+wwUJS75b7Wm70
         3cb6Iks7fRbPPps4r33m5M4m7aS+tI0egUhY7XwhIpfdfhKgC5+aeGGgroNy/kycNeZt
         zmPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cnV1CHg7fCn5AmilbSUrnET1tHffeaZG92AWXorIfXU=;
        b=PFfby89oKRDabptzfiRCvp/du+dA5CQeK7I1tO8YIeV9TgfbuYHHv0AVDF7ftqPtC7
         5poKPK2lpr6xWaGb9wZGdCH9d1mCdjmy7MPnM/eSomWV6Hb9CGy0LfGZZnuXbHSOkY+Y
         2nRU6MkbKMRfg4hIb89tDDO+a9kMIMNLSp3+HfyoSPQzuwYkmVjLDOS27yH/p00lUD2Y
         D7oem0/TYue0u09FU5nFKEGSgJRp1U3vahjjXDa+iD3SxteVubNK7UYgJecWNZhA4bX+
         HKp3gfVef0GcvLzEzXNYpBJ4pMfsBLeZ0l5ELc3jvJW8eZATRP/iMNMbiqs8j/lisvbr
         XeWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gs7si4440273ejb.68.2019.07.12.01.04.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 01:04:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 30666AE37;
	Fri, 12 Jul 2019 08:04:51 +0000 (UTC)
Date: Fri, 12 Jul 2019 09:04:49 +0100
From: Mel Gorman <mgorman@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, mhocko@suse.cz,
	stable@vger.kernel.org
Subject: Re: [PATCH RFC] mm: migrate: Fix races of __find_get_block() and
 page migration
Message-ID: <20190712080449.GG13484@suse.de>
References: <20190711125838.32565-1-jack@suse.cz>
 <20190711170455.5a9ae6e659cab1a85f9aa30c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190711170455.5a9ae6e659cab1a85f9aa30c@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 05:04:55PM -0700, Andrew Morton wrote:
> On Thu, 11 Jul 2019 14:58:38 +0200 Jan Kara <jack@suse.cz> wrote:
> 
> > buffer_migrate_page_norefs() can race with bh users in a following way:
> > 
> > CPU1					CPU2
> > buffer_migrate_page_norefs()
> >   buffer_migrate_lock_buffers()
> >   checks bh refs
> >   spin_unlock(&mapping->private_lock)
> > 					__find_get_block()
> > 					  spin_lock(&mapping->private_lock)
> > 					  grab bh ref
> > 					  spin_unlock(&mapping->private_lock)
> >   move page				  do bh work
> > 
> > This can result in various issues like lost updates to buffers (i.e.
> > metadata corruption) or use after free issues for the old page.
> > 
> > Closing this race window is relatively difficult. We could hold
> > mapping->private_lock in buffer_migrate_page_norefs() until we are
> > finished with migrating the page but the lock hold times would be rather
> > big. So let's revert to a more careful variant of page migration requiring
> > eviction of buffers on migrated page. This is effectively
> > fallback_migrate_page() that additionally invalidates bh LRUs in case
> > try_to_free_buffers() failed.
> 
> Is this premature optimization?  Holding ->private_lock while messing
> with the buffers would be the standard way of addressing this.  The
> longer hold times *might* be an issue, but we don't know this, do we? 
> If there are indeed such problems then they could be improved by, say,
> doing more of the newpage preparation prior to taking ->private_lock.
> 

To some extent, we do not know how much of a problem this patch will
be either or what impact avoiding dirty block pages during migration
is either. So both approaches have their downsides.

However, failing a high-order allocation is typically benign and it is an
inevitable problem that depends on the workload. I don't think we could
ever hit a case whereby there was enough spinning to cause a soft lockup
but on the other hand, I don't think there is much scope for doing more
of the preparation steps before acquiring private_lock either.

-- 
Mel Gorman
SUSE Labs

