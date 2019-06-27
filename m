Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5EA5C5B576
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 20:58:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C6B42075E
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 20:58:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C6B42075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A98C6B0003; Thu, 27 Jun 2019 16:58:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 159EE8E0003; Thu, 27 Jun 2019 16:58:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 047528E0002; Thu, 27 Jun 2019 16:58:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D782C6B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 16:58:18 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id i196so3860133qke.20
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 13:58:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=IRxeaXD7MNYi+4DQpHJ7keFZoWtD592Ry/e2Cz42UtE=;
        b=Ple3LdhVyG0G6DKNceE5xYFWFz7YIMUmGxZQiikFvA6wBt/jSIaBwCPhJHdupM9Abn
         sD3KDtkXytKwr66IMfuM4UR64lf3fKCPkEQ3PBGbfsJ+K6dBdCLWcOBNk8x6GWpc3WJF
         Ou8X5xwK/8isBXGGmG/uBRJPBG8jlZYWbMBRAhmx43RIC7UX/JfVzAwKOlQdcKZriSt8
         Md2cO8RQqcBO+6dT/jlSjqRQEIWj+kd1GCNOoEFh2s0zaMx8rY7YuBrb87N7zJBsksP0
         De0senV9DgsQ+V9HRjAhajjNE19oCGHwz0UBI+L9SBkgFmycrK4tQrH2H1oqki25n+rK
         exGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUp1SyY/7hQKypu75YzzrbqmMRkqjXaznkHT7CTQZYnjaJNfbhq
	BAw/IyYiQJEANhzKeyfxrzQMnh7eR2WlsI0gimOHdcOK9jKrLs9z1GdKTD7NfnVo2SKHPLtlhbd
	OBvVGByPJ7oB9tYaQuNmS/QynNBj5LgKcv41vgQ7dtJMRkByxD3joI+VnyBONdGWOiw==
X-Received: by 2002:a05:620a:1310:: with SMTP id o16mr5115563qkj.196.1561669098583;
        Thu, 27 Jun 2019 13:58:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLmLqEMTCeogT/I/X8vpY7SbdwobE2l91vNaW5uyz4ggFKriCNW/QTvy3z2GkuCU00kdx9
X-Received: by 2002:a05:620a:1310:: with SMTP id o16mr5115522qkj.196.1561669097863;
        Thu, 27 Jun 2019 13:58:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561669097; cv=none;
        d=google.com; s=arc-20160816;
        b=ksaAk/NeC8thX7DvezUP2ZxEvTR1mo8sicF01LsrluLIyRzvSjyJ2sXjVn9dfa5jzz
         8BsjoYKuLq7pHejXdt4crK8xI7lD11l6ajpkWz+n1uZiF4tUfzUiKDX3aubz4AxNedAg
         gqO6UnvvhDCQetRK3lWfznASBy19TDuXF95NfCBsJeymbrsVSKVAhy96bzWTfwXrdvtj
         jGOMHWZi5i7Tz4JInVYCeOdhJLhQIYVG2Fhaq5LkNeCmdHFTmVAWvoKPydRQV0VE73TK
         Mqx5pRtIxz2j4DPlwI5TiVVyATvhH+cccmYfVB+xp0XfAEP5/snBAxp3AF0WIvuB7yQg
         slwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=IRxeaXD7MNYi+4DQpHJ7keFZoWtD592Ry/e2Cz42UtE=;
        b=uvwCF4qiRBiPC56n8b7ozxoiodOpqzRfrVpuVAPXYsydauoB+v3lLsSGGM43aTtm8B
         TcjLoSzZVzieY08YfQidxh3U9axc2jryfMPE02LJ776VY1y3orLx2R7URj8/YcsarMoi
         qHCf/vmSRDdKX0JfzQNZb/BuZJk7VYalM0+pZYrSn0nqR1HujnPhWgUcRgki3kCzP1K1
         ssWNRpUeKaUns9rVbq1zRmku7h47z5GJBD3S5Mzw9/IUIM1Tz/QVrc+GgMumeofyXwoy
         KhO57VWcluSmrQQY7yvXw58tFn/esoly7lUdWNlC6WYvOtmV0rIqk2mU5NPcxROFHyOT
         vL+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o56si227384qvc.130.2019.06.27.13.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 13:58:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C10C930C0DCA;
	Thu, 27 Jun 2019 20:57:57 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3DD4B10013D9;
	Thu, 27 Jun 2019 20:57:51 +0000 (UTC)
Subject: Re: [PATCH 2/2] mm, slab: Extend vm/drop_caches to shrink kmem slabs
To: Roman Gushchin <guro@fb.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>,
 Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Shakeel Butt <shakeelb@google.com>, Andrea Arcangeli <aarcange@redhat.com>
References: <20190624174219.25513-1-longman@redhat.com>
 <20190624174219.25513-3-longman@redhat.com>
 <20190626201900.GC24698@tower.DHCP.thefacebook.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <063752b2-4f1a-d198-36e7-3e642d4fcf19@redhat.com>
Date: Thu, 27 Jun 2019 16:57:50 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190626201900.GC24698@tower.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Thu, 27 Jun 2019 20:58:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/26/19 4:19 PM, Roman Gushchin wrote:
>>  
>> +#ifdef CONFIG_MEMCG_KMEM
>> +static void kmem_cache_shrink_memcg(struct mem_cgroup *memcg,
>> +				    void __maybe_unused *arg)
>> +{
>> +	struct kmem_cache *s;
>> +
>> +	if (memcg == root_mem_cgroup)
>> +		return;
>> +	mutex_lock(&slab_mutex);
>> +	list_for_each_entry(s, &memcg->kmem_caches,
>> +			    memcg_params.kmem_caches_node) {
>> +		kmem_cache_shrink(s);
>> +	}
>> +	mutex_unlock(&slab_mutex);
>> +	cond_resched();
>> +}
> A couple of questions:
> 1) how about skipping already offlined kmem_caches? They are already shrunk,
>    so you probably won't get much out of them. Or isn't it true?

I have been thinking about that. This patch is based on the linux tree
and so don't have an easy to find out if the kmem caches have been
shrinked. Rebasing this on top of linux-next, I can use the
SLAB_DEACTIVATED flag as a marker for skipping the shrink.

With all the latest patches, I am still seeing 121 out of a total of 726
memcg kmem caches (1/6) that are deactivated caches after system bootup
one of the test systems. My system is still using cgroup v1 and so the
number may be different in a v2 setup. The next step is probably to
figure out why those deactivated caches are still there.

> 2) what's your long-term vision here? do you think that we need to shrink
>    kmem_caches periodically, depending on memory pressure? how a user
>    will use this new sysctl?
Shrinking the kmem caches under extreme memory pressure can be one way
to free up extra pages, but the effect will probably be temporary.
> What's the problem you're trying to solve in general?

At least for the slub allocator, shrinking the caches allow the number
of active objects reported in slabinfo to be more accurate. In addition,
this allow to know the real slab memory consumption. I have been working
on a BZ about continuous memory leaks with a container based workloads.
The ability to shrink caches allow us to get a more accurate memory
consumption picture. Another alternative is to turn on slub_debug which
will then disables all the per-cpu slabs.

Anyway, I think this can be useful to others that is why I posted the patch.

Cheers,
Longman

