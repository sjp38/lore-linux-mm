Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41694C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 08:46:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E750B20854
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 08:45:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="i/r1cUhP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E750B20854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 813746B0008; Tue, 19 Mar 2019 04:45:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C4266B000A; Tue, 19 Mar 2019 04:45:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D9B16B000C; Tue, 19 Mar 2019 04:45:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 265ED6B0008
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 04:45:59 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v6so16153295pgo.22
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 01:45:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9EbD8SYVxjECn/vPlG55W0WV+leCz2o3Rm26sNUa/m0=;
        b=CSThbgOgYdu916tGoTqYsqQEYe9gyaYme3V/k1ZeHnF2Q2EkMGDiUtf+w92QM9VLmn
         QZR6lUyulImh4g+3+3uAkXqWZGsdogQi249KfQSZ7UaXfT5NmCaXPvYp9WO4mgj3VqfV
         Dk65dgkOdpcsZ+YJgllJ94k6lBNXQh95RK8VB+Z/DtA0TKw3GizYAkMqD8Pf7TL5LiOz
         XKoqXUHx0h22xCqQmU6odX08HXwKXYeY3T5YbgghLWDdpfc6fpa8/HcIuszTzowFPowd
         Bhl/tWFr1tkXQfwZ4yFD7ey56FH/YpWD+hkMO75g25FeyUQe1ZiNAVGWZPu0oh0COsSm
         RXjw==
X-Gm-Message-State: APjAAAXzug3atTJ2n4G+FeZo3VC+SfSBMqo12QQtTCZQXIHeGkfWAc7o
	7FgtWoDAVK8zNdQs36AdAI2wRY9Xi3pmRDGe/Iva9i0an1pVzv6U11OOJo+b3+Zj6xuPOkoc0Nf
	6HVQwFpFsX51au4ESyRo2wDMglBcvVslt6BVaQG24F0jLJxf3sYfLxlD/00XsbhgWIw==
X-Received: by 2002:a65:5c07:: with SMTP id u7mr755924pgr.320.1552985158809;
        Tue, 19 Mar 2019 01:45:58 -0700 (PDT)
X-Received: by 2002:a65:5c07:: with SMTP id u7mr755872pgr.320.1552985157908;
        Tue, 19 Mar 2019 01:45:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552985157; cv=none;
        d=google.com; s=arc-20160816;
        b=gZCT7o+GQXcZR/J7ysb+5e9SAOZghMr4bPNO0IsO9B2lkMHlHGBCtBAmB19b3Njenx
         NwwUgN6LsEC51KR1YPrVziJjkqYOe+2tqO/kHCtNChBxIOb7N+2Uyw6UhctXXZ9RKzIF
         NZnLRxMwvWRdcODa2PUqCU8YMdlTZDDYb/eIhRSuuY89BaYfC8cZ6td4dV6DDmfbMzyx
         N//mBIpBQqLpU3aKuehU6A6eJiyPHwLOzazDdVgMciRmYqZyXHi9zOnfyWyUJsEJr16y
         m1COCsoPFsbPPERCbnvFcfITQ4RK05HjbxIliNi5ZaQ231cvEwO/JDzV9gwGayKCm6tH
         iWcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9EbD8SYVxjECn/vPlG55W0WV+leCz2o3Rm26sNUa/m0=;
        b=bhFjuydNiF/BFsXV9wcSOBZQ3iFNIAfjASSrLQUdQXPC3yr717mwW5MX9Pvr8jf4Ua
         7jFy94/8DbPMaJ1/yz5feScSjYnE8zq6o5nbKMK58I3yHLQg1uS+DlKbna8oDf2DHMWm
         wnmejUcwNrkmLrm7lKFHNDb6+QRYmAntVdb5cJbQbZ//KRPDl69ALmCPmFdaLVYjzdpu
         6I/ESLXRFkBFGPvi43h6uNDhRG9ZCIzA2m/mAOxNescBPOSyrr6DuVGc/ZiJwgXlTzVn
         IFFVN1v+OmuQkakNSJOvg6xE1cAc5vbhh1Oc+rFsCJoeW3H3CJJWuezKeoeQXLYEIJ2t
         MCqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="i/r1cUhP";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d18sor11260642pgp.85.2019.03.19.01.45.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 01:45:57 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="i/r1cUhP";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=9EbD8SYVxjECn/vPlG55W0WV+leCz2o3Rm26sNUa/m0=;
        b=i/r1cUhPRgQn1TvYQEiXrqgh3TqKtnExJ7Csss+9t3U5oHRGWOWorMHyNJ0mv6o17/
         r0kBjBkC+wxMN+/U134w9yMkr9FmkZLdoq+SFXznsBdbhF6pxKgjIq8cYjUX/2jCj2PS
         aZOVNK4sm/Z9ETX2HU5BMqYgkqmLaVnY+4c1EA6C6YL1d+JeCiEXqzGQuHZN3g8WLDFg
         6NuNZcy4iSP4XGwYSkT2q334oHOo84TssZh/OuxbzHMirQJO4vAn5BSHiUMfdvnB7u8S
         AInMGO8+zERbsleDu7bn0YZ0mKTXrpN/wmkzygZX87h7ZOMghyGQHXg/McJFzkFWtG53
         bABw==
X-Google-Smtp-Source: APXvYqwiA2BHLCgWmJ884rWZbGyqkGXOibn/Ce1JhESraItT0qgQ8oKmy0iHV7/kJJaGpHuFU6ZCgg==
X-Received: by 2002:a63:fc60:: with SMTP id r32mr752860pgk.345.1552985157566;
        Tue, 19 Mar 2019 01:45:57 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id x19sm16938831pfm.108.2019.03.19.01.45.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 01:45:56 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 29011300B98; Tue, 19 Mar 2019 11:45:53 +0300 (+03)
Date: Tue, 19 Mar 2019 11:45:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Takashi Iwai <tiwai@suse.de>, Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3] mm, page_alloc: disallow __GFP_COMP in
 alloc_pages_exact()
Message-ID: <20190319084553.2ogwmrafjkjfcylh@kshutemo-mobl1>
References: <20190314093944.19406-1-vbabka@suse.cz>
 <20190314094249.19606-1-vbabka@suse.cz>
 <0c6393eb-b28d-4607-c386-862a71f09de6@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0c6393eb-b28d-4607-c386-862a71f09de6@suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 01:21:59PM +0100, Vlastimil Babka wrote:
> OK here's a new version that changes the patch to remove __GFP_COMP per
> the v2 discussion, and also fixes the bug Kirill spotted (thanks!).
> 
> ----8<----
> From 1fbc84c208573b885f51818ed823f89b3aa1e0ae Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Thu, 14 Mar 2019 10:19:30 +0100
> Subject: [PATCH v3] mm, page_alloc: disallow __GFP_COMP in alloc_pages_exact()
> 
> alloc_pages_exact*() allocates a page of sufficient order and then splits it
> to return only the number of pages requested. That makes it incompatible with
> __GFP_COMP, because compound pages cannot be split.
> 
> As shown by [1] things may silently work until the requested size (possibly
> depending on user) stops being power of two. Then for CONFIG_DEBUG_VM, BUG_ON()
> triggers in split_page(). Without CONFIG_DEBUG_VM, consequences are unclear.
> 
> There are several options here, none of them great:
> 
> 1) Don't do the spliting when __GFP_COMP is passed, and return the whole
> compound page. However if caller then returns it via free_pages_exact(),
> that will be unexpected and the freeing actions there will be wrong.
> 
> 2) Warn and remove __GFP_COMP from the flags. But the caller may have really
> wanted it, so things may break later somewhere.
> 
> 3) Warn and return NULL. However NULL may be unexpected, especially for
> small sizes.
> 
> This patch picks option 2, because as Michal Hocko put it: "callers wanted it"
> is much less probable than "caller is simply confused and more gfp flags is
> surely better than fewer".
> 
> [1] https://lore.kernel.org/lkml/20181126002805.GI18977@shao2-debian/T/#u
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

