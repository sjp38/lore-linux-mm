Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5222F6B0007
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 15:49:44 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id bf1-v6so2770759plb.2
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 12:49:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f12-v6si5891603pgo.203.2018.07.05.12.49.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Jul 2018 12:49:43 -0700 (PDT)
Date: Thu, 5 Jul 2018 12:49:36 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 13/13] libnvdimm, namespace: Publish page structure init
 state / control
Message-ID: <20180705194936.GA28447@bombadil.infradead.org>
References: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153077341292.40830.11333232703318633087.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180705082931.echvdqipgvwhghf2@linux-x5ow.site>
 <CAPcyv4h1L6ZMCqWXhWD_ZJ=sH7SVzuUGMG2Ln=6Cy6sR4S=VUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4h1L6ZMCqWXhWD_ZJ=sH7SVzuUGMG2Ln=6Cy6sR4S=VUw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Johannes Thumshirn <jthumshirn@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Vishal Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, Jeff Moyer <jmoyer@redhat.com>, Christoph Hellwig <hch@lst.de>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jul 05, 2018 at 07:46:05AM -0700, Dan Williams wrote:
> On Thu, Jul 5, 2018 at 1:29 AM, Johannes Thumshirn <jthumshirn@suse.de> wrote:
> > On Wed, Jul 04, 2018 at 11:50:13PM -0700, Dan Williams wrote:
> >> +static ssize_t memmap_state_store(struct device *dev,
> >> +             struct device_attribute *attr, const char *buf, size_t len)
> >> +{
> >> +     int i;
> >> +     struct nd_pfn *nd_pfn = to_nd_pfn_safe(dev);
> >> +     struct memmap_async_state *async = &nd_pfn->async;
> >> +
> >> +     if (strcmp(buf, "sync") == 0)
> >> +             /* pass */;
> >> +     else if (strcmp(buf, "sync\n") == 0)
> >> +             /* pass */;
> >> +     else
> >> +             return -EINVAL;
> >
> > Hmm what about:
> >
> >         if (strncmp(buf, "sync", 4))
> >            return -EINVAL;
> >
> > This collapses 6 lines into 4.
> 
> ...but that also allows 'echo "syncAndThenSomeGarbage" >
> /sys/.../memmap_state' to succeed.

	if (strncmp(buf, "sync", 4))
		return -EINVAL;
	if (buf[4] != '\0' && buf[4] != '\n')
		return -EINVAL;
