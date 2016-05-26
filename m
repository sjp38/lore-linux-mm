Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0C76B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 05:19:11 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 132so5964959lfz.3
        for <linux-mm@kvack.org>; Thu, 26 May 2016 02:19:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 198si3408624wmj.9.2016.05.26.02.19.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 May 2016 02:19:10 -0700 (PDT)
Subject: Re: [PATCH percpu/for-4.7-fixes 1/2] percpu: fix synchronization
 between chunk->map_extend_work and chunk destruction
References: <5713C0AD.3020102@oracle.com>
 <20160417172943.GA83672@ast-mbp.thefacebook.com> <5742F127.6080000@suse.cz>
 <5742F267.3000309@suse.cz> <20160523213501.GA5383@mtj.duckdns.org>
 <57441396.2050607@suse.cz> <20160524153029.GA3354@mtj.duckdns.org>
 <20160524190433.GC3354@mtj.duckdns.org>
 <CAADnVQ+GprFZJkvCKHVN1gmBMO6uORimsNZ4tE-jgPPOcZhCfA@mail.gmail.com>
 <20160525154419.GE3354@mtj.duckdns.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ced75777-583e-9444-c59f-6cdeb468f1bf@suse.cz>
Date: Thu, 26 May 2016 11:19:06 +0200
MIME-Version: 1.0
In-Reply-To: <20160525154419.GE3354@mtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Alexei Starovoitov <ast@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Linux-MM layout <linux-mm@kvack.org>, Marco Grassi <marco.gra@gmail.com>

On 05/25/2016 05:44 PM, Tejun Heo wrote:
> Atomic allocations can trigger async map extensions which is serviced
> by chunk->map_extend_work.  pcpu_balance_work which is responsible for
> destroying idle chunks wasn't synchronizing properly against
> chunk->map_extend_work and may end up freeing the chunk while the work
> item is still in flight.
>
> This patch fixes the bug by rolling async map extension operations
> into pcpu_balance_work.
>
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-and-tested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Reported-by: Vlastimil Babka <vbabka@suse.cz>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Cc: stable@vger.kernel.org # v3.18+
> Fixes: 9c824b6a172c ("percpu: make sure chunk->map array has available space")

I didn't spot issues, but I'm not that familiar with the code, so it doesn't 
mean much. Just one question below:

> ---
>  mm/percpu.c |   57 ++++++++++++++++++++++++++++++++++++---------------------
>  1 file changed, 36 insertions(+), 21 deletions(-)
>
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -112,7 +112,7 @@ struct pcpu_chunk {
>  	int			map_used;	/* # of map entries used before the sentry */
>  	int			map_alloc;	/* # of map entries allocated */
>  	int			*map;		/* allocation map */
> -	struct work_struct	map_extend_work;/* async ->map[] extension */
> +	struct list_head	map_extend_list;/* on pcpu_map_extend_chunks */
>
>  	void			*data;		/* chunk data */
>  	int			first_free;	/* no free below this */
> @@ -166,6 +166,9 @@ static DEFINE_MUTEX(pcpu_alloc_mutex);	/
>
>  static struct list_head *pcpu_slot __read_mostly; /* chunk list slots */
>
> +/* chunks which need their map areas extended, protected by pcpu_lock */
> +static LIST_HEAD(pcpu_map_extend_chunks);
> +
>  /*
>   * The number of empty populated pages, protected by pcpu_lock.  The
>   * reserved chunk doesn't contribute to the count.
> @@ -395,13 +398,19 @@ static int pcpu_need_to_extend(struct pc
>  {
>  	int margin, new_alloc;
>
> +	lockdep_assert_held(&pcpu_lock);
> +
>  	if (is_atomic) {
>  		margin = 3;
>
>  		if (chunk->map_alloc <
> -		    chunk->map_used + PCPU_ATOMIC_MAP_MARGIN_LOW &&
> -		    pcpu_async_enabled)
> -			schedule_work(&chunk->map_extend_work);
> +		    chunk->map_used + PCPU_ATOMIC_MAP_MARGIN_LOW) {
> +			if (list_empty(&chunk->map_extend_list)) {

So why this list_empty condition? Doesn't it deserve a comment then? And isn't 
using a list an overkill in that case?

Thanks.

> +				list_add_tail(&chunk->map_extend_list,
> +					      &pcpu_map_extend_chunks);
> +				pcpu_schedule_balance_work();
> +			}
> +		}
>  	} else {
>  		margin = PCPU_ATOMIC_MAP_MARGIN_HIGH;
>  	}

[...]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
