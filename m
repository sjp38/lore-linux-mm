Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E6A7C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 13:54:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10E4721670
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 13:54:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10E4721670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E2958E0003; Wed, 26 Jun 2019 09:54:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76B5B8E0002; Wed, 26 Jun 2019 09:54:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60C648E0003; Wed, 26 Jun 2019 09:54:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 09BEF8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 09:54:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m23so3355809edr.7
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 06:54:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xXr3uz6EvKpjzSrBgtJXu2l135EJdGIcBr08dZAq+Fw=;
        b=eKyycE+nMVPrBpilcYNkLuA+Xkd/IXuXcVUuv++zga82qepQswt9WZibaN5ybfMQce
         92jBuznxDhBUSwb8VxuuS8AHuhgHS/wUOwism90CKFv+BqkPUwE5R4nXLcHZHvik0weq
         f85MVeTAdsMz8kOFO4F/P1vXuOmIAR/kHBFx+0PI3H8JlM7ok4DBBZioScKX180JRZ3i
         lrbhm5KTjlejra8gYqitgL+lSGSHD7357Cn/+wd9ecfOPsgH10EY2RQKvpYTOdyKbdHX
         6isVORpSM7SzSeLYTElirKsUnw51iPoCFAQ7jXbyu4tSR+nr3d2demticgvwyizf+Z3U
         dpxw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUk9/TSZe5wH4s5zTytno+nfNnZEySMgjsrfrVPRwsCBnS3SCyL
	ziN6HPGdl/o6VOifLLbTiSXkaC66tpVKex22iZHBIwVzPptw2hF5YeD/cOdNw+75sFa+AYh8uaq
	Pcwtky6GtqVg/z7p47Cr4AM3DPn1waB0/uvAYsxNyIG2VZcasAA6n7AZRL1jlM+U=
X-Received: by 2002:a50:9590:: with SMTP id w16mr5620328eda.0.1561557294638;
        Wed, 26 Jun 2019 06:54:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxS5t6eDGoUeJHm2y30mrzQFtLISlkzPp98vlGfIjPY9z19MHbT4yO2YmXgMOTYNY9I7RfJ
X-Received: by 2002:a50:9590:: with SMTP id w16mr5620263eda.0.1561557293847;
        Wed, 26 Jun 2019 06:54:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561557293; cv=none;
        d=google.com; s=arc-20160816;
        b=uN1LKmfRaTFXJcChiZjwchN6pMi/Sd2+vsPDhBZ13S59oY7cfx6giu2nQJqhGVP+t8
         OyVUXUJvrydQ3vc7FTU89h0/Xvq0PKGnEgwkwLZnebJ6z+zmClMn1otuCA+F687z5YNb
         3392gTeWd6pQMXRxmQWWfIDEZoz1eXOrhTD13vAhX4eSKQQP0KSE5JRTJVfRbmf5yOY4
         pMe7tLLuDPRHR1x/4LNp1Z0Srnyvk8JJccDo0q/CpEMNk97C+LKXSzjRt1iHX0aYB8F1
         r+q7PlbTJdPUUHpeEWyHhpBp0gMPzC7WHwj0q5Yan3I7OKU55t6nedKDfaCdNPXgSQXb
         YADg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xXr3uz6EvKpjzSrBgtJXu2l135EJdGIcBr08dZAq+Fw=;
        b=ABLLIHUu3tBkFc43W0p5m7ZXYdumOVsR8fAITyjih37os4OXOTJFQKbPUzf3WVqfAF
         2EZIqRnQt8vp8/iGqOMaZbTl7Xq24ScVYOPuMElTQZljtOJSXsLjywI6lOcSYD+dCROo
         Yq7IHX8voRdWfSO9sI+bryPJyvTtdc+51jA++y7o1nnYV34QZlGYZuHKpd6sTMyl0MkU
         ScRFy/bXy34gn6jv5lYAThwo48TtC5CZn7yOF1qqKgDSqpqD3XRVUbH9eGG+QLTZOu9w
         D4y7cURtS9w6aP8FkjVNjdYQ7kU8Ltp6UnOELO2H69Lrc8bGTnYKypGRtfeRwZplv884
         jgNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z23si1867885edc.256.2019.06.26.06.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 06:54:53 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D2ABDAE3F;
	Wed, 26 Jun 2019 13:54:52 +0000 (UTC)
Date: Wed, 26 Jun 2019 15:54:50 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Barret Rhoden <brho@google.com>
Cc: linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] x86, numa: always initialize all possible nodes
Message-ID: <20190626135450.GW17798@dhcp22.suse.cz>
References: <20190212095343.23315-1-mhocko@kernel.org>
 <20190212095343.23315-2-mhocko@kernel.org>
 <34f96661-41c2-27cc-422d-5a7aab526f87@google.com>
 <20190502130031.GC29835@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190502130031.GC29835@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 02-05-19 09:00:31, Michal Hocko wrote:
> On Wed 01-05-19 15:12:32, Barret Rhoden wrote:
> [...]
> > A more elegant solution may be to avoid registering with sysfs during early
> > boot, or something else entirely.  But I figured I'd ask for help at this
> > point.  =)
> 
> Thanks for the report and an excellent analysis! This is really helpful.
> I will think about this some more but I am traveling this week. It seems
> really awkward to register a sysfs file for an empty range. That looks
> like a bug to me.

I am sorry, but I didn't get to this for a long time and I am still
busy. The patch has been dropped from the mm tree (thus linux-next). I
hope I can revisit this or somebody else will take over and finish this
work. This is much more trickier than I anticipated unfortunately.

-- 
Michal Hocko
SUSE Labs

