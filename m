Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50AB3C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 08:49:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D78A2075E
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 08:49:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D78A2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF4066B000A; Wed, 27 Mar 2019 04:49:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7E0B6B000C; Wed, 27 Mar 2019 04:49:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9473D6B000D; Wed, 27 Mar 2019 04:49:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 409B86B000A
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 04:49:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c40so5099299eda.10
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 01:49:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yfgfTfkN07TW4pIkt5/GWXsdlzuhp3dTp6SgLlk9ssw=;
        b=oDrFET1U8+ezWKvGy93s/x9FdXybut3NyBBBkRIa9j6NCi1wwp9dLZgRWF7JEeDH5M
         A5CGQArj51p12hcdxxY22IkGSDRbiSSddwEPPA3L65N1OqCZj0TSqZKbPVy9o2RVGyUT
         L+tB8crAP805nB/E8uInl1yFNq6ce9Xaqa4Km0NLs2X84aOR+8VrWQTHpuRsiQEJDrEA
         bq4KvZZ3fXU+/zS4jcXDe5w1tV5R9/X+24HvX9+bh1s24jwuMUz9PUjjBeWfZ+v+O1z3
         yNHqGNT3O/KQZMcVoKNO2SPr51PcGZDdT9DGQ+QGYHe5sr8zrGXPZJwSw27h3asX1t9j
         0Nrg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVcvAKQGamK9pyXRRdamBGbNOZUpSF2NlVKaBaJrmiDhXGc6Upg
	jWCNLB7Nk+uPrU6OJX4CkgYvpr8TxiclvQgWx33qAJr8JgylKI6N9m8ZXYn5sjO9kpVXNL8RDSm
	lPK24+GX660H079Ww5LyAfBlolIhmY5IMLYQ0rZNVsny1Cj98ERfsjXWwo6yJStk=
X-Received: by 2002:a17:906:1584:: with SMTP id k4mr16514020ejd.226.1553676554791;
        Wed, 27 Mar 2019 01:49:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3xeUj2QzNiegDAl0EvBhcK8EagA5UgE+lUHL4jWsIR5Por4fLm1+ziG6why7pkkQ4Euv3
X-Received: by 2002:a17:906:1584:: with SMTP id k4mr16513978ejd.226.1553676553686;
        Wed, 27 Mar 2019 01:49:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553676553; cv=none;
        d=google.com; s=arc-20160816;
        b=lA0bnbr+b/wIqACpVT6i9w1lQK4m+fwe82fle8C5D37S3DMktF+l0wexX/K9Y5gFSq
         DDUzsi6hUU9OBZb3WWGiVemnLI1XB7IZYXEBYs/5p7xggq9iioSAfiyZiPMfYcXEcmnB
         hwhZB3cO3zKxnwZFqFhtg6I/7SHfmPySfrQ1zg96UCqBHbXv5VCONudqtHNrBkVs0q8B
         zWzAlFeT8O+YpLW0j4bi8Xjw5Qo7Nt0sQxSxdkoUhMkP5z1DZ+Zxf/vbInQmUz41FNyG
         BEOQroQzaqeQfNSbyfaYemrfD79j54Buds0PhbQ6GsyW95bq6Nv85jju2jEmlfREQzQm
         Jqzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yfgfTfkN07TW4pIkt5/GWXsdlzuhp3dTp6SgLlk9ssw=;
        b=uju9sNhkhUgl04u8+nOltJgbX9Ja9DjdiDJYM5oc7KjyYQUkuCVuJ1wSdqUflFcw8t
         T155Wos2p3b2BNKIyN3IrUMsc9U+Ie/WtB+PdeWs2Zu79o7MlSCHh21ndK7Vkrm6OWHo
         LUmoKlPVDoK6UkDbGDhhvQyqGGca+vDFmNzUGGp5Tsiy+dgpnZxb516gX4NNGUFzYx32
         EzX2rz+M/Mn6BkJpdoHtXuUpgLlxxszeJbohP0OYbhxyTgvVbSwDnObC6ZqPdQqhzHrW
         Cy63cbWOZXbHgjRT7y4dxxUoXazCZikFZCCHQhUM2jfjRVOGgdw2jmNLpegK7sy0oLrm
         lHXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z46si1290535edc.278.2019.03.27.01.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 01:49:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E5444AC6B;
	Wed, 27 Mar 2019 08:49:12 +0000 (UTC)
Date: Wed, 27 Mar 2019 09:49:12 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	zhong jiang <zhongjiang@huawei.com>,
	syzkaller-bugs@googlegroups.com,
	syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Peter Xu <peterx@redhat.com>, Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH 1/2] userfaultfd: use RCU to free the task struct when
 fork fails
Message-ID: <20190327084912.GC11927@dhcp22.suse.cz>
References: <20190325225636.11635-1-aarcange@redhat.com>
 <20190325225636.11635-2-aarcange@redhat.com>
 <20190326085643.GG28406@dhcp22.suse.cz>
 <20190327001616.GB15679@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190327001616.GB15679@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-03-19 20:16:16, Andrea Arcangeli wrote:
> On Tue, Mar 26, 2019 at 09:56:43AM +0100, Michal Hocko wrote:
> > On Mon 25-03-19 18:56:35, Andrea Arcangeli wrote:
> > > MEMCG depends on the task structure not to be freed under
> > > rcu_read_lock() in get_mem_cgroup_from_mm() after it dereferences
> > > mm->owner.
> > 
> > Please state the actual problem. Your cover letter mentiones a race
> > condition. Please make it explicit in the changelog.
> 
> The actual problem is the task structure is freed while
> get_mem_cgroup_from_mm() holds rcu_read_lock() and dereferences
> mm->owner.
> 
> I thought the breakage of RCU is pretty clear, but we could add a
> description of the race like I did in the original thread:
> 
> https://lkml.kernel.org/r/000000000000601367057a095de4@google.com
> https://lkml.kernel.org/r/20190316194222.GA29767@redhat.com

Yes please. That really belongs to the changelog. You do not expect
people chasing long email threads or code to figure that out, right?

> > > An alternate possible fix would be to defer the delivery of the
> > > userfaultfd contexts to the monitor until after fork() is guaranteed
> > > to succeed. Such a change would require more changes because it would
> > > create a strict ordering dependency where the uffd methods would need
> > > to be called beyond the last potentially failing branch in order to be
> > > safe.
> > 
> > How much more changes are we talking about? Because ...
> 
> I haven't implemented but I can theorize. It should require a new
> hooking point and information being accumulated in RAM and passed from
> the current hooking point to the new hooking point and to hold off the
> delivery of such information to the uffd monitor (the fd reader),
> until the new hooking point is invoked. The new hooking point would
> need to be invoked after fork cannot fail anymore.
> 
> We already accumulate some information in RAM there, but the first
> delivery happens at a point where fork can still fail.

I am sorry but this is not really clear to me. What is the problem to
postpone hooking point to later and how much more data we are talking
about here?

> > > This solution as opposed only adds the dependency to common code
> > > to set mm->owner to NULL and to free the task struct that was pointed
> > > by mm->owner with RCU, if fork ends up failing. The userfaultfd
> > > methods can still be called anywhere during the fork runtime and the
> > > monitor will keep discarding orphaned "mm" coming from failed forks in
> > > userland.
> > 
> > ... this is adding a subtle hack that might break in the future because
> > copy_process error paths are far from trivial and quite error prone
> > IMHO. I am not opposed to the patch in principle but I would really like
> > to see what kind of solutions we are comparing here.
> 
> The rule of clearing mm->owner and then freeing the mm->owner memory
> with call_rcu is already followed everywhere else. See for example
> mm_update_next_owner() that sets mm->owner to NULL and only then
> invokes put_task_struct which frees the memory pointed by the old
> value of mm->owner using RCU.
>
> The "subtle hack" already happens at every exit when MEMCG=y. All the
> patch does is to extend the "subtle hack" to the fork failure path too
> which it didn't follow the rule and it didn't clear mm->owner and it
> just freed the task struct without waiting for a RCU grace period. In
> fact like pointed out by Kirill Tkhai we could reuse
> delayed_put_task_struct method that is already used by exit, except it
> does more than freeing the task structure and it relies on refcounters
> to be initialized so I thought the free_task -> call_rcu( free_task)
> conversion was simpler and more obviously safe. Sharing the other
> method only looked a complication that requires syncing up the
> refcounts.
> 
> I think the only conceptual simplification possible would be again to
> add a new hooking point and more buildup of information until fork
> cannot fail, but in implementation terms I doubt the fix will become
> smaller or simpler that way.

Well, in general I prefer the code to be memcg neutral as much as
possible. We might have this subtle dependency with memcg now but this
is not specific to memcg in general. Therefore, if there is a way to
make a userfault specific fix then I would prefer it. If that is not
feasible then fair enough.

JFYI, getting rid of mm->owner is a long term plan. This is just too
ugly to live. Easier said than done, unfortunately.

> > > This race condition couldn't trigger if CONFIG_MEMCG was set =n at
> > > build time.
> > 
> > All the CONFIG_MEMCG is just ugly as hell. Can we reduce that please?
> > E.g. use if (IS_ENABLED(CONFIG_MEMCG)) where appropriate?
> 
> There's just one place where I could use that instead of #ifdef.

OK, I can see it now. Is there any strong reason to make the delayed
freeing conditional that would spare at least part of the ugliness.

> > > +static __always_inline void mm_clear_owner(struct mm_struct *mm,
> > > +					   struct task_struct *p)
> > > +{
> > > +#ifdef CONFIG_MEMCG
> > > +	if (mm->owner == p)
> > > +		WRITE_ONCE(mm->owner, NULL);
> > > +#endif
> > 
> > How can we ever hit this warning and what does that mean?
> 
> Which warning?

A brain fart, I would have sworn that I've seen WARN_ON_ONCE. Sorry
about the confusion.

-- 
Michal Hocko
SUSE Labs

