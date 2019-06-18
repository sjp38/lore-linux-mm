Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DCD5C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 15:22:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 358A220B1F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 15:22:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="S0baOBWq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 358A220B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C62C16B0005; Tue, 18 Jun 2019 11:22:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C13658E0002; Tue, 18 Jun 2019 11:22:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B28648E0001; Tue, 18 Jun 2019 11:22:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 658BD6B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 11:22:20 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y24so21760643edb.1
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:22:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:mail-followup-to:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=E/qk0N+cIbM6HKj1qhjne1NfpocVmMqaX5q+/tL+ueI=;
        b=Ha+ddr++oyzY712kbYD2AYrBqMFwtHND4P5LrPMOOXicpiP+wXW+w5Q8a2iLoFryfJ
         KAqUZMW6GyKdgZ41Xrnfe6vN5ot5vz7I8r1+J5j9Om+SuFUbzTkAXr3TKzClChOeuzwG
         5G6ZBwCmnM6S9ASNG7299rV5uQuLwqWtN675it/ch/TimfpR7y2XpFmCdWYi0Izjvk9E
         gashFkj4g0KdYkk5z6rUeLINmYyvkCFhcRi6sN/na+H/NL1O2Smx8sO7Ame2iP8+183s
         J9WavbxOFEVa0HiKFGEX4nYrZKeAIVPDwv8pD/ENYbkX72io9uWXfQCs773XSEQrkj7/
         sd7w==
X-Gm-Message-State: APjAAAWf2Qsuii2Z0YzyWorh4BL5iQ3Cpq8IWmf9jW80lrj5BxgJ4ZHj
	huwLyhRvHei7PM13pmwTrbR0WvhSg0IE8/UsQonl87njRGNkf/TYjMjybwo0AuVhcfFkPbwI7m0
	X7g5p+5qVCzYbj1ZeM67GfijmTFLls7hn5jz98pcryU5dIfthirdp/PnCTxqwtdXB2A==
X-Received: by 2002:a17:906:3948:: with SMTP id g8mr69865195eje.168.1560871339838;
        Tue, 18 Jun 2019 08:22:19 -0700 (PDT)
X-Received: by 2002:a17:906:3948:: with SMTP id g8mr69865129eje.168.1560871338914;
        Tue, 18 Jun 2019 08:22:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560871338; cv=none;
        d=google.com; s=arc-20160816;
        b=w72JxrZnuTDcmI2ETpvwdBGHGFwPDoQSl1QL0HrIkvb8eN3GADy8hOAhqOdcZqNdda
         O0EFYpShWLMbwhbpuM8rj6Xsmvw5pHrzzaKn3Z+b4wXIoESO8076BiipEREUT7xeMcay
         zpE/qDCu6+DAGnqcx7gIyBUPDpmzThIC2SlcIMO71hEot7x8zGEMu3V+uE1oqn/8usAY
         yb+UDGdWMM6lBSHnMxEmLjfwY25Bb5T1/J7VEY/SgxnApGUJ37ZD9ybixNWG7hlAmtZS
         oWJM5MwLllOtMBTlP8nwSSdQUjS6vmJHciwJBMKNQnttPCAD5XolLpHatSOASz4Tb2PU
         FDXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:mail-followup-to
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=E/qk0N+cIbM6HKj1qhjne1NfpocVmMqaX5q+/tL+ueI=;
        b=ry4jXTQGE18q40lSdT7WzuiWqJa5Ea7Vx+GamkrJqsXHnXFnzQBR2UshB+aBEBHYmE
         3xDlgh9d/acVHKpwd5R1wibOsJH76u/ZPdpZY4GpSpt7MhurtTTejaCYAdi9nMT+cmJu
         ccxFmjVRp52yV+O2TWCiH6FHr8Y6NpRyJkZIBIursAcjWBI9L2CNRvu/jbyPuBgw4kny
         WpVXrfiBXRFmJ0qSN1eHCxIoBoj33gDUWByqqzPMPNFo3/p0hhtaDgjzUnz0PftTbcXw
         wkmD48cGXmtiRLkeR6pamrFwe0INfiIgz9TO16HAUyQOF/rJKhG5GrfDV+mwzGiiDHMV
         Baig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=S0baOBWq;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel@ffwll.ch) smtp.mailfrom=daniel@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i21sor12555068ede.18.2019.06.18.08.22.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 08:22:18 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=S0baOBWq;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel@ffwll.ch) smtp.mailfrom=daniel@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=sender:date:from:to:cc:subject:message-id:mail-followup-to
         :references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=E/qk0N+cIbM6HKj1qhjne1NfpocVmMqaX5q+/tL+ueI=;
        b=S0baOBWqecd8R9Fv9S0yBSLlPx0B4vYX0TvI7oaRAzSf4d2jvMU2DZNwb2RG3dYdoB
         4+rZlzI6OA2RQxSWsdDqUVmzxXcyYpc2/nLIKI8MXqYfLfBjl7BetsvlRKqBiD5NuAUg
         AXHEz2PEzrj8GeuDgxkf0L8t0EXnxlWwtpkRw=
X-Google-Smtp-Source: APXvYqwy35fNeHyWQSb1sdW5IH38w+mc35q9rAaNur5D3Zl1Sv5PQx84zYiDMSvgBUjPLKdZDrkeAA==
X-Received: by 2002:a50:8825:: with SMTP id b34mr48288557edb.22.1560871338412;
        Tue, 18 Jun 2019 08:22:18 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id 9sm1439769ejg.49.2019.06.18.08.22.16
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 18 Jun 2019 08:22:17 -0700 (PDT)
Date: Tue, 18 Jun 2019 17:22:15 +0200
From: Daniel Vetter <daniel@ffwll.ch>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Michal Hocko <mhocko@suse.com>,
	Daniel Vetter <daniel.vetter@intel.com>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Linux MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>
Subject: Re: [PATCH 1/4] mm: Check if mmu notifier callbacks are allowed to
 fail
Message-ID: <20190618152215.GG12905@phenom.ffwll.local>
Mail-Followup-To: Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Daniel Vetter <daniel.vetter@intel.com>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Linux MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>
References: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
 <20190521154411.GD3836@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190521154411.GD3836@redhat.com>
X-Operating-System: Linux phenom 4.19.0-5-amd64 
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 11:44:11AM -0400, Jerome Glisse wrote:
> On Mon, May 20, 2019 at 11:39:42PM +0200, Daniel Vetter wrote:
> > Just a bit of paranoia, since if we start pushing this deep into
> > callchains it's hard to spot all places where an mmu notifier
> > implementation might fail when it's not allowed to.
> > 
> > Inspired by some confusion we had discussing i915 mmu notifiers and
> > whether we could use the newly-introduced return value to handle some
> > corner cases. Until we realized that these are only for when a task
> > has been killed by the oom reaper.
> > 
> > An alternative approach would be to split the callback into two
> > versions, one with the int return value, and the other with void
> > return value like in older kernels. But that's a lot more churn for
> > fairly little gain I think.
> > 
> > Summary from the m-l discussion on why we want something at warning
> > level: This allows automated tooling in CI to catch bugs without
> > humans having to look at everything. If we just upgrade the existing
> > pr_info to a pr_warn, then we'll have false positives. And as-is, no
> > one will ever spot the problem since it's lost in the massive amounts
> > of overall dmesg noise.
> > 
> > v2: Drop the full WARN_ON backtrace in favour of just a pr_warn for
> > the problematic case (Michal Hocko).
> > 
> > v3: Rebase on top of Glisse's arg rework.
> > 
> > v4: More rebase on top of Glisse reworking everything.
> > 
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: "Christian König" <christian.koenig@amd.com>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> > Cc: "Jérôme Glisse" <jglisse@redhat.com>
> > Cc: linux-mm@kvack.org
> > Cc: Paolo Bonzini <pbonzini@redhat.com>
> > Reviewed-by: Christian König <christian.koenig@amd.com>
> > Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> 
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

-mm folks, is this (entire series of 4 patches) planned to land in the 5.3
merge window? Or do you want more reviews/testing/polish?

I think with all the hmm rework going on, a bit more validation and checks
in this tricky area would help.

Thanks, Daniel

> 
> > ---
> >  mm/mmu_notifier.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> > index ee36068077b6..c05e406a7cd7 100644
> > --- a/mm/mmu_notifier.c
> > +++ b/mm/mmu_notifier.c
> > @@ -181,6 +181,9 @@ int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
> >  				pr_info("%pS callback failed with %d in %sblockable context.\n",
> >  					mn->ops->invalidate_range_start, _ret,
> >  					!mmu_notifier_range_blockable(range) ? "non-" : "");
> > +				if (!mmu_notifier_range_blockable(range))
> > +					pr_warn("%pS callback failure not allowed\n",
> > +						mn->ops->invalidate_range_start);
> >  				ret = _ret;
> >  			}
> >  		}
> > -- 
> > 2.20.1
> > 
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/dri-devel

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

