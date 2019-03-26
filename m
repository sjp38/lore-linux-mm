Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA847C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:56:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C09320856
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:56:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C09320856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C88306B0005; Tue, 26 Mar 2019 04:56:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C37F16B0006; Tue, 26 Mar 2019 04:56:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4F5B6B0007; Tue, 26 Mar 2019 04:56:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69D026B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 04:56:47 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n24so4922467edd.21
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 01:56:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fsfWT0ngDuqLxZGzjvxnPlOGNaNiIFdiLSpcCpwbPtY=;
        b=nw0U/+Xv+lXaAU8HgI7I0dMgRjG8ODSbNyDu9B2ydI01ASFSd9kxRRE9SNNa1PCFFe
         BEWsyfl2ewAtPu1oNJqjufEYzFTrSIrGB5mdo4dMaHZACTFPA97LdlJB0U1r4sER7bBK
         sHpDFObik1OcOgSGoRfUKrL3K2U1ZiZXN/hd4G3n5Cii3pAEJNdmduGrCBOoC0DnPDjP
         J7IwOy4kwUCykpL2DnxkYFhTTY9f1WOPTjXnj2h2vA6byY4rlOZtV17CmhPzpKt3ZK13
         Yosgyb/Bs4jHNihkcoPbvfG2peP25JI+jgTTbW6qMVzE1opdyhHlOWZnkJ8eWxClkfjP
         oGrA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVdpCK0DEQJPqvPlOGzI7yHMcS6b13uLDiSdlYAZlgWKnKqky/f
	8mpzyZgxdkpGp8KB7iXCiLDPtQSFRK+AgWwaKREDvaJycOjRaQcrHLKAcm3i3LeVTDFHJ5q+Jxf
	fRrd7tm+JPZl1Nu0Ul1cwQ1IbUeXCR0sCaryus3nmMOWvXf8Rw8/NKN4yVkhcSkg=
X-Received: by 2002:a50:bdc4:: with SMTP id z4mr5336131edh.199.1553590606992;
        Tue, 26 Mar 2019 01:56:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBktE4Q5f/BlXTXDp08bKIy98ma8xClUywNOTwwa8edhpAZjzCNZCtcvcfJU6R2tQLIia3
X-Received: by 2002:a50:bdc4:: with SMTP id z4mr5336100edh.199.1553590606193;
        Tue, 26 Mar 2019 01:56:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553590606; cv=none;
        d=google.com; s=arc-20160816;
        b=tQUrvAhQ0cyF07FniPNGEM0s2cbhwt0yJzpysZN7Zp6Vws7VEvRrErpQ8aidjfaDl4
         nLNn0OGY0aL4FBRvVr1ZIZOqOiX25kjwPoAHBO93iFrxnOkJwGClfo+EGyRzLvMPRroR
         VphlIJGgB9MGh3Am50VZvlYhC+QnMe+V9mN6cczoCgliwz7fP/uNEwKSJIZxZb8dxyvd
         Z0x06Gen3Pf3e0vVDaZQdwuPP9YvP80szgqmwoLIpzX490LSigoxxOrdtkUtyy4ejInZ
         4aPMwIe14cn0GSxywKw5zrEqcJ12Rg1+l8MrDfLuOQIIPxDpbgHHpudKnu9FF+RquDGm
         ZnJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fsfWT0ngDuqLxZGzjvxnPlOGNaNiIFdiLSpcCpwbPtY=;
        b=KtTqOAywuCivO9WeJ3M4ciDzILEkX3ZY4l3VcpH3mrbQnZh1bj+eI2HCk2eBNhdmRg
         +tzIHl2Q5hhceJZSKVeyqmvJiyupTRaNTML9pHUa4KO9td0KasVX5aNJYCf1hiSgEwSV
         lU4agwXmadkGV1RRtcFo+KVG9a8+XS5A9bxN+vVSkbijl8oiMq0eDxqPei13Dc8qGMhn
         0u3/1y8vS0oq8KYXnxOfKxwwwZZKjWWQRWrzrO4hMo1jlQgyM9BRMvr2WrnNsY4yLso5
         WY5zKLJAD9hi2Xsco5d5ki4oWhe2/UsPq9dQ2uw5YqtJduJC+iOsNssbHKvDlVVsjTsT
         shCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q8si911056edg.87.2019.03.26.01.56.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 01:56:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 90FAAAC17;
	Tue, 26 Mar 2019 08:56:45 +0000 (UTC)
Date: Tue, 26 Mar 2019 09:56:43 +0100
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
Message-ID: <20190326085643.GG28406@dhcp22.suse.cz>
References: <20190325225636.11635-1-aarcange@redhat.com>
 <20190325225636.11635-2-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190325225636.11635-2-aarcange@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 25-03-19 18:56:35, Andrea Arcangeli wrote:
> MEMCG depends on the task structure not to be freed under
> rcu_read_lock() in get_mem_cgroup_from_mm() after it dereferences
> mm->owner.

Please state the actual problem. Your cover letter mentiones a race
condition. Please make it explicit in the changelog.
 
> An alternate possible fix would be to defer the delivery of the
> userfaultfd contexts to the monitor until after fork() is guaranteed
> to succeed. Such a change would require more changes because it would
> create a strict ordering dependency where the uffd methods would need
> to be called beyond the last potentially failing branch in order to be
> safe.

How much more changes are we talking about? Because ...

> This solution as opposed only adds the dependency to common code
> to set mm->owner to NULL and to free the task struct that was pointed
> by mm->owner with RCU, if fork ends up failing. The userfaultfd
> methods can still be called anywhere during the fork runtime and the
> monitor will keep discarding orphaned "mm" coming from failed forks in
> userland.

... this is adding a subtle hack that might break in the future because
copy_process error paths are far from trivial and quite error prone
IMHO. I am not opposed to the patch in principle but I would really like
to see what kind of solutions we are comparing here.

> This race condition couldn't trigger if CONFIG_MEMCG was set =n at
> build time.

All the CONFIG_MEMCG is just ugly as hell. Can we reduce that please?
E.g. use if (IS_ENABLED(CONFIG_MEMCG)) where appropriate?

[...]

> +static __always_inline void mm_clear_owner(struct mm_struct *mm,
> +					   struct task_struct *p)
> +{
> +#ifdef CONFIG_MEMCG
> +	if (mm->owner == p)
> +		WRITE_ONCE(mm->owner, NULL);
> +#endif

How can we ever hit this warning and what does that mean?

-- 
Michal Hocko
SUSE Labs

