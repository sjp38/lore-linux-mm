Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F876C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 12:05:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6902206A2
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 12:05:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6902206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E8E76B0006; Mon,  5 Aug 2019 08:05:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 798EB6B0007; Mon,  5 Aug 2019 08:05:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 661BC6B0008; Mon,  5 Aug 2019 08:05:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 188656B0006
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 08:05:28 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y15so51412823edu.19
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 05:05:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XtHWSvQanYkrnSYaXyBrSV+kEcO7Bqv181hzKdFbYC8=;
        b=AV7qPjLnphNA4FC9GPjR4gQ0l302rh2vWnDDzqRNtS6EgUW+oQFoKih58Jh4rJASsr
         4jNDxkmBu6nPQb5Avo4DMkMfthZF+a/0SSXiLx87l+E8aahl5Rs/qW7BbKxMadqt+Pg7
         leq+H3r6YhbteIIbjOJO41DYFS6Rge376wd/IcDNhQstJ1JS21TAo8Q7GZadFXq5Rx1R
         ScRE4CS6khUKo5atwhy3z1NVdPTs1ANYOQbzv+7ZLj3Zilr+zRhzWv2WOEn5hXInYdj9
         QHobZJ3LsjuSBbETYcPBrdnRjecklEPmNN5CvwJEr0cSDfqoH034He6RK7arQ8Q+dA60
         zfww==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXx+0HgJunfzHD51F/skOWiBn22uy1cnS3alyVAfxewYyJpSklr
	/+zepvvgQuFUoYGQzJtzpgK2CIBGZ8zn3iKWJ2s6cHFtwE9vt/ZvWIv8C2helaKk7z2225LcQcD
	Px+cYd7W96CpZ/cEB+h18Z+VvP0VGfWHV5m0ulGlbjfeSSTBxfOCSURR+OSQZSMY=
X-Received: by 2002:a17:906:3919:: with SMTP id f25mr12510136eje.243.1565006727674;
        Mon, 05 Aug 2019 05:05:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx30QSOzzxvxVxEnO1mTqaqwlXOnYmt2fHTpg8V9pDyURmZ+dgjW4qgv0pNb7iJiJhUf1/3
X-Received: by 2002:a17:906:3919:: with SMTP id f25mr12510082eje.243.1565006727016;
        Mon, 05 Aug 2019 05:05:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565006727; cv=none;
        d=google.com; s=arc-20160816;
        b=Nxj+UlhZgV/LpBFoCmTGe6C2ZQw1aVWIKT3g+oyPpHwRMrDtIvkrnmckOZeObZxaD7
         Is08uu4SIWduOT7rvU+UlpFEiDnXr8vl86khQ6dCTgkz0h0f/ziaOyrUZ4+D3P82ibbC
         aURNjfJKXq8/qSMK8nBBuKvSa4ueBOOCJZYfOwLxAvwmfN6f8hcIHpLwlXGVZfjJUzSt
         UDKDH0zaM6QOBTHnSNGcJVNkBokjUti0ZhTEzdjX334wBl4IYyzKbzYkTf7Mm/1/Zoim
         D2x3d190O2nR1B6PWfMsFYQ1e3AVsAt3rNGRgC9gPcAy+EsobrauqjhDX84Fn+eNE73t
         G/ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XtHWSvQanYkrnSYaXyBrSV+kEcO7Bqv181hzKdFbYC8=;
        b=hgl7QmBgSmLbyEo/gvGvTezeCu2zsyS8WHDg3XQSE4MV5QkpRPwSA2oAE1nr6QZvD8
         8BjDpUw182TYdKwE2sjqB7qsn73JNFo2F+s63oM2pdZn6d8OJ+ueM/XsDVRnmg6Gi8Rc
         XL+zlvhEqmKXc69SSSJvHIxdOQMKE1Mr5d/OMcBcm1z6gf7inQ1A7FL1RQF/YAQGJqvs
         b8kBbcUhwROrr2Ed9J5V24VwbbdVYtQKgdbnSZjuKqgl6XfCroYXa75WM0duXRhYc9c0
         x0eZezRT36dNQn1cepmykz7sNdRNn9byJsQwnVMW5GjfhnutalDXM2kDDNKOKMKjh0AU
         hEQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l15si26228769ejx.299.2019.08.05.05.05.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 05:05:26 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A26EBADAA;
	Mon,  5 Aug 2019 12:05:26 +0000 (UTC)
Date: Mon, 5 Aug 2019 14:05:25 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	pankaj.suryawanshi@einfochips.com
Subject: Re: oom-killer
Message-ID: <20190805120525.GL7597@dhcp22.suse.cz>
References: <CACDBo54Jbueeq1XbtbrFOeOEyF-Q4ipZJab8mB7+0cyK1Foqyw@mail.gmail.com>
 <20190805112437.GF7597@dhcp22.suse.cz>
 <0821a17d-1703-1b82-d850-30455e19e0c1@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0821a17d-1703-1b82-d850-30455e19e0c1@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 05-08-19 13:56:20, Vlastimil Babka wrote:
> On 8/5/19 1:24 PM, Michal Hocko wrote:
> >> [  727.954355] CPU: 0 PID: 56 Comm: kworker/u8:2 Tainted: P           O  4.14.65 #606
> > [...]
> >> [  728.029390] [<c034a094>] (oom_kill_process) from [<c034af24>] (out_of_memory+0x140/0x368)
> >> [  728.037569]  r10:00000001 r9:c12169bc r8:00000041 r7:c121e680 r6:c1216588 r5:dd347d7c > [  728.045392]  r4:d5737080
> >> [  728.047929] [<c034ade4>] (out_of_memory) from [<c03519ac>]  (__alloc_pages_nodemask+0x1178/0x124c)
> >> [  728.056798]  r7:c141e7d0 r6:c12166a4 r5:00000000 r4:00001155
> >> [  728.062460] [<c0350834>] (__alloc_pages_nodemask) from [<c021e9d4>] (copy_process.part.5+0x114/0x1a28)
> >> [  728.071764]  r10:00000000 r9:dd358000 r8:00000000 r7:c1447e08 r6:c1216588 r5:00808111
> >> [  728.079587]  r4:d1063c00
> >> [  728.082119] [<c021e8c0>] (copy_process.part.5) from [<c0220470>] (_do_fork+0xd0/0x464)
> >> [  728.090034]  r10:00000000 r9:00000000 r8:dd008400 r7:00000000 r6:c1216588 r5:d2d58ac0
> >> [  728.097857]  r4:00808111
> > 
> > The call trace tells that this is a fork (of a usermodhlper but that is
> > not all that important.
> > [...]
> >> [  728.260031] DMA free:17960kB min:16384kB low:25664kB high:29760kB active_anon:3556kB inactive_anon:0kB active_file:280kB inactive_file:28kB unevictable:0kB writepending:0kB present:458752kB managed:422896kB mlocked:0kB kernel_stack:6496kB pagetables:9904kB bounce:0kB free_pcp:348kB local_pcp:0kB free_cma:0kB
> >> [  728.287402] lowmem_reserve[]: 0 0 579 579
> > 
> > So this is the only usable zone and you are close to the min watermark
> > which means that your system is under a serious memory pressure but not
> > yet under OOM for order-0 request. The situation is not great though
> 
> Looking at lowmem_reserve above, wonder if 579 applies here? What does
> /proc/zoneinfo say?

This is GFP_KERNEL request essentially so there shouldn't be any lowmem
reserve here, no?
-- 
Michal Hocko
SUSE Labs

