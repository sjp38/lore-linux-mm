Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A6CB76B0253
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 12:41:06 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p129so20530139wmp.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 09:41:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 138si2249508wmf.29.2016.07.26.09.41.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jul 2016 09:41:05 -0700 (PDT)
Subject: Re: [PATCH 1/3] Add a new field to struct shrinker
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
 <20160711063730.GA5284@dhcp22.suse.cz>
 <1468246371.13253.63.camel@surriel.com>
 <20160711143342.GN1811@dhcp22.suse.cz>
 <F072D3E2-0514-4A25-868E-2104610EC14A@gmail.com>
 <20160720145405.GP11249@dhcp22.suse.cz>
From: Tony Jones <tonyj@suse.de>
Message-ID: <5e6e4f2d-ae94-130e-198d-fa402a9eef50@suse.de>
Date: Tue, 26 Jul 2016 09:40:57 -0700
MIME-Version: 1.0
In-Reply-To: <20160720145405.GP11249@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On 07/20/2016 07:54 AM, Michal Hocko wrote:
> On Wed 20-07-16 20:11:09, Janani Ravichandran wrote:
>>
>>> On Jul 11, 2016, at 8:03 PM, Michal Hocko <mhocko@kernel.org> wrote:
>>>
>>> On Mon 11-07-16 10:12:51, Rik van Riel wrote:
>>>>
>>>> What mechanism do you have in mind for obtaining the name,
>>>> Michal?
>>>
>>> Not sure whether tracing infrastructure allows printk like %ps. If not
>>> then it doesn't sound too hard to add.
>>
>> It does allow %ps. Currently what is being printed is the function symbol
>> of the callback using %pF. Ia??d like to know why %pF is used instead of
>> %ps in this case.
>
> From a quick look into the code %pF should be doing the same thing as
> %ps in the end. Some architectures just need some magic to get a proper
> address of the function.
>
>> Michal, just to make sure I understand you correctly, do you mean that we
>> could infer the names of the shrinkers by looking at the names of their callbacks?
>
> Yes, %ps can then be used for the name of the shrinker structure
> (assuming it is available).

The "shrinker structure" (struct shrinker) isn't a good candidate (as it's often embedded as thus no symbol name can be
resolved) but the callback seems to work fine in my testing.

I made an earlier suggestion to Janani that it was helpful to have the superblock shrinker name constructed to include
the fstype.   This level of specificity would be lost if just the callback is used.  I talked briefly to Michal and his view
is that more specific tracepoints can be added for this case.   This is certainly an option as the super_cache_scan callback
can access the superblock and thus the file_system_type via containing record.   It's just more work to later reconcile the
output of two tracepoints.

I talked briefly to Mel and we both think being able to have this level (of fstype) specificity would be useful and it would
be lost just using the callback.   Another option which would avoid the static overhead of the names would be to add a new
shrinker_name() callback.  If NULL,  the caller can just perform the default, in this case lookup the symbol for the callback,
if !NULL it would provide additional string information which the caller could use.   The per-sb shrinker could implement it
and return the fstype.   It's obviously still a +1 word growth of the struct shrinker but it avoids the text overhead of the
constructed names.

Opinions?

Tony


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
