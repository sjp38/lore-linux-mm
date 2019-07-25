Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F18A4C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:26:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B244022CD4
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:26:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B244022CD4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 319FD8E000C; Thu, 25 Jul 2019 10:26:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C9DE8E0003; Thu, 25 Jul 2019 10:26:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 191868E000C; Thu, 25 Jul 2019 10:26:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E8B708E0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:25:59 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v4so42443091qkj.10
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:25:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=nyRex2jcekjMUD0qDDSF97miavYbe8l/Na9XGXfffcI=;
        b=nxquewHBpLj1WUk2IvxoMjLKXhR0Wsj0YyrSbvjUwWqjMRSCyOnH0Kklwv4GD6Baob
         IfX06z2+SoZMQ6mjul1qocD5LzxSfMxokGYa5k6Q0tcOSE2eeO2B+kO1sehXjQm1Z9zD
         GxsQdrQ4I8+lWrHAPxoiMpKKnbeAgdl5//Bi40PhxGTmVWL2O/QRE9WCqGUZRuGmUVD8
         djx/1QQ5Hp31Mty9HzqOHzHnykHvBpTpCo2kGBXrNPlE0aXdi/oOHXQ3MawsCY4ZXqbe
         sS4UlnxIIWEJ8ohFH9QG595DO66I9Vj+CqK1Uy16FZoMyfy6GA9+hE4WdcygrwS8s4Cv
         /qJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWe2LZE9Fcg6LM6ydwNvsLJuAeHKGh0SC85yB9TANXbeWv+UnYC
	c9KFFO7DryhYd9hBAraX13ho59sHo9LDMRqoroJNk8C45M6GENQjW64e/Ib9ipBEQjYRyumgiX7
	xKrdYK3t5LaGtVwjydmySn1Q++GaZezVFsePzafwbEtNgiRcdu7MyxxLOoOMxBb7aqQ==
X-Received: by 2002:a05:620a:1228:: with SMTP id v8mr14209442qkj.357.1564064759715;
        Thu, 25 Jul 2019 07:25:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxN/W7paAWbtmuGtuJGr6LCv5Tg6Ce+k2C6F5HQezF+ZDU9YtTlBxDlHzFQhdbhQahsTAZN
X-Received: by 2002:a05:620a:1228:: with SMTP id v8mr14209396qkj.357.1564064759159;
        Thu, 25 Jul 2019 07:25:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564064759; cv=none;
        d=google.com; s=arc-20160816;
        b=YemWdp0yzkGXEAw5Uon5PXSn3jYy4ofDTJvxouSt22mATrGnUTN40fwLtFeTZBSsdi
         fsYrfFKzl3Jx6anmpN/nFLqovW2pXzpiaKZ2Y/1b9a6+oGjKJU2k8ggYv8VirDtl27kq
         ulBF7zn01sQnw2wIjkn7a4HQVi/LixICVoDxV6JBJ5xE5Ll7ZRd8wS3d/jXLIYityC+e
         JX0H9e4zKxYirjc3fKI9q8rdp7qGQKC6SwqCbcSIZgPyWrGfM8ZrE+m3Es+Esl/jcQ2g
         gf3dfqYulWxyvgzodpzqpQkYXyk6MRYebrkEioS165BtNImsoQNI+ebIrPxGgy1FAqpX
         MhSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=nyRex2jcekjMUD0qDDSF97miavYbe8l/Na9XGXfffcI=;
        b=IURsNoKm+fmE22xISQsrrfFu9hHPbAICZ7ZZ/AL40eYkFfVLWdwcYBsVx+8EraKPOi
         CDOu7AV4hvMiAAX//8WjACYLvm0ttk0+Yy7o6rHKJWtnuBLJ3z//h+jX8qzqBDuhVVvO
         KbyeoyaSzfLPqW7IqQUFOG29gHNfODA/ydkodNtqZLE2hTTScJRFT8pfU9tbIZK523sg
         3Im6nJiYLNB4u2sOLnMq9fJ8eIigeM5ZisA4GrcPaiMURl9vxGIN6tba09TEQ9taZke8
         FNFhlCbbVf+OjOHQRhGVNkLviJOC+lrVHdNAyaIUAKBNMfnv37OqNZBZC+wDiO7H3ZXa
         zauw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j7si29691040qtb.118.2019.07.25.07.25.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 07:25:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0E40A335E8;
	Thu, 25 Jul 2019 14:25:58 +0000 (UTC)
Received: from [10.72.12.18] (ovpn-12-18.pek2.redhat.com [10.72.12.18])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 910435D71A;
	Thu, 25 Jul 2019 14:25:48 +0000 (UTC)
Subject: Re: WARNING in __mmdrop
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
References: <20190723032024-mutt-send-email-mst@kernel.org>
 <1d14de4d-0133-1614-9f64-3ded381de04e@redhat.com>
 <20190723035725-mutt-send-email-mst@kernel.org>
 <3f4178f1-0d71-e032-0f1f-802428ceca59@redhat.com>
 <20190723051828-mutt-send-email-mst@kernel.org>
 <caff362a-e208-3468-3688-63e1d093a9d3@redhat.com>
 <20190725012149-mutt-send-email-mst@kernel.org>
 <55e8930c-2695-365f-a07b-3ad169654d28@redhat.com>
 <20190725042651-mutt-send-email-mst@kernel.org>
 <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
 <20190725092332-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
Date: Thu, 25 Jul 2019 22:25:25 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190725092332-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 25 Jul 2019 14:25:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/25 下午9:26, Michael S. Tsirkin wrote:
>> Exactly, and that's the reason actually I use synchronize_rcu() there.
>>
>> So the concern is still the possible synchronize_expedited()?
> I think synchronize_srcu_expedited.
>
> synchronize_expedited sends lots of IPI and is bad for realtime VMs.
>
>> Can I do this
>> on through another series on top of the incoming V2?
>>
>> Thanks
>>
> The question is this: is this still a gain if we switch to the
> more expensive srcu? If yes then we can keep the feature on,


I think we only care about the cost on srcu_read_lock() which looks 
pretty tiny form my point of view. Which is basically a READ_ONCE() + 
WRITE_ONCE().

Of course I can benchmark to see the difference.


> if not we'll put it off until next release and think
> of better solutions. rcu->srcu is just a find and replace,
> don't see why we need to defer that. can be a separate patch
> for sure, but we need to know how well it works.


I think I get here, let me try to do that in V2 and let's see the numbers.

Thanks

