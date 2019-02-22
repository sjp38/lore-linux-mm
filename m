Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9569C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:36:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76DE220700
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:36:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76DE220700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A2118E0115; Fri, 22 Feb 2019 10:36:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 251808E0109; Fri, 22 Feb 2019 10:36:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13FE28E0115; Fri, 22 Feb 2019 10:36:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E331D8E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:36:25 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id u13so795814qkj.13
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:36:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=RWseMIZ6VEO+YkmkUuk06YfiztvL53XmsCsIhfSt5K8=;
        b=MNd3mksRWqQD6RKa6mfogFjSL+aLU3vJXFz/YUZbd74sXedlZzO2mX9yt5yCMIcd4H
         hHhcBvi6/+/a+xS6DDs3TteYO0/wcUxitY5xdplySZOrhKTc9aKo/TKYqZazLvBWDnKp
         dD/TQnixnyEpmMUoYDoxhD6VfCiMPXSDW8xsBsL5fgU+JiOBflCxjA3yX0a2g3FIOw/Q
         repSy92sZijwXruc0hhQDbz09N7SPK40hGaEdBda+LW+vZa45g2GAW40CyRM6Z7VO+NP
         akgYkX2CsZqPVAzxNJZoMAvAakv0el/pX6IuuSgoSZsGSN64/zc7UV80OijP9GPifTjg
         1emw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubpp+HEoXkoOsYK09ws5SJTb1MQVIMtXsXM7kWxJytR03aO0Ofd
	VDrOM/X+cXJwUoL0C8+Ea7LnoWNtQlxhI66nstmzMyF9UNxHg7vRdk54w6MnMdqCAMm7LlKpr7A
	XqtMOkzisdakhJGRtBpLmBs/9hpIJ6xFje0kZ+25Gu2qJRYdl/HuGwAHnQ468z2hKEw==
X-Received: by 2002:a0c:ae78:: with SMTP id z53mr3493324qvc.235.1550849785734;
        Fri, 22 Feb 2019 07:36:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaZakk95Sq0iTIU9xRAktsXkcsVWtY/Vg2TjCBQwSud2PpFCBjEVIcFhgvAe1XjD0Lyvgjn
X-Received: by 2002:a0c:ae78:: with SMTP id z53mr3493284qvc.235.1550849785203;
        Fri, 22 Feb 2019 07:36:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550849785; cv=none;
        d=google.com; s=arc-20160816;
        b=PeRXuYUqtB3ICfyoZU3Q8TpqP8Yow+DXapyFie67zqAYBjZ+nLmw9ZMJTo2FOEXC3S
         d2ChSAO7oY2C4MPTVi17swxlwE1Q+mdddSEbIGAmMb1Gy3mLbF6ERH0oPcODgJRy0UOi
         FsfqWCXZV1koVvYKsRJ2C+zD9eG7aSEaHRUBfbLbUFuqIEB9+PYwudPvUVkNldCfoDpA
         m4JQjLTMS/JTmoEwaW1XDa3mPwGoptxcUzbXQQW174DdpdD8LxPztcv8mrZfmNFbEJ22
         Zw2S5q6w4CxwOt6BGhfgFVY3+GFxl9Bj2MRcGrR8ZpfP2NRyQtulVekqpPaX0OID6rFs
         A10w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=RWseMIZ6VEO+YkmkUuk06YfiztvL53XmsCsIhfSt5K8=;
        b=w0+s3fwCYIIUyw0BAbMSeqNUf0ivXFOnAvvA8ENChpRavg72FBLl+KXcgu1Dh47l4x
         SVMRzW8cXMtjuZYcAqSVrcP2tG0ReP6iEFbYkmJ7v5LSnlMLsJpc47ezgcP3M6tTOXk9
         JPdVDHfmNmnv0NanmrILgQUQHIulLNvqp2pwuLBO6D20n33+ZR4gLtkIQeUm19IiYmHo
         Cuv4TGKoAe2tF5AVG0cvX9csc7aMFRZ6bQBEVkISXb7XwOs0uisSgZ3c+/GMXcmZ185O
         08admXfgF81BMnMno3g3pqEbcEzjgcydlWD/ocerL+xzX3zgPkb0BvHw55yVy8T6b5ko
         u8nw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x2si1062220qkh.65.2019.02.22.07.36.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 07:36:25 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5508D820FF;
	Fri, 22 Feb 2019 15:36:24 +0000 (UTC)
Received: from redhat.com (ovpn-126-14.rdu2.redhat.com [10.10.126.14])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E8EBD611D1;
	Fri, 22 Feb 2019 15:36:17 +0000 (UTC)
Date: Fri, 22 Feb 2019 10:36:15 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 15/26] userfaultfd: wp: drop _PAGE_UFFD_WP properly
 when fork
Message-ID: <20190222153615.GF7783@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-16-peterx@redhat.com>
 <20190221180631.GO2813@redhat.com>
 <20190222090919.GM8904@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190222090919.GM8904@xz-x1>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 22 Feb 2019 15:36:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 05:09:19PM +0800, Peter Xu wrote:
> On Thu, Feb 21, 2019 at 01:06:31PM -0500, Jerome Glisse wrote:
> > On Tue, Feb 12, 2019 at 10:56:21AM +0800, Peter Xu wrote:
> > > UFFD_EVENT_FORK support for uffd-wp should be already there, except
> > > that we should clean the uffd-wp bit if uffd fork event is not
> > > enabled.  Detect that to avoid _PAGE_UFFD_WP being set even if the VMA
> > > is not being tracked by VM_UFFD_WP.  Do this for both small PTEs and
> > > huge PMDs.
> > > 
> > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > 
> > This patch must be earlier in the serie, before the patch that introduce
> > the userfaultfd API so that bisect can not end up on version where this
> > can happen.
> 
> Yes it should be now? Since the API will be introduced until patch
> 21/26 ("userfaultfd: wp: add the writeprotect API to userfaultfd
> ioctl").

No i was confuse when reading this patch i had the feeling it was
after the ioctl ignore my comment.

> 
> > 
> > Otherwise the patch itself is:
> > 
> > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> 
> Unless I found anything I've missed above... I'll temporarily pick
> this R-b for now then.

It is fine, the patch ordering was my confusion.

Cheers,
Jérôme

