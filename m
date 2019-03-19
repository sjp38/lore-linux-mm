Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8BC9C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 20:55:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54B22213F2
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 20:55:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54B22213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=talpey.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7F116B0005; Tue, 19 Mar 2019 16:55:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E04FE6B0006; Tue, 19 Mar 2019 16:55:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCD616B0007; Tue, 19 Mar 2019 16:55:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7E46B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:55:27 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id d64so7163ywa.17
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 13:55:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=YUCF5iT8WZ1bs0Asu5Ul8X8Z6auVA0aar4nuYXpbU0Y=;
        b=DuEd2jCCUl+RNvQPPFr85eo8eH5KgYtKVjzV0U/JDm+sglgmCe59iQ1jUDpmLKjOkw
         sV7NGols1nS2ymHo4arPAd3lGzhf65lmvWuEbXfu90l5C1d+XcwWx2+Ve+AoRNZ305ta
         xKcLTabHubQuN2FKDPKFisQWe5DQc24Ee77fXhgOme1hOl4bkzdsFT/rr0kBzSPZ/CDL
         Q1A/aiUob78LPlS/gr00QY80TTQivxOItBwKvk3XW92XYp5rw/V+p/8bVU52wHhB1Kpw
         zEgyu7uyXWLWfGqI+51tjKkOlcKILVWoQ7fxHBHiCWb0AfKZyGLuJk9Y/rOD8KqJx9ed
         KWvg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 68.178.252.110 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
X-Gm-Message-State: APjAAAU1beUS2mvHz1v7yg+KbOr1wGcGa+rtIMAjwuAL+KAxyyzvTiW9
	uT+I55yLmpuvmtsfho10WqSGl6znv0mnKoTfyZN7TD5H/BGf7Dth2LtWoZj6VFln8lRIRFgQS5H
	eVzCmB9n1HvLZ7CHoNu6wcSGELpvfeo5kKL4IrnEHSiNzx79kXI9rLatVpKiqTEg=
X-Received: by 2002:a81:6044:: with SMTP id u65mr3736774ywb.88.1553028927390;
        Tue, 19 Mar 2019 13:55:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUJhkmUY7pORRHJdydmU6PfEHkU6Cwq1ZGGNzqOX/vxYQuawqBTqomovlzdXOKRduikdEB
X-Received: by 2002:a81:6044:: with SMTP id u65mr3736720ywb.88.1553028926379;
        Tue, 19 Mar 2019 13:55:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553028926; cv=none;
        d=google.com; s=arc-20160816;
        b=Rn2ba8PXqtuJB/PFlGi6VBY/ilHqLwHqJUrUSDSgXxZV6xhLXmX0FfzAyj/P/4hDKK
         Emepy8aEQZEkyLr20ZjuCYOgZDZW/FkDfsefDHWesuMSV0D4Wj6lXof2zW4RsiX+wwNT
         hmYdRPiOqbNgIL9YezXc5jYTTwaueuzVae1Bnh5IZuW3j5jBeBgjFHwAqYAGAT5VHpbM
         Lj4IhjpDKuw0YUFaUTa9FDIoOLO67VrOR6YwwzYL+oY7OsroJon+XJ1RLBnfB6nxjJSv
         aRUUgcKhty15hvB4WEtLPc4QXXX6+4FiisU2jB/CxOL3G/ikQGqvl7kby3dLGNP26q0Y
         z5OQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=YUCF5iT8WZ1bs0Asu5Ul8X8Z6auVA0aar4nuYXpbU0Y=;
        b=Mosgz8X68fhyQHweW11AYAbdqbVxWpMW3E2OnRP1+1EnaRXZSmgDWQUgF1nNFQkSDg
         ZWNYykyDYIGDn42uMgiSn3zLbehHoAcFYGjrS/9SnxZOMcj8WL8/aQ3NMaetpVcmE/KP
         67WKYQi1nyGPDXt7gFLmlB+gwCwfJShjQfp2hZb7qcwfdihs1rF3FzXpH++sihVfCFFC
         d3TmlswmxCJOdwKVMJcg18O7Mh1vEKxmiO2iJ5U3p4WfZQGsc4hGkwuF7CsDkAzNQN8Z
         DOrWRXxEzcKZIacNdOI+UYkLYn4EkHztDsPN2+9R4fYVcq+0F8qMHgXdj7TX7Mp6xnr7
         CuPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 68.178.252.110 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
Received: from p3plsmtpa11-09.prod.phx3.secureserver.net (p3plsmtpa11-09.prod.phx3.secureserver.net. [68.178.252.110])
        by mx.google.com with ESMTPS id h128si25006ybh.489.2019.03.19.13.55.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 13:55:26 -0700 (PDT)
Received-SPF: neutral (google.com: 68.178.252.110 is neither permitted nor denied by best guess record for domain of tom@talpey.com) client-ip=68.178.252.110;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 68.178.252.110 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
Received: from [10.10.38.206] ([139.138.146.66])
	by :SMTPAUTH: with ESMTPSA
	id 6Llch3MG7QWsA6LlchfylR; Tue, 19 Mar 2019 13:55:25 -0700
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
To: Jerome Glisse <jglisse@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
 "Kirill A. Shutemov" <kirill@shutemov.name>, john.hubbard@gmail.com,
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
 <f9195df4-66ca-95f6-874e-d19cd775794d@talpey.com>
 <20190319204512.GB3096@redhat.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <0bdce970-1ec4-6bda-b82a-015fa68535a3@talpey.com>
Date: Tue, 19 Mar 2019 15:55:23 -0500
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190319204512.GB3096@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CMAE-Envelope: MS4wfMVa2shDUX+qImuuG9eO58HEKoL7WNIRscvVfrd3/c/hyQmzZqjN/V9bvlUbC8/EbcvuePnPxhhkYoRNhkkGkPKJMYMnFrBd7bkdhD8Lqc2/8QJxDpW8
 FwUnpH7vpLy0rFhtpSBAKBjJ6yr6DUn1Lc2ndWvyK446f3yIA+o0dJv94gKEbCQ7M4CnP1cpG9qmvkEkKClKzUSYeV8qEXoH1I89L4L4PhHbfED87+idqKaO
 BTZcmi2y62gW4ZU7z2kCstuaa+XQ7vbch5oK8aXuI2y8SoHKfel8ZviHUIyLr9L52jcVRkrBx3m7bLgG5mdADZ/Tbu52umTn13TuTtK8CGuEtb9ODBTOX1yt
 X24YGGj/x0C9mIZl18gNTaa+HcPdAmasOr3LD2Loyx5v4Zqds/IeiDmUFMtwIa9ED7uTI2bdSMX5zPRyj2qqMFX5fIQQ+f7Dl9aT+Qkkf/Ut8y7oR1ZQ1Lcw
 PLHwr8JmQCTHM/GoyKv3lIv1Q68bL+oPdmMEhUi/QquXWcjbnpWIMJoR/UBFpmV2EYbINs3FoogX5Lwu6M6cwy5kiNXy/6VXse6lcbUuowawXAn9RA3ye3tg
 DVd+8K1Fx/NE/BXuSYH3fQgp2Tm0vSjPw0GsTmODQjneFb5axER1dYvZ/fYf+icUwu6w97noG4AOC5Mjvtus7IDFzddULflgke/IuKJVwNvjPNTC49RZStRP
 pu4HoAAFs2FHNNJ6pbH5Vm4eM5Xuf/xHBJf2XKhpGF39oQZKk7cJ6w7T8TqMS1KIxRTZ3w6uLEiR6eNa+0KF/Xu5DHZxLQUio/JVf7QIed7zMAEbRAEt91Jy
 JnxvLb4jr+1BTzgJoJtr6nCVMWbQn/dVwPmOgpqCf9TTN7tTpy8mLKtoQ4PnocvShgzwXlA1F+jsMHLnJhI+/7PCnYrDCNqXnCL7nCAO
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/19/2019 3:45 PM, Jerome Glisse wrote:
> On Tue, Mar 19, 2019 at 03:43:44PM -0500, Tom Talpey wrote:
>> On 3/19/2019 4:03 AM, Ira Weiny wrote:
>>> On Tue, Mar 19, 2019 at 04:36:44PM +0100, Jan Kara wrote:
>>>> On Tue 19-03-19 17:29:18, Kirill A. Shutemov wrote:
>>>>> On Tue, Mar 19, 2019 at 10:14:16AM -0400, Jerome Glisse wrote:
>>>>>> On Tue, Mar 19, 2019 at 09:47:24AM -0400, Jerome Glisse wrote:
>>>>>>> On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
>>>>>>>> On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
>>>>>>>>> From: John Hubbard <jhubbard@nvidia.com>
>>>>>>>
>>>>>>> [...]
>>>>>>>
>>>>>>>>> diff --git a/mm/gup.c b/mm/gup.c
>>>>>>>>> index f84e22685aaa..37085b8163b1 100644
>>>>>>>>> --- a/mm/gup.c
>>>>>>>>> +++ b/mm/gup.c
>>>>>>>>> @@ -28,6 +28,88 @@ struct follow_page_context {
>>>>>>>>>    	unsigned int page_mask;
>>>>>>>>>    };
>>>>>>>>> +typedef int (*set_dirty_func_t)(struct page *page);
>>>>>>>>> +
>>>>>>>>> +static void __put_user_pages_dirty(struct page **pages,
>>>>>>>>> +				   unsigned long npages,
>>>>>>>>> +				   set_dirty_func_t sdf)
>>>>>>>>> +{
>>>>>>>>> +	unsigned long index;
>>>>>>>>> +
>>>>>>>>> +	for (index = 0; index < npages; index++) {
>>>>>>>>> +		struct page *page = compound_head(pages[index]);
>>>>>>>>> +
>>>>>>>>> +		if (!PageDirty(page))
>>>>>>>>> +			sdf(page);
>>>>>>>>
>>>>>>>> How is this safe? What prevents the page to be cleared under you?
>>>>>>>>
>>>>>>>> If it's safe to race clear_page_dirty*() it has to be stated explicitly
>>>>>>>> with a reason why. It's not very clear to me as it is.
>>>>>>>
>>>>>>> The PageDirty() optimization above is fine to race with clear the
>>>>>>> page flag as it means it is racing after a page_mkclean() and the
>>>>>>> GUP user is done with the page so page is about to be write back
>>>>>>> ie if (!PageDirty(page)) see the page as dirty and skip the sdf()
>>>>>>> call while a split second after TestClearPageDirty() happens then
>>>>>>> it means the racing clear is about to write back the page so all
>>>>>>> is fine (the page was dirty and it is being clear for write back).
>>>>>>>
>>>>>>> If it does call the sdf() while racing with write back then we
>>>>>>> just redirtied the page just like clear_page_dirty_for_io() would
>>>>>>> do if page_mkclean() failed so nothing harmful will come of that
>>>>>>> neither. Page stays dirty despite write back it just means that
>>>>>>> the page might be write back twice in a row.
>>>>>>
>>>>>> Forgot to mention one thing, we had a discussion with Andrea and Jan
>>>>>> about set_page_dirty() and Andrea had the good idea of maybe doing
>>>>>> the set_page_dirty() at GUP time (when GUP with write) not when the
>>>>>> GUP user calls put_page(). We can do that by setting the dirty bit
>>>>>> in the pte for instance. They are few bonus of doing things that way:
>>>>>>       - amortize the cost of calling set_page_dirty() (ie one call for
>>>>>>         GUP and page_mkclean()
>>>>>>       - it is always safe to do so at GUP time (ie the pte has write
>>>>>>         permission and thus the page is in correct state)
>>>>>>       - safe from truncate race
>>>>>>       - no need to ever lock the page
>>>>>>
>>>>>> Extra bonus from my point of view, it simplify thing for my generic
>>>>>> page protection patchset (KSM for file back page).
>>>>>>
>>>>>> So maybe we should explore that ? It would also be a lot less code.
>>>>>
>>>>> Yes, please. It sounds more sensible to me to dirty the page on get, not
>>>>> on put.
>>>>
>>>> I fully agree this is a desirable final state of affairs.
>>>
>>> I'm glad to see this presented because it has crossed my mind more than once
>>> that effectively a GUP pinned page should be considered "dirty" at all times
>>> until the pin is removed.  This is especially true in the RDMA case.
>>
>> But, what if the RDMA registration is readonly? That's not uncommon, and
>> marking dirty unconditonally would add needless overhead to such pages.
> 
> Yes and this is only when FOLL_WRITE is set ie when you are doing GUP and
> asking for write. Doing GUP and asking for read is always safe.

Aha, ok great.

I guess it does introduce something for callers to be aware of, if
they GUP very large regions. I suppose if they're sufficiently aware
of the situation, e.g. pnfs LAYOUT_COMMIT notifications, they could
walk lists and reset page_dirty for untouched pages before releasing.
That's their issue though, and agreed it's safest for the GUP layer
to mark.

Tom.

