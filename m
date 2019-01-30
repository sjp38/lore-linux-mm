Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A65EC282D8
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:38:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E670520869
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:38:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E670520869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BA498E0005; Wed, 30 Jan 2019 13:38:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9400E8E0001; Wed, 30 Jan 2019 13:38:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E17D8E0005; Wed, 30 Jan 2019 13:38:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 505078E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:38:06 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id f22so511295qkm.11
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:38:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=vxt2UPQQc+BUT1dpQTnJ0YmPM5DoDzLEMG2Lv1yDCOU=;
        b=Qc029qKlBCFkMVbnzC80gqMkTRhnIWjbDg9ACsztY8Z7Jcs4/Uuz9v2o7oOZRXJs+m
         uKrPp5Hft82/g8wlixfhQtmAq2b8nKxz+dAHpiyJuaK7mALXFYhuToXgRtt9D47mjyuj
         QOnczAMKPXEmKJnQFGnFt5XNMq+vVmiLzapif8wLpvYoqp0OLkOpu65+0V9jcuD5qZCn
         NckmWxdPGMNB471+sczUIW+Qci95hGu0SE3X9yLee/Ez8lXLlKl0DADJMnsWI2646rt5
         aAost+KLp6TnjDkSXXuyPqgW7JSn2a6Q3xyvNpVS2PI7oqGrQm8j9TOxCy7wKBgzKHUq
         hkJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukcepvaS1kZKRGhfUrHvzSILcxX415haPUVhPY+aQz3pNSAw7A1p
	jB9/lkHQZdjhDS5QwK4qe1wYVMyP/DFHuozB5ZyJrILVUCGWGoycqlXRP5nSAB2hqvBbvzsrFvL
	TEAy6vdVyE5YmgZukX6GLzeGY/vq2JuJC85tvxmx6ODLz//UXuCGbEO5dxebN8L4UkA==
X-Received: by 2002:a0c:81b5:: with SMTP id 50mr29592547qvd.166.1548873486109;
        Wed, 30 Jan 2019 10:38:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7dQD1ZkfCoFy+SFhV2JKwZ//t0Jcq5gR/UDn/l02oEbhIDXbVu1yyv6Pz/G3MLw5MnYeyr
X-Received: by 2002:a0c:81b5:: with SMTP id 50mr29592527qvd.166.1548873485715;
        Wed, 30 Jan 2019 10:38:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548873485; cv=none;
        d=google.com; s=arc-20160816;
        b=TR/i3jLJ4e/l/ZD9SmLBTQ0l0PjoDVDLoaHa4ceDhRsndSwh6SNkRXShda6vy4pBE2
         O5sufZcDo1nYfzA/S76xNFCzpUpm0zMV+bAurQaKN2N8iznPwmUVzfHV1kDa7TxKtpTD
         a9RkTVuwOOLENwzApLCyijOBQMcy7JrKIdbUYpmfmUDSGTrOLMWSVp6As7cYfTBxjCZy
         2FBioAvnHC2zjdwqcW1K712pwtdQKCM0CMgtubqH/7eFg5GJF0BeXMubt9zE/79zQ5m8
         Wl4wup41pr7cZhtFhfuqvlTo14RAhkCCU+K5UCW6twIOWy2P1H5xaKxcju4sQZyyfihY
         vnbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=vxt2UPQQc+BUT1dpQTnJ0YmPM5DoDzLEMG2Lv1yDCOU=;
        b=FLqYODYKl7zZYyawU9GgBI5eeS3xQ3K1qe26CsWs/DjkaOG6qvzCgDF2LJHT32E2P6
         gynKPSlGfKFRmZ6+WnmX+DrQK2ij15oC1kKIAmfns7GXckQlXMhv2aNn0UfjOcPSlJZU
         mMrTIBFBHxAIn+PAEwu01CxUn0fTA09sSqIOsNq6iTW5uPK4ud7vXNDF6aQhM1dvC2s0
         ky/ueMph8dJyFOGGkbUDmAp9BD1DLIC1zVsJAKjemq/i3vXWzF24M539gnwZgVenlGNU
         w3CbgkUTSGFvkdz4jPkppsropGIe6h1XRlpQE6ntVO6NI8TnIcJkDekxDC/ozMYzgO4A
         DCmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v4si96451qtq.23.2019.01.30.10.38.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 10:38:05 -0800 (PST)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A36CC89AC7;
	Wed, 30 Jan 2019 18:38:04 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-59.bos.redhat.com [10.18.17.59])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2FF54261A6;
	Wed, 30 Jan 2019 18:38:00 +0000 (UTC)
Subject: Re: [RESEND PATCH v4 0/3] fs/dcache: Track # of negative dentries
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
 Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM
 <linux-mm@kvack.org>, linux-doc@vger.kernel.org, mcgrof@kernel.org,
 Kees Cook <keescook@chromium.org>, Jan Kara <jack@suse.cz>,
 Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>,
 Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>,
 lwoodman@redhat.com, James Bottomley
 <James.Bottomley@hansenpartnership.com>, wangkai86@huawei.com,
 Michal Hocko <mhocko@kernel.org>
References: <1544824384-17668-1-git-send-email-longman@redhat.com>
 <CAHk-=wi-V7LjAAzFuxg+eLQAdp+Ay4WmVJdTNxgPjqKXaj-3Xw@mail.gmail.com>
 <0433488a-c8ad-e31a-6144-648e45478c07@redhat.com>
 <260e6cdb-42b7-1891-e525-54048d168b5c@redhat.com>
 <CAHk-=wi1raFRkRH1HEe_awy7HVy7XWxFRv9aZY-cgNL5zMqW4A@mail.gmail.com>
From: Waiman Long <longman@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=longman@redhat.com; prefer-encrypt=mutual; keydata=
 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
 weim8xU=
Organization: Red Hat
Message-ID: <70f895e7-b882-c821-a212-d1b5fe456261@redhat.com>
Date: Wed, 30 Jan 2019 13:37:59 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <CAHk-=wi1raFRkRH1HEe_awy7HVy7XWxFRv9aZY-cgNL5zMqW4A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Wed, 30 Jan 2019 18:38:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/30/2019 01:35 PM, Linus Torvalds wrote:
> On Wed, Jan 30, 2019 at 8:40 AM Waiman Long <longman@redhat.com> wrote:
>> Ping. Will this patch be picked up?
> Can you re-send the patch-set and I'll just apply it directly since it
> seems to be languishing otherwise.
>
>                 Linus

Sure.

Thanks for your help.

-Longman

