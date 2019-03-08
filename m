Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF4FFC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 08:31:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A55020811
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 08:31:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A55020811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58CB68E0004; Fri,  8 Mar 2019 03:31:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53AD58E0002; Fri,  8 Mar 2019 03:31:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 450688E0004; Fri,  8 Mar 2019 03:31:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 196FB8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 03:31:41 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id t13so3646392qkm.2
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 00:31:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=LDLvu3bgPlLprKlle7wIEeDM1lyxWYMbYNm7tRx0nR4=;
        b=c+FJ/ZGorQFZhhdRF9mQCR4rEdIODtoXmO06l7e5XuC7FK5zL0QcsYA02DYX6mHVM+
         +kG0SZKv2cFv7O3llwUJRhd5RZJyrlya7d0zSAjDqqPLzgQK3aBwC9KKhjBozNeVjEVl
         ynMHUpoM2SDjfISyG4vi+LU568MKi1o3CR+wMbgYf+3biLCSEAlNbfa8nHibg7dp152x
         FCcqrpK9Sd+W7l7TN6Au4bBAb92+NVtIQ7/SCEqcQiR4rlCCrP4Zhxxpqcvq1zesZi5x
         071MagYZVgj1RGZGzOzkk4QEpKj4z9zgvJKn5mqTzeI6SQlH2RuaLYzetio3f4U1sW+g
         pyZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX0z+x1knoozLLUrLpe13bGAnQZXkKplwO5d+YM/zJt5L81s9M9
	zBGdZ+hU6nS985AP+NmHkP6zWaX3oyiMdDRhRYMxOT6LPaw0tsXfLx930diwrhiUn+WGsTDxHzh
	SS0goJ5Wqjv2UmdzD0T5zzHBtUkRXXWBX5ddh3kyF7V/dDNEuLbyW9Zy/9PXlZDUh3g==
X-Received: by 2002:a0c:d1a7:: with SMTP id e36mr14360790qvh.127.1552033900717;
        Fri, 08 Mar 2019 00:31:40 -0800 (PST)
X-Google-Smtp-Source: APXvYqyvsDUjcvN7J2daJBrlQlH/xUc/T4Uj3pmbJ5CuoIy03MMuwJrWupQoMqA7Ab02vriodA42
X-Received: by 2002:a0c:d1a7:: with SMTP id e36mr14360748qvh.127.1552033899859;
        Fri, 08 Mar 2019 00:31:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552033899; cv=none;
        d=google.com; s=arc-20160816;
        b=0WLircjdaUqnLNzRhOkepK5RiRxABeGC4eUppkd7IJOkVI1V83GCnJzd/wahEvAOAN
         cd2Z7Q2F9zstqTK9Vf9CEaXrwxRRA84juEJwXwVX0tNKN9n0Baduew2gWG+F+1QnTIXA
         IfuJsbUwzC/N69dqMA4ZBPdl9TnuK4Bzy6UcXIHVB6jBbtiJvNynsKt5kl84ArJe+EXL
         et3dN6sTOYaGzPY6fDOFVJsY6HYxwftWX+kL3GUzedHfQRJnGTP7PcIZH2JhJ5Jwe1Tw
         hst0Of+m5Ivu62lRpTP9qGmef6oc/IPNT6yeGZBCB1xayl75AY+zeuvFGkMdlvHuqVhz
         17VA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=LDLvu3bgPlLprKlle7wIEeDM1lyxWYMbYNm7tRx0nR4=;
        b=PhKonK4qwhEOJvNlwNEcooAYjMG3VIXo6ASqV6Guo2yqbZeWSB4IYl6QgxA+EeTfE5
         13VaTacB/gaJBt3/bzcyyQCie2uy4OjE0MbB40v+51zUNTMbRocIVl0KQAHben4s2jKA
         Tb0fr87HPdJJUbe/luZh7Y34XhZKY2ovvr/3X6LZe7gaxkq0Ym6791q30fp/dAdB6mLM
         g08/Ud77dhQzpnku3mTaR4Rzx8TSkPzl4nVS8mz9TeEofB+tJTv1c67I/LJgzO15UBDw
         VhtaETakLnDOKov6xYdW9DVtFbcSeCmtnTyZI8WrpBppu6U/MDA3uKoVfjz/VYWCGdWh
         wr7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l81si2119455qke.236.2019.03.08.00.31.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 00:31:39 -0800 (PST)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E0B2310C6C;
	Fri,  8 Mar 2019 08:31:38 +0000 (UTC)
Received: from [10.72.12.27] (ovpn-12-27.pek2.redhat.com [10.72.12.27])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C3731611D1;
	Fri,  8 Mar 2019 08:31:31 +0000 (UTC)
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, peterx@redhat.com,
 linux-mm@kvack.org, aarcange@redhat.com
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190306092837-mutt-send-email-mst@kernel.org>
 <15105894-4ec1-1ed0-1976-7b68ed9eeeda@redhat.com>
 <20190307101708-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <92dfa6cc-a86c-0cef-6384-98aeb8b9e567@redhat.com>
Date: Fri, 8 Mar 2019 16:31:29 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190307101708-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 08 Mar 2019 08:31:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/7 下午11:34, Michael S. Tsirkin wrote:
> On Thu, Mar 07, 2019 at 10:45:57AM +0800, Jason Wang wrote:
>> On 2019/3/7 上午12:31, Michael S. Tsirkin wrote:
>>>> +static void vhost_set_vmap_dirty(struct vhost_vmap *used)
>>>> +{
>>>> +	int i;
>>>> +
>>>> +	for (i = 0; i < used->npages; i++)
>>>> +		set_page_dirty_lock(used->pages[i]);
>>> This seems to rely on page lock to mark page dirty.
>>>
>>> Could it happen that page writeback will check the
>>> page, find it clean, and then you mark it dirty and then
>>> invalidate callback is called?
>>>
>>>
>> Yes. But does this break anything?
>> The page is still there, we just remove a
>> kernel mapping to it.
>>
>> Thanks
> Yes it's the same problem as e.g. RDMA:
> 	we've just marked the page as dirty without having buffers.
> 	Eventually writeback will find it and filesystem will complain...
> 	So if the pages are backed by a non-RAM-based filesystem, it’s all just broken.


Yes, we can't depend on the pages that might have been invalidated. As 
suggested, the only suitable place is the MMU notifier callbacks.

Thanks


> one can hope that RDMA guys will fix it in some way eventually.
> For now, maybe add a flag in e.g. VMA that says that there's no
> writeback so it's safe to mark page dirty at any point?
>
>
>
>
>

