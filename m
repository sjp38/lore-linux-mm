Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A999FC48BE4
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 18:45:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 797B92075E
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 18:45:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 797B92075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31EA06B0005; Thu, 27 Jun 2019 14:45:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CF988E0003; Thu, 27 Jun 2019 14:45:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1984A8E0002; Thu, 27 Jun 2019 14:45:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA6D26B0005
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 14:45:10 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 97so3352764qtb.16
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 11:45:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=C97BOyLoroY+sjZmkbUJ+oaw9j+XRbWDV51Qy+EJemo=;
        b=N0V2AV6exzZxkNihbr9yQVaYF8JwOY2OWalUHFP+OYTNK5csNFz6y97O/upWnyRntM
         Q/ZKO2aTumUuUMyJnZCgPU7TaMqXEnHcMgPhtJIhRmRBmsPnW5u+NLGkQ9+4nqY/vrsI
         tw1u1w1X8UTyKwboWsoHgQ7pNM3dafgeivaAxeNMcgwyRortTVCSE9JCz3riegHV12IR
         f+mXKynMoC62+OU67iwsnAf/qEvxN/ZrJUctLR2+J7g8ccBa5Cx3Vc4viLSJRaw9vjPr
         OxK/7ek62L6dpdpjSLlYX2crrhC8xxMYUu0cLel8GdAnIG/6CXyN3OmzigTSpCxvQ3e0
         o3ag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXwLNh9tDMQJrFH2hKO3BLWPEwdrZqJNcGOjDAzAHZQkbmqb8UY
	XPV1KX7s1Nf+YXur/o9/bSTyuWKVyUxzffj2j3s9GtUINm8O03dutXRcL5blQpT2kxMsuUxyvK9
	uUeBE+IVc8lYh4Ip1UBDyiW20ABx+AJBpX5TdFAkG0Vr5VYOvUTrEGWKAZ3o7bYaN0Q==
X-Received: by 2002:a0c:ae35:: with SMTP id y50mr4610984qvc.204.1561661110711;
        Thu, 27 Jun 2019 11:45:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+jVYrd02sqt/J1d6FBSZgw1lkMwyqhF1rMQZDpyVWDLFMiQF9253w58cbzhMhgY3tU9Cc
X-Received: by 2002:a0c:ae35:: with SMTP id y50mr4610946qvc.204.1561661110169;
        Thu, 27 Jun 2019 11:45:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561661110; cv=none;
        d=google.com; s=arc-20160816;
        b=Ix4DN/GAeNefFj8o4YCB8xtqczFuoR+14pdDglGFZaRy6ERDDbmCR96SNo4ELo+b0u
         cA6N2Etv17XkMImfg2oA/bO1FCp47xRyXkmBtkXzI+QOkNfpfLuusGrGXd48uYqdbFpe
         ccVykrEBXWTn1TMqIXpRRhu7flg3m4m4drTskXeYOkKYNJqMbqSWCy3lFPgSK/5wzdhQ
         dXm/DH1pj5E9gAbvD3lM/BMPG9DetM8JXw4TuUAkj50m65ANi7EZrY6OsHwB4VWuXxoV
         j+l6RbeF/Oc9TQX5hRIwIOritvVbn0DbEt6trMe0YOMh4LLBD633clfH5B67PCa56vn9
         MJ4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=C97BOyLoroY+sjZmkbUJ+oaw9j+XRbWDV51Qy+EJemo=;
        b=mx0PNPLX8Y6fRGoTnqzJ7EGSsFSbykrCoHKXbkJfX4TlTA02g5Dv4CHIJRH5SKE5uj
         3PnOI0sU05SCWPFwUAoeXnfqL8JSBZ9w20QT0Ci2JM75N29wBhl83WCEAjpXedN63kr0
         b9kuBenbUd78STWrl0u1OKAkpHnmDeDGUBiSCO3dplEf+BJKaZgpdTPWBhU/RUVjndqd
         609b3Kd+LHc3clY9FY1ekOVYz2r8d0cLYP+kplWGd/92zW2b0F7o7upHsQDvRvpCTute
         W/YldFeGbJ/VIQ0lbrXHhhuHiQ9Q5J7fOeEJxDiFoO97uv8/+SLao+NPa3nkHBHZ1TMF
         smig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z37si2293254qth.274.2019.06.27.11.45.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 11:45:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 39072C05168F;
	Thu, 27 Jun 2019 18:45:04 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 140405C1B4;
	Thu, 27 Jun 2019 18:45:00 +0000 (UTC)
Subject: Re: [PATCH-next] mm, memcg: Add ":deact" tag for reparented kmem
 caches in memcg_slabinfo
To: Roman Gushchin <guro@fb.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
 Shakeel Butt <shakeelb@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>
References: <20190621173005.31514-1-longman@redhat.com>
 <20190626195757.GB24698@tower.DHCP.thefacebook.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <cc7a0ac0-6f3a-4d0a-54b2-7387400aeb8c@redhat.com>
Date: Thu, 27 Jun 2019 14:45:00 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190626195757.GB24698@tower.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 27 Jun 2019 18:45:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/26/19 3:58 PM, Roman Gushchin wrote:
> On Fri, Jun 21, 2019 at 01:30:05PM -0400, Waiman Long wrote:
>> With Roman's kmem cache reparent patch, multiple kmem caches of the same
>> type can be seen attached to the same memcg id. All of them, except
>> maybe one, are reparent'ed kmem caches. It can be useful to tag those
>> reparented caches by adding a new slab flag "SLAB_DEACTIVATED" to those
>> kmem caches that will be reparent'ed if it cannot be destroyed completely.
>>
>> For the reparent'ed memcg kmem caches, the tag ":deact" will now be
>> shown in <debugfs>/memcg_slabinfo.
>>
>> Signed-off-by: Waiman Long <longman@redhat.com>
> Hi Waiman!
>
> Sorry for the late reply. The patch overall looks good to me,
> except one nit. Please feel free to use my ack:
> Acked-by: Roman Gushchin <guro@fb.com>
>
>> ---
>>  include/linux/slab.h |  4 ++++
>>  mm/slab.c            |  1 +
>>  mm/slab_common.c     | 14 ++++++++------
>>  mm/slub.c            |  1 +
>>  4 files changed, 14 insertions(+), 6 deletions(-)
>>
>> diff --git a/include/linux/slab.h b/include/linux/slab.h
>> index fecf40b7be69..19ab1380f875 100644
>> --- a/include/linux/slab.h
>> +++ b/include/linux/slab.h
>> @@ -116,6 +116,10 @@
>>  /* Objects are reclaimable */
>>  #define SLAB_RECLAIM_ACCOUNT	((slab_flags_t __force)0x00020000U)
>>  #define SLAB_TEMPORARY		SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
>> +
>> +/* Slab deactivation flag */
>> +#define SLAB_DEACTIVATED	((slab_flags_t __force)0x10000000U)
>> +
>>  /*
>>   * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
>>   *
>> diff --git a/mm/slab.c b/mm/slab.c
>> index a2e93adf1df0..e8c7743fc283 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -2245,6 +2245,7 @@ int __kmem_cache_shrink(struct kmem_cache *cachep)
>>  #ifdef CONFIG_MEMCG
>>  void __kmemcg_cache_deactivate(struct kmem_cache *cachep)
>>  {
>> +	cachep->flags |= SLAB_DEACTIVATED;
> A nit: it can be done from kmemcg_cache_deactivate() instead,
> and then you don't have to do it in slab and slub separately.
>
> Since it's not slab- or slub-specific code, it'd be better, IMO,
> to put it into slab_common.c.

Thanks for the suggestion.

You are right. It will be cleaner to set the flag in
kmemcg_cache_deactivate(). I have just sent out a v2 patch to do that.

Cheers,
Longman

