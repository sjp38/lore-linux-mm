Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1E02C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 18:40:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5295920856
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 18:40:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5295920856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCFB06B0003; Tue, 21 May 2019 14:40:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7FDF6B0006; Tue, 21 May 2019 14:40:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C47B36B0007; Tue, 21 May 2019 14:40:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A62F36B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 14:40:07 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id p7so66297qkk.19
        for <linux-mm@kvack.org>; Tue, 21 May 2019 11:40:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-language;
        bh=3a9gzlmrNHlOMQL+epRzF+a1gnlr0Fwt49u6tI7+iAE=;
        b=nCbdlD5I6bk1MThBJea0QOYonnHatvWrXPSjrUR2EIHwqtHLIlalmKU5kVIJQjOmBP
         vrwBjDMcC3zJkVWVsNo7zRSId1CBCeWdaOHaZN/4oeDAHKEH8RtPMUyVYT9Jy7mfIJwM
         rZMu7nQ94K2wubiVDAhNocvAKMs6ju77EOOM3UQQtUZ8Kwb5irKDbKMUbx+rgAVD2Ttx
         X0IhxjhhJO3mPIUpBOeHdP6JMUoskvgu/tAbec251k9R1nsYPQRxPbbVNR9WS5k289pw
         Xjb/5tcZ4+anmUteBew82ASqfPKEINp4Jkfw5IoGwTNSXrFrn7SyOzBYWCVvlZR6AS69
         tYRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXKjOsG6Dj6a0wtrwvGBd2tEYDf+4DqPei2StQj+q9gWDenGaOO
	mSH4UCVEz4mYq3JzngNxYkyzOsbhZ2RmpxXWuXNyX/84Rx2c5oSW+p1xzRLt4NBCGG4NRBUoaMX
	L4S5lSvnEzGSe3ih7hruag0sgpUHfUmwyIXtBGevVLsH9G+SXWCOljPatDmfTXjRnFw==
X-Received: by 2002:a37:358:: with SMTP id 85mr63167486qkd.174.1558464007432;
        Tue, 21 May 2019 11:40:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcE3LWGo9c7Ox7qAwcMXAacDCw0Q1uI+kyCmz0aOVT8stCM3WBhTfodPS5Q6otkqkPdDxa
X-Received: by 2002:a37:358:: with SMTP id 85mr63167434qkd.174.1558464006649;
        Tue, 21 May 2019 11:40:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558464006; cv=none;
        d=google.com; s=arc-20160816;
        b=uWWA+Sd03mE3jvDZlC92UFckvQoXeRHF1IGkIER14RtCxqlTRqeZJrTzXqIT5kB6YI
         mOkLfDbgmQUdBoxHAD1ayvXloIEzIaU1cyqnS4ah3ulQPwBlw7uPU0k9tjZFjWjq/E4L
         x846anC5LcaDEYsWomB2R4E2uLUs/pgJGKrG6n/jNFGxLNyjdgdrB94asgrafxWYYr7e
         o9q5PY5HJ74m1X3TpF0kGMs1Ag+dMr/mFCfxx1DMjdOXiqNqyBp59QNUIKV1yNUIuAqi
         T+Yjq5D9Fz3fcwFd5bDuxQIzWWfxjc4K1Ij0DPvFdTFw2EGPkEYk4MNtXqeIAB+puh0Q
         6/Zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:organization:from:references:cc:to:subject;
        bh=3a9gzlmrNHlOMQL+epRzF+a1gnlr0Fwt49u6tI7+iAE=;
        b=aqstY6UIMUZd4iHDO3C9uB4BQSzuFHWhfmjJQYdb46NA5zG1a6S8S2xEe5X1wLYz1m
         9Ne24ud08FDr7JxsbAR9Ygwz1T4w7oEdxEOTtyV2SOjY738qkiM5jjrgDsTHOX/ftZfC
         Rtw70RjH9k/kQ4t1A8YmKs/qnBCTmVLqfHj06s48+/KpZvBzcPJbK8VQ1PejOf70OJJ1
         +JiuIPhrioFLCyls8BHWGkZ0f2Zu8UIdRwc/qct/VBdcx4y1oNw72lzjg08WzwMtma8I
         6oplOJvZuiEQiJCQu9HmXZpBBTS7XVgSAbf/uaK867PSPpr8CPemSnyo7LYGwfYL6GfW
         A9Qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o40si1370981qta.354.2019.05.21.11.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 11:40:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6026CC05FBD7;
	Tue, 21 May 2019 18:39:55 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 32E0A1001E73;
	Tue, 21 May 2019 18:39:51 +0000 (UTC)
Subject: Re: [PATCH v4 5/7] mm: rework non-root kmem_cache lifecycle
 management
To: Shakeel Butt <shakeelb@google.com>, Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Rik van Riel <riel@surriel.com>, Christoph Lameter <cl@linux.com>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>
References: <20190514213940.2405198-1-guro@fb.com>
 <20190514213940.2405198-6-guro@fb.com>
 <CALvZod6Zb_kYHyG02jXBY9gvvUn_gOug7kq_hVa8vuCbXdPdjQ@mail.gmail.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <7d06354d-4542-af42-d83d-2bc4639b56f2@redhat.com>
Date: Tue, 21 May 2019 14:39:50 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CALvZod6Zb_kYHyG02jXBY9gvvUn_gOug7kq_hVa8vuCbXdPdjQ@mail.gmail.com>
Content-Type: multipart/alternative;
 boundary="------------881B149B7D2607D879F64E2B"
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 21 May 2019 18:40:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------881B149B7D2607D879F64E2B
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

On 5/14/19 8:06 PM, Shakeel Butt wrote:
>> @@ -2651,20 +2652,35 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
>>         struct mem_cgroup *memcg;
>>         struct kmem_cache *memcg_cachep;
>>         int kmemcg_id;
>> +       struct memcg_cache_array *arr;
>>
>>         VM_BUG_ON(!is_root_cache(cachep));
>>
>>         if (memcg_kmem_bypass())
>>                 return cachep;
>>
>> -       memcg = get_mem_cgroup_from_current();
>> +       rcu_read_lock();
>> +
>> +       if (unlikely(current->active_memcg))
>> +               memcg = current->active_memcg;
>> +       else
>> +               memcg = mem_cgroup_from_task(current);
>> +
>> +       if (!memcg || memcg == root_mem_cgroup)
>> +               goto out_unlock;
>> +
>>         kmemcg_id = READ_ONCE(memcg->kmemcg_id);
>>         if (kmemcg_id < 0)
>> -               goto out;
>> +               goto out_unlock;
>>
>> -       memcg_cachep = cache_from_memcg_idx(cachep, kmemcg_id);
>> -       if (likely(memcg_cachep))
>> -               return memcg_cachep;
>> +       arr = rcu_dereference(cachep->memcg_params.memcg_caches);
>> +
>> +       /*
>> +        * Make sure we will access the up-to-date value. The code updating
>> +        * memcg_caches issues a write barrier to match this (see
>> +        * memcg_create_kmem_cache()).
>> +        */
>> +       memcg_cachep = READ_ONCE(arr->entries[kmemcg_id]);
>>
>>         /*
>>          * If we are in a safe context (can wait, and not in interrupt
>> @@ -2677,10 +2693,20 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
>>          * memcg_create_kmem_cache, this means no further allocation
>>          * could happen with the slab_mutex held. So it's better to
>>          * defer everything.
>> +        *
>> +        * If the memcg is dying or memcg_cache is about to be released,
>> +        * don't bother creating new kmem_caches. Because memcg_cachep
>> +        * is ZEROed as the fist step of kmem offlining, we don't need
>> +        * percpu_ref_tryget() here. css_tryget_online() check in
> *percpu_ref_tryget_live()
>
>> +        * memcg_schedule_kmem_cache_create() will prevent us from
>> +        * creation of a new kmem_cache.
>>          */
>> -       memcg_schedule_kmem_cache_create(memcg, cachep);
>> -out:
>> -       css_put(&memcg->css);
>> +       if (unlikely(!memcg_cachep))
>> +               memcg_schedule_kmem_cache_create(memcg, cachep);
>> +       else if (percpu_ref_tryget(&memcg_cachep->memcg_params.refcnt))
>> +               cachep = memcg_cachep;
>> +out_unlock:
>> +       rcu_read_lock();

There is one more bug that causes the kernel to panic on bootup when I
turned on debugging options.

[   49.871437] =============================
[   49.875452] WARNING: suspicious RCU usage
[   49.879476] 5.2.0-rc1.bz1699202_memcg_test+ #2 Not tainted
[   49.884967] -----------------------------
[   49.888991] include/linux/rcupdate.h:268 Illegal context switch in
RCU read-side critical section!
[   49.897950]
[   49.897950] other info that might help us debug this:
[   49.897950]
[   49.905958]
[   49.905958] rcu_scheduler_active = 2, debug_locks = 1
[   49.912492] 3 locks held by systemd/1:
[   49.916252]  #0: 00000000633673c5 (&type->i_mutex_dir_key#5){.+.+},
at: lookup_slow+0x42/0x70
[   49.924788]  #1: 0000000029fa8c75 (rcu_read_lock){....}, at:
memcg_kmem_get_cache+0x12b/0x910
[   49.933316]  #2: 0000000029fa8c75 (rcu_read_lock){....}, at:
memcg_kmem_get_cache+0x3da/0x910

It should be "rcu_read_unlock();" at the end.

-Longman


--------------881B149B7D2607D879F64E2B
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <div class="moz-cite-prefix">On 5/14/19 8:06 PM, Shakeel Butt wrote:<br>
    </div>
    <blockquote type="cite"
cite="mid:CALvZod6Zb_kYHyG02jXBY9gvvUn_gOug7kq_hVa8vuCbXdPdjQ@mail.gmail.com">
      <blockquote type="cite" style="color: #000000;">
        <pre class="moz-quote-pre" wrap="">@@ -2651,20 +2652,35 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
        struct mem_cgroup *memcg;
        struct kmem_cache *memcg_cachep;
        int kmemcg_id;
+       struct memcg_cache_array *arr;

        VM_BUG_ON(!is_root_cache(cachep));

        if (memcg_kmem_bypass())
                return cachep;

-       memcg = get_mem_cgroup_from_current();
+       rcu_read_lock();
+
+       if (unlikely(current-&gt;active_memcg))
+               memcg = current-&gt;active_memcg;
+       else
+               memcg = mem_cgroup_from_task(current);
+
+       if (!memcg || memcg == root_mem_cgroup)
+               goto out_unlock;
+
        kmemcg_id = READ_ONCE(memcg-&gt;kmemcg_id);
        if (kmemcg_id &lt; 0)
-               goto out;
+               goto out_unlock;

-       memcg_cachep = cache_from_memcg_idx(cachep, kmemcg_id);
-       if (likely(memcg_cachep))
-               return memcg_cachep;
+       arr = rcu_dereference(cachep-&gt;memcg_params.memcg_caches);
+
+       /*
+        * Make sure we will access the up-to-date value. The code updating
+        * memcg_caches issues a write barrier to match this (see
+        * memcg_create_kmem_cache()).
+        */
+       memcg_cachep = READ_ONCE(arr-&gt;entries[kmemcg_id]);

        /*
         * If we are in a safe context (can wait, and not in interrupt
@@ -2677,10 +2693,20 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
         * memcg_create_kmem_cache, this means no further allocation
         * could happen with the slab_mutex held. So it's better to
         * defer everything.
+        *
+        * If the memcg is dying or memcg_cache is about to be released,
+        * don't bother creating new kmem_caches. Because memcg_cachep
+        * is ZEROed as the fist step of kmem offlining, we don't need
+        * percpu_ref_tryget() here. css_tryget_online() check in
</pre>
      </blockquote>
      <pre class="moz-quote-pre" wrap="">*percpu_ref_tryget_live()

</pre>
      <blockquote type="cite" style="color: #000000;">
        <pre class="moz-quote-pre" wrap="">+        * memcg_schedule_kmem_cache_create() will prevent us from
+        * creation of a new kmem_cache.
         */
-       memcg_schedule_kmem_cache_create(memcg, cachep);
-out:
-       css_put(&amp;memcg-&gt;css);
+       if (unlikely(!memcg_cachep))
+               memcg_schedule_kmem_cache_create(memcg, cachep);
+       else if (percpu_ref_tryget(&amp;memcg_cachep-&gt;memcg_params.refcnt))
+               cachep = memcg_cachep;
+out_unlock:
+       rcu_read_lock();</pre>
      </blockquote>
    </blockquote>
    <p>There is one more bug that causes the kernel to panic on bootup
      when I turned on debugging options.</p>
    <p>[   49.871437] =============================<br>
      [   49.875452] WARNING: suspicious RCU usage<br>
      [   49.879476] 5.2.0-rc1.bz1699202_memcg_test+ #2 Not tainted<br>
      [   49.884967] -----------------------------<br>
      [   49.888991] include/linux/rcupdate.h:268 Illegal context switch
      in RCU read-side critical section!<br>
      [   49.897950]<br>
      [   49.897950] other info that might help us debug this:<br>
      [   49.897950]<br>
      [   49.905958]<br>
      [   49.905958] rcu_scheduler_active = 2, debug_locks = 1<br>
      [   49.912492] 3 locks held by systemd/1:<br>
      [   49.916252]  #0: 00000000633673c5
      (&amp;type-&gt;i_mutex_dir_key#5){.+.+}, at: lookup_slow+0x42/0x70<br>
      [   49.924788]  #1: 0000000029fa8c75 (rcu_read_lock){....}, at:
      memcg_kmem_get_cache+0x12b/0x910<br>
      [   49.933316]  #2: 0000000029fa8c75 (rcu_read_lock){....}, at:
      memcg_kmem_get_cache+0x3da/0x910<br>
    </p>
    <p>It should be "rcu_read_unlock();" at the end.<br>
    </p>
    <p>-Longman</p>
  </body>
</html>

--------------881B149B7D2607D879F64E2B--

