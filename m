Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0F6BC3A5AA
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 11:22:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E50620820
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 11:22:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E50620820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B120C6B0278; Thu,  5 Sep 2019 07:22:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9C206B028A; Thu,  5 Sep 2019 07:22:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 915936B028B; Thu,  5 Sep 2019 07:22:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0226.hostedemail.com [216.40.44.226])
	by kanga.kvack.org (Postfix) with ESMTP id 672986B0278
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 07:22:43 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 12BC382437C9
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 11:22:43 +0000 (UTC)
X-FDA: 75900629406.30.join12_51cd45f7b5522
X-HE-Tag: join12_51cd45f7b5522
X-Filterd-Recvd-Size: 10877
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 11:22:42 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1C9BEB685;
	Thu,  5 Sep 2019 11:22:40 +0000 (UTC)
Subject: Re: [rfc 3/4] mm, page_alloc: avoid expensive reclaim when compaction
 may not succeed
To: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>,
 "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>
References: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1909041253390.94813@chino.kir.corp.google.com>
 <20190905090009.GF3838@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 mQINBFZdmxYBEADsw/SiUSjB0dM+vSh95UkgcHjzEVBlby/Fg+g42O7LAEkCYXi/vvq31JTB
 KxRWDHX0R2tgpFDXHnzZcQywawu8eSq0LxzxFNYMvtB7sV1pxYwej2qx9B75qW2plBs+7+YB
 87tMFA+u+L4Z5xAzIimfLD5EKC56kJ1CsXlM8S/LHcmdD9Ctkn3trYDNnat0eoAcfPIP2OZ+
 9oe9IF/R28zmh0ifLXyJQQz5ofdj4bPf8ecEW0rhcqHfTD8k4yK0xxt3xW+6Exqp9n9bydiy
 tcSAw/TahjW6yrA+6JhSBv1v2tIm+itQc073zjSX8OFL51qQVzRFr7H2UQG33lw2QrvHRXqD
 Ot7ViKam7v0Ho9wEWiQOOZlHItOOXFphWb2yq3nzrKe45oWoSgkxKb97MVsQ+q2SYjJRBBH4
 8qKhphADYxkIP6yut/eaj9ImvRUZZRi0DTc8xfnvHGTjKbJzC2xpFcY0DQbZzuwsIZ8OPJCc
 LM4S7mT25NE5kUTG/TKQCk922vRdGVMoLA7dIQrgXnRXtyT61sg8PG4wcfOnuWf8577aXP1x
 6mzw3/jh3F+oSBHb/GcLC7mvWreJifUL2gEdssGfXhGWBo6zLS3qhgtwjay0Jl+kza1lo+Cv
 BB2T79D4WGdDuVa4eOrQ02TxqGN7G0Biz5ZLRSFzQSQwLn8fbwARAQABtCBWbGFzdGltaWwg
 QmFia2EgPHZiYWJrYUBzdXNlLmN6PokCVAQTAQoAPgIbAwULCQgHAwUVCgkICwUWAgMBAAIe
 AQIXgBYhBKlA1DSZLC6OmRA9UCJPp+fMgqZkBQJcbbyGBQkH8VTqAAoJECJPp+fMgqZkpGoP
 /1jhVihakxw1d67kFhPgjWrbzaeAYOJu7Oi79D8BL8Vr5dmNPygbpGpJaCHACWp+10KXj9yz
 fWABs01KMHnZsAIUytVsQv35DMMDzgwVmnoEIRBhisMYOQlH2bBn/dqBjtnhs7zTL4xtqEcF
 1hoUFEByMOey7gm79utTk09hQE/Zo2x0Ikk98sSIKBETDCl4mkRVRlxPFl4O/w8dSaE4eczH
 LrKezaFiZOv6S1MUKVKzHInonrCqCNbXAHIeZa3JcXCYj1wWAjOt9R3NqcWsBGjFbkgoKMGD
 usiGabetmQjXNlVzyOYdAdrbpVRNVnaL91sB2j8LRD74snKsV0Wzwt90YHxDQ5z3M75YoIdl
 byTKu3BUuqZxkQ/emEuxZ7aRJ1Zw7cKo/IVqjWaQ1SSBDbZ8FAUPpHJxLdGxPRN8Pfw8blKY
 8mvLJKoF6i9T6+EmlyzxqzOFhcc4X5ig5uQoOjTIq6zhLO+nqVZvUDd2Kz9LMOCYb516cwS/
 Enpi0TcZ5ZobtLqEaL4rupjcJG418HFQ1qxC95u5FfNki+YTmu6ZLXy+1/9BDsPuZBOKYpUm
 3HWSnCS8J5Ny4SSwfYPH/JrtberWTcCP/8BHmoSpS/3oL3RxrZRRVnPHFzQC6L1oKvIuyXYF
 rkybPXYbmNHN+jTD3X8nRqo+4Qhmu6SHi3VquQENBFsZNQwBCACuowprHNSHhPBKxaBX7qOv
 KAGCmAVhK0eleElKy0sCkFghTenu1sA9AV4okL84qZ9gzaEoVkgbIbDgRbKY2MGvgKxXm+kY
 n8tmCejKoeyVcn9Xs0K5aUZiDz4Ll9VPTiXdf8YcjDgeP6/l4kHb4uSW4Aa9ds0xgt0gP1Xb
 AMwBlK19YvTDZV5u3YVoGkZhspfQqLLtBKSt3FuxTCU7hxCInQd3FHGJT/IIrvm07oDO2Y8J
 DXWHGJ9cK49bBGmK9B4ajsbe5GxtSKFccu8BciNluF+BqbrIiM0upJq5Xqj4y+Xjrpwqm4/M
 ScBsV0Po7qdeqv0pEFIXKj7IgO/d4W2bABEBAAGJA3IEGAEKACYWIQSpQNQ0mSwujpkQPVAi
 T6fnzIKmZAUCWxk1DAIbAgUJA8JnAAFACRAiT6fnzIKmZMB0IAQZAQoAHRYhBKZ2GgCcqNxn
 k0Sx9r6Fd25170XjBQJbGTUMAAoJEL6Fd25170XjDBUH/2jQ7a8g+FC2qBYxU/aCAVAVY0NE
 YuABL4LJ5+iWwmqUh0V9+lU88Cv4/G8fWwU+hBykSXhZXNQ5QJxyR7KWGy7LiPi7Cvovu+1c
 9Z9HIDNd4u7bxGKMpn19U12ATUBHAlvphzluVvXsJ23ES/F1c59d7IrgOnxqIcXxr9dcaJ2K
 k9VP3TfrjP3g98OKtSsyH0xMu0MCeyewf1piXyukFRRMKIErfThhmNnLiDbaVy6biCLx408L
 Mo4cCvEvqGKgRwyckVyo3JuhqreFeIKBOE1iHvf3x4LU8cIHdjhDP9Wf6ws1XNqIvve7oV+w
 B56YWoalm1rq00yUbs2RoGcXmtX1JQ//aR/paSuLGLIb3ecPB88rvEXPsizrhYUzbe1TTkKc
 4a4XwW4wdc6pRPVFMdd5idQOKdeBk7NdCZXNzoieFntyPpAq+DveK01xcBoXQ2UktIFIsXey
 uSNdLd5m5lf7/3f0BtaY//f9grm363NUb9KBsTSnv6Vx7Co0DWaxgC3MFSUhxzBzkJNty+2d
 10jvtwOWzUN+74uXGRYSq5WefQWqqQNnx+IDb4h81NmpIY/X0PqZrapNockj3WHvpbeVFAJ0
 9MRzYP3x8e5OuEuJfkNnAbwRGkDy98nXW6fKeemREjr8DWfXLKFWroJzkbAVmeIL0pjXATxr
 +tj5JC0uvMrrXefUhXTo0SNoTsuO/OsAKOcVsV/RHHTwCDR2e3W8mOlA3QbYXsscgjghbuLh
 J3oTRrOQa8tUXWqcd5A0+QPo5aaMHIK0UAthZsry5EmCY3BrbXUJlt+23E93hXQvfcsmfi0N
 rNh81eknLLWRYvMOsrbIqEHdZBT4FHHiGjnck6EYx/8F5BAZSodRVEAgXyC8IQJ+UVa02QM5
 D2VL8zRXZ6+wARKjgSrW+duohn535rG/ypd0ctLoXS6dDrFokwTQ2xrJiLbHp9G+noNTHSan
 ExaRzyLbvmblh3AAznb68cWmM3WVkceWACUalsoTLKF1sGrrIBj5updkKkzbKOq5gcC5AQ0E
 Wxk1NQEIAJ9B+lKxYlnKL5IehF1XJfknqsjuiRzj5vnvVrtFcPlSFL12VVFVUC2tT0A1Iuo9
 NAoZXEeuoPf1dLDyHErrWnDyn3SmDgb83eK5YS/K363RLEMOQKWcawPJGGVTIRZgUSgGusKL
 NuZqE5TCqQls0x/OPljufs4gk7E1GQEgE6M90Xbp0w/r0HB49BqjUzwByut7H2wAdiNAbJWZ
 F5GNUS2/2IbgOhOychHdqYpWTqyLgRpf+atqkmpIJwFRVhQUfwztuybgJLGJ6vmh/LyNMRr8
 J++SqkpOFMwJA81kpjuGR7moSrUIGTbDGFfjxmskQV/W/c25Xc6KaCwXah3OJ40AEQEAAYkC
 PAQYAQoAJhYhBKlA1DSZLC6OmRA9UCJPp+fMgqZkBQJbGTU1AhsMBQkDwmcAAAoJECJPp+fM
 gqZkPN4P/Ra4NbETHRj5/fM1fjtngt4dKeX/6McUPDIRuc58B6FuCQxtk7sX3ELs+1+w3eSV
 rHI5cOFRSdgw/iKwwBix8D4Qq0cnympZ622KJL2wpTPRLlNaFLoe5PkoORAjVxLGplvQIlhg
 miljQ3R63ty3+MZfkSVsYITlVkYlHaSwP2t8g7yTVa+q8ZAx0NT9uGWc/1Sg8j/uoPGrctml
 hFNGBTYyPq6mGW9jqaQ8en3ZmmJyw3CHwxZ5FZQ5qc55xgshKiy8jEtxh+dgB9d8zE/S/UGI
 E99N/q+kEKSgSMQMJ/CYPHQJVTi4YHh1yq/qTkHRX+ortrF5VEeDJDv+SljNStIxUdroPD29
 2ijoaMFTAU+uBtE14UP5F+LWdmRdEGS1Ah1NwooL27uAFllTDQxDhg/+LJ/TqB8ZuidOIy1B
 xVKRSg3I2m+DUTVqBy7Lixo73hnW69kSjtqCeamY/NSu6LNP+b0wAOKhwz9hBEwEHLp05+mj
 5ZFJyfGsOiNUcMoO/17FO4EBxSDP3FDLllpuzlFD7SXkfJaMWYmXIlO0jLzdfwfcnDzBbPwO
 hBM8hvtsyq8lq8vJOxv6XD6xcTtj5Az8t2JjdUX6SF9hxJpwhBU0wrCoGDkWp4Bbv6jnF7zP
 Nzftr4l8RuJoywDIiJpdaNpSlXKpj/K6KrnyAI/joYc7
Message-ID: <fab91766-da33-d62f-59fb-c226e4790a91@suse.cz>
Date: Thu, 5 Sep 2019 13:22:39 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190905090009.GF3838@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/5/19 11:00 AM, Michal Hocko wrote:
> [Ccing Mike for checking on the hugetlb side of this change]
> 
> On Wed 04-09-19 12:54:22, David Rientjes wrote:
>> Memory compaction has a couple significant drawbacks as the allocation
>> order increases, specifically:
>>
>>  - isolate_freepages() is responsible for finding free pages to use as
>>    migration targets and is implemented as a linear scan of memory
>>    starting at the end of a zone,

Note that's no longer entirely true, see fast_isolate_freepages().

>>  - failing order-0 watermark checks in memory compaction does not account
>>    for how far below the watermarks the zone actually is: to enable
>>    migration, there must be *some* free memory available.  Per the above,
>>    watermarks are not always suffficient if isolate_freepages() cannot
>>    find the free memory but it could require hundreds of MBs of reclaim to
>>    even reach this threshold (read: potentially very expensive reclaim with
>>    no indication compaction can be successful), and

I doubt it's hundreds of MBs for a 2MB hugepage.

>>  - if compaction at this order has failed recently so that it does not even
>>    run as a result of deferred compaction, looping through reclaim can often
>>    be pointless.

Agreed.

>> For hugepage allocations, these are quite substantial drawbacks because
>> these are very high order allocations (order-9 on x86) and falling back to
>> doing reclaim can potentially be *very* expensive without any indication
>> that compaction would even be successful.

You seem to lump together hugetlbfs and THP here, by saying "hugepage",
but these are very different things - hugetlbfs reservations are
expected to be potentially expensive.

>> Reclaim itself is unlikely to free entire pageblocks and certainly no
>> reliance should be put on it to do so in isolation (recall lumpy reclaim).
>> This means we should avoid reclaim and simply fail hugepage allocation if
>> compaction is deferred.

It is however possible that reclaim frees enough to make even a
previously deferred compaction succeed.

>> It is also not helpful to thrash a zone by doing excessive reclaim if
>> compaction may not be able to access that memory.  If order-0 watermarks
>> fail and the allocation order is sufficiently large, it is likely better
>> to fail the allocation rather than thrashing the zone.
>>
>> Signed-off-by: David Rientjes <rientjes@google.com>
>> ---
>>  mm/page_alloc.c | 22 ++++++++++++++++++++++
>>  1 file changed, 22 insertions(+)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -4458,6 +4458,28 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>  		if (page)
>>  			goto got_pg;
>>  
>> +		 if (order >= pageblock_order && (gfp_mask & __GFP_IO)) {
>> +			/*
>> +			 * If allocating entire pageblock(s) and compaction
>> +			 * failed because all zones are below low watermarks
>> +			 * or is prohibited because it recently failed at this
>> +			 * order, fail immediately.
>> +			 *
>> +			 * Reclaim is
>> +			 *  - potentially very expensive because zones are far
>> +			 *    below their low watermarks or this is part of very
>> +			 *    bursty high order allocations,
>> +			 *  - not guaranteed to help because isolate_freepages()
>> +			 *    may not iterate over freed pages as part of its
>> +			 *    linear scan, and
>> +			 *  - unlikely to make entire pageblocks free on its
>> +			 *    own.
>> +			 */
>> +			if (compact_result == COMPACT_SKIPPED ||
>> +			    compact_result == COMPACT_DEFERRED)
>> +				goto nopage;

As I said, I expect this will make hugetlbfs reservations fail
prematurely - Mike can probably confirm or disprove that.
I think it also addresses consequences, not the primary problem, IMHO.
I believe the primary problem is that we reclaim something even if
there's enough memory for compaction. This won't change with your patch,
as compact_result won't be SKIPPED in that case. Then we continue
through to __alloc_pages_direct_reclaim(), shrink_zones() which will
call compaction_ready(), which will only return true and skip reclaim of
the zone, if there's high_watermark (!!!) + compact_gap() pages. But as
long as one zone isn't compaction_ready(), we enter shrink_node(), which
will reclaim something and call should_continue_reclaim() where we might
finally notice that compaction_suitable() returns CONTINUE, and abort
reclaim.

Thus I think the right solution might be to really avoid reclaim for
zones where compaction is not skipped, while your patch avoids reclaim
when compaction is skipped. The per-node reclaim vs per-zone compaction
might complicate those decisions a lot, though.

>> +		}
>> +
>>  		/*
>>  		 * Checks for costly allocations with __GFP_NORETRY, which
>>  		 * includes THP page fault allocations
> 


