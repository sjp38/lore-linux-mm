Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 920376B000D
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 16:00:27 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id f8-v6so10163580qth.9
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 13:00:27 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s1-v6si805221qte.304.2018.07.05.13.00.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 13:00:26 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 13/13] libnvdimm, namespace: Publish page structure init state / control
References: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
	<153077341292.40830.11333232703318633087.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20180705082931.echvdqipgvwhghf2@linux-x5ow.site>
	<CAPcyv4h1L6ZMCqWXhWD_ZJ=sH7SVzuUGMG2Ln=6Cy6sR4S=VUw@mail.gmail.com>
	<20180705194936.GA28447@bombadil.infradead.org>
	<CAPcyv4jHG9jCWz_hVc8DPxxALQ2JyD=AJKuYn6-ZMhB_fot1-Q@mail.gmail.com>
Date: Thu, 05 Jul 2018 16:00:25 -0400
In-Reply-To: <CAPcyv4jHG9jCWz_hVc8DPxxALQ2JyD=AJKuYn6-ZMhB_fot1-Q@mail.gmail.com>
	(Dan Williams's message of "Thu, 5 Jul 2018 12:52:07 -0700")
Message-ID: <x49tvpd78rq.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, Johannes Thumshirn <jthumshirn@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Vishal Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, Christoph Hellwig <hch@lst.de>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Dan Williams <dan.j.williams@intel.com> writes:

> On Thu, Jul 5, 2018 at 12:49 PM, Matthew Wilcox <willy@infradead.org> wrote:
>> On Thu, Jul 05, 2018 at 07:46:05AM -0700, Dan Williams wrote:
>>> On Thu, Jul 5, 2018 at 1:29 AM, Johannes Thumshirn <jthumshirn@suse.de> wrote:
>>> > On Wed, Jul 04, 2018 at 11:50:13PM -0700, Dan Williams wrote:
>>> >> +static ssize_t memmap_state_store(struct device *dev,
>>> >> +             struct device_attribute *attr, const char *buf, size_t len)
>>> >> +{
>>> >> +     int i;
>>> >> +     struct nd_pfn *nd_pfn = to_nd_pfn_safe(dev);
>>> >> +     struct memmap_async_state *async = &nd_pfn->async;
>>> >> +
>>> >> +     if (strcmp(buf, "sync") == 0)
>>> >> +             /* pass */;
>>> >> +     else if (strcmp(buf, "sync\n") == 0)
>>> >> +             /* pass */;
>>> >> +     else
>>> >> +             return -EINVAL;
>>> >
>>> > Hmm what about:
>>> >
>>> >         if (strncmp(buf, "sync", 4))
>>> >            return -EINVAL;
>>> >
>>> > This collapses 6 lines into 4.
>>>
>>> ...but that also allows 'echo "syncAndThenSomeGarbage" >
>>> /sys/.../memmap_state' to succeed.
>>
>>         if (strncmp(buf, "sync", 4))
>>                 return -EINVAL;
>>         if (buf[4] != '\0' && buf[4] != '\n')
>>                 return -EINVAL;
>>
>
> Not sure that's a win either, I'd rather just:
>
> +       if (strcmp(buf, "sync") == 0 || strcmp(buf, "sync\n") == 0)
> +               /* pass */;
> +       else
> +               return -EINVAL;
>
> If we're trying to save those 2 lines.

WFM.  I don't like that I had to go digging around in sysfs
documentation to convince myself that strcmp was safe, but I guess
that's my problem.  ;-)

Cheers,
Jeff
