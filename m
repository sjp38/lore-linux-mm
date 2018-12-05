Return-Path: <linux-kernel-owner@vger.kernel.org>
Reply-To: xlpang@linux.alibaba.com
Subject: Re: [PATCH 1/3] mm/memcg: Fix min/low usage in
 propagate_protected_usage()
References: <20181203080119.18989-1-xlpang@linux.alibaba.com>
 <20181203180008.GB31090@castle.DHCP.thefacebook.com>
From: Xunlei Pang <xlpang@linux.alibaba.com>
Message-ID: <03652447-d9ba-45ea-3365-46a4caf96748@linux.alibaba.com>
Date: Wed, 5 Dec 2018 16:58:31 +0800
MIME-Version: 1.0
In-Reply-To: <20181203180008.GB31090@castle.DHCP.thefacebook.com>
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Roman,

On 2018/12/4 AM 2:00, Roman Gushchin wrote:
> On Mon, Dec 03, 2018 at 04:01:17PM +0800, Xunlei Pang wrote:
>> When usage exceeds min, min usage should be min other than 0.
>> Apply the same for low.
>>
>> Signed-off-by: Xunlei Pang <xlpang@linux.alibaba.com>
>> ---
>>  mm/page_counter.c | 12 ++----------
>>  1 file changed, 2 insertions(+), 10 deletions(-)
>>
>> diff --git a/mm/page_counter.c b/mm/page_counter.c
>> index de31470655f6..75d53f15f040 100644
>> --- a/mm/page_counter.c
>> +++ b/mm/page_counter.c
>> @@ -23,11 +23,7 @@ static void propagate_protected_usage(struct page_counter *c,
>>  		return;
>>  
>>  	if (c->min || atomic_long_read(&c->min_usage)) {
>> -		if (usage <= c->min)
>> -			protected = usage;
>> -		else
>> -			protected = 0;
>> -
>> +		protected = min(usage, c->min);
> 
> This change makes sense in the combination with the patch 3, but not as a
> standlone "fix". It's not a bug, it's a required thing unless you start scanning
> proportionally to memory.low/min excess.
> 
> Please, reflect this in the commit message. Or, even better, merge it into
> the patch 3.

The more I looked the more I think it's a bug, but anyway I'm fine with
merging it into patch 3 :-)

> 
> Also, please, make sure that cgroup kselftests are passing after your changes.

Sure, will do and send v2. Thanks for your inputs.
