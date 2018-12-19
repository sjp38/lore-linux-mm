Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A03D8E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 07:46:52 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id f22so22826316qkm.11
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 04:46:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k21sor3198548qvh.10.2018.12.19.04.46.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 04:46:51 -0800 (PST)
Subject: Re: [PATCH] mm: skip checking poison pattern for page_to_nid()
References: <1545172285.18411.26.camel@lca.pw>
 <20181219015732.26179-1-cai@lca.pw> <20181219102010.GF5758@dhcp22.suse.cz>
From: Qian Cai <cai@lca.pw>
Message-ID: <cbfacb4b-dbfd-f68f-3d1e-05e137feca18@lca.pw>
Date: Wed, 19 Dec 2018 07:46:49 -0500
MIME-Version: 1.0
In-Reply-To: <20181219102010.GF5758@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, mingo@kernel.org, hpa@zytor.com, mgorman@techsingularity.net, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/19/18 5:20 AM, Michal Hocko wrote:
> On Tue 18-12-18 20:57:32, Qian Cai wrote:
> [...]
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 5411de93a363..f083f366ea90 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -985,9 +985,7 @@ extern int page_to_nid(const struct page *page);
>>  #else
>>  static inline int page_to_nid(const struct page *page)
>>  {
>> -	struct page *p = (struct page *)page;
>> -
>> -	return (PF_POISONED_CHECK(p)->flags >> NODES_PGSHIFT) & NODES_MASK;
>> +	return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
>>  }
>>  #endif
> 
> I didn't get to think about a proper fix but this is clearly worng. If
> the page is still poisoned then flags are clearly bogus and the node you
> get is a garbage as well. Have you actually tested this patch?
> 

Yes, I did notice that after running for a while triggering some UBSAN
out-of-bounds access warnings. I am still trying to figure out how those
uninitialized page flags survived though after

mm_init
  mem_init
    memblock_free_all
      init_single_page()
