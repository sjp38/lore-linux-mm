Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06556C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 09:11:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C27E32080C
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 09:11:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C27E32080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6469B6B000A; Tue, 30 Apr 2019 05:11:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F7436B000C; Tue, 30 Apr 2019 05:11:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E6156B000D; Tue, 30 Apr 2019 05:11:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0938E6B000A
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 05:11:44 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id m11so138531ljj.6
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 02:11:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=KTe3MPBcj9GYqzqNE1xWLm88jBqBFR7Ze5yRMgNlbMQ=;
        b=VHeqZ+9coDVhnazg5B7rCMeQ3N2n1FCKqdnqVN5XVtvUL1Dj7zDm429NlYCISU/Ug8
         XnsG4h4E+fgnZYkQKK6j1S9trD6NDqhIdnd8HmySN/zUuceAbJZh5M3J+tl2LW4I6fOS
         30Kcw2GN/GS0yTcgbezjL6odzT+8GJhnNuLDRnwhQh3q9/CcOjbJPmPPQuartr/j7hUf
         OhY3n7saEa4qoxuYn0m09LaTC1AtUSm5gNaspeo4KYS9vqV1L9dJmJXS3nn6NFSkcfWX
         6EWgkPcAsxcmpBxqxQoFDerdnuwPXOErEZ2PPG7XTxHR1v1S2SE2dLAOCT68MwUYwL7W
         +5OA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXYthWNpTNsbexJBtO7lm8qeR6zTgMXgb6PNeJpHXAXi/dL1En6
	cQTMclioDnrbekBQorIebz7uXEojxQi2srpMjPhiuYL50n7xcm0gJkzdo8nlDVJhfmbMxATG5CC
	XQ3fAslchTZxV50euJpTHSfCWZzIgQ5q25b+EuFJu2ftN/NSWDaVC74lUzYa+EQSNzQ==
X-Received: by 2002:a2e:2b8c:: with SMTP id r12mr7121455ljr.115.1556615503450;
        Tue, 30 Apr 2019 02:11:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyCXyzOquEdfT0TZb6wMlZp0eXlZv4RP2/juv9DexvVBlbUFUm0i6CygObnHfJfAwqt/Cm
X-Received: by 2002:a2e:2b8c:: with SMTP id r12mr7121418ljr.115.1556615502760;
        Tue, 30 Apr 2019 02:11:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556615502; cv=none;
        d=google.com; s=arc-20160816;
        b=IMT5Acp9l6VnIAxbKbknpR+n3x03GcNBHwsEfiUuRxl7C0uyK6xQNaMg8FTGStfDlM
         YhbkJWVx7iYSZ0KUaqlR2kmEmFG7xH5Vv25RDZMqTEPzdUjC+AStucdHuv929wF14/X3
         jjOccMOAYd2McX+A3QBPKPQtUvoFdJK9uoIn2d57bhphycEkECmo77sLpPzjaUYxirof
         q7UyTu978BTiHjIJIcsosfYA6023A8fHAB+TuaIg1u3Cheq6dOi5gzC3pnx2E5rQiU+A
         oJiiW2CnvPH6eLJ1KucjP7/syCYxf2+CC9hN0zMinWQfFfyqIJUtspv56qlmaS97WEk4
         CnfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=KTe3MPBcj9GYqzqNE1xWLm88jBqBFR7Ze5yRMgNlbMQ=;
        b=GrT4smTPZ/zSrBlsoBuU7DslLeMX9XScVHledYhjEeSRoVD+5ZZiapDM2VNxJO0MOW
         d1TJqlZkQEE+0HoeLbqeAM7g9H+IlUZz5EjvkNJqfKuudADRpVhRNhE8fK/K1Cod5L4w
         CjeJUqpOSLwvkhZabLlJwJMxtfrsF5uSGqIQHns0hcexmF0BZZ9crcezhPunt/Xy23ST
         0Qw7rUwma/YH8b96tEikBZdFOkaB52R8pyAAqqaU/V5KVWcWhpALYnvMA0YVKdmjVKpd
         6vlJXKV4KQN8IV/5Xrv+oKUkwWTqHWrK/KO3n1PDMe9/Cajrpr6zhfqpz9IPVBsyc/HY
         HosA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id t9si6554569ljj.93.2019.04.30.02.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 02:11:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hLOnZ-0007Uk-Vy; Tue, 30 Apr 2019 12:11:38 +0300
Subject: Re: [PATCH 3/3] prctl_set_mm: downgrade mmap_sem to read lock
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>,
 akpm@linux-foundation.org, arunks@codeaurora.org, brgl@bgdev.pl,
 geert+renesas@glider.be, ldufour@linux.ibm.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, mguzik@redhat.com,
 mhocko@kernel.org, rppt@linux.ibm.com, vbabka@suse.cz
References: <20190418182321.GJ3040@uranus.lan>
 <20190430081844.22597-1-mkoutny@suse.com>
 <20190430081844.22597-4-mkoutny@suse.com>
 <af8f7958-06aa-7134-c750-b7a994368e89@virtuozzo.com>
 <20190430090808.GC2673@uranus.lan>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <0a48e0a2-a282-159e-a56e-201fbc0faa91@virtuozzo.com>
Date: Tue, 30 Apr 2019 12:11:37 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190430090808.GC2673@uranus.lan>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 30.04.2019 12:08, Cyrill Gorcunov wrote:
> On Tue, Apr 30, 2019 at 11:55:45AM +0300, Kirill Tkhai wrote:
>>> -	up_write(&mm->mmap_sem);
>>> +	spin_unlock(&mm->arg_lock);
>>> +	up_read(&mm->mmap_sem);
>>>  	return error;
>>
>> Hm, shouldn't spin_lock()/spin_unlock() pair go as a fixup to existing code
>> in a separate patch? 
>>
>> Without them, the existing code has a problem at least in get_mm_cmdline().
> 
> Seems reasonable to merge it into patch 1.

Sounds sensibly.

