Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EB29C32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 09:40:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D01B82086A
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 09:40:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D01B82086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C94F6B0005; Fri,  2 Aug 2019 05:40:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67B1E6B0006; Fri,  2 Aug 2019 05:40:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 542926B0008; Fri,  2 Aug 2019 05:40:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 094636B0005
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 05:40:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d27so46612049eda.9
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 02:40:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GVvRLyZwxdfn9nyNqh7UZq5Pv7RIZE41nfZGdWdwPoo=;
        b=OwbSdottnNlUok3/h9FzOryDs5W+sVrr2TGvyw6FsUsOly+kqEbhF4aDP8YNST0GFD
         KnIbtD7Imsfg02pq2bTMOrNN51dwWqn4g22jDL46TVnpT7QmTgO53julBN+4ukU9SXfj
         PsR5+2GL/MTFXmsHzqiKHsv0l4tk5aYQMlAuLr4dUsnEgP0wgXGDiwArysfjq7buIGWi
         bMKeLaH43QJj+/vOUMuSYUHhdfGeG0+2c2z8ubiVCv9ArhRJc7AgF2I30UT6bUJDY3Fj
         dIEYhKG3rTFK0VBFEY5AZqThiXKlMKl+bbRQszqdAF7WwgYouq6m1mVbr/hnmAbLPY8G
         Tq1A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWgC+36FEYCN9TP37gR2xMXJvgN+ts9E9W490xeervR4ZDMGIkp
	wKw9MQv2A4CEwR6imLuvYBnvSfRfhaik1vQh7ydKj2nFpX9WekUUYOMIVQBWj8Ii1dkMjKY0naq
	mUIqxXR7qgaTrI0tNETPwJ4zMsk6ymd4TRu2XzbS1Sg8F6gWLTOTqv6pZbtmaUkE=
X-Received: by 2002:a17:906:698e:: with SMTP id i14mr87663949ejr.122.1564738831596;
        Fri, 02 Aug 2019 02:40:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBF8m046a0V31cZSZZ+2QjmX/U87GcSZE6cxBbzPtqdvVPIZqRj7Erb/LouPfiICsd/ykb
X-Received: by 2002:a17:906:698e:: with SMTP id i14mr87663898ejr.122.1564738830770;
        Fri, 02 Aug 2019 02:40:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564738830; cv=none;
        d=google.com; s=arc-20160816;
        b=QMIvilVS2v7vSiVFyUUiymQgwmtPVsIV48lA2O4emm+5eNvYTDfFNuxARdHNL2oZxT
         995VqZeS2u/5arpWk7TV3SOLhey3gPmD1RvUXLRrR45dRmDwxOYcEjvTS7UZYN5j69fE
         dLB/an3DOSLRrftiYE3sIy8Xps75KhGpETe0g2bKLHM5HbazWzNI0j3/sTysr5u4ljkz
         HekkJi1jOrsyrznzs/GoMFusR/8PvkhG1MGMg0id2bnp1AotJ0mTuOEtkrNgusl/0Z8W
         MkwL8SdoPWXrkRYdTPpv4R7YqiqiueAKT7/Io45TjzSi1rDS4tK8iFZXGraS/KO+HjhY
         sDDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GVvRLyZwxdfn9nyNqh7UZq5Pv7RIZE41nfZGdWdwPoo=;
        b=P5l9CPrbuy9wCUZQbaaqh12QAbBrf7Ugc/JHc2nwcESJ+3V3N4efTiVS/w4RT1zC9a
         jrOp4QTz6dHs4BfArzuLzyxYWWGeZk+rCV1uzjMdn2KHnFBIsJmQrGtwGVaXMoQsQGR7
         gRZHHdXXU/ArWtG6WkzPoGEL1kIOjupSML2ya+Ld8PLqXow+kjQEcdgxItg44vBQ025K
         /p912OZLNOKbOmlkxuwnHy6M1puxJN0c8vPD2t9Rk1VbftbKn03LQrK+VZDxbVG49Qwc
         fSSB2Sks41evyowY5SUbpi6m2utDtSyzWrxprKTyq6WXsDka1JICI1W7FDLPN4hVTrRT
         3UAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dc19si22012992ejb.324.2019.08.02.02.40.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 02:40:30 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 30C32AE50;
	Fri,  2 Aug 2019 09:40:30 +0000 (UTC)
Date: Fri, 2 Aug 2019 11:40:28 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
Message-ID: <20190802094028.GG6461@dhcp22.suse.cz>
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729154952.GC21958@cmpxchg.org>
 <20190729185509.GI9330@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729185509.GI9330@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-07-19 20:55:09, Michal Hocko wrote:
> On Mon 29-07-19 11:49:52, Johannes Weiner wrote:
> > On Sun, Jul 28, 2019 at 03:29:38PM +0300, Konstantin Khlebnikov wrote:
> > > --- a/mm/gup.c
> > > +++ b/mm/gup.c
> > > @@ -847,8 +847,11 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> > >  			ret = -ERESTARTSYS;
> > >  			goto out;
> > >  		}
> > > -		cond_resched();
> > >  
> > > +		/* Reclaim memory over high limit before stocking too much */
> > > +		mem_cgroup_handle_over_high(true);
> > 
> > I'd rather this remained part of the try_charge() call. The code
> > comment in try_charge says this:
> > 
> > 	 * We can perform reclaim here if __GFP_RECLAIM but let's
> > 	 * always punt for simplicity and so that GFP_KERNEL can
> > 	 * consistently be used during reclaim.
> > 
> > The simplicity argument doesn't hold true anymore once we have to add
> > manual calls into allocation sites. We should instead fix try_charge()
> > to do synchronous reclaim for __GFP_RECLAIM and only punt to userspace
> > return when actually needed.
> 
> Agreed. If we want to do direct reclaim on the high limit breach then it
> should go into try_charge same way we do hard limit reclaim there. I am
> not yet sure about how/whether to scale the excess. The only reason to
> move reclaim to return-to-userspace path was GFP_NOWAIT charges. As you
> say, maybe we should start by always performing the reclaim for
> sleepable contexts first and only defer for non-sleeping requests.

In other words. Something like patch below (completely untested). Could
you give it a try Konstantin?

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ba9138a4a1de..53a35c526e43 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2429,8 +2429,12 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				schedule_work(&memcg->high_work);
 				break;
 			}
-			current->memcg_nr_pages_over_high += batch;
-			set_notify_resume(current);
+			if (gfpflags_allow_blocking(gfp_mask)) {
+				reclaim_high(memcg, nr_pages, GFP_KERNEL);
+			} else {
+				current->memcg_nr_pages_over_high += batch;
+				set_notify_resume(current);
+			}
 			break;
 		}
 	} while ((memcg = parent_mem_cgroup(memcg)));
-- 
Michal Hocko
SUSE Labs

