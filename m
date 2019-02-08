Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74757C282C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 03:03:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C73B21916
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 03:03:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C73B21916
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA4B08E0072; Thu,  7 Feb 2019 22:03:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C53EE8E0002; Thu,  7 Feb 2019 22:03:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B42458E0072; Thu,  7 Feb 2019 22:03:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 581728E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 22:03:42 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id l45so796278edb.1
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 19:03:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=3uNAgE82wvAut5qWwJouSpZaMQTwpoo6SOiZaqFUhEg=;
        b=pqKVPN865V5vhYd/tm1ABdfotFLSUop/54vIOjmxtW/QgBvsWxQ/7wipC7No/URadt
         c22uT5sE1qHBLnO3SW9m4ZpBK9EuTx8T/NRRSdJ6ckH8e52TyE/ayvF8HPk+6AE+ZK3c
         avMUiogCOi/JMSYBB1dCySBpMegH+y2d+MV1plH1783TBr5PdMGw5Lm5Mqep7CvVIbSi
         PFFSLI1OiG41J1lsQmzqOsTKAbR6fzgZ618Q8DnztrmFRX19/PlAwW++FfLbyCdswxJ1
         /4n+/UB+dmOeBZifw1G3Fk4w6ItwbzQpYygvnFBLHiXcWcA2LRFLEP0MLfcer8CO0Syh
         8Liw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAubkTHhTRhxDqNfC/M8Ut7oogTRaUgKqNOLUUK8fOHyS9Klillh5
	q9li6km+BoIi+lLCGi8BteWSRLM2EHUhx5kQfYbNcPnJO+DVEmva5SbRVkmv0sbVsm292KfzFiD
	X3saZ0fq82EYh4wKstLWWY9n5yXROLGkUBBG+rcpns192xp9zm5jHlhmZ312+f6pOfw==
X-Received: by 2002:a50:8a45:: with SMTP id i63mr15211714edi.262.1549595021809;
        Thu, 07 Feb 2019 19:03:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbSINaV0ebVb4giCOM2mttbP0/b2/tCZ09hfKwld+HalUNaZKW+kTuhDvN/Jvy2HHd5hTRe
X-Received: by 2002:a50:8a45:: with SMTP id i63mr15211667edi.262.1549595020864;
        Thu, 07 Feb 2019 19:03:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549595020; cv=none;
        d=google.com; s=arc-20160816;
        b=tSoyT+JBy7CLoYFBxrpDkcKEFizNiuxp+FDEtuqWUJu48HV5dJauYiNJYTE0K4MnQo
         fkvN+st6tMfKoBdgj5oIg+pIIbZrPvgL729L2qLSu/FPEtDTrOzYWFzYMGvb/QtK/0JD
         pwPOY6a9RS2oFOveaHtYyYZO21kKA48perfaWj5yxXH5RfSIwHNtzmdG6Q3LqZVD8lxc
         jF+hQJaTL5ZMC472WDsBU13q8U0PuMocGUUIQggHnsMyFCXqy/PAeewleFUpTQvfeMAj
         Xnzoc+im12H+oxkffsDc6BxwF+hty/8++8I3SWsxmkl83ScV4pagPzzuLD/JqloxixEW
         zODg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=3uNAgE82wvAut5qWwJouSpZaMQTwpoo6SOiZaqFUhEg=;
        b=FRMbKlsal0+71C5uF12VIUmyH8c2Q8MXHIQInJldWucCR6dBSssBKz7RbHuxFV7lAv
         py3cC0VpGZLhQjI/5beHa0fY8NkYoyXHRMmm2k+RB0RvZCol7Cyzh9/0MWUUsBQysBQ/
         7/zZ8DY8Ro6WLvqwCL0553QNnE6O+z9vhy5qDM1eNn4fqZ+5zCaMRvRUL7OOhd8C6y5h
         cEct/P201lXlcNF14zVqmPL+BqeYVdtTFPjCLI4NjEKLggGbrE/72zM9P0W7twK6P7AS
         eYmBFxd1NfaeANILQKD8J1rlD+1AXTKMs4g2Yr+R/E3XQN36onTwsvpsByNHSHoj0eJf
         Lnxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 4si521196edh.154.2019.02.07.19.03.40
        for <linux-mm@kvack.org>;
        Thu, 07 Feb 2019 19:03:40 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9701BEBD;
	Thu,  7 Feb 2019 19:03:39 -0800 (PST)
Received: from [10.162.40.126] (p8cg001049571a15.blr.arm.com [10.162.40.126])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BF7733F557;
	Thu,  7 Feb 2019 19:03:36 -0800 (PST)
Subject: Re: [PATCH] mm/memory-hotplug: Add sysfs hot-remove trigger
To: Robin Murphy <robin.murphy@arm.com>, Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 gregkh@linuxfoundation.org, rafael@kernel.org, mhocko@kernel.org,
 akpm@linux-foundation.org
References: <29ed519902512319bcc62e071d52b712fa97e306.1549469965.git.robin.murphy@arm.com>
 <20190207133620.a4vg2xqphsloke6i@d104.suse.de>
 <7bf25a0f-766e-7924-9a54-64cef9f53b57@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <bde72792-9116-f28d-f252-084345631f15@arm.com>
Date: Fri, 8 Feb 2019 08:33:34 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <7bf25a0f-766e-7924-9a54-64cef9f53b57@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/07/2019 09:02 PM, Robin Murphy wrote:
> On 07/02/2019 13:36, Oscar Salvador wrote:
>> On Wed, Feb 06, 2019 at 05:03:53PM +0000, Robin Murphy wrote:
>>> ARCH_MEMORY_PROBE is a useful thing for testing and debugging hotplug,
>>> but being able to exercise the (arguably trickier) hot-remove path would
>>> be even more useful. Extend the feature to allow removal of offline
>>> sections to be triggered manually to aid development.
>>>
>>> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
>>> ---
>>>
>>> This is inspired by a previous proposal[1], but in coming up with a
>>> more robust interface I ended up rewriting the whole thing from
>>> scratch. The lack of documentation is semi-deliberate, since I don't
>>> like the idea of anyone actually relying on this interface as ABI, but
>>> as a handy tool it felt useful enough to be worth sharing :)
>>
>> Hi Robin,
>>
>> I think this might come in handy, especially when trying to test hot-remove
>> on arch's that do not have any means to hot-remove memory, or even on virtual
>> platforms that do not have yet support for hot-remove depending on the platform,
>> like qemu/arm64.
>>
>>
>> I could have used this while testing hot-remove on other archs for [1]
>>
>>>
>>> Robin.
>>>
>>> [1] https://lore.kernel.org/lkml/22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com/
>>>
>>
>>> +    if (mem->state != MEM_OFFLINE)
>>> +        return -EBUSY;
>>
>> We do have the helper "is_memblock_offlined()", although it is only used in one place now.
>> So, I would rather use it here as well.
> 
> Ooh, if I'd actually noticed that that helper existed, I would indeed have used it - fixed.
> 
>>> +
>>> +    ret = lock_device_hotplug_sysfs();
>>> +    if (ret)
>>> +        return ret;
>>> +
>>> +    if (device_remove_file_self(dev, attr)) {
>>> +        __remove_memory(pfn_to_nid(start_pfn), PFN_PHYS(start_pfn),
>>> +                MIN_MEMORY_BLOCK_SIZE * sections_per_block);
>>
>> Sorry, I am not into sysfs inners, but I thought that:
>> device_del::device_remove_attrs::device_remove_groups::sysfs_remove_groups
>> would be enough to remove the dev attributes.
>> I guess in this case that is not enough, could you explain why?
> 
> As I found out the hard way, since the "remove" attribute itself belongs to the device being removed, the standard device teardown callchain would end up trying to remove the file from its own method, which results in deadlock. Fortunately, the PCI sysfs code has a similar "remove" attribute which showed me how it should be handled - following the kerneldoc breadcrumb trail to kernfs_remove_self() hopefully explains it more completely.
Instead we could have an interface like /sys/devices/system/memory/[unprobe|remove]
which would take a memory block start address looking into the existing ones and
attempt to remove [addr, addr + memory_block_size] provided its already offlined.
This will be exact opposite for /sys/devices/system/memory/probe except the fact
that it can trigger onlining of the memory automatically (even this new one could
trigger offlining automatically as well). But I dont have a preference between the
proposed one or this one. Either of them should be okay.

