Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFB6EC28CC2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:09:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A36262402A
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:09:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A36262402A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 553776B0266; Wed, 29 May 2019 14:09:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 504336B026B; Wed, 29 May 2019 14:09:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41A216B026D; Wed, 29 May 2019 14:09:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C18D6B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:09:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c26so4543547eda.15
        for <linux-mm@kvack.org>; Wed, 29 May 2019 11:09:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=EfUXAEKOBEQ5oVgvzLevWaSSNa4NAkEZbhRAn262kxM=;
        b=hU/MWi3bE38tNmVWHkSL0WYSC0n2lDmCz/rCX331Xh/KqOH+m3snSP4KNUnyieD8hy
         rF5IzDv27/ni7urpYNH43MEBH4Fh1GiYLEzGFshbON5Wefv+itgmGoizFDJY5NGxE0jQ
         CqZtpehNaXvOjcQKGkw5LJvhCy1FT9XtzNbTBstdSpVrxdPJ5MbA3SJr3m23nyQciFaI
         pZ00J4uHRW2FBQQMztmUXGmuY7v4AbBuDX+SOeGnr0niDdBBQ1wDZqUjwVXVzzC98OFu
         9K/zaTfV8CUJTSOzBgCvn5zsM88bO0pH9y6JVjno1aIuQXk+ZWi8menrZG5zIuaCtM+t
         jzBg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU9p+mxv6BQUuMlhqHXilfvWotdn4T3Dj+ot9kBPDaGr+CO/ThF
	w1ZD71fxNpBeEfCybRzMEid+Idmoqv9yQCBSy7PyrWvFKbNQf4p/acaTF7dBX9eHAv0ukN7EDe3
	T2j6mPGXejhB/fVsEpPvmbv+DVtaVdVLEdbltdfJ4S7r2EFJYwITcn+2odo4S4OI=
X-Received: by 2002:a17:906:774e:: with SMTP id o14mr83134618ejn.175.1559153373628;
        Wed, 29 May 2019 11:09:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVXJw9ffCOHmbPHYxQNCnPN72j3TvRgmy3tFqzgvK8Q4O+8vlVqcqRUO/kbNnjP+H0r2tO
X-Received: by 2002:a17:906:774e:: with SMTP id o14mr83134547ejn.175.1559153372869;
        Wed, 29 May 2019 11:09:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559153372; cv=none;
        d=google.com; s=arc-20160816;
        b=EQ9pT1NzruAQxvtshIq5kG2YSJkVHdhmAdksltaey/kXASstGUa4ISECYz9Zwz2VFw
         m01IXISDFfH1YTNhxk7mVlSXmqg59aAY7w6ET9YD34rAkCEODM/QvwVxUsoRxGKEHi7n
         Htd8mJ1JWlZxQ+ISxBud/+k0USroJqwlIEIOtF71UVm+Q7ZokJ5QYsrfD+pT5mtGwR7W
         I471DuDJcexXC5K3wU+w0q5Yh7ODLw8D0nfj+44ofLzpiJzCZqoy9VTsQ2LHWqbzPvSF
         9DJ/aJMvscTR82YAvzJ7VCO2cFE5orPkh9RErjK5ns0qQdc6xhELp1qksRV18RTf9e6E
         +CaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=EfUXAEKOBEQ5oVgvzLevWaSSNa4NAkEZbhRAn262kxM=;
        b=F/WPvPdLLjdzc1Q8ef9oqTArKtBLUY9ctKmHDx81eBsVPnCGRtPFm1P/xcJhzavWRr
         9MGL5BqYtjmgEGyip6i4XiiasarA6lHbKw6LcfK+w7R4zTkS04bHcAO05cJACFuzFH8a
         o3ske1gHLf+C27rbVKFIPQifpKkcgN9Ah0ECTeTi5SRJDQCOPK+g9jaA7JKcyMWAcdE5
         JfiqhkyzZpkCxOOMwlnFVqdFa1IyitTeo+to05rWTqsgdwRU+xeZELF8RH0yltLS6Lm5
         7g/yJtj62h+9wVfAIFJKO01qlmlQxdc8FBcl4C/lAJ/6r9qVqmCqHwWyaSoOp4ySCV0D
         mlnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x36si23115edx.60.2019.05.29.11.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 11:09:32 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0BD96AD89;
	Wed, 29 May 2019 18:09:32 +0000 (UTC)
Date: Wed, 29 May 2019 20:09:31 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org
Subject: Re: kernel BUG at mm/swap_state.c:170!
Message-ID: <20190529180931.GI18589@dhcp22.suse.cz>
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
 <CABXGCsNq4xTFeeLeUXBj7vXBz55aVu31W9q74r+pGM83DrPjfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXGCsNq4xTFeeLeUXBj7vXBz55aVu31W9q74r+pGM83DrPjfA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 29-05-19 22:32:08, Mikhail Gavrilov wrote:
> On Wed, 29 May 2019 at 09:05, Mikhail Gavrilov
> <mikhail.v.gavrilov@gmail.com> wrote:
> >
> > Hi folks.
> > I am observed kernel panic after update to git tag 5.2-rc2.
> > This crash happens at memory pressing when swap being used.
> >
> > Unfortunately in journalctl saved only this:
> >
> 
> Now I captured better trace.
> 
> : page:ffffd6d34dff0000 refcount:1 mapcount:1 mapping:ffff97812323a689
> index:0xfecec363
> : anon
> : flags: 0x17fffe00080034(uptodate|lru|active|swapbacked)
> : raw: 0017fffe00080034 ffffd6d34c67c508 ffffd6d3504b8d48 ffff97812323a689
> : raw: 00000000fecec363 0000000000000000 0000000100000000 ffff978433ace000
> : page dumped because: VM_BUG_ON_PAGE(entry != page)
> : page->mem_cgroup:ffff978433ace000
> : ------------[ cut here ]------------
> : kernel BUG at mm/swap_state.c:170!

Do you see the same with 5.2-rc1 resp. 5.1?
-- 
Michal Hocko
SUSE Labs

