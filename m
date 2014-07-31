Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3780F6B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 12:09:22 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id w10so3728826pde.4
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 09:09:21 -0700 (PDT)
Received: from USMAMAIL.TILERA.COM (usmamail.tilera.com. [12.216.194.151])
        by mx.google.com with ESMTPS id ch3si6413245pbb.235.2014.07.31.09.09.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 31 Jul 2014 09:09:21 -0700 (PDT)
Message-ID: <53DA6A2F.100@tilera.com>
Date: Thu, 31 Jul 2014 12:09:19 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH] swap: remove the struct cpumask has_work
References: <1406777421-12830-3-git-send-email-laijs@cn.fujitsu.com> <20140731115137.GA20244@dhcp22.suse.cz>
In-Reply-To: <20140731115137.GA20244@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@gentwo.org>, Frederic Weisbecker <fweisbec@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Khalid Aziz <khalid.aziz@oracle.com>, linux-mm@kvack.org, Gilad Ben-Yossef <gilad@benyossef.com>

On 7/31/2014 7:51 AM, Michal Hocko wrote:
> On Thu 31-07-14 11:30:19, Lai Jiangshan wrote:
>> It is suggested that cpumask_var_t and alloc_cpumask_var() should be used
>> instead of struct cpumask.  But I don't want to add this complicity nor
>> leave this unwelcome "static struct cpumask has_work;", so I just remove
>> it and use flush_work() to perform on all online drain_work.  flush_work()
>> performs very quickly on initialized but unused work item, thus we don't
>> need the struct cpumask has_work for performance.
> Why? Just because there is general recommendation for using
> cpumask_var_t rather than cpumask?
>
> In this particular case cpumask shouldn't matter much as it is static.
> Your code will work as well, but I do not see any strong reason to
> change it just to get rid of cpumask which is not on stack.

The code uses for_each_cpu with a cpumask to avoid waking cpus that don't
need to do work.  This is important for the nohz_full type functionality,
power efficiency, etc.  So, nack for this change.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
