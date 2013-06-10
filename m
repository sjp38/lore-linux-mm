Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id D72456B0032
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 15:56:35 -0400 (EDT)
Message-ID: <51B62F6B.8040308@oracle.com>
Date: Mon, 10 Jun 2013 15:56:27 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: prevent warnings when allocating with __GFP_NOWARN
References: <1370891880-2644-1-git-send-email-sasha.levin@oracle.com> <CAOJsxLGDH2iwznRkP-iwiMZw7Ee3mirhjLvhShrWLHR0qguRxA@mail.gmail.com>
In-Reply-To: <CAOJsxLGDH2iwznRkP-iwiMZw7Ee3mirhjLvhShrWLHR0qguRxA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 06/10/2013 03:31 PM, Pekka Enberg wrote:
> Hello Sasha,
>
> On Mon, Jun 10, 2013 at 10:18 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
>> slab would still spew a warning when a big allocation happens with the
>> __GFP_NOWARN fleg is set. Prevent that to conform to __GFP_NOWARN.
>>
>> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
>> ---
>>   mm/slab_common.c | 4 +++-
>>   1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index ff3218a..2d41450 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -373,8 +373,10 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
>>   {
>>          int index;
>>
>> -       if (WARN_ON_ONCE(size > KMALLOC_MAX_SIZE))
>> +       if (size > KMALLOC_MAX_SIZE) {
>> +               WARN_ON_ONCE(!(flags & __GFP_NOWARN));
>>                  return NULL;
>> +       }
>
> Does this fix a real problem you're seeing? __GFP_NOWARN is about not
> warning if a memory allocation fails but this particular WARN_ON
> suggests a kernel bug.

It fixes this warning:

[ 1691.703002] WARNING: CPU: 15 PID: 21519 at mm/slab_common.c:376 
kmalloc_slab+0x2f/0xb0()
[ 1691.706906] can: request_module (can-proto-4) failed.
[ 1691.707827] mpoa: proc_mpc_write: could not parse ''
[ 1691.713952] Modules linked in:
[ 1691.715199] CPU: 15 PID: 21519 Comm: trinity-child15 Tainted: G 
   W    3.10.0-rc4-next-20130607-sasha-00011-gcd78395-dirty #2
[ 1691.719669]  0000000000000009 ffff880020a95e30 ffffffff83ff4041 
0000000000000000
[ 1691.797744]  ffff880020a95e68 ffffffff8111fe12 fffffffffffffff0 
00000000000082d0
[ 1691.802822]  0000000000080000 0000000000080000 0000000001400000 
ffff880020a95e78
[ 1691.807621] Call Trace:
[ 1691.809473]  [<ffffffff83ff4041>] dump_stack+0x4e/0x82
[ 1691.812783]  [<ffffffff8111fe12>] warn_slowpath_common+0x82/0xb0
[ 1691.817011]  [<ffffffff8111fe55>] warn_slowpath_null+0x15/0x20
[ 1691.819936]  [<ffffffff81243dcf>] kmalloc_slab+0x2f/0xb0
[ 1691.824942]  [<ffffffff81278d54>] __kmalloc+0x24/0x4b0
[ 1691.827285]  [<ffffffff8196ffe3>] ? security_capable+0x13/0x20
[ 1691.829405]  [<ffffffff812a26b7>] ? pipe_fcntl+0x107/0x210
[ 1691.831827]  [<ffffffff812a26b7>] pipe_fcntl+0x107/0x210
[ 1691.833651]  [<ffffffff812b7ea0>] ? fget_raw_light+0x130/0x3f0
[ 1691.835343]  [<ffffffff812aa5fb>] SyS_fcntl+0x60b/0x6a0
[ 1691.837008]  [<ffffffff8403ca98>] tracesys+0xe1/0xe6

The caller specifically sets __GFP_NOWARN presumably to avoid this 
warning on slub but I'm not sure if there's any other reason.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
