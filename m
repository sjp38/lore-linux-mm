Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 748C9C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:21:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A8342173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:21:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A8342173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABDF46B0006; Thu, 28 Mar 2019 19:21:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1E3A6B0007; Thu, 28 Mar 2019 19:21:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C1126B0008; Thu, 28 Mar 2019 19:21:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 634CB6B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:21:31 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d139so220250qke.20
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 16:21:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=uEVPzSKffhuZT44tSuyQZ+C0VyXM4wvhMw0fFeadUcc=;
        b=ekylZqbgYuyWW7nYcW7lxNNXOUueUdwSI0g3LG10gkNGZfSsolAL+FetONFO3BmwOM
         NkjbJ8oEVhLXiW/e/DcpD28umCFpggYLHcXlwhYk6R5GS3hn33UJcowPkdBW7CwgA5y/
         iOEB6UU93fGN5kFhpXh8OuV4EByVRHnLfZj8dnMeib7sQxuCk9iLXYGTEzwKXid5bXU+
         MvAWDR7LOpPok+BOMXe7gXo+Q+VqDxqTJIZNTuU20lojbowBRn+fO6G/DIMbRcADYD6f
         1DpYd7YfuAU/wbNFZcQsRvO2nySEmB4IgC1z83gPVyogI9zbS3Fy1SHnYwv83n7ikwY6
         Uxqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVQc7aSbc0vgk7WdNQgQ19HMnuzstfoqrPD9P7BjIy+7P1uJuTS
	T6h+SjolWchaiIJK4cEvVaJjbzxCzHo38yFqCwWFPxtXTLv7r5rzLlpqgWIPipPERjZt7SoTQIP
	LlKzZRZ5sDhCYxEA9Z4/u0XmYbwgmD8MBsAV5/v2qQUip7ZX31NNDW+pgr3SJTkXCNw==
X-Received: by 2002:aed:2a22:: with SMTP id c31mr39462382qtd.49.1553815291126;
        Thu, 28 Mar 2019 16:21:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxE5gdT6HgjW+AM0OU5QqHec+afTVTqlfHIyxcJ4j5WgjlvDhdCs+ys6VJiwG1yHMU7RzW6
X-Received: by 2002:aed:2a22:: with SMTP id c31mr39462330qtd.49.1553815290316;
        Thu, 28 Mar 2019 16:21:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553815290; cv=none;
        d=google.com; s=arc-20160816;
        b=icWMxvHeG6ujAlf7TbqlEe7eZhDOz8aYW9EgS9aPVaexqwXb59bGpjLO/XGo0aaLrp
         b9H3LG7DW0w40+wcg1vAgMJKYL4t0JIbm7C7YfB9lBR1Q+lMGoeQ0qXNd160OjP8YPIc
         umUjXxOtfteCOJYsX82b4RaOufvQ+Mzn8Qkk1/klHyM8PePeJRZYG/j3lNZezBF/A62k
         Gr8a9I1CtT4JdE1jSNmFsoKOAaMMDhOub+el7p7pAGdPWhiu+6qZBNpF8TJDxYiACd2c
         A8u5oabzbiAGQSQ6kIqRJWuqiDaUOr8M8zzs8igUd68AzCydRPWLKPZVSNocLuQJC/zV
         CxXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=uEVPzSKffhuZT44tSuyQZ+C0VyXM4wvhMw0fFeadUcc=;
        b=o/JIiBpD+wD10veckXNwmGZGFS4QI6gEXd793KABOoJYfyAJwlXZO4vb6MVloQC8dE
         ECt+ksoL8PdH6RBq6QptNPx5nzE/EgIKdP87ZWmgBgPGnTb5HTMwEoWxmiHBXqY0A63D
         jVIA6Orsku1eRldS50YK0+egYXOcRf219gkIT8O0FGDgYHZgfIJ4RkbI7gxLVYh3CyaT
         lOLdmnczwFA1HwSgUaEcBjFcXTpIpOCCydGIAK4qy0KO8A+txYjxew9SzafvXUPw2xzc
         bdF+B/0vOY2pYoKWURMSM79EvXmUrOObU9t3uPneFhJXHbVJ/ApD4aOzIkNSa0HxELmB
         wgHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 94si260226qtc.15.2019.03.28.16.21.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 16:21:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 56526308338E;
	Thu, 28 Mar 2019 23:21:29 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6A41F1001DC5;
	Thu, 28 Mar 2019 23:21:28 +0000 (UTC)
Date: Thu, 28 Mar 2019 19:21:26 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 07/11] mm/hmm: add default fault flags to avoid the
 need to pre-fill pfns arrays.
Message-ID: <20190328232125.GJ13560@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-8-jglisse@redhat.com>
 <2f790427-ea87-b41e-b386-820ccdb7dd38@nvidia.com>
 <20190328221203.GF13560@redhat.com>
 <555ad864-d1f9-f513-9666-0d3d05dbb85d@nvidia.com>
 <20190328223153.GG13560@redhat.com>
 <768f56f5-8019-06df-2c5a-b4187deaac59@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <768f56f5-8019-06df-2c5a-b4187deaac59@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Thu, 28 Mar 2019 23:21:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 03:40:42PM -0700, John Hubbard wrote:
> On 3/28/19 3:31 PM, Jerome Glisse wrote:
> > On Thu, Mar 28, 2019 at 03:19:06PM -0700, John Hubbard wrote:
> >> On 3/28/19 3:12 PM, Jerome Glisse wrote:
> >>> On Thu, Mar 28, 2019 at 02:59:50PM -0700, John Hubbard wrote:
> >>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> >>>>> From: Jérôme Glisse <jglisse@redhat.com>
> >>>>>
> >>>>> The HMM mirror API can be use in two fashions. The first one where the HMM
> >>>>> user coalesce multiple page faults into one request and set flags per pfns
> >>>>> for of those faults. The second one where the HMM user want to pre-fault a
> >>>>> range with specific flags. For the latter one it is a waste to have the user
> >>>>> pre-fill the pfn arrays with a default flags value.
> >>>>>
> >>>>> This patch adds a default flags value allowing user to set them for a range
> >>>>> without having to pre-fill the pfn array.
> >>>>>
> >>>>> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> >>>>> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> >>>>> Cc: Andrew Morton <akpm@linux-foundation.org>
> >>>>> Cc: John Hubbard <jhubbard@nvidia.com>
> >>>>> Cc: Dan Williams <dan.j.williams@intel.com>
> >>>>> ---
> >>>>>  include/linux/hmm.h |  7 +++++++
> >>>>>  mm/hmm.c            | 12 ++++++++++++
> >>>>>  2 files changed, 19 insertions(+)
> >>>>>
> >>>>> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> >>>>> index 79671036cb5f..13bc2c72f791 100644
> >>>>> --- a/include/linux/hmm.h
> >>>>> +++ b/include/linux/hmm.h
> >>>>> @@ -165,6 +165,8 @@ enum hmm_pfn_value_e {
> >>>>>   * @pfns: array of pfns (big enough for the range)
> >>>>>   * @flags: pfn flags to match device driver page table
> >>>>>   * @values: pfn value for some special case (none, special, error, ...)
> >>>>> + * @default_flags: default flags for the range (write, read, ...)
> >>>>> + * @pfn_flags_mask: allows to mask pfn flags so that only default_flags matter
> >>>>>   * @pfn_shifts: pfn shift value (should be <= PAGE_SHIFT)
> >>>>>   * @valid: pfns array did not change since it has been fill by an HMM function
> >>>>>   */
> >>>>> @@ -177,6 +179,8 @@ struct hmm_range {
> >>>>>  	uint64_t		*pfns;
> >>>>>  	const uint64_t		*flags;
> >>>>>  	const uint64_t		*values;
> >>>>> +	uint64_t		default_flags;
> >>>>> +	uint64_t		pfn_flags_mask;
> >>>>>  	uint8_t			pfn_shift;
> >>>>>  	bool			valid;
> >>>>>  };
> >>>>> @@ -521,6 +525,9 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> >>>>>  {
> >>>>>  	long ret;
> >>>>>  
> >>>>> +	range->default_flags = 0;
> >>>>> +	range->pfn_flags_mask = -1UL;
> >>>>
> >>>> Hi Jerome,
> >>>>
> >>>> This is nice to have. Let's constrain it a little bit more, though: the pfn_flags_mask
> >>>> definitely does not need to be a run time value. And we want some assurance that
> >>>> the mask is 
> >>>> 	a) large enough for the flags, and
> >>>> 	b) small enough to avoid overrunning the pfns field.
> >>>>
> >>>> Those are less certain with a run-time struct field, and more obviously correct with
> >>>> something like, approximately:
> >>>>
> >>>>  	#define PFN_FLAGS_MASK 0xFFFF
> >>>>
> >>>> or something.
> >>>>
> >>>> In other words, this is more flexibility than we need--just a touch too much,
> >>>> IMHO.
> >>>
> >>> This mirror the fact that flags are provided as an array and some devices use
> >>> the top bits for flags (read, write, ...). So here it is the safe default to
> >>> set it to -1. If the caller want to leverage this optimization it can override
> >>> the default_flags value.
> >>>
> >>
> >> Optimization? OK, now I'm a bit lost. Maybe this is another place where I could
> >> use a peek at the calling code. The only flags I've seen so far use the bottom
> >> 3 bits and that's it. 
> >>
> >> Maybe comments here?
> >>
> >>>>
> >>>>> +
> >>>>>  	ret = hmm_range_register(range, range->vma->vm_mm,
> >>>>>  				 range->start, range->end);
> >>>>>  	if (ret)
> >>>>> diff --git a/mm/hmm.c b/mm/hmm.c
> >>>>> index fa9498eeb9b6..4fe88a196d17 100644
> >>>>> --- a/mm/hmm.c
> >>>>> +++ b/mm/hmm.c
> >>>>> @@ -415,6 +415,18 @@ static inline void hmm_pte_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
> >>>>>  	if (!hmm_vma_walk->fault)
> >>>>>  		return;
> >>>>>  
> >>>>> +	/*
> >>>>> +	 * So we not only consider the individual per page request we also
> >>>>> +	 * consider the default flags requested for the range. The API can
> >>>>> +	 * be use in 2 fashions. The first one where the HMM user coalesce
> >>>>> +	 * multiple page fault into one request and set flags per pfns for
> >>>>> +	 * of those faults. The second one where the HMM user want to pre-
> >>>>> +	 * fault a range with specific flags. For the latter one it is a
> >>>>> +	 * waste to have the user pre-fill the pfn arrays with a default
> >>>>> +	 * flags value.
> >>>>> +	 */
> >>>>> +	pfns = (pfns & range->pfn_flags_mask) | range->default_flags;
> >>>>
> >>>> Need to verify that the mask isn't too large or too small.
> >>>
> >>> I need to check agin but default flag is anded somewhere to limit
> >>> the bit to the one we expect.
> >>
> >> Right, but in general, the *mask* could be wrong. It would be nice to have
> >> an assert, and/or a comment, or something to verify the mask is proper.
> >>
> >> Really, a hardcoded mask is simple and correct--unless it *definitely* must
> >> vary for devices of course.
> > 
> > Ok so re-read the code and it is correct. The helper for compatibility with
> > old API (so that i do not break nouveau upstream code) initialize those to
> > the safe default ie:
> > 
> > range->default_flags = 0;
> > range->pfn_flags_mask = -1;
> > 
> > Which means that in the above comment we are in the case where it is the
> > individual entry within the pfn array that will determine if we fault or
> > not.
> > 
> > Driver using the new API can either use this safe default or use the
> > second case in the above comment and set default_flags to something
> > else than 0.
> > 
> > Note that those default_flags are not set in the final result they are
> > use to determine if we need to do a page fault. For instance if you set
> > the write bit in the default flags then the pfns computed above will
> > have the write bit set and when we compare with the CPU pte if the CPU
> > pte do not have the write bit set then we will fault. What matter is
> > that in this case the value within the pfns array is totaly pointless
> > ie we do not care what it is, it will not affect the decission ie the
> > decision is made by looking at the default flags.
> > 
> > Hope this clarify thing. You can look at the ODP patch to see how it
> > is use:
> > 
> > https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-odp-v2&id=eebd4f3095290a16ebc03182e2d3ab5dfa7b05ec
> > 
> 
> Hi Jerome,
> 
> I think you're talking about flags, but I'm talking about the mask. The 
> above link doesn't appear to use the pfn_flags_mask, and the default_flags 
> that it uses are still in the same lower 3 bits:
> 
> +static uint64_t odp_hmm_flags[HMM_PFN_FLAG_MAX] = {
> +	ODP_READ_BIT,	/* HMM_PFN_VALID */
> +	ODP_WRITE_BIT,	/* HMM_PFN_WRITE */
> +	ODP_DEVICE_BIT,	/* HMM_PFN_DEVICE_PRIVATE */
> +};
> 
> So I still don't see why we need the flexibility of a full 0xFFFFFFFFFFFFFFFF
> mask, that is *also* runtime changeable. 

So the pfn array is using a device driver specific format and we have
no idea nor do we need to know where the valid, write, ... bit are in
that format. Those bits can be in the top 60 bits like 63, 62, 61, ...
we do not care. They are device with bit at the top and for those you
need a mask that allows you to mask out those bits or not depending on
what the user want to do.

The mask here is against an _unknown_ (from HMM POV) format. So we can
not presume where the bits will be and thus we can not presume what a
proper mask is.

So that's why a full unsigned long mask is use here.

Maybe an example will help let say the device flag are:
    VALID (1 << 63)
    WRITE (1 << 62)

Now let say that device wants to fault with at least read a range
it does set:
    range->default_flags = (1 << 63)
    range->pfn_flags_mask = 0;

This will fill fault all page in the range with at least read
permission.

Now let say it wants to do the same except for one page in the range
for which its want to have write. Now driver set:
    range->default_flags = (1 << 63);
    range->pfn_flags_mask = (1 << 62);
    range->pfns[index_of_write] = (1 << 62);

With this HMM will fault in all page with at least read (ie valid)
and for the address: range->start + index_of_write << PAGE_SHIFT it
will fault with write permission ie if the CPU pte does not have
write permission set then handle_mm_fault() will be call asking for
write permission.


Note that in the above HMM will populate the pfns array with write
permission for any entry that have write permission within the CPU
pte ie the default_flags and pfn_flags_mask is only the minimun
requirement but HMM always returns all the flag that are set in the
CPU pte.


Now let say you are an "old" driver like nouveau upstream, then it
means that you are setting each individual entry within range->pfns
with the exact flags you want for each address hence here what you
want is:
    range->default_flags = 0;
    range->pfn_flags_mask = -1UL;

So that what we do is (for each entry):
    (range->pfns[index] & range->pfn_flags_mask) | range->default_flags
and we end up with the flags that were set by the driver for each of
the individual range->pfns entries.


Does this help ?

Cheers,
Jérôme

