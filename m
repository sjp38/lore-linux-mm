Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E1A1F6B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 12:10:18 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b192so464139wmb.1
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 09:10:18 -0700 (PDT)
Received: from thoth.sbs.de (thoth.sbs.de. [192.35.17.2])
        by mx.google.com with ESMTPS id e25si7047940wmh.27.2018.04.24.09.10.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 09:10:17 -0700 (PDT)
Subject: Re: [PATCH] kmemleak: Report if we need to tune
 KMEMLEAK_EARLY_LOG_SIZE
References: <288b0afc-bcc3-a2aa-2791-707e625d1da7@siemens.com>
 <20180424155504.frbxmzq4dw3veudu@armageddon.cambridge.arm.com>
From: Jan Kiszka <jan.kiszka@siemens.com>
Message-ID: <c248c83e-e9c1-6b4d-050e-9aa30cd14669@siemens.com>
Date: Tue, 24 Apr 2018 18:10:14 +0200
MIME-Version: 1.0
In-Reply-To: <20180424155504.frbxmzq4dw3veudu@armageddon.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 2018-04-24 17:55, Catalin Marinas wrote:
> On Tue, Apr 24, 2018 at 05:51:15PM +0200, Jan Kiszka wrote:
>> ...rather than just mysteriously disabling it.
>>
>> Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
>> ---
>>  mm/kmemleak.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
>> index 9a085d525bbc..156c0c69cc5c 100644
>> --- a/mm/kmemleak.c
>> +++ b/mm/kmemleak.c
>> @@ -863,6 +863,7 @@ static void __init log_early(int op_type, const void *ptr, size_t size,
>>  
>>  	if (crt_early_log >= ARRAY_SIZE(early_log)) {
>>  		crt_early_log++;
>> +		pr_warn("Too many early logs\n");
> 
> That's already printed, though later where we have an idea of how big the early
> log needs to be:
> 
> 	if (crt_early_log > ARRAY_SIZE(early_log))
> 		pr_warn("Early log buffer exceeded (%d), please increase DEBUG_KMEMLEAK_EARLY_LOG_SIZE\n",
> 			crt_early_log);
> 

Well, that's good, but where you read "detector disabled", there is no
hint on that. I missed that because subsystems tend to not do any
further actions after telling they are off.

BTW, my system (virtual ARM64 target) required 26035 entries, which is a
few orders of magnitude above the default and pretty close the the
limit. What's causing this? Other debug options?

Jan

-- 
Siemens AG, Corporate Technology, CT RDA IOT SES-DE
Corporate Competence Center Embedded Linux
