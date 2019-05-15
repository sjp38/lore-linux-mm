Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABC5AC04AA7
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 06:26:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7713B2084F
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 06:26:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7713B2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 210596B0007; Wed, 15 May 2019 02:26:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C0386B0008; Wed, 15 May 2019 02:26:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 089506B000A; Wed, 15 May 2019 02:26:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF4726B0007
	for <linux-mm@kvack.org>; Wed, 15 May 2019 02:26:42 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v5so695141wrn.6
        for <linux-mm@kvack.org>; Tue, 14 May 2019 23:26:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=r4oR53z2LH/girWhdadET5NwW+9qTEXME3Zh2uwLVAY=;
        b=V1DzRP8bX7bxldOGd04wiQ+ykVx6fQS4uxKC8JqY+zfgRO17M+DoYoumpHTWtD/VZd
         MTFWSmkzzQi/X3ixsj5p3wCoy1UnJzR/THCtD04o0RccnUB4Mv5qfYtJLWa9IZCuaEL4
         zwJ4+eYFSNUdOew/zVpFl9aV5XmwDuHXqLIYYdmMG58HR8NFNiWrddBKmg1nJZdNgacK
         c+0R5Om01rtHMfSjaz98CKB7XiLyvEy74aP995arsc2VVbxo8SS/65R8qDHWnp1A7Wzk
         a41nyy0tNYPLbdTeo31WaKkGtf6Z9fGC6xGdJ2a5FcJ/R299Ms9CcKyyg44PhxVzVSgQ
         BPGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVubn5jRgziLCahYRpYfTzoqp4/uMlBHAnWct95sGq3zwEZXUXj
	XRcDyneIU+ZSYQSBL6hIUr+AbpGvJk0hgMDaV7HYdM3q2D4CVljWEkg7HnJu4aXCOg8bEIq8AYl
	B9XFhqN1d4XlkVOaaWYkyVJsYfXG1uEwS7eNJUW6awS2/aIbIAVgAjCA1wizG/PpU6w==
X-Received: by 2002:a5d:6750:: with SMTP id l16mr17082732wrw.274.1557901602321;
        Tue, 14 May 2019 23:26:42 -0700 (PDT)
X-Received: by 2002:a5d:6750:: with SMTP id l16mr17082676wrw.274.1557901601321;
        Tue, 14 May 2019 23:26:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557901601; cv=none;
        d=google.com; s=arc-20160816;
        b=R4uBZg1tG4Mdvxn9KpkWqjrH9A+nrpSDAjKaOK+cshxqfbPC4EKDCQUqmrLmRacNYQ
         6ulxaj/MO2uv7oUgIicOKjvw56U/xfAm47L9aySC8HgAffl4fxeX/EI1ZkZdTQVm2HdA
         EJ3F1ewT1sGOWdOv1DMGeEU3I1/3jnPv7YUj2hHCVB1FXjKSKb8vKEst+6gUFSq6FhxR
         PoE0yBvKCB+tzynXSk1yvlPxjbKwKS1X5MNOBJKmHurDnsyJvrVMalkd50iPH8o6ilFD
         n3wYLQZOXQiCxPC8t4LGiexkhFrLTrreteTN+TeLAQbcZiD25Hgv3+WCIKgypHAwsdV0
         rutg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=r4oR53z2LH/girWhdadET5NwW+9qTEXME3Zh2uwLVAY=;
        b=rPNqJ+R8Rxm9S642e89puTLF2G9v0mMCmshVFpf9c5ltigDJmM4Zz+lu55ats3QuSK
         9ZNHigHyS5B4wsKMldhuaRBZuvLI79J/08UHxY3RRmc5lN16r29khzo08KU2tPsbp1ki
         wKAuihBaZEhMsPZ+4c4B2gNcSpXKDPf0C75WWlvQ382v1gJO2a7vnMtNwyI3NrTV/nS1
         +F/ftU2IL705zbODd1gORk7nRiT6OvAafuYpah01WMxIoV+gRKVpwsSyqLlSaPmbhrng
         B1D5qqCt5tRgoF28RVxKSdHieDdEfmjV4Rn2d5FCQIHO6dtM7qLa5+gyYUd4XFsGjFtH
         Mr4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v16sor767324wrw.2.2019.05.14.23.26.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 23:26:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwzRUd6h96LZgyFbTY+qpvrY3nI1N7OivjjSgq9A995vDhb95FwUCzP1jKfNcPST/ps3r/5IA==
X-Received: by 2002:a5d:6750:: with SMTP id l16mr17082656wrw.274.1557901600948;
        Tue, 14 May 2019 23:26:40 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id t7sm981391wrq.76.2019.05.14.23.26.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 23:26:40 -0700 (PDT)
Date: Wed, 15 May 2019 08:26:39 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH RFC v2 4/4] mm/ksm: add force merging/unmerging
 documentation
Message-ID: <20190515062639.qpqdkbrmujhnxfg7@butterfly.localdomain>
References: <20190514131654.25463-1-oleksandr@redhat.com>
 <20190514131654.25463-5-oleksandr@redhat.com>
 <CAGqmi77gESF0h8ZduHm8TTPKRqQLGFdCP15TAW5skDwZnL85YA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAGqmi77gESF0h8ZduHm8TTPKRqQLGFdCP15TAW5skDwZnL85YA@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

On Wed, May 15, 2019 at 03:53:55AM +0300, Timofey Titovets wrote:
> LGTM for whole series
> 
> Reviewed-by: Timofey Titovets <nefelim4ag@gmail.com>
> 
> вт, 14 мая 2019 г. в 16:17, Oleksandr Natalenko <oleksandr@redhat.com>:
> >
> > Document respective sysfs knob.
> >
> > Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
> > ---
> >  Documentation/admin-guide/mm/ksm.rst | 11 +++++++++++
> >  1 file changed, 11 insertions(+)
> >
> > diff --git a/Documentation/admin-guide/mm/ksm.rst b/Documentation/admin-guide/mm/ksm.rst
> > index 9303786632d1..4302b92910ec 100644
> > --- a/Documentation/admin-guide/mm/ksm.rst
> > +++ b/Documentation/admin-guide/mm/ksm.rst
> > @@ -78,6 +78,17 @@ KSM daemon sysfs interface
> >  The KSM daemon is controlled by sysfs files in ``/sys/kernel/mm/ksm/``,
> >  readable by all but writable only by root:
> >
> > +force_madvise
> > +        write-only control to force merging/unmerging for specific
> > +        task.
> > +
> > +        To mark the VMAs as mergeable, use:
> > +        ``echo PID > /sys/kernel/mm/ksm/force_madvise``
> > +
> > +        To unmerge all the VMAs, use:
> > +        ``echo -PID > /sys/kernel/mm/ksm/force_madvise``
> > +        (note the prepending "minus")
> > +
> In patch 3/4 you have special case with PID 0,
> may be that also must be documented here?

Thanks for the review. Yes, this is a valid point, I'll document it too.

> 
> >  pages_to_scan
> >          how many pages to scan before ksmd goes to sleep
> >          e.g. ``echo 100 > /sys/kernel/mm/ksm/pages_to_scan``.
> > --
> > 2.21.0
> >
> 
> 
> --
> Have a nice day,
> Timofey.

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

