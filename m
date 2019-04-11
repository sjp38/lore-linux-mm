Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B906AC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 10:51:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FCC3217D4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 10:51:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FCC3217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C0D96B0273; Thu, 11 Apr 2019 06:51:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 170166B0274; Thu, 11 Apr 2019 06:51:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 061266B0275; Thu, 11 Apr 2019 06:51:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A79466B0273
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 06:51:15 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t14so2889398edw.15
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 03:51:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=fsF0DTHRJ2Lob7a1MaX8Z5BHLr7TecIc5EZZhX5aYZM=;
        b=LymEFdqhRkZiHpvBQfjJEIc6d4HN9OoYQqmi5egalkEHyMo++RNUCaciTj7VmWVixH
         TH5o98492zPeFpm8bhsJsvdRexLIeS7pGxQjjmJw5mszCPjGM827m1RmzCVhGy47FXhn
         +RtqKUuPv2L2tbZvtuCHupAy2zpfEvLm11OMhzCti9rP5mvmail9YqV8LkPpaU/KZO4U
         S7pluYMmrX8cfTWALOonEPdK4OpHxzKlzbh1vvScOSE+NlBBYn3IouN3JwwFN67kkb9t
         aadaie+PQWQrNEP7fwgayJLmRj5OKoNewffhNWhBKLaZozbfOXvCSe6gf3DgQtslIA/5
         RbBw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWQACSvMbJQO1jGLuLwCtjCDU+9w585kky4csBAALSItFvf+Bjd
	GZADvdNv57feKUseFp1RRy12/On6iEOdQD+4UG3nASfepTLJl7DLH702BYrjQTwHZgOQ8PQznGu
	mWYCDf0TObA5PVyEmWX1mUJR4VHyt7DJe1ooPq9v4sPoszjtP5soYqz118BcjKEU=
X-Received: by 2002:a17:906:6152:: with SMTP id p18mr26874264ejl.245.1554979875197;
        Thu, 11 Apr 2019 03:51:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwO1euib5QA/2grUUumLRtUfNl/lUOfAo5jPkaDhyiBMD79y1crxVHqUf97j9teEf7o0yEW
X-Received: by 2002:a17:906:6152:: with SMTP id p18mr26874226ejl.245.1554979874242;
        Thu, 11 Apr 2019 03:51:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554979874; cv=none;
        d=google.com; s=arc-20160816;
        b=NibXgbtfn1BqDa5C1rgJR/tO72FA3KsYJb7qa5+LOWUdEwTRz8z9nS7H4fdX7QnXqN
         oAIjbsiTVIR+KO0b2+9CK0JuE2H3qTtfQrUT4sim4rgA9uPH/0lpUoSJ2dOb0q4sBvip
         qYPnB64vL1FgGdRW22r+mqOCKZ1POxY1VQry1YJCazhgIVi9+M3ZeXdyTj0K0qPRLwmY
         3rseWKQjBM/SULStVBargz8ZqFoaQoGIyiWF6A8LH0y++sktJqPBa9RBh7l9oeZUf/UW
         GEM1nkjprzSUk9wDeSm8gZjTAYFf8mnXOzLjxEM2OrWO45i+b/DLRlcPsQuEG6C/foQU
         BSLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=fsF0DTHRJ2Lob7a1MaX8Z5BHLr7TecIc5EZZhX5aYZM=;
        b=BVzhbYl9xxXTIdIkBHT7WmD4BZDaHFPRq9tNw0PbgoiC57qh+jbpbSmZt2vbDmt6vJ
         2gBS/bgFCyXA0JST/t5Jhs5BcVDqC/mr2xtnSvoPy02fCyJwRzItqwldLrz28W3Y7hFc
         bXgH8zRXYqZRtGpAGZPtwEzYEw72b3ZG5Edh6KSbtLsclWhcb8TcquYi0j1qVknBRzrA
         9W8hvjU0dPWdY2l5ciZSNx4PunbO0lsGgIPEUISG8J1XtsJv6ykEHu/yg4TtW33keq/J
         rc1JRCnpvid/4XA7L6o9WeAFPIE2VLENMOhWRd1qJDFNYilmoBT5FKeJjxW80DsBIT+2
         cifg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f17si791543edy.54.2019.04.11.03.51.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 03:51:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 58915ABAC;
	Thu, 11 Apr 2019 10:51:13 +0000 (UTC)
Date: Thu, 11 Apr 2019 12:51:11 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, willy@infradead.org,
	yuzhoujian@didichuxing.com, jrdr.linux@gmail.com, guro@fb.com,
	hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp,
	ebiederm@xmission.com, shakeelb@google.com, christian@brauner.io,
	minchan@kernel.org, timmurray@google.com, dancol@google.com,
	joel@joelfernandes.org, jannh@google.com, linux-mm@kvack.org,
	lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [RFC 0/2] opportunistic memory reclaim of a killed process
Message-ID: <20190411105111.GR10383@dhcp22.suse.cz>
References: <20190411014353.113252-1-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190411014353.113252-1-surenb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 10-04-19 18:43:51, Suren Baghdasaryan wrote:
[...]
> Proposed solution uses existing oom-reaper thread to increase memory
> reclaim rate of a killed process and to make this rate more deterministic.
> By no means the proposed solution is considered the best and was chosen
> because it was simple to implement and allowed for test data collection.
> The downside of this solution is that it requires additional “expedite”
> hint for something which has to be fast in all cases. Would be great to
> find a way that does not require additional hints.

I have to say I do not like this much. It is abusing an implementation
detail of the OOM implementation and makes it an official API. Also
there are some non trivial assumptions to be fullfilled to use the
current oom_reaper. First of all all the process groups that share the
address space have to be killed. How do you want to guarantee/implement
that with a simply kill to a thread/process group?

> Other possible approaches include:
> - Implementing a dedicated syscall to perform opportunistic reclaim in the
> context of the process waiting for the victim’s death. A natural boost
> bonus occurs if the waiting process has high or RT priority and is not
> limited by cpuset cgroup in its CPU choices.
> - Implement a mechanism that would perform opportunistic reclaim if it’s
> possible unconditionally (similar to checks in task_will_free_mem()).
> - Implement opportunistic reclaim that uses shrinker interface, PSI or
> other memory pressure indications as a hint to engage.

I would question whether we really need this at all? Relying on the exit
speed sounds like a fundamental design problem of anything that relies
on it. Sure task exit might be slow, but async mm tear down is just a
mere optimization this is not guaranteed to really help in speading
things up. OOM killer uses it as a guarantee for a forward progress in a
finite time rather than as soon as possible.

-- 
Michal Hocko
SUSE Labs

