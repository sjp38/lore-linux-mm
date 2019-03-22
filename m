Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9758C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 18:12:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 953282192B
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 18:12:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 953282192B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 315C66B0005; Fri, 22 Mar 2019 14:12:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C6EC6B0006; Fri, 22 Mar 2019 14:12:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18F2C6B0007; Fri, 22 Mar 2019 14:12:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB2606B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 14:12:07 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id v2so2628693qkf.21
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 11:12:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=XD8n6goMt4dC4wuvECdvOn68p+Ulc2miP63u9K7A82M=;
        b=Y9fmafYPeDqKmqifKT7MN8aidc3Pd6riKYjK1bqgC1/sf/F6RQj+iB8GHT4d05sHAU
         6A1jCDaZm3W4W9mAUW9J6oH+ZWR9pAGAIjeazW8wWqnsRTYxULILuBuDMcZpWUxQCDAj
         DgiTZ1X3JWPoM7EZOZkPYWrXP35xes37OYwsWMdgabMaLCXW6I6pZ0H7wGGxoXHkDZhx
         cZcuMF5JmpFyJt34stMJlO6Vl8hZynwNYmNc95rGhtR1dTncRTNG8gUowL5yxuly0t3i
         RcoZYIe8ps1LZXrMNN+iQNg0t+PMUcR2AH4xws7BCh68VBOBYk1MoXTIuwQY/82keUkz
         m6Lg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVOqWscOSV+izGT45LdrxWlItF7cF6G37VSNkhlJ37Qa4vmavWI
	5gPnGaiMR5KUrvTgntp2uRC0x3XLS0vqKC55VXxtBNaIZvEq4J3/3Xp8m201NyS5t4McOQRiyBe
	rUquRQ3sy6URCJmiIfMiHpKdxsHrKr3IYm0ylIOYPw3MeI6b9kUQ3h3pAFuehpv/zMA==
X-Received: by 2002:a37:ae04:: with SMTP id x4mr8656174qke.339.1553278327646;
        Fri, 22 Mar 2019 11:12:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhXXF+FhG0YdoHYNMzCYUxSUefeVLy/iZ+uCF++2IRgeQiN7a96HEMcgUMig31Wvi0GHnb
X-Received: by 2002:a37:ae04:: with SMTP id x4mr8656122qke.339.1553278327011;
        Fri, 22 Mar 2019 11:12:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553278327; cv=none;
        d=google.com; s=arc-20160816;
        b=urePVoIh1rzKdnyFNl5t1JmeJdjND8n7Wiwx8xd/un33XS4ZjkIo9Ph/F5/8Xcel2m
         0K1k2Tw8J+duSZe9sUx5vHyCG6rxs0b9KaFhgtg+IH9fIk9OTJWUwj5SV83vrgY4uRzc
         hUBfoaRCJn4vzfqYHBns7tdZ7EU2abCmABhPt6fG7suCrCToJXFCZN8dJtvhaGCLp4vv
         p8WOfl6U41EqCpWqqqSfMv47aQvQ0unE7fXHVHyooudL3A/3fnq0uxnROSgr6fyyuyzp
         qH2S0gAOOX3Rog2Q8dBfSEz5s0olvQ3ZaiDIx5WtoFjghQKvHoU8SiRftPhLyqkiZdxr
         P2YQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=XD8n6goMt4dC4wuvECdvOn68p+Ulc2miP63u9K7A82M=;
        b=zF7YSbz6bASIwF/9wt9vsCeGynSdoVjN2lXnQboJ1ClusVvwKZWJEKygjLUAfnXwRV
         wooerOHfKLtDmv7u4410d59rtj0hQnkR9qSEPZoge/dWv+GXlFID7h9LTUNX7Ht/muDd
         hgR/vMWB8PRY50GqDz8XpbdxOMzt8meiMpAQ+q6AliQ0Meh6Z2AalQtv3adu/IZEM1Vi
         GLmYnTn7o/33hd2N8a57c+/jhYhy54GKLgCb5KHWetpm+37Akyt5Tt6sfBNtVjxo9ScO
         R1eaSuKA+7UioWFHFmXyznkWHbruQr0hnXunPyDFxJ4woRQ8vBuT/NQJyzFGGSziIsDy
         MiMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r25si2434869qvc.91.2019.03.22.11.12.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 11:12:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F30753084024;
	Fri, 22 Mar 2019 18:12:05 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-47.bos.redhat.com [10.18.17.47])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AB6E560142;
	Fri, 22 Mar 2019 18:12:01 +0000 (UTC)
Subject: Re: [PATCH 2/4] signal: Make flush_sigqueue() use free_q to release
 memory
To: Christopher Lameter <cl@linux.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Matthew Wilcox <willy@infradead.org>,
 Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg
 <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, selinux@vger.kernel.org, Paul Moore
 <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>,
 Eric Paris <eparis@parisplace.org>,
 "Peter Zijlstra (Intel)" <peterz@infradead.org>
References: <20190321214512.11524-1-longman@redhat.com>
 <20190321214512.11524-3-longman@redhat.com>
 <20190322015208.GD19508@bombadil.infradead.org>
 <20190322111642.GA28876@redhat.com>
 <d9e02cc4-3162-57b0-7924-9642aecb8f49@redhat.com>
 <01000169a686689d-bc18fecd-95e1-4b3e-8cd5-dad1b1c570cc-000000@email.amazonses.com>
From: Waiman Long <longman@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=longman@redhat.com; prefer-encrypt=mutual; keydata=
 xsFNBFgsZGsBEAC3l/RVYISY3M0SznCZOv8aWc/bsAgif1H8h0WPDrHnwt1jfFTB26EzhRea
 XQKAJiZbjnTotxXq1JVaWxJcNJL7crruYeFdv7WUJqJzFgHnNM/upZuGsDIJHyqBHWK5X9ZO
 jRyfqV/i3Ll7VIZobcRLbTfEJgyLTAHn2Ipcpt8mRg2cck2sC9+RMi45Epweu7pKjfrF8JUY
 r71uif2ThpN8vGpn+FKbERFt4hW2dV/3awVckxxHXNrQYIB3I/G6mUdEZ9yrVrAfLw5M3fVU
 CRnC6fbroC6/ztD40lyTQWbCqGERVEwHFYYoxrcGa8AzMXN9CN7bleHmKZrGxDFWbg4877zX
 0YaLRypme4K0ULbnNVRQcSZ9UalTvAzjpyWnlnXCLnFjzhV7qsjozloLTkZjyHimSc3yllH7
 VvP/lGHnqUk7xDymgRHNNn0wWPuOpR97J/r7V1mSMZlni/FVTQTRu87aQRYu3nKhcNJ47TGY
 evz/U0ltaZEU41t7WGBnC7RlxYtdXziEn5fC8b1JfqiP0OJVQfdIMVIbEw1turVouTovUA39
 Qqa6Pd1oYTw+Bdm1tkx7di73qB3x4pJoC8ZRfEmPqSpmu42sijWSBUgYJwsziTW2SBi4hRjU
 h/Tm0NuU1/R1bgv/EzoXjgOM4ZlSu6Pv7ICpELdWSrvkXJIuIwARAQABzR9Mb25nbWFuIExv
 bmcgPGxsb25nQHJlZGhhdC5jb20+wsF/BBMBAgApBQJYLGRrAhsjBQkJZgGABwsJCAcDAgEG
 FQgCCQoLBBYCAwECHgECF4AACgkQbjBXZE7vHeYwBA//ZYxi4I/4KVrqc6oodVfwPnOVxvyY
 oKZGPXZXAa3swtPGmRFc8kGyIMZpVTqGJYGD9ZDezxpWIkVQDnKM9zw/qGarUVKzElGHcuFN
 ddtwX64yxDhA+3Og8MTy8+8ZucM4oNsbM9Dx171bFnHjWSka8o6qhK5siBAf9WXcPNogUk4S
 fMNYKxexcUayv750GK5E8RouG0DrjtIMYVJwu+p3X1bRHHDoieVfE1i380YydPd7mXa7FrRl
 7unTlrxUyJSiBc83HgKCdFC8+ggmRVisbs+1clMsK++ehz08dmGlbQD8Fv2VK5KR2+QXYLU0
 rRQjXk/gJ8wcMasuUcywnj8dqqO3kIS1EfshrfR/xCNSREcv2fwHvfJjprpoE9tiL1qP7Jrq
 4tUYazErOEQJcE8Qm3fioh40w8YrGGYEGNA4do/jaHXm1iB9rShXE2jnmy3ttdAh3M8W2OMK
 4B/Rlr+Awr2NlVdvEF7iL70kO+aZeOu20Lq6mx4Kvq/WyjZg8g+vYGCExZ7sd8xpncBSl7b3
 99AIyT55HaJjrs5F3Rl8dAklaDyzXviwcxs+gSYvRCr6AMzevmfWbAILN9i1ZkfbnqVdpaag
 QmWlmPuKzqKhJP+OMYSgYnpd/vu5FBbc+eXpuhydKqtUVOWjtp5hAERNnSpD87i1TilshFQm
 TFxHDzbOwU0EWCxkawEQALAcdzzKsZbcdSi1kgjfce9AMjyxkkZxcGc6Rhwvt78d66qIFK9D
 Y9wfcZBpuFY/AcKEqjTo4FZ5LCa7/dXNwOXOdB1Jfp54OFUqiYUJFymFKInHQYlmoES9EJEU
 yy+2ipzy5yGbLh3ZqAXyZCTmUKBU7oz/waN7ynEP0S0DqdWgJnpEiFjFN4/ovf9uveUnjzB6
 lzd0BDckLU4dL7aqe2ROIHyG3zaBMuPo66pN3njEr7IcyAL6aK/IyRrwLXoxLMQW7YQmFPSw
 drATP3WO0x8UGaXlGMVcaeUBMJlqTyN4Swr2BbqBcEGAMPjFCm6MjAPv68h5hEoB9zvIg+fq
 M1/Gs4D8H8kUjOEOYtmVQ5RZQschPJle95BzNwE3Y48ZH5zewgU7ByVJKSgJ9HDhwX8Ryuia
 79r86qZeFjXOUXZjjWdFDKl5vaiRbNWCpuSG1R1Tm8o/rd2NZ6l8LgcK9UcpWorrPknbE/pm
 MUeZ2d3ss5G5Vbb0bYVFRtYQiCCfHAQHO6uNtA9IztkuMpMRQDUiDoApHwYUY5Dqasu4ZDJk
 bZ8lC6qc2NXauOWMDw43z9He7k6LnYm/evcD+0+YebxNsorEiWDgIW8Q/E+h6RMS9kW3Rv1N
 qd2nFfiC8+p9I/KLcbV33tMhF1+dOgyiL4bcYeR351pnyXBPA66ldNWvABEBAAHCwWUEGAEC
 AA8FAlgsZGsCGwwFCQlmAYAACgkQbjBXZE7vHeYxSQ/+PnnPrOkKHDHQew8Pq9w2RAOO8gMg
 9Ty4L54CsTf21Mqc6GXj6LN3WbQta7CVA0bKeq0+WnmsZ9jkTNh8lJp0/RnZkSUsDT9Tza9r
 GB0svZnBJMFJgSMfmwa3cBttCh+vqDV3ZIVSG54nPmGfUQMFPlDHccjWIvTvyY3a9SLeamaR
 jOGye8MQAlAD40fTWK2no6L1b8abGtziTkNh68zfu3wjQkXk4kA4zHroE61PpS3oMD4AyI9L
 7A4Zv0Cvs2MhYQ4Qbbmafr+NOhzuunm5CoaRi+762+c508TqgRqH8W1htZCzab0pXHRfywtv
 0P+BMT7vN2uMBdhr8c0b/hoGqBTenOmFt71tAyyGcPgI3f7DUxy+cv3GzenWjrvf3uFpxYx4
 yFQkUcu06wa61nCdxXU/BWFItryAGGdh2fFXnIYP8NZfdA+zmpymJXDQeMsAEHS0BLTVQ3+M
 7W5Ak8p9V+bFMtteBgoM23bskH6mgOAw6Cj/USW4cAJ8b++9zE0/4Bv4iaY5bcsL+h7TqQBH
 Lk1eByJeVooUa/mqa2UdVJalc8B9NrAnLiyRsg72Nurwzvknv7anSgIkL+doXDaG21DgCYTD
 wGA5uquIgb8p3/ENgYpDPrsZ72CxVC2NEJjJwwnRBStjJOGQX4lV1uhN1XsZjBbRHdKF2W9g
 weim8xU=
Organization: Red Hat
Message-ID: <93523469-48b0-07c8-54fd-300678af3163@redhat.com>
Date: Fri, 22 Mar 2019 14:12:01 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <01000169a686689d-bc18fecd-95e1-4b3e-8cd5-dad1b1c570cc-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Fri, 22 Mar 2019 18:12:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/22/2019 01:50 PM, Christopher Lameter wrote:
> On Fri, 22 Mar 2019, Waiman Long wrote:
>
>> I am looking forward to it.
> There is also alrady rcu being used in these paths. kfree_rcu() would n=
ot
> be enough? It is an estalished mechanism that is mature and well
> understood.
>
In this case, the memory objects are from kmem caches, so they can't
freed using kfree_rcu().

There are certainly overhead using the kfree_rcu(), or a
kfree_rcu()-like mechanism. Also I think the actual freeing is done at
SoftIRQ context which can be a problem if there are too many memory
objects to free.

I think what Oleg is trying to do is probably the most efficient way.

Cheers,
Longman


