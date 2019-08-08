Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A26E3C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 20:07:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C2B62173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 20:07:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C2B62173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD4FC6B0003; Thu,  8 Aug 2019 16:07:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D84ED6B0006; Thu,  8 Aug 2019 16:07:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4E106B0007; Thu,  8 Aug 2019 16:07:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 777D26B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 16:07:18 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so58890738edv.16
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 13:07:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=I8XsaFXf8iQlq8E+z7qOR+Ik+xepl7WhVzVrX1wGvAk=;
        b=n+6Qywa9jqFkYzy2VtXDTKEeXI6eVAFiUzEFFPB6czodY6BJVlMxKJZjredh9y9XMB
         hD6ywYKg9MQlF7EKBlDF1+k+zXIzwDxWjDNA7MBjnkk/SbXMd9ncgurCjhBo7lc7GDAO
         Kvg4TBSR3Z3Y+yZOYhW3qee0bYkgEpzvhNwiZ515NZi7RzRAV8IIqxyV2nnQZhTlPQij
         V8CQGxFZd4kC095aCUsLmsQIKfTgn3V4E2EpdUF78/piHdpNDGUOUnoyBGzYEua0eucE
         68GAreWSAwsuiZSki5GcmwLHMeJcLkWSE2aVMr35+llMF9/ya8d1zy5T0JMjRo7VhewI
         ax2g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUEZ7dsv86rzO8/CNV06XTNnHt+PTWyNkx85Ou0O+VxivAuQc5L
	YfT8SVsapulu1wSf21jWvZVqdL1XovePX3pPjx934IoDSsVfWmi9NOIR3Rid0CdMN1Nbm6Gu10e
	Km+hd5bcA/zjEMVVdsHyecG/95E9dj+wZC/KBl6u82ZwGPf8twoGDaJH9VTCA8pA=
X-Received: by 2002:a50:9799:: with SMTP id e25mr17581491edb.79.1565294838066;
        Thu, 08 Aug 2019 13:07:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJ2LdJtgrGBV689+vVFhhejTMYI1j9PFhmphltV0B7y8c1zSwRnSNiYHEKy7euVglfFfwA
X-Received: by 2002:a50:9799:: with SMTP id e25mr17581438edb.79.1565294837291;
        Thu, 08 Aug 2019 13:07:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565294837; cv=none;
        d=google.com; s=arc-20160816;
        b=Xvdz458rWHc592sLHNG7XKkRPTxbej9uDHEZESz8xAlePihNI1B0d15hRyoB5+6tVR
         QHR+hXDo5IAxux9EL21ajJF8gqYKi8d20t6pcg7vkAvNOwEESNyRZv0uWcUNfBx43gbk
         pdF1e5BsFIaPWCazpzyFYr/24r/GOREa03wz66D8ql0gLN0AbN0ugLi4UGkyqebrqSFG
         KxBjqCSOSoZiyzm2Hq0wyBZ2H6rs/Z0r7IFq3qO+n5o7Ov9pdINfOtCfnukl0ferwIoE
         ZLqlGCOgbYe17sMS/eJJ3V1jI5HZqnSWsq6Nz/QXj2RVHWvgntG6YJVlJf0oAYgGgVZ5
         Y8Cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=I8XsaFXf8iQlq8E+z7qOR+Ik+xepl7WhVzVrX1wGvAk=;
        b=XS082YVSX0wjiJvoKAiNIHOOqhtHXBdDHn65Wz6NIf8mTGQJTQ8F1V6q7xWJR8rTzt
         f93gWj8Dt5LjtoVFE1rUNtYHzr6FsGjPaTt3+8UoXJmW+xCddiEz5JkJoHdQKMIRicyz
         iOaw47lYrroE0FgY6MF5VSHxXaErsxVzqnsoNMUquWL06OVAqLY9uY2tLddgJFa2ZmD0
         oT3jGHxlq1dUDZoRlbUUwQPEP2R+RlZ/n2AEc6agIcOuCubkav2Ft6xEaRxSbM1Ez+eT
         +ewQeSY+tRy7QRiLHWFwMNtoH7dCl0VNWP65IlEsVyu4Vmt+3brKlBpn2ybqOrI/NxK6
         qShw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p6si11071114ejg.75.2019.08.08.13.07.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 13:07:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 83B03AD2A;
	Thu,  8 Aug 2019 20:07:16 +0000 (UTC)
Date: Thu, 8 Aug 2019 22:07:15 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Edward Chron <echron@arista.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Ivan Delalande <colona@arista.com>
Subject: Re: [PATCH] mm/oom: Add killed process selection information
Message-ID: <20190808200715.GI18351@dhcp22.suse.cz>
References: <20190808183247.28206-1-echron@arista.com>
 <20190808185119.GF18351@dhcp22.suse.cz>
 <CAM3twVT0_f++p1jkvGuyMYtaYtzgEiaUtb8aYNCmNScirE4=og@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAM3twVT0_f++p1jkvGuyMYtaYtzgEiaUtb8aYNCmNScirE4=og@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[please do not top-post]

On Thu 08-08-19 12:21:30, Edward Chron wrote:
> It is helpful to the admin that looks at the kill message and records this
> information. OOMs can come in bunches.
> Knowing how much resource the oom selected process was using at the time of
> the OOM event is very useful, these fields document key process and system
> memory/swap values and can be quite helpful.

I do agree and we already print that information. rss with a break down
to anonymous, file backed and shmem, is usually a large part of the oom
victims foot print. It is not a complete information because there might
be a lot of memory hidden by other resource (open files etc.). We do not
print that information because it is not considered in the oom
selection. It is also not guaranteed to be freed upon the task exit.
 
> Also can't you disable printing the oom eligible task list? For systems
> with very large numbers of oom eligible processes that would seem to be
> very desirable.

Yes that is indeed the case. But how does the oom_score and
oom_score_adj alone without comparing it to other eligible tasks help in
isolation?

[...]

> I'm not sure that change would be supported upstream but again in our
> experience we've found it helpful, since you asked.

Could you be more specific about how that information is useful except
for recording it? I am all for giving an useful information in the OOM
report but I would like to hear a sound justification for each
additional piece of information.

E.g. this helped us to understand why the task has been selected - this
is usually dump_tasks portion of the report because it gives a picture
of what the OOM killer sees when choosing who to kill.

Then we have the summary to give us an estimation on how much
memory will get freed when the victim dies - rss is a very rough
estimation. But is a portion of the overal memory or oom_score{_adj}
important to print as well? Those are relative values. Say you get
memory-usage:10%, oom_score:42 and oom_score_adj:0. What are you going
to tell from that information?
-- 
Michal Hocko
SUSE Labs

