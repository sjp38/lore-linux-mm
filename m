Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30E8BC76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:26:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC699216C8
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:26:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC699216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 831306B0006; Thu, 25 Jul 2019 14:26:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E3406B0007; Thu, 25 Jul 2019 14:26:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A90A8E0002; Thu, 25 Jul 2019 14:26:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id 484376B0006
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:26:06 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id d1so5438270uak.23
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:26:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=J3+CidwfAYkBITCE3PZ8hU5n6b9+EFq8j/Gwsz5dpaI=;
        b=Pw2c50DMItsBR33G9JOrwfIhRrCffqWEYYPMUPPwclAwA3t5n23bxIKJsO66FxbTz1
         ksfnJuwPOALKocncC810510UgGzv84Goow63xhFXkognGI2XX3u06B5aa2H7JW5TxgFt
         lCWl3L/hLkU1hQBW6XRjLbD0+wRxyDUX7/HnsaLezv6yDCe9djCq7XC7PHj5/XG3Fi69
         qWfcPtK94WZWMx6T5/kAF5m8KpgyBy1Vn7fpcZMqMo2/MiwdPXCtdBJ6/dG/7tQyjsCh
         3sCYiD6NVEkLA3LzlNiyJwbIxITY/M5asrsb31PZh00Dry4F/0VKvMQl2ifxbEM2xNK9
         3BMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXq8EkusjFrZju+nWcxSpWRe2VrGEvC4Hrt33pYKFISPzy21Z7b
	Aaj24ry6EEPeUQaNE5yFcbRCQY8PCG2uOcwtY6MiXYt3FHJexJSC1D8LpMfY9d5/3MqBIOiM3tV
	1JhJNYojlH47G+Lj6KNimbpLrO22i6ECUbCeUqWntQLpmEUDN4RjKlVxk9L+PJCP3GA==
X-Received: by 2002:ab0:3159:: with SMTP id e25mr8213152uam.81.1564079166008;
        Thu, 25 Jul 2019 11:26:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnxHvFsiMlk2UIJUhTH881phzDs5+vtx9XISHi+PQq/AwwCynX9fE539SWdhCKJIkQZdD7
X-Received: by 2002:ab0:3159:: with SMTP id e25mr8213066uam.81.1564079165142;
        Thu, 25 Jul 2019 11:26:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564079165; cv=none;
        d=google.com; s=arc-20160816;
        b=PFsrn8yVXSX7fwoz+ndkKerbIpEsvRNAdvcUz4c+Quh+BfbLP2wQhRGVgFJ7b17uSG
         CAH1+JxkhVcvvtvdEMGB63D/9/LoqVJSJb3QsQuRopRXKjfwBH+UlJDyLNkz7XYgVkBO
         wKcZUh2NLf2daWHdPG2LLPa91kXFTwTVBYjCOI9Imw+Zl9+ojK+k4N7p+Qn5LwOLWJbf
         yX7QA4NG0wCNkediDkNT0/hERw2smct+H93Jyx09WZ9kAMgm0CN4ri8kwvtvFJoWBLJO
         QlegpAD7AIRsmz9bSmhiflFE4WsA9nicrZWKm0b+Ez8WvCfOjCzqxX80JBkD2f6e7msU
         B2Fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=J3+CidwfAYkBITCE3PZ8hU5n6b9+EFq8j/Gwsz5dpaI=;
        b=0++3OvVeEdjRZwZ5L76z0x6iFwVOvhPnlUtp8OwgqnXp9XrZLa8PYhTdiSE9mkdMjY
         UNEp53E7BtFsyR/N6OsJGtjFLdX1JuBQWACU3+9OQ1siqtTh0t2kJE3D/c//gPaJ8Vrd
         F30b7jZInfFXetm0KKRiV5T5BsKiYc1uvaTb15kv4dYJv11cmWMUc0el2VvYD25ZzOqx
         Fw3hz0IvdOfyQ9wGe4PQS4XDFU0ectE6G5ri0ZOBKWOhLd/ccR9981h3VP/iOYauJBQI
         Oj4V5jopp5jGATjmiB0VUwS6psG4NLtRFRKJL+Z31Rd3dKhMudyfC8SBwxtvSX+jX0QF
         USoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m4si10178135vsd.38.2019.07.25.11.26.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 11:26:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2C26D30001D8;
	Thu, 25 Jul 2019 18:26:04 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id CD0165E1B0;
	Thu, 25 Jul 2019 18:25:53 +0000 (UTC)
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
 david@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
 pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
 lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
 pbonzini@redhat.com, dan.j.williams@intel.com
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724171050.7888.62199.stgit@localhost.localdomain>
 <20190724173403-mutt-send-email-mst@kernel.org>
 <ada4e7d932ebd436d00c46e8de699212e72fd989.camel@linux.intel.com>
 <fed474fe-93f4-a9f6-2e01-75e8903edd81@redhat.com>
 <bc162a5eaa58ac074c8ad20cb23d579aa04d0f43.camel@linux.intel.com>
 <20190725111303-mutt-send-email-mst@kernel.org>
 <96b1ac42dccbfbb5dd17210e6767ca2544558390.camel@linux.intel.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <cc98f7c9-bcf8-79cb-54b7-de7c996f76e1@redhat.com>
Date: Thu, 25 Jul 2019 14:25:52 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <96b1ac42dccbfbb5dd17210e6767ca2544558390.camel@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 25 Jul 2019 18:26:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/25/19 12:16 PM, Alexander Duyck wrote:
> On Thu, 2019-07-25 at 11:16 -0400, Michael S. Tsirkin wrote:
>> On Thu, Jul 25, 2019 at 08:05:30AM -0700, Alexander Duyck wrote:
>>> On Thu, 2019-07-25 at 07:35 -0400, Nitesh Narayan Lal wrote:
>>>> On 7/24/19 6:03 PM, Alexander Duyck wrote:
>>>>> On Wed, 2019-07-24 at 17:38 -0400, Michael S. Tsirkin wrote:
>>>>>> On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
>>>>>>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>>>>>>
>>>>>>> Add support for what I am referring to as "bubble hinting". Basic=
ally the
>>>>>>> idea is to function very similar to how the balloon works in that=
 we
>>>>>>> basically end up madvising the page as not being used. However we=
 don't
>>>>>>> really need to bother with any deflate type logic since the page =
will be
>>>>>>> faulted back into the guest when it is read or written to.
>>>>>>>
>>>>>>> This is meant to be a simplification of the existing balloon inte=
rface
>>>>>>> to use for providing hints to what memory needs to be freed. I am=
 assuming
>>>>>>> this is safe to do as the deflate logic does not actually appear =
to do very
>>>>>>> much other than tracking what subpages have been released and whi=
ch ones
>>>>>>> haven't.
>>>>>>>
>>>>>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com=
>
>>>>>> BTW I wonder about migration here.  When we migrate we lose all hi=
nts
>>>>>> right?  Well destination could be smarter, detect that page is ful=
l of
>>>>>> 0s and just map a zero page. Then we don't need a hint as such - b=
ut I
>>>>>> don't think it's done like that ATM.
>>>>> I was wondering about that a bit myself. If you migrate with a ball=
oon
>>>>> active what currently happens with the pages in the balloon? Do you=

>>>>> actually migrate them, or do you ignore them and just assume a zero=
 page?
>>>>> I'm just reusing the ram_block_discard_range logic that was being u=
sed for
>>>>> the balloon inflation so I would assume the behavior would be the s=
ame.
>>>> I agree, however, I think it is worth investigating to see if enabli=
ng hinting
>>>> adds some sort of overhead specifically in this kind of scenarios. W=
hat do you
>>>> think?
>>> I suspect that the hinting/reporting would probably improve migration=

>>> times based on the fact that from the sound of things it would just b=
e
>>> migrated as a zero page.
>>>
>>> I don't have a good setup for testing migration though and I am not t=
hat
>>> familiar with trying to do a live migration. That is one of the reaso=
ns
>>> why I didn't want to stray too far from the existing balloon code as =
that
>>> has already been tested with migration so I would assume as long as I=
 am
>>> doing almost the exact same thing to hint the pages away it should be=
have
>>> exactly the same.
>>>
>>>>>> I also wonder about interaction with deflate.  ATM deflate will ad=
d
>>>>>> pages to the free list, then balloon will come right back and repo=
rt
>>>>>> them as free.
>>>>> I don't know how likely it is that somebody who is getting the free=
 page
>>>>> reporting is likely to want to also use the balloon to take up memo=
ry.
>>>> I think it is possible. There are two possibilities:
>>>> 1. User has a workload running, which is allocating and freeing the =
pages and at
>>>> the same time, user deflates.
>>>> If these new pages get used by this workload, we don't have to worry=
 as you are
>>>> already handling that by not hinting the free pages immediately.
>>>> 2. Guest is idle and the user adds up some memory, for this situatio=
n what you
>>>> have explained below does seems reasonable.
>>> Us hinting on pages that are freed up via deflate wouldn't be too big=
 of a
>>> deal. I would think that is something we could look at addressing as =
more
>>> of a follow-on if we ever needed to since it would just add more
>>> complexity.
>>>
>>> Really what I would like to see is the balloon itself get updated fir=
st to
>>> perhaps work with variable sized pages first so that we could then ha=
ve
>>> pages come directly out of the balloon and go back into the freelist =
as
>>> hinted, or visa-versa where hinted pages could be pulled directly int=
o the
>>> balloon without needing to notify the host.
>> Right, I agree. At this point the main thing I worry about is that
>> the interfaces only support one reporter, since a page flag is used.
>> So if we ever rewrite existing hinting to use the new mm
>> infrastructure then we can't e.g. enable both types of hinting.
> Does it make sense to have multiple types of hinting active at the same=

> time though? That kind of seems wasteful to me.=20


I agree.


> Ideally we should be able
> to provide the hints and have them feed whatever is supposed to be usin=
g
> them. So for example I could probably look at also clearing the bitmaps=

> when migration is in process.
>
> Also, I am wonder if the free page hints would be redundant with the fo=
rm
> of page hinting/reporting that I have since we should be migrating a mu=
ch
> smaller footprint anyway if the pages have been madvised away before we=

> even start the migration.
>
>> FWIW Nitesh's RFC does not have this limitation.
> Yes, but there are also limitations to his approach. For example the fa=
ct
> that the bitmap it maintains is back to being a hint rather then being
> very exact.

True.


>  As a result you could end up walking the bitmap for a while
> clearing bits without ever finding a free page.


Are referring to the overhead which will be introduced due to bitmap scan=
ning on
very large guests?


>
>> I intend to think about this over the weekend.
> Sounds good. I'll try to get the stuff you have pointed out so far
> addressed and hopefully have v3 ready to go next week.
>
> Thanks.
>
> - Alex
>
--=20
Thanks
Nitesh

