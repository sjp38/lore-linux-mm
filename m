Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 147D7C06511
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 06:56:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A90A121897
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 06:56:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A90A121897
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03D0F6B0003; Wed,  3 Jul 2019 02:56:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2F8E8E0003; Wed,  3 Jul 2019 02:56:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF6BA8E0001; Wed,  3 Jul 2019 02:56:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E07D6B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 02:56:34 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so940093ede.23
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 23:56:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jfv9gRnY9t7SvkI8JTGdad6rZxRWX9kuKh2PqgPGXDo=;
        b=oiYYyag965d1p8wE96BLNMAflZ7AUQJVHQsyLIyRotaFfmh85C6N1haLuF0M461ZVw
         vK35AVI8VPE6ExYb+x4Kpiju6yjHRbGzH+n4lKko1wpJxvKQgtujCRk5X21wzyqsvA47
         VzTG3RUflBptjzMnCUbp4UJ//lnfGrkrwEY/Yq59Zd/t5MpJszZ4D7YhbAD1iaVKkP6R
         85zLPX/lxZ+aRP6IsyWxYYkcuNXSQFDFkEIqQn09A6T2O5bDcrTEDvZ76aQqCxxHeba7
         n+5vGLyS3N6B+9CZ7kZTjFK1huMvgUjZ+kGmogMiMMbs613i0k9KDCS4+w1LNGTRgyhk
         EOVw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXVlhDc9lKPX7lSvJmGDJxMpBwRNBimWscH7oIx3BRBEQzfPHGQ
	VXBII+dyn22dPUaMpyfZ95fRBJJW3QVU2iz+VPfEH6d7xv4yj4exqSrcARGsjFhIUh4Vovq4vbr
	DL/FAkDsByyltaij3+p2gR2amZ4HK1svQ5Iu32SaoYEXOBKO24KUp6MuSAn+TV8Y=
X-Received: by 2002:a50:9451:: with SMTP id q17mr40454757eda.119.1562136994057;
        Tue, 02 Jul 2019 23:56:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhHmNQowAYKmwxx9Igpm3xHqmi7lUg3fuT/blPcGAA193UhTCzWtius2aDhxUqteE7HOJo
X-Received: by 2002:a50:9451:: with SMTP id q17mr40454712eda.119.1562136993335;
        Tue, 02 Jul 2019 23:56:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562136993; cv=none;
        d=google.com; s=arc-20160816;
        b=OreBhlZfGr/RuSkz9B3sVqTvsyfX6QTJ2AU9ynXFAaahV/bJRzKv4adGv/akkt6qpi
         N5itGcW1oeW8x7IUcZF8rEyyKIVVImZn4WQFowkGy0WByVJIMCxXEnOgEydwm9EuDERX
         3pdEdHHoNqr7+rAfxYDgIj5M/l0D9XN7onMXgsoQeW+qOa0RGFPX9ukBQLKYZ9934p50
         enl9qbkYKZtb/7Rk92xBeintiJedrIxFiIHgQdjwdikMuTNGGPDlXptTriqpQmmP2E5C
         mDBNtke11nw/CLb3h9rNIXZr0rbaWn9eioPpd7IZr3lBc3uGP5erGOc5WTkkp4VzNf1E
         4uyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jfv9gRnY9t7SvkI8JTGdad6rZxRWX9kuKh2PqgPGXDo=;
        b=Kdx3JmHWoxzd5AV9XE0glbDOFXMDPRgg47j5C4kL3Ya/Ck/RoJn7ajg4UVl9SSlAmx
         +7UdXA+OVSYc/iDE6CYQoCayTKn0OECAlLgYyUvk2QCAwHBZ6Q9Bflih+ZYd/IQxtcCZ
         WavGK/SkNviz9pESeWk65jJSIRRNimDT/RhpW6+WXHzgTUqipAiL4dQ5RZUUElOJBzFj
         VfMTkoGHNNJt8uePEzqcyvpiDUrtqsnP9QQMvS4VsyeXkG7KNc3YSDRPcmDhhq/cBXND
         +TyiV4oSV/baTBDteQiwbSZ+RIRGDryuByGX7ldtP6d9Dn4zC9pqFi1tIrIxsaZETG0K
         1bYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c48si1320234ede.122.2019.07.02.23.56.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 23:56:33 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 84525AF84;
	Wed,  3 Jul 2019 06:56:32 +0000 (UTC)
Date: Wed, 3 Jul 2019 08:56:28 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
Message-ID: <20190703065628.GK978@dhcp22.suse.cz>
References: <20190702183730.14461-1-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190702183730.14461-1-longman@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 02-07-19 14:37:30, Waiman Long wrote:
> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
> file to shrink the slab by flushing all the per-cpu slabs and free
> slabs in partial lists. This applies only to the root caches, though.
> 
> Extends this capability by shrinking all the child memcg caches and
> the root cache when a value of '2' is written to the shrink sysfs file.

Why do we need a new value for this functionality? I would tend to think
that skipping memcg caches is a bug/incomplete implementation. Or is it
a deliberate decision to cover root caches only?
-- 
Michal Hocko
SUSE Labs

