Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C712C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 08:04:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08CFD206A2
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 08:03:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08CFD206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FF0A8E0003; Tue, 30 Jul 2019 04:03:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B0858E0001; Tue, 30 Jul 2019 04:03:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69F5D8E0003; Tue, 30 Jul 2019 04:03:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6CF8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 04:03:59 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id l9so57505244qtu.12
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:03:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=x6RPycPoRAsF1VkEPpu353GKcUnEMUI9BSmZo5qOVlU=;
        b=gs4GTaQeZdLXcIdXWXUOwTsDwUU8mv0VRbcTgU9Qg3E6eI0O0lM/g2PJ4GrgexXeK9
         hTCU/1CcHHQCtp5Y0wDp9jGsdWpKPYGhTmGwVajDEbv3QVJ+AhKzciYwTgnlNaCV505m
         OEf8VF+wHMgdsSniHcnLaqOZXMIrfC3QSON5G0mmFANgpsqta6Ppv2vceuIVAoNfCJGV
         HC6XkRF0gnih8g7DkCtFbPEMub5Rtjxz4ZEU/DN5W8vMQQlYYZ7B114jjhfwJqIkOsma
         IL1odJ9W4/fhcaQTJbn54lDfG6NSj7nAthril+1GWzx7dZPL5LryGQEC3rmI4IrS0jlR
         0ZVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV1C70R9zhesJfpM7RwZ9E9FU40XG34Y4oZDXOaKKninIJafOSq
	EOjGZ1JxMOQx2lMl3Kf4J1vfvXf7ZDEQD/Sf3PCX25wr//kd4++BU46ikCjeGcK28s2Z1JCEHvY
	IyaWwG4xc9UqMSeWd8dMW+TyfL6GpCykUzwrUYq8r6jUvQ2MKDOtJq/UU+bCmm1+k0w==
X-Received: by 2002:a37:afc3:: with SMTP id y186mr74935098qke.115.1564473839046;
        Tue, 30 Jul 2019 01:03:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBMzZCavPxI1SyHTlU+zpAI3GA9bdUoKZcD01jYlI3PLERi7KR7VO11BJkpPPZ4fN425h6
X-Received: by 2002:a37:afc3:: with SMTP id y186mr74935070qke.115.1564473838467;
        Tue, 30 Jul 2019 01:03:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564473838; cv=none;
        d=google.com; s=arc-20160816;
        b=quATZuxzCyLoY3FUGjGpvCfklVwGuulfnbeibXtVLJNU3RopEBDlEG/2PsTj1XX/Kp
         hdu3FIegXkge4f1nd5KNfwtEFjGzxU4JAo2GjF9y4pZhOKZ+dSvlKt6ctzcobstQCJHV
         TmcC2x0EMIy4pnIl2K+RH5933smMHTMvsrAYbUbhzdH4MPSqKTxf9uw4aaF+GD8x1fJ8
         Ws1K/vcbN26bZZXcvRcb/TIpU14HLdUCbM9ZuO3ZvuojM9PQebxCOJd8Fi6asS4V9J7T
         Bul1EeUKfwN+ZQoYGcFy4cTmbr2Kb8Raczyj15IX/wBIq9JnaAg6tLdXZNdTCY5c4/w+
         IG0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=x6RPycPoRAsF1VkEPpu353GKcUnEMUI9BSmZo5qOVlU=;
        b=gSItm7SZXmi32bvsEF4Z1QDwUfx95ZnNk5nw0NECY9COD86ElWLiyti1rUAw6VfLkv
         LYfkLiF47T1rEanVisoehrHM//rBThYtMzux6CkznUhCNAUt2obBVTVdse4uWPlt4AT+
         R9vz4jL65/fP12d4iVXaydPJOY63I8MZKrBC+fVIGqtMi1t+Z960ZqogFprJO/DNz2oG
         5ZmOWoHvxud4BMyaXKlv4/AIUMaQ1Djv8kml9edKBQzQAfMDlL2NBbpmjroUxG7JA42o
         vZ03J7hVBuMGhibApiK2+a9fz3ebRyo+JAVmpWlknKXdQaSmD3ZR2ADtq12GsIOo0PkY
         KsWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 124si201767qkh.244.2019.07.30.01.03.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 01:03:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5026330C5843;
	Tue, 30 Jul 2019 08:03:57 +0000 (UTC)
Received: from [10.72.12.185] (ovpn-12-185.pek2.redhat.com [10.72.12.185])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D89B65D6A5;
	Tue, 30 Jul 2019 08:03:46 +0000 (UTC)
Subject: Re: WARNING in __mmdrop
From: Jason Wang <jasowang@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
 aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io,
 davem@davemloft.net, ebiederm@xmission.com, elena.reshetova@intel.com,
 guro@fb.com, hch@infradead.org, james.bottomley@hansenpartnership.com,
 jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-parisc@vger.kernel.org, luto@amacapital.net,
 mhocko@suse.com, mingo@kernel.org, namit@vmware.com, peterz@infradead.org,
 syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, wad@chromium.org
References: <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
 <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
 <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
 <aaefa93e-a0de-1c55-feb0-509c87aae1f3@redhat.com>
 <20190726094756-mutt-send-email-mst@kernel.org>
 <0792ee09-b4b7-673c-2251-e5e0ce0fbe32@redhat.com>
 <20190729045127-mutt-send-email-mst@kernel.org>
 <4d43c094-44ed-dbac-b863-48fc3d754378@redhat.com>
 <20190729104028-mutt-send-email-mst@kernel.org>
 <96b1d67c-3a8d-1224-e9f0-5f7725a3dc10@redhat.com>
Message-ID: <fc4cf42d-ea06-f405-b3ff-0579cf67e4ec@redhat.com>
Date: Tue, 30 Jul 2019 16:03:45 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <96b1d67c-3a8d-1224-e9f0-5f7725a3dc10@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Tue, 30 Jul 2019 08:03:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/30 下午3:44, Jason Wang wrote:
>>>
>>> }
>> Looks good but I'd like to think of a strategy/existing lock that let us
>> block properly as opposed to spinning, that would be more friendly to
>> e.g. the realtime patch.
>
>
> Does it make sense to disable preemption in the critical section? Then 
> we don't need to block and we have a deterministic time spent on 
> memory accssors?


Ok, touching preempt counter seems a little bit expensive in the fast 
path. Will try for blocking.

Thanks

