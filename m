Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DD72C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 08:07:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0EFF222A1
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 08:07:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0EFF222A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72FB18E0002; Thu, 14 Feb 2019 03:07:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7083B8E0001; Thu, 14 Feb 2019 03:07:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F6958E0002; Thu, 14 Feb 2019 03:07:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0758E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 03:07:46 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b15so4190491pfi.6
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 00:07:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=MNU/ypIn3eUj4NZye31YTxLObfvyeRfA90UO94cmzLI=;
        b=A624+pw/UqMMW+snf5hY5udIEtDwy4cgt7c+iVuCioEx2Jg12xh70T0Pi36Ga+ykf6
         GUvW7TrG/pT63lQyoG8F/vZp13EqMOipijyfry1Rvir9YGNUMpEsq6mZir/0hMZNjmzs
         AznfM2xoxB7C3DmPxnCb34nXwNqcLZfseVZQnfjZn75qdYSM7MCdARZXI+0kgioV09Pw
         jpOmZT53av3O88QWfkArNobFDyShq5gIdOQm5n3EACheWBKaiz/ZRaHkhzeG6rgl5fQJ
         efkbf0OLJIWoj2Hi1o2iESjmB+hr0EWWPGipiCfm/85/sZGSHoBs43XjmJLAJcmwG31Q
         Va+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubPS3bWC1jt5YKBwldEIdIMi0wjz31FN8ZHsxqrBqjd8/dX6lyC
	cY6XHQwJMOS6eJMjp36X8egFwu7SjWaUO7zDxvLYo3Ej06T2Q8+ia71jhL1cJBEaNw+QF0W9OuK
	GxLjBFaZ3PtepXOomMIbPEcKLVmWCTUl+7GBml1VL15PaN+OSL+iXj3b5UJ1n9ekd3w==
X-Received: by 2002:a63:cf42:: with SMTP id b2mr2558846pgj.173.1550131665759;
        Thu, 14 Feb 2019 00:07:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IarXOWGiGzDAY7eoyU70yI44Khd54/cXwLmp/EBFCjbn4CSXkQzV/nPWAs3Xu/SpV3eIMxc
X-Received: by 2002:a63:cf42:: with SMTP id b2mr2558795pgj.173.1550131664767;
        Thu, 14 Feb 2019 00:07:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550131664; cv=none;
        d=google.com; s=arc-20160816;
        b=Ck5AxcV+OGWs19SBvrp8pcYL6clqqtvQuCpPQMupyg8Rr3rxbKErXp1j0U5prxLlw5
         cKuhNk+x3/P7RyMwIZPq9Rd6l59UsktbPiz+aFOk1aRPhgjIz4zouxUNKhcuKqTnlNrH
         wLaCMiJVAEXm6Do28WJoWQ9WZ4TjkVpMQrFdGrSvtGR5xDEl2sel/JWD4PgPgI3clJuu
         QOFRzBAEF5Q80UAVxg7IfZEoAyqC3ZbAxw0m3l49dUMZ6bLS1lGDLt+vLpb99WYcE1fz
         ZKfE8lPELdBHqnlQMVexTDLnxixdVPY9I3eTjT43MGcR5ySqoh6HpdsU5yyExy8FasGY
         gghA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=MNU/ypIn3eUj4NZye31YTxLObfvyeRfA90UO94cmzLI=;
        b=lTMeFtNOrH6n2T6kRZEcG84L9JtT9cPo1bDGH1B46Pu5oO9dof/ujVYMQsrwGrCs++
         07VZDX4wJfjoQ+dVNdW96/rIkOK+AFIa0OfujudgAtkdlhoUzxm5NO0uASVKy7YX/E0w
         fCjNw0/LaPSUB91Dr4yqnuje8cSzWfBnPe1tUSmg+VI5EnPuFdCtza7702WDvDoiZfhw
         ollWpztn/vfpUtuhqpOTDvQDyjPw8k4TSnIjpBPArhkoVmiu4JyYcnGojLVnnXzYteor
         9iwm2RvkHIczXsWgH3+cmExW6Anw+4h4AEzlLt9OVwNmS3iZM8lJi6Sou7jg+Et3aKMh
         yuHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id x29si1668926pgl.584.2019.02.14.00.07.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 00:07:44 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 00:07:44 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,367,1544515200"; 
   d="scan'208";a="146763938"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.151])
  by fmsmga001.fm.intel.com with ESMTP; 14 Feb 2019 00:07:40 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Hugh Dickins <hughd@google.com>,  "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,  Minchan Kim <minchan@kernel.org>,  Johannes Weiner <hannes@cmpxchg.org>,  Tim Chen <tim.c.chen@linux.intel.com>,  Mel Gorman <mgorman@techsingularity.net>,  Jérôme Glisse <jglisse@redhat.com>,  Michal Hocko <mhocko@suse.com>,  David Rientjes <rientjes@google.com>,  Rik van Riel <riel@redhat.com>,  Jan Kara <jack@suse.cz>,  Dave Jiang <dave.jiang@intel.com>,  Daniel Jordan <daniel.m.jordan@oracle.com>,  Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap operations
References: <20190211083846.18888-1-ying.huang@intel.com>
	<20190214023805.GA19090@redhat.com>
Date: Thu, 14 Feb 2019 16:07:37 +0800
In-Reply-To: <20190214023805.GA19090@redhat.com> (Andrea Arcangeli's message
	of "Wed, 13 Feb 2019 21:38:05 -0500")
Message-ID: <87k1i2oks6.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Andrea,

Andrea Arcangeli <aarcange@redhat.com> writes:

> Hello everyone,
>
> On Mon, Feb 11, 2019 at 04:38:46PM +0800, Huang, Ying wrote:
>> @@ -2386,7 +2463,17 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
>>  	frontswap_init(p->type, frontswap_map);
>>  	spin_lock(&swap_lock);
>>  	spin_lock(&p->lock);
>> -	 _enable_swap_info(p, prio, swap_map, cluster_info);
>> +	setup_swap_info(p, prio, swap_map, cluster_info);
>> +	spin_unlock(&p->lock);
>> +	spin_unlock(&swap_lock);
>> +	/*
>> +	 * Guarantee swap_map, cluster_info, etc. fields are used
>> +	 * between get/put_swap_device() only if SWP_VALID bit is set
>> +	 */
>> +	stop_machine(swap_onoff_stop, NULL, cpu_online_mask);
>
> Should cpu_online_mask be read while holding cpus_read_lock?
>
> 	cpus_read_lock();
> 	err = __stop_machine(swap_onoff_stop, NULL, cpu_online_mask);
> 	cpus_read_unlock();

Thanks for pointing this out.  Because swap_onoff_stop() is just dumb
function, something as below should be sufficient.

stop_machine(swap_onoff_stop, NULL, NULL);

> I missed what the exact motivation was for the switch from
> rcu_read_lock()/syncrhonize_rcu() to preempt_disable()/stop_machine().
>
> It looks like the above stop_machine all it does is to reach a
> quiescent point, when you've RCU that already can reach the quiescent
> point without an explicit stop_machine.
>
> The reason both implementations are basically looking the same is that
> stop_machine dummy call of swap_onoff_stop() { /* noop */ } will only
> reach a quiescent point faster than RCU, but it's otherwise
> functionally identical to RCU, but it's extremely more expensive. If
> it wasn't functionally identical stop_machine() couldn't be used as a
> drop in replacement of synchronize_sched() in the previous patch.
>
> I don't see the point of worrying about the synchronize_rcu latency in
> swapoff when RCU is basically identical and not more complex.
>
> So to be clear, I'm not against stop_machine() but with stop_machine()
> method invoked in all CPUs, you can actually do more than RCU and you
> can remove real locking not just reach a quiescent point.
>
> With stop_machine() the code would need reshuffling around so that the
> actual p->swap_map = NULL happens inside stop_machine, not outside
> like with RCU.
>
> With RCU all code stays concurrent at all times, simply the race is
> controlled, as opposed with stop_machine() you can make fully
> serialize and run like in UP temporarily (vs all preempt_disable()
> section at least).
>
> For example nr_swapfiles could in theory become a constant under
> preempt_disable() with stop_machine() without having to take a
> swap_lock.
>
> swap_onoff_stop can be implemented like this:
>
> enum {
> 	FIRST_STOP_MACHINE_INIT,
> 	FIRST_STOP_MACHINE_START,
> 	FIRST_STOP_MACHINE_END,
> };
> static int first_stop_machine;
> static int swap_onoff_stop(void *data)
> {
> 	struct swap_stop_machine *swsm = (struct swap_stop_machine *)data;
> 	int first;
>
> 	first = cmpxchg(&first_stop_machine, FIRST_STOP_MACHINE_INIT,
> 			FIRST_STOP_MACHINE_START);
> 	if (first == FIRST_STOP_MACHINE_INIT) {
> 		swsm->p->swap_map = NULL;
> 		/* add more stuff here until swap_lock goes away */
> 		smp_wmb();
> 		WRITE_ONCE(first_stop_machine, FIRST_STOP_MACHINE_END);
> 	} else {
> 		do {
> 			cpu_relax();
> 		} while (READ_ONCE(first_stop_machine) !=
> 			 FIRST_STOP_MACHINE_END);
> 		smp_rmb();
> 	}
>
> 	return 0;
> }
>
> stop_machine invoked with a method like above, will guarantee while we
> set p->swap_map to NULL (and while we do nr_swapfiles++) nothing else
> can run, no even interrupts, so some lock may just disappear. Only NMI
> and SMI could possibly run concurrently with the swsm->p->swap_map =
> NULL operation.
>
> If we've to keep swap_onoff_stop() a dummy function run on all CPUs
> just to reach a quiescent point, then I don't see why
> the synchronize_rcu() (or synchronize_sched or synchronize_kernel or
> whatever it is called right now, but still RCU) solution isn't
> preferable.

We only need to keep swap_onoff_stop() a dummy function as above.  So
from functionality point of view, RCU works for us perfectly too.  Paul
pointed out that before too.

Before, we choose to use stop_machine() to reduce the overhead of hot
path (page fault handler) as much as possible.  But now, I found
rcu_read_lock_sched() is just a wrapper of preempt_disable().  So maybe
we can switch to RCU version now.

Best Regards,
Huang, Ying

> Thanks,
> Andrea

