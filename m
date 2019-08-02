Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7F14C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:59:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 840F32173E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:59:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 840F32173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C43516B0003; Fri,  2 Aug 2019 04:59:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCCE36B0005; Fri,  2 Aug 2019 04:59:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A65E76B0006; Fri,  2 Aug 2019 04:59:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5435B6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 04:59:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b33so46508294edc.17
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 01:59:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pwoBRHTt34v3MyGUXe9+vTyAcJC/7Y+fLlbaM5uT68c=;
        b=MlqYaHqOZwZg93+cR+fW5Mn1x3Y+vu4E3nEil0Dh9+qOATO8/2PcvisGrcQp8BfBuT
         hURINqIusATjQ9YQ4/TvYxpJLGf6HcPDdFsbTcp7Hnho7mZJ8ZYjMPQ6DX2jnCcFfTZm
         23oR0m81NyiV8ypzdup8MyLM1UiSMmyPM4OfXeFuR20DlMDuncAks+pmfpkj+MqRUWNZ
         NvQX/yWdxldoreCmprI677tt8+K5EG0weDSUKrtEP4NATCOMxrio1VoyEEcNw3QweQbn
         mLJTsiQ17ho5WqDOoBUJeA3/e/Inm6+Tw8QekYKfbkrwSWlIS144upCLc9aS1HN8aoVx
         7nhg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWkAxPPMZW/chdxAazXgqVNlSlA3X+dYqoT9KpjDNsmPp35RW+K
	Pw+N1IgYF0AlCepWnMiPZKR2pRPWj1s5DKbpQvbV+YV8ofHOdj02j544Dgy0vy+MDt+DgTPuGuQ
	RLkvM5+qcUzXgRT9lvdXA0E79j7yPCO9WFjuafxAX42+scdiK7UsxnOsc7Y90Pp0=
X-Received: by 2002:a50:b13b:: with SMTP id k56mr121407491edd.192.1564736390796;
        Fri, 02 Aug 2019 01:59:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBi+rVeFHY86CcSZv4seuI+6BA27P+n3Dy3Xz3lcm4b1ocJ9XeeDbXx1F0thTogyL1T7m2
X-Received: by 2002:a50:b13b:: with SMTP id k56mr121407459edd.192.1564736390115;
        Fri, 02 Aug 2019 01:59:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564736390; cv=none;
        d=google.com; s=arc-20160816;
        b=SYNo3c/pCtRc4sFJFv9Blr7TCBKlNCu2Z6xFZfErLPd+W5UAxsiJSzusi/Omu1wJGh
         O0pMWGLY80W3EvaLL6mdrZo1Y1gnRXLFvNmoQdkbvCjl+83Pm9U8uQqgXJyg9ePtbkql
         tlXuX8bNhBHKOWch0ohkAh6zFmDdKBjF4QJz8kSUGoC8rEx8dvoxaHa1gFJ89RpgYAp6
         MYIn0+orpd1o1ms9gSbmQ03n8QRvZK9aOcANKiDWcJzkMbx8GtF12rFbuu+UH1CSHplF
         7sUQEHjQnz6vZJfbz+g1cAyZNav9E6vTKNXzvMnU3XfcLWqNT4b4Qdt49T04Mr0JZZ5f
         eOtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pwoBRHTt34v3MyGUXe9+vTyAcJC/7Y+fLlbaM5uT68c=;
        b=eZic+YB+Ow7IMstusA1pO0mHYZ4eO/wVB6Yw9Dxj1Ai3fQi1V1BV/GKfTQz9Bpf9OK
         +DgGWefiZ3gKsFpTPPZV6+Z3fsl9LjAPmwAkZShFLGKbdrqr+eR6ESigLdbJLf+p/hhP
         Cq0NIKSycQXwmUmzNuan36z9g2Ws3CLeVNEg+89grTw09nn78NCtMpqhcpek7TRnlPvY
         6khnWm0yyG3gU/56v+P8I6yT4LVdiI3sgD090L4KHGamKfBwBjqmkgjOHH7l0kGAOWbf
         vJduVFa+gifKaFnBtNQzWrJUu1etLbEd037yO7EP20lwjH9cGvQWwqQNcHSeDowNg1kc
         Ae4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m55si24192130edm.55.2019.08.02.01.59.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 01:59:50 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AA743AB8C;
	Fri,  2 Aug 2019 08:59:49 +0000 (UTC)
Date: Fri, 2 Aug 2019 10:59:47 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: [PATCH] mm: memcontrol: switch to rcu protection in
 drain_all_stock()
Message-ID: <20190802085947.GC6461@dhcp22.suse.cz>
References: <20190801233513.137917-1-guro@fb.com>
 <20190802080422.GA6461@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802080422.GA6461@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 02-08-19 10:04:22, Michal Hocko wrote:
> On Thu 01-08-19 16:35:13, Roman Gushchin wrote:
> > Commit 72f0184c8a00 ("mm, memcg: remove hotplug locking from try_charge")
> > introduced css_tryget()/css_put() calls in drain_all_stock(),
> > which are supposed to protect the target memory cgroup from being
> > released during the mem_cgroup_is_descendant() call.
> > 
> > However, it's not completely safe. In theory, memcg can go away
> > between reading stock->cached pointer and calling css_tryget().
> 
> I have to remember how is this whole thing supposed to work, it's been
> some time since I've looked into that.

OK, I guess I remember now and I do not see how the race is possible.
Stock cache is keeping its memcg alive because it elevates the reference
counting for each cached charge. And that should keep the whole chain up
to the root (of draining) alive, no? Or do I miss something, could you
generate a sequence of events that would lead to use-after-free?
-- 
Michal Hocko
SUSE Labs

