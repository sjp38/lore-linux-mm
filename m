Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9623A6B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 10:46:07 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id q11-v6so7775907oih.15
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 07:46:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k2-v6sor61358oif.309.2018.07.05.07.46.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 07:46:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180705082931.echvdqipgvwhghf2@linux-x5ow.site>
References: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153077341292.40830.11333232703318633087.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180705082931.echvdqipgvwhghf2@linux-x5ow.site>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 5 Jul 2018 07:46:05 -0700
Message-ID: <CAPcyv4h1L6ZMCqWXhWD_ZJ=sH7SVzuUGMG2Ln=6Cy6sR4S=VUw@mail.gmail.com>
Subject: Re: [PATCH 13/13] libnvdimm, namespace: Publish page structure init
 state / control
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Vishal Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, Jeff Moyer <jmoyer@redhat.com>, Christoph Hellwig <hch@lst.de>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jul 5, 2018 at 1:29 AM, Johannes Thumshirn <jthumshirn@suse.de> wrote:
> On Wed, Jul 04, 2018 at 11:50:13PM -0700, Dan Williams wrote:
>> +static ssize_t memmap_state_store(struct device *dev,
>> +             struct device_attribute *attr, const char *buf, size_t len)
>> +{
>> +     int i;
>> +     struct nd_pfn *nd_pfn = to_nd_pfn_safe(dev);
>> +     struct memmap_async_state *async = &nd_pfn->async;
>> +
>> +     if (strcmp(buf, "sync") == 0)
>> +             /* pass */;
>> +     else if (strcmp(buf, "sync\n") == 0)
>> +             /* pass */;
>> +     else
>> +             return -EINVAL;
>
> Hmm what about:
>
>         if (strncmp(buf, "sync", 4))
>            return -EINVAL;
>
> This collapses 6 lines into 4.

...but that also allows 'echo "syncAndThenSomeGarbage" >
/sys/.../memmap_state' to succeed.
