Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3586B0023
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:12:49 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id c11so4587115wrf.4
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 09:12:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r74si5322035wrb.249.2018.03.22.09.12.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Mar 2018 09:12:47 -0700 (PDT)
Date: Thu, 22 Mar 2018 17:12:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
Message-ID: <20180322161246.GG23100@dhcp22.suse.cz>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180321131449.GN23100@dhcp22.suse.cz>
 <8e0ded7b-4be4-fa25-f40c-d3116a6db4db@linux.alibaba.com>
 <cf87ade4-5a5c-3919-0fc6-acc40e12659b@linux.alibaba.com>
 <20180321212355.GR23100@dhcp22.suse.cz>
 <952dcae2-a73e-0726-3cc5-9b6a63b417b7@linux.alibaba.com>
 <20180322091008.GZ23100@dhcp22.suse.cz>
 <8b4407dd-78f6-2f6f-3f45-ddb8a2d805c8@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8b4407dd-78f6-2f6f-3f45-ddb8a2d805c8@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 22-03-18 09:06:14, Yang Shi wrote:
> 
> 
> On 3/22/18 2:10 AM, Michal Hocko wrote:
> > On Wed 21-03-18 15:36:12, Yang Shi wrote:
> > > 
> > > On 3/21/18 2:23 PM, Michal Hocko wrote:
[...]
> > > > pages and that is quite easy to move out of the write lock. That would
> > > > be an improvement already and it should be risk safe. If even that is
> > > > not sufficient then using range locking should help a lot. There
> > > > shouldn't be really any other address space operations within the range
> > > > most of the time so this would be basically non-contended access.
> > > It might depend on how the range is defined. Too big range may lead to
> > > surprisingly more contention, but too small range may bring in too much
> > > lock/unlock operations.
> > The full vma will have to be range locked. So there is nothing small or large.
> 
> It sounds not helpful to a single large vma case since just one range lock
> for the vma, it sounds equal to mmap_sem.

This is not how the range locking works. If we have a range lock per mm
then exclusive ranges are not contending. So if you are unmapping one
vma and want to create a new mapping or fault into a different range
then you are basically lockless.

-- 
Michal Hocko
SUSE Labs
