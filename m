Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92A3DC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 13:12:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 579DD2084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 13:12:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 579DD2084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E55EA6B000C; Wed,  3 Apr 2019 09:12:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E043A6B000D; Wed,  3 Apr 2019 09:12:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1AF36B000E; Wed,  3 Apr 2019 09:12:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8304A6B000C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 09:12:30 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y17so7508671edd.20
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 06:12:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=UB3zzA/YM9Fa5HrsaG5jRhhGURYP41u6Xfwt2B+v/C0=;
        b=YZ8r4qPIGdYuh4MMgTr2eWIs0phi1GCT/iBM1qRxWVljOSrS4zpi9mr5kWv7oO+yaS
         5rUlfAmaqA2fJtyxLw8kU+iY7veOVBicO4FyEjAm3i8snJb2/1Uv45e5i99FEBZxsrqA
         ixHE8a8HLu3Trx2JHfcKb5c8KLPah7GluD8RzYP8wF+ukZ3c4I2pGJ/vDF0yVS8Szt0S
         siAhyojuuxxcxP2V10IOF4FmObOJRQQ9+NbOHgMd3WMuYcLltpLPVzv4yX5wVeHf/Pb1
         HdJTBWB/oJVrAGWqlpabDdQHTPGMPeM6oN+CPmZgqOw/KLYvQTt1jBu5dxyFf6VHgWWs
         lfeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAXUlm+f/pLEd2Hs9KIlv5qwK+A/zNW6qnoRr2xaWWMUswr8faYV
	/GpkvCXe6hlNZ8PScMS/u6n5JA8ynclldU+nTmqQqg0sNdk6jiuRjcTMl81yySye3r3tI0hp7BW
	xQ5qP3MCm24pxNxnKgZ2/HPRzVP2H9TI4psFufXw2u0XayuV33jTNAqGN3laDxkgWYw==
X-Received: by 2002:a05:6402:392:: with SMTP id o18mr35253093edv.118.1554297150049;
        Wed, 03 Apr 2019 06:12:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweHikKNhsNVcpFTlQNGuMglBtv5OL9agqe+kIls5Ir9/137+VMRupSITe6iBoiC1E/UReb
X-Received: by 2002:a05:6402:392:: with SMTP id o18mr35253017edv.118.1554297148901;
        Wed, 03 Apr 2019 06:12:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554297148; cv=none;
        d=google.com; s=arc-20160816;
        b=T0oDyU/56FA+jH0K23FCvvNWmyep1SM1g+Om9V1sIAy/qeivPocC+8/PNmn/QHD/9o
         4Y91emov/RnY5aLRfBw5iZQ+Fpi/8iY2CPpM+wRAH7bcQH8tUuSkVgR1iEutTdeLei8B
         fb6Kay1whkooDZLZzaUWoGUD+0aKCsMq93gUFzosDYW72XD4WL+EraEmHPy2JddDEqzv
         mHo2oSq+96ZbYD4OQnlZ0jjdCSFUKQ90Yz+7etdzM/1cj4x1yLPyzvEENrk3rJ1f47B6
         UUAKBc0W6OnX8iMeg5yw9KbH0bGWtxGuWOZYhFik6eX3Q6jCsKXzMfW8SfGeJV39wpYu
         dXZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=UB3zzA/YM9Fa5HrsaG5jRhhGURYP41u6Xfwt2B+v/C0=;
        b=v9elccYJPbP5VyPSYc65zfczc1NAWtY3mcNqMZ3C/G2sNSfcQfdzvTyZkXzahLh6pS
         SPkjSS6Q8biGT9KyzQgxSdg0NEaAOw/MojKPUqavfTrpjlbTos9DtHEKsfxbNh2iP8Ve
         dRl7eS+wk62RcGKmXPGF9zOBox7P8RdDTZ0EieMfw45Ek/2dVPrAyrPW9g9951jWYFCx
         0y8PXJ2XXzb1cuiG4s/ZdjXDBV94XK+0xEdMvJ/zT8LjOxDD8Lb/qwU3/pV3UTc0nmdM
         TCfQ+P+lUbyb4j4bHfEsHBXrdalBXiCLdRtMaB4oeH33M+p06+31feTk5ov7v9bR+0Wx
         BQGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p93si120724edd.158.2019.04.03.06.12.28
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 06:12:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CEB58A78;
	Wed,  3 Apr 2019 06:12:27 -0700 (PDT)
Received: from [10.1.196.75] (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DCED23F59C;
	Wed,  3 Apr 2019 06:12:24 -0700 (PDT)
Subject: Re: [PATCH 1/6] arm64/mm: Enable sysfs based memory hot add interface
To: David Hildenbrand <david@redhat.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, will.deacon@arm.com, catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, osalvador@suse.de, logang@deltatee.com, cai@lca.pw
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-2-git-send-email-anshuman.khandual@arm.com>
 <4b9dd2b0-3b11-608c-1a40-9a3d203dd904@redhat.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <e5665673-60ab-eee8-bc05-53dafb941039@arm.com>
Date: Wed, 3 Apr 2019 14:12:23 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <4b9dd2b0-3b11-608c-1a40-9a3d203dd904@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/04/2019 09:20, David Hildenbrand wrote:
> On 03.04.19 06:30, Anshuman Khandual wrote:
>> Sysfs memory probe interface (/sys/devices/system/memory/probe) can accept
>> starting physical address of an entire memory block to be hot added into
>> the kernel. This is in addition to the existing ACPI based interface. This
>> just enables it with the required config CONFIG_ARCH_MEMORY_PROBE.
>>
> 
> We recently discussed that the similar interface for removal should
> rather be moved to a debug/test module
> 
> I wonder if we should try to do the same for the sysfs probing
> interface. Rather try to get rid of it than open the doors for more users.

Agreed - if this option even exists in a released kernel, there's a risk 
that distros will turn it on for the sake of it, and at that point arm64 
is stuck carrying the same ABI baggage as well.

If users turn up in future with a desperate and unavoidable need for the 
legacy half-an-API on arm64, we can always reconsider adding it at that 
point. It was very much deliberate that my original hot-add support did 
not include a patch like this one.

Robin.

>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>>   arch/arm64/Kconfig | 9 +++++++++
>>   1 file changed, 9 insertions(+)
>>
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index 7e34b9e..a2418fb 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -266,6 +266,15 @@ config HAVE_GENERIC_GUP
>>   config ARCH_ENABLE_MEMORY_HOTPLUG
>>   	def_bool y
>>   
>> +config ARCH_MEMORY_PROBE
>> +	bool "Enable /sys/devices/system/memory/probe interface"
>> +	depends on MEMORY_HOTPLUG
>> +	help
>> +	  This option enables a sysfs /sys/devices/system/memory/probe
>> +	  interface for testing. See Documentation/memory-hotplug.txt
>> +	  for more information. If you are unsure how to answer this
>> +	  question, answer N.
>> +
>>   config SMP
>>   	def_bool y
>>   
>>
> 
> 

