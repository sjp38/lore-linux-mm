Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B54D2831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 06:25:38 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g67so8318029wrd.0
        for <linux-mm@kvack.org>; Thu, 18 May 2017 03:25:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b143si6115176wme.100.2017.05.18.03.25.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 May 2017 03:25:36 -0700 (PDT)
Subject: Re: [PATCH v2 3/6] mm, page_alloc: pass preferred nid instead of
 zonelist to allocator
References: <20170517081140.30654-1-vbabka@suse.cz>
 <20170517081140.30654-4-vbabka@suse.cz>
 <alpine.DEB.2.20.1705171009340.8714@east.gentwo.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c748a22c-9a94-52cb-2247-afc281cc5d78@suse.cz>
Date: Thu, 18 May 2017 12:25:03 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1705171009340.8714@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dimitri Sivanich <sivanich@sgi.com>

On 05/17/2017 05:19 PM, Christoph Lameter wrote:
> On Wed, 17 May 2017, Vlastimil Babka wrote:
> 
>>  struct page *
>> -__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>> -		       struct zonelist *zonelist, nodemask_t *nodemask);
>> +__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
>> +							nodemask_t *nodemask);
>>
>>  static inline struct page *
>> -__alloc_pages(gfp_t gfp_mask, unsigned int order,
>> -		struct zonelist *zonelist)
>> +__alloc_pages(gfp_t gfp_mask, unsigned int order, int preferred_nid)
>>  {
>> -	return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
>> +	return __alloc_pages_nodemask(gfp_mask, order, preferred_nid, NULL);
>>  }
> 
> Maybe use nid instead of preferred_nid like in __alloc_pages? Otherwise
> there may be confusion with the MPOL_PREFER policy.

I'll think about that.

>> @@ -1963,8 +1960,8 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>>  {
>>  	struct mempolicy *pol;
>>  	struct page *page;
>> +	int preferred_nid;
>>  	unsigned int cpuset_mems_cookie;
>> -	struct zonelist *zl;
>>  	nodemask_t *nmask;
> 
> Same here.
> 
>> @@ -4012,8 +4012,8 @@ static inline void finalise_ac(gfp_t gfp_mask,
>>   * This is the 'heart' of the zoned buddy allocator.
>>   */
>>  struct page *
>> -__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>> -			struct zonelist *zonelist, nodemask_t *nodemask)
>> +__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
>> +							nodemask_t *nodemask)
>>  {
> 
> and here
> 
> This looks clean to me. Still feel a bit uneasy about this since I do
> remember that we had a reason to use zonelists instead of nodes back then
> but cannot remember what that reason was....

My history digging showed me that mempolicies used to have a custom
zonelist attached, not nodemask. So I supposed that's why.

> CCing Dimitri at SGI. This may break a lot of legacy SGIapps. If you read
> this Dimitri then please review this patchset and the discussions around
> it.

Break how? This shouldn't break any apps AFAICS, just out-of-tree kernel
patches/modules as usual when APIs change.

> Reviewed-by: Christoph Lameter <cl@linux.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
