Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFCDCC48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 07:44:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A72952086D
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 07:44:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A72952086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43DE06B0003; Wed, 26 Jun 2019 03:44:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EF468E0003; Wed, 26 Jun 2019 03:44:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DC708E0002; Wed, 26 Jun 2019 03:44:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 09B316B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 03:44:06 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id v58so1832022qta.2
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 00:44:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AYJMbDsTZYynkoysg16sIFZnKDOyQjAo4kujBrr+YvE=;
        b=a+B2TgVdJRV3s/Hc0cYnvtNVwwQQOsJQyFSHQXEIef3mYO4DM0dUp3oAfMzjr7Zgv+
         akabS5LnuYyZWeunle7cfjW8DH1i1elfvvVBtmDS0B+FmZoEx3NEQhIZZs0aHxlQrNID
         p7WS/ABCA09n+WW1s6Qxj32VrNhEH1ENH755G5QlTv/BRo2Ubl/o2TkquAKq6KOh1Z9U
         OglQHZcSfz6p7lXseQjmsDEV8qJK5efHN7QdlextUoLRoaoKASto2NuQbqpkalL6652Y
         PRARW5F0EWS9ECUSASMgmT0KRnkeafPi/4NSeQ4Ok/0OcgmxBpyfmoYdCssChJEjm8TZ
         VeQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWG7u1OF8qpMB1GWS5RvLlfENqK44SOVBzPlReaf6v6lDMdyz/1
	eqI8m9HM9SPOts2p4oYokDdXhFFXkqzaQVvYuVwVVD8ebOlMp5LcKvVkwRbbJ1soMv0Jh53YeAe
	oDU9ghu980zxI+bhyuzWRmK9u8L17wP+m+55StmGr9cEi4K8z6uUlMmtdYNsPzotZ7g==
X-Received: by 2002:a37:488c:: with SMTP id v134mr2644753qka.276.1561535045759;
        Wed, 26 Jun 2019 00:44:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLjRe4KUICXDKWdIeoa7XocVQfXdVnCiEwObaSh56Anap1/8c7FoY9lsG7V1nxtPIvGIYS
X-Received: by 2002:a37:488c:: with SMTP id v134mr2644727qka.276.1561535045270;
        Wed, 26 Jun 2019 00:44:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561535045; cv=none;
        d=google.com; s=arc-20160816;
        b=FTw39ihfU07ndYEHXFOx9a8JY7BYkRf1LqCiTTlhIhNuhAy7RcSK6ynsi6BjvBsmjJ
         bsZ+WacGF4Oq5c/ogZFOqIYTjkDChiPxDD2tyZj4WwOqVrEjnaNljOpWGqun70nVzG1l
         rRCzwkbSTr0PXON3p5wLuVTM9wCpuAPr8SydPH2v8YOYTkvUsCdd2omxFBFjAR958sHD
         GDYdI992vEH2LfSEemyUdnnp6tLQxMAVsyo1KgvI8w40QE6AmNk/7G+agRXNVGJC9v0M
         by6+Iw2Q0+ljyAP5hHgGTDEXbQgNkeJTH40q4Ct/SEvrXkInEvA7NoBXF/A4bZaIJdWa
         FHMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AYJMbDsTZYynkoysg16sIFZnKDOyQjAo4kujBrr+YvE=;
        b=jCto/pE/vbtS2+RXQX1W8irseXtECu6O/Ab2VcrCy9g5c0itKUHKag2zHxkGs6APgN
         SWTaTcEbwDOq83cOZap9PYteg88f810Wko2Bopqdn4SvQKW7L3diUw664WTCM80/uhfG
         58mdy3YE71zKpcZIFOqSGiY7ESrkVR4mo75gAAt4qgQmWEU+slH3k4pqupdNdUiI67oP
         b+b7y8JRbzjWoORk9NjQKWVDqWfd+1kwUZrm9ms1uJZPh9erjRcOndd0jF0EuJBBnX5m
         DomsfJO8X6Ej9+a+djG/YXJ3M8HyO95rKzPdz5rssQTOgS3V4U2nh9MAuC5Rdy94PP53
         FByg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n1si11281718qkd.107.2019.06.26.00.44.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 00:44:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0C4045D672;
	Wed, 26 Jun 2019 07:43:54 +0000 (UTC)
Received: from xz-x1 (ovpn-12-42.pek2.redhat.com [10.72.12.42])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7FC9C1001B04;
	Wed, 26 Jun 2019 07:43:36 +0000 (UTC)
Date: Wed, 26 Jun 2019 15:43:30 +0800
From: Peter Xu <peterx@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v5 02/25] mm: userfault: return VM_FAULT_RETRY on signals
Message-ID: <20190626074330.GB24379@xz-x1>
References: <20190620022008.19172-1-peterx@redhat.com>
 <20190620022008.19172-3-peterx@redhat.com>
 <CAHk-=wiGphH2UL+To5rASyFoCk6=9bROUkGDWSa_rMu9Kgb0yw@mail.gmail.com>
 <20190624074250.GF6279@xz-x1>
 <CAHk-=whRw_6ZTj=AT=cRoSTyoEk2-hiqJoNkqgWE-gSRVE5YwQ@mail.gmail.com>
 <20190625053047.GC10020@xz-x1>
 <CAHk-=wjxOz5RXpFTU=wSJg4Mjg1ugOBhBVppSTH6qjZPxpGOKg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAHk-=wjxOz5RXpFTU=wSJg4Mjg1ugOBhBVppSTH6qjZPxpGOKg@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 26 Jun 2019 07:44:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 09:59:58AM +0800, Linus Torvalds wrote:
> On Tue, Jun 25, 2019 at 1:31 PM Peter Xu <peterx@redhat.com> wrote:
> >
> > Yes that sounds reasonable to me, and that matches perfectly with
> > TASK_INTERRUPTIBLE and TASK_KILLABLE.  The only thing that I am a bit
> > uncertain is whether we should define FAULT_FLAG_INTERRUPTIBLE as a
> > new bit or make it simply a combination of:
> >
> >   FAULT_FLAG_KILLABLE | FAULT_FLAG_USER
> 
> It needs to be a new bit, I think.
> 
> Some things could potentially care about the difference between "can I
> abort this thing because the task will *die* and never see the end
> result" and "can I abort this thing because it will be retried".
> 
> For a regular page fault, maybe FAULT_FLAG_INTERRUPTBLE will always be
> set for the same things that set FAULT_FLAG_KILLABLE when it happens
> from user mode, but at least conceptually I think they are different,
> and it could make a difference for things like get_user_pages() or
> similar.
> 
> Also, I actually don't think we should ever expose FAULT_FLAG_USER to
> any fault handlers anyway. It has a very specific meaning for memory
> cgroup handling, and no other fault handler should likely ever care
> about "was this a user fault". So I'd actually prefer for people to
> ignore and forget that hacky flag entirely, rather than give it subtle
> semantic meaning together with KILLABLE.

OK.

> 
> [ Side note: this is the point where I may soon lose internet access,
> so I'll probably not be able to participate in the discussion any more
> for a while ]

Appreciate for these suggestions.  I'll prepare something with that
new bit and see whether that could be accepted.  I'll also try to
split those out of the bigger series.

Thanks,

-- 
Peter Xu

