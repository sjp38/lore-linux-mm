Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BB5AC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 18:23:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E19DB2064A
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 18:23:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oCZtbd8w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E19DB2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 784016B000D; Thu, 18 Apr 2019 14:23:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 734026B000E; Thu, 18 Apr 2019 14:23:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 623596B0010; Thu, 18 Apr 2019 14:23:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id ECEE76B000D
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:23:24 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id r135so524765lff.18
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:23:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=vC2agpd/yeTIjkC+tv6Q0HWjOpOqDC0mbvCHm0eBf4Y=;
        b=qnjK7BRNGucQfVkO3mordmWlYZuSwWABNirAuleFXjUINIzY69IRk+WiaQbaG0wKXe
         UdTim7Hqx6OQVU6rgYcZ4kWpkn9iv516aoURIO9H2Iuj4F/s4TDwGdYJvVWbdHcKop34
         OmSSYrqsHasEuUdvBj7cWXTtFf1zQ9DMMuhKMvii2n/Bd7vxy29SeadKSFaGnpSP0meM
         yOA/IbNEHQU7bQElMht17l0+/OVwTHSC8FxeElrV6JBii2bHuQZ1iBopXaWPLqHA6eZ5
         HGChXHXkDtL2iDAyRpFzz6q8EGLeDL6PuMVEZ7xVABTvkV1cDhANWCbUO6hEzDjr23Rz
         7vew==
X-Gm-Message-State: APjAAAW7q7l6IBpOphkurA2QVtJ4zTGxZLM5zBq/FlDeGPzUUuRHznzl
	RtHA2+Kl1DcFHTY2UggQM8tS28+gS6RR2VkA2+THUhn4yEHZyFD7FwmPctpDzJmLMmley3rXNU7
	QEzreabtuaCP51ptT7bUErE4gRFgHlwcrrRRrIPSzFSnH6/QJGdL1toUgQNhBUNoxIQ==
X-Received: by 2002:a2e:380c:: with SMTP id f12mr54713073lja.116.1555611804013;
        Thu, 18 Apr 2019 11:23:24 -0700 (PDT)
X-Received: by 2002:a2e:380c:: with SMTP id f12mr54713033lja.116.1555611803168;
        Thu, 18 Apr 2019 11:23:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555611803; cv=none;
        d=google.com; s=arc-20160816;
        b=UBvfh/MouNrdMH3S+8UlfkH97Jw1nae7z46NH2iegrAl5Z3VHOsY0c42CzST5J87Wo
         FB6HSeD84xwYa2tw8FA82SJiQz/hcyoN0MhEElNFZQmz7DfiRoL9Y64yju09T5xOPvyg
         FwWtNrqL0v2mLkMnhOq2VwQwurRimBdV6QPMjppGr+PuohVXd1gkjg585bqX2AfQLXWv
         Ne6sDxY7CkqRcEgiBUef3HkeXyRlw/spfFZZlCcwvBcELWAiYNqAO+HK9h8oBTQqNGOA
         MWPBTORSOosIgdJ0pbloHKJoCxAgpwipS/fMkNUqdsCBnlzZIRAcqARZZM953pKLpFWT
         eyFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=vC2agpd/yeTIjkC+tv6Q0HWjOpOqDC0mbvCHm0eBf4Y=;
        b=uzS0+maGIWzQlYXNfmmwdzCvxRZyxB7nkERKjUCTz/HvIzXmEKPYfs9BEO+u9sBuQm
         T0Y41uPYUeDVYpyDPipt+9ratOFHFq91qFlijc+3laPyatxW0HcWvUpvO4EhzP5jZE8i
         HArUsYe4fDzzRHPTygV/7mCnv/GvBqX7jJVGHPHLAD9xOZ5GIPPPcdykPlAM6rRd39H/
         qVvbjwtLq73umjBOJC57lINqKTHGdTvfd52XShHEJ4RgRl2hPNasKn/oKx1YTDI3mj8J
         6wm9MCd47hXpuHw5FdxQEkwYQKINQnH5Svxaj4Uj6PhxM94xflJv8kLp7QslfjZd96qz
         KbXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oCZtbd8w;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b26sor811554lfa.36.2019.04.18.11.23.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 11:23:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oCZtbd8w;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=vC2agpd/yeTIjkC+tv6Q0HWjOpOqDC0mbvCHm0eBf4Y=;
        b=oCZtbd8wbvAsIKhSYoUJZQVeVFzI9LhVk5xw5A9aYv70oTCxPDa6CUjfhq+7Ko97Yw
         5EBuW7fdsXGgA4duhAS6WpIwtYcQqgAk9n2TFWUG9A7Guuq6Wjh96ylkUMKabdIy43a6
         8DlL8MSTSorKUkzsLvIHVbj17K+BG/zixxqBZhZOCrrzOYOTMKXRFKWY3xzHa5FX0FnE
         N6PJsM8S5vsd0FFiKD5cO1kUvacWe5/8AigkrFKVHcH1e2gmueli4YEM7P5c4pgH8ojH
         IXmHDGo8zSl1fe/FBh+n8Fy+4L+B3KeT+Qf9JY48R+SfJhpOvzSGNTMAIWBWK6bhaoHX
         t7lA==
X-Google-Smtp-Source: APXvYqyBjDf0Lb5iqi1H4sy3SWYyTORWzsqfNAlBTaJ1dtcbk6DdNBZyJ36/uSTPPp/2Mrwa4eR7NA==
X-Received: by 2002:a19:c51a:: with SMTP id w26mr50367270lfe.59.1555611802703;
        Thu, 18 Apr 2019 11:23:22 -0700 (PDT)
Received: from uranus.localdomain ([5.18.103.226])
        by smtp.gmail.com with ESMTPSA id n28sm90162lfi.79.2019.04.18.11.23.21
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 18 Apr 2019 11:23:22 -0700 (PDT)
Received: by uranus.localdomain (Postfix, from userid 1000)
	id B8D49460E21; Thu, 18 Apr 2019 21:23:21 +0300 (MSK)
Date: Thu, 18 Apr 2019 21:23:21 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
To: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, arunks@codeaurora.org,
	brgl@bgdev.pl, geert+renesas@glider.be,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mguzik@redhat.com,
	rppt@linux.ibm.com, vbabka@suse.cz,
	Laurent Dufour <ldufour@linux.ibm.com>
Subject: Re: [PATCH] prctl_set_mm: downgrade mmap_sem to read lock
Message-ID: <20190418182321.GJ3040@uranus.lan>
References: <20190417145548.GN5878@dhcp22.suse.cz>
 <20190418135039.19987-1-mkoutny@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190418135039.19987-1-mkoutny@suse.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 03:50:39PM +0200, Michal Koutný wrote:
> I learnt, it's, alas, too late to drop the non PRCTL_SET_MM_MAP calls
> [1], so at least downgrade the write acquisition of mmap_sem as in the
> patch below (that should be stacked on the previous one or squashed).
> 
> Cyrill, you mentioned lock changes in [1] but the link seems empty. Is
> it supposed to be [2]? That could be an alternative to this patch after
> some refreshments and clarifications.
> 
> 
> [1] https://lore.kernel.org/lkml/20190417165632.GC3040@uranus.lan/
> [2] https://lore.kernel.org/lkml/20180507075606.870903028@gmail.com/
> 
> ========
> 
> Since commit 88aa7cc688d4 ("mm: introduce arg_lock to protect
> arg_start|end and env_start|end in mm_struct") we use arg_lock for
> boundaries modifications. Synchronize prctl_set_mm with this lock and
> keep mmap_sem for reading only (analogous to what we already do in
> prctl_set_mm_map).
> 
> Also, save few cycles by looking up VMA only after performing basic
> arguments validation.
> 
> Signed-off-by: Michal Koutný <mkoutny@suse.com>
Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>

As Laurent mentioned we might move vma lookup before the spinlock,
but this might be done on top of the series.

