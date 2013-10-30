Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 914F16B0035
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 15:26:22 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so1419864pad.11
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 12:26:22 -0700 (PDT)
Received: from psmtp.com ([74.125.245.198])
        by mx.google.com with SMTP id gw3si71533pac.172.2013.10.30.12.26.20
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 12:26:21 -0700 (PDT)
Received: by mail-gg0-f171.google.com with SMTP id u2so753502ggn.16
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 12:26:19 -0700 (PDT)
Message-ID: <52715D58.9020800@gmail.com>
Date: Wed, 30 Oct 2013 15:26:16 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: get rid of unnecessary pageblock scanning in setup_zone_migrate_reserve
References: <1382562092-15570-1-git-send-email-kosaki.motohiro@gmail.com> <20131030151904.GO2400@suse.de>
In-Reply-To: <20131030151904.GO2400@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: kosaki.motohiro@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

(10/30/13 11:19 AM), Mel Gorman wrote:
> On Wed, Oct 23, 2013 at 05:01:32PM -0400, kosaki.motohiro@gmail.com wrote:
>> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>
>> Yasuaki Ithimatsu reported memory hot-add spent more than 5 _hours_
>> on 9TB memory machine and we found out setup_zone_migrate_reserve
>> spnet >90% time.
>>
>> The problem is, setup_zone_migrate_reserve scan all pageblock
>> unconditionally, but it is only necessary number of reserved block
>> was reduced (i.e. memory hot remove).
>> Moreover, maximum MIGRATE_RESERVE per zone are currently 2. It mean,
>> number of reserved pageblock are almost always unchanged.
>>
>> This patch adds zone->nr_migrate_reserve_block to maintain number
>> of MIGRATE_RESERVE pageblock and it reduce an overhead of
>> setup_zone_migrate_reserve dramatically.
>>
>
> It seems regrettable to expand the size of struct zone just for this.

This is only matter when backporting enterprise distro. But you are right
it would be nice if it's avoidable.

> You are right that the number of blocks does not exceed 2 because of a
> check made in setup_zone_migrate_reserve so it should be possible to
> special case this. I didn't test this or think about it particularly
> carefully and no doubt there is a nicer way but for illustration
> purposes see the patch below.

I'll test. A few days give me please.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
