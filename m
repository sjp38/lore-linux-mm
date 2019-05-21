Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED2C2C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:47:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBAD52173E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:47:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBAD52173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F8486B000A; Tue, 21 May 2019 10:47:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A7F66B000D; Tue, 21 May 2019 10:47:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 297386B000E; Tue, 21 May 2019 10:47:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CECBF6B000A
	for <linux-mm@kvack.org>; Tue, 21 May 2019 10:47:16 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d15so31054718edm.7
        for <linux-mm@kvack.org>; Tue, 21 May 2019 07:47:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RB/ih1Dsr3797szTwgcU5Z2LQdjakWn14S+GjoQ6Vqc=;
        b=c2T1J4LuQI8zMuduFGsPE+HXFXTjKf3frCJQRTmonPjrwXzqEIB7K6iEFkzab8HIZQ
         ICa6kK6QVxoM+AW+SPIorYPH09RGveYuiq2md1EWxl421TarvyQ64LmtjaMs8UfMRpsN
         rvbXw4pg6FiP1DJOn7CzOH6yMNDeZ9q0E/oxc74vVZC1W/DiOqGh76OPZUlM6OmszuHX
         zEFQJlFW4+ByC5WW+bc4HqgJx7WloALUOYqc5EJ4fOGlEa5Lk2lv7LQsd9tin/pW7zcO
         OAK9MLJm7t5xrrBKooO1b0L8LQVXlzmUzpev5GtdsbtNLp2EUkCe+gQNE8JLYRpuGStj
         g89w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXcLP6NYfHpxCg8ZTpjcPwI7MyRBQbCRj+pcC3c26oW7T8h7zy9
	u5AeDqqV8JW7ZPVdrH3zmKuNKlYVb1E919OOvoXtTdxcuvaZjG4XKM/uU5dK5Wmk9HXBYJotwNJ
	Z3NsuFh2wWhoWf6pXsMxZl77AK0WK7dP/+pYnEW80cwLTzM+sXjzcNn8LkotYNFo=
X-Received: by 2002:a17:906:5a49:: with SMTP id l9mr4161456ejs.40.1558450036409;
        Tue, 21 May 2019 07:47:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrGdjG99ZqNgvgHP6QUSVC6pqgXHj5UhIeM3tD6ByX7sXKjTetzfjInuzjC6m6Z+OaTfwN
X-Received: by 2002:a17:906:5a49:: with SMTP id l9mr4161409ejs.40.1558450035773;
        Tue, 21 May 2019 07:47:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558450035; cv=none;
        d=google.com; s=arc-20160816;
        b=r8JLlAcmJhGMl7+2TPqxw2+ejGmuYlIKvzqy+hozJNYR8FtvSm3VSH89fN+lPY9YUk
         7yd0Y6Ex8fZHxe6opOeC+ZygT2VB+BkGvDpP4/luy84j7gsgq5AVq6FYjiyVM4vUW8GQ
         3rxxW9YqH/w+9lBRLgKlbnZA4dOJkcTe1jkleBTL/XJNoJ0QWnj5wWsqnuupRmMk/DgK
         UDNV5Q+YAE2SGJOF/LVulwaiB+wiG6DkKNm+UoqkOmUgjnIGQjt0D2dw/XW74JwBZL4l
         oDcUaVijurG9dgYsVtPJpIpU1MBp782HvibXELv1d9HXQcWde2V4N2QWhJmSKhHYXF+x
         cI1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RB/ih1Dsr3797szTwgcU5Z2LQdjakWn14S+GjoQ6Vqc=;
        b=NEr4K6Cp2sx8FxdK79tSL+s5vJGeMg9jCVNvozoM08EVuR5F1xN50CG3hogtv2UMLI
         Q+1GuMUx1eBt7SBTx0/z7kI0o+8VjX8us3IK8rz9yYD2wiiCrg12hNW+IUEOl/9TOWQJ
         XKObapMXeXej/QcYS5RZF5rkm88eqnXJCxX8JsjCm93EvhKVdRbZl0fAs6fMmPzDZ6+2
         ZApb6szM5xcgUAz90Y1JKGSPxlDtkb1WEOSW9OqHYbjwv19ZLtQwLgjvMvK8z6Ycf0B0
         +P+TGCa1WBdjPvrcpzStc/nG1PTWDPI51cEGB3AhSpo73N09FIMPNBq4PaAlCaYBbdpq
         Hs7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h4si3010652ejc.386.2019.05.21.07.47.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 07:47:15 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ED24FAF8E;
	Tue, 21 May 2019 14:47:14 +0000 (UTC)
Date: Tue, 21 May 2019 16:47:13 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Christopher Lameter <cl@linux.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH] kernel.h: Add non_block_start/end()
Message-ID: <20190521144713.GX32329@dhcp22.suse.cz>
References: <20190521100611.10089-1-daniel.vetter@ffwll.ch>
 <0100016adad909d8-e6c9c310-36e0-4bdd-80fd-5df1a1660041-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0100016adad909d8-e6c9c310-36e0-4bdd-80fd-5df1a1660041-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 21-05-19 14:43:38, Cristopher Lameter wrote:
> On Tue, 21 May 2019, Daniel Vetter wrote:
> 
> > In some special cases we must not block, but there's not a
> > spinlock, preempt-off, irqs-off or similar critical section already
> > that arms the might_sleep() debug checks. Add a non_block_start/end()
> > pair to annotate these.
> 
> Just putting preempt on/off around these is not sufficient?

It is not a critical section. It is a _debugging_ facility to help
discover blocking contexts.
-- 
Michal Hocko
SUSE Labs

