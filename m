Return-Path: <SRS0=oA8h=PB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D4FFC43444
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 11:58:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19497218A4
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 11:58:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19497218A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hofr.at
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7816C8E0003; Mon, 24 Dec 2018 06:58:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 732888E0001; Mon, 24 Dec 2018 06:58:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 647868E0003; Mon, 24 Dec 2018 06:58:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 111B88E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 06:58:29 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id 49so3925097wra.14
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 03:58:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Dsa1UZlhXVxjOcRc2wQXLmaY9e4FunxgC8tJ8azhmSQ=;
        b=bMU4fD3umNtheUzdOoMcOxdjayW/eyrG49nSn/rxf73ZGgQeA8o3g+0HEDo+pDiOk9
         FLq3DMNYcAA71Y1DpBCCt6xwd5zUwr5vgIT2KEIfenI40aj/v47oSUI9jIE53fF00Qf7
         FT+R7qqH0K0TrBzRm30cLtoOJZ3/wx03PCIwqHM+11JcDsmdewP1LxKCMJoQtgltu8Oc
         aDrNnmiPmrmzhF3JbmilLvnW89v8BQFqGV32BrQiWuyBt9mHGQWLzbIT9RpbCv5IbeL5
         cFzEZSpKmSf+QBGeuYQTXZ7TQGO4yVlAN+7g5Ko4Ee4Pb8GhX/VJSs824A4vbbT/0RaK
         JRzw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hofrat@osadl.at designates 178.115.242.59 as permitted sender) smtp.mailfrom=hofrat@osadl.at
X-Gm-Message-State: AA+aEWbbCrq7N7nf3oZCiApR0zWDavEWQs5j/eVVIgOlPbbXRvVX/7/x
	SaLifvuoTkiHcY5qamQYl+JoqxZcpRjtB4/v/Iq+rEZA6F52HLHrN24+9TnQiPmV1K8J80sT6a1
	mUvQjGJQSezb4JZbMPrEeQs8OCwuaj4vj8gayBOMAGnsFQ4EHKC/n9ImH60CwDfc=
X-Received: by 2002:a1c:448a:: with SMTP id r132mr11491025wma.47.1545652708500;
        Mon, 24 Dec 2018 03:58:28 -0800 (PST)
X-Google-Smtp-Source: AFSGD/VgrbWwLPBwVH8TXMw0cYKq0e9CIMnc4wDtX6EMRGMtkF2Vf91d8BxvS+c2Ne0WzBqFSRh2
X-Received: by 2002:a1c:448a:: with SMTP id r132mr11490969wma.47.1545652707132;
        Mon, 24 Dec 2018 03:58:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545652707; cv=none;
        d=google.com; s=arc-20160816;
        b=vTrSp05sajyTlM711ny6+6iJkYCSrHzPA83eoDkN4Z7f4jm4AxR04OtDw+5zVfEqu6
         AB/uooQg4GYizHQSMrp0dMzoJq+sSkI4QRdCyUU/mZlL2j74ytAuqmyTNKN3B3TWssLx
         boLGOn4T3qDVvVatHpxLGlLNtRDfyCqHlFn8PaMRHXz9afDKP6w92TCGXAKtxxZuyNQZ
         eoPudGrLS709N1/kKeFotFj5zG01LTajlLnXxudTtNmlaQxQpvIixjtSCcIU9GaucERC
         i7aXAwJneO85UqLDloV/mvPaps7ynoFeKAS7Z8pVnrea8WBrBEdeKQz4LLxd/yFMcCpy
         Yx2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Dsa1UZlhXVxjOcRc2wQXLmaY9e4FunxgC8tJ8azhmSQ=;
        b=YUQy513AtDza3cAMQejwS2pUUovk3UBaJwCcuZ3JOLnu/ne64Z8CgCjAZlCfJYQ9Ek
         miu04h75MT+lCPJl0x4/ohK0C3o99QwrZWapJXohQWeyCQcYtXyDesZ9oGv24ILnM4Tt
         4XxOuu2szfEa43MnwW3mrrmAYhzd3kVFuuEpIoXCqrxcvLgiZzh6C43qYHZGTsB3ch4o
         ji8AWfQ3uHn5AP6tGnIi8vFE0y+f0NUxfeAjafKxsFy37G26U0ink0mS5md7ylNT4KQj
         zHP17nm3Q/6/03TiqjRoahPIGrdXs4OEzncK6mvzQJsSPEj6jmCdkOLeTqvwtB9oGCR2
         NFRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hofrat@osadl.at designates 178.115.242.59 as permitted sender) smtp.mailfrom=hofrat@osadl.at
Received: from mail.osadl.at (178.115.242.59.static.drei.at. [178.115.242.59])
        by mx.google.com with ESMTP id f1si6553026wri.445.2018.12.24.03.58.26
        for <linux-mm@kvack.org>;
        Mon, 24 Dec 2018 03:58:27 -0800 (PST)
Received-SPF: pass (google.com: domain of hofrat@osadl.at designates 178.115.242.59 as permitted sender) client-ip=178.115.242.59;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hofrat@osadl.at designates 178.115.242.59 as permitted sender) smtp.mailfrom=hofrat@osadl.at
Received: by mail.osadl.at (Postfix, from userid 1001)
	id 85CF45C06EB; Mon, 24 Dec 2018 12:58:18 +0100 (CET)
Date: Mon, 24 Dec 2018 12:58:18 +0100
From: Nicholas Mc Guire <der.herr@hofr.at>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>,
	Nicholas Mc Guire <hofrat@osadl.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Arun KS <arunks@codeaurora.org>, Joe Perches <joe@perches.com>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH RFC] mm: vmalloc: do not allow kzalloc to fail
Message-ID: <20181224115818.GA3063@osadl.at>
References: <1545337437-673-1-git-send-email-hofrat@osadl.org>
 <alpine.DEB.2.21.1812211356040.219499@chino.kir.corp.google.com>
 <20181222080421.GB26155@osadl.at>
 <20181224081056.GD9063@dhcp22.suse.cz>
 <20181224093804.GA16933@osadl.at>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181224093804.GA16933@osadl.at>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181224115818.1uWMyHhnQtCmpfujxNaFSISyT9SB9xy00WMbgkBsKTY@z>

On Mon, Dec 24, 2018 at 10:38:04AM +0100, Nicholas Mc Guire wrote:
> On Mon, Dec 24, 2018 at 09:10:56AM +0100, Michal Hocko wrote:
> > On Sat 22-12-18 09:04:21, Nicholas Mc Guire wrote:
> > > On Fri, Dec 21, 2018 at 01:58:39PM -0800, David Rientjes wrote:
> > > > On Thu, 20 Dec 2018, Nicholas Mc Guire wrote:
> > > > 
> > > > > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > > > > index 871e41c..1c118d7 100644
> > > > > --- a/mm/vmalloc.c
> > > > > +++ b/mm/vmalloc.c
> > > > > @@ -1258,7 +1258,7 @@ void __init vmalloc_init(void)
> > > > >  
> > > > >  	/* Import existing vmlist entries. */
> > > > >  	for (tmp = vmlist; tmp; tmp = tmp->next) {
> > > > > -		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
> > > > > +		va = kzalloc(sizeof(*va), GFP_NOWAIT | __GFP_NOFAIL);
> > > > >  		va->flags = VM_VM_AREA;
> > > > >  		va->va_start = (unsigned long)tmp->addr;
> > > > >  		va->va_end = va->va_start + tmp->size;
> > > > 
> > > > Hi Nicholas,
> > > > 
> > > > You're right that this looks wrong because there's no guarantee that va is 
> > > > actually non-NULL.  __GFP_NOFAIL won't help in init, unfortunately, since 
> > > > we're not giving the page allocator a chance to reclaim so this would 
> > > > likely just end up looping forever instead of crashing with a NULL pointer 
> > > > dereference, which would actually be the better result.
> > > >
> > > tried tracing the __GFP_NOFAIL path and had concluded that it would
> > > end in out_of_memory() -> panic("System is deadlocked on memory\n");
> > > which also should point cleanly to the cause - but I´m actually not
> > > that sure if that trace was correct in all cases.
> > 
> > No, we do not trigger the memory reclaim path nor the oom killer when
> > using GFP_NOWAIT. In fact the current implementation even ignores
> > __GFP_NOFAIL AFAICS (so I was wrong about the endless loop but I suspect
> > that we used to loop fpr __GFP_NOFAIL at some point in the past). The
> > patch simply doesn't have any effect. But the primary objection is that
> > the behavior might change in future and you certainly do not want to get
> > stuck in the boot process without knowing what is going on. Crashing
> > will tell you that quite obviously. Although I have hard time imagine
> > how that could happen in a reasonably configured system.
> 
> I think most of the defensive structures are covering rare to almost
> impossible cases - but those are precisely the hard ones to understand if
> they do happen.
> 
> > 
> > > > You could do
> > > > 
> > > > 	BUG_ON(!va);
> > > > 
> > > > to make it obvious why we crashed, however.  It makes it obvious that the 
> > > > crash is intentional rather than some error in the kernel code.
> > > 
> > > makes sense - that atleast makes it imediately clear from the code
> > > that there is no way out from here.
> > 
> > How does it differ from blowing up right there when dereferencing flags?
> > It would be clear from the oops.
> 
> The question is how soon does it blow-up if it were imediate then three is
> probably no real difference if there is some delay say due to the region
> affected by the NULL pointer not being imediately in use - it may be very
> hard to differenciate between an allocation failure and memory corruption
> so having a directly associated trace should be significantly simpler to
> understand - and you might actually not want a system to try booting if there
> are problems at this level.
>
sorry - you are right - it would blow up imediately - so there is no way this
could be delayed in this case. So then its just a matter of the code making
clear that the NULL case was considered - by a comment or by BUG_ON().

thx!
hofrat

