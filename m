Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 852D6C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 20:43:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1933E2146E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 20:43:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1933E2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=talpey.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49A7E6B0007; Tue, 19 Mar 2019 16:43:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 449806B0008; Tue, 19 Mar 2019 16:43:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 311186B000A; Tue, 19 Mar 2019 16:43:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 057FF6B0007
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:43:48 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id c74so28858668ywc.9
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 13:43:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=u4qLXRcCaqq3XD8ChuyO2Uqs5602EE6/MUhQ+Z8Yqtg=;
        b=SsBA8RsdNyCD6ZkVJoSKoEThxOfcJjqPmxDZUJdBCs7rdcKvCqQNH+msKq+d7aVzZK
         4UFAJQgSCgd9g+PfhiTHnp1elisZsE25lu1HnBobi6MrH6ux9Q7QeeBOdMLnGjdUGu+e
         pIqiz5w4aqIobJLq+XNCsp6S4CsfAg/QSiYq5FcOPW81VTdT96v7O561UkONvrMPvssK
         XMCmKcpAFjdKR5h7ZFEON4Yk4bN+FRKpU/fbU7Lp4XcK6+kSGndcdNcnf5A6zvcd8JZn
         4hX8b6fwpNqlARQcn1EJAPLFmRSVCbLZEE8xnWeN0DGtCfhnIQGot7x4iA7MuhjJ6qFF
         Y1hQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 68.178.252.102 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
X-Gm-Message-State: APjAAAXIEj/+uNPN2i7kqsK+x5uKthC3LAFhn4971vVqEBcFTaj1dY67
	hAcZpJF0Hx5cDtKGr1wWFbhPnPwRvdZFXY0kbtwEEQRnn9W+p4TaCPzznNpwj2+If201lb8NqC7
	bri8kyEoRwOKY29D3U+QnWfDt82Fm6xOIUi9z+xrCc5wKdhdou9ZlNsyH63MqdbA=
X-Received: by 2002:a25:b1a1:: with SMTP id h33mr3809606ybj.270.1553028227597;
        Tue, 19 Mar 2019 13:43:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLYqcGWAIaqpzNeFbNPZBX85mGsYURPGE8oYUKhb2nCFgwd6JIfC8r+9bSH37J5uD6BRSz
X-Received: by 2002:a25:b1a1:: with SMTP id h33mr3809559ybj.270.1553028226687;
        Tue, 19 Mar 2019 13:43:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553028226; cv=none;
        d=google.com; s=arc-20160816;
        b=fIK4KTZD24fDDKD/hhrAevwtbqTN0gAo8HWyjpYMi3oqtiAK2274rk55gCWGTaCLp9
         RGmlTW3UnvmHmOtYYL71k6YZmaw5l792JROzWqIKLFQAqvseHAdVltP0F1Vzxkir62LJ
         6ctaj6b5NDo1cwMxagoYaos848Bhxh/VBSHU1mMouskGvIkgSGZdnSRJ1zhr8YC1nDn2
         wqKxeHM2lqGIyyACLvm9sfCEQhYKZFB8XEjCDcHqCuE9oi74dXcHtrNgPg7ObztjuQsA
         c2685CHFjQvE0Rqty3lAsIVhGYGfzN9DEwetzQEFpZl8hOUaAPd74/GxQvCuefHEm/wG
         DRfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=u4qLXRcCaqq3XD8ChuyO2Uqs5602EE6/MUhQ+Z8Yqtg=;
        b=lg6mJknqrkGpIJQp7FmKFBqrz9Jyx2sXJrBs+I2lfY6+eXiiPc3Mpjpr+z8QAnZJoh
         lTILXykMx+9QHgGEZ4NFLFOf8ybHZ08MohC2OPzMBL3T5j0snfFbF097cNb5iSomJI2e
         M8HcfIiJ/71sGYyor0fK2bLTR6vNyUBVqt8xN/nZMAUA5bHyjp0+wSf9ie+Fg2YGQONV
         uzIh7PxXejaxwJedxeStktolESROEvg1XjWy2imopDbzIiNG8sGbtpMbttsxL3QYozO1
         5pcrAfLemZCpWZ8UTIea6e2cTym3Q2a9rQIcivQvzoKpfoFLy+BK2mkvHP6ojrNde6SH
         fTLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 68.178.252.102 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
Received: from p3plsmtpa11-01.prod.phx3.secureserver.net (p3plsmtpa11-01.prod.phx3.secureserver.net. [68.178.252.102])
        by mx.google.com with ESMTPS id i6si28435ybk.165.2019.03.19.13.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 13:43:46 -0700 (PDT)
Received-SPF: neutral (google.com: 68.178.252.102 is neither permitted nor denied by best guess record for domain of tom@talpey.com) client-ip=68.178.252.102;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 68.178.252.102 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
Received: from [10.10.38.206] ([139.138.146.66])
	by :SMTPAUTH: with ESMTPSA
	id 6LaKhOUO4K1jK6LaKhFqDp; Tue, 19 Mar 2019 13:43:46 -0700
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
To: Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
 Jerome Glisse <jglisse@redhat.com>, john.hubbard@gmail.com,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>,
 Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>,
 Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>,
 Dennis Dalessandro <dennis.dalessandro@intel.com>,
 Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
 Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>,
 Mike Rapoport <rppt@linux.ibm.com>,
 Mike Marciniszyn <mike.marciniszyn@intel.com>,
 Ralph Campbell <rcampbell@nvidia.com>, LKML <linux-kernel@vger.kernel.org>,
 linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
 Andrea Arcangeli <aarcange@redhat.com>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com> <20190319141416.GA3879@redhat.com>
 <20190319142918.6a5vom55aeojapjp@kshutemo-mobl1>
 <20190319153644.GB26099@quack2.suse.cz>
 <20190319090322.GE7485@iweiny-DESK2.sc.intel.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <f9195df4-66ca-95f6-874e-d19cd775794d@talpey.com>
Date: Tue, 19 Mar 2019 15:43:44 -0500
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190319090322.GE7485@iweiny-DESK2.sc.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CMAE-Envelope: MS4wfN68ogHI//w010AOOp/HiIKMI+WedmJjAfCUDtxFhhDVGnjPk04WBXY2mLLWMKbpDReApTSBOCQizPAeuLqpYMbwcbWkdCv0lExYdkQDqOgifQ1qlW81
 eUAFG+FD7SEdo0ezn5Tu+wBkJdLBZ5+6oUIhCUnhEDCHPYua5JMWgzd3pgerrhRgr9EMHq74vwzcr2HhGrdhj+alNY3YKk3JEGq2VfUIqCsybjvNmj1Tc8V0
 bTQLXZTtHQGzuY+EKmgTSSGcvmr77Cm2vbGY6JS0ezq3fwtYtHMHjOhkwhDaYFfqXNbdkDxeqlrIMi/ANE95sVSnhvosYwZIvzA6rmfgVLpPk/7aVr4eI7dp
 eMdSB2AZyUs064blgdnsUFcBU/JjxfQLkYvtEoJv1GEzxdnccd5Nkw//roQAG5GLEvFQ47pv16cEIVT0AO2IoOriZjpLkLOav1tNInyTwF6SfyKRxcoVanm5
 Dp6l/ldmndbSQ+9j60cRk46Pe4R6nMQodYQpycFFLOg5hz13Y4aHT7wbHYQpWcdpL0DiJp2KXWZQJMbfEhvGzpLS9EdsrjRrelNCOiwvck7ZLp6nLamI4Gge
 hh4ATvQ3Su6XlUfHNMFIYy1M9MiqrkCFoy+bvsl05dCIyuiW6u7tvkSPVoearPn6QB5TKdq4eqRzx8Br3yQ5Qb02SUiDuf+eStUeL77EwlBpQdhacDgV/wmn
 oComaDWsXh/deXq+4YMXFVIdDssWLqVkEwb//dTjelTadR3jEVhg99VvK3uW21t37iCwfC7oPfIvsCeRZza7ltQlgnQqqrijMJxISVg7/cOdfLC9likn+n6B
 OblLK/zKLJCXVSM6a03oyWXPDXfqD8pBGqJABh9Ps/X5Gun8efR3ulUTARJSMG4yW6DGFGsHfT0PcoCcZw7CUE4EMlGkyP916b0Ppu4z
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/19/2019 4:03 AM, Ira Weiny wrote:
> On Tue, Mar 19, 2019 at 04:36:44PM +0100, Jan Kara wrote:
>> On Tue 19-03-19 17:29:18, Kirill A. Shutemov wrote:
>>> On Tue, Mar 19, 2019 at 10:14:16AM -0400, Jerome Glisse wrote:
>>>> On Tue, Mar 19, 2019 at 09:47:24AM -0400, Jerome Glisse wrote:
>>>>> On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
>>>>>> On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
>>>>>>> From: John Hubbard <jhubbard@nvidia.com>
>>>>>
>>>>> [...]
>>>>>
>>>>>>> diff --git a/mm/gup.c b/mm/gup.c
>>>>>>> index f84e22685aaa..37085b8163b1 100644
>>>>>>> --- a/mm/gup.c
>>>>>>> +++ b/mm/gup.c
>>>>>>> @@ -28,6 +28,88 @@ struct follow_page_context {
>>>>>>>   	unsigned int page_mask;
>>>>>>>   };
>>>>>>>   
>>>>>>> +typedef int (*set_dirty_func_t)(struct page *page);
>>>>>>> +
>>>>>>> +static void __put_user_pages_dirty(struct page **pages,
>>>>>>> +				   unsigned long npages,
>>>>>>> +				   set_dirty_func_t sdf)
>>>>>>> +{
>>>>>>> +	unsigned long index;
>>>>>>> +
>>>>>>> +	for (index = 0; index < npages; index++) {
>>>>>>> +		struct page *page = compound_head(pages[index]);
>>>>>>> +
>>>>>>> +		if (!PageDirty(page))
>>>>>>> +			sdf(page);
>>>>>>
>>>>>> How is this safe? What prevents the page to be cleared under you?
>>>>>>
>>>>>> If it's safe to race clear_page_dirty*() it has to be stated explicitly
>>>>>> with a reason why. It's not very clear to me as it is.
>>>>>
>>>>> The PageDirty() optimization above is fine to race with clear the
>>>>> page flag as it means it is racing after a page_mkclean() and the
>>>>> GUP user is done with the page so page is about to be write back
>>>>> ie if (!PageDirty(page)) see the page as dirty and skip the sdf()
>>>>> call while a split second after TestClearPageDirty() happens then
>>>>> it means the racing clear is about to write back the page so all
>>>>> is fine (the page was dirty and it is being clear for write back).
>>>>>
>>>>> If it does call the sdf() while racing with write back then we
>>>>> just redirtied the page just like clear_page_dirty_for_io() would
>>>>> do if page_mkclean() failed so nothing harmful will come of that
>>>>> neither. Page stays dirty despite write back it just means that
>>>>> the page might be write back twice in a row.
>>>>
>>>> Forgot to mention one thing, we had a discussion with Andrea and Jan
>>>> about set_page_dirty() and Andrea had the good idea of maybe doing
>>>> the set_page_dirty() at GUP time (when GUP with write) not when the
>>>> GUP user calls put_page(). We can do that by setting the dirty bit
>>>> in the pte for instance. They are few bonus of doing things that way:
>>>>      - amortize the cost of calling set_page_dirty() (ie one call for
>>>>        GUP and page_mkclean()
>>>>      - it is always safe to do so at GUP time (ie the pte has write
>>>>        permission and thus the page is in correct state)
>>>>      - safe from truncate race
>>>>      - no need to ever lock the page
>>>>
>>>> Extra bonus from my point of view, it simplify thing for my generic
>>>> page protection patchset (KSM for file back page).
>>>>
>>>> So maybe we should explore that ? It would also be a lot less code.
>>>
>>> Yes, please. It sounds more sensible to me to dirty the page on get, not
>>> on put.
>>
>> I fully agree this is a desirable final state of affairs.
> 
> I'm glad to see this presented because it has crossed my mind more than once
> that effectively a GUP pinned page should be considered "dirty" at all times
> until the pin is removed.  This is especially true in the RDMA case.

But, what if the RDMA registration is readonly? That's not uncommon, and
marking dirty unconditonally would add needless overhead to such pages.

Tom.

