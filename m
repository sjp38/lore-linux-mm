Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16416C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:38:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC47021734
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:38:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC47021734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 781596B0284; Tue, 28 May 2019 13:38:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70A936B0285; Tue, 28 May 2019 13:38:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AC256B0286; Tue, 28 May 2019 13:38:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3009D6B0284
	for <linux-mm@kvack.org>; Tue, 28 May 2019 13:38:18 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id 73so10631400oty.2
        for <linux-mm@kvack.org>; Tue, 28 May 2019 10:38:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-language;
        bh=Bk2LsvsBSuSaHOjj9Wy0EZFxVxL6bxXfc+CWqcO5Pv8=;
        b=ThRW0nUpONkvcyOk8q6mYZJ7I5SjT4yBb+k6Z7AKplIjgo7gTWGi+t97zfuutpCKqc
         c7PBdZiu7cyMWzBG2zaAhOwa69J7Ck+xqsOfjtwkSderNZUEt1bhvOC82OTJ+4kRnUfj
         wNJ+h7YikUnKGfpBpxV0D6sIWLsGXGe1tknW/29BIfPq//+5RHnhoXsJzxs7qXmvYDmM
         PQ0AnqoLHQxyGcJBuVznqhZzM1J7d87OUtOhROtkJAH/OB8IxXrSmFjnNDDQDqKtVYT5
         5wuIqMrCAtj81Pkv+XGi6Yrzu7bK1GIaXeVOAXKk3MtWw2GwXm/GVFxOeR6GNtYYQEOe
         AMIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXbf5fmzlTUzxY/tXKmF8XhK3KO37+Qfu4k51Y8L2Eo+uyHZapI
	mBqEHey4HGiABZ191p1WdvFIcmRl6NCdGZ2+Z6HkrNJkCXkppG9DiNYAnqnpN4P6YY9yZFv10q8
	4JPrhUX6esabq6ipD3hC95GUxCb5cALb64cIsEV339jkVOT30+60WPMggrXpNALXVQw==
X-Received: by 2002:aca:cc41:: with SMTP id c62mr3505396oig.167.1559065097861;
        Tue, 28 May 2019 10:38:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2DFnPgpxQma0A/uEhZgsJfLjHt4TqW1LaQ3g4i/Wa3ENhNFOnXhovWik0QlA2DGkkzYZm
X-Received: by 2002:aca:cc41:: with SMTP id c62mr3505366oig.167.1559065097329;
        Tue, 28 May 2019 10:38:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559065097; cv=none;
        d=google.com; s=arc-20160816;
        b=yIj2MgAz3xtgyz6L1+o8KtH9+v9QgjLbu4TszgFbmg9CBSxIoamV2diFl8A/cjTPM2
         UTWe3gwgX/ZMQzcdlg9op/Z/RrSlW3bWvEDf8/HmAgOECTeEcX6/oHPgOfq8aOZJjWGR
         bSMVBYu8hNjwX5LFwyC8siH/WQx8nsbxYUqGQV1aWj3smCCk8uHUgRhYgN8cuBcMku5J
         pDusGbAsmZvQ2wmKavXHkO8Cxft0dOpwbyIK3thvbYQDvz/F/bq8AuYMopwZ9Gg6jojO
         Hp4NtLkd6b+FzOV3MVpcmyCdVRJ+HxDNYMYRUMHxFS1pnF2rOnpdKtJB794JKijnbv2s
         Zxjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:organization:from:references:cc:to:subject;
        bh=Bk2LsvsBSuSaHOjj9Wy0EZFxVxL6bxXfc+CWqcO5Pv8=;
        b=R6RAvmHqVDdctSn4S9DyEis3GPTBW/LsxbTvJ5XKAXVdAa2AWrqYiNkTyqO5t8MKpC
         Y6E62wlw7+nsWAZQwm3YE0cqgPlQwb89FxydVpprfa8gk6KbdBFDK3tGTpZ+frJK/R5R
         vMKGCmZosdMnlecKCMLwuY5wxXts4Ui3fyGukrmUe461H5GePW+YOBbAT2ImvzHQaiDO
         JhYHksy274tAMEvr7cFFnnWxFEkJPj1gtwu67uTofkRPyoFi81ZvNdSakZgYIVpYP4Bd
         hYKHm8hpMI6C71JmhgdOTJLLB7zL7RcO9yJs9swKzD062jlFFghsEfzy1uMBl4DjnSXq
         Ox3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k67si7544286oih.168.2019.05.28.10.38.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 10:38:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0A7D37E424;
	Tue, 28 May 2019 17:37:59 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9884910027C7;
	Tue, 28 May 2019 17:37:50 +0000 (UTC)
Subject: Re: [PATCH v5 5/7] mm: rework non-root kmem_cache lifecycle
 management
To: Vladimir Davydov <vdavydov.dev@gmail.com>, Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kernel-team@fb.com,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Rik van Riel <riel@surriel.com>, Shakeel Butt <shakeelb@google.com>,
 Christoph Lameter <cl@linux.com>, cgroups@vger.kernel.org
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-6-guro@fb.com>
 <20190528170828.zrkvcdsj3d3jzzzo@esperanza>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <96b8a923-49e4-f13e-b1e3-3df4598d849e@redhat.com>
Date: Tue, 28 May 2019 13:37:50 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190528170828.zrkvcdsj3d3jzzzo@esperanza>
Content-Type: multipart/alternative;
 boundary="------------93207EDE24F79E4B4BD55885"
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 28 May 2019 17:38:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------93207EDE24F79E4B4BD55885
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 5/28/19 1:08 PM, Vladimir Davydov wrote:
>>  static void flush_memcg_workqueue(struct kmem_cache *s)
>>  {
>> +	/*
>> +	 * memcg_params.dying is synchronized using slab_mutex AND
>> +	 * memcg_kmem_wq_lock spinlock, because it's not always
>> +	 * possible to grab slab_mutex.
>> +	 */
>>  	mutex_lock(&slab_mutex);
>> +	spin_lock(&memcg_kmem_wq_lock);
>>  	s->memcg_params.dying = true;
>> +	spin_unlock(&memcg_kmem_wq_lock);
> I would completely switch from the mutex to the new spin lock -
> acquiring them both looks weird.
>
>>  	mutex_unlock(&slab_mutex);
>>  
>>  	/*

There are places where the slab_mutex is held and sleeping functions
like kvzalloc() are called. I understand that taking both mutex and
spinlocks look ugly, but converting all the slab_mutex critical sections
to spinlock critical sections will be a major undertaking by itself. So
I would suggest leaving that for now.

Cheers,
Longman


--------------93207EDE24F79E4B4BD55885
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <div class="moz-cite-prefix">On 5/28/19 1:08 PM, Vladimir Davydov
      wrote:<br>
    </div>
    <blockquote type="cite"
      cite="mid:20190528170828.zrkvcdsj3d3jzzzo@esperanza">
      <blockquote type="cite" style="color: #000000;">
        <pre class="moz-quote-pre" wrap=""> static void flush_memcg_workqueue(struct kmem_cache *s)
 {
+	/*
+	 * memcg_params.dying is synchronized using slab_mutex AND
+	 * memcg_kmem_wq_lock spinlock, because it's not always
+	 * possible to grab slab_mutex.
+	 */
 	mutex_lock(&amp;slab_mutex);
+	spin_lock(&amp;memcg_kmem_wq_lock);
 	s-&gt;memcg_params.dying = true;
+	spin_unlock(&amp;memcg_kmem_wq_lock);
</pre>
      </blockquote>
      <pre class="moz-quote-pre" wrap="">I would completely switch from the mutex to the new spin lock -
acquiring them both looks weird.

</pre>
      <blockquote type="cite" style="color: #000000;">
        <pre class="moz-quote-pre" wrap=""> 	mutex_unlock(&amp;slab_mutex);
 
 	/*
</pre>
      </blockquote>
    </blockquote>
    <p>There are places where the slab_mutex is held and sleeping
      functions like kvzalloc() are called. I understand that taking
      both mutex and spinlocks look ugly, but converting all the
      slab_mutex critical sections to spinlock critical sections will be
      a major undertaking by itself. So I would suggest leaving that for
      now.</p>
    <p>Cheers,<br>
      Longman<br>
    </p>
  </body>
</html>

--------------93207EDE24F79E4B4BD55885--

