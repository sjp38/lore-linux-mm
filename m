Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67C26C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:57:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AE5E22C7C
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:57:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AE5E22C7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF9B46B0003; Fri, 26 Jul 2019 04:57:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AABB96B0005; Fri, 26 Jul 2019 04:57:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94A598E0002; Fri, 26 Jul 2019 04:57:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 746216B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 04:57:56 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 199so44717035qkj.9
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 01:57:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=b4skpfKJLKybcfy5n1hvZ1EzSRecMEbnZOk8aC9/iTU=;
        b=n8qOZld2UN/r7XkP/LHFeMbSlCeGTJw/ex6RfeRMluDF9A/0jTXYbIt+JGAVvb1e8O
         0BvcmchiDszgKMMEHvHV3Nuo6WtLt5iRZNY8RO+a7OYsG4CapIIG2c6vtQOKHaz2NVyM
         kNfnCIs+HP2MfKlHKnPannE7+jJi1aCKmKGMdxqrrz+5pRBcMr31To2WkELY84X7zdcJ
         7iDqSKL4ITa+UK0OQ2ke0ws5cqSm6KsuahbXuUE3zbtjz8hPRC2GEakWGWS/q3vgO0nn
         J+rADW3VFkI2A/qP3RhqhjRieq4iOIdWpObCK5b2Bh/TIWMObaLwgaLAwipRJcSpJl5Y
         fOVw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUu5yrobDI0EMjGMtl1UzLZf6/FZ/ITcEetlez0yLtVaxASEKVa
	5IIvrslwOz7o5UaFpLsZgUMU5aC+qPgZdYQOzZiAhziHTAb3as/mjaD+EJpuEkqO+tzjUdMh4Y0
	3pxcK9wYNCIg3Z6gbH7llEazfDp+WEOrpEeVnBYYjJ1ycE+4gHJf+E1E6Nt0AbJu9nw==
X-Received: by 2002:a0c:98e9:: with SMTP id g38mr65988546qvd.187.1564131476261;
        Fri, 26 Jul 2019 01:57:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjhWox9DoYCFHPTqA74TDLdFzYvsP0Hcjn9+7iJX+wRGIOJ/JfE6eD5YPQmBxtk5rgQTvp
X-Received: by 2002:a0c:98e9:: with SMTP id g38mr65988527qvd.187.1564131475783;
        Fri, 26 Jul 2019 01:57:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564131475; cv=none;
        d=google.com; s=arc-20160816;
        b=i0LVBumJU83kU7Qker3/L7/6q1DqIQ3IPskdh4/v3Pc0W6xrXbIPs04peUwI8ggEoL
         3KGuPP/XtFIzf02GUAEmRrZJDozKJC57qISrtMBiU8E0AD7cUK6Kx0odTK9k5Sv2jipH
         ETVcJi4PnhxgsZkzM46jy+ojLhGbySsZXr6ZTXomaJALxnCroaob7MZjfnrG4pPWJMYn
         4+P/M75KC4Brg4KxqGcLzfQdmbirc1oODuFskmRt82YiQIoSqdqOSivZ5EqjzhgFdO0u
         ji7tqTTpCf6bjogF/wOy5I8MGYUp/fHyqXMSaotxPvufsOmAHhAhYhPkpmUszLmsn7et
         V7cQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=b4skpfKJLKybcfy5n1hvZ1EzSRecMEbnZOk8aC9/iTU=;
        b=GPl9jqnxuwMrqF4ckShbAM02CeQ8Kt8QuhQMG0sveXsxFbg8q7gd28R1YMhzBljJHT
         IrvYDSsyfKi/PtRIW1Sztgw4s5HLgBQVDMPKM5+Ten6YqyaRqEgdXwRm/ewMgL/CV8h0
         ES+lAiJ7kjpB7nEKRH17gIcEsN8mS0s6MfljiL9Gwn6GHZymO+oOXwG9ntxd1Ydw9snr
         1UeH7H2iFiooOm92+REv6pnTdh/WPZxjH4KZDGf2dQOW86wvC142q1tuS/9QkodeK2Nv
         badQSLLimUlVOmWHd8dduN/6zTZfUBbxRQCLG+U5E/5ifHaGnO8/sJvh+lw+Pq8+GJ/v
         M5dA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v54si34088252qtv.88.2019.07.26.01.57.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 01:57:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E9ABB30C134E;
	Fri, 26 Jul 2019 08:57:54 +0000 (UTC)
Received: from [10.36.116.244] (ovpn-116-244.ams2.redhat.com [10.36.116.244])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6C22C5D9C6;
	Fri, 26 Jul 2019 08:57:53 +0000 (UTC)
Subject: Re: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in
 acpi_scan_init()
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
 Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <osalvador@suse.de>
References: <20190725125636.GA3582@dhcp22.suse.cz>
 <6dc566c2-faf6-565d-4ef1-2ac3a366bc76@redhat.com>
 <20190725135747.GB3582@dhcp22.suse.cz>
 <447b74ca-f7c7-0835-fd50-a9f7191fe47c@redhat.com>
 <20190725191943.GA6142@dhcp22.suse.cz>
 <e31882cf-3290-ea36-77d6-637eaf66fe77@redhat.com>
 <20190726075729.GG6142@dhcp22.suse.cz>
 <fd9e8495-1a93-ac47-442f-081d392ed09b@redhat.com>
 <20190726083117.GJ6142@dhcp22.suse.cz>
 <38d76051-504e-c81a-293a-0b0839e829d3@redhat.com>
 <20190726084408.GK6142@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <45c9f942-fe67-fa60-b62f-31867f9c6e53@redhat.com>
Date: Fri, 26 Jul 2019 10:57:52 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190726084408.GK6142@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 26 Jul 2019 08:57:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.07.19 10:44, Michal Hocko wrote:
> On Fri 26-07-19 10:36:42, David Hildenbrand wrote:
>> On 26.07.19 10:31, Michal Hocko wrote:
> [...]
>>> Anyway, my dislike of the device_hotplug_lock persists. I would really
>>> love to see it go rather than grow even more to the hotplug code. We
>>> should be really striving for mem hotplug internal and ideally range
>>> defined locking longterm. 
>>
>> Yes, and that is a different story, because it will require major
>> changes to all add_memory() users. (esp, due to the documented race
>> conditions). Having that said, memory hotplug locking is not ideal yet.
> 
> I am really happy to hear that we are on the same page here. Do we have
> any document (I am sorry but I am lacking behind recent development in
> this area) that describes roadblocks to remove device_hotplug_lock?

Only the core-api document I mentioned (I documented there quite some
current conditions I identified back then).

I am not sure if we can remove it completely from
add_memory()/remove_memory(): We actually create/delete devices which
can otherwise create races with user space.

Besides that:
- try_offline_node() needs the lock to synchronize against cpu hotplug
- I *assume* try_online_node() needs it as well

Then, there is the possible race condition with user space onlining
memory avoided by the lock. Also, currently the lock protects the
"online_type" when onlining memory.

Then, there might be other global variables (eventually
zone/node/section related) that might need this lock right now - no
details known.

IOW, we have to be very carefully and it is more involved than it might
seem.

Locking is definitely better (and more reliably!) than one year ago, but
there is definitely a lot to do. (unfortunately, just like in many areas
in memory hotplug code :( - say zone handling when offlining/failing to
online memory).

-- 

Thanks,

David / dhildenb

