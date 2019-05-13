Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9602C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 11:42:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E8CD2070D
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 11:42:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E8CD2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E73FB6B0287; Mon, 13 May 2019 07:42:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFCFC6B0288; Mon, 13 May 2019 07:42:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D13556B0289; Mon, 13 May 2019 07:42:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 854DA6B0287
	for <linux-mm@kvack.org>; Mon, 13 May 2019 07:42:37 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r48so17566789eda.11
        for <linux-mm@kvack.org>; Mon, 13 May 2019 04:42:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=82Gk93Y9AsRtb/GDFWT8d0IHwJaFybCyLnVKqKKEhDI=;
        b=tTjn/8PTb5tvSwd+TV52R5ImmW6yZDahUPCS9y+B0b/j9QTl+Vzp8n0IvQN9PDvzBQ
         WzQ4hZ+zOclpU8cYps4PhZhl29xVAZDeE8Yd7ZHTS1FBx40cupiTcwa6xy+KNEjWlHjj
         pZj8mJe8/rSTdncU+UHp48KCNszLbKffY+1dJpipqAr56QhKYqQNZlvUPXBDhtTgZogt
         y3as/A5Vu3DFsORzjOo9WuXSqZGcQoq7mzhCk+xnPyOHXhMKAce4BTGYva356dNj7Eex
         ajAfYsnOW61bv/OySo7m38McRu45PyXKfaoFZ7pYpz1hD8aPYmByYQvFT1pPLwCeDZlJ
         a3nA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVlXkGWF0wT+2z1ArD6NoStT8sjxPWwOag+IX/iGBEGZtbcAY2P
	HdAbcwEuUtXtja29eBHVS6xFn+dF1YpV8TEsL4YH5UR2dWDq9dnpvs/QX7DDIDWnnK6qxt0Gur6
	ieOfAYXh+jCYZx/xo9R4nQbxJdWzO9xYcEiE0bmPcDKCvBarOXILcW3b8ZfAU/Ag=
X-Received: by 2002:a50:aad9:: with SMTP id r25mr28131438edc.266.1557747757009;
        Mon, 13 May 2019 04:42:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/xWvj4x1mf5k1JU5nytf+nWbL5QeLVHGTFuZM2QCpe7EKLl6SnlJjVs21PvuD3Wq5xoq4
X-Received: by 2002:a50:aad9:: with SMTP id r25mr28131371edc.266.1557747756251;
        Mon, 13 May 2019 04:42:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557747756; cv=none;
        d=google.com; s=arc-20160816;
        b=sVHrcLYCDIGHSOnZVkUb5zJm/Wd5LRA9BBlGjUtFZOkT5QiFDV/DzCE2EEAnrvw+Xf
         RcWytamxAUGuzQxtj1WKPv3grohiiiCHINl/RdPDH7hIIumvEPq5+xUpImzD8o7mWZwG
         lLmBDd1gGxaRnePStMLhy7uwcTrwaidF/XOd8k06kJoFrcVpYrXu85EzH8hgfEXDIQIk
         jHqlQ3ya4yjfW+aNR9Mp9fW7grOu60mplzmyp34NQjHUmQ/l0oTydPfBGcR6ZsAF6lWG
         7t5IdO1gllMSpsMjBYvth6TKbQ2QEo62VvQJLEyaTmmdOuF4nyd8aLwu2tb6ylz0dP8q
         2aRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=82Gk93Y9AsRtb/GDFWT8d0IHwJaFybCyLnVKqKKEhDI=;
        b=pDel6ai1l0EfO2nBtTL1vpGgcOrBb/BHNPxJbPZSjvcdJXsM+t2PBDzvSuVoJckZ9i
         5fA2TGINkBMG3yizBHyB94xUgnV+8eTnFLKgceGNQeqAJ5lD8uhIVA5cz0OFROUzyHeq
         fHsJSQ0GuqEl+SNkcxUHhj16+8sEcY6M9gQRFxN2tp1nj104J+gXv8lju/nrWh/hqs+l
         +aE75fANxdloia5eBp/FfHgGb8AbhtJlj+TLNbyATsf1rwhoWCPoXpgZe+J2g4g2eVYD
         Umy/P9TweqQb35TlurA/xQxaVbOMva5u2nO8N/HHeoPaTrOU6YyJUxFuF+4PYB9C23Vf
         uisA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l14si1291444edv.262.2019.05.13.04.42.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 04:42:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 51F11AB42;
	Mon, 13 May 2019 11:42:35 +0000 (UTC)
Date: Mon, 13 May 2019 13:42:34 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH v2 00/15] Remove 'order' argument from many mm functions
Message-ID: <20190513114234.GG24036@dhcp22.suse.cz>
References: <20190510135038.17129-1-willy@infradead.org>
 <20190513105138.GF24036@dhcp22.suse.cz>
 <20190513112107.GB3721@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190513112107.GB3721@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 13-05-19 04:21:07, Matthew Wilcox wrote:
> On Mon, May 13, 2019 at 12:51:38PM +0200, Michal Hocko wrote:
> > On Fri 10-05-19 06:50:23, Matthew Wilcox wrote:
> > > This is a little more serious attempt than v1, since nobody seems opposed
> > > to the concept of using GFP flags to pass the order around.  I've split
> > > it up a bit better, and I've reversed the arguments of __alloc_pages_node
> > > to match the order of the arguments to other functions in the same family.
> > > alloc_pages_node() needs the same treatment, but there's about 70 callers,
> > > so I'm going to skip it for now.
> > > 
> > > This is against current -mm.  I'm seeing a text saving of 482 bytes from
> > > a tinyconfig vmlinux (1003785 reduced to 1003303).  There are more
> > > savings to be had by combining together order and the gfp flags, for
> > > example in the scan_control data structure.
> > 
> > So what is the primary objective here? Reduce the code size? Reduce the
> > registers pressure? Please tell us more why changing the core allocator
> > API and make it more subtle is worth it.
> 
> The primary objective here is to avoid adding an 'order' parameter to
> pagecache_get_page().

It would be great to state that explicitly in the changelog. Because
that has some clear goal to achieve and that we can weigh.

> I don't think it makes the API more subtle; I see
> it as fundamental to the allocation API as any of the other GFP flags.

Well, that really depends on how you look at it. Size, allocation
restrictions and numa placing can be viewed as orthogonal attributes of
the allocation. On the other hand the vast majority of callers do care
about order-0 requests and that's where you get most out of the change
so it makes some sense to me as well. I can imagine that this can
optimize some code paths nicely.

That being said, I am not really opposing this change, I would just
appreciate to give us full picture of where the motivation comes from.

-- 
Michal Hocko
SUSE Labs

