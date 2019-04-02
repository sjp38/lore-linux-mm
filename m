Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 219E3C43381
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 07:49:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5ED62084C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 07:49:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5ED62084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 725776B0269; Tue,  2 Apr 2019 03:49:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D53F6B026A; Tue,  2 Apr 2019 03:49:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C6BD6B026B; Tue,  2 Apr 2019 03:49:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1EAEB6B0269
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 03:49:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l19so5382088edr.12
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 00:49:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yPx97lo5C36fgiWKhGMYngbMg7wsjQYx1oOtePNCxjQ=;
        b=uArwYWO3gQgKo1lf1AwJdjcboQDUh8wbhini+Ld82/wDNtAkgOU6eduOt6ofLFOU0M
         a1ArbN0IeuN0Wt7CIKVDzzds4q/L8AE9yyXrwPQKjGKPtuoDN23FjcPahpc0Cun0t2jt
         qYSEL+Y7sfSOKg43KwkDl2NaV/kwMHnVNc1pmjkxIdiqjkUtHYpgsr+6WwRdgcGmEn5e
         Lts4YJUkSHYsDTodFFt69HygDRssTKuLntZXk5WcsbuatYRR8LRE572zCg56Nh9d3IGv
         mGTj6W5UTT/HA0VEFndCqvkGMDBuMoEsZKPHud788bTpRMaqf336Va8Sz48nF4qr5nc0
         qQPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAWpwi+BT592x8w20jsnrNgqDgXsTJef09aq3VWocBtItLuelO9U
	vHiKw8KLYMEev6+gqfe3rC93ufksqVpxrQnoLYhfReQZJ/2ag1IPKkuvJO7VxAEwD5K4MT0lhJS
	rAM7KD43RrSmyMXq8H6igmacepo5rXAhCsNT4xCq+Jwk8lBWx8j26nnXM4M7u64pSzA==
X-Received: by 2002:a17:906:3fc4:: with SMTP id k4mr12881793ejj.166.1554191353525;
        Tue, 02 Apr 2019 00:49:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNYCXIxq2+uqSxnTWwSG1zMJIwmspVcuVYLsKRPB4ZR2EwlKymGQvbhBb6+6YIYBjNtuEQ
X-Received: by 2002:a17:906:3fc4:: with SMTP id k4mr12881756ejj.166.1554191352729;
        Tue, 02 Apr 2019 00:49:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554191352; cv=none;
        d=google.com; s=arc-20160816;
        b=bRaruzQFk4gWbAGGgdt8DxpnD7okqZbyXfwZ88L+pCyvo20TLYF+7K1fxPSS75BrwN
         IyR6FqAHN5/yZYqLhOeWsWkvjPStogpP/rCCZ+MaTfWuLpdA3Vjn9pnQPsPy2XqG3RpZ
         6nhPXAiQrZiceQldSMcolp5C3FyDkFsOyDDpobsBQbqaS7l7b1s6X/ON5Zx65askf1wl
         bPaXOJ8oSWEl3gWOORWlJP5WMMGnvWVAKD4x2ajO8/rrvksWxYlTnHDumhf8jTh5ft6P
         4QrVZmdBkcuRwA9ShantFkrZoeYgUUxdNPprXQbN2R+XJVYUjJF1EdItkFciFF1QTvAi
         3xyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yPx97lo5C36fgiWKhGMYngbMg7wsjQYx1oOtePNCxjQ=;
        b=Q32O7dDCM5cL35Pp3ZRdC6o3BiDN7i6OildCsGT0MsWcNAY002bUbnr7n1VUblzkmi
         r3uIkKuCjmpdSaDo3iQtlTkY7hwsrBXySVmirZqcfS4DvyTKDHTKQjMXdgGkXRcap+Vf
         dNnwbfHPR7UU1+2EKBX2et7T5A7lUvnHat+7z6MMj8rgvQt6EX2lEQEuOijqq3+Jv+o/
         XQzhBRhmV+1pHmE4yUt16mB4IijwmOmF8+r4jkiHMk6s5z8gl4RajTlicV+cNuNPAcA8
         xQI+i9RNWQv8sOlKWEsl0JtZlRK9G9Nj2mYmgs7jFFhSDrt46wQioKz0bfS6m0K90Wyj
         PrWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g7si1394779ejk.311.2019.04.02.00.49.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 00:49:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E4FECABF5;
	Tue,  2 Apr 2019 07:49:11 +0000 (UTC)
Date: Tue, 2 Apr 2019 09:49:11 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: willy@infradead.org, Jan Kara <jack@suse.cz>,
	Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>
Subject: Re: [PATCH] mm: add vm event for page cache miss
Message-ID: <20190402074911.GQ28293@dhcp22.suse.cz>
References: <1554185720-26404-1-git-send-email-laoar.shao@gmail.com>
 <20190402072351.GN28293@dhcp22.suse.cz>
 <CALOAHbASRo1xdkG62K3sAAYbApD5yTt6GEnCAZo1ZSop=ORj6w@mail.gmail.com>
 <20190402074459.GP28293@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190402074459.GP28293@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000006, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 02-04-19 09:44:59, Michal Hocko wrote:
> On Tue 02-04-19 15:38:02, Yafang Shao wrote:
[...]
> > Seems I missed this dicussion.
> > Could you pls. give a reference to it?
> 
> The long thread starts here http://lkml.kernel.org/r/nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm

Thinking about it some more this like falls into the same category as
timing attack where you measure the read latency or even watch for major
faults. The attacker would destroy the side channel by the read so the
attack would be likely impractical.
-- 
Michal Hocko
SUSE Labs

