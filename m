Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F4082C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:36:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6FBE2147A
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:36:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6FBE2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49FBF6B0008; Wed,  3 Apr 2019 04:36:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44DCA6B000A; Wed,  3 Apr 2019 04:36:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 315996B000C; Wed,  3 Apr 2019 04:36:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE176B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:36:09 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 54so16132902qtn.15
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:36:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=mol9fHp5RIYsfscn5BMwxJ4+l8Bbe4WpfLFO7oRqyOo=;
        b=VH7j9GGsFFcPmGMMjlsAWHAWZGnolVwXKainiH5BHoXQ1nA/5GUkErD/7wVReu9Utx
         V7/e8RR4Zmxk+2RoffzYsmIX+WmXp93PJsoMoeYqxv/iiI9jdDFGkiM91GUIn/5GDBpL
         QH79EJ1lEjtrXeQuv5z7SZPEgK1Xe7cChpPudLYdwMVh87mEy2xBfQWgt5dWDUU3Qmyw
         seWfhMyjH63QUFcByhtpF5LfUwbsUfwCLje7FmcIWQaEgHhDDcADG4r4LbitLpPn4OOx
         6FXmgcVzHJzle4pszvX049ED4J3IByFyzR7RfxlHEiM4IlafsDL7S2Pd7cuPl0o/scP/
         U45g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW21tgaiaeb7oVOh3c9KYH7en64tbAyUgGKmXi0tAUnuUt4iCu4
	ngoqnls20k7YiCWG7wa0+Nxk/G3kMl7HpL85EoSizbhFHPlVnaqAw31ibhGxT4MwgPzwfU7PGQ1
	iZhtCrJbqNUk9/4uX6QKBexzZf3oGCBBYsxDhKT+DhS/T11xanUbUNreHRG8A6kHbkg==
X-Received: by 2002:aed:22bc:: with SMTP id p57mr64323596qtc.180.1554280568751;
        Wed, 03 Apr 2019 01:36:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiMsKlSuP6xhkOhWci8ZryzMgiYj2rcce8ceA5BPFBA6N+LHkp5Yfm3SaKy2GqpESHVfuO
X-Received: by 2002:aed:22bc:: with SMTP id p57mr64323569qtc.180.1554280568301;
        Wed, 03 Apr 2019 01:36:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554280568; cv=none;
        d=google.com; s=arc-20160816;
        b=CcewosjyjKSZ7iC4A1VXU0E5Wav5XoGcPL4IJ02FP1kcVOnZn6EPJ/y7Fqoe/w8/qF
         0Kn+gScKfAAGhcjLQ0UKWBTVAKXqIAId6XwkJRHhaTHarTN77fiWHq6XyHRS0zSyNtTW
         Fg9/FWUza4zxpzXEHzGlYoUmybgDp1lTWEJbx9tKgXKToV8WA2bBSylCM0OupdSqOBAV
         I5LI6GtFTXJqRb39oK/TJXKU83fuXSx8sVM77bGEjkN7eY/Rq2mLkITTV3gDBra/YktW
         xZppa9XgJj9p9aE4BLM0Ze8bjYikm7qtDH08SL5XpcZjqQFrylkldgOxC9kZcVgohO+c
         iWpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=mol9fHp5RIYsfscn5BMwxJ4+l8Bbe4WpfLFO7oRqyOo=;
        b=FNCrWAC4We8YzEJW8/JbdcvCX+/WInlg+G+rTB2Z07i1X2olkj6A0IcAuuZd1RxdyQ
         tyEryecGJBoCNrBM64sgke6Yn0vJZAH76e3nkR5ePcdW8/FLBKuKoNM/ZYy98G3caLT3
         c7BOJDo4athmOux18W1I184Qr7LGRVonEFk2n2kzo7dyu9ACRwdzV/JKzTfTRS6GhE5S
         PdbJE9A9cDaJ35Oul9m7IU9W2nSxWc0WEkR3n/rfAvTcPFasZEl67pa31yR5SFlTSZhi
         k99CtlWf7sJEHcqX/TUPdjkS131NcNnI+SU/lX51Gxz0asVvCDgbTpZewqlccNF7jL2A
         2nww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f51si516171qte.155.2019.04.03.01.36.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 01:36:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5D46981F10;
	Wed,  3 Apr 2019 08:36:07 +0000 (UTC)
Received: from [10.36.117.246] (ovpn-117-246.ams2.redhat.com [10.36.117.246])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A0C1C60240;
	Wed,  3 Apr 2019 08:36:05 +0000 (UTC)
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
To: Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com,
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
 <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
 <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
 <20190329134243.GA30026@dhcp22.suse.cz>
 <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
 <20190401115306.GF28293@dhcp22.suse.cz>
 <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
 <20190402124845.GD28293@dhcp22.suse.cz>
 <20190403080113.adj2m3szhhnvzu56@d104.suse.de>
 <20190403081232.GB15605@dhcp22.suse.cz>
 <20190403083359.vqbzy5krjfzfjedx@d104.suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <a2ebe8c0-916e-1117-acfd-0ac2300a7dfd@redhat.com>
Date: Wed, 3 Apr 2019 10:36:04 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190403083359.vqbzy5krjfzfjedx@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 03 Apr 2019 08:36:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03.04.19 10:34, Oscar Salvador wrote:
> On Wed, Apr 03, 2019 at 10:12:32AM +0200, Michal Hocko wrote:
>> What does prevent calling somebody arch_add_memory for a range spanning
>> multiple memblocks from a driver directly. In other words aren't you
>> making  assumptions about a future usage based on the qemu usecase?
> 
> Well, right now they cannot as it is not exported.
> But if we want to do it in the future, then yes, I would have to
> be more careful because I made the assumption that hot-add/hot-remove
> are working with the same granularity, which is the case right now.
> 
> Given said this, I think that something like you said before, giving
> the option to the caller to specify whether it wants vmemmaps per the
> whole hot-added range or per memblock is a reasonable thing to do.
> That way, there will not be a problem working with different granularities
> in hot-add/hot-remove operations and we would be on safe side.

There might still be an issue if the person adding memory might be
somebody else removing memory. I am not yet sure if we should even allow
add_memory/remove_memory with different granularity. But as I noted,
ACPI and powernv.


-- 

Thanks,

David / dhildenb

