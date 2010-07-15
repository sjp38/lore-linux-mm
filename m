Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BB270620202
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 07:51:59 -0400 (EDT)
Message-ID: <4C3EF644.1070505@redhat.com>
Date: Thu, 15 Jul 2010 19:51:32 +0800
From: Xiaotian Feng <dfeng@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mmotm 12/30] selinux: tag avc cache alloc as non-critical
References: <20100713101650.2835.15245.sendpatchset@danny.redhat> <20100713101906.2835.83443.sendpatchset@danny.redhat> <6E38A74E-B033-4D2A-9620-2A8BDF9E0AD1@earthlink.net>
In-Reply-To: <6E38A74E-B033-4D2A-9620-2A8BDF9E0AD1@earthlink.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mitchell Erblich <erblichs@earthlink.net>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org, riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, lwang@redhat.com, penberg@cs.helsinki.fi, akpm@linux-foundation.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On 07/13/2010 06:55 PM, Mitchell Erblich wrote:
>
> On Jul 13, 2010, at 3:19 AM, Xiaotian Feng wrote:
>
>>  From 6c3a91091b2910c23908a9f9953efcf3df14e522 Mon Sep 17 00:00:00 2001
>> From: Xiaotian Feng<dfeng@redhat.com>
>> Date: Tue, 13 Jul 2010 11:02:41 +0800
>> Subject: [PATCH 12/30] selinux: tag avc cache alloc as non-critical
>>
>> Failing to allocate a cache entry will only harm performance not correctness.
>> Do not consume valuable reserve pages for something like that.
>>
>> Signed-off-by: Peter Zijlstra<a.p.zijlstra@chello.nl>
>> Signed-off-by: Suresh Jayaraman<sjayaraman@suse.de>
>> Signed-off-by: Xiaotian Feng<dfeng@redhat.com>
>> ---
>> security/selinux/avc.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/security/selinux/avc.c b/security/selinux/avc.c
>> index 3662b0f..9029395 100644
>> --- a/security/selinux/avc.c
>> +++ b/security/selinux/avc.c
>> @@ -284,7 +284,7 @@ static struct avc_node *avc_alloc_node(void)
>> {
>> 	struct avc_node *node;
>>
>> -	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC);
>> +	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC|__GFP_NOMEMALLOC);
>> 	if (!node)
>> 		goto out;
>>
>> -- 
>> 1.7.1.1
>>
>
> Why not just replace GFP_ATOMIC with GFP_NOWAIT?
>
> This would NOT consume the valuable last pages.

But replace GFP_ATOMIC with GFP_NOWAIT can not prevent avc_alloc_node 
consume reserved pages.

>
> Mitchell Erblich
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
