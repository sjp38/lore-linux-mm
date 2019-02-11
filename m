Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4702C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:07:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E166217D9
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:07:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E166217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 295A78E00EE; Mon, 11 Feb 2019 10:07:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 245FF8E00EB; Mon, 11 Feb 2019 10:07:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 134448E00EE; Mon, 11 Feb 2019 10:07:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id ACBA08E00EB
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:07:38 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v26so9672799eds.17
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:07:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BtCrG0jAOzGiDf2xK6kH3qfc48twA/PIur4OPW9KftE=;
        b=uFT1RsPiPGaaebeeGFIXC0ozWBX8JSjvoR945vUCIIcD/W/XjcdlxbCgXqEQIY+jE/
         HVNwhsTiMohDmFWP1v4qg0HTargEgz1225q6uMgYjb0lPPiLbg850QqNLDqwzUm4g4Vg
         Y1weLWFnJCGxp3y8Pi4p+Ovxzzcy7eOuqUCQvkrlhPz24g5s8bm8vW8e0SWSUuf5ySn+
         NDxs3PZhO3dxKTzjnTdkFFzXmA7ZtIGZEgo8ANbAFUIpxG53HElZBRsO1rzjGBPxgE4U
         knWZf8WOw6agjjeL/tszXXDDT5Od9WM8FSk//TEzTvH/v7jhEzpG85LgRdvfC6SlstwH
         eNmA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZ8J1AK5654RWrrGBHw+6LRWxYfQjVZwRZp8vP4fqZ6V2BRMT0L
	zNH0n9RaQiJaTVqN8xqWGg2hNqlKNt7fLm/Y59SH5yDq36PlppzUid0l4aBv6wHHIUVkkQd9NGA
	A2AnesNlfJhdOafOsaFarKuZiplhEEFhUD09js0zMLurwMpLlMfvX8RAzwTL4iS4=
X-Received: by 2002:a50:a086:: with SMTP id 6mr227634edo.88.1549897658216;
        Mon, 11 Feb 2019 07:07:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IazJ/GR+5qWLKZStjq7EC5hiOFO9ANPCO6eB9JZOcSBcM5f0VQdpeGB0p07kibMLZBeXtvG
X-Received: by 2002:a50:a086:: with SMTP id 6mr227558edo.88.1549897657139;
        Mon, 11 Feb 2019 07:07:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549897657; cv=none;
        d=google.com; s=arc-20160816;
        b=Q4qpqx2Ouw1ScPUhcyeuhUkpNAcZ/RrxW3lBzzdqsGQT5HJPvFDJs/efloS/dk/u9m
         Xg/pDMua7BGhW2UVj8qD9N/JiBuQl0gkExEMgiugU5KIe4w/bMpmCnijTqd8vaw2oniV
         yfk4an2FdE1yuugh1r6u1xd7A+KuImOqZNFgv7z9sJi6LbBt4iZRTb/5nm6upQF5/hUa
         YiZ5Wth/r3CDiTBo5cJ8+4nZVV4EEkyNvvyD62SpFDmm5l8EayrCSsD8NkrHwMn8u8ij
         4MRNP7PFiFeVYdMeusfeL3vvgVF73+mqt0pq68bOaWAIUEKQ1uoV+dpkjtot4XG94mbh
         O0Cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BtCrG0jAOzGiDf2xK6kH3qfc48twA/PIur4OPW9KftE=;
        b=QKBFT5hB/8+b+3RAVi46DQUFKZ5YnfDw1I71UzAKr2jHknFAr/7cAccrbr5CJsbS3T
         aDrD58fbHCWtqbI8myvmUnBqHExDZRbUV6K3/JvOlY2s5X5S+WG74vWkOMp1/t3BjDwh
         Vv1tJCn8w0LF3oCg7+HIbTRcyBfn0uTmTax+IZrKLRkFOwkq83UkRPnzsJqBn5qowtbO
         rqozih3q6w31dyzSxNijgVLjsna5fcJv62Y9DgAzZeVZkOnwVm5e+nw1n3e4f3DLuow5
         gIWZUOagaZGNKCHCYjK5ZTc+QurdwQmfpJtSBF62sq1ixvGHgoykYot7PEONzq840tQ6
         vwAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a25si4824504edn.280.2019.02.11.07.07.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 07:07:37 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E7426ACF8;
	Mon, 11 Feb 2019 15:07:35 +0000 (UTC)
Date: Mon, 11 Feb 2019 16:07:34 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>, linux-mm@kvack.org,
	Yong-Taek Lee <ytk.lee@samsung.com>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] mm, oom: Tolerate processes sharing mm with different
 view of oom_score_adj.
Message-ID: <20190211150734.GF15609@dhcp22.suse.cz>
References: <88e10029-f3d9-5bb5-be46-a3547c54de28@I-love.SAKURA.ne.jp>
 <20190116121915.GJ24149@dhcp22.suse.cz>
 <6118fa8a-7344-b4b2-36ce-d77d495fba69@i-love.sakura.ne.jp>
 <20190116134131.GP24149@dhcp22.suse.cz>
 <20190117155159.GA4087@dhcp22.suse.cz>
 <edad66e0-1947-eb42-f4db-7f826d3157d7@i-love.sakura.ne.jp>
 <20190131071130.GM18811@dhcp22.suse.cz>
 <5fd73d87-3e4b-f793-1976-b937955663e3@i-love.sakura.ne.jp>
 <20190201091433.GH11599@dhcp22.suse.cz>
 <643b94c2-d720-fa95-d6ee-4f0ea6e2686a@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <643b94c2-d720-fa95-d6ee-4f0ea6e2686a@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 02-02-19 20:06:07, Tetsuo Handa wrote:
> int main(int argc, char *argv[])
> {
> 	printf("PID=%d\n", getpid());
> 	if (vfork() == 0) {
> 		clone(thread1, malloc(8192) + 8192,
> 		      CLONE_VM | CLONE_FS | CLONE_FILES, NULL);
> 		sleep(1);
> 		_exit(0);
> 	}
> 	return 0;
> }

This program is not correct AFAIU:
   Standard description
       (From POSIX.1) The vfork() function has the same effect as
       fork(2), except that the behavior is undefined if the process
       created by vfork() either modifies any data other than a variable
       of type pid_t used to store the return value from vfork(), or
       returns from the function in which vfork() was called, or calls
       any other function before successfully calling _exit(2) or one of
       the exec(3) family of functions.
> 
>   PID=8802
>   [ 1138.425255] updating oom_score_adj for 8802 (a.out) from 0 to 1000 because it shares mm with 8804 (a.out). Report if this is unexpected.
> 
> Current loop to enforce same oom_score_adj is 99%+ ending in vain.
> And even your "eventually" will remove this loop.

But it keeps the semantic of the mm shared processes share the same
oomd_score_adj so that we do not have to add kludges to the OOM code to
handle with potential corner cases.

Really, this nagging is both unproductive and annoying. You are right
that the printk is overzealous and it can be dropped. The printk is
more than two years old and we haven't heard anybody to care. So the
first and the most obvious thing to do is to remove it. The patch is
trivial and if I was not buried in the backlog I would have posted it
already.  Regarding a potentially expensive for_each_process. This is
unfortunate but the thing we have to pay for in other paths as well
(e.g. exit path) so closing this only here just doesn't really help
much if you are concerned about security and potential stalls will
explode the machine scenarios.. So even though this sucks it is not
earth shattering. CLONE_VM withtout CLONE_SIGHAND simply sucks and
nobody should be using this threading model.

So, please calm down, try to be more productive and try to understand
what people try to tell you rather than shout around "i want my pony".
-- 
Michal Hocko
SUSE Labs

