Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 053E5C282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 07:05:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1A9420857
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 07:05:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1A9420857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E66A6B0008; Tue,  9 Apr 2019 03:05:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4972A6B000C; Tue,  9 Apr 2019 03:05:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 339376B000D; Tue,  9 Apr 2019 03:05:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 128856B0008
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 03:05:32 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d139so13762669qke.20
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 00:05:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=I6+MdslU3EkJ4tsZVZTvXKUXn46wzotr+UL+V4Rkt1I=;
        b=sjxG598HE0/MP6F2MmuSMt2QzWIUtc3YQnLRt1CohinMSjHlqIQrrfgo5tuED5ADYr
         U4w/MQMAQr9Lk/b/nYU/kzWuJd7lK9fOImh/zLhjqUpmyIZ0TgaKyGJcsEEgBgFOBARe
         efzWc3FkmGlPg1olky5uk72CH2fZBlAUn5Jh4xEhmbGpyjysmxZI6IxJQodC7G8YXI4I
         qGYOX2O8WeTpA0a95SVP8j2J/i3otdq4RBbZj2eabJPHV9QBJ1Hx7m19cU1FfbnEa7+D
         ZiAWt3WQHBRrNzZkfRxcJHqdHm1yjUkd++GjsIAetBDlBUan7GyPKlh99bWwSayDmDx3
         XXtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWOv/9MGDz35Wn/QVp/yVnSRUTPlSB9Ueld89mmJm2X+WFY0t9E
	SXO3DbeBEt2HLSvFyu1EJlm0H/VMpZrt0IXoghwg1ccbAgmqq9cm27oMKJtKGSTajQttn6v392t
	6/hT/M+47CMhzt3MhkyCQB6M5kacOTTsjBrR0WzpkNKOPmleM+dczkTrmoCe2lr3ETw==
X-Received: by 2002:a0c:d28f:: with SMTP id q15mr27730888qvh.185.1554793531857;
        Tue, 09 Apr 2019 00:05:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9OyYnV+eJ0VLiKTU4E0j6usu14vgsXIkXu64RuQutRJEZQypEKBOBZKPuRTSOFZjkD2Dn
X-Received: by 2002:a0c:d28f:: with SMTP id q15mr27730835qvh.185.1554793531097;
        Tue, 09 Apr 2019 00:05:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554793531; cv=none;
        d=google.com; s=arc-20160816;
        b=yWj8fn8hyh5jsADWKbsscxvt8DdQc/x1U8eOuI5bbEug0p1FPc/JW4G+CamxYpdX9o
         Gi/xghnkPL11fXDmUkxUy7gKDkN4i24FYg/qTo0xTrIISSa6dP2q0pR6wbjDwpMQqHcf
         0lWSEzTRFb07aLCdyQ1UF2M0ppwj1noYQOrdAzXBcJQkTmjgC3WZrlMWN9CSMVjIXOKF
         mwEW+5ZZgFKkpe8N777xRaBxg/YVEcoGel7cE1Yv2Wpao1M02/t0OpwmE4qJEbWVZmQW
         jZIdlt+MXt2GhucCeQ4gQffDsYStqWtafbUXFAFly3Zb1YmkBI5MVYZMKE/rzfXazmoT
         Lf7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=I6+MdslU3EkJ4tsZVZTvXKUXn46wzotr+UL+V4Rkt1I=;
        b=BLS43eBoqstjtsKw8QEam5swH4Ppl96bxN8Hgutlj9voYsdX7JbCE/d8r/XIdoIXIZ
         fr9t8IydQ+etHQpb3/wJaiKGSV8HHDnC7mhPd1geh+hskpGk7As8YhlRi20voFu5HtrD
         +5oPRuJSRPiRBiq69WUprOgflnhdTcBYHMWirR8fHa5Zh3/yO4IivWjNSH9MUREdFg2+
         Jk87qiCtstCZhYRIXMI/T7DcgNlYHoM4K7+UPDRw6JyG6IJsSkS6JRbTq8zIGsHOZCPC
         r/hIy4/5akEn+pxuI1RDDDuHc0LmiBlKDA4bZ83CEdYCRcNJy3fKzS7ceqrO2eDShTuh
         D9kQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v91si2976785qte.315.2019.04.09.00.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 00:05:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 11D85C04D943;
	Tue,  9 Apr 2019 07:05:30 +0000 (UTC)
Received: from [10.36.117.49] (ovpn-117-49.ams2.redhat.com [10.36.117.49])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E109110A1822;
	Tue,  9 Apr 2019 07:05:16 +0000 (UTC)
Subject: Re: Thoughts on simple scanner approach for free page hinting
To: "Michael S. Tsirkin" <mst@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
 <20190408203541-mutt-send-email-mst@kernel.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <ba84ec1f-79f2-e15b-e225-7d2e2885a4c6@redhat.com>
Date: Tue, 9 Apr 2019 09:05:16 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190408203541-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 09 Apr 2019 07:05:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09.04.19 04:44, Michael S. Tsirkin wrote:
> On Fri, Apr 05, 2019 at 05:09:45PM -0700, Alexander Duyck wrote:
>> In addition we will need some way to identify which pages have been
>> hinted on and which have not. The way I believe easiest to do this
>> would be to overload the PageType value so that we could essentially
>> have two values for "Buddy" pages. We would have our standard "Buddy"
>> pages, and "Buddy" pages that also have the "Offline" value set in the
>> PageType field. Tracking the Online vs Offline pages this way would
>> actually allow us to do this with almost no overhead as the mapcount
>> value is already being reset to clear the "Buddy" flag so adding a
>> "Offline" flag to this clearing should come at no additional cost.
> 
> It bothers me a bit that this doesn't scale to multiple hint types
> if we ever need them. Would it be better to have two
> free lists: hinted and non-hinted one?

That would imply having to change all places trying to allocate memory
to have a look at both lists? I think that could be factored out. I
assume keeping track of the amount of pages would feel more naturally
than having split counters for the existing lists.

I think I'd actually prefer something like that, avoiding mixing page
types and working with different types per list.

-- 

Thanks,

David / dhildenb

