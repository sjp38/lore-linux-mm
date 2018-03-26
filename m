Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C594B6B000A
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 11:30:00 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id b2-v6so13261259plz.17
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:30:00 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0113.outbound.protection.outlook.com. [104.47.2.113])
        by mx.google.com with ESMTPS id 132si10383272pgb.470.2018.03.26.08.29.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 26 Mar 2018 08:29:59 -0700 (PDT)
Subject: Re: [PATCH 04/10] fs: Propagate shrinker::id to list_lru
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163851112.21546.11559231484397320114.stgit@localhost.localdomain>
 <20180324185018.iibbx3zjtzikjtlc@esperanza>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <d65c7a9e-eb8b-a2bd-163c-4d6652ecb74c@virtuozzo.com>
Date: Mon, 26 Mar 2018 18:29:45 +0300
MIME-Version: 1.0
In-Reply-To: <20180324185018.iibbx3zjtzikjtlc@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

On 24.03.2018 21:50, Vladimir Davydov wrote:
> On Wed, Mar 21, 2018 at 04:21:51PM +0300, Kirill Tkhai wrote:
>> The patch adds list_lru::shrk_id field, and populates
>> it by registered shrinker id.
>>
>> This will be used to set correct bit in memcg shrinkers
>> map by lru code in next patches, after there appeared
>> the first related to memcg element in list_lru.
>>
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>> ---
>>  fs/super.c               |    5 +++++
>>  include/linux/list_lru.h |    1 +
>>  mm/list_lru.c            |    7 ++++++-
>>  mm/workingset.c          |    3 +++
>>  4 files changed, 15 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/super.c b/fs/super.c
>> index 0660083427fa..1f3dc4eab409 100644
>> --- a/fs/super.c
>> +++ b/fs/super.c
>> @@ -521,6 +521,11 @@ struct super_block *sget_userns(struct file_system_type *type,
>>  	if (err) {
>>  		deactivate_locked_super(s);
>>  		s = ERR_PTR(err);
>> +	} else {
>> +#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
>> +		s->s_dentry_lru.shrk_id = s->s_shrink.id;
>> +		s->s_inode_lru.shrk_id = s->s_shrink.id;
>> +#endif
> 
> I don't really like the new member name. Let's call it shrink_id or
> shrinker_id, shall we?
> 
> Also, I think we'd better pass shrink_id to list_lru_init rather than
> setting it explicitly.

Ok, I'll think on this in v2.

Thanks,
Kirill
