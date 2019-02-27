Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B4A4C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 09:21:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3EE620842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 09:21:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3EE620842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90D128E0005; Wed, 27 Feb 2019 04:21:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 897778E0001; Wed, 27 Feb 2019 04:21:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 786E58E0005; Wed, 27 Feb 2019 04:21:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 319408E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 04:21:39 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u12so6674923edo.5
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 01:21:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bl4SEftyTvZ6nlNTlPOgS1FMkBTnKrfbu9Kcnz0nbgM=;
        b=fsVbRmeuxs1391bbha7vzVISqaU8AyJEy3EaANQj9j4OT+X2jSeHP2UDtvyqNOu+pP
         OAKvtcYL4tnCxxkc1bQGtNvXaVK1UpKpa4Kk6/YbAvfhOfRAjqLvR9ofGqtu+4iWY4DW
         EUJ1+SEtQOiA8726kKxKE1jldUglLqePJ14YZUF1sHCS57F+XKCZy4ndMY/Ihdl823RG
         AlKpydueJ10mJzPXr/+gQ7TCrV0QWrtq/tGgsCEs88umy9/n03tWetgvY7Oxg0SFJf7Q
         iIcwqF0YYDEib/Od+uYJhvqlsVdJQWOQcGglrvYMZeCue5VQV0IX7Otw8xG11UWyPXZb
         4LXQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYyHgXaMBo4+u1UxeJnlEBNJZ2FhMIGC7qs513vKNd2RzXfHPBx
	3SERq9b0fEpeVirEzIklfOyAQZQOGbduyMFgBWP2NJEF+7XTn2Xjz1EuQyCllVWr/iyqIasUyrY
	kNorqVhAFwWW35R3yhoFkrEsLlxSYsfYmQN1dXZdEsT+qbkociMC2YYWSb0A21gM=
X-Received: by 2002:a17:906:1343:: with SMTP id x3mr793891ejb.76.1551259298719;
        Wed, 27 Feb 2019 01:21:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbHUk/Q+++7EvyCZDkxjSJTETrTy0dvtkgqqTqK4qOYAAMOQUjipNWLr++bkhWGO2FCGgPG
X-Received: by 2002:a17:906:1343:: with SMTP id x3mr793844ejb.76.1551259297921;
        Wed, 27 Feb 2019 01:21:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551259297; cv=none;
        d=google.com; s=arc-20160816;
        b=VN9jiyDg/zhM2pFrOtk2I4dz+6quC51Uon3WZ/iz5+xNCD2+M3iEnj6mZz0SLeQilH
         23Me2+yLpQl6/k+LibLgE6SbV2r8SWKSNei5SUlS3ydzzzKKrVMlmkuM4aCzDL8BXldW
         E57e3rgPdpUWiq4iH2/PD8gnJbpNIYbQNcnz+vsVjiBPajDkfMYZrYrjinG+T6lXjeIR
         gxtWqsMHG9iGeQ1qpmNIX+xQCJD2HzOhvwME1BOvgIlJXlPowgDU1fB4kn4VG0nrgRlQ
         D9XzV5do8uQqtRnNn1Ls+UBHYt8P9mYqVsbZd5T4Mvmahoj44vB44UgGGwIRGXt1Rcc5
         Q5fA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bl4SEftyTvZ6nlNTlPOgS1FMkBTnKrfbu9Kcnz0nbgM=;
        b=0aE9R7LTrBdr35ZMh0qmRg6xiJWMWNTsq+I8D5EmdkOl7jKAr279opAD88rqFMUKsz
         iK4iAeyEhhCbFTiG7ZbPrEazyondrjR/uU0kRX7trwigdp7L8upDazRlb77Y1jb8JRJh
         Ee8M1auV1kR7fv4SEz7rrQUMIXb7ABSS7QXOp4/WWqYp7bpX2Pnq7Y1Wsc/g/d9Tz1cA
         be0nldNUr9son9OW3Q2UwBsa4TZm6/Q/R6VpeGBalyyLPd/av/4JnWKmNBHsQc2pgoI3
         1ZvvoKZEeqUc+rWOsCzXiLonHkV2YPGUd74+frVtC2tDPbg3EuQee61j+cpscB/7iLGw
         dR2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si5957837edc.154.2019.02.27.01.21.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 01:21:37 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7B6E9ADE2;
	Wed, 27 Feb 2019 09:21:37 +0000 (UTC)
Date: Wed, 27 Feb 2019 10:21:36 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org
Subject: Re: mm: Can we bail out p?d_alloc() loops upon SIGKILL?
Message-ID: <20190227092136.GM10588@dhcp22.suse.cz>
References: <201902270343.x1R3hpZl029621@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201902270343.x1R3hpZl029621@www262.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 27-02-19 12:43:51, Tetsuo Handa wrote:
> I noticed that when a kdump kernel triggers the OOM killer because a too
> small value was given to crashkernel= parameter, the OOM reaper tends to
> fail to reclaim memory from OOM victims because they are in dup_mm() from
> copy_mm() from copy_process() with mmap_sem held for write.

I would presume that a page table allocation would fail for the oom
victim as soon as the oom memory reserves get depleted and then
copy_page_range would bail out and release the lock. That being
said, the oom_reaper might bail out before then but does sprinkling
fatal_signal_pending checks into copy_*_range really help reliably?
-- 
Michal Hocko
SUSE Labs

