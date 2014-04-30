Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1C74F6B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 17:24:04 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so632729eek.35
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 14:24:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 43si32153223eei.145.2014.04.30.14.24.01
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 14:24:02 -0700 (PDT)
Message-ID: <53616957.1020309@redhat.com>
Date: Wed, 30 Apr 2014 17:21:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5] mm,writeback: fix divide by zero in pos_ratio_polynom
References: <20140429151910.53f740ef@annuminas.surriel.com>	<5360C9E7.6010701@jp.fujitsu.com>	<20140430093035.7e7226f2@annuminas.surriel.com>	<20140430134826.GH4357@dhcp22.suse.cz>	<20140430104114.4bdc588e@cuia.bos.redhat.com>	<20140430120001.b4b95061ac7252a976b8a179@linux-foundation.org>	<53614F3C.8020009@redhat.com>	<20140430123526.bc6a229c1ea4addad1fb483d@linux-foundation.org>	<20140430160218.442863e0@cuia.bos.redhat.com>	<20140430131353.fa9f49604ea39425bc93c24a@linux-foundation.org>	<20140430164255.7a753a8e@cuia.bos.redhat.com> <20140430140057.7d2a6e984b2ec987182d2a4e@linux-foundation.org>
In-Reply-To: <20140430140057.7d2a6e984b2ec987182d2a4e@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com, mpatlasov@parallels.com, Motohiro.Kosaki@us.fujitsu.com

On 04/30/2014 05:00 PM, Andrew Morton wrote:
> On Wed, 30 Apr 2014 16:42:55 -0400 Rik van Riel <riel@redhat.com> wrote:
>
>> On Wed, 30 Apr 2014 13:13:53 -0700
>> Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>>> This was a consequence of 64->32 truncation and it can't happen any
>>> more, can it?
>>
>> Andrew, this is cleaner indeed :)
>
> I'm starting to get worried about 32-bit wraparound in the patch
> version number ;)
>
>> Masayoshi-san, does the bug still happen with this version, or does
>> this fix the problem?
>>
>
> We could put something like
>
> 	if (WARN_ON_ONCE(setpoint == limit))
> 		setpoint--;
>
> in there if we're not sure.  But it's better to be sure!

The more I look at the code, the more I am convinced that
Michal is right, and we cannot actually hit the case that
"limit - setpoint + 1 == 0".

Setpoint always seems to be some in-between point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
