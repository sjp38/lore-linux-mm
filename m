Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C924C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 13:49:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4860F214AE
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 13:49:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4860F214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEBEA6B0005; Mon,  1 Jul 2019 09:49:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC2DB8E0003; Mon,  1 Jul 2019 09:49:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D9B98E0002; Mon,  1 Jul 2019 09:49:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f78.google.com (mail-ed1-f78.google.com [209.85.208.78])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9FE6B0005
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 09:49:02 -0400 (EDT)
Received: by mail-ed1-f78.google.com with SMTP id s7so16812415edb.19
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 06:49:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YcQ1SYYcdvmpHMekoMOmxiVePBrt0yuLrrgWh/ofntk=;
        b=td6usoJBAYbLPlESdeVa7yTCkWIt1mi44bZy39NKLgBoIbtqjLFbVPCp6gezQhIBtk
         KBo1VgZdiWpOWkEqCf9iyQ8Q/QFtbMxHEMGgDqpeOy3zpTIdoESRKvZW3PS8o8KrGjpJ
         iFei0aY6J4MohgIzX9w0wnHPT1S+1hI7f8Ee0nSoUSIh0mF2Y/SKVXM5DsbiFxLC1JL3
         KOC/jCcLpgsHxX4EER9NOHeA5mh0dWOtz1ME1twpefXnJN24BITlE0W9UnXoQeLSCa60
         V0IwS8TFE9qf2Ud+5BlrlK6DQXUP5EzaNUNKHCJMpOucBGJqQgbJ7mhldJ6TNNUqedUj
         27PA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUD8Y56w6b97C9QCtWJ11gGYxdfkc2Z2WHBb/qnknoyZyFVFwFd
	4zwdzOEgSv7WawBCtihqFvRFtn8nJvMoeh/1d2M6jg/ucbBvmeAHL6iKMEYVexWoy3LuEY3HxLI
	I0jF1/3DYJ0UTuhN/y6qpnpBMPGmprhGwnrkn5jjy2kBdg2jqRK7Y8ZpJ4pYgcNk=
X-Received: by 2002:aa7:d0cc:: with SMTP id u12mr29140713edo.212.1561988941773;
        Mon, 01 Jul 2019 06:49:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybj5zYFpy8+sM2QQnPoqHcSjmYLQCvnP2o5vabfzbs6+2c9EzI+gX2ZaqM/NHWgqiQrVCb
X-Received: by 2002:aa7:d0cc:: with SMTP id u12mr29140662edo.212.1561988941132;
        Mon, 01 Jul 2019 06:49:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561988941; cv=none;
        d=google.com; s=arc-20160816;
        b=JaNbliyJgukaqXzkjMA/ca/8ukJBpSImoFnnOfYPN6Ughs5tSN+v84FQiL/Hjtn5EE
         piUg1i63z1/WJye30mEPR4fBtHrb2Y51r3sIrVEKtwmyc3sogHh6xu5aK7/Caw5QdoPf
         C6aODoGifm6mjSr8lSUmlS99uZkFCzpb9eTcFkvnVyM6+xyHQjXmSDSSE1Q4OQCrRn2M
         zkOytCeqU+TQNXKQllB+VP5ni2rJ3+4Zz2VWKcHb0YieOGU5CwWK7mEDCRiscnS/oAGw
         mn6w4xpKjKGyPWWLGGRjjHwcnXkwEIsYdB6RNnQn8VwPtKE7+XmBGmVpt0LeRfNObe/Q
         KDMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YcQ1SYYcdvmpHMekoMOmxiVePBrt0yuLrrgWh/ofntk=;
        b=cSK0U6vrW+bIviTOVCdXQVu3psn/bCwI2B6Lnz8rHPJ/8G6rL87I35V3OmqtFvrWaP
         XxiHD3FE/bbtr/7fztkxbqv5ztHqmeLQlVNk60rmGLzKsBox8XRtNc+cg8ovjpZbXJ8W
         DoZoScV54tJ/mHymU1qR3MnvOLNJ3tmCfKvKXeo1JC0dVRk5vbaE1JVRtXkKCp7g0xfa
         e6z/RrGVDNdSRkT+P4TAOEd+bC0cM8d2XJBM7NT1JMCeoOy8eJ9EtSlbt8kts3eVF3GD
         FuxhK9WgyIZkJzSIiROG5Y9528mLiGq4mQ/xf6OV7BznCGfntpFcC00D6bPTJC+80NZl
         COXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x17si7650028ejv.386.2019.07.01.06.49.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 06:49:01 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4A2A4AF99;
	Mon,  1 Jul 2019 13:49:00 +0000 (UTC)
Date: Mon, 1 Jul 2019 15:48:59 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org
Subject: Re: [PATCH] mm: mempolicy: don't select exited threads as OOM victims
Message-ID: <20190701134859.GZ6376@dhcp22.suse.cz>
References: <1561807474-10317-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190701111708.GP6376@dhcp22.suse.cz>
 <15099126-5d0f-51eb-7134-46c5c2db3bf0@i-love.sakura.ne.jp>
 <20190701131736.GX6376@dhcp22.suse.cz>
 <ecc63818-701f-403e-4d15-08c3f8aea8fb@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ecc63818-701f-403e-4d15-08c3f8aea8fb@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 01-07-19 22:38:58, Tetsuo Handa wrote:
> On 2019/07/01 22:17, Michal Hocko wrote:
> > On Mon 01-07-19 22:04:22, Tetsuo Handa wrote:
> >> But I realized that this patch was too optimistic. We need to wait for mm-less
> >> threads until MMF_OOM_SKIP is set if the process was already an OOM victim.
> > 
> > If the process is an oom victim then _all_ threads are so as well
> > because that is the address space property. And we already do check that
> > before reaching oom_badness IIRC. So what is the actual problem you are
> > trying to solve here?
> 
> I'm talking about behavioral change after tsk became an OOM victim.
> 
> If tsk->signal->oom_mm != NULL, we have to wait for MMF_OOM_SKIP even if
> tsk->mm == NULL. Otherwise, the OOM killer selects next OOM victim as soon as
> oom_unkillable_task() returned true because has_intersects_mems_allowed() returned
> false because mempolicy_nodemask_intersects() returned false because all thread's
> mm became NULL (despite tsk->signal->oom_mm != NULL).

OK, I finally got your point. It was not clear that you are referring to
the code _after_ the patch you are proposing. You are indeed right that
this would have a side effect that an additional victim could be
selected even though the current process hasn't terminated yet. Sigh,
another example how the whole thing is subtle so I retract my Ack and
request a real life example of where this matters before we think about
a proper fix and make the code even more complex.

-- 
Michal Hocko
SUSE Labs

