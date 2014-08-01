Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id F36DE6B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 21:37:45 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so4510928pdj.26
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 18:37:45 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id bz3si3924269pdb.493.2014.07.31.18.37.44
        for <linux-mm@kvack.org>;
        Thu, 31 Jul 2014 18:37:45 -0700 (PDT)
Message-ID: <53DAEFB5.7060501@cn.fujitsu.com>
Date: Fri, 1 Aug 2014 09:39:01 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] swap: remove the struct cpumask has_work
References: <1406777421-12830-3-git-send-email-laijs@cn.fujitsu.com> <20140731115137.GA20244@dhcp22.suse.cz> <53DA6A2F.100@tilera.com>
In-Reply-To: <53DA6A2F.100@tilera.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@gentwo.org>, Frederic Weisbecker <fweisbec@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Khalid Aziz <khalid.aziz@oracle.com>, linux-mm@kvack.org, Gilad Ben-Yossef <gilad@benyossef.com>

On 08/01/2014 12:09 AM, Chris Metcalf wrote:
> On 7/31/2014 7:51 AM, Michal Hocko wrote:
>> On Thu 31-07-14 11:30:19, Lai Jiangshan wrote:
>>> It is suggested that cpumask_var_t and alloc_cpumask_var() should be used
>>> instead of struct cpumask.  But I don't want to add this complicity nor
>>> leave this unwelcome "static struct cpumask has_work;", so I just remove
>>> it and use flush_work() to perform on all online drain_work.  flush_work()
>>> performs very quickly on initialized but unused work item, thus we don't
>>> need the struct cpumask has_work for performance.
>> Why? Just because there is general recommendation for using
>> cpumask_var_t rather than cpumask?
>>
>> In this particular case cpumask shouldn't matter much as it is static.
>> Your code will work as well, but I do not see any strong reason to
>> change it just to get rid of cpumask which is not on stack.
> 
> The code uses for_each_cpu with a cpumask to avoid waking cpus that don't
> need to do work.  This is important for the nohz_full type functionality,
> power efficiency, etc.  So, nack for this change.
> 

flush_work() on initialized but unused work item just disables irq and
fetches work->data to test and restores irq and return.

the struct cpumask has_work is just premature optimization.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
